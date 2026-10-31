import 'package:drishti/core/content/tarot/tarot_deck.dart';
import 'package:drishti/features/wellness/tarot/tarot_astro_label.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every card\'s astrology line is fully localized', () {
    for (final lang in const ['hi', 'mr', 'bn', 'ta', 'te', 'kn', 'ml']) {
      for (final card in TarotCard.deck) {
        final s = localizeTarotAstrology(card.astrology, lang);
        expect(s, isNot(matches(RegExp('[A-Za-z]'))), reason: '$lang ${card.astrology} -> $s');
      }
    }
  });

  test('modern rulers keep the element and the planet', () {
    expect(localizeTarotAstrology('Air (Uranus in modern use)', 'en'), 'Air (Uranus)');
    expect(localizeTarotAstrology('Water (Neptune in modern use)', 'en'), 'Water (Neptune)');
    expect(localizeTarotAstrology('Fire (Pluto in modern use)', 'en'), 'Fire (Pluto)');
    expect(localizeTarotAstrology('Mars in Aries', 'en'), 'Mars in Aries');
  });
}
