import 'package:flutter/material.dart';

import '../../core/ai/explain_service.dart';
import '../../core/astro/chart.dart';
import '../../core/astro/constants.dart';
import '../../core/i18n/astro_names.dart';
import '../../core/models/profile.dart';
import '../../l10n/app_localizations.dart';
import '../ai/explain_sheet.dart';
import '../../ui/widgets/tool_info_button.dart';

class PlanetsTab extends StatelessWidget implements HasToolGuide {
  @override
  String get toolGuideId => 'planets';

  const PlanetsTab({super.key, required this.chart, required this.profile});
  final Chart chart;
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final vedic = chart.settings.sidereal;
    final rows = chart.planets.values.toList();
    final names = AstroNames.of(Localizations.localeOf(context).languageCode);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (chart.ascendant != null)
          _PlanetCard(
            title: vedic ? l.lagna : l.ascendant,
            symbol: 'As',
            lon: chart.ascendant!,
            explain: AscendantTopic(chart.ascendantSign!, vedic: vedic),
            details: [
              if (vedic)
                '${names.nakshatraOf(Nakshatra.fromLongitude(chart.ascendant!))} ${l.pada} ${Nakshatra.padaOf(chart.ascendant!)}',
            ],
          ),
        for (final p in rows)
          _PlanetCard(
            title: names.planet(p.planet),
            symbol: p.planet.symbol,
            lon: p.longitude,
            retro: p.isRetrograde && !p.planet.isNode,
            explain: PlanetPlacementTopic(p, vedic: vedic),
            details: [
              if (p.house != null) '${l.house} ${p.house}',
              if (vedic) '${names.nakshatraOf(p.nakshatra)} ${l.pada} ${p.pada} · ${names.planet(p.nakshatra.lord)}',
              if (p.isExalted) l.exalted,
              if (p.isDebilitated) l.debilitated,
              if (p.isOwnSign) l.ownSign,
              '${p.speed.toStringAsFixed(3)}°/${l.day}',
            ],
          ),
        const SizedBox(height: 8),
        Text(l.planetsFootnote, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _PlanetCard extends StatelessWidget {
  const _PlanetCard({
    required this.title,
    required this.symbol,
    required this.lon,
    required this.details,
    this.retro = false,
    this.explain,
  });
  final String title;
  final String symbol;
  final double lon;
  final List<String> details;
  final bool retro;
  final ExplainTopic? explain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final sign = Sign.fromLongitude(lon);
    final names = AstroNames.of(Localizations.localeOf(context).languageCode);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  symbol,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title, style: theme.textTheme.titleMedium),
                        if (retro) ...[
                          const SizedBox(width: 6),
                          Text(
                            '℞ ${l.retrograde}',
                            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.secondary),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      names.isEnglish
                          ? '${sign.symbol} ${sign.rashi} / ${names.sign(sign)}  ${formatDms(lon % 30)}'
                          : '${sign.symbol} ${names.rashi(sign)}  ${formatDms(lon % 30)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (details.isNotEmpty) Text(details.join(' · '), style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              if (explain != null) ExplainButton(topic: explain!),
            ],
          ),
        ),
      ),
    );
  }
}
