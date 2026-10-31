import '../chart.dart';
import '../constants.dart';
import 'progressions.dart';

/// Composite chart by the midpoint method: every planet and angle is placed
/// at the nearer midpoint of the two partners' positions. Cusps are the
/// nearer midpoints of the corresponding cusps (a common simple approach; the
/// "derived from composite MC" variant gives slightly different cusps).
class Composite {
  Composite._();

  /// Nearer midpoint of two longitudes.
  static double midpoint(double a, double b) {
    final d = norm360(b - a);
    final mid = norm360(a + d / 2);
    return d > 180 ? norm360(mid + 180) : mid;
  }

  static Chart compute(Chart a, Chart b) {
    final planets = <Planet, PlanetPlacement>{};
    for (final p in a.planets.keys) {
      final pb = b.planets[p];
      if (pb == null) continue;
      final pa = a[p];
      planets[p] = PlanetPlacement(
        planet: p,
        longitude: midpoint(pa.longitude, pb.longitude),
        latitude: (pa.latitude + pb.latitude) / 2,
        speed: (pa.speed + pb.speed) / 2,
      );
    }
    final bothHouses = a.hasHouses && b.hasHouses;
    final cusps = bothHouses ? [for (var i = 0; i < 12; i++) midpoint(a.cusps![i], b.cusps![i])] : null;
    final asc = bothHouses ? midpoint(a.ascendant!, b.ascendant!) : null;
    // Keep Ketu exactly opposite Rahu after taking midpoints.
    final rahu = planets[Planet.rahu];
    if (rahu != null && planets.containsKey(Planet.ketu)) {
      planets[Planet.ketu] = PlanetPlacement(
        planet: Planet.ketu,
        longitude: norm360(rahu.longitude + 180),
        latitude: -rahu.latitude,
        speed: rahu.speed,
      );
    }
    return Chart(
      jd: (a.jd + b.jd) / 2,
      settings: a.settings,
      planets: cusps == null ? planets : withHouses(planets, cusps, asc!, a.settings.houseSystem),
      ayanamsaValue: (a.ayanamsaValue + b.ayanamsaValue) / 2,
      ascendant: asc,
      midheaven: bothHouses ? midpoint(a.midheaven!, b.midheaven!) : null,
      cusps: cusps,
      latitude: bothHouses ? (a.latitude! + b.latitude!) / 2 : null,
      longitude: bothHouses ? (a.longitude! + b.longitude!) / 2 : null,
    );
  }
}
