import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/astro/chart.dart';
import '../../core/astro/constants.dart';
import 'chart_diagram.dart';

/// Circular Western chart. The Ascendant sits at 9 o'clock and the zodiac
/// runs anticlockwise. Without a birth time, 0Â° Aries is placed on the left
/// and no houses are drawn.
class WesternWheelPainter extends ChartPainterBase {
  const WesternWheelPainter({required this.chart, required super.colors, super.fontFamily});

  final Chart chart;

  // Ring radii as fractions of the outer radius.
  static const _zodiacInner = 0.84;
  static const _planetRing = 0.72;
  static const _degreeRing = 0.615;
  static const _aspectRing = 0.50;

  /// Text presentation selector: stops glyphs such as ♈ rendering as emoji.

  static const _aspects = [
    (angle: 180.0, orb: 8.0, hard: true),
    (angle: 120.0, orb: 7.0, hard: false),
    (angle: 90.0, orb: 7.0, hard: true),
    (angle: 60.0, orb: 5.0, hard: false),
  ];

  double get _rotation => chart.ascendant ?? 0;

  /// Screen point for an ecliptic longitude at [radius] around [c].
  Offset _point(Offset c, double radius, double longitude) {
    final theta = (180 + longitude - _rotation) * math.pi / 180;
    return Offset(c.dx + radius * math.cos(theta), c.dy - radius * math.sin(theta));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 1;
    final base = size.shortestSide / 24;
    final stroke = (size.shortestSide / 260).clamp(1.0, 1.8);

    final line = Paint()
      ..color = colors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final faint = Paint()
      ..color = colors.line.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke * 0.7;

    canvas.drawCircle(c, r, Paint()..color = colors.background);
    canvas.drawCircle(c, r, line);
    canvas.drawCircle(c, r * _zodiacInner, line);
    canvas.drawCircle(c, r * _aspectRing, faint);

    _paintZodiac(canvas, c, r, base, line, faint);
    if (chart.hasHouses && chart.cusps != null) _paintHouses(canvas, c, r, base, stroke);
    _paintAspects(canvas, c, r, stroke);
    _paintPlanets(canvas, c, r, base, faint);
  }

  void _paintZodiac(Canvas canvas, Offset c, double r, double base, Paint line, Paint faint) {
    for (final sign in Sign.values) {
      final start = sign.index * 30.0;
      // Alternate shading makes the twelve signs easier to tell apart.
      if (sign.index.isEven) {
        final first = _point(c, r, start);
        final path = Path()..moveTo(first.dx, first.dy);
        for (var d = 2.0; d <= 30; d += 2) {
          final p = _point(c, r, start + d);
          path.lineTo(p.dx, p.dy);
        }
        for (var d = 30.0; d >= 0; d -= 2) {
          final p = _point(c, r * _zodiacInner, start + d);
          path.lineTo(p.dx, p.dy);
        }
        path.close();
        canvas.drawPath(path, Paint()..color = colors.highlight);
      }
      canvas.drawLine(_point(c, r * _zodiacInner, start), _point(c, r, start), line);
      paintCentered(
        canvas,
        TextSpan(text: sign.symbol, style: textStyle(base * 1.05, colors.title)),
        _point(c, r * (1 + _zodiacInner) / 2, start + 15),
      );
      // Ticks every 5Â°.
      for (var d = 5; d < 30; d += 5) {
        final len = d == 15 ? 0.035 : 0.02;
        canvas.drawLine(_point(c, r * _zodiacInner, start + d), _point(c, r * (_zodiacInner + len), start + d), faint);
      }
    }
  }

  void _paintHouses(Canvas canvas, Offset c, double r, double base, double stroke) {
    final cusps = chart.cusps!;
    final cuspPaint = Paint()
      ..color = colors.line.withValues(alpha: 0.7)
      ..strokeWidth = stroke * 0.8;
    final axisPaint = Paint()
      ..color = colors.ascendant
      ..strokeWidth = stroke * 1.6;
    for (var i = 0; i < 12; i++) {
      final axis = i == 0 || i == 3 || i == 6 || i == 9;
      canvas.drawLine(
        _point(c, r * _aspectRing, cusps[i]),
        _point(c, r * _zodiacInner, cusps[i]),
        axis ? axisPaint : cuspPaint,
      );
      final next = cusps[(i + 1) % 12];
      final mid = cusps[i] + norm360(next - cusps[i]) / 2;
      paintCentered(
        canvas,
        TextSpan(text: '${i + 1}', style: textStyle(base * 0.65, colors.signNumber)),
        _point(c, r * (_aspectRing + 0.045), mid),
      );
    }
    final asc = TextSpan(
      text: 'AC',
      style: textStyle(base * 0.7, colors.ascendant, weight: FontWeight.w700),
    );
    paintCentered(canvas, asc, _point(c, r * (_aspectRing - 0.06), cusps[0]));
    if (chart.midheaven != null) {
      final mc = TextSpan(
        text: 'MC',
        style: textStyle(base * 0.7, colors.ascendant, weight: FontWeight.w700),
      );
      paintCentered(canvas, mc, _point(c, r * (_aspectRing - 0.06), chart.midheaven!));
    }
  }

