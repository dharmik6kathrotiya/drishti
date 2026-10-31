import '../../core/services/ads_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/astro/vedic/festivals.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/format.dart';
import '../../ui/widgets/common.dart';
import '../panchang/panchang_screen.dart';
import 'festival_texts.dart';
import '../../ui/widgets/tool_info_button.dart';

/// Festivals for one Gregorian year at the Panchang place, computed on the
/// phone. Yields to the UI first so a loading indicator can appear.
final festivalYearProvider = FutureProvider.family<List<FestivalEvent>, int>((ref, year) async {
  final place = ref.watch(panchangPlaceProvider);
  final ayanamsa = ref.watch(settingsProvider.select((s) => s.calc.ayanamsa));
  await Future<void>.delayed(const Duration(milliseconds: 32));
  return FestivalCalculator(
    latitude: place.latitude,
    longitude: place.longitude,
    timezoneId: place.timezoneId,
    ayanamsa: ayanamsa,
  ).year(year);
});

IconData festivalIcon(FestivalType t) => switch (t) {
  FestivalType.festival => Icons.celebration_outlined,
  FestivalType.vrat => Icons.self_improvement,
  FestivalType.sankranti => Icons.wb_sunny_outlined,
  FestivalType.eclipse => Icons.brightness_2_outlined,
};

Color festivalColor(ColorScheme s, FestivalType t) => switch (t) {
  FestivalType.festival => s.primary,
  FestivalType.vrat => s.secondary,
  FestivalType.sankranti => s.tertiary,
  FestivalType.eclipse => s.outline,
};

class FestivalCalendarScreen extends ConsumerStatefulWidget {
  const FestivalCalendarScreen({super.key});

  @override
  ConsumerState<FestivalCalendarScreen> createState() => _FestivalCalendarScreenState();
}

class _FestivalCalendarScreenState extends ConsumerState<FestivalCalendarScreen> {
  late DateTime _month;
  DateTime? _selected;
  FestivalType? _filter;

  @override
  void initState() {
    super.initState();
    final today = todayAt(ref.read(panchangPlaceProvider));
    _month = DateTime(today.year, today.month);
    _selected = today;
  }

  void _shiftMonth(int delta) => setState(() {
    _month = DateTime(_month.year, _month.month + delta);
    _selected = null;
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final place = ref.watch(panchangPlaceProvider);
    final today = todayAt(place);
    final events = ref.watch(festivalYearProvider(_month.year));
    final texts = FestivalTexts.of(Localizations.localeOf(context).languageCode);
    final theme = Theme.of(context);
    final loc = MaterialLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.festTitle),
        actions: [
          const ToolInfoButton(toolId: 'festivals'),
          IconButton(
            tooltip: l.festOpenMuhurat,
            icon: const Icon(Icons.event_available_outlined),
            onPressed: () => context.push('/festivals/muhurat'),
          ),
        ],
      ),
      body: events.when(
        loading: () => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [const CircularProgressIndicator(), const SizedBox(height: 12), Text(l.festLoading)],
          ),
        ),
        error: (e, _) => Center(child: Text('$e')),
        data: (all) {
          final filtered = all.where((e) => _filter == null || e.type == _filter).toList();
          final inMonth = filtered.where((e) => e.date.year == _month.year && e.date.month == _month.month).toList();
          final byDay = <DateTime, List<FestivalEvent>>{};
          for (final e in inMonth) {
            byDay.putIfAbsent(e.date, () => []).add(e);
          }
          final selectedEvents = _selected == null ? null : byDay[_selected] ?? const <FestivalEvent>[];

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _shiftMonth(-1)),
                  Expanded(
                    child: Text(
                      loc.formatMonthYear(_month),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => _shiftMonth(1)),
                ],
              ),
              Text(
                l.festCalculatedFor(place.displayName),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final (type, label) in <(FestivalType?, String)>[
                      (null, l.festAll),
                      (FestivalType.festival, l.festFestivals),
                      (FestivalType.vrat, l.festVrats),
                      (FestivalType.sankranti, l.festSankrantis),
                      (FestivalType.eclipse, l.festEclipses),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: _filter == type,
                          onSelected: (_) => setState(() => _filter = type),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _MonthGrid(
                month: _month,
                today: today,
                selected: _selected,
                byDay: byDay,
                onTap: (d) => setState(() => _selected = d),
              ),
              const SizedBox(height: 12),
              if (selectedEvents != null) ...[
                Text(Fmt.date(_selected!), style: theme.textTheme.titleSmall),
                const SizedBox(height: 6),
                if (selectedEvents.isEmpty)
                  Text(l.festNoEventsDay, style: theme.textTheme.bodyMedium)
                else
                  for (final e in selectedEvents) _EventTile(event: e, texts: texts),
                const Divider(height: 24),
              ],
              if (inMonth.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(l.festNoEventsMonth, textAlign: TextAlign.center),
                )
              else
                for (final e in inMonth) _EventTile(event: e, texts: texts, showDate: true),
              const SizedBox(height: 12),
              SourceNote(l.festDisclaimer),
              const BannerSlot(),
            ],
          );
        },
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.today,
    required this.selected,
    required this.byDay,
    required this.onTap,
  });

  final DateTime month;
  final DateTime today;
  final DateTime? selected;
  final Map<DateTime, List<FestivalEvent>> byDay;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final firstDow = loc.firstDayOfWeekIndex; // 0 = Sunday
    final first = DateTime(month.year, month.month, 1);
    final lead = (first.weekday % 7 - firstDow) % 7;
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    final cells = lead + days;
    final rows = (cells / 7).ceil();

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Text(loc.narrowWeekdays[(firstDow + i) % 7], style: Theme.of(context).textTheme.labelSmall),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        for (var r = 0; r < rows; r++)
          Row(
            children: [
              for (var c = 0; c < 7; c++)
                Expanded(
                  child: () {
                    final dayNum = r * 7 + c - lead + 1;
                    if (dayNum < 1 || dayNum > days) return const SizedBox(height: 46);
                    final d = DateTime(month.year, month.month, dayNum);
                    final ev = byDay[d] ?? const [];
                    final isSel = d == selected;
                    final isToday = d == today;
                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onTap(d),
                      child: Container(
                        height: 46,
                        margin: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          color: isSel ? scheme.primary.withValues(alpha: 0.18) : null,
                          border: isToday ? Border.all(color: scheme.primary) : null,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$dayNum',
                              style: TextStyle(
                                fontWeight: ev.any((e) => e.type == FestivalType.festival)
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (final t in {for (final e in ev) e.type}.take(3))
                                  Container(
                                    width: 5,
                                    height: 5,
                                    margin: const EdgeInsets.symmetric(horizontal: 1),
                                    decoration: BoxDecoration(color: festivalColor(scheme, t), shape: BoxShape.circle),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }(),
                ),
            ],
          ),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.texts, this.showDate = false});
  final FestivalEvent event;
  final FestivalTexts texts;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final loc = MaterialLocalizations.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(festivalIcon(event.type), color: festivalColor(scheme, event.type)),
      title: Text(texts.name(event)),
      subtitle: showDate ? Text(loc.formatMediumDate(event.date)) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/festivals/event', extra: event),
    );
  }
}
