import 'package:drishti/core/astro/constants.dart';
import 'package:drishti/core/astro/vedic/match_advice.dart';
import 'package:drishti/core/astro/vedic/matching.dart';
import 'package:drishti/core/astro/western/aspects.dart';
import 'package:drishti/core/i18n/engine_texts.dart';
import 'package:drishti/core/i18n/text_ref.dart';
import 'package:flutter_test/flutter_test.dart';

const _languages = ['en', 'hi', 'mr', 'bn', 'ta', 'te', 'kn', 'ml'];

/// Every text of the advice, in every language, is fully filled in.
void _expectRendered(MatchAdvice a) {
  final refs = <TextRef>[
    a.summary,
    for (final p in [...a.strengths, ...a.cautions]) ...[p.text, ...p.why],
    ...a.steps,
    ...a.remedies,
  ];
  for (final lang in _languages) {
    final et = EngineTexts.of(lang);
    for (final r in refs) {
      final s = et.ref(r);
      expect(s, isNot(contains('{')), reason: '$lang ${r.key}: $s');
      expect(s, isNot(contains('advice.')), reason: '$lang ${r.key}: $s');
      expect(s, isNot(contains('match.')), reason: '$lang ${r.key}: $s');
    }
  }
}

AshtakootResult _match(double boy, double girl) => Ashtakoot.match(
  boy: MatchInput(moonLongitude: boy),
  girl: MatchInput(moonLongitude: girl),
);

MatchAdvice _vedic(AshtakootResult r, double boy, double girl, {bool groom = false, bool bride = false}) =>
    MatchAdvice.vedic(
      r,
      groomMoon: Sign.fromLongitude(boy),
      brideMoon: Sign.fromLongitude(girl),
      groomManglik: groom,
      brideManglik: bride,
    );

void main() {
  test('a strong match with no dosha: conclusion, strengths first by weight, no remedies', () {
    // 31.5 of 36 and no dosha (see matching_why_test).
    final r = _match(261.0, 358.5);
    final a = _vedic(r, 261.0, 358.5);
    // The same verdict as the score card (25 to 32 is a good match).
    expect(a.conclusion, Ashtakoot.verdictId(r.total));
    expect(a.conclusion, 'good');
    expect(EngineTexts.of('en').ref(a.summary), contains('Good match, 31.5 of 36'));
    expect(a.strengths.first.text.key, 'advice.s.nadi');
    expect(a.strengths, hasLength(3));
    // Varna is the only koota at 0.
    expect([for (final c in a.cautions) c.text.key], ['advice.c.varna']);
    expect(a.steps.first.key, 'advice.step.talk');
    expect(a.steps.last.key, 'advice.step.fullChart');
    expect(a.remedies, isEmpty);
    _expectRendered(a);
  });

  test('a counted Nadi dosha is never hidden behind the total', () {
    // Ashwini and Moola: same nadi with no exception; Bhakoot dosha is
    // cancelled because Mars and Jupiter are mutual friends.
    final r = _match(5, 245);
    final a = _vedic(r, 5, 245);
    expect(a.conclusion, r.total < 18 ? 'weak' : 'dosha');
    final cautions = [for (final c in a.cautions) c.text.key];
    expect(cautions, contains('advice.c.nadi'));
    final nadi = a.cautions.firstWhere((c) => c.text.key == 'advice.c.nadi');
    expect(nadi.text.params['cancelled'], isFalse);
    expect(EngineTexts.of('en').ref(nadi.text), contains('most serious'));
    // The why shows the score, the rule steps and each exception checked.
    expect(nadi.why.first.key, 'advice.why.koota');
    expect(nadi.why.where((w) => w.key == 'advice.why.exception'), hasLength(3));
    expect([for (final s in a.steps) s.key], contains('advice.step.health'));
    expect([for (final x in a.remedies) x.key], ['advice.rem.nadi', 'advice.rem.note']);
    if (a.conclusion == 'dosha') {
      expect(EngineTexts.of('en').ref(a.summary), contains('Nadi dosha is counted'));
    }
    _expectRendered(a);
  });

  test('Manglik: one-sided is a caution with a remedy, both is a strength', () {
    final r = _match(261.0, 358.5);
    final one = _vedic(r, 261.0, 358.5, groom: true);
    expect([for (final c in one.cautions) c.text.key], contains('advice.c.manglik'));
    expect([for (final s in one.steps) s.key], contains('advice.step.manglik'));
    expect([for (final x in one.remedies) x.key], ['advice.rem.manglik', 'advice.rem.note']);
    _expectRendered(one);

    final both = _vedic(r, 261.0, 358.5, groom: true, bride: true);
    expect([for (final s in both.strengths) s.text.key], contains('advice.s.manglikBoth'));
    expect(both.remedies, isEmpty);
    _expectRendered(both);
  });

  test('remedies never ask anyone to buy', () {
    for (final key in ['advice.rem.nadi', 'advice.rem.bhakoot', 'advice.rem.manglik', 'advice.rem.note']) {
      final s = EngineTexts.of('en').t(key, {'a': Planet.mars, 'b': Planet.venus});
      expect(s, isNot(matches(RegExp(r'\b(buy|shop|price|order)\b', caseSensitive: false))), reason: key);
    }
  });

  test('Western: conclusion from supportive against challenging aspects, one point per theme', () {
    Aspect x(Planet a, Planet b, AspectType t, double orb) => Aspect(a: a, b: b, type: t, orb: orb, applying: false);
    final a = MatchAdvice.western(
      [
        x(Planet.sun, Planet.moon, AspectType.trine, 1.2),
        x(Planet.moon, Planet.sun, AspectType.sextile, 2.0),
        x(Planet.venus, Planet.mars, AspectType.trine, 3.0),
        x(Planet.mars, Planet.saturn, AspectType.square, 0.5),
        x(Planet.uranus, Planet.sun, AspectType.square, 0.1), // not a personal planet
      ],
      nameA: 'Asha',
      nameB: 'Ravi',
    );
    expect(a.conclusion, 'good');
    expect([for (final s in a.strengths) s.text.key], ['advice.w.good.sunMoon', 'advice.w.good.venusMars']);
    expect([for (final c in a.cautions) c.text.key], ['advice.w.hard.saturn']);
    expect(EngineTexts.of('en').ref(a.cautions.first.why.first), 'Asha\'s Mars square Ravi\'s Saturn (orb 0.5°).');
    expect([for (final s in a.steps) s.key], containsAll(['advice.step.w.anger', 'advice.step.w.duty']));
    _expectRendered(a);
  });
}
