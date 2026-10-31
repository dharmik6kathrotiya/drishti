import 'package:drishti/core/astro/constants.dart';
import 'package:drishti/core/astro/settings.dart';
import 'package:drishti/core/horoscope/horoscope_generator.dart';
import 'package:drishti/core/horoscope/interpretations_en.dart';
import 'package:drishti/core/horoscope/sky_events.dart';
import 'package:drishti/core/horoscope/transit_engine.dart';
import 'package:drishti/core/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/ephemeris_setup.dart';

const ist = Duration(hours: 5, minutes: 30);
const forbidden = ['guaranteed', 'guarantee', 'definitely will', 'curse', 'doomed', 'disaster', 'death'];

final fullProfile = Profile(
  id: 'full',
  name: 'Full data',
  birthDate: DateTime(1990, 5, 17),
  birthHour: 8,
  birthMinute: 45,
  timeAccuracy: TimeAccuracy.exact,
  place: const Place(name: 'Ahmedabad', latitude: 23.0225, longitude: 72.5714, timezoneId: 'Asia/Kolkata'),
);

final dateOnlyProfile = Profile(id: 'date-only', name: 'Date only', birthDate: DateTime(1985, 11, 2));

void main() {
  setUpAll(setUpEphemeris);

  const vedic = CalcSettings();
  const western = CalcSettings(system: AstroSystem.western);
  final day = DateTime(2026, 10, 26);

  final subjects = {
    'full': HoroscopeSubject.fromProfile(fullProfile),
    'date-only': HoroscopeSubject.fromProfile(dateOnlyProfile),
    'sign-only': HoroscopeSubject.forSign(Sign.leo),
  };

  void checkTexts(Horoscope h) {
    final all = [
      h.summary,
      h.why,
      ...h.keyEvents,
      for (final s in h.sections) s.text,
      for (final r in h.reasons) r.text,
      if (h.lucky != null) h.lucky!.note,
    ].join('\n').toLowerCase();
    for (final w in forbidden) {
      expect(all.contains(w), isFalse, reason: 'contains "$w"');
    }
    expect(all.contains('{'), isFalse, reason: 'unfilled placeholder');
    expect(all.contains('[period'), isFalse, reason: 'missing key');
  }

  for (final system in [vedic, western]) {
    for (final entry in subjects.entries) {
      for (final period in HoroscopePeriod.values) {
        test('${system.system.name} ${entry.key} ${period.name}', () {
          final h = generate(
            subject: entry.value,
            period: period,
            date: day,
            settings: system,
            utcOffset: ist,
            latitude: 23.0225,
            longitude: 72.5714,
          );
          expect(h.sections, hasLength(5));
          expect(h.overallScore, inInclusiveRange(1, 5));
          for (final s in h.sections) {
            expect(s.score, inInclusiveRange(1, 5));
            expect(s.reasons, isNotEmpty, reason: '${s.area} has no reasons');
            final sentences = s.text.split(RegExp(r'(?<=\.)\s+'));
            expect(sentences.length, inInclusiveRange(2, 4), reason: s.text);
          }
          expect(h.reasons, isNotEmpty);
          expect(h.why, isNotEmpty);
          expect(h.signOnly, entry.key == 'sign-only');
          if (period == HoroscopePeriod.daily) {
            expect(h.lucky, isNotNull);
            expect(h.lucky!.timeWindow, isNotNull);
          }
          if (period != HoroscopePeriod.daily) expect(h.keyEvents, isNotEmpty);
          checkTexts(h);
        });
      }
    }
  }

  test('output is deterministic', () {
    String render(Horoscope h) => [h.summary, h.why, for (final s in h.sections) '${s.score}${s.text}'].join('|');
    final a = generate(
      subject: subjects['full']!,
      period: HoroscopePeriod.daily,
      date: day,
      settings: vedic,
      utcOffset: ist,
    );
    final b = generate(
      subject: subjects['full']!,
      period: HoroscopePeriod.daily,
      date: day,
      settings: vedic,
      utcOffset: ist,
    );
    expect(render(a), render(b));
  });

  test('date-only subject flags approximation when Moon changes sign', () {
    // On 2024-01-01 the sidereal Moon moved from Simha into Kanya.
    final p = Profile(id: 'x', name: 'x', birthDate: DateTime(2024, 1, 1));
    final natal = HoroscopeSubject.fromProfile(p).natalFor(vedic);
    final h = generate(
      subject: HoroscopeSubject.fromProfile(p),
      period: HoroscopePeriod.daily,
      date: day,
      settings: vedic,
      utcOffset: ist,
    );
    expect(h.approximate, natal.anyApproximate);
    if (natal.moonApproximate) {
      expect(h.reasons.any((r) => r.kind == ReasonKind.approximation), isTrue);
    }
  });

  test('vedha: Sun in 11th is obstructed by a planet in the 5th', () {
    expect(TransitEngine.vedha[Planet.sun]![11], 5);
    expect(TransitEngine.favourableHouses[Planet.jupiter], {2, 5, 7, 9, 11});
  });

  test('tara bala names count from the birth star', () {
    final tb = TaraBala(count: 3, transitNakshatra: Nakshatra.all[2], birthNakshatra: Nakshatra.all[0]);
    expect(tb.tara, 2);
    expect(tb.polarity, -1);
    expect(interpretationsEn.one('tara.name.${tb.tara}'), 'Vipat');
  });

  test('eclipses of 2026 are found', () {
    final e = SkyEvents.eclipses(DateTime.utc(2026), DateTime.utc(2027));
    expect(e.where((x) => x.type == SkyEventType.solarEclipse), hasLength(2));
    expect(e.where((x) => x.type == SkyEventType.lunarEclipse), hasLength(2));
  });

  test('every planet/area/polarity has effect text', () {
    for (final p in Planet.values) {
      for (final a in LifeArea.values) {
        for (final pol in ['pos', 'neg']) {
          expect(
            interpretationsEn.entries['fx.${p.name}.${a.name}.$pol'],
            isNotNull,
            reason: 'fx.${p.name}.${a.name}.$pol',
          );
        }
      }
    }
  });
}
