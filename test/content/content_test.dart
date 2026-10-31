import 'package:drishti/core/astro/constants.dart';
import 'package:drishti/core/astro/settings.dart';
import 'package:drishti/core/content/palmistry/palmistry_content.dart';
import 'package:drishti/core/content/remedies/remedies_content.dart';
import 'package:drishti/core/content/tarot/tarot_deck.dart';
import 'package:drishti/features/remedies/personal_remedies.dart';
import 'package:drishti/features/wellness/journal/journal_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/ephemeris_setup.dart';
import '../helpers/manual_chart.dart';

/// Words that must never appear: no selling, no guarantees, no fear.
final _forbidden = RegExp(
  r'\b(buy|buying|purchase|shop|shops|seller|sellers|price|prices|guaranteed?|doomed|curse[ds]?)\b',
  caseSensitive: false,
);

void main() {
  group('remedies', () {
    final r = remediesFor('en');

    test('all nine grahas present with every field filled', () {
      expect(r.grahas.map((g) => g.planet).toSet(), Planet.vedic.toSet());
      for (final g in r.grahas) {
        for (final field in [
          g.name,
          g.signifies,
          g.deity,
          g.day,
          g.colour,
          g.direction,
          g.japa,
          g.charity,
          g.fasting,
          g.rudraksha,
          g.yantra,
          g.gem.primary,
          g.gem.upratna,
          g.beej.devanagari,
          g.beej.iast,
          g.beej.meaning,
          g.beej.source,
          g.stotra.devanagari,
          g.stotra.iast,
          g.stotra.meaning,
          g.stotra.source,
        ]) {
          expect(field.trim(), isNotEmpty, reason: '${g.planet} has an empty field');
        }
        expect(g.lifestyle, isNotEmpty);
      }
    });

    test('dosha sections and books exist', () {
      expect(r.doshas.map((d) => d.id), containsAll(['sadeSati', 'manglik', 'kaalSarp', 'pitru']));
      expect(r.dosha('manglik')!.adultOnly, isTrue);
      expect(r.books.length, greaterThanOrEqualTo(10));
    });

    test('no selling, guarantees or fear words', () {
      final all = <String>[
        r.intro,
        r.gemNote,
        r.personalNote,
        for (final g in r.grahas) ...[
          g.signifies,
          g.deity,
          g.charity,
          g.fasting,
          g.japa,
          g.gem.primary,
          g.gem.upratna,
          g.beej.meaning,
          g.stotra.meaning,
          ...g.lifestyle,
        ],
        for (final d in r.doshas) ...[d.about, for (final p in d.practices) '${p.title} ${p.detail} ${p.source}'],
        for (final b in r.books) '${b.title} ${b.author} ${b.description}',
      ];
      for (final s in all) {
        expect(_forbidden.hasMatch(s), isFalse, reason: 'Forbidden word in: $s');
      }
    });

    test('unknown language falls back to English', () {
      expect(identical(remediesFor('xx'), remediesFor('en')), isTrue);
    });
  });

  group('tarot', () {
    final t = tarotFor('en');

    test('78 cards with complete texts', () {
      expect(TarotCard.deck.length, 78);
      expect(t.cards.length, 78);
      expect(TarotCard.deck.where((c) => c.isMajor).length, 22);
      for (final suit in [TarotSuit.wands, TarotSuit.cups, TarotSuit.swords, TarotSuit.pentacles]) {
        expect(TarotCard.deck.where((c) => c.suit == suit).length, 14);
      }
      for (var i = 0; i < 78; i++) {
        final c = t.cards[i];
        expect(c.name, isNotEmpty);
        expect(c.upright, isNotEmpty);
        expect(c.reversed, isNotEmpty);
        expect(c.uprightKeywords, isNotEmpty);
        expect(c.reversedKeywords, isNotEmpty);
        expect(TarotCard.deck[i].astrology, isNotEmpty);
        expect(_forbidden.hasMatch('${c.upright} ${c.reversed}'), isFalse, reason: c.name);
      }
    });

    test('card names line up with structure', () {
      expect(t.cards[0].name, 'The Fool');
      expect(t.cards[21].name, 'The World');
      expect(t.cards[22].name, 'Ace of Wands');
      expect(t.cards[35].name, 'King of Wands');
      expect(t.cards[36].name, 'Ace of Cups');
      expect(t.cards[50].name, 'Ace of Swords');
      expect(t.cards[64].name, 'Ace of Pentacles');
      expect(t.cards[77].name, 'King of Pentacles');
      expect(TarotCard.deck[1].astrology, 'Mercury');
      expect(TarotCard.deck[23].astrology, 'Mars in Aries'); // Two of Wands
      expect(TarotCard.deck[22].numeral, 'A');
      expect(TarotCard.deck[14].numeral, 'XIV');
    });

    test('daily card is deterministic and varies', () {
      final d = DateTime(2026, 10, 27);
      final a = dailyCard('p1', d), b = dailyCard('p1', d);
      expect(a.card.id, b.card.id);
      expect(a.reversed, b.reversed);
      final ids = {for (var i = 0; i < 30; i++) dailyCard('p1', d.add(Duration(days: i))).card.id};
      expect(ids.length, greaterThan(10));
    });
  });

  group('palmistry', () {
    test('questions have options and honest notes', () {
      final p = palmistryFor('en');
      expect(p.questions.length, greaterThanOrEqualTo(6));
      for (final q in p.questions) {
        expect(q.options.length, greaterThanOrEqualTo(3), reason: q.id);
        for (final o in q.options) {
          expect(_forbidden.hasMatch(o.meaning), isFalse);
        }
      }
      // Honest about the automatic suggestions: they can be wrong, the user
      // checks them, and the photo stays on the phone.
      expect(p.noScanNote, isNot(contains('no automatic')));
      expect(p.noScanNote, contains('not always right'));
      expect(p.noScanNote, contains('never uploaded'));
    });
  });

  group('translations', () {
    const langs = ['hi', 'mr', 'bn', 'ta', 'te', 'kn', 'ml'];
    // Simple cross-language selling check: no currency, prices or "buy".
    final selling = RegExp(r'₹|\bRs\.?\b|\bprice\b|\bbuy\b|खरीद|कीमत|किंमत|विकत', caseSensitive: false);

    for (final lang in langs) {
      test('remedies ($lang) mirror English and keep the Sanskrit', () {
        final en = remediesFor('en');
        final r = remediesFor(lang);
        expect(identical(r, en), isFalse, reason: 'missing $lang');
        expect(r.grahas.map((g) => g.planet).toList(), en.grahas.map((g) => g.planet).toList());
        expect(r.doshas.map((d) => d.id).toList(), en.doshas.map((d) => d.id).toList());
        expect(r.books.length, en.books.length);
        for (var i = 0; i < en.grahas.length; i++) {
          final g = r.grahas[i], e = en.grahas[i];
          expect(g.beej.devanagari, e.beej.devanagari);
          expect(g.beej.iast, e.beej.iast);
          expect(g.stotra.devanagari, e.stotra.devanagari);
          expect(g.stotra.iast, e.stotra.iast);
          expect(g.lifestyle.length, e.lifestyle.length);
          for (final field in [
            g.name,
            g.signifies,
            g.deity,
            g.day,
            g.colour,
            g.direction,
            g.japa,
            g.charity,
            g.fasting,
            g.rudraksha,
            g.yantra,
            g.gem.primary,
            g.gem.upratna,
            g.beej.meaning,
            g.stotra.meaning,
          ]) {
            expect(field.trim(), isNotEmpty);
          }
        }
        for (var i = 0; i < en.doshas.length; i++) {
          expect(r.doshas[i].adultOnly, en.doshas[i].adultOnly);
          expect(r.doshas[i].practices.length, en.doshas[i].practices.length);
        }
        final all = [
          r.intro,
          r.gemNote,
          r.personalNote,
          for (final g in r.grahas) ...[g.charity, g.fasting, g.gem.primary, g.gem.upratna, ...g.lifestyle],
          for (final d in r.doshas) ...[d.about, for (final p in d.practices) p.detail],
          for (final b in r.books) b.description,
        ];
        for (final s in all) {
          expect(selling.hasMatch(s), isFalse, reason: '$lang: $s');
        }
      });

      test('palmistry ($lang) mirrors English option order', () {
        final en = palmistryFor('en');
        final p = palmistryFor(lang);
        expect(identical(p, en), isFalse, reason: 'missing $lang');
        expect(p.questions.map((q) => q.id).toList(), en.questions.map((q) => q.id).toList());
        for (var i = 0; i < en.questions.length; i++) {
          expect(p.questions[i].area, en.questions[i].area);
          expect(p.questions[i].options.length, en.questions[i].options.length, reason: p.questions[i].id);
          for (final o in p.questions[i].options) {
            expect(o.label.trim(), isNotEmpty);
            expect(o.meaning.trim(), isNotEmpty);
          }
        }
        expect(p.noScanNote, contains('Android'));
        for (final s in [p.intro, p.noScanNote, p.whichHand, p.closing]) {
          expect(selling.hasMatch(s), isFalse, reason: '$lang: $s');
        }
      });
    }
  });

  group('journal insights', () {
    test('averages by paksha and weekday', () {
      final entries = [
        for (var i = 0; i < 40; i++)
          JournalEntry(
            date: DateTime(2026, 1, 1).add(Duration(days: i)),
            mood: i.isEven ? 4 : 2,
            energy: 3,
            sky: JournalSky(tithi: i.isEven ? 5 : 20, nakshatra: 0, moonSign: Sign.aries),
          ),
      ];
      final ins = JournalInsights(entries);
      expect(ins.shukla, 4);
      expect(ins.krishna, 2);
      expect(ins.byElement[Element.fire], 3);
    });

    test('entries round-trip through JSON', () {
      final e = JournalEntry(
        date: DateTime(2026, 3, 9),
        mood: 5,
        energy: 2,
        tags: const ['work'],
        note: 'hello',
        sky: const JournalSky(tithi: 30, nakshatra: 12, moonSign: Sign.pisces),
      );
      final back = JournalEntry.fromJson(e.toJson());
      expect(back.key, '2026-03-09');
      expect(back.sky!.moonSign, Sign.pisces);
      expect(back.tags, ['work']);
    });
  });

  group('personal remedies', () {
    setUpAll(setUpEphemeris);

    test('suggests dasha lords and debilitated planets', () {
      // Sun at 10° Libra (debilitated), Moon at 5° Taurus.
      final chart = manualChart(
        ascendant: 15,
        longitudes: {
          Planet.sun: 190,
          Planet.moon: 35,
          Planet.mars: 100,
          Planet.mercury: 200,
          Planet.jupiter: 250,
          Planet.venus: 60,
          Planet.saturn: 300,
          Planet.rahu: 10,
          Planet.ketu: 190,
        },
      );
      final s = personalRemedySuggestions(
        chart: chart,
        birthUtc: DateTime.utc(1990, 1, 1),
        now: DateTime.utc(2026, 10, 27),
        ayanamsa: Ayanamsa.lahiri,
        includeMarriageTopics: false,
      );
      expect(s.where((x) => x.reason == SuggestionReason.mahadasha), hasLength(1));
      expect(s.any((x) => x.reason == SuggestionReason.debilitated && x.planet == Planet.sun), isTrue);
      expect(s.any((x) => x.reason == SuggestionReason.manglik), isFalse);
    });
  });
}
