import 'package:drishti/core/astro/vedic/matching.dart';
import 'package:drishti/core/i18n/engine_texts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final en = EngineTexts.of('en');

  // Groom: Moon in Purva Ashadha pada 3 (Sagittarius 21°); bride: Moon in
  // Revati pada 4 (Pisces 28°). Checked by hand: 0+1+1.5+3+5+6+7+8 = 31.5.
  final r = Ashtakoot.match(boy: const MatchInput(moonLongitude: 261.0), girl: const MatchInput(moonLongitude: 358.5));
  KootaResult k(String id) => r.kootas.firstWhere((x) => x.id == id);

  test('scores and steps for a real pair', () {
    expect(r.total, 31.5);
    expect([for (final x in r.kootas) x.score], [0, 1, 1.5, 3, 5, 6, 7, 8]);
    for (final x in r.kootas) {
      expect(x.why, isNotEmpty, reason: x.id);
      for (final s in en.kootaWhy(x)) {
        expect(s, isNot(contains('{')), reason: '${x.id}: $s');
        expect(s, isNot(contains('match.')), reason: '${x.id}: $s');
      }
      expect(en.kootaAbout(x), isNot(startsWith('match.')));
      expect(en.kootaResult(x), isNot(startsWith('match.')));
    }
    expect(en.kootaWhy(k('varna')).join(' '), contains('below the bride'));
    expect(en.kootaWhy(k('tara')).first, contains('Revati'));
    expect(en.kootaWhy(k('tara')).join(' '), contains('Vipat'));
    expect(en.kootaWhy(k('bhakoot')).join(' '), contains('4/10'));
    expect(en.kootaWhy(k('nadi')).join(' '), contains('8 of 8'));
    expect(k('nadi').doshaId, isNull);
    expect(k('vashya').why.length, 4);
    expect(en.kootaWhy(k('vashya')).first, contains('21°00′'));
  });

  test('Nadi dosha lists the exceptions and which one applies', () {
    // Ashwini (Aries 5°) and Moola (Sagittarius 5°) are both Adi nadi, and
    // Aries/Sagittarius is a 5/9 position, so Bhakoot dosha too.
    final d = Ashtakoot.match(boy: const MatchInput(moonLongitude: 5), girl: const MatchInput(moonLongitude: 245));
    final nadi = d.kootas.last;
    expect(nadi.score, 0);
    expect(nadi.doshaId, 'nadi');
    expect(nadi.exceptions, hasLength(3));
    expect(nadi.doshaCancelled, isFalse);
    final bhakoot = d.kootas[6];
    expect(bhakoot.doshaId, 'bhakoot');
    expect(en.kootaWhy(bhakoot).join(' '), contains('5/9'));
    // Mars and Jupiter are mutual friends, which cancels Bhakoot dosha.
    expect(bhakoot.doshaCancelled, isTrue);

    // Same Moon sign, different nakshatras: Krittika (Taurus 1°) and Rohini
    // (Taurus 15°) are both Antya nadi, and the first exception applies.
    final same = Ashtakoot.match(boy: const MatchInput(moonLongitude: 31), girl: const MatchInput(moonLongitude: 45));
    expect(same.kootas.last.doshaId, 'nadi');
    expect(same.kootas.last.doshaCancelled, isTrue);
    expect(same.kootas.last.exceptions.first.applies, isTrue);
  });

  test('every language renders every koota without raw keys', () {
    for (final lang in ['hi', 'mr', 'bn', 'ta', 'te', 'kn', 'ml']) {
      final t = EngineTexts.of(lang);
      for (final x in r.kootas) {
        for (final s in [t.kootaAbout(x), t.kootaResult(x), ...t.kootaWhy(x)]) {
          expect(s, isNot(contains('{')), reason: '$lang ${x.id}: $s');
          expect(s, isNot(startsWith('match.')), reason: '$lang ${x.id}: $s');
        }
      }
    }
  });
}
