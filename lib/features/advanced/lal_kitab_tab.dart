import 'package:flutter/material.dart';

import '../../core/astro/chart.dart';
import '../../core/astro/constants.dart';
import '../../core/astro/vedic/lal_kitab.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/charts/chart_diagram.dart';
import '../../ui/charts/north_indian_painter.dart';
import '../../ui/widgets/common.dart';
import 'lal_kitab_content.dart';
import '../../ui/i18n.dart';
import '../../ui/widgets/tool_info_button.dart';

class LalKitabTab extends StatelessWidget implements HasToolGuide {
  @override
  String get toolGuideId => 'lal_kitab';

  const LalKitabTab({super.key, required this.chart});
  final Chart chart;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final inPakka = LalKitab.inPakkaGhar(chart);
    final sleeping = LalKitab.sleepingHouses(chart);

    // Lal Kitab houses are fixed to signs, so the "lagna" of the drawing is Aries.
    final view = ChartView(
      lagna: Sign.aries,
      bySign: {
        for (final s in Sign.values)
          s: [
            for (final p in LalKitab.planets)
              if (chart[p].sign == s) PlanetLabel(context.names.planetAbbr(p)),
          ],
      },
      isMoonChart: false,
      title: 'Lal Kitab',
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SourceNote(l.advLalKitabIntro),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, c) {
            final side = c.maxWidth.clamp(240.0, 420.0);
            return Center(
              child: CustomPaint(
                size: Size.square(side),
                painter: NorthIndianPainter(view: view, colors: ChartColors.of(theme)),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        SectionCard(
          child: Column(
            children: [
              KeyValueRow(l.advPakkaGhar, inPakka.isEmpty ? l.advNone : inPakka.map(context.names.planet).join(', ')),
              KeyValueRow(l.advSleepingHouses, sleeping.isEmpty ? l.advNone : sleeping.join(', ')),
              const SizedBox(height: 4),
              SourceNote(l.advSleepingNote),
            ],
          ),
        ),
        const SizedBox(height: 10),
        for (final p in LalKitab.planets)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SectionCard(
              title: '${context.names.planet(p)} · ${l.advHouseN(LalKitab.houseOf(chart, p))}',
              child: Text(lalKitabMeaning(lang, p, LalKitab.houseOf(chart, p))),
            ),
          ),
        const SizedBox(height: 4),
        SourceNote(l.advVarshphalNote),
      ],
    );
  }
}
