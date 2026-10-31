import 'dart:convert';
import 'dart:io';

import 'package:drishti/core/astro/constants.dart';
import 'package:drishti/core/astro/numerology.dart';
import 'package:drishti/core/astro/numerology_texts.dart';
import 'package:flutter_test/flutter_test.dart';

void _expectConsistent(Working w) {
  expect(w.chain.first, w.terms.fold<int>(0, (a, b) => a + b), reason: 'total is the sum of the terms');
  for (var i = 1; i < w.chain.length; i++) {
    expect(w.chain[i], Numerology.digitSum(w.chain[i - 1]), reason: 'each step adds the digits');
  }
  expect(w.result <= 9 || Numerology.isMaster(w.result), isTrue);
}

void main() {
  group('how it is calculated', () {
    test('life path of 1995-08-23 is 1 with the expected steps', () {
      final d = Numerology.detail('lifePath', birthDate: DateTime(1995, 8, 23))!;
      expect(d.lines.map((l) => l.part), [WorkingPart.month, WorkingPart.day, WorkingPart.year, WorkingPart.sum]);
      expect(d.lines[0].working.format(), '8');
      expect(d.lines[1].working.format(), '23 → 2+3 = 5');
      expect(d.lines[2].working.format(), '1995 → 1+9+9+5 = 24 → 2+4 = 6');
      expect(d.lines[3].working.terms, [8, 5, 6]);
      expect(d.lines[3].working.chain, [19, 10, 1]);
      expect(d.lines[3].working.format(), '8 + 5 + 6 = 19 → 1+9 = 10 → 1+0 = 1');
      expect(d.value, 1);
      expect(Numerology.lifePath(DateTime(1995, 8, 23)), 1);
    });

    test('master numbers are kept where the existing engine keeps them', () {
      final b = Numerology.detail('birthday', birthDate: DateTime(1990, 7, 29))!;
      expect(b.lines.single.working.chain, [29, 11]);
      expect(b.lines.single.working.masterKept, isTrue);
      final m = Numerology.detail('mulank', birthDate: DateTime(1990, 7, 29))!;
      expect(m.lines.single.working.chain, [29, 11, 2]);
      expect(m.lines.single.working.masterKept, isFalse);
      final lp = Numerology.detail('lifePath', birthDate: DateTime(1990, 11, 5))!;
      expect(lp.lines.first.working.chain, [11]);
      expect(lp.lines.first.working.masterKept, isTrue);
    });

    test('Bhagyank adds every digit of the date', () {
      final d = Numerology.detail('bhagyank', birthDate: DateTime(1990, 7, 29))!;
      expect(d.lines.single.working.terms, [2, 9, 7, 1, 9, 9, 0]);
      expect(d.lines.single.working.chain, [37, 10, 1]);
    });

    test('name numbers list letters, vowels and consonants', () {
      final e = Numerology.detail('expression', name: 'John')!;
      expect(e.letters.map((l) => '${l.letter}${l.value}').join(' '), 'J1 O6 H8 N5');
      expect(e.lines.single.working.chain, [20, 2]);
      final s = Numerology.detail('soulUrge', name: 'John')!;
      expect(s.lines.single.part, WorkingPart.vowels);
      expect(s.lines.single.working.terms, [6]);
      final p = Numerology.detail('personality', name: 'John')!;
      expect(p.lines.single.working.terms, [1, 8, 5]);
      expect(p.value, 5);
      final c = Numerology.detail('chaldeanName', name: 'Ram')!;
      expect(c.system, NumerologySystem.chaldean);
      expect(c.lines.single.working.terms, [2, 1, 4]);
      expect(c.value, 7);
    });

    test('details always match the report and the steps add up', () {
      const names = ['John', 'Asha Patel', 'Bhargav Hirpara', 'Lakshmi Narayanan', 'Zoe', 'Y'];
      for (var y = 1901; y <= 2030; y += 7) {
        for (var m = 1; m <= 12; m++) {
          for (final day in [1, 9, 10, 11, 19, 22, 28, 29]) {
            final date = DateTime(y, m, day);
            final name = names[(y + m + day) % names.length];
            final report = Numerology.report(name: name, birthDate: date);
            for (final n in report.numbers) {
              final d = Numerology.detail(n.id, name: name, birthDate: date)!;
              expect(d.value, n.value, reason: '${n.id} $date $name');
              if (n.compound != null) expect(d.total, n.compound);
              for (final l in d.lines) {
                _expectConsistent(l.working);
              }
            }
          }
        }
      }
    });

    test('missing input gives no detail', () {
      expect(Numerology.detail('lifePath', name: 'John'), isNull);
      expect(Numerology.detail('expression', birthDate: DateTime(2000)), isNull);
      expect(Numerology.detail('expression', name: 'राम'), isNull);
    });
  });

  group('combinations', () {
    test('ruling planets', () {
      expect(
        [for (var n = 1; n <= 9; n++) Numerology.planetOf(n)],
        [
          Planet.sun,
          Planet.moon,
          Planet.jupiter,
          Planet.rahu,
          Planet.mercury,
          Planet.venus,
          Planet.ketu,
          Planet.saturn,
          Planet.mars,
        ],
      );
      expect(Numerology.planetOf(11), Planet.moon);
      expect(Numerology.planetOf(22), Planet.rahu);
    });

    test('Mulank-Bhagyank pair friendship', () {
      // 1995-08-23: Mulank 5 (Mercury), Bhagyank 1 (Sun).
      final p = Numerology.mulankBhagyankPair(DateTime(1995, 8, 23));
      expect((p.first, p.second), (5, 1));
      expect(p.firstView, 1); // Mercury regards the Sun as a friend
      expect(p.secondView, 0); // the Sun is neutral to Mercury
      expect(p.relation, PairRelation.friendly);
      expect(Numerology.pair(1, 8).relation, PairRelation.challenging); // Sun-Saturn
      expect(Numerology.pair(1, 9).relation, PairRelation.friendly); // Sun-Mars
      expect(Numerology.pair(2, 5).relation, PairRelation.neutral); // Moon friend, Mercury enemy
      expect(Numerology.pair(3, 6).relation, PairRelation.challenging); // Jupiter-Venus
      expect(Numerology.pair(6, 8).relation, PairRelation.friendly); // Venus-Saturn
      expect(Numerology.pair(3, 3).relation, PairRelation.same);
      expect(Numerology.pair(4, 8).relation, PairRelation.friendly); // Rahu-Saturn (convention)
      expect(Numerology.pair(4, 1).relation, PairRelation.challenging); // Rahu-Sun (convention)
      expect(Numerology.pair(4, 7).relation, PairRelation.neutral);
    });

    test('Lo Shu grid of 1995-08-23', () {
      final pure = Numerology.loShu(DateTime(1995, 8, 23), addMulankBhagyank: false);
      expect(pure.dateDigits, [2, 3, 8, 1, 9, 9, 5]);
      expect(pure.extra, isEmpty);
      expect(pure.missing, [4, 6, 7]);
      expect(pure.repeated, [9]);
      expect(pure.count(9), 2);
      expect(pure.completePlanes, [LoShuPlane.will, LoShuPlane.silver]);

      final indian = Numerology.loShu(DateTime(1995, 8, 23));
      expect(indian.extra, [5, 1]); // Mulank 5, Bhagyank 1
      expect(indian.missing, [4, 6, 7]);
      expect(indian.repeated, [1, 5, 9]);
    });

    test('Lo Shu ignores zeros and does not add Mulank twice', () {
      final g = Numerology.loShu(DateTime(2000, 1, 10));
      expect(g.dateDigits, [1, 1, 2]);
      expect(g.extra, [4]); // Bhagyank only; Mulank 1 is already there
      expect(Numerology.loShu(DateTime(2000, 1, 7)).extra, [Numerology.bhagyank(DateTime(2000, 1, 7))]);
      expect(LoShuGrid.layout.expand((r) => r).toSet(), {1, 2, 3, 4, 5, 6, 7, 8, 9});
      for (final row in LoShuGrid.layout) {
        expect(row.fold<int>(0, (a, b) => a + b), 15);
      }
      for (final p in LoShuPlane.values) {
        expect(p.numbers.fold<int>(0, (a, b) => a + b), 15);
      }
    });

    test('compound numbers', () {
      expect(Numerology.compoundOf(7), isNull);
      expect(Numerology.compoundOf(10), 10);
      expect(Numerology.compoundOf(52), 52);
      expect(Numerology.compoundOf(67), 13);
      expect(Numerology.compoundOf(99), 18);
      expect(Numerology.compoundOf(53), isNull);
    });

    test('personal year, month and day', () {
      final c = Numerology.personalCycles(DateTime(1995, 8, 23), DateTime(2026, 10, 29));
      expect(c.yearLines.map((l) => l.working.result), [5, 8, 1, 5]);
      expect(c.year, 5); // 5 + 8 + (2026 -> 10 -> 1) = 14 -> 5
      expect(c.monthWorking.format(), '5 + 10 = 15 → 1+5 = 6');
      expect(c.month, 6);
      expect(c.dayWorking.format(), '6 + 29 = 35 → 3+5 = 8');
      expect(c.day, 8);
    });
  });

  group('texts', () {
    final placeholder = RegExp(r'\{\w+\}');
    Set<String> ph(String s) => placeholder.allMatches(s).map((m) => m.group(0)!).toSet();

    test('English has every text the screen asks for', () {
      final nt = NumerologyTexts.of('en');
      final keys = numerologyTextsEn.keys.toSet();
      for (final id in [
        'lifePath',
        'birthday',
        'mulank',
        'bhagyank',
        'expression',
        'soulUrge',
        'personality',
        'chaldeanName',
      ]) {
        expect(keys, contains('type.$id'));
      }
      for (final n in [1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 22, 33]) {
        for (final part in ['strengths', 'challenges', 'guidance']) {
          expect(keys, contains('num.$n.$part'));
        }
      }
      for (var n = 1; n <= 9; n++) {
        expect(keys, containsAll(['loshu.missing.$n', 'loshu.repeat.$n.2', 'loshu.repeat.$n.3', 'cycle.$n']));
      }
      for (var c = 10; c <= 52; c++) {
        expect(keys, contains('compound.$c'));
      }
      for (final p in LoShuPlane.values) {
        expect(keys, containsAll(['loshu.plane.${p.name}.name', 'loshu.plane.${p.name}.meaning']));
      }
      for (final r in PairRelation.values) {
        expect(keys, contains('pair.${r.name}'));
      }
      expect(nt.t('missing.key'), 'missing.key');
    });

    test('every language has every content key, nothing extra, no English left', () {
      final enKeys = numerologyTextsEn.keys.toSet();
      final longLatinWord = RegExp('[A-Za-z]{4,}');
      for (final MapEntry(key: lang, value: map) in NumerologyTexts.languages.entries) {
        expect(map.keys.toSet(), enKeys, reason: lang);
        for (final e in map.entries) {
          expect(e.value.trim(), isNotEmpty, reason: '$lang ${e.key}');
          expect(ph(e.value), ph(numerologyTextsEn[e.key]!), reason: '$lang ${e.key}');
          expect(longLatinWord.hasMatch(e.value), isFalse, reason: '$lang ${e.key}: ${e.value}');
        }
      }
    });

    test('UI fragments: every language has every key with the same placeholders', () {
      Map<String, dynamic> read(String path) => jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
      final en = read('lib/l10n/fragments/numero_detail.json');
      final enKeys = en.keys.where((k) => !k.startsWith('@')).toSet();
      for (final k in enKeys) {
        if (ph(en[k] as String).isNotEmpty) expect(en, contains('@$k'), reason: 'metadata for $k');
      }
      for (final lang in ['hi', 'mr', 'bn', 'ta', 'te', 'kn', 'ml']) {
        final map = read('lib/l10n/fragments/numero_detail.$lang.json');
        expect(map.keys.toSet(), enKeys, reason: lang);
        for (final k in enKeys) {
          expect(ph(map[k] as String), ph(en[k] as String), reason: '$lang $k');
        }
      }
    });
  });
}
