import 'package:drishti/core/content/palmistry/palm_trace.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A right hand photographed upright: index finger base on the left.
  const right = PalmFrame(indexBase: Offset(100, 100), littleBase: Offset(300, 100), wrist: Offset(200, 380));
  // A left hand, rotated about 30°, smaller in the photo.
  const left = PalmFrame(indexBase: Offset(520, 260), littleBase: Offset(390, 185), wrist: Offset(355, 395));

  TracedLine trace(PalmFrame f, List<Offset> uv, {List<int> breakAt = const []}) {
    final strokes = <List<Offset>>[[]];
    for (var i = 0; i < uv.length; i++) {
      if (breakAt.contains(i)) strokes.add([]);
      strokes.last.add(f.toImage(uv[i]));
    }
    return TracedLine(strokes);
  }

  for (final (name, f) in [('right hand', right), ('rotated left hand', left)]) {
    group(name, () {
      test('palm coordinates round-trip', () {
        const p = Offset(0.4, 0.7);
        final back = f.toPalm(f.toImage(p));
        expect(back.dx, closeTo(p.dx, 1e-9));
        expect(back.dy, closeTo(p.dy, 1e-9));
      });

      test('heart line endings', () {
        final curvesUp = trace(f, const [Offset(0.0, 0.18), Offset(0.5, 0.2), Offset(0.95, 0.08)]);
        expect(PalmMeasure.heart(f, curvesUp).option, 1);
        final between = trace(f, const [Offset(0.0, 0.18), Offset(0.4, 0.2), Offset(0.8, 0.15)]);
        expect(PalmMeasure.heart(f, between).option, 0);
        final middle = trace(f, const [Offset(0.0, 0.18), Offset(0.35, 0.2), Offset(0.62, 0.17)]);
        expect(PalmMeasure.heart(f, middle).option, 2);
        final straight = trace(f, const [Offset(0.0, 0.18), Offset(0.5, 0.18), Offset(0.95, 0.17)]);
        expect(PalmMeasure.heart(f, straight).option, 3);
      });

      test('head line: straight, sloping, short', () {
        final straight = trace(f, const [Offset(1.0, 0.3), Offset(0.5, 0.33), Offset(0.1, 0.36)]);
        expect(PalmMeasure.head(f, straight).option, 0);
        final sloping = trace(f, const [Offset(1.0, 0.3), Offset(0.6, 0.45), Offset(0.25, 0.7)]);
        expect(PalmMeasure.head(f, sloping).option, 1);
        final short = trace(f, const [Offset(1.0, 0.3), Offset(0.7, 0.32), Offset(0.6, 0.33)]);
        expect(PalmMeasure.head(f, short).option, 2);
      });

      test('life line: wide, close to the thumb, broken', () {
        final wide = trace(f, const [Offset(1.0, 0.3), Offset(0.6, 0.55), Offset(0.5, 0.75), Offset(0.7, 0.98)]);
        expect(PalmMeasure.life(f, wide).option, 0);
        final close = trace(f, const [Offset(1.0, 0.3), Offset(0.88, 0.5), Offset(0.85, 0.7), Offset(0.9, 0.9)]);
        expect(PalmMeasure.life(f, close).option, 1);
        final broken = trace(
          f,
          const [Offset(1.0, 0.3), Offset(0.8, 0.45), Offset(0.72, 0.62), Offset(0.74, 0.8), Offset(0.8, 0.95)],
          breakAt: const [3],
        );
        expect(PalmMeasure.life(f, broken).option, 3);
      });

      test('fate line starts', () {
        final life = trace(f, const [Offset(1.0, 0.3), Offset(0.75, 0.55), Offset(0.72, 0.75), Offset(0.8, 0.98)]);
        final fromWrist = trace(f, const [Offset(0.5, 0.97), Offset(0.6, 0.1)]);
        expect(PalmMeasure.fate(f, fromWrist, life: life).option, 0);
        final fromLife = trace(f, const [Offset(0.73, 0.74), Offset(0.62, 0.1)]);
        expect(PalmMeasure.fate(f, fromLife, life: life).option, 1);
        final fromEdge = trace(f, const [Offset(0.12, 0.9), Offset(0.55, 0.1)]);
        expect(PalmMeasure.fate(f, fromEdge, life: life).option, 2);
        final fromMiddle = trace(f, const [Offset(0.5, 0.55), Offset(0.58, 0.1)]);
        expect(PalmMeasure.fate(f, fromMiddle, life: life).option, 3);
        expect(PalmMeasure.fate(f, null).option, 4);
      });
    });
  }

  test('nothing traced suggests nothing', () {
    expect(PalmMeasure.heart(right, TracedLine([[]])).option, isNull);
  });
}
