import 'package:drishti/core/ai/answerer.dart';
import 'package:drishti/core/ai/explain_texts.dart';
import 'package:drishti/core/ai/fact_render.dart';
import 'package:drishti/core/ai/fact_sheet.dart';
import 'package:drishti/core/ai/fact_texts.dart';
import 'package:drishti/core/ai/safety.dart';
import 'package:drishti/core/astro/constants.dart';
import 'package:drishti/core/astro/settings.dart';
import 'package:drishti/core/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/ephemeris_setup.dart';

const _langs = ['en', 'hi', 'mr', 'bn', 'ta', 'te', 'kn', 'ml'];
const _englishPlanets = ['Sun ', 'Moon ', 'Mars ', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu ', 'Ketu '];
const _lifeQuestion = {
  'en': 'How long will I live?',
  'hi': 'मेरी आयु कितनी है?',
  'mr': 'माझं आयुष्य किती आहे?',
  'bn': 'আমার আয়ু কত?',
  'ta': 'என் ஆயுள் எவ்வளவு?',
  'te': 'నా ఆయుష్షు ఎంత?',
  'kn': 'ನನ್ನ ಆಯುಷ್ಯ ಎಷ್ಟು?',
  'ml': 'എന്റെ ആയുസ്സ് എത്ര?',
};

const _place = Place(
  name: 'Mumbai',
  region: 'Maharashtra',
  countryCode: 'IN',
  latitude: 19.0728,
  longitude: 72.8826,
  timezoneId: 'Asia/Kolkata',
);

final _full = Profile(
  id: 'p1',
  name: 'Asha',
  birthDate: DateTime(1990, 8, 15),
  birthHour: 10,
  birthMinute: 30,
  timeAccuracy: TimeAccuracy.exact,
  place: _place,
);

final _noTime = Profile(id: 'p2', name: 'Ravi', birthDate: DateTime(1992, 3, 4), place: _place);

final _now = DateTime.utc(2026, 10, 27, 6);

void main() {
  setUpAll(setUpEphemeris);

  test('every language pack has every fact/answer key with the same placeholders', () {
    final en = FactTexts.pack('en')!;
    Set<String> ph(String s) => {for (final m in RegExp(r'\{(\w+)\}').allMatches(s)) m.group(1)!};
    for (final lang in _langs) {
      final pack = FactTexts.pack(lang)!;
      for (final e in en.entries) {
        expect(pack[e.key], isNotNull, reason: '$lang ${e.key}');
        expect(ph(pack[e.key]!), ph(e.value), reason: '$lang placeholders of ${e.key}');
      }
    }
  });

  for (final lang in _langs) {
    group(lang, () {
      late FactSheet sheet;
      late RuleBasedAnswerer answerer;
      late FactRenderer fr;
      setUpAll(() {
        sheet = FactSheet.build(_full, const CalcSettings(), now: _now)!;
        answerer = RuleBasedAnswerer(lang);
        fr = FactRenderer(lang);
      });

      test('career answer states concrete chart facts in the body', () {
        final a = answerer.answer('How is my career?', sheet);
        final tenthLord = sheet.chart.houseLord(10)!;
        expect(a.text, contains(fr.planet(tenthLord)), reason: '10th lord named');
        expect(a.text, contains(fr.planet(sheet.running[0].lord)), reason: 'mahadasha lord named');
        expect(a.text, contains(fr.planet(sheet.running[1].lord)), reason: 'antardasha lord named');
        expect(a.text, contains(fr.sign(sheet.chart.houseSign(10)!, vedic: true)), reason: '10th sign named');
        expect(a.text, isNot(contains('{')));
        expect(Safety.violations(a.text), isEmpty);
        expect(answerer.answer('How is my career?', sheet).text, a.text, reason: 'deterministic');
      });

      test('personality answer names the Lagna and the Moon', () {
        final a = answerer.answer('Tell me about my personality', sheet);
        expect(a.text, contains(fr.sign(sheet.chart.ascendantSign!, vedic: true)));
        expect(a.text, contains(fr.sign(sheet.chart.moon.sign, vedic: true)));
        expect(a.text, isNot(contains('{')));
      });

      test('facts render without placeholders, and in the language', () {
        for (final f in sheet.facts) {
          final s = fr.render(f, sheet);
          expect(s, isNot(contains('{')), reason: f.id);
          if (lang != 'en') {
            expect(s, isNot(f.text), reason: '${f.id} was not localized');
            for (final p in _englishPlanets) {
              expect(s, isNot(contains(p)), reason: '${f.id}: "$s"');
            }
          }
        }
        if (lang != 'en') {
          final a = answerer.answer('When will my career grow?', sheet);
          for (final f in a.factors) {
            for (final p in _englishPlanets) {
              expect(f.fact, isNot(contains(p)), reason: f.fact);
            }
            expect(f.fact, isNot(contains(' house ')), reason: f.fact);
          }
        }
      });

      test('lifespan answer states the calculation in the language', () {
        final a = answerer.answer(_lifeQuestion[lang]!, sheet);
        final texts = explainTextsFor(lang);
        expect(a.safetyResponse, isFalse);
        expect(a.text, contains(fr.render(sheet.byId('longevity.span')!, sheet)));
        expect(a.text, contains(texts.phrase('lifeCare')));
        expect(a.text, contains(texts.phrase('lifeCaveat')));
        expect(a.text, isNot(contains('{')));
        expect(Safety.violations(a.text), isEmpty);
        expect(a.factors.map((f) => f.factId), containsAll(['longevity.span', 'longevity.pairs']));
      });

      test('without a birth time the body says houses cannot be judged', () {
        final s = FactSheet.build(_noTime, const CalcSettings(), now: _now)!;
        final a = answerer.answer('How is my career?', s);
        expect(a.text, contains(FactTexts(lang).t('b.noHouses')));
        expect(a.text, contains(fr.planet(s.running[0].lord)));
        expect(a.text, isNot(contains('{')));
      });
    });
  }

  test('English fact text (model input) is unchanged', () {
    final sheet = FactSheet.build(_full, const CalcSettings(), now: _now)!;
    final sun = sheet.byId('planet.${Planet.sun.name}')!;
    expect(sun.text, startsWith('Sun in Karka (Cancer)'));
    expect(FactRenderer('en').render(sun, sheet), sun.text);
  });
}
