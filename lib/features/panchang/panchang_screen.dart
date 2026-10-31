import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../app/providers.dart';
import '../../core/astro/vedic/panchang.dart';
import '../../core/i18n/astro_names.dart';
import '../../core/models/profile.dart';
import '../../core/services/ads_service.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/format.dart';
import '../../ui/widgets/common.dart';
import '../profiles/place_search_sheet.dart';
import '../../ui/widgets/tool_info_button.dart';

/// Place used for daily timings: chosen Panchang place, else the user's own
/// birthplace, else New Delhi.
final panchangPlaceProvider = Provider<Place>((ref) {
  final chosen = ref.watch(settingsProvider.select((s) => s.panchangPlace));
  if (chosen != null) return chosen;
  final self = ref.watch(profilesProvider).where((p) => p.isSelf && p.place != null).firstOrNull;
  // Daily timings belong to where the user is now. Keep the birthplace when it
  // shares the phone's timezone (more precise); otherwise use the largest city
  // in the phone's timezone (e.g. an NRI living abroad).
  final deviceTz = ref.watch(deviceTimezoneProvider);
  if (self?.place != null && self!.place!.timezoneId == deviceTz) return self.place!;
  final local = ref.watch(placeDatabaseProvider).value?.largestInTimezone(deviceTz);
  if (local != null) return local;
  return self?.place ??
      const Place(
        name: 'New Delhi',
        region: 'Delhi',
        countryCode: 'IN',
        latitude: 28.6139,
        longitude: 77.2090,
        timezoneId: 'Asia/Kolkata',
      );
});

final panchangProvider = Provider.family<Panchang, DateTime>((ref, date) {
  final place = ref.watch(panchangPlaceProvider);
  final ayanamsa = ref.watch(settingsProvider.select((s) => s.calc.ayanamsa));
  final loc = tz.getLocation(place.timezoneId);
  final offset = tz.TZDateTime(loc, date.year, date.month, date.day, 12).timeZoneOffset;
  return PanchangCalculator.compute(
    date: date,
    latitude: place.latitude,
    longitude: place.longitude,
    utcOffset: offset,
    ayanamsa: ayanamsa,
  );
});

DateTime todayAt(Place place) {
  final now = tz.TZDateTime.now(tz.getLocation(place.timezoneId));
  return DateTime(now.year, now.month, now.day);
}

class PanchangScreen extends ConsumerStatefulWidget {
  const PanchangScreen({super.key});

  @override
  ConsumerState<PanchangScreen> createState() => _PanchangScreenState();
}

class _PanchangScreenState extends ConsumerState<PanchangScreen> {
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final place = ref.watch(panchangPlaceProvider);
    final date = _date ?? todayAt(place);
    final p = ref.watch(panchangProvider(date));
    final tzId = place.timezoneId;
    // Show the date too when a time falls on another day (e.g. a tithi that
    // ends after midnight).
    String t(DateTime? d) {
      if (d == null) return '—';
      final local = Fmt.toLocal(d, tzId);
      final sameDay = local.year == date.year && local.month == date.month && local.day == date.day;
      return sameDay ? Fmt.time(d, tzId) : '${DateFormat.MMMd().format(local)}, ${Fmt.time(d, tzId)}';
    }

