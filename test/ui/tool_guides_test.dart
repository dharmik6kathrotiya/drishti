import 'package:drishti/core/content/tool_guides/tool_guides.dart';
import 'package:drishti/l10n/app_localizations.dart';
import 'package:drishti/ui/widgets/tool_info_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const languages = ['en', 'hi', 'mr', 'bn', 'ta', 'te', 'kn', 'ml'];

  test('ids are unique and every language is registered', () {
    expect(ToolGuides.ids.toSet().length, ToolGuides.ids.length);
    expect(ToolGuides.byLanguage.keys.toSet(), languages.toSet());
  });

  for (final lang in languages) {
    test('[$lang] every tool has all five parts', () {
      final texts = ToolGuides.byLanguage[lang]!;
      expect(texts.keys.toSet(), ToolGuides.ids.toSet(), reason: 'tool ids in $lang');
      for (final id in ToolGuides.ids) {
        final t = texts[id]!;
        for (final (name, value) in [
          ('title', t.title),
          ('what', t.what),
          ('why', t.why),
          ('how', t.how),
          ('science', t.science),
        ]) {
          expect(value.trim(), isNotEmpty, reason: '$lang/$id/$name');
        }
        if (lang != 'en') {
          // A real translation, not a copy of the English text.
          expect(t.what, isNot(toolGuidesEn[id]!.what), reason: '$lang/$id/what is untranslated');
          expect(t.science, isNot(toolGuidesEn[id]!.science), reason: '$lang/$id/science is untranslated');
        }
        final guide = ToolGuides.of(id, lang)!;
        expect(guide.references, isNotEmpty, reason: '$lang/$id references');
        expect(guide.references.every((r) => r.trim().isNotEmpty), isTrue);
      }
    });
  }

  test('unknown language falls back to English, unknown id gives null', () {
    expect(ToolGuides.of('panchang', 'xx')!.title, toolGuidesEn['panchang']!.title);
    expect(ToolGuides.of('no_such_tool', 'en'), isNull);
  });

  testWidgets('info button opens the guide with all sections', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          appBar: AppBar(actions: const [ToolInfoButton(toolId: 'panchang')]),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final l = lookupAppLocalizations(const Locale('en'));
    expect(find.text(toolGuidesEn['panchang']!.title), findsOneWidget);
    // The sheet is a lazy list, so scroll to each heading in turn.
    for (final heading in [l.toolInfoWhat, l.toolInfoWhy, l.toolInfoHow, l.toolInfoScience, l.toolInfoReferences]) {
      await tester.scrollUntilVisible(find.text(heading), 200, scrollable: find.byType(Scrollable).last);
      expect(find.text(heading), findsOneWidget);
    }
  });

  for (final lang in languages) {
    testWidgets('[$lang] every guide renders', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.6;
      addTearDown(tester.view.reset);
      for (final id in ToolGuides.ids) {
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(lang),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: ToolGuideView(guide: ToolGuides.of(id, lang)!)),
          ),
        );
        expect(tester.takeException(), isNull, reason: '$lang/$id');
      }
    });
  }
}
