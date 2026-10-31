import 'package:flutter/material.dart';

import '../../core/astro/chart.dart';
import '../../core/astro/vedic/jaimini.dart';
import '../../core/models/profile.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/format.dart';
import '../../ui/widgets/common.dart';
import '../../ui/i18n.dart';
import '../../ui/widgets/tool_info_button.dart';

class JaiminiTab extends StatefulWidget implements HasToolGuide {
  @override
  String get toolGuideId => 'jaimini';

  const JaiminiTab({super.key, required this.chart, required this.profile});
  final Chart chart;
  final Profile profile;

  @override
  State<JaiminiTab> createState() => _JaiminiTabState();
}

class _JaiminiTabState extends State<JaiminiTab> {
  bool _eight = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final chart = widget.chart;
    final karakas = Jaimini.charaKarakas(chart, eight: _eight);
    final padas = Jaimini.arudhas(chart);
    final now = DateTime.now().toUtc();
    final dasha = Jaimini.charaDasha(chart, widget.profile.birthUtc()!);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SourceNote(l.advJaiminiIntro),
        const SizedBox(height: 12),
        SectionCard(
          title: l.advKarakas,
          icon: Icons.person_pin_circle_outlined,
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.advKarakaScheme8, style: theme.textTheme.bodyMedium),
                value: _eight,
                onChanged: (v) => setState(() => _eight = v),
              ),
              for (final k in karakas)
                KeyValueRow(
                  '${_karakaName(l, k.abbr)} (${k.abbr})',
                  '${context.names.planet(k.planet)} · ${k.degree.toStringAsFixed(2)}°',
                  highlight: k.abbr == 'AK',
                ),
              const Divider(),
              KeyValueRow(l.advKarakamsa, context.names.rashi(Jaimini.karakamsa(chart, eight: _eight))),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SectionCard(
          title: l.advArudhas,
          icon: Icons.filter_center_focus,
          child: Column(
            children: [
              KeyValueRow(l.advArudhaLagna, context.names.rashi(padas[0]), highlight: true),
              KeyValueRow(l.advUpapada, context.names.rashi(padas[11]), highlight: true),
              for (var h = 2; h <= 11; h++) KeyValueRow('A$h', context.names.rashi(padas[h - 1])),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SectionCard(
          title: l.advCharaDasha,
          icon: Icons.timelapse,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final d in dasha)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${context.names.rashi(d.sign)} · ${l.advYears(d.years)}',
                          style: d.contains(now)
                              ? theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                )
                              : theme.textTheme.bodyMedium,
                        ),
                      ),
                      Text('${Fmt.dateShort(d.start)} → ${Fmt.dateShort(d.end)}', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              SourceNote(l.advCharaDashaNote),
            ],
          ),
        ),
      ],
    );
  }
}

/// Localized chara karaka name from its standard abbreviation.
String _karakaName(AppLocalizations l, String abbr) => switch (abbr) {
  'AK' => l.advKarakaAK,
  'AmK' => l.advKarakaAmK,
  'BK' => l.advKarakaBK,
  'MK' => l.advKarakaMK,
  'PiK' => l.advKarakaPiK,
  'PK' => l.advKarakaPK,
  'GK' => l.advKarakaGK,
  _ => l.advKarakaDK,
};
