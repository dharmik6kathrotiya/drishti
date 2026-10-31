import 'tarot_bn.dart';
import 'tarot_en.dart';
import 'tarot_hi.dart';
import 'tarot_kn.dart';
import 'tarot_ml.dart';
import 'tarot_mr.dart';
import 'tarot_ta.dart';
import 'tarot_te.dart';

/// The 78-card tarot deck. Card structure (suit, number, Golden Dawn
/// attributions) is language independent; names and meanings come from a
/// per-language [TarotTexts] (English fallback).
enum TarotSuit { major, wands, cups, swords, pentacles }

enum TarotElement { fire, water, air, earth }

class TarotCard {
  const TarotCard._(this.id, this.suit, this.rank, this.astrology);

  /// 0..77: 0–21 major arcana, then Wands, Cups, Swords, Pentacles
  /// (Ace..10, Page, Knight, Queen, King).
  final int id;
  final TarotSuit suit;

  /// Major arcana: 0..21. Minor arcana: 1 (Ace)..10, 11 Page, 12 Knight,
  /// 13 Queen, 14 King.
  final int rank;

  /// Golden Dawn astrological or elemental attribution.
  final String astrology;

  bool get isMajor => suit == TarotSuit.major;
  bool get isCourt => !isMajor && rank > 10;

  TarotElement? get element => switch (suit) {
    TarotSuit.wands => TarotElement.fire,
    TarotSuit.cups => TarotElement.water,
    TarotSuit.swords => TarotElement.air,
    TarotSuit.pentacles => TarotElement.earth,
    TarotSuit.major => null,
  };

  /// Roman numeral (major) or rank label for drawing.
  String get numeral {
    if (isMajor) return rank == 0 ? '0' : _roman(rank);
    if (rank == 1) return 'A';
    if (rank <= 10) return '$rank';
    return const ['P', 'Kn', 'Q', 'K'][rank - 11];
  }

  static String _roman(int n) {
    const values = [10, 9, 5, 4, 1];
    const symbols = ['X', 'IX', 'V', 'IV', 'I'];
    final b = StringBuffer();
    var x = n;
    for (var i = 0; i < values.length; i++) {
      while (x >= values[i]) {
        b.write(symbols[i]);
        x -= values[i];
      }
    }
    return b.toString();
  }

  static final List<TarotCard> deck = _build();

  static List<TarotCard> _build() {
    const majorAstro = [
      'Air (Uranus in modern use)',
      'Mercury',
      'Moon',
      'Venus',
      'Aries',
      'Taurus',
      'Gemini',
      'Cancer',
      'Leo',
      'Virgo',
      'Jupiter',
      'Libra',
      'Water (Neptune in modern use)',
      'Scorpio',
      'Sagittarius',
      'Capricorn',
      'Mars',
      'Aquarius',
      'Pisces',
      'Sun',
      'Fire (Pluto in modern use)',
      'Saturn (and Earth)',
    ];
    // Decan rulers of the small cards 2–10 (Golden Dawn).
    const decans = {
      TarotSuit.wands: [
        'Mars in Aries',
        'Sun in Aries',
        'Venus in Aries',
        'Saturn in Leo',
        'Jupiter in Leo',
        'Mars in Leo',
        'Mercury in Sagittarius',
        'Moon in Sagittarius',
        'Saturn in Sagittarius',
      ],
      TarotSuit.cups: [
        'Venus in Cancer',
        'Mercury in Cancer',
        'Moon in Cancer',
        'Mars in Scorpio',
        'Sun in Scorpio',
        'Venus in Scorpio',
        'Saturn in Pisces',
        'Jupiter in Pisces',
        'Mars in Pisces',
      ],
      TarotSuit.swords: [
        'Moon in Libra',
        'Saturn in Libra',
        'Jupiter in Libra',
        'Venus in Aquarius',
        'Mercury in Aquarius',
        'Moon in Aquarius',
        'Jupiter in Gemini',
        'Mars in Gemini',
        'Sun in Gemini',
      ],
      TarotSuit.pentacles: [
        'Jupiter in Capricorn',
        'Mars in Capricorn',
        'Sun in Capricorn',
        'Mercury in Taurus',
        'Moon in Taurus',
        'Saturn in Taurus',
        'Sun in Virgo',
        'Venus in Virgo',
        'Mercury in Virgo',
      ],
    };
    const elementName = {
      TarotSuit.wands: 'Fire',
      TarotSuit.cups: 'Water',
      TarotSuit.swords: 'Air',
      TarotSuit.pentacles: 'Earth',
    };
    // Court cards: Page = Earth, Knight = Fire, Queen = Water, King = Air of the suit.
    const courtElement = ['Earth', 'Fire', 'Water', 'Air'];

    final cards = <TarotCard>[for (var i = 0; i < 22; i++) TarotCard._(i, TarotSuit.major, i, majorAstro[i])];
    var id = 22;
    for (final suit in [TarotSuit.wands, TarotSuit.cups, TarotSuit.swords, TarotSuit.pentacles]) {
      for (var rank = 1; rank <= 14; rank++) {
        final astro = rank == 1
            ? 'Root of ${elementName[suit]}'
            : rank <= 10
            ? decans[suit]![rank - 2]
            : '${courtElement[rank - 11]} of ${elementName[suit]}';
        cards.add(TarotCard._(id++, suit, rank, astro));
      }
    }
    return List.unmodifiable(cards);
  }
}

class TarotCardText {
  const TarotCardText(this.name, this.uprightKeywords, this.reversedKeywords, this.upright, this.reversed);
  final String name;
  final List<String> uprightKeywords;
  final List<String> reversedKeywords;
  final String upright;
  final String reversed;
}

class TarotTexts {
  const TarotTexts({required this.cards, required this.disclaimer, required this.suitNames});

  /// Indexed by [TarotCard.id].
  final List<TarotCardText> cards;
  final String disclaimer;
  final Map<TarotSuit, String> suitNames;
}

const tarotByLanguage = <String, TarotTexts>{
  'en': tarotEn,
  'hi': tarotHi,
  'mr': tarotMr,
  'bn': tarotBn,
  'ta': tarotTa,
  'te': tarotTe,
  'kn': tarotKn,
  'ml': tarotMl,
};

TarotTexts tarotFor(String languageCode) => tarotByLanguage[languageCode] ?? tarotEn;

/// Deterministic card of the day for a person (or anonymous id) and date.
({TarotCard card, bool reversed}) dailyCard(String seedId, DateTime date) {
  final key = '$seedId|${date.year}-${date.month}-${date.day}';
  var h = 0x811c9dc5;
  for (final c in key.codeUnits) {
    h ^= c;
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return (card: TarotCard.deck[h % 78], reversed: (h >> 8) % 4 == 0);
}
