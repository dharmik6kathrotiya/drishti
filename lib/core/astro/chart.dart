import 'constants.dart';
import 'ephemeris.dart';
import 'settings.dart';

class PlanetPlacement {
  const PlanetPlacement({
    required this.planet,
    required this.longitude,
    required this.latitude,
    required this.speed,
    this.house,
  });

  final Planet planet;

  /// Zodiacal longitude in the chart's zodiac (sidereal for Vedic).
  final double longitude;
  final double latitude;
  final double speed;

  /// 1..12, null when the birth time is unknown.
  final int? house;

  Sign get sign => Sign.fromLongitude(longitude);
  double get degreeInSign => longitude % 30;
  Nakshatra get nakshatra => Nakshatra.fromLongitude(longitude);
  int get pada => Nakshatra.padaOf(longitude);

  /// Nodes are always retrograde in mean motion; we report them as such.
  bool get isRetrograde => planet.isNode ? true : speed < 0;

  bool get isExalted => Dignity.exaltationSign(planet) == sign;
  bool get isDebilitated => Dignity.debilitationSign(planet) == sign;
  bool get isOwnSign => sign.lord == planet;
}

/// A cast chart: planets, houses and angles for one moment and place.
class Chart {
  Chart({
    required this.jd,
    required this.settings,
    required this.planets,
    required this.ayanamsaValue,
    this.ascendant,
    this.midheaven,
    this.cusps,
    this.latitude,
    this.longitude,
  });

  final double jd;
  final CalcSettings settings;
  final Map<Planet, PlanetPlacement> planets;
  final double ayanamsaValue;
  final double? ascendant;
  final double? midheaven;

  /// Cusp longitudes, index 0 = 1st house. Null without birth time.
  final List<double>? cusps;
  final double? latitude;
  final double? longitude;

  bool get hasHouses => ascendant != null;
  Sign? get ascendantSign => ascendant == null ? null : Sign.fromLongitude(ascendant!);
  PlanetPlacement operator [](Planet p) => planets[p]!;

  PlanetPlacement get moon => planets[Planet.moon]!;
  PlanetPlacement get sun => planets[Planet.sun]!;

  /// Planets occupying a house (1..12).
  List<PlanetPlacement> inHouse(int house) => planets.values.where((p) => p.house == house).toList();

  /// Planets in a sign.
  List<PlanetPlacement> inSign(Sign sign) => planets.values.where((p) => p.sign == sign).toList();

  /// House counted from a reference sign (e.g. Moon for Chandra lagna).
  int houseFrom(Sign reference, Planet p) => reference.countTo(planets[p]!.sign);

  /// The sign on the cusp of a house (whole-sign houses: the house sign).
  Sign? houseSign(int house) {
    final asc = ascendantSign;
    if (asc == null) return null;
    if (settings.houseSystem == HouseSystem.wholeSign) return asc + (house - 1);
    return Sign.fromLongitude(cusps![house - 1]);
  }

  /// Lord of a house (1..12).
  Planet? houseLord(int house) => houseSign(house)?.lord;
}

class ChartCalculator {
  ChartCalculator._();

  /// Casts a chart for [utc] at the given place. Without a place (or when the
  /// birth time is unknown) houses and the ascendant are omitted.
  static Chart cast({
    required DateTime utc,
    required CalcSettings settings,
    double? latitude,
    double? longitude,
    bool withHouses = true,
  }) {
    final jd = Ephemeris.julianDay(utc);
    final ayan = settings.sidereal ? settings.ayanamsa : null;
    final bodies = settings.sidereal ? Planet.vedic : Planet.western;

    HouseData? houses;
    final canHouses = withHouses && latitude != null && longitude != null;
    if (canHouses) {
      houses = Ephemeris.houses(jd, latitude, longitude, settings.houseSystem, ayanamsa: ayan);
    }

    final placements = <Planet, PlanetPlacement>{};
    for (final p in bodies) {
      final pos = Ephemeris.position(jd, p, ayanamsa: ayan, node: settings.nodeType);
      placements[p] = PlanetPlacement(
        planet: p,
        longitude: pos.longitude,
        latitude: pos.latitude,
        speed: pos.speed,
        house: houses == null ? null : _houseOf(pos.longitude, houses, settings.houseSystem),
      );
    }

    return Chart(
      jd: jd,
      settings: settings,
      planets: placements,
      ayanamsaValue: ayan == null ? 0 : Ephemeris.ayanamsa(jd, ayan),
      ascendant: houses?.ascendant,
      midheaven: houses?.midheaven,
      cusps: houses?.cusps,
      latitude: latitude,
      longitude: longitude,
    );
  }

  static int _houseOf(double lon, HouseData h, HouseSystem system) {
    if (system == HouseSystem.wholeSign) {
      return Sign.fromLongitude(h.ascendant).countTo(Sign.fromLongitude(lon));
    }
    // Swiss Ephemeris returns Sripati cusps already shifted to the bhava
    // boundaries (midpoints of Porphyry cusps), so all quadrant systems work
    // the same way here.
    for (var i = 0; i < 12; i++) {
      if (_within(lon, h.cusps[i], h.cusps[(i + 1) % 12])) return i + 1;
    }
    return 1;
  }

  static bool _within(double lon, double start, double end) {
    final span = norm360(end - start);
    return norm360(lon - start) < span;
  }
}
