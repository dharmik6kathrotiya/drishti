import 'dart:math' as math;
import 'dart:ui' show Offset;

/// Measures palm lines on a photo of the hand (traced by the user, or
/// suggested automatically and then checked by the user) and suggests which
/// traditional description fits. Every suggestion is shown for the user to
/// confirm or change.
///
/// Points are in image units (any consistent scale, same unit on both
/// axes). The palm frame makes the measurements independent of the hand
/// (left or right), its size and the angle of the photo.
class PalmFrame {
  const PalmFrame({required this.indexBase, required this.littleBase, required this.wrist});

  final Offset indexBase;
  final Offset littleBase;
  final Offset wrist;

  Offset get _across => indexBase - littleBase;
  Offset get _mid => (indexBase + littleBase) / 2;
  Offset get _down => wrist - _mid;

  /// Palm width (little-finger base to index-finger base).
  double get width => _across.distance;

  /// Palm length (middle of the finger bases to the wrist).
  double get length => _down.distance;

  /// Palm coordinates: u runs from the little finger (0) to the index finger
  /// (1) along the finger bases; v from the finger bases (0) to the wrist (1).
  /// The exact inverse of [toImage], so tilted photos (axes not at right
  /// angles) measure correctly.
  Offset toPalm(Offset p) {
    final d = p - littleBase, a = _across, w = _down;
    final det = a.dx * w.dy - a.dy * w.dx;
    return Offset((d.dx * w.dy - d.dy * w.dx) / det, (a.dx * d.dy - a.dy * d.dx) / det);
  }

  /// Image point for palm coordinates (used to draw the guides).
  Offset toImage(Offset uv) => littleBase + _across * uv.dx + _down * uv.dy;

  /// Where each line usually runs, in palm coordinates, for the dotted guide.
  static const guides = <String, List<Offset>>{
    'heart': [Offset(0.0, 0.16), Offset(0.3, 0.19), Offset(0.6, 0.17), Offset(0.85, 0.1)],
    'head': [Offset(1.0, 0.3), Offset(0.75, 0.33), Offset(0.45, 0.4), Offset(0.15, 0.48)],
    'life': [Offset(1.0, 0.3), Offset(0.8, 0.45), Offset(0.72, 0.65), Offset(0.78, 0.85), Offset(0.88, 0.98)],
    'fate': [Offset(0.55, 0.98), Offset(0.57, 0.6), Offset(0.6, 0.15)],
  };
}

/// One traced line: one or more strokes (a lifted finger means a break).
class TracedLine {
  TracedLine(this.strokes);
  final List<List<Offset>> strokes;

  Iterable<Offset> get points => strokes.expand((s) => s);
  bool get isEmpty => points.length < 2;

  /// Length of the traced line, gaps excluded.
  double get length {
    var sum = 0.0;
    for (final s in strokes) {
      for (var i = 1; i < s.length; i++) {
        sum += (s[i] - s[i - 1]).distance;
      }
    }
    return sum;
  }

  /// Strokes that start more than [gap] away from where the previous stroke
  /// ended count as breaks.
  int breaks(double gap) {
    var n = 0;
    for (var i = 1; i < strokes.length; i++) {
      if (strokes[i].isEmpty || strokes[i - 1].isEmpty) continue;
      final prev = strokes[i - 1].last, next = strokes[i].first;
      final d = math.min((next - prev).distance, (strokes[i].last - prev).distance);
      if (d > gap) n++;
    }
    return n;
  }
}

/// What was measured for one line and the option it suggests (the index in
/// the matching palmistry question), or null when the tracing cannot decide.
class PalmSuggestion {
  const PalmSuggestion(this.option, this.measures);
  final int? option;

  /// Measured values in palm units, for "Why?".
  final Map<String, double> measures;
}

class PalmMeasure {
  PalmMeasure._();

  static List<Offset> _uv(PalmFrame f, TracedLine t) => [for (final p in t.points) f.toPalm(p)];

