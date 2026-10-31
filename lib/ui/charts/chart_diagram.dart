import '../theme/app_themes.dart' show symbolFontFallback;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/astro/chart.dart';
import '../../core/astro/constants.dart';
import '../../core/astro/settings.dart';
import '../../core/astro/vedic/divisional.dart';
import '../../core/i18n/astro_names.dart';
import '../../core/i18n/engine_texts.dart';
import 'east_indian_painter.dart';
import 'north_indian_painter.dart';
import 'south_indian_painter.dart';
import 'western_wheel_painter.dart';

/// Draws a chart in any supported style. Indian styles can show any varga;
/// the Western wheel always shows the natal (D1) positions with exact degrees.
class ChartDiagram extends StatelessWidget {
  const ChartDiagram({
    super.key,
    required this.chart,
    required this.style,
    this.varga = Varga.d1,
    this.size,
    this.onHouseTap,
  });

  final Chart chart;
  final ChartStyle style;
  final Varga varga;

  /// Side length; defaults to the available width, capped at 420.
  final double? size;

  /// Called with the tapped house (1..12, counted from the lagna).
  final void Function(int house)? onHouseTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ChartColors.of(theme);
    final fontFamily = theme.textTheme.bodySmall?.fontFamily;
    final lang = Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite ? constraints.maxWidth : 320.0;
        final side = size ?? math.min(available, 420.0);
        final canvasSize = Size.square(side);

        final ChartPainterBase painter;
        if (style == ChartStyle.westernWheel) {
          painter = WesternWheelPainter(chart: chart, colors: colors, fontFamily: fontFamily);
        } else {
          final view = ChartView.from(chart, varga, lang: lang);
          painter = switch (style) {
            ChartStyle.northIndian => NorthIndianPainter(view: view, colors: colors, fontFamily: fontFamily),
            ChartStyle.southIndian => SouthIndianPainter(view: view, colors: colors, fontFamily: fontFamily),
            _ => EastIndianPainter(view: view, colors: colors, fontFamily: fontFamily),
          };
        }

        return Semantics(
          label: _semanticLabel(),
          child: SizedBox.square(
            dimension: side,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: onHouseTap == null
                  ? null
                  : (details) {
                      final house = painter.houseAt(details.localPosition, canvasSize);
                      if (house != null) onHouseTap!(house);
                    },
              child: CustomPaint(size: canvasSize, painter: painter),
            ),
          ),
        );
      },
    );
  }

  String _semanticLabel() {
    final asc = chart.ascendantSign;
    return asc == null
        ? 'Moon chart, Moon in ${chart.moon.sign.rashi}'
        : '${varga.name} chart, ascendant ${varga.signOf(chart.ascendant!).rashi}';
  }
}

/// A planet as written inside an Indian-style chart.
class PlanetLabel {
  const PlanetLabel(this.text, {this.retrograde = false, this.isAscendant = false});
  final String text;
  final bool retrograde;
  final bool isAscendant;
}

/// Sign-based view of a chart used by the Indian chart painters.
class ChartView {
  const ChartView({
    required this.lagna,
    required this.bySign,
    required this.isMoonChart,
    required this.title,
    this.moonChartLabel = 'Moon chart',
  });

  /// Reference sign for house 1: the ascendant, or the Moon (Chandra lagna)
  /// when the birth time is unknown.
  final Sign lagna;
  final Map<Sign, List<PlanetLabel>> bySign;
  final bool isMoonChart;
  final String title;

  /// Localized label shown when [isMoonChart].
  final String moonChartLabel;

  factory ChartView.from(Chart chart, Varga varga, {String lang = 'en'}) {
    final names = AstroNames.of(lang);
    final moonChart = !chart.hasHouses;
    final lagna = varga.signOf(moonChart ? chart.moon.longitude : chart.ascendant!);
    final bySign = {for (final s in Sign.values) s: <PlanetLabel>[]};
    if (!moonChart) bySign[lagna]!.add(PlanetLabel(names.ascAbbr, isAscendant: true));

    final placements = chart.planets.values.toList()..sort((a, b) => a.planet.index.compareTo(b.planet.index));
    for (final p in placements) {
      bySign[varga.signOf(p.longitude)]!.add(
        PlanetLabel(
          names.planetAbbr(p.planet),
          // Nodes always move backwards; marking them adds no information.
          retrograde: !p.planet.isNode && p.isRetrograde,
        ),
      );
    }
    return ChartView(
      lagna: lagna,
      bySign: bySign,
      isMoonChart: moonChart,
      title: varga == Varga.d1 ? names.rasiChart : '${varga.code} ${EngineTexts.of(lang).vargaName(varga)}',
      moonChartLabel: names.moonChart,
    );
  }

