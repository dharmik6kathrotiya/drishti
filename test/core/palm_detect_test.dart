import 'dart:math' as math;
import 'dart:typed_data';

import 'package:drishti/core/content/palmistry/palm_detect.dart';
import 'package:drishti/core/content/palmistry/palm_trace.dart';
import 'package:flutter_test/flutter_test.dart';

/// A synthetic palm photo: skin with uneven light and noise, a darker
/// background outside the palm, and creases drawn as soft dark lines along
/// [lines] (palm coordinates).
Uint8List palmPhoto(int w, int h, PalmFrame f, Map<String, List<Offset>> lines, {int seed = 1, double depth = 45}) {
  final rnd = math.Random(seed);
  final img = Float64List(w * h);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final uv = f.toPalm(Offset(x.toDouble(), y.toDouble()));
      final inside = uv.dx > -0.08 && uv.dx < 1.08 && uv.dy > -0.02 && uv.dy < 1.1;
      // Light falls off from the top-left corner.
      final light = 1.0 - 0.25 * (x / w) - 0.15 * (y / h);
      img[y * w + x] = (inside ? 200.0 : 70.0) * light + rnd.nextDouble() * 14 - 7;
    }
  }
  final width = f.width * 0.012; // crease half-width in pixels
  // Creases: darken by the nearest line distance (no double counting).
  final out = Uint8List(w * h);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      var nearest = double.infinity;
      final p = Offset(x.toDouble(), y.toDouble());
      for (final pts in lines.values) {
        for (var i = 1; i < pts.length; i++) {
          nearest = math.min(nearest, _segDist(p, f.toImage(pts[i - 1]), f.toImage(pts[i])));
        }
      }
      final dark = depth * math.exp(-nearest * nearest / (2 * width * width));
      out[y * w + x] = (img[y * w + x] - dark).round().clamp(0, 255);
    }
  }
  return out;
}

double _segDist(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / ab.distanceSquared).clamp(0.0, 1.0);
  return (p - (a + ab * t)).distance;
}

/// Mean distance (in palm widths) from each detected point to the drawn line.
double meanError(List<Offset> found, List<Offset> truth, PalmFrame f) {
  var sum = 0.0;
  for (final p in found) {
    var best = double.infinity;
    for (var i = 1; i < truth.length; i++) {
      best = math.min(best, _segDist(p, f.toImage(truth[i - 1]), f.toImage(truth[i])));
    }
    sum += best;
  }
  return sum / found.length / f.width;
}

void main() {
  const lines = {
    'heart': [Offset(0.02, 0.18), Offset(0.35, 0.21), Offset(0.65, 0.17), Offset(0.88, 0.1)],
    'head': [Offset(0.98, 0.32), Offset(0.65, 0.38), Offset(0.3, 0.48), Offset(0.15, 0.55)],
    'life': [Offset(0.98, 0.34), Offset(0.78, 0.5), Offset(0.7, 0.7), Offset(0.76, 0.9), Offset(0.84, 1.0)],
    'fate': [Offset(0.52, 0.98), Offset(0.55, 0.6), Offset(0.58, 0.3)],
  };

  for (final (name, f) in [
    (
      'upright right hand',
      const PalmFrame(indexBase: Offset(110, 120), littleBase: Offset(330, 120), wrist: Offset(220, 400)),
    ),
    (
      'tilted left hand',
      const PalmFrame(indexBase: Offset(330, 200), littleBase: Offset(150, 110), wrist: Offset(110, 380)),
    ),
  ]) {
    test('finds the four lines on a $name', () {
      const w = 440, h = 460;
      final photo = palmPhoto(w, h, f, lines);
      final found = PalmLineDetector.detect(photo, w, h, f);
      for (final id in lines.keys) {
        expect(found[id], isNotNull, reason: '$id not found');
        expect(meanError(found[id]!, lines[id]!, f), lessThan(0.03), reason: id);
      }
      // What it found gives the same suggestions as tracing the true lines.
      TracedLine truth(String id) => TracedLine([
        [for (final p in lines[id]!) f.toImage(p)],
      ]);
      TracedLine got(String id) => TracedLine([found[id]!]);
      expect(PalmMeasure.heart(f, got('heart')).option, PalmMeasure.heart(f, truth('heart')).option);
      expect(PalmMeasure.head(f, got('head')).option, PalmMeasure.head(f, truth('head')).option);
      expect(PalmMeasure.life(f, got('life')).option, PalmMeasure.life(f, truth('life')).option);
      expect(
        PalmMeasure.fate(f, got('fate'), life: got('life')).option,
        PalmMeasure.fate(f, truth('fate'), life: truth('life')).option,
      );
    });
  }

  test('a darker head line is not taken for the heart line', () {
    const f = PalmFrame(indexBase: Offset(110, 120), littleBase: Offset(330, 120), wrist: Offset(220, 400));
    // Same skin (same seed); the head crease is much deeper than the others.
    final faint = palmPhoto(440, 460, f, {...lines}..remove('head'), seed: 9, depth: 25);
    final deep = palmPhoto(440, 460, f, {'head': lines['head']!}, seed: 9, depth: 70);
    final photo = Uint8List.fromList([for (var i = 0; i < faint.length; i++) math.min(faint[i], deep[i])]);
    final found = PalmLineDetector.detect(photo, 440, 460, f);
    expect(meanError(found['heart']!, lines['heart']!, f), lessThan(0.03));
    expect(meanError(found['head']!, lines['head']!, f), lessThan(0.03));
  });

  test('a palm without a fate line returns no fate line', () {
    const f = PalmFrame(indexBase: Offset(110, 120), littleBase: Offset(330, 120), wrist: Offset(220, 400));
    final photo = palmPhoto(440, 460, f, {...lines}..remove('fate'), seed: 7);
    final found = PalmLineDetector.detect(photo, 440, 460, f);
    expect(found['fate'], isNull);
    expect(found['heart'], isNotNull);
  });

  test('plain skin with noise finds nothing', () {
    const f = PalmFrame(indexBase: Offset(110, 120), littleBase: Offset(330, 120), wrist: Offset(220, 400));
    final photo = palmPhoto(440, 460, f, const {}, seed: 3);
    expect(PalmLineDetector.detect(photo, 440, 460, f), isEmpty);
  });

  test('faint creases among many small wrinkles', () {
    const f = PalmFrame(indexBase: Offset(110, 120), littleBase: Offset(330, 120), wrist: Offset(220, 400));
    final rnd = math.Random(11);
    // 25 short random wrinkles, as fine lines on a real palm.
    final wrinkles = {
      for (var i = 0; i < 25; i++)
        'w$i': () {
          final a = Offset(0.05 + rnd.nextDouble() * 0.9, 0.05 + rnd.nextDouble() * 0.95);
          final angle = rnd.nextDouble() * math.pi;
          return [a, a + Offset(math.cos(angle), math.sin(angle)) * 0.08];
        }(),
    };
    final photo = palmPhoto(440, 460, f, {...lines, ...wrinkles}, seed: 5, depth: 28);
    final found = PalmLineDetector.detect(photo, 440, 460, f);
    for (final id in ['heart', 'head', 'life']) {
      expect(found[id], isNotNull, reason: '$id not found');
      expect(meanError(found[id]!, lines[id]!, f), lessThan(0.04), reason: id);
    }
  });
}
