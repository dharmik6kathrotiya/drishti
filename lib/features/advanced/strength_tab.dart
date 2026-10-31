import 'package:flutter/material.dart';

import '../../core/astro/chart.dart';
import '../../core/astro/constants.dart';
import '../../core/astro/vedic/ashtakavarga.dart';
import '../../core/astro/vedic/shadbala.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets/common.dart';
import '../../ui/i18n.dart';
import '../../ui/widgets/tool_info_button.dart';

/// Shadbala bars and Ashtakavarga grids.
class StrengthTab extends StatelessWidget implements HasToolGuide {
  @override
  String get toolGuideId => 'shadbala';

  const StrengthTab({super.key, required this.chart});
  final Chart chart;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final shadbala = Shadbala.compute(chart);
    final av = Ashtakavarga.compute(chart);
    final maxRupas = shadbala.rows.values
        .map((r) => r.rupas > r.required ? r.rupas : r.required)
        .reduce((a, b) => a > b ? a : b);
    String f(double v) => v.toStringAsFixed(0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: l.advShadbala,
          icon: Icons.fitness_center,
          trailing: const ToolInfoButton(toolId: 'shadbala', compact: true),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.advShadbalaIntro, style: theme.textTheme.bodySmall),
              const SizedBox(height: 12),
              for (final r in Shadbala.planets.map((p) => shadbala.rows[p]!))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(context.names.planet(r.planet), style: theme.textTheme.titleSmall)),
                          Text(
                            '${l.advRupas(r.rupas.toStringAsFixed(2))} · ${l.advRequired(r.required.toString())}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _StrengthBar(value: r.rupas / maxRupas, marker: r.required / maxRupas, strong: r.ratio >= 1),
                      const SizedBox(height: 2),
                      Text(
                        l.advShadbalaParts(
                          f(r.sthana),
                          f(r.dig),
                          f(r.kalaTotal),
                          f(r.chesta),
                          f(r.naisargika),
                          f(r.drik),
                        ),
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              SourceNote(l.advShadbalaNote),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: l.advAshtakavarga,
          icon: Icons.grid_on,
          trailing: const ToolInfoButton(toolId: 'ashtakavarga', compact: true),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.advAshtakavargaIntro, style: theme.textTheme.bodySmall),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _AvTable(result: av, ascendant: chart.ascendantSign),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StrengthBar extends StatelessWidget {
  const _StrengthBar({required this.value, required this.marker, required this.strong});
  final double value;
  final double marker;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        return SizedBox(
          height: 14,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: scheme.outline.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              Container(
                width: (w * value.clamp(0, 1)).toDouble(),
                decoration: BoxDecoration(
                  color: strong ? scheme.primary : scheme.secondary.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              Positioned(
                left: (w * marker.clamp(0, 1)).toDouble() - 1,
                top: 0,
                bottom: 0,
                child: Container(width: 2, color: scheme.onSurface),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AvTable extends StatelessWidget {
  const _AvTable({required this.result, required this.ascendant});
  final AshtakavargaResult result;
  final Sign? ascendant;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall;
    final bold = style?.copyWith(fontWeight: FontWeight.w700);

    TableRow row(String label, List<int> values, {bool highlight = false}) => TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          child: Text(label, style: highlight ? bold : style),
        ),
        for (var i = 0; i < 12; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            alignment: Alignment.center,
            color: highlight && values[i] >= 28 ? theme.colorScheme.primary.withValues(alpha: 0.15) : null,
            child: Text('${values[i]}', style: highlight ? bold : style),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          child: Text('${values.fold<int>(0, (a, b) => a + b)}', style: bold),
        ),
      ],
    );

    return Table(
      defaultColumnWidth: const FixedColumnWidth(30),
      columnWidths: const {0: FixedColumnWidth(84), 13: FixedColumnWidth(44)},
      border: TableBorder(horizontalInside: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3))),
      children: [
        TableRow(
          children: [
            const SizedBox(),
            for (final s in Sign.values)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  s.symbol,
                  textAlign: TextAlign.center,
                  style: s == ascendant ? bold?.copyWith(color: theme.colorScheme.primary) : style,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(l.advTotal, style: bold),
            ),
          ],
        ),
        for (final p in Ashtakavarga.planets) row(context.names.planet(p), result.bav[p]!),
        row(l.advSav, result.sav, highlight: true),
      ],
    );
  }
}
