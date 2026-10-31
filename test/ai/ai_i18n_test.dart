import 'package:drishti/core/ai/answerer.dart';
import 'package:drishti/core/ai/explain_service.dart';
import 'package:drishti/core/ai/explain_texts.dart';
import 'package:drishti/core/ai/fact_sheet.dart';
import 'package:drishti/core/ai/safety.dart';
import 'package:drishti/core/astro/constants.dart';
import 'package:drishti/core/astro/settings.dart';
import 'package:drishti/core/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/ephemeris_setup.dart';

const _langs = ['hi', 'mr', 'bn', 'ta', 'te', 'kn', 'ml'];

Set<String> _placeholders(String s) => {for (final m in RegExp(r'\{(\w+)\}').allMatches(s)) m.group(1)!};

final _profile = Profile(
  id: 'p1',
  name: 'Asha',
  birthDate: DateTime(1990, 8, 15),
  birthHour: 10,
  birthMinute: 30,
  timeAccuracy: TimeAccuracy.exact,
  place: const Place(
    name: 'Mumbai',
    region: 'Maharashtra',
    countryCode: 'IN',
    latitude: 19.0728,
    longitude: 72.8826,
    timezoneId: 'Asia/Kolkata',
  ),
);

void main() {
  group('explanation packs', () {
    const en = ExplainTextsEn();

    for (final lang in _langs) {
      test('$lang has every entry with matching placeholders', () {
        final t = explainTextsFor(lang);
        expect(t.code, lang);
        for (final p in Planet.values) {
          expect(t.planetNature(p), isNotNull, reason: '$lang planet $p');
        }
        for (final s in Sign.values) {
          expect(t.signNature(s), isNotNull, reason: '$lang sign $s');
          expect(t.phrase('sign.${s.name}'), isNotNull, reason: '$lang sign name $s');
          expect(t.phrase('rashi.${s.name}'), isNotNull, reason: '$lang rashi name $s');
        }
        for (var h = 1; h <= 12; h++) {
          expect(t.houseNature(h, vedic: true), isNotNull, reason: '$lang vedic house $h');
          expect(t.houseNature(h, vedic: false), isNotNull, reason: '$lang western house $h');
        }
        for (var i = 0; i < 27; i++) {
          expect(t.nakshatraNature(i), isNotNull, reason: '$lang nakshatra $i');
        }
        for (final p in Planet.vedic) {
          expect(t.dashaTheme(p), isNotNull, reason: '$lang dasha $p');
        }
        for (final k in ['Varna', 'Vashya', 'Tara', 'Yoni', 'Graha Maitri', 'Gana', 'Bhakoot', 'Nadi']) {
          expect(t.kootaMeaning(k), isNotNull, reason: '$lang koota $k');
        }
        for (final p in Planet.values) {
          expect(t.phrase('planet.${p.name}'), isNotNull, reason: '$lang planet name $p');
        }
        expect(t.phrase('ordinal'), contains('{n}'));
        for (final e in ExplainTextsEn.phrases.entries) {
          final tr = t.phrase(e.key);
          expect(tr, isNotNull, reason: '$lang phrase ${e.key}');
          expect(_placeholders(tr!), _placeholders(e.value), reason: '$lang placeholders of ${e.key}');
        }
        expect(en.phrase('caveat'), isNot(t.phrase('caveat')));
      });

      test('$lang crisis message keeps both helplines', () {
        final crisis = explainTextsFor(lang).phrase('safety.crisis')!;
        expect(crisis, contains('14416'));
        expect(crisis, contains('1800-599-0019'));
      });
    }
  });

  group('intent detection in Indian scripts', () {
    test('one native-script question per language', () {
      final cases = <String, Intent>{
        'मेरी शादी कब होगी?': Intent.relationships,
        'माझी नोकरी कधी लागेल?': Intent.career,
        'আমার বিয়ে কবে হবে?': Intent.relationships,
        'எனக்கு எப்போது வேலை கிடைக்கும்?': Intent.career,
        'నా పెళ్లి ఎప్పుడు అవుతుంది?': Intent.relationships,
        'ನನ್ನ ಮದುವೆ ಯಾವಾಗ ಆಗುತ್ತದೆ?': Intent.relationships,
        'എന്റെ വിവാഹം എപ്പോൾ നടക്കും?': Intent.relationships,
      };
      cases.forEach((q, intent) {
        final d = detectIntent(q);
        expect(d.intent, intent, reason: q);
        expect(d.asksTiming, isTrue, reason: q);
      });
    });

    test('other topics and romanised questions', () {
      expect(detectIntent('मुझे विदेश जाने का योग है?').intent, Intent.travel);
      expect(detectIntent('ನನ್ನ ಆರೋಗ್ಯ ಹೇಗಿದೆ').intent, Intent.health);
      expect(detectIntent('എനിക്ക് പണം കിട്ടുമോ').intent, Intent.money);
      expect(detectIntent('meri naukri kab lagegi').intent, Intent.career);
      expect(detectIntent('kalyanam eppo nadakkum').intent, Intent.relationships);
      expect(detectIntent('kalyanam eppo nadakkum').asksTiming, isTrue);
      expect(detectIntent('pelli eppudu').intent, Intent.relationships);
    });
  });

  group('safety in Indian scripts', () {
    test('crisis and death questions are caught in native script', () {
      expect(Safety.isCrisis('मैं आत्महत्या के बारे में सोच रहा हूँ'), isTrue);
      expect(Safety.isCrisis('எனக்கு வாழ விருப்பமில்லை'), isTrue);
      expect(Safety.asksDeath('मेरी मृत्यु कब होगी'), isTrue);
      expect(Safety.asksDeath('എന്റെ ആയുസ്സ് എത്ര'), isTrue);
      expect(Safety.referralKeysFor('मुझे कौन सी दवा लेनी चाहिए'), contains('safety.medical'));
    });

    test('safety responses come back in the asked language', () {
      final a = RuleBasedAnswerer('hi').gate('मैं आत्महत्या करना चाहता हूँ', teen: false)!;
      expect(a.safetyResponse, isTrue);
      expect(a.text, contains('14416'));
      expect(a.text, contains('टेली-मानस'));
      // Lifespan questions are answered (not gated); teens get a localized note.
      expect(RuleBasedAnswerer('ta').gate('எப்போது இறப்பேன்?', teen: false), isNull);
      final teen = RuleBasedAnswerer('ta').gate('எப்போது இறப்பேன்?', teen: true)!;
      expect(teen.text, explainTextsFor('ta').phrase('teenLongevity'));
    });

    test('teen gate is localised', () {
      final a = RuleBasedAnswerer('bn').gate('আমার বিয়ে কবে হবে?', teen: true)!;
      expect(a.text, explainTextsFor('bn').phrase('teenRelationships'));
    });

    test('forbidden output is also caught in Indian scripts', () {
      expect(Safety.violations('यह गारंटी है'), isNotEmpty);
      expect(Safety.violations('இந்த ரத்தினத்தை வாங்குங்கள்'), isNotEmpty);
    });
  });

  group('localised explanations and answers', () {
    setUpAll(setUpEphemeris);

    for (final lang in _langs) {
      test('$lang explanations and answers are complete and safe', () {
        final sheet = FactSheet.build(_profile, const CalcSettings(), now: DateTime.utc(2026, 10, 27, 6))!;
        final service = ExplainService(lang);
        for (final p in sheet.chart.planets.values) {
          final e = service.explain(PlanetPlacementTopic(p, vedic: true));
          expect(e.title, isNot(contains('{')), reason: '$lang ${p.planet}');
          expect(e.body, isNot(contains('{')), reason: '$lang ${p.planet}');
          expect(Safety.violations(e.body), isEmpty, reason: '$lang ${p.planet}');
        }
        final dasha = service.explain(DashaTopic(sheet.running[1], chart: sheet.chart));
        expect(dasha.body, isNot(contains('{')));
        final answerer = RuleBasedAnswerer(lang);
        for (final q in ['How is my career?', 'When will I get married?', 'How is my health?']) {
          final a = answerer.answer(q, sheet);
          expect(a.factors, isNotEmpty, reason: '$lang $q');
          expect(a.text, isNot(contains('{')), reason: '$lang $q');
          expect(Safety.violations(a.text), isEmpty, reason: '$lang $q');
          expect(a.notes, contains(explainTextsFor(lang).phrase('caveat')), reason: '$lang $q');
        }
        expect(
          answerer.answer('How is my health?', sheet).notes,
          contains(explainTextsFor(lang).phrase('safety.medical')),
        );
      });
    }
  });
}
