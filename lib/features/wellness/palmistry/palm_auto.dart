import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import '../../../core/content/palmistry/palm_detect.dart';
import '../../../core/content/palmistry/palm_trace.dart';

/// What was found automatically in a palm photo, in the trace screen's
/// units (the photo's height is 1).
class PalmAutoResult {
  const PalmAutoResult({required this.frame, required this.lines});

  /// Finger bases and wrist from the hand detector.
  final PalmFrame frame;

  /// Line id ('heart', 'head', 'life', 'fate') -> points, for the lines that
  /// stood out clearly enough.
  final Map<String, List<Offset>> lines;
}

/// Finds the hand with MediaPipe Hand Landmarker (Android, on the phone) and
/// then the main lines with [PalmLineDetector]. Returns null when no hand is
/// found or on other platforms, and the user taps the points instead.
class PalmAuto {
  PalmAuto._();

  static const _channel = MethodChannel('app.drishti/hand');

  static Future<PalmAutoResult?> run(String photoPath) async {
    if (kIsWeb || !Platform.isAndroid) return null;
    final Map<Object?, Object?>? hand;
    try {
      hand = await _channel.invokeMapMethod<Object?, Object?>('detect', {'path': photoPath});
    } on PlatformException catch (e) {
      debugPrint('Hand detection failed: ${e.message}');
      return null;
    } on MissingPluginException {
      return null;
    }
    if (hand == null) return null;
    final pts = (hand['points']! as List).cast<num>();
    final height = (hand['height']! as num).toDouble();
    Offset lm(int i) => Offset(pts[2 * i].toDouble(), pts[2 * i + 1].toDouble());
    // MediaPipe gives joint centres; the base of a finger on the palm side is
    // a little past the knuckle (MCP) towards the next joint (PIP).
    final frame = PalmFrame(
      indexBase: Offset.lerp(lm(5), lm(6), 0.2)!,
      littleBase: Offset.lerp(lm(17), lm(18), 0.2)!,
      wrist: lm(0),
    );
    final found = await compute(palmLinesInPhoto, (photoPath, frame.indexBase, frame.littleBase, frame.wrist));
    Offset unit(Offset p) => p / height;
    return PalmAutoResult(
      frame: PalmFrame(indexBase: unit(frame.indexBase), littleBase: unit(frame.littleBase), wrist: unit(frame.wrist)),
      lines: {
        for (final e in found.entries) e.key: [for (final p in e.value) unit(p)],
      },
    );
  }
}

/// Runs in a background isolate: decodes the photo (same orientation as
/// shown), works on a copy at most 1000 px tall, and returns line points in
/// the full photo's pixels.
@visibleForTesting
Map<String, List<Offset>> palmLinesInPhoto((String, Offset, Offset, Offset) args) {
  final (path, index, little, wrist) = args;
  final decoded = img.decodeImage(File(path).readAsBytesSync());
  if (decoded == null) return const {};
  final full = img.bakeOrientation(decoded);
  final scale = full.height > 1000 ? 1000 / full.height : 1.0;
  final small = scale < 1 ? img.copyResize(full, height: 1000) : full;
  final gray = Uint8List(small.width * small.height);
  var i = 0;
  for (final p in small) {
    gray[i++] = (p.luminanceNormalized * 255).round().clamp(0, 255);
  }
  final frame = PalmFrame(indexBase: index * scale, littleBase: little * scale, wrist: wrist * scale);
  return {
    for (final e in PalmLineDetector.detect(gray, small.width, small.height, frame).entries)
      e.key: [for (final p in e.value) p / scale],
  };
}
