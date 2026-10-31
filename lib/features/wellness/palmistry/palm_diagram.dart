import 'package:flutter/material.dart';

import '../../../core/content/palmistry/palmistry_content.dart';

/// Simple illustrative right palm with the asked-about feature highlighted.
class PalmDiagram extends StatelessWidget {
  const PalmDiagram({super.key, required this.area, this.size = 200});
  final PalmArea area;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size * 1.25,
    child: CustomPaint(painter: _PalmPainter(area, Theme.of(context).colorScheme)),
  );
}

class _PalmPainter extends CustomPainter {
  _PalmPainter(this.area, this.scheme);
  final PalmArea area;
  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size s) {
    Offset p(double x, double y) => Offset(x * s.width, y * s.height);
    final outline = Paint()
      ..color = scheme.onSurface.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round;
    final faint = Paint()
      ..color = scheme.onSurface.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final hi = Paint()
      ..color = scheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final hiFill = Paint()..color = scheme.primary.withValues(alpha: 0.28);

    // Palm.
    final palm = RRect.fromRectAndCorners(
      Rect.fromPoints(p(0.2, 0.42), p(0.8, 0.95)),
      topLeft: const Radius.circular(10),
      topRight: const Radius.circular(10),
      bottomLeft: Radius.circular(s.width * 0.18),
      bottomRight: Radius.circular(s.width * 0.14),
    );
    if (area == PalmArea.hand) canvas.drawRRect(palm, hiFill);
    canvas.drawRRect(palm, outline);

    // Fingers: index, middle, ring, little (left to right for a right palm facing you).
    const fingers = [(0.22, 0.12, 0.13), (0.37, 0.05, 0.13), (0.52, 0.09, 0.13), (0.67, 0.2, 0.12)];
    for (var i = 0; i < fingers.length; i++) {
      final (x, top, w) = fingers[i];
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x * s.width, top * s.height, w * s.width, (0.43 - top) * s.height),
        Radius.circular(w * s.width / 2),
      );
      if (area == PalmArea.fingers && (i == 0 || i == 2)) canvas.drawRRect(r, hiFill);
      canvas.drawRRect(r, outline);
    }

    // Thumb.
    final thumb = Path()
      ..moveTo(p(0.2, 0.62).dx, p(0.2, 0.62).dy)
      ..quadraticBezierTo(p(0.02, 0.55).dx, p(0.02, 0.55).dy, p(0.04, 0.42).dx, p(0.04, 0.42).dy)
      ..quadraticBezierTo(p(0.1, 0.38).dx, p(0.1, 0.38).dy, p(0.16, 0.45).dx, p(0.16, 0.45).dy)
      ..quadraticBezierTo(p(0.2, 0.52).dx, p(0.2, 0.52).dy, p(0.22, 0.56).dx, p(0.22, 0.56).dy);
    if (area == PalmArea.thumb) canvas.drawPath(thumb, hiFill);
    canvas.drawPath(thumb, outline);

    // Lines.
    final heart = Path()
      ..moveTo(p(0.78, 0.52).dx, p(0.78, 0.52).dy)
      ..quadraticBezierTo(p(0.5, 0.5).dx, p(0.5, 0.5).dy, p(0.33, 0.45).dx, p(0.33, 0.45).dy);
    final head = Path()
      ..moveTo(p(0.24, 0.58).dx, p(0.24, 0.58).dy)
      ..quadraticBezierTo(p(0.5, 0.6).dx, p(0.5, 0.6).dy, p(0.75, 0.68).dx, p(0.75, 0.68).dy);
    final life = Path()
      ..moveTo(p(0.25, 0.57).dx, p(0.25, 0.57).dy)
      ..quadraticBezierTo(p(0.42, 0.72).dx, p(0.42, 0.72).dy, p(0.36, 0.93).dx, p(0.36, 0.93).dy);
    final fate = Path()
      ..moveTo(p(0.5, 0.93).dx, p(0.5, 0.93).dy)
      ..lineTo(p(0.46, 0.5).dx, p(0.46, 0.5).dy);

    canvas.drawPath(heart, area == PalmArea.heartLine ? hi : faint);
    canvas.drawPath(head, area == PalmArea.headLine ? hi : faint);
    canvas.drawPath(life, area == PalmArea.lifeLine ? hi : faint);
    canvas.drawPath(fate, area == PalmArea.fateLine ? hi : faint);

    if (area == PalmArea.mounts) {
      for (final c in [
        p(0.285, 0.47), p(0.435, 0.46), p(0.585, 0.47), p(0.73, 0.5), // finger mounts
        p(0.3, 0.8), p(0.7, 0.82), // Venus, Moon
      ]) {
        canvas.drawCircle(c, s.width * 0.06, hiFill);
      }
    }
  }

  @override
  bool shouldRepaint(_PalmPainter old) => old.area != area || old.scheme != scheme;
}
