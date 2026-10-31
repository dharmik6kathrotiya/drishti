import 'package:drishti/core/astro/settings.dart';
import 'package:drishti/core/astro/vedic/doshas.dart';
import 'package:drishti/core/astro/vedic/match_advice.dart';
import 'package:drishti/core/astro/vedic/matching.dart';
import 'package:drishti/core/astro/western/aspects.dart';
import 'package:drishti/app/providers.dart';
import 'package:drishti/core/models/profile.dart';
import 'package:drishti/features/children/children_screen.dart';
import 'package:drishti/features/matching/match_advice_card.dart';
import 'package:drishti/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/ephemeris_setup.dart';

void main() {
  setUpAll(setUpEphemeris);

  const languages = ['en', 'hi', 'mr', 'bn', 'ta', 'te', 'kn', 'ml'];
  const place = Place(name: 'Mumbai', latitude: 19.076, longitude: 72.8777, timezoneId: 'Asia/Kolkata');
  final a = Profile(
    id: 'a',
    name: 'Ravi',
    birthDate: DateTime(1990, 8, 15),
    birthHour: 10,
    birthMinute: 30,
    timeAccuracy: TimeAccuracy.exact,
    place: place,
  );
  final b = Profile(id: 'b', name: 'Asha', birthDate: DateTime(1993, 2, 3), place: place);
  const vedic = CalcSettings(system: AstroSystem.vedic);

  Future<void> pump(WidgetTester tester, String lang, Widget child) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale(lang),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    // Expand every "Why?" so the reasons render too.
    for (final tile in find.byType(ExpansionTile).evaluate().toList()) {
      await tester.tap(find.byWidget(tile.widget), warnIfMissed: false);
    }
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    for (final t in find.byType(Text).evaluate()) {
      final s = (t.widget as Text).data ?? '';
      expect(s, isNot(contains('{')), reason: '$lang: $s');
      expect(s, isNot(matches(RegExp(r'\b(advice|children|match)\.[a-z]'))), reason: '$lang: $s');
    }
  }

  for (final lang in languages) {
    testWidgets('[$lang] match advice renders, Vedic and Western', (tester) async {
      final ac = chartForProfile(a, vedic)!, bc = chartForProfile(b, vedic)!;
      final r = Ashtakoot.match(
        boy: MatchInput(moonLongitude: ac.moon.longitude),
        girl: MatchInput(moonLongitude: bc.moon.longitude),
      );
      final am = Doshas.manglik(ac), bm = Doshas.manglik(bc);
      await pump(
        tester,
        lang,
        Column(
          children: [
            MatchAdviceCard(
              advice: MatchAdvice.vedic(
                r,
                groomMoon: ac.moon.sign,
                brideMoon: bc.moon.sign,
                groomManglik: am.present,
                brideManglik: bm.present,
                groomManglikWhy: am.factorRefs,
                brideManglikWhy: bm.factorRefs,
              ),
            ),
            MatchAdviceCard(
              advice: MatchAdvice.western(
                aspectsBetween(
                  chartForProfile(a, const CalcSettings(system: AstroSystem.western))!.planets,
                  chartForProfile(b, const CalcSettings(system: AstroSystem.western))!.planets,
                ),
                nameA: a.name,
                nameB: b.name,
              ),
            ),
          ],
        ),
      );
    });

    testWidgets('[$lang] children readings render for one person and a couple', (tester) async {
      await pump(
        tester,
        lang,
        Column(
          children: [
            ChildrenSingleResult(person: a, calc: vedic),
            ChildrenSingleResult(person: b, calc: vedic),
            ChildrenCoupleResult(father: a, mother: b, calc: vedic),
          ],
        ),
      );
    });
  }
}
