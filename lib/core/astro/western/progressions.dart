import 'dart:math' as math;

import 'package:sweph/sweph.dart';

import '../chart.dart';
import '../constants.dart';
import '../settings.dart';

/// Secondary progressions ("a day for a year").
///
/// Method:
/// * Planets: positions on the day that is as many days after birth as the
///   native is years old (tropical year of 365.2422 days).
/// * MC: natal MC plus the solar arc in longitude (progressed Sun minus
///   natal Sun). The Ascendant and cusps are then derived from that MC at the
///   birth latitude via the right ascension of the MC (ARMC). Other
///   programs may use the solar arc in right ascension or Naibod; results
///   then differ by a fraction of a degree.
class Progressions {
  Progressions._();

  static const tropicalYear = 365.2422;

  static Chart progressed(Chart natal, DateTime birthUtc, DateTime target) {
    final ageYears = target.difference(birthUtc).inSeconds / (tropicalYear * 86400);
    final progUtc = birthUtc.add(Duration(seconds: (ageYears * 86400).round()));
    final settings = natal.settings;
    final base = ChartCalculator.cast(utc: progUtc, settings: settings, withHouses: false);
    if (!natal.hasHouses || natal.latitude == null) return base;

    final arc = norm360(base.sun.longitude - natal.sun.longitude);
    final mc = norm360(natal.midheaven! + arc);
    final eps = obliquity(base.jd);
    // Convert the progressed MC (tropical ecliptic longitude) to ARMC.
    final tropicalMc = settings.sidereal ? norm360(mc + natal.ayanamsaValue) : mc;
    final l = tropicalMc * math.pi / 180, e = eps * math.pi / 180;
    final armc = norm360(math.atan2(math.sin(l) * math.cos(e), math.cos(l)) * 180 / math.pi);
    final hsys = _hsys(settings.houseSystem);
    final h = Sweph.swe_houses_armc(armc, natal.latitude!, eps, hsys);
    final offset = settings.sidereal ? natal.ayanamsaValue : 0.0;
    final cusps = [for (var i = 1; i <= 12; i++) norm360(h.cusps[i] - offset)];
    final asc = norm360(h.ascmc[0] - offset);

    return Chart(
      jd: base.jd,
      settings: settings,
      planets: withHouses(base.planets, cusps, asc, settings.houseSystem),
      ayanamsaValue: base.ayanamsaValue,
      ascendant: asc,
      midheaven: mc,
      cusps: cusps,
      latitude: natal.latitude,
      longitude: natal.longitude,
    );
  }

  /// Mean obliquity of the ecliptic (IAU 1980, sufficient for house angles).
  static double obliquity(double jd) {
    final t = (jd - 2451545.0) / 36525;
    return 23.439291 - 0.0130042 * t - 1.64e-7 * t * t + 5.04e-7 * t * t * t;
  }

  static Hsys _hsys(HouseSystem h) => switch (h) {
    HouseSystem.wholeSign => Hsys.W,
    HouseSystem.koch => Hsys.K,
    HouseSystem.equal => Hsys.E,
    HouseSystem.porphyry => Hsys.O,
    HouseSystem.regiomontanus => Hsys.R,
    HouseSystem.campanus => Hsys.C,
    HouseSystem.sripati => Hsys.S,
    _ => Hsys.P,
  };
}

/// Re-assigns house numbers for given cusps (index 0 = 1st house).
Map<Planet, PlanetPlacement> withHouses(
  Map<Planet, PlanetPlacement> planets,
  List<double> cusps,
  double asc,
  HouseSystem system,
) {
  int houseOf(double lon) {
    if (system == HouseSystem.wholeSign) return Sign.fromLongitude(asc).countTo(Sign.fromLongitude(lon));
    for (var i = 0; i < 12; i++) {
      final start = cusps[i], end = cusps[(i + 1) % 12];
      if (norm360(lon - start) < norm360(end - start)) return i + 1;
    }
    return 1;
  }

  return {
    for (final e in planets.entries)
      e.key: PlanetPlacement(
        planet: e.key,
        longitude: e.value.longitude,
        latitude: e.value.latitude,
        speed: e.value.speed,
        house: houseOf(e.value.longitude),
      ),
  };
}