  int houseOf(Sign s) => lagna.countTo(s);
  Sign signOfHouse(int house) => lagna + (house - 1);
}

/// Colours derived from the active theme so charts work in every theme.
class ChartColors {
  const ChartColors({
    required this.background,
    required this.line,
    required this.signNumber,
    required this.planet,
    required this.retrograde,
    required this.ascendant,
    required this.highlight,
    required this.title,
    required this.aspectHard,
    required this.aspectSoft,
  });

  final Color background;
  final Color line;
  final Color signNumber;
  final Color planet;
  final Color retrograde;
  final Color ascendant;
  final Color highlight;
  final Color title;
  final Color aspectHard;
  final Color aspectSoft;

  factory ChartColors.of(ThemeData theme) {
    final cs = theme.colorScheme;
    return ChartColors(
      background: cs.surfaceContainerHighest.withValues(alpha: 0.35),
      line: cs.outline,
      signNumber: cs.onSurfaceVariant.withValues(alpha: 0.8),
      planet: cs.onSurface,
      retrograde: cs.tertiary,
      ascendant: cs.primary,
      highlight: cs.primary.withValues(alpha: 0.10),
      title: cs.onSurfaceVariant,
      aspectHard: cs.error.withValues(alpha: 0.65),
      aspectSoft: cs.primary.withValues(alpha: 0.65),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ChartColors &&
      other.background == background &&
      other.line == line &&
      other.signNumber == signNumber &&
      other.planet == planet &&
      other.retrograde == retrograde &&
      other.ascendant == ascendant &&
      other.highlight == highlight &&
      other.title == title &&
      other.aspectHard == aspectHard &&
      other.aspectSoft == aspectSoft;

  @override
  int get hashCode => Object.hash(
    background,
    line,
    signNumber,
    planet,
    retrograde,
    ascendant,
    highlight,
    title,
    aspectHard,
    aspectSoft,
  );
}

/// Base for all chart painters: adds hit testing for house taps.
abstract class ChartPainterBase extends CustomPainter {
  const ChartPainterBase({required this.colors, this.fontFamily});

  final ChartColors colors;
  final String? fontFamily;

  /// House (1..12) under [position], or null.
  int? houseAt(Offset position, Size size);

  TextStyle textStyle(double fontSize, Color color, {FontWeight? weight}) => TextStyle(
    fontSize: fontSize,
    color: color,
    fontWeight: weight,
    fontFamily: fontFamily,
    fontFamilyFallback: symbolFontFallback,
    height: 1.15,
  );

  /// Paints [span] centred on [center].
  void paintCentered(Canvas canvas, InlineSpan span, Offset center, {double? maxWidth}) {
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr, textAlign: TextAlign.center)
      ..layout(maxWidth: maxWidth ?? double.infinity);
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
    tp.dispose();
  }

  /// Planet labels wrapped [perLine] to a line; retrograde planets get ℞.
  TextSpan labelsSpan(List<PlanetLabel> labels, double fontSize, {int perLine = 3}) {
    final children = <InlineSpan>[];
    for (var i = 0; i < labels.length; i++) {
      final l = labels[i];
      if (i > 0) children.add(TextSpan(text: i % perLine == 0 ? '\n' : ' '));
      final color = l.isAscendant
          ? colors.ascendant
          : l.retrograde
          ? colors.retrograde
          : colors.planet;
      children.add(
        TextSpan(
          text: l.retrograde ? '${l.text}℞' : l.text,
          style: textStyle(fontSize, color, weight: l.isAscendant ? FontWeight.w700 : FontWeight.w600),
        ),
      );
    }
    return TextSpan(children: children);
  }

  /// Font size that shrinks as a region gets crowded.
  double crowdedFontSize(double base, int count, int comfortable) =>
      count <= comfortable ? base : base * math.max(0.7, comfortable / count + 0.15);

  @override
  bool shouldRepaint(covariant ChartPainterBase oldDelegate) =>
      oldDelegate.colors != colors || oldDelegate.fontFamily != fontFamily;
}

/// Centroid of a polygon's vertices.
Offset polygonCentroid(List<Offset> pts) {
  var x = 0.0, y = 0.0;
  for (final p in pts) {
    x += p.dx;
    y += p.dy;
  }
  return Offset(x / pts.length, y / pts.length);
}

Path polygonPath(List<Offset> pts) => Path()..addPolygon(pts, true);
