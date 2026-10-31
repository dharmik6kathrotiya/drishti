import 'dart:io';

import 'package:drishti/core/content/palmistry/palm_trace.dart';
import 'package:drishti/features/wellness/palmistry/palm_auto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'palm_detect_test.dart' show meanError, palmPhoto;

void main() {
  test('a large photo file is scaled down and the lines come back in full-size pixels', () async {
    // 900 x 1300: taller than 1000 px, so the detector works on a smaller copy.
    const w = 900, h = 1300;
    const f = PalmFrame(indexBase: Offset(230, 340), littleBase: Offset(680, 340), wrist: Offset(455, 1130));
    const lines = {
      'heart': [Offset(0.02, 0.18), Offset(0.35, 0.21), Offset(0.65, 0.17), Offset(0.88, 0.1)],
      'head': [Offset(0.98, 0.32), Offset(0.65, 0.38), Offset(0.3, 0.48), Offset(0.15, 0.55)],
      'life': [Offset(0.98, 0.34), Offset(0.78, 0.5), Offset(0.7, 0.7), Offset(0.76, 0.9), Offset(0.84, 1.0)],
    };
    final gray = palmPhoto(w, h, f, lines);
    final photo = img.Image(width: w, height: h);
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final g = gray[y * w + x];
        photo.setPixelRgb(x, y, g, g, g);
      }
    }
    final dir = await Directory.systemTemp.createTemp('palm');
    final file = File('${dir.path}/palm.png')..writeAsBytesSync(img.encodePng(photo));
    final found = palmLinesInPhoto((file.path, f.indexBase, f.littleBase, f.wrist));
    for (final id in lines.keys) {
      expect(found[id], isNotNull, reason: id);
      expect(meanError(found[id]!, lines[id]!, f), lessThan(0.03), reason: id);
    }
    await dir.delete(recursive: true);
  });
}
