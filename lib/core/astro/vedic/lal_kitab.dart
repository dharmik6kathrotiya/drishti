import '../chart.dart';
import '../constants.dart';

/// Lal Kitab chart helpers.
///
/// In Lal Kitab the signs are fixed to the houses (Aries = house 1 ...
/// Pisces = house 12) and each planet is placed in the house matching its
/// sidereal sign; the Ascendant sign itself is not used for house numbers.
///
/// Not included: the Varshphal (annual chart) age table. We have not been
/// able to verify the 120-year table against a primary source, so it is left
/// out rather than risk publishing wrong placements.
class LalKitab {
  LalKitab._();

  static const planets = [
    Planet.sun,
    Planet.moon,
    Planet.mars,
    Planet.mercury,
    Planet.jupiter,
    Planet.venus,
    Planet.saturn,
    Planet.rahu,
    Planet.ketu,
  ];

  /// Pakka ghar (permanent house) of each planet. Mars and Saturn are given
  /// with their most cited house; some texts also list Mars 8 and Saturn 8.
  static const pakkaGhar = {
    Planet.sun: 1,
    Planet.moon: 4,
    Planet.mars: 3,
    Planet.mercury: 7,
    Planet.jupiter: 2,
    Planet.venus: 7,
    Planet.saturn: 10,
    Planet.rahu: 12,
    Planet.ketu: 6,
  };

  /// House (1..12) of a planet in the Lal Kitab chart.
  static int houseOf(Chart chart, Planet p) => chart[p].sign.index + 1;

  static Map<int, List<Planet>> byHouse(Chart chart) => {
    for (var h = 1; h <= 12; h++)
      h: [
        for (final p in planets)
          if (houseOf(chart, p) == h) p,
      ],
  };

  /// Planets sitting in their own pakka ghar.
  static List<Planet> inPakkaGhar(Chart chart) => [
    for (final p in planets)
      if (houseOf(chart, p) == pakkaGhar[p]) p,
  ];

  /// Simplified "sleeping house" rule: an empty house that is also not
  /// aspected from the opposite (7th) house. Lal Kitab uses further aspect
  /// rules (e.g. 1→7, 4→10, 3→9/11, 5→9, 2→6, 6→12, 8→2) that differ between
  /// commentators; only the 7th-house rule is applied here.
  static List<int> sleepingHouses(Chart chart) {
    final occ = byHouse(chart);
    return [
      for (var h = 1; h <= 12; h++)
        if (occ[h]!.isEmpty && occ[((h + 5) % 12) + 1]!.isEmpty) h,
    ];
  }

  /// Simplified "sleeping planet" rule: a planet with no planet in the house
  /// it aspects (the 7th from it).
  static List<Planet> sleepingPlanets(Chart chart) {
    final occ = byHouse(chart);
    return [
      for (final p in planets)
        if (occ[((houseOf(chart, p) + 5) % 12) + 1]!.isEmpty) p,
    ];
  }
}
