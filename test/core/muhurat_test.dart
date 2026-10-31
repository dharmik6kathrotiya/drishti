import 'package:drishti/core/astro/constants.dart';
import 'package:drishti/core/astro/ephemeris.dart';
import 'package:drishti/core/astro/vedic/muhurat.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/ephemeris_setup.dart';

void main() {
  setUpAll(setUpEphemeris);

  MuhuratFinder delhi() => MuhuratFinder(latitude: 28.6139, longitude: 77.2090, timezoneId: 'Asia/Kolkata');

  test('vehicle purchase windows meet the hard rules and essentials', () {
    final w = delhi().find(
      activity: MuhuratActivity.vehiclePurchase,
      from: DateTime(2025, 11, 1),
      to: DateTime(2025, 11, 30),
    );
    expect(w, isNotEmpty);
    for (final x in w) {
      expect(x.checks.where((c) => c.hard).every((c) => c.passed), isTrue);
      expect(x.checks.firstWhere((c) => c.id == 'nakshatra').passed, isTrue);
      expect(x.checks.firstWhere((c) => c.id == 'tithi').passed, isTrue);
      expect(x.length.inMinutes, greaterThanOrEqualTo(30));
      expect(x.score, inInclusiveRange(0, 100));
      expect(x.endUtc.isAfter(x.startUtc), isTrue);
    }
  });

  test('no marriage muhurat during Chaturmas when the rule is on', () {
    final finder = delhi();
    final on = finder.find(activity: MuhuratActivity.marriage, from: DateTime(2025, 8, 1), to: DateTime(2025, 8, 31));
    expect(on, isEmpty);
    final off = finder.find(
      activity: MuhuratActivity.marriage,
      from: DateTime(2025, 8, 1),
      to: DateTime(2025, 8, 31),
      options: const MuhuratOptions(avoidChaturmas: false, avoidCombustion: false),
    );
    expect(off, isNotEmpty);
  });

  test('no marriage muhurat in Kharmas (Sun in sidereal Sagittarius)', () {
    final w = delhi().find(activity: MuhuratActivity.marriage, from: DateTime(2025, 12, 20), to: DateTime(2026, 1, 10));
    expect(w, isEmpty);
  });

  test('personal Tara and Chandra Bala are reported when a birth Moon is given', () {
    const moon = 100.0; // Pushya, Cancer
    final w = delhi().find(
      activity: MuhuratActivity.travel,
      from: DateTime(2025, 11, 1),
      to: DateTime(2025, 11, 15),
      birthNakshatra: Nakshatra.fromLongitude(moon),
      birthMoonSign: Sign.fromLongitude(moon),
    );
    expect(w, isNotEmpty);
    expect(w.first.checks.any((c) => c.id == 'tara_bala'), isTrue);
    expect(w.first.checks.any((c) => c.id == 'chandra_bala'), isTrue);
  });

  test('windows never overlap Rahu Kaal', () {
    final w = delhi().find(
      activity: MuhuratActivity.businessStart,
      from: DateTime(2025, 11, 3),
      to: DateTime(2025, 11, 9),
    );
    for (final x in w) {
      // Recompute Rahu Kaal for the window's date.
      final jd0 = Ephemeris.julianDay(
        DateTime.utc(x.date.year, x.date.month, x.date.day).subtract(const Duration(hours: 5, minutes: 30)),
      );
      final rise = Ephemeris.riseSet(jd0, Planet.sun, 28.6139, 77.2090, rise: true)!;
      final set = Ephemeris.riseSet(rise, Planet.sun, 28.6139, 77.2090, rise: false)!;
      final vara = x.date.weekday % 7;
      final p = MuhuratFinder.rahuPart[vara];
      final rs = rise + (set - rise) * p / 8, re = rise + (set - rise) * (p + 1) / 8;
      final a = Ephemeris.julianDay(x.startUtc), b = Ephemeris.julianDay(x.endUtc);
      expect(b <= rs + 1e-6 || a >= re - 1e-6, isTrue);
    }
  });
}
