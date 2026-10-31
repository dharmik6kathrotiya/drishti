// Renders the app icon PNGs used by flutter_launcher_icons / native splash.
//
// Run: flutter test tool/icon/render_icon_test.dart
// Output: assets/icon/icon.png (full, 1024), assets/icon/foreground.png
// (adaptive-icon foreground with transparent background), assets/icon/splash.png
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _night = Color(0xFF0B1026);
const _night2 = Color(0xFF1F2A5C);
const _gold = Color(0xFFE8C26E);
const _goldDeep = Color(0xFFC9973F);

/// The Drishti mark: an eye ("drishti" = sight) whose pupil is a star.
void paintMark(Canvas canvas, double size, {required bool background, double scale = 1}) {
  final c = Offset(size / 2, size / 2);
  if (background) {
    final rect = Offset.zero & Size(size, size);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -0.2),
          radius: 0.9,
          colors: [_night2, _night],
        ).createShader(rect),
    );
    final rnd = Random(11);
    for (var i = 0; i < 60; i++) {
      final p = Offset(rnd.nextDouble() * size, rnd.nextDouble() * size);
      if ((p - c).distance < size * 0.36) continue;
      canvas.drawCircle(p, size * (0.002 + rnd.nextDouble() * 0.004),
          Paint()..color = Colors.white.withValues(alpha: 0.25 + rnd.nextDouble() * 0.5));
    }
  }

  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.scale(scale);
  final w = size * 0.34; // half width of the eye
  final h = size * 0.20; // half height of the eye
  final eye = Path()
    ..moveTo(-w, 0)
    ..quadraticBezierTo(0, -h * 1.9, w, 0)
    ..quadraticBezierTo(0, h * 1.9, -w, 0)
    ..close();
  final stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = size * 0.028
    ..strokeJoin = StrokeJoin.round
    ..shader = const LinearGradient(colors: [_gold, _goldDeep])
        .createShader(Rect.fromCircle(center: Offset.zero, radius: w));
  canvas.drawPath(eye, stroke);

  // Iris ring.
  canvas.drawCircle(Offset.zero, h * 0.78,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size * 0.014
        ..color = _gold.withValues(alpha: 0.85));

  // Eight-pointed star pupil.
  final star = Path();
  const points = 8;
  final outer = h * 0.62, inner = h * 0.24;
  for (var i = 0; i < points * 2; i++) {
    final r = i.isEven ? outer : inner;
    final a = -pi / 2 + i * pi / points;
    final p = Offset(cos(a) * r, sin(a) * r);
    i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
  }
  star.close();
  canvas.drawPath(star, Paint()..color = _gold);
  canvas.drawCircle(Offset.zero, h * 0.12, Paint()..color = _night);
  canvas.restore();
}

Future<void> _render(String path, double size, {required bool background, double scale = 1}) async {
  final recorder = ui.PictureRecorder();
  paintMark(Canvas(recorder), size, background: background, scale: scale);
  final image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  testWidgets('render icons', (tester) async {
    await tester.runAsync(() async {
      await _render('assets/icon/icon.png', 1024, background: true);
      // Adaptive icons crop to the inner ~66%; shrink the mark to stay safe.
      await _render('assets/icon/foreground.png', 1024, background: false, scale: 0.72);
      await _render('assets/icon/splash.png', 768, background: false, scale: 0.9);
    });
    expect(File('assets/icon/icon.png').existsSync(), isTrue);
  });
}
