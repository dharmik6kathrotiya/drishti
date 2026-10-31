import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Offset;

import 'palm_trace.dart';

/// Finds the main palm lines in a grey-scale photo, inside a known palm
/// frame (from the hand detector or the user's taps).
///
/// The palm is resampled into palm coordinates (so rotation and size do not
/// matter), creases are enhanced as narrow darker valleys, and each line is
/// the strongest continuous crease inside the band where that line runs.
/// A line is only returned when it stands out clearly from the skin around
/// it; otherwise the user traces it. This is image processing, not a
/// learned model, and it is never assumed to be right: the user confirms
/// every line.
class PalmLineDetector {
  PalmLineDetector._();

  static const _cols = 200, _rows = 210;
  static const _u0 = -0.05, _u1 = 1.05, _v0 = 0.0, _v1 = 1.05;

  static double _uOf(int c) => _u0 + (_u1 - _u0) * c / (_cols - 1);
  static double _vOf(int r) => _v0 + (_v1 - _v0) * r / (_rows - 1);
  static int _colOf(double u) => ((u - _u0) / (_u1 - _u0) * (_cols - 1)).round().clamp(0, _cols - 1);
  static int _rowOf(double v) => ((v - _v0) / (_v1 - _v0) * (_rows - 1)).round().clamp(0, _rows - 1);

  /// [gray] is width x height luminance (0-255), row by row. [frame] is in
  /// the same pixel units. Returns line id -> points in pixel units.
  static Map<String, List<Offset>> detect(Uint8List gray, int width, int height, PalmFrame frame) {
    final ridge = _ridges(_resample(gray, width, height, frame));
    final out = <String, List<Offset>>{};
    void keep(String id, List<Offset>? uv) {
      if (uv != null) out[id] = [for (final p in uv) frame.toImage(p)];
    }

    // The two strongest creases across the palm; the heart line is the one
    // nearer the fingers. Taking the strongest first and sorting them stops a
    // darker head line from being taken for the heart line.
    final first = _horizontal(ridge, from: 0.02, to: 1.0, vMin: 0.05, vMax: 0.68, minSpan: 0.35);
    final second = _horizontal(_suppress(ridge, first), from: 0.02, to: 1.0, vMin: 0.05, vMax: 0.68, minSpan: 0.35);
    final upperFirst = second == null || (first != null && _meanV(first, second) <= _meanV(second, first));
    final heart = upperFirst ? first : second, head = upperFirst ? second : first;
    keep('heart', heart != null && _meanV(heart, null) <= 0.4 ? heart : null);
    keep('head', head != null && _meanV(head, null) >= 0.15 ? head : null);
    // The life line begins between the thumb and the index finger.
    final life = _vertical(
      _suppress(ridge, heart),
      from: 0.25,
      to: 1.0,
      uMin: 0.5,
      uMax: 1.02,
      minSpan: 0.35,
      start: (u, v) => u >= 0.68 && v <= 0.5,
    );
    keep('life', life);
    keep('fate', _vertical(_suppress(ridge, life), from: 0.1, to: 1.0, uMin: 0.28, uMax: 0.72, minSpan: 0.25));
    return out;
  }

  /// Mean v of [line] over the u range it shares with [other] (all of it
  /// when [other] is null or they do not overlap).
  static double _meanV(List<Offset> line, List<Offset>? other) {
    var lo = double.negativeInfinity, hi = double.infinity;
    if (other != null) {
      lo = other.map((p) => p.dx).reduce(math.min);
      hi = other.map((p) => p.dx).reduce(math.max);
    }
    var shared = [
      for (final p in line)
        if (p.dx >= lo && p.dx <= hi) p.dy,
    ];
    if (shared.isEmpty) shared = [for (final p in line) p.dy];
    return shared.reduce((a, b) => a + b) / shared.length;
  }

  /// Luminance in palm coordinates, each cell the mean of 3x3 samples.
  static List<Float64List> _resample(Uint8List gray, int w, int h, PalmFrame f) {
    double at(double x, double y) {
      final xi = x.round().clamp(0, w - 1), yi = y.round().clamp(0, h - 1);
      return gray[yi * w + xi].toDouble();
    }

    final du = (_u1 - _u0) / (_cols - 1) / 3, dv = (_v1 - _v0) / (_rows - 1) / 3;
    return [
      for (var r = 0; r < _rows; r++)
        Float64List.fromList([
          for (var c = 0; c < _cols; c++)
            () {
              var sum = 0.0;
              for (var i = -1; i <= 1; i++) {
                for (var j = -1; j <= 1; j++) {
                  final p = f.toImage(Offset(_uOf(c) + i * du, _vOf(r) + j * dv));
                  sum += at(p.dx, p.dy);
                }
              }
              return sum / 9;
            }(),
        ]),
    ];
  }

