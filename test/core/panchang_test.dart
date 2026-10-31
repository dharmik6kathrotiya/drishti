import 'package:drishti/core/astro/vedic/panchang.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/ephemeris_setup.dart';

const ist = Duration(hours: 5, minutes: 30);
const delhiLat = 28.6139, delhiLon = 77.2090;

void main() {
  setUpAll(setUpEphemeris);

  Panchang delhi(int y, int m, int d) =>
      PanchangCalculator.compute(date: DateTime(y, m, d), latitude: delhiLat, longitude: delhiLon, utcOffset: ist);

  void expectNear(DateTime? actualUtc, DateTime expectedIst, {int minutes = 3}) {
    final local = actualUtc!.add(ist);
    final expected = DateTime.utc(
      expectedIst.year,
      expectedIst.month,
      expectedIst.day,
      expectedIst.hour,
      expectedIst.minute,
    );
    expect(
      local.difference(expected).inMinutes.abs(),
      lessThanOrEqualTo(minutes),
      reason: 'got $local expected $expected',
    );
  }

  test('Diwali 2024: Amavasya on Friday, ends 18:16 IST, Ashwin/Kartika', () {
    final p = delhi(2024, 11, 1);
    expect(p.vara, 5);
    expect(p.tithi.index, 30);
    expect(p.tithi.name, 'Amavasya');
    expectNear(p.tithi.endsAt, DateTime(2024, 11, 1, 18, 16));
    expect(p.lunarMonthAmanta, 'Ashwin');
    expect(p.lunarMonthPurnimanta, 'Kartika');
    expect(p.vikramSamvat, 2081);
  });

  test('Holi 2024: Purnima at sunrise on 25 March, ends 12:29 IST', () {
    final p = delhi(2024, 3, 25);
    expect(p.tithi.index, 15);
    expect(p.paksha, 'Shukla');
    expectNear(p.tithi.endsAt, DateTime(2024, 3, 25, 12, 29));
    expect(p.lunarMonthAmanta, 'Phalguna');
  });

  test('Rahu Kaal on a Monday falls in the 2nd eighth of the day', () {
    final p = delhi(2024, 6, 24); // Monday
    expect(p.vara, 1);
    final dayLen = p.sunset.difference(p.sunrise);
    expect(p.rahuKaal.start.difference(p.sunrise.add(dayLen ~/ 8)).inMilliseconds.abs(), lessThan(10));
    expect(p.dayChoghadiya.first.label, 'Amrit');
    expect(p.horas.first.label, 'moon');
  });

  test('Nakshatra and yoga end after sunrise', () {
    final p = delhi(2025, 1, 14);
    expect(p.nakshatra.endsAt!.isAfter(p.sunrise), isTrue);
    expect(p.yoga.endsAt!.isAfter(p.sunrise), isTrue);
    expect(p.karana.endsAt!.isAfter(p.sunrise), isTrue);
  });
}