  /// Heart line options: 0 ends between index and middle, 1 curves up under
  /// the index, 2 ends under the middle finger, 3 straight across, 4 wavy.
  /// Finger centres along the base: little 0, ring about 0.33, middle about
  /// 0.64, index 1.
  static PalmSuggestion heart(PalmFrame f, TracedLine t) {
    if (t.isEmpty) return const PalmSuggestion(null, {});
    final uv = _uv(f, t);
    final start = uv.reduce((a, b) => a.dx < b.dx ? a : b);
    final end = uv.reduce((a, b) => a.dx > b.dx ? a : b);
    final rise = start.dy - end.dy; // towards the fingers
    final straight = _deviation(f, uv) < 0.05;
    final int? option;
    if (end.dx >= 0.9) {
      option = rise > 0.06 ? 1 : (straight ? 3 : 0);
    } else if (end.dx >= 0.72) {
      option = 0;
    } else if (end.dx >= 0.5) {
      option = 2;
    } else {
      option = null;
    }
    return PalmSuggestion(option, {'end': end.dx, 'rise': rise});
  }

  /// Head line options: 0 long and straight, 1 slopes towards the wrist,
  /// 2 short, 3 starts separate from the life line, 4 forked.
  static PalmSuggestion head(PalmFrame f, TracedLine t, {TracedLine? life}) {
    if (t.isEmpty) return const PalmSuggestion(null, {});
    final uv = _uv(f, t);
    final start = uv.reduce((a, b) => a.dx > b.dx ? a : b); // thumb side
    final end = uv.reduce((a, b) => a.dx < b.dx ? a : b);
    final span = start.dx - end.dx;
    // Slope in real proportions: v is scaled by the palm length.
    final slope = math.atan2((end.dy - start.dy) * f.length, span * f.width) * 180 / math.pi;
    final int option;
    if (span < 0.55) {
      option = 2;
    } else if (slope > 20) {
      option = 1;
    } else {
      option = 0;
    }
    final measures = {'span': span, 'slope': slope};
    if (life != null && !life.isEmpty) {
      final lifeTop = _uv(f, life).reduce((a, b) => a.dy < b.dy ? a : b);
      measures['gapToLife'] = (start - lifeTop).distance;
    }
    return PalmSuggestion(option, measures);
  }

  /// Life line options: 0 wide curve, 1 close to the thumb, 2 long and clear,
  /// 3 broken, 4 sister line.
  static PalmSuggestion life(PalmFrame f, TracedLine t) {
    if (t.isEmpty) return const PalmSuggestion(null, {});
    final uv = _uv(f, t);
    final inner = uv.map((p) => p.dx).reduce(math.min); // how far into the palm
    final reach = uv.map((p) => p.dy).reduce(math.max) - uv.map((p) => p.dy).reduce(math.min);
    final breaks = t.breaks(0.06 * f.width);
    final int? option;
    if (breaks > 0) {
      option = 3;
    } else if (inner < 0.6) {
      option = 0;
    } else if (inner > 0.78) {
      option = 1;
    } else if (reach >= 0.6) {
      option = 2;
    } else {
      option = null;
    }
    return PalmSuggestion(option, {'inner': inner, 'reach': reach, 'breaks': breaks.toDouble()});
  }

  /// Fate line options: 0 from the wrist, 1 from the life line, 2 from the
  /// outer edge, 3 from the middle of the palm, 4 faint or absent.
  static PalmSuggestion fate(PalmFrame f, TracedLine? t, {TracedLine? life}) {
    if (t == null || t.isEmpty) return const PalmSuggestion(4, {});
    final uv = _uv(f, t);
    final start = uv.reduce((a, b) => a.dy > b.dy ? a : b); // nearest the wrist
    var nearLife = double.infinity;
    if (life != null && !life.isEmpty) {
      for (final p in _uv(f, life)) {
        nearLife = math.min(nearLife, (p - start).distance);
      }
    }
    final int option;
    if (nearLife < 0.08) {
      option = 1;
    } else if (start.dx < 0.3) {
      option = 2;
    } else if (start.dy >= 0.82) {
      option = 0;
    } else {
      option = 3;
    }
    return PalmSuggestion(option, {'startU': start.dx, 'startV': start.dy});
  }

  /// Largest distance of the line from its end-to-end chord, in palm widths.
  static double _deviation(PalmFrame f, List<Offset> uv) {
    final a = uv.reduce((x, y) => x.dx < y.dx ? x : y);
    final b = uv.reduce((x, y) => x.dx > y.dx ? x : y);
    final ab = b - a;
    final len = ab.distance;
    if (len == 0) return 0;
    var worst = 0.0;
    for (final p in uv) {
      final ap = p - a;
      worst = math.max(worst, (ap.dx * ab.dy - ap.dy * ab.dx).abs() / len);
    }
    return worst * f.length / f.width;
  }
}