  /// Crease strength: how much darker a cell is than its surroundings
  /// (difference of Gaussians), divided by the local contrast so shadows and
  /// uneven light count less. Zero where the cell is not darker.
  static List<Float64List> _ridges(List<Float64List> img) {
    final fine = _blur(img, 1.0), coarse = _blur(img, 5.0);
    final diff = [
      for (var r = 0; r < _rows; r++) Float64List.fromList([for (var c = 0; c < _cols; c++) coarse[r][c] - fine[r][c]]),
    ];
    final sq = [
      for (var r = 0; r < _rows; r++) Float64List.fromList([for (var c = 0; c < _cols; c++) diff[r][c] * diff[r][c]]),
    ];
    final spread = _blur(sq, 10.0);
    return [
      for (var r = 0; r < _rows; r++)
        Float64List.fromList([
          for (var c = 0; c < _cols; c++) math.max(0.0, diff[r][c]) / (math.sqrt(spread[r][c]) + 2.0),
        ]),
    ];
  }

  static List<Float64List> _blur(List<Float64List> img, double sigma) {
    final radius = (sigma * 2.5).ceil();
    final k = [for (var i = -radius; i <= radius; i++) math.exp(-i * i / (2 * sigma * sigma))];
    List<Float64List> pass(List<Float64List> src, bool horizontal) {
      final rows = src.length, cols = src.first.length;
      return [
        for (var r = 0; r < rows; r++)
          Float64List.fromList([
            for (var c = 0; c < cols; c++)
              () {
                var sum = 0.0, weight = 0.0;
                for (var i = -radius; i <= radius; i++) {
                  final rr = horizontal ? r : r + i, cc = horizontal ? c + i : c;
                  if (rr < 0 || rr >= rows || cc < 0 || cc >= cols) continue;
                  sum += src[rr][cc] * k[i + radius];
                  weight += k[i + radius];
                }
                return sum / weight;
              }(),
          ]),
      ];
    }

    return pass(pass(img, true), false);
  }

  /// Moving average of the sideways position over 9 steps, so the suggested
  /// line follows the crease without pixel stair-steps.
  static List<(int, int)> _smooth(List<(int, int)> cells) {
    const half = 4;
    return [
      for (var i = 0; i < cells.length; i++)
        () {
          final from = math.max(0, i - half), to = math.min(cells.length - 1, i + half);
          var sum = 0;
          for (var k = from; k <= to; k++) {
            sum += cells[k].$2;
          }
          return (cells[i].$1, (sum / (to - from + 1)).round());
        }(),
    ];
  }

  /// Where a run across the palm turns sharply it has usually left one
  /// crease for another that crosses it (the life line curves, so this is
  /// only used for the heart and head lines): the run is cut at each sharp turn and the longest piece
  /// is kept. Real lines bend gradually.
  static List<(int, int)> _straightest(List<(int, int)> cells) {
    const w = 6, maxTurn = 3.5; // window in steps, change of drift in cells
    var bestFrom = 0, bestTo = cells.length, from = 0;
    for (var i = 0; i + 2 * w < cells.length; i++) {
      final before = cells[i + w].$2 - cells[i].$2, after = cells[i + 2 * w].$2 - cells[i + w].$2;
      if ((after - before).abs() > maxTurn && i + w > from) {
        if (i + w - from > bestTo - bestFrom || bestTo == cells.length && bestFrom == 0) {
          bestFrom = from;
          bestTo = i + w;
        }
        from = i + w;
        i += w; // one cut per turn
      }
    }
    if (from == 0) return cells;
    if (cells.length - from > bestTo - bestFrom) {
      bestFrom = from;
      bestTo = cells.length;
    }
    return cells.sublist(bestFrom, bestTo);
  }

  /// [ridge] with the cells near [path] set to zero, so the next line does
  /// not pick the same crease.
  static List<Float64List> _suppress(List<Float64List> ridge, List<Offset>? path) {
    if (path == null) return ridge;
    final out = [for (final row in ridge) Float64List.fromList(row)];
    for (final p in path) {
      final r0 = _rowOf(p.dy), c0 = _colOf(p.dx);
      for (var r = r0 - 4; r <= r0 + 4; r++) {
        for (var c = c0 - 4; c <= c0 + 4; c++) {
          if (r >= 0 && r < _rows && c >= 0 && c < _cols) out[r][c] = 0;
        }
      }
    }
    return out;
  }

