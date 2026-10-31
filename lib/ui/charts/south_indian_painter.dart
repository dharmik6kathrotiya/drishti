import 'package:flutter/material.dart';

import '../../core/astro/constants.dart';
import 'chart_diagram.dart';

/// South Indian chart: a 4x4 grid with fixed signs. Pisces is top-left and
/// signs run clockwise; the ascendant sign is marked with a diagonal line.
class SouthIndianPainter extends ChartPainterBase {
  const SouthIndianPainter({required this.view, required super.colors, super.fontFamily});

  final ChartView view;

  /// (row, column) of each sign, Aries first.
  static const _cells = [
    (0, 1),
    (0, 2),
    (0, 3),
    (1, 3),
    (2, 3),
    (3, 3),
    (3, 2),
    (3, 1),
    (3, 0),
    (2, 0),
    (1, 0),
    (0, 0),
  ];

  static Rect _cellRect(Sign s, Size size) {
    final (row, col) = _cells[s.index];
    final cw = size.width / 4, ch = size.height / 4;
    return Rect.fromLTWH(col * cw, row * ch, cw, ch);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final cw = w / 4, ch = h / 4;
    canvas.drawRect(Offset.zero & size, Paint()..color = colors.background);

    final lagnaRect = _cellRect(view.lagna, size);
    canvas.drawRect(lagnaRect, Paint()..color = colors.highlight);

    final line = Paint()
      ..color = colors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = (w / 260).clamp(1.0, 1.8);
    canvas.drawRect((Offset.zero & size).deflate(line.strokeWidth / 2), line);
    // Inner grid lines, skipping the merged 2x2 centre.
    for (var i = 1; i < 4; i++) {
      canvas.drawLine(Offset(i * cw, 0), Offset(i * cw, ch), line);
      canvas.drawLine(Offset(i * cw, h - ch), Offset(i * cw, h), line);
      canvas.drawLine(Offset(0, i * ch), Offset(cw, i * ch), line);
      canvas.drawLine(Offset(w - cw, i * ch), Offset(w, i * ch), line);
    }
    canvas.drawRect(Rect.fromLTWH(cw, ch, cw * 2, ch * 2), line);

    // Traditional ascendant mark: a diagonal across the cell's top-left corner.
    if (!view.isMoonChart) {
      final mark = Paint()
        ..color = colors.ascendant
        ..strokeWidth = line.strokeWidth * 1.4;
      canvas.drawLine(lagnaRect.topLeft + Offset(0, ch * 0.28), lagnaRect.topLeft + Offset(cw * 0.28, 0), mark);
    }

    final base = w / 24;
    for (final sign in Sign.values) {
      final r = _cellRect(sign, size);
      paintCentered(
        canvas,
        TextSpan(text: '${sign.index + 1}', style: textStyle(base * 0.7, colors.signNumber)),
        r.bottomRight - Offset(base * 0.6, base * 0.6),
      );
      final labels = view.bySign[sign]!;
      if (labels.isEmpty) continue;
      paintCentered(
        canvas,
        labelsSpan(labels, crowdedFontSize(base, labels.length, 4), perLine: 2),
        r.center,
        maxWidth: cw * 0.95,
      );
    }

    final title = TextSpan(
      children: [
        TextSpan(
          text: view.title,
          style: textStyle(base * 1.05, colors.title, weight: FontWeight.w600),
        ),
        if (view.isMoonChart) TextSpan(text: '\n${view.moonChartLabel}', style: textStyle(base * 0.75, colors.title)),
      ],
    );
    paintCentered(canvas, title, Offset(w / 2, h / 2), maxWidth: cw * 1.9);
  }

  @override
  int? houseAt(Offset position, Size size) {
    for (final sign in Sign.values) {
      if (_cellRect(sign, size).contains(position)) return view.houseOf(sign);
    }
    return null;
  }

  @override
  bool shouldRepaint(covariant SouthIndianPainter oldDelegate) =>
      oldDelegate.view != view || super.shouldRepaint(oldDelegate);
}