  void _paintAspects(Canvas canvas, Offset c, double r, double stroke) {
    final bodies = chart.planets.values.where((p) => !p.planet.isNode).toList();
    for (var i = 0; i < bodies.length; i++) {
      for (var j = i + 1; j < bodies.length; j++) {
        final sep = angularDistance(bodies[i].longitude, bodies[j].longitude);
        for (final a in _aspects) {
          if ((sep - a.angle).abs() <= a.orb) {
            canvas.drawLine(
              _point(c, r * _aspectRing, bodies[i].longitude),
              _point(c, r * _aspectRing, bodies[j].longitude),
              Paint()
                ..color = a.hard ? colors.aspectHard : colors.aspectSoft
                ..strokeWidth = stroke * 0.8,
            );
            break;
          }
        }
      }
    }
  }

  void _paintPlanets(Canvas canvas, Offset c, double r, double base, Paint faint) {
    final placements = chart.planets.values.toList()..sort((a, b) => a.longitude.compareTo(b.longitude));
    final glyphSize = base * 1.15;
    // Minimum angular gap so glyphs don't overlap on the planet ring.
    final minGap = (glyphSize * 1.15) / (r * _planetRing) * 180 / math.pi;
    final shown = _spread([for (final p in placements) p.longitude], minGap);

    for (var i = 0; i < placements.length; i++) {
      final p = placements[i];
      final actual = p.longitude;
      final disp = shown[i];
      canvas.drawLine(
        _point(c, r * _zodiacInner, actual),
        _point(c, r * (_zodiacInner - 0.03), actual),
        Paint()
          ..color = colors.planet
          ..strokeWidth = faint.strokeWidth * 1.4,
      );
      if (angularDistance(actual, disp) > 0.5) {
        canvas.drawLine(_point(c, r * (_zodiacInner - 0.03), actual), _point(c, r * (_planetRing + 0.05), disp), faint);
      }
      final color = p.isRetrograde && !p.planet.isNode ? colors.retrograde : colors.planet;
      paintCentered(
        canvas,
        TextSpan(text: p.planet.symbol, style: textStyle(glyphSize, color)),
        _point(c, r * _planetRing, disp),
      );
      final deg = formatDms(p.degreeInSign, seconds: false);
      final retro = p.isRetrograde && !p.planet.isNode ? '℞' : '';
      paintCentered(
        canvas,
        TextSpan(text: '$deg$retro', style: textStyle(base * 0.55, colors.signNumber)),
        _point(c, r * _degreeRing, disp),
      );
    }
  }

  /// Pushes sorted longitudes apart until neighbours are at least [gap]
  /// degrees apart, keeping each as close as possible to its true position.
  static List<double> _spread(List<double> lons, double gap) {
    final n = lons.length;
    if (n < 2) return [...lons];
    // Work in an unwrapped frame starting just after the widest empty arc so
    // that pushing never wraps around 360Â°.
    var widest = 0, widestGap = -1.0;
    for (var i = 0; i < n; i++) {
      final g = norm360(lons[(i + 1) % n] - lons[i]);
      if (g > widestGap) {
        widestGap = g;
        widest = i;
      }
    }
    final start = (widest + 1) % n;
    final order = [for (var k = 0; k < n; k++) (start + k) % n];
    final origin = lons[order.first];
    final pos = [for (final i in order) norm360(lons[i] - origin)];
    final target = [...pos];
    for (var iter = 0; iter < 50; iter++) {
      var moved = false;
      for (var k = 0; k + 1 < n; k++) {
        final d = pos[k + 1] - pos[k];
        if (d < gap) {
          final push = (gap - d) / 2;
          pos[k] -= push;
          pos[k + 1] += push;
          moved = true;
        }
      }
      // Gently pull towards true positions without breaking the gap.
      for (var k = 0; k < n; k++) {
        final pulled = pos[k] + (target[k] - pos[k]) * 0.1;
        final okLeft = k == 0 || pulled - pos[k - 1] >= gap;
        final okRight = k == n - 1 || pos[k + 1] - pulled >= gap;
        if (okLeft && okRight) pos[k] = pulled;
      }
      if (!moved) break;
    }
    final result = List<double>.filled(n, 0);
    for (var k = 0; k < n; k++) {
      result[order[k]] = norm360(pos[k] + origin);
    }
    return result;
  }

  @override
  int? houseAt(Offset position, Size size) {
    final cusps = chart.cusps;
    if (!chart.hasHouses || cusps == null) return null;
    final c = size.center(Offset.zero);
    final v = position - c;
    if (v.distance > size.shortestSide / 2) return null;
    final theta = math.atan2(-v.dy, v.dx) * 180 / math.pi;
    final lon = norm360(theta - 180 + _rotation);
    for (var i = 0; i < 12; i++) {
      final span = norm360(cusps[(i + 1) % 12] - cusps[i]);
      if (norm360(lon - cusps[i]) < span) return i + 1;
    }
    return null;
  }

  @override
  bool shouldRepaint(covariant WesternWheelPainter oldDelegate) =>
      oldDelegate.chart != chart || super.shouldRepaint(oldDelegate);
}
