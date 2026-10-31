import 'package:flutter/material.dart';

import 'chart_diagram.dart';

/// North Indian (diamond) chart: houses are fixed, house 1 is the top
/// central diamond and houses run anticlockwise. Each house shows the number
/// of the sign occupying it.
class NorthIndianPainter extends ChartPainterBase {
  const NorthIndianPainter({required this.view, required super.colors, super.fontFamily});

  final ChartView view;

  /// House polygons on a unit square, house 1 first. Kites (1, 4, 7, 10)
  /// have 4 vertices; the remaining houses are triangles.
  static const _unitHouses = [
    [Offset(.5, 0), Offset(.75, .25), Offset(.5, .5), Offset(.25, .25)],
    [Offset(0, 0), Offset(.5, 0), Offset(.25, .25)],
    [Offset(0, 0), Offset(.25, .25), Offset(0, .5)],
    [Offset(0, .5), Offset(.25, .25), Offset(.5, .5), Offset(.25, .75)],
    [Offset(0, .5), Offset(.25, .75), Offset(0, 1)],
    [Offset(0, 1), Offset(.25, .75), Offset(.5, 1)],
    [Offset(.5, 1), Offset(.25, .75), Offset(.5, .5), Offset(.75, .75)],
    [Offset(.5, 1), Offset(.75, .75), Offset(1, 1)],
    [Offset(1, 1), Offset(.75, .75), Offset(1, .5)],
    [Offset(1, .5), Offset(.75, .75), Offset(.5, .5), Offset(.75, .25)],
    [Offset(1, .5), Offset(.75, .25), Offset(1, 0)],
    [Offset(1, 0), Offset(.75, .25), Offset(.5, 0)],
  ];

  static List<Offset> _scaled(int i, Size size) => [
    for (final p in _unitHouses[i]) Offset(p.dx * size.width, p.dy * size.height),
  ];

  /// The vertex pointing to the chart centre, where the sign number goes.
  static Offset _innerVertex(int i, Size size) {
    final pts = _scaled(i, size);
    if (pts.length == 4) return Offset(size.width / 2, size.height / 2);
    // Triangles: the vertex that is not on the outer border.
    return pts.firstWhere((p) => p.dx > 1 && p.dx < size.width - 1 && p.dy > 1 && p.dy < size.height - 1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = colors.background);
    canvas.drawPath(polygonPath(_scaled(0, size)), Paint()..color = colors.highlight);

    final line = Paint()
      ..color = colors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = (w / 260).clamp(1.0, 1.8);
    canvas.drawRect(rect.deflate(line.strokeWidth / 2), line);
    canvas.drawLine(Offset.zero, Offset(w, h), line);
    canvas.drawLine(Offset(w, 0), Offset(0, h), line);
    canvas.drawPath(polygonPath([Offset(w / 2, 0), Offset(w, h / 2), Offset(w / 2, h), Offset(0, h / 2)]), line);

    final base = w / 24;
    for (var i = 0; i < 12; i++) {
      final pts = _scaled(i, size);
      final kite = pts.length == 4;
      final centroid = polygonCentroid(pts);
      final inner = _innerVertex(i, size);
      final sign = view.signOfHouse(i + 1);

      // Sign number near the inner vertex.
      final numberPos = Offset.lerp(centroid, inner, kite ? 0.62 : 0.72)!;
      paintCentered(
        canvas,
        TextSpan(text: '${sign.index + 1}', style: textStyle(base * 0.8, colors.signNumber)),
        numberPos,
      );

      final labels = view.bySign[sign]!;
      if (labels.isEmpty) continue;
      final fontSize = crowdedFontSize(base, labels.length, kite ? 6 : 3);
      final labelPos = kite ? Offset.lerp(centroid, inner, -0.12)! : centroid;
      paintCentered(
        canvas,
        labelsSpan(labels, fontSize, perLine: kite ? 3 : 2),
        labelPos,
        maxWidth: w * (kite ? 0.42 : 0.3),
      );
    }

    if (view.isMoonChart) {
      paintCentered(
        canvas,
        TextSpan(text: view.moonChartLabel, style: textStyle(base * 0.75, colors.title)),
        Offset(w / 2, h / 2),
      );
    }
  }

  @override
  int? houseAt(Offset position, Size size) {
    for (var i = 0; i < 12; i++) {
      if (polygonPath(_scaled(i, size)).contains(position)) return i + 1;
    }
    return null;
  }

  @override
  bool shouldRepaint(covariant NorthIndianPainter oldDelegate) =>
      oldDelegate.view != view || super.shouldRepaint(oldDelegate);
}
