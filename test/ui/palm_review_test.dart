import 'dart:io';

import 'package:drishti/core/content/palmistry/palm_trace.dart';
import 'package:drishti/features/wellness/palmistry/palm_auto.dart';
import 'package:drishti/features/wellness/palmistry/palm_trace_screen.dart';
import 'package:drishti/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  // A plain 300 x 400 photo; the "found" hand and lines come from the fake
  // detector, in the screen's units (photo height = 1).
  const frame = PalmFrame(indexBase: Offset(0.2, 0.3), littleBase: Offset(0.55, 0.3), wrist: Offset(0.38, 0.95));
  List<Offset> along(String id) => [for (final p in PalmFrame.guides[id]!) frame.toImage(p)];

  testWidgets('every line found is shown at once and accepted with one tap', (tester) async {
    final path = await tester.runAsync(() async {
      final dir = await Directory.systemTemp.createTemp('palm');
      return (File('${dir.path}/palm.png')..writeAsBytesSync(img.encodePng(img.Image(width: 300, height: 400)))).path;
    });
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);

    Map<String, int?>? result;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await Navigator.of(context).push<Map<String, int?>>(
                  MaterialPageRoute(
                    builder: (_) => PalmTraceScreen(
                      photoPath: path!,
                      detect: (_) async => PalmAutoResult(
                        frame: frame,
                        // The fate line was not found.
                        lines: {'heart': along('heart'), 'head': along('head'), 'life': along('life')},
                      ),
                    ),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    final l = lookupAppLocalizations(const Locale('en'));
    await tester.tap(find.text('open'));
    // The photo is decoded off the test clock; wait for the review.
    for (var i = 0; i < 50 && find.text(l.palmLooksRight).evaluate().isEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(tester.takeException(), isNull);

    expect(find.text(l.palmLooksRight), findsOneWidget);
    expect(find.text(l.palmFixLine), findsOneWidget);
    expect(find.textContaining('Not found: Fate line'), findsOneWidget);

    await tester.tap(find.text(l.palmLooksRight));
    await tester.pumpAndSettle();
    expect(result, isNotNull);
    for (final id in ['heart', 'head', 'life']) {
      expect(result![id], isNotNull, reason: id);
    }
  });
}
