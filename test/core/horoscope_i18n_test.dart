import 'package:drishti/core/astro/constants.dart';
import 'package:drishti/core/astro/settings.dart';
import 'package:drishti/core/horoscope/horoscope_generator.dart';
import 'package:drishti/core/horoscope/interpretations.dart';
import 'package:drishti/core/horoscope/interpretations_en.dart';
import 'package:drishti/core/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/ephemeris_setup.dart';

const ist = Duration(hours: 5, minutes: 30);

final fullProfile = Profile(
  id: 'full',
  name: 'Full data',
  birthDate: DateTime(1990, 5, 17),
  birthHour: 8,
  birthMinute: 45,
  timeAccuracy: TimeAccuracy.exact,
  place: const Place(name: 'Ahmedabad', latitude: 23.0225, longitude: 72.5714, timezoneId: 'Asia/Kolkata'),
);

/// Keys that only make sense in English (articles).
bool _englishOnly(String key) => key.endsWith('.the');

Set<String> _placeholders(Iterable<String> texts) => {
  for (final t in texts)
    for (final m in RegExp(r'\{(\w+)\}').allMatches(t)) m.group(1)!,
};

/// Common English words that must not leak into other languages.
final _englishLeak = RegExp(r'\b(the|and|your|house|transits?|traditionally|favourable)\b', caseSensitive: false);

void main() {
  final others = horoscopeLanguages.where((l) => l != 'en').toList();

  group('text packs', () {
    final en = interpretationsEn.entries;

    for (final lang in others) {
      test('$lang has every English key with the same variant count', () {
        final pack = horoscopeTextsFor(lang);
        expect(pack.languageCode, lang);
        for (final e in en.entries) {
          if (_englishOnly(e.key)) continue;
          final tr = pack.entries[e.key];
          expect(tr, isNotNull, reason: '$lang is missing "${e.key}"');
          expect(tr!.length, e.value.length, reason: '$lang "${e.key}" variant count');
          for (final v in tr) {
            expect(v.trim(), isNotEmpty, reason: '$lang "${e.key}" is empty');
          }
        }
      });

      test('$lang has no extra keys and no unknown placeholders', () {
        final pack = horoscopeTextsFor(lang);
        for (final e in pack.entries.entries) {
          expect(en.containsKey(e.key), isTrue, reason: '$lang has unknown key "${e.key}"');
          final allowed = _placeholders(en[e.key]!);
          final used = _placeholders(e.value);
          expect(
            allowed.containsAll(used),
            isTrue,
            reason: '$lang "${e.key}" uses ${used.difference(allowed)} not in English',
          );
        }
      });

      test('$lang texts contain no English words', () {
        final pack = horoscopeTextsFor(lang);
        for (final e in pack.entries.entries) {
          // Abbreviated month names and nakshatra transliterations are fine.
          for (final v in e.value) {
            expect(_englishLeak.hasMatch(v), isFalse, reason: '$lang "${e.key}": $v');
          }
        }
      });
    }
  });

  group('generated readings', () {
    setUpAll(setUpEphemeris);

    final day = DateTime(2026, 10, 26);
    final subjects = {
      'full': HoroscopeSubject.fromProfile(fullProfile),
      'sign-only': HoroscopeSubject.forSign(Sign.scorpio),
    };

    List<String> allTexts(Horoscope h) => [
      h.summary,
      h.why,
      ...h.keyEvents,
      for (final s in h.sections) ...[s.title, s.text, for (final r in s.reasons) r.text],
      for (final r in h.reasons) r.text,
      if (h.lucky != null) ...[h.lucky!.note, h.lucky!.color, ?h.lucky!.timeWindow],
    ];

    for (final lang in horoscopeLanguages) {
      for (final system in AstroSystem.values) {
        for (final entry in subjects.entries) {
          test('$lang ${system.name} ${entry.key}: all periods read cleanly', () {
            for (final period in HoroscopePeriod.values) {
              Horoscope gen() => generate(
                subject: entry.value,
                period: period,
                date: day,
                settings: CalcSettings(system: system),
                utcOffset: ist,
                latitude: 28.6139,
                longitude: 77.2090,
                languageCode: lang,
              );
              final h = gen();
              final texts = allTexts(h);
              final joined = texts.join('\n');
              expect(h.summary.trim(), isNotEmpty);
              expect(h.sections, hasLength(5));
              for (final s in h.sections) {
                expect(s.text.trim(), isNotEmpty, reason: '$lang ${period.name} ${s.area.name}');
              }
              expect(joined.contains('{'), isFalse, reason: 'unfilled placeholder in $lang ${period.name}:\n$joined');
              expect(
                RegExp(r'\[[a-z]+\.').hasMatch(joined),
                isFalse,
                reason: 'missing key in $lang ${period.name}:\n$joined',
              );
              if (lang != 'en') {
                expect(
                  _englishLeak.hasMatch(joined),
                  isFalse,
                  reason: 'English leaked into $lang ${period.name}:\n$joined',
                );
              }

              // Deterministic: the same input gives the same reading.
              final again = gen();
              expect(allTexts(again), texts);
            }
          });
        }
      }
    }

    test('English keeps articles ("the Sun") and other languages never get them', () {
      final en = generate(
        subject: HoroscopeSubject.fromProfile(fullProfile),
        period: HoroscopePeriod.yearly,
        date: day,
        settings: const CalcSettings(),
        utcOffset: ist,
      );
      expect(horoscopeTextsFor('hi').own('planet.sun.the'), isNull);
      expect(horoscopeTextsFor('en').own('planet.sun.the'), 'the Sun');
      expect(en.reasons, isNotEmpty);
    });
  });
}