    final nowUtc = DateTime.now().toUtc();
    final names = AstroNames.of(Localizations.localeOf(context).languageCode);
    final tithi = '${names.pakshaFromEnglish(p.paksha)} ${names.tithi(p.tithi.index)}';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l.navPanchang),
        actions: [
          const ToolInfoButton(toolId: 'panchang'),
          IconButton(
            tooltip: l.changePlace,
            icon: const Icon(Icons.place_outlined),
            onPressed: () async {
              final np = await showPlaceSearch(context);
              if (np != null) {
                ref.read(settingsProvider.notifier).update((s) => s.copyWith(panchangPlace: () => np));
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() => _date = date.subtract(const Duration(days: 1))),
              ),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(1800),
                      lastDate: DateTime(2399),
                    );
                    if (d != null) setState(() => _date = d);
                  },
                  child: Column(
                    children: [
                      Text(Fmt.date(date), style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        place.displayName,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() => _date = date.add(const Duration(days: 1))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SectionCard(
            title: '${names.vara(p.vara)} · $tithi',
            icon: Icons.brightness_3_outlined,
            child: Column(
              children: [
                KeyValueRow(l.tithi, '$tithi · ${l.untilDate(t(p.tithi.endsAt))}', highlight: true),
                KeyValueRow(
                  l.nakshatra,
                  '${names.nakshatra(p.nakshatra.index)} · ${l.untilDate(t(p.nakshatra.endsAt))}',
                ),
                KeyValueRow(l.yoga, '${names.yoga(p.yoga.index)} · ${l.untilDate(t(p.yoga.endsAt))}'),
                KeyValueRow(l.karana, '${names.karana(p.karana.index)} · ${l.untilDate(t(p.karana.endsAt))}'),
                KeyValueRow(l.moonSign, names.rashi(p.moonSign)),
                KeyValueRow(l.sunSign, names.rashi(p.sunSign)),
                KeyValueRow(
                  l.lunarMonth,
                  '${names.monthFromEnglish(p.lunarMonthAmanta)} (${l.amanta}) · ${names.monthFromEnglish(p.lunarMonthPurnimanta)} (${l.purnimanta})',
                ),
                KeyValueRow(l.samvat, '${names.vikram} ${p.vikramSamvat} · ${names.shaka} ${p.shakaSamvat}'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SectionCard(
            title: l.sunMoon,
            icon: Icons.wb_twilight,
            child: Column(
              children: [
                KeyValueRow(l.sunrise, t(p.sunrise)),
                KeyValueRow(l.sunset, t(p.sunset)),
                KeyValueRow(l.moonrise, t(p.moonrise)),
                KeyValueRow(l.moonset, t(p.moonset)),
              ],
            ),
          ),
          const NativeSlot(medium: false),
          const SizedBox(height: 10),
          SectionCard(
            title: l.timings,
            icon: Icons.schedule,
            child: Column(
              children: [
                if (p.abhijit != null) _SpanRow(span: p.abhijit!, tzId: tzId, label: l.abhijit, now: nowUtc),
                _SpanRow(span: p.rahuKaal, tzId: tzId, label: l.rahuKaal, now: nowUtc),
                _SpanRow(span: p.yamaganda, tzId: tzId, label: l.yamaganda, now: nowUtc),
                _SpanRow(span: p.gulika, tzId: tzId, label: l.gulika, now: nowUtc),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _ExpandableSpans(
            title: l.dayChoghadiya,
            spans: p.dayChoghadiya,
            tzId: tzId,
            now: nowUtc,
            labelOf: (s) => names.choghadiyaFromEnglish(s.label),
          ),
          const SizedBox(height: 10),
          _ExpandableSpans(
            title: l.nightChoghadiya,
            spans: p.nightChoghadiya,
            tzId: tzId,
            now: nowUtc,
            labelOf: (s) => names.choghadiyaFromEnglish(s.label),
          ),
          const SizedBox(height: 10),
          _ExpandableSpans(
            title: l.hora,
            spans: p.horas,
            tzId: tzId,
            now: nowUtc,
            labelOf: (s) => names.horaFromEnglish(s.label),
          ),
          const SizedBox(height: 12),
          SourceNote(l.panchangNote),
          const BannerSlot(),
        ],
      ),
    );
  }
}

class _SpanRow extends StatelessWidget {
  const _SpanRow({required this.span, required this.tzId, required this.label, required this.now});
  final TimeSpan span;
  final String tzId;
  final String label;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = span.good == null ? null : (span.good! ? scheme.secondary : scheme.error);
    final active = span.contains(now);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(span.good == false ? Icons.remove_circle_outline : Icons.check_circle_outline, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: TextStyle(fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
          ),
          Text(
            '${Fmt.time(span.start, tzId)} – ${Fmt.time(span.end, tzId)}',
            style: TextStyle(fontWeight: active ? FontWeight.w700 : FontWeight.w400),
          ),
        ],
      ),
    );
  }
}

class _ExpandableSpans extends StatelessWidget {
  const _ExpandableSpans({
    required this.title,
    required this.spans,
    required this.tzId,
    required this.now,
    this.labelOf,
  });
  final String title;
  final List<TimeSpan> spans;
  final String tzId;
  final DateTime now;
  final String Function(TimeSpan)? labelOf;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        shape: const Border(),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [for (final s in spans) _SpanRow(span: s, tzId: tzId, label: labelOf?.call(s) ?? s.label, now: now)],
      ),
    );
  }
}
