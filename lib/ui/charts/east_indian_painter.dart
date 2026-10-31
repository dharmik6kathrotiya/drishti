import 'package:flutter/material.dart';

import '../../core/astro/constants.dart';
import 'chart_diagram.dart';

/// East Indian (Bengali) chart: a 3x3 grid with fixed signs. Aries is the
/// top-middle cell and signs run anticlockwise; each corner cell is split
/// diagonally into two triangles holding one sign each.
class EastIndianPainter extends ChartPainterBase {
  const EastIndianPainter({required this.view, required super.colors, super.fontFamily});

  final ChartView view;

  /// Sign regions on a unit square, Aries first.
  static const _t = 1 / 3, _u = 2 / 3;
  static const _unitRegions = [
    [Offset(_t, 0), Offset(_u, 0), Offset(_u, _t), Offset(_t, _t)], // Aries
    [Offset(0, 0), Offset(_t, 0), Offset(_t, _t)], // Taurus
    [Offset(0, 0), Offset(_t, _t), Offset(0, _t)], // Gemini
    [Offset(0, _t), Offset(_t, _t), Offset(_t, _u), Offset(0, _u)], // Cancer
    [Offset(0, _u), Offset(_t, _u), Offset(0, 1)], // Leo
    [Offset(0, 1), Offset(_t, _u), Offset(_t, 1)], // Virgo
    [Offset(_t, _u), Offset(_u, _u), Offset(_u, 1), Offset(_t, 1)], // Libra
    [Offset(_u, 1), Offset(_u, _u), Offset(1, 1)], // Scorpio
    [Offset(1, 1), Offset(_u, _u), Offset(1, _u)], // Sagittarius
    [Offset(_u, _t), Offset(1, _t), Offset(1, _u), Offset(_u, _u)], // Capricorn
    [Offset(1, _t), Offset(_u, _t), Offset(1, 0)], // Aquarius
    [Offset(1, 0), Offset(_u, _t), Offset(_u, 0)], // Pisces
  ];

  static List<Offset> _region(Sign s, Size size) => [
    for (final p in _unitRegions[s.index]) Offset(p.dx * size.width, p.dy * size.height),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = colors.background);
    canvas.drawPath(polygonPath(_region(view.lagna, size)), Paint()..color = colors.highlight);

    final line = Paint()
      ..color = colors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = (w / 260).clamp(1.0, 1.8);
    canvas.drawRect((Offset.zero & size).deflate(line.strokeWidth / 2), line);
    for (final f in [_t, _u]) {
      canvas.drawLine(Offset(f * w, 0), Offset(f * w, h), line);
      canvas.drawLine(Offset(0, f * h), Offset(w, f * h), line);
    }
    // Corner diagonals, along the chart's main diagonals.
    canvas.drawLine(Offset.zero, Offset(_t * w, _t * h), line);
    canvas.drawLine(Offset(w, 0), Offset(_u * w, _t * h), line);
    canvas.drawLine(Offset(0, h), Offset(_t * w, _u * h), line);
    canvas.drawLine(Offset(w, h), Offset(_u * w, _u * h), line);

    final base = w / 24;
    for (final sign in Sign.values) {
      final pts = _region(sign, size);
      final square = pts.length == 4;
      final centroid = polygonCentroid(pts);
      final labels = [...view.bySign[sign]!];
      final number = TextSpan(text: '${sign.index + 1}', style: textStyle(base * 0.7, colors.signNumber));
      if (square) {
        final r = Rect.fromPoints(pts[0], pts[2]);
        paintCentered(canvas, number, r.topRight + Offset(-base * 0.6, base * 0.6));
      } else {
        // Triangles: sign number near the right-angle corner.
        paintCentered(canvas, number, Offset.lerp(centroid, _rightAngle(pts), 0.55)!);
      }
      if (labels.isEmpty) continue;
      final fontSize = crowdedFontSize(base, labels.length, square ? 5 : 3);
      paintCentered(
        canvas,
        labelsSpan(labels, fontSize, perLine: square ? 3 : 2),
        centroid,
        maxWidth: w * (square ? 0.32 : 0.22),
      );
    }

    final title = TextSpan(
      children: [
        TextSpan(
          text: view.title,
          style: textStyle(base * 0.95, colors.title, weight: FontWeight.w600),
        ),
        if (view.isMoonChart) TextSpan(text: '\n${view.moonChartLabel}', style: textStyle(base * 0.7, colors.title)),
      ],
    );
    paintCentered(canvas, title, Offset(w / 2, h / 2), maxWidth: w * 0.32);
  }

  /// Vertex of a right triangle where its two legs meet.
  static Offset _rightAngle(List<Offset> pts) {
    for (var i = 0; i < 3; i++) {
      final v = pts[i], a = pts[(i + 1) % 3] - v, b = pts[(i + 2) % 3] - v;
      if ((a.dx * b.dx + a.dy * b.dy).abs() < 1e-6) return v;
    }
    return pts[1];
  }

  @override
  int? houseAt(Offset position, Size size) {
    for (final sign in Sign.values) {
      if (polygonPath(_region(sign, size)).contains(position)) return view.houseOf(sign);
    }
    return null;
  }

  @override
  bool shouldRepaint(covariant EastIndianPainter oldDelegate) =>
      oldDelegate.view != view || super.shouldRepaint(oldDelegate);
}
