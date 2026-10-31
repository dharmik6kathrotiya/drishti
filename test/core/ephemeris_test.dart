import 'package:drishti/core/astro/constants.dart';
import 'package:drishti/core/astro/ephemeris.dart';
import 'package:drishti/core/astro/settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/ephemeris_setup.dart';

void main() {
  setUpAll(setUpEphemeris);

  final j2000 = DateTime.utc(2000, 1, 1, 12);

  test('Julian day of J2000', () {
    expect(Ephemeris.julianDay(j2000), closeTo(2451545.0, 1e-9));
  });

  test('Lahiri ayanamsa at J2000 is about 23°51\'', () {
    final jd = Ephemeris.julianDay(j2000);
    expect(Ephemeris.ayanamsa(jd, Ayanamsa.lahiri), closeTo(23.857, 0.01));
  });

  test('Sun and Moon tropical longitudes at J2000', () {
    final jd = Ephemeris.julianDay(j2000);
    expect(Ephemeris.position(jd, Planet.sun).longitude, closeTo(280.37, 0.05));
    expect(Ephemeris.position(jd, Planet.moon).longitude, closeTo(223.32, 0.1));
  });

  test('Ketu is exactly opposite Rahu', () {
    final jd = Ephemeris.julianDay(j2000);
    final rahu = Ephemeris.position(jd, Planet.rahu, ayanamsa: Ayanamsa.lahiri).longitude;
    final ketu = Ephemeris.position(jd, Planet.ketu, ayanamsa: Ayanamsa.lahiri).longitude;
    expect(angularDistance(rahu, ketu), closeTo(180, 1e-9));
  });

  test('Sunrise in New Delhi on 2024-06-21 is about 05:23 IST', () {
    // Search from local midnight (18:30 UT previous day).
    final start = Ephemeris.julianDay(DateTime.utc(2024, 6, 20, 18, 30));
    final rise = Ephemeris.riseSet(start, Planet.sun, 28.6139, 77.2090, rise: true)!;
    final ist = Ephemeris.dateTimeFromJd(rise).add(const Duration(hours: 5, minutes: 30));
    expect(ist.hour, 5);
    expect(ist.minute, inInclusiveRange(21, 26));
  });
}
