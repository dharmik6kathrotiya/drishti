import 'package:drishti/core/astro/constants.dart';
import 'package:drishti/core/content/tarot/tarot_deck.dart';
import 'package:drishti/features/advanced/lal_kitab_content.dart';
import 'package:flutter_test/flutter_test.dart';

const _langs = ['hi', 'mr', 'bn', 'ta', 'te', 'kn', 'ml'];

void main() {
  group('tarot translations', () {
    final en = tarotFor('en');

    for (final lang in _langs) {
      test('$lang has all 78 cards, both meanings and every keyword', () {
        final t = tarotFor(lang);
        expect(identical(t, en), isFalse, reason: '$lang falls back to English');
        expect(t.cards.length, 78);
        expect(t.disclaimer.trim(), isNotEmpty);
        expect(t.suitNames.keys.toSet(), TarotSuit.values.toSet());
        for (var i = 0; i < 78; i++) {
          final c = t.cards[i], e = en.cards[i];
          expect(c.name.trim(), isNotEmpty, reason: '$lang card $i');
          expect(c.upright.trim(), isNotEmpty, reason: '$lang card $i upright');
          expect(c.reversed.trim(), isNotEmpty, reason: '$lang card $i reversed');
          expect(c.upright, isNot(e.upright), reason: '$lang card $i is untranslated');
          expect(c.uprightKeywords.length, e.uprightKeywords.length, reason: '$lang card $i');
          expect(c.reversedKeywords.length, e.reversedKeywords.length, reason: '$lang card $i');
          expect(c.uprightKeywords.every((k) => k.trim().isNotEmpty), isTrue, reason: '$lang card $i');
          expect(c.reversedKeywords.every((k) => k.trim().isNotEmpty), isTrue, reason: '$lang card $i');
        }
        // The Death card keeps its reassurance that it is about transformation.
        expect(t.cards[13].upright, isNot(contains('{')));
      });
    }

    test('unknown languages still fall back to English', () {
      expect(identical(tarotFor('xx'), en), isTrue);
    });
  });

  group('Lal Kitab translations', () {
    for (final lang in _langs) {
      test('$lang has 108 planet-in-house entries', () {
        final map = lalKitabMeanings[lang];
        expect(map, isNotNull, reason: lang);
        var count = 0;
        for (final p in Planet.vedic) {
          final houses = map![p];
          expect(houses, isNotNull, reason: '$lang $p');
          expect(houses!.length, 12, reason: '$lang $p');
          for (var h = 1; h <= 12; h++) {
            final text = lalKitabMeaning(lang, p, h);
            expect(text.trim(), isNotEmpty, reason: '$lang $p $h');
            expect(text, isNot(lalKitabMeaning('en', p, h)), reason: '$lang $p $h untranslated');
            count++;
          }
        }
        expect(count, 108);
      });
    }
  });
}
