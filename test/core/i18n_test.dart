import 'package:drishti/core/astro/constants.dart';
import 'package:drishti/core/astro/vedic/panchang.dart';
import 'package:drishti/core/i18n/astro_names.dart';
import 'package:drishti/core/i18n/engine_texts.dart';
import 'package:drishti/core/i18n/engine_texts_bn.dart';
import 'package:drishti/core/i18n/engine_texts_hi.dart';
import 'package:drishti/core/i18n/engine_texts_kn.dart';
import 'package:drishti/core/i18n/engine_texts_ml.dart';
import 'package:drishti/core/i18n/engine_texts_mr.dart';
import 'package:drishti/core/i18n/engine_texts_ta.dart';
import 'package:drishti/core/i18n/engine_texts_te.dart';
import 'package:drishti/core/i18n/text_ref.dart';
import 'package:flutter_test/flutter_test.dart';

const _langs = {
  'hi': engineTextsHi,
  'mr': engineTextsMr,
  'bn': engineTextsBn,
  'ta': engineTextsTa,
  'te': engineTextsTe,
  'kn': engineTextsKn,
  'ml': engineTextsMl,
};

Set<String> _placeholders(String s) => RegExp(r'\{(\w+)').allMatches(s).map((m) => m.group(1)!).toSet();

void main() {
  test('every language has every engine text key with the same placeholders', () {
    for (final entry in _langs.entries) {
      for (final key in engineTextsEn.keys) {
        final value = entry.value[key];
        expect(value, isNotNull, reason: '${entry.key} is missing $key');
        expect(
          _placeholders(value!),
          _placeholders(engineTextsEn[key]!),
          reason: '${entry.key} placeholders differ for $key',
        );
      }
    }
  });

  test('English astro names equal the engine names', () {
    final en = AstroNames.of('en');
    for (final n in Nakshatra.all) {
      expect(en.nakshatra(n.index), n.name);
      expect(en.nakshatraDeity(n.index), n.deity);
    }
    for (final s in Sign.values) {
      expect(en.rashi(s), s.rashi);
    }
    for (var i = 0; i < 27; i++) {
      expect(en.yoga(i), yogaNames[i]);
    }
    for (var n = 1; n <= 60; n++) {
      expect(en.karana(n), karanaName(n));
    }
    for (var i = 0; i < 7; i++) {
      expect(en.vara(i), varaNames[i]);
    }
    for (var i = 0; i < 12; i++) {
      expect(en.month(i), lunarMonthNames[i]);
    }
    expect(en.tithi(15), 'Purnima');
    expect(en.tithi(30), 'Amavasya');
    expect(en.tithi(16), 'Pratipada');
    expect(en.monthFromEnglish('Adhika Shravana'), 'Adhika Shravana');
  });

  test('all languages provide complete name tables', () {
    for (final lang in ['en', ..._langs.keys]) {
      final n = AstroNames.of(lang);
      for (final p in Planet.values) {
        expect(n.planet(p), isNotEmpty);
        expect(n.planetAbbr(p), isNotEmpty);
      }
      for (var i = 0; i < 27; i++) {
        expect(n.nakshatra(i), isNotEmpty);
        expect(n.yoga(i), isNotEmpty);
      }
      for (var t = 1; t <= 30; t++) {
        expect(n.tithi(t), isNotEmpty, reason: '$lang tithi $t');
      }
      for (var k = 1; k <= 60; k++) {
        expect(n.karana(k), isNotEmpty);
      }
      for (final c in ChoghadiyaKind.values) {
        expect(n.choghadiya(c), isNotEmpty);
      }
    }
    expect(AstroNames.of('hi').nakshatra(0), 'अश्विनी');
    expect(AstroNames.of('ta').nakshatra(5), 'திருவாதிரை');
  });

  test('placeholders, lists, flags and nested refs are filled', () {
    final en = EngineTexts.of('en');
    expect(
      en.t('yoga.mahapurusha.reason', {'planet': Planet.mars, 'exalted': true, 'sign': Sign.capricorn, 'house': 10}),
      'Mars is exalted (Makara) in house 10, a kendra.',
    );
    expect(
      en.t('yoga.yogakaraka.reason', {
        'planet': Planet.saturn,
        'houses': [4, 5],
      }),
      'Saturn rules houses 4 and 5 (a kendra and a trikona).',
    );
    expect(
      en.t('yoga.neecha.reason', {
        'planet': Planet.sun,
        'sign': Sign.libra,
        'parts': [
          const TextRef('yoga.neecha.debLord', {'planet': Planet.venus}),
        ],
      }),
      'Sun is debilitated in Tula, and Venus, lord of the debilitation sign, is in a kendra from the Ascendant or Moon.',
    );
    expect(EngineTexts.of('hi').t('dosha.manglik.fromMoon', {'house': 7}), 'मंगल चंद्र से 7वें भाव में है।');
    // Unknown language falls back to English.
    expect(EngineTexts.of('xx').raw('match.verdict.good'), 'Good match');
  });
}
