import 'package:drishti/core/astro/chart.dart';
import 'package:drishti/core/astro/constants.dart';
import 'package:drishti/core/astro/kp/kp.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/ephemeris_setup.dart';
import '../helpers/manual_chart.dart';

void main() {
  test('0° Aries: Mars sign, Ketu star, Ketu sub, Ketu sub-sub', () {
    final l = subLordsOf(0);
    expect(l.signLord, Planet.mars);
    expect(l.starLord, Planet.ketu);
    expect(l.subLord, Planet.ketu);
    expect(l.subSubLord, Planet.ketu);
  });

  test('13°20\' Aries starts Bharani: Venus star, Venus sub', () {
    final l = subLordsOf(13 + 20 / 60 + 1e-9);
    expect(l.starLord, Planet.venus);
    expect(l.subLord, Planet.venus);
  });

  test('Second sub of Ashwini (Venus) starts at 0°46\'40"', () {
    // Ketu sub = 800' × 7/120 = 46'40".
    expect(subLordsOf(46 / 60 + 39 / 3600).subLord, Planet.ketu);
    expect(subLordsOf(46 / 60 + 41 / 3600).subLord, Planet.venus);
  });

  test('249 horary divisions covering the zodiac', () {
    final t = kpHoraryTable();
    expect(t.length, 249);
    expect(kpHoraryStart(1), 0);
    expect(t.last.end, closeTo(360, 1e-9));
    for (var i = 1; i < t.length; i++) {
      expect(t[i].start, closeTo(t[i - 1].end, 1e-9));
    }
    // No division crosses a sign boundary.
    for (final d in t) {
      expect((d.start / 30).floor(), ((d.end - 1e-9) / 30).floor());
    }
    expect(() => kpHoraryStart(250), throwsRangeError);
  });

  test('Significators list occupants and the house lord', () {
    // Ascendant Aries; Sun in Aries 5° (Ashwini, Ketu star) -> house 1.
    final chart = manualChart(
      ascendant: 2,
      longitudes: {
        Planet.sun: 5,
        Planet.moon: 100,
        Planet.mars: 200,
        Planet.mercury: 20,
        Planet.jupiter: 250,
        Planet.venus: 310,
        Planet.saturn: 150,
        Planet.rahu: 60,
        Planet.ketu: 240,
      },
    );
    final sig = kpSignificators(chart);
    expect(sig.length, 12);
    final h1 = sig.first;
    expect(h1.occupants, containsAll([Planet.sun, Planet.mercury]));
    expect(h1.lord, Planet.mars);
    // Mercury at 20° Aries is in Bharani (Venus star); Sun is in Ashwini (Ketu).
    expect(h1.inStarOfOccupants, isNot(contains(Planet.sun)));
    expect(h1.all.last, Planet.mars);
  });

  group('with ephemeris', () {
    setUpAll(setUpEphemeris);

    test('KP cusps and ruling planets are produced', () {
      final utc = DateTime.utc(2024, 1, 1, 6, 30);
      final chart = ChartCalculator.cast(utc: utc, settings: kpSettings, latitude: 19.076, longitude: 72.8777);
      final cusps = kpCusps(chart);
      expect(cusps.length, 12);
      expect(cusps.first.longitude, closeTo(chart.ascendant!, 1e-9));
      final rp = kpRulingPlanets(utc, 19.076, 72.8777);
      // 1 Jan 2024 was a Monday (sunrise in Mumbai ~07:12 IST = 01:42 UT).
      expect(rp.dayLord, Planet.moon);
      expect(rp.ascendantSignLord, chart.ascendantSign!.lord);
      expect(rp.all, isNotEmpty);
    });
  });
}
