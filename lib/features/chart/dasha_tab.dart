import '../../core/services/ads_service.dart';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../../core/ai/explain_service.dart';
import '../../core/astro/chart.dart';
import '../../core/astro/vedic/dasha.dart';
import '../../core/i18n/engine_texts.dart';
import '../../core/models/profile.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/format.dart';
import '../../ui/widgets/common.dart';
import '../ai/explain_sheet.dart';

class DashaTab extends StatefulWidget {
  const DashaTab({super.key, required this.chart, required this.profile});
  final Chart chart;
  final Profile profile;

  @override
  State<DashaTab> createState() => _DashaTabState();
}

class _DashaTabState extends State<DashaTab> {
  late DashaSystem _system = Vimshottari();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final et = EngineTexts.of(Localizations.localeOf(context).languageCode);
    String name(DashaPeriod p) => _name(p, et);
    final birth = widget.profile.birthUtc()!;
    final moon = widget.chart.moon.longitude;
    final now = DateTime.now().toUtc();
    final running = _system.runningAt(birth, moon, now);
    final mahas = _system.mahadashas(birth, moon).where((m) => m.end.isAfter(birth)).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'Vimshottari', label: Text(et.dashaName('Vimshottari'))),
            ButtonSegment(value: 'Yogini', label: Text(et.dashaName('Yogini'))),
          ],
          selected: {_system.name},
          onSelectionChanged: (s) => setState(() => _system = s.first == 'Yogini' ? YoginiDasha() : Vimshottari()),
        ),
        const SizedBox(height: 8),
        Text(et.dashaDesc(_system.name), style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        if (running.isNotEmpty)
          SectionCard(
            title: l.runningNow,
            icon: Icons.timelapse,
            child: Column(
              children: [
                for (final p in running)
                  Row(
                    children: [
                      Expanded(
                        child: KeyValueRow(
                          [l.mahadasha, l.antardasha, l.pratyantardasha][p.level - 1],
                          '${name(p)} · ${l.untilDate(Fmt.date(p.end))}',
                          highlight: p.level == 1,
                        ),
                      ),
                      ExplainButton(topic: DashaTopic(p, chart: widget.chart)),
                    ],
                  ),
              ],
            ),
          ),
        if (!widget.profile.hasTime) ...[const SizedBox(height: 8), SourceNote(l.dashaApproxNote)],
        const SizedBox(height: 12),
        _comingNext(context, birth, moon, now, name),
        const NativeSlot(medium: false),
        const SizedBox(height: 12),
        _monthByMonth(context, birth, moon, now, name),
        const SizedBox(height: 12),
        for (final m in mahas)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              shape: const Border(),
              initiallyExpanded: m.contains(now),
              title: Text(name(m)),
              subtitle: Text('${Fmt.date(m.start.isBefore(birth) ? birth : m.start)} → ${Fmt.date(m.end)}'),
              children: [
                for (final a in _system.subPeriods(m))
                  ListTile(
                    dense: true,
                    selected: a.contains(now),
                    title: Text('${name(m)} / ${name(a)}'),
                    trailing: Text('${Fmt.dateShort(a.start)} → ${Fmt.dateShort(a.end)}'),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  /// "Maha / Antar / Pratyantar" names of a period and its parents.
  static String _chain(DashaPeriod p, String Function(DashaPeriod) name) =>
      [for (DashaPeriod? x = p; x != null; x = x.parent) name(x)].reversed.join(' / ');

  /// What runs next: the next sub-sub, sub and main periods, with start dates.
  Widget _comingNext(
    BuildContext context,
    DateTime birth,
    double moon,
    DateTime now,
    String Function(DashaPeriod) name,
  ) {
    final l = AppLocalizations.of(context);
    final rows = [
      for (final p in _system.upcoming(birth, moon, now, level: 3)) (l.pratyantardasha, p),
      for (final p in _system.upcoming(birth, moon, now, level: 2, count: 1)) (l.antardasha, p),
      for (final p in _system.upcoming(birth, moon, now, level: 1, count: 1)) (l.mahadasha, p),
    ];
    return SectionCard(
      title: l.dashaComingNext,
      icon: Icons.upcoming_outlined,
      child: Column(
        children: [
          for (final (label, p) in rows)
            Row(
              children: [
                Expanded(child: KeyValueRow(label, '${_chain(p, name)} · ${l.dashaFromDate(Fmt.date(p.start))}')),
                ExplainButton(topic: DashaTopic(p, chart: widget.chart)),
              ],
            ),
        ],
      ),
    );
  }

  /// The periods running in each of the next twelve months.
  Widget _monthByMonth(
    BuildContext context,
    DateTime birth,
    double moon,
    DateTime now,
    String Function(DashaPeriod) name,
  ) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return SectionCard(
      title: l.dashaMonthByMonth,
      icon: Icons.calendar_view_month_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SourceNote(l.dashaMonthNote),
          for (var i = 0; i < 12; i++) ...[
            const SizedBox(height: 10),
            Builder(
              builder: (context) {
                final from = DateTime.utc(now.year, now.month + i);
                final to = DateTime.utc(now.year, now.month + i + 1);
                final periods = _system.between(birth, moon, from, to);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat.yMMMM(locale).format(from),
                      style: theme.textTheme.titleSmall?.copyWith(color: i == 0 ? theme.colorScheme.primary : null),
                    ),
                    for (final p in periods)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_chain(p, name)} · ${Fmt.date(p.start.isBefore(from) ? from : p.start)} → '
                              '${Fmt.date(p.end.isAfter(to) ? to.subtract(const Duration(days: 1)) : p.end)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: p.contains(now) ? FontWeight.bold : null,
                              ),
                            ),
                          ),
                          ExplainButton(topic: DashaTopic(p, chart: widget.chart)),
                        ],
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  static String _name(DashaPeriod p, EngineTexts et) =>
      p.label != null ? '${et.yoginiName(p.label!)} (${et.names.planet(p.lord)})' : et.names.planet(p.lord);
}
