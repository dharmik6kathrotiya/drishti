import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import '../../../core/content/palmistry/palm_detect.dart';
import '../../../core/content/palmistry/palm_trace.dart';

/// What was found automatically in a palm photo, in the trace screen's
/// units (the photo's height is 1).
class PalmAutoResult {
  const PalmAutoResult({required this.frame, required this.lines, this.hand = const []});

  /// Finger bases and wrist from the hand detector.
  final PalmFrame frame;

  /// Line id ('heart', 'head', 'life', 'fate') -> points, for the lines that
  /// stood out clearly enough.
  final Map<String, List<Offset>> lines;

  /// The 21 hand points (wrist, every finger joint and tip, in MediaPipe's
  /// order), so the user can see the whole hand was found.
  final List<Offset> hand;

  /// Pairs of [hand] indices joined by a bone (MediaPipe's hand connections).
  static const bones = [
    (0, 1), (1, 2), (2, 3), (3, 4), // thumb
    (0, 5), (5, 6), (6, 7), (7, 8), // index
    (5, 9), (9, 10), (10, 11), (11, 12), // middle
    (9, 13), (13, 14), (14, 15), (15, 16), // ring
    (13, 17), (0, 17), (17, 18), (18, 19), (19, 20), // little and palm edge
  ];
}

/// Finds the hand with MediaPipe Hand Landmarker (Android, on the phone) and
/// then the main lines with [PalmLineDetector]. Returns null when no hand is
/// found or on other platforms, and the user taps the points instead.
class PalmAuto {
  PalmAuto._();

  static const _channel = MethodChannel('com.kaal.drishti/hand');

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
      hand: [for (var i = 0; i < pts.length ~/ 2; i++) unit(lm(i))],
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

/// The photo with its creases made easier to see: grey, with each point
/// compared with its surroundings (local contrast), so fine lines stand out
/// whatever the light. Runs in a background isolate; returns a JPEG.
Future<Uint8List?> enhancedPalmPhoto(String path) => compute(_enhance, path);

Uint8List? _enhance(String path) {
  final decoded = img.decodeImage(File(path).readAsBytesSync());
  if (decoded == null) return null;
  var photo = img.bakeOrientation(decoded);
  if (photo.height > 1200) photo = img.copyResize(photo, height: 1200);
  final gray = img.grayscale(photo);
  final around = img.gaussianBlur(gray.clone(), radius: (gray.height / 60).round().clamp(4, 30));
  final out = img.Image(width: gray.width, height: gray.height);
  for (var y = 0; y < gray.height; y++) {
    for (var x = 0; x < gray.width; x++) {
      final v = gray.getPixel(x, y).r - around.getPixel(x, y).r;
      final g = (150 + 3.2 * v).round().clamp(0, 255);
      out.setPixelRgb(x, y, g, g, g);
    }
  }
  return img.encodeJpg(out, quality: 90);
}
