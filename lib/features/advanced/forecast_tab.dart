import 'package:flutter/material.dart';

import '../../core/astro/chart.dart';
import '../../core/astro/constants.dart';
import '../../core/astro/ephemeris.dart';
import '../../core/astro/settings.dart';
import '../../core/astro/western/progressions.dart';
import '../../core/astro/western/returns.dart';
import '../../core/models/profile.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/charts/chart_diagram.dart';
import '../../ui/format.dart';
import '../../ui/widgets/common.dart';
import '../../ui/i18n.dart';
import '../../ui/widgets/tool_info_button.dart';

/// Western forecasting: secondary progressions and solar/lunar returns.
class ForecastTab extends StatefulWidget implements HasToolGuide {
  @override
  String get toolGuideId => 'forecast';

  const ForecastTab({super.key, required this.chart, required this.profile});
  final Chart chart;
  final Profile profile;

  @override
  State<ForecastTab> createState() => _ForecastTabState();
}

class _ForecastTabState extends State<ForecastTab> {
  late DateTime _date = DateTime.now();
  late int _year = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final birth = widget.profile.birthUtc()!;
    final natal = widget.chart;
    final tzId = widget.profile.place?.timezoneId;
    final progressed = Progressions.progressed(natal, birth, _date.toUtc());
    final canReturn = natal.hasHouses;
    final solar = canReturn ? Returns.solarReturn(natal, birth, _year) : null;
    final solarTime = canReturn ? Returns.solarReturnTime(natal, birth, _year) : null;
    final lunar = canReturn ? Returns.lunarReturn(natal, DateTime.now().toUtc()) : null;

    List<Widget> positions(Chart c) => [
      for (final p in c.planets.values.where((p) => p.planet != Planet.ketu))
        KeyValueRow(context.names.planet(p.planet), Fmt.longitude(p.longitude)),
      if (c.ascendant != null) KeyValueRow('Asc', Fmt.longitude(c.ascendant!)),
      if (c.midheaven != null) KeyValueRow('MC', Fmt.longitude(c.midheaven!)),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: l.advProgressions,
          icon: Icons.trending_up,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.advProgressionsNote, style: theme.textTheme.bodySmall),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: Text(l.advForDate),
                subtitle: Text(Fmt.date(_date)),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: birth.toLocal(),
                    lastDate: DateTime(birth.year + 110),
                  );
                  if (d != null) setState(() => _date = d);
                },
              ),
              ...positions(progressed),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (!canReturn)
          SectionCard(child: Text(l.advNeedsTime))
        else ...[
          SectionCard(
            title: l.advSolarReturn,
            icon: Icons.wb_sunny_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.advSolarReturnNote, style: theme.textTheme.bodySmall),
                Row(
                  children: [
                    Text(l.advYear),
                    IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => setState(() => _year--)),
                    Text('$_year', style: theme.textTheme.titleMedium),
                    IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => setState(() => _year++)),
                  ],
                ),
                Text(l.advReturnMoment(Fmt.dateTime(solarTime!, tzId)), style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                Center(
                  child: ChartDiagram(chart: solar!, style: ChartStyle.westernWheel, size: 320),
                ),
                const SizedBox(height: 8),
                ...positions(solar),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: l.advLunarReturn,
            icon: Icons.nightlight_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Fmt.dateTime(Ephemeris.dateTimeFromJd(lunar!.jd), tzId), style: theme.textTheme.titleSmall),
                ...positions(lunar),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
