import 'package:drishti/core/astro/constants.dart';
import 'package:drishti/core/astro/vedic/children.dart';
import 'package:drishti/core/i18n/engine_texts.dart';
import 'package:drishti/core/i18n/text_ref.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/manual_chart.dart';

const _languages = ['en', 'hi', 'mr', 'bn', 'ta', 'te', 'kn', 'ml'];

void _expectRendered(Iterable<TextRef> refs) {
  for (final lang in _languages) {
    final et = EngineTexts.of(lang);
    for (final r in refs) {
      final s = et.ref(r);
      expect(s, isNot(contains('{')), reason: '$lang ${r.key}: $s');
      expect(s, isNot(contains(RegExp(r'children\.[a-z]'))), reason: '$lang ${r.key}: $s');
    }
  }
}

List<String> _keys(ChildrenReport r) => [for (final f in r.factors) f.text.key];

void main() {
  final birth = DateTime.utc(1990, 1, 1);
  final now = DateTime.utc(2026, 1, 1);

  test('a supportive chart: 5th lord in its own house, Jupiter strong and aspecting the 5th', () {
    // Aries Ascendant, so the 5th is Leo ruled by the Sun. Sun in Leo (house
    // 5), Jupiter in Sagittarius (house 9, own sign), which aspects Leo.
    final c = manualChart(ascendant: 5, longitudes: {Planet.sun: 130, Planet.jupiter: 250});
    final r = Children.single(c, birthUtc: birth, now: now);
    expect(r.fromMoon, isFalse);
    expect(r.fifthSign, Sign.leo);
    expect(r.fifthLord, Planet.sun);
    expect(_keys(r), ['children.f.lordGood', 'children.f.jupGood', 'children.f.jupStrong', 'children.f.jupAspect']);
    expect(r.tone, 1);
    _expectRendered([for (final f in r.factors) f.text]);
  });

  test('a chart with classical signs of delay', () {
    // 5th lord Sun in Scorpio (house 8), Jupiter debilitated in Capricorn,
    // Saturn alone in Leo with no benefic in or aspecting it.
    final c = manualChart(
      ascendant: 5,
      longitudes: {Planet.sun: 220, Planet.jupiter: 280, Planet.saturn: 130, Planet.mercury: 225, Planet.venus: 230},
    );
    final r = Children.single(c, birthUtc: birth, now: now);
    expect(_keys(r), [
      'children.f.lordDusthana',
      'children.f.jupGood',
      'children.f.jupDebilitated',
      'children.f.maleficIn',
    ]);
    expect(r.score, -2);
    expect(r.tone, -1);
    expect(EngineTexts.of('en').raw('children.tone.-1'), contains('not as a final answer'));
  });

  test('without a birth time houses are counted from the Moon', () {
    final c = manualChart(longitudes: {Planet.moon: 95, Planet.jupiter: 250});
    final r = Children.single(c, birthUtc: birth, now: now);
    expect(r.fromMoon, isTrue);
    expect(r.fifthSign, Sign.scorpio); // Cancer Moon
    expect(r.fifthLord, Planet.mars);
  });

  test('periods: Antardashas of the significators inside the next 12 years', () {
    final c = manualChart(ascendant: 5, longitudes: {Planet.sun: 130, Planet.jupiter: 250, Planet.moon: 40});
    final r = Children.single(c, birthUtc: birth, now: now);
    expect(r.windows, isNotEmpty);
    final until = now.add(const Duration(days: 12 * 366));
    for (final w in r.windows) {
      expect(w.start.isBefore(now), isFalse);
      expect(w.start.isBefore(until), isTrue);
      expect(w.end.isAfter(w.start), isTrue);
      final ad = w.why.first.params['ad'];
      expect(ad, anyOf(Planet.sun, Planet.jupiter));
    }
    _expectRendered([for (final w in r.windows) ...w.why]);
  });

  test('Beeja and Kshetra Sphuta follow the odd/even sign and navamsa rule', () {
    // 1 + 0.5 + 0.5 = 2°: Aries (odd), navamsa Aries (odd): strong.
    final man = manualChart(longitudes: {Planet.sun: 1, Planet.venus: 0.5, Planet.jupiter: 0.5});
    expect(Children.beeja(man).longitude, closeTo(2, 1e-9));
    expect(Children.beeja(man).tone, 1);
    // 35°: Taurus (even) but navamsa Aquarius (odd): moderate.
    final man2 = manualChart(longitudes: {Planet.sun: 10, Planet.venus: 20, Planet.jupiter: 5});
    expect(Children.beeja(man2).navamsa, Sign.aquarius);
    expect(Children.beeja(man2).tone, 0);
    // 32°: Taurus (even), navamsa Capricorn (even): strong for the mother.
    final woman = manualChart(longitudes: {Planet.moon: 10, Planet.mars: 12, Planet.jupiter: 10});
    expect(Children.kshetra(woman).sign, Sign.taurus);
    expect(Children.kshetra(woman).navamsa, Sign.capricorn);
    expect(Children.kshetra(woman).tone, 1);
    // Over 360 wraps: 200 + 100 + 62 = 362 → 2°, Aries: odd and odd, weak.
    final woman2 = manualChart(longitudes: {Planet.moon: 200, Planet.mars: 100, Planet.jupiter: 62});
    expect(Children.kshetra(woman2).longitude, closeTo(2, 1e-9));
    expect(Children.kshetra(woman2).tone, -1);
    _expectRendered([...Children.beeja(man2).why, ...Children.kshetra(woman2).why]);
  });

  test('a couple: shared periods lie inside both people\'s periods', () {
    final f = manualChart(ascendant: 5, longitudes: {Planet.sun: 130, Planet.jupiter: 250, Planet.moon: 40});
    final m = manualChart(ascendant: 95, longitudes: {Planet.sun: 300, Planet.jupiter: 100, Planet.moon: 200});
    final c = Children.couple(f, m, fatherUtc: birth, motherUtc: DateTime.utc(1992, 6, 1), now: now);
    for (final (s, e) in c.shared) {
      bool inside(ChildrenReport r) => r.windows.any((w) => !s.isBefore(w.start) && !e.isAfter(w.end));
      expect(inside(c.father), isTrue);
      expect(inside(c.mother), isTrue);
    }
    expect(c.tone, inInclusiveRange(-1, 1));
  });

  test('no reading text says boy, girl, son or daughter; only the tradition page explains them', () {
    final forbidden = RegExp(r'\b(boy|girl|son|sons|daughter|daughters|male|female)\b', caseSensitive: false);
    for (final e in engineTextsEn.entries) {
      if (!e.key.startsWith('children.') || e.key.startsWith('children.trad.')) continue;
      expect(e.value, isNot(matches(forbidden)), reason: e.key);
    }
    // Every language has the tradition page.
    for (final lang in _languages) {
      for (final k in ['intro', 'rules', 'science', 'law', 'equal']) {
        expect(EngineTexts.of(lang).has('children.trad.$k'), isTrue);
      }
    }
  });
}