  /// A mostly horizontal line: one row per column between u = [from] and
  /// [to], inside the rows of [vMin]..[vMax].
  static List<Offset>? _horizontal(
    List<Float64List> ridge, {
    required double from,
    required double to,
    required double vMin,
    required double vMax,
    required double minSpan,
  }) {
    final cells = _best(
      steps: [for (var c = _colOf(from); c <= _colOf(to); c++) c],
      positions: [for (var r = _rowOf(vMin); r <= _rowOf(vMax); r++) r],
      value: (c, r) => ridge[r][c],
    );
    if (cells == null) return null;
    final uv = [for (final (c, r) in _straightest(cells)) Offset(_uOf(c), _vOf(r))];
    return (uv.last.dx - uv.first.dx).abs() >= minSpan ? uv : null;
  }

  /// A mostly vertical line: one column per row between v = [from] and [to].
  static List<Offset>? _vertical(
    List<Float64List> ridge, {
    required double from,
    required double to,
    required double uMin,
    required double uMax,
    required double minSpan,
    bool Function(double u, double v)? start,
  }) {
    final cells = _best(
      steps: [for (var r = _rowOf(from); r <= _rowOf(to); r++) r],
      positions: [for (var c = _colOf(uMin); c <= _colOf(uMax); c++) c],
      value: (r, c) => ridge[r][c],
      canStart: start == null ? null : (r, c) => start(_uOf(c), _vOf(r)),
    );
    if (cells == null) return null;
    final uv = [for (final (r, c) in cells) Offset(_uOf(c), _vOf(r))];
    return (uv.last.dy - uv.first.dy).abs() >= minSpan ? uv : null;
  }

  /// Cost of one sideways cell per step, in thresholds: real creases bend
  /// gently, so a run may not hop between neighbouring creases.
  static const _turn = 0.35;

  /// The strongest smooth run through the band (local alignment by dynamic
  /// programming): each step moves at most one cell sideways, the run may
  /// start and end anywhere, and cells must beat a threshold set from the
  /// band's own statistics. [canStart] limits where a run may begin.
  /// Returns (step, position) cells or null when no run stands out.
  static List<(int, int)>? _best({
    required List<int> steps,
    required List<int> positions,
    required double Function(int step, int position) value,
    bool Function(int step, int position)? canStart,
  }) {
    final n = steps.length, m = positions.length;
    if (n < 2 || m < 3) return null;
    // Threshold: well above the band's typical crease strength.
    var sum = 0.0, sumSq = 0.0;
    for (final s in steps) {
      for (final p in positions) {
        final x = value(s, p);
        sum += x;
        sumSq += x * x;
      }
    }
    final count = n * m;
    final mean = sum / count;
    final sd = math.sqrt(math.max(0.0, sumSq / count - mean * mean));
    final threshold = mean + 1.2 * sd;

    final score = List.generate(n, (_) => Float64List(m));
    final from = List.generate(n, (_) => Int32List(m));
    var bestI = -1, bestJ = -1, best = 0.0;
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < m; j++) {
        var prev = 0.0, arg = -1;
        if (i > 0) {
          for (var k = math.max(0, j - 1); k <= math.min(m - 1, j + 1); k++) {
            final s = score[i - 1][k] - _turn * (k - j).abs() * threshold;
            if (s > prev) {
              prev = s;
              arg = k;
            }
          }
        }
        if (arg < 0 && canStart != null && !canStart(steps[i], positions[j])) {
          score[i][j] = 0;
          from[i][j] = -1;
          continue;
        }
        score[i][j] = math.max(0.0, value(steps[i], positions[j]) - threshold + prev);
        from[i][j] = score[i][j] > 0 ? arg : -1;
        if (score[i][j] > best) {
          best = score[i][j];
          bestI = i;
          bestJ = j;
        }
      }
    }
    if (bestI < 0) return null;
    final cells = <(int, int)>[];
    for (var i = bestI, j = bestJ; i >= 0 && j >= 0 && score[i][j] > 0; j = from[i][j], i--) {
      cells.add((steps[i], positions[j]));
    }
    if (cells.length < 2) return null;
    // Clear enough: the run's mean strength must be well above the band's.
    var along = 0.0;
    for (final (s, p) in cells) {
      along += value(s, p);
    }
    if (along / cells.length < mean + 2.0 * sd) return null;
    return _smooth(cells.reversed.toList());
  }
}
