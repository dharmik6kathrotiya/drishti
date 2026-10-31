import '../chart.dart';
import '../constants.dart';

/// Ashtakavarga (BPHS ch. 66-67).
///
/// Each of the seven planets has a Bhinnashtakavarga (BAV): for every sign,
/// eight contributors (the seven planets and the Lagna) either give a benefic
/// point (bindu) or not. The contributor gives a bindu to the signs that are
/// listed houses away from its own position. Adding the seven BAVs gives the
/// Sarvashtakavarga (SAV), whose grand total is always 337.
class Ashtakavarga {
  Ashtakavarga._();

  /// Planets that own a BAV.
  static const planets = [
    Planet.sun,
    Planet.moon,
    Planet.mars,
    Planet.mercury,
    Planet.jupiter,
    Planet.venus,
    Planet.saturn,
  ];

  /// Contributor order used in [benefic] tables; `null` stands for the Lagna.
  static const contributors = <Planet?>[
    Planet.sun,
    Planet.moon,
    Planet.mars,
    Planet.mercury,
    Planet.jupiter,
    Planet.venus,
    Planet.saturn,
    null,
  ];

  /// Houses (counted from each contributor) receiving a bindu, per BPHS.
  /// Keys: the planet whose BAV it is. Lists follow [contributors] order.
  static const benefic = <Planet, List<List<int>>>{
    Planet.sun: [
      [1, 2, 4, 7, 8, 9, 10, 11],
      [3, 6, 10, 11],
      [1, 2, 4, 7, 8, 9, 10, 11],
      [3, 5, 6, 9, 10, 11, 12],
      [5, 6, 9, 11],
      [6, 7, 12],
      [1, 2, 4, 7, 8, 9, 10, 11],
      [3, 4, 6, 10, 11, 12],
    ],
    Planet.moon: [
      [3, 6, 7, 8, 10, 11],
      [1, 3, 6, 7, 10, 11],
      [2, 3, 5, 6, 9, 10, 11],
      [1, 3, 4, 5, 7, 8, 10, 11],
      [1, 4, 7, 8, 10, 11, 12],
      [3, 4, 5, 7, 9, 10, 11],
      [3, 5, 6, 11],
      [3, 6, 10, 11],
    ],
    Planet.mars: [
      [3, 5, 6, 10, 11],
      [3, 6, 11],
      [1, 2, 4, 7, 8, 10, 11],
      [3, 5, 6, 11],
      [6, 10, 11, 12],
      [6, 8, 11, 12],
      [1, 4, 7, 8, 9, 10, 11],
      [1, 3, 6, 10, 11],
    ],
    Planet.mercury: [
      [5, 6, 9, 11, 12],
      [2, 4, 6, 8, 10, 11],
      [1, 2, 4, 7, 8, 9, 10, 11],
      [1, 3, 5, 6, 9, 10, 11, 12],
      [6, 8, 11, 12],
      [1, 2, 3, 4, 5, 8, 9, 11],
      [1, 2, 4, 7, 8, 9, 10, 11],
      [1, 2, 4, 6, 8, 10, 11],
    ],
    Planet.jupiter: [
      [1, 2, 3, 4, 7, 8, 9, 10, 11],
      [2, 5, 7, 9, 11],
      [1, 2, 4, 7, 8, 10, 11],
      [1, 2, 4, 5, 6, 9, 10, 11],
      [1, 2, 3, 4, 7, 8, 10, 11],
      [2, 5, 6, 9, 10, 11],
      [3, 5, 6, 12],
      [1, 2, 4, 5, 6, 7, 9, 10, 11],
    ],
    Planet.venus: [
      [8, 11, 12],
      [1, 2, 3, 4, 5, 8, 9, 11, 12],
      [3, 5, 6, 9, 11, 12],
      [3, 5, 6, 9, 11],
      [5, 8, 9, 10, 11],
      [1, 2, 3, 4, 5, 8, 9, 10, 11],
      [3, 4, 5, 8, 9, 10, 11],
      [1, 2, 3, 4, 5, 8, 9, 11],
    ],
    Planet.saturn: [
      [1, 2, 4, 7, 8, 10, 11],
      [3, 6, 11],
      [3, 5, 6, 10, 11, 12],
      [6, 8, 9, 10, 11, 12],
      [5, 6, 11, 12],
      [6, 11, 12],
      [3, 5, 6, 11],
      [1, 3, 4, 6, 10, 11],
    ],
  };

  /// Classical total bindus of each BAV (independent of the chart).
  static const totals = {
    Planet.sun: 48,
    Planet.moon: 49,
    Planet.mars: 39,
    Planet.mercury: 54,
    Planet.jupiter: 56,
    Planet.venus: 52,
    Planet.saturn: 39,
  };

  /// Computes all BAVs and the SAV. Requires the Lagna (birth time); without
  /// it the Lagna's contributions are left out and [AshtakavargaResult.complete]
  /// is false.
  static AshtakavargaResult compute(Chart chart) {
    final contributorSigns = <Sign?>[for (final c in contributors) c == null ? chart.ascendantSign : chart[c].sign];
    final bav = <Planet, List<int>>{};
    for (final p in planets) {
      final points = List<int>.filled(12, 0);
      final table = benefic[p]!;
      for (var ci = 0; ci < contributors.length; ci++) {
        final from = contributorSigns[ci];
        if (from == null) continue;
        for (final h in table[ci]) {
          points[(from + (h - 1)).index]++;
        }
      }
      bav[p] = points;
    }
    final sav = List<int>.generate(12, (i) => planets.fold(0, (s, p) => s + bav[p]![i]));
    return AshtakavargaResult(bav: bav, sav: sav, complete: chart.hasHouses);
  }

  /// Trikona shodhana: within each group of trine signs, subtract the
  /// smallest value from all three (no change if any is zero; all become zero
  /// if all three are equal).
  static List<int> trikonaShodhana(List<int> points) {
    final out = [...points];
    for (var g = 0; g < 4; g++) {
      final idx = [g, g + 4, g + 8];
      final vals = idx.map((i) => out[i]).toList();
      if (vals.contains(0)) continue;
      final m = vals.reduce((a, b) => a < b ? a : b);
      for (final i in idx) {
        out[i] -= m;
      }
    }
    return out;
  }

  /// Ekadhipatya shodhana for the five pairs of signs ruled by one planet
  /// (Cancer and Leo are skipped), as commonly applied after trikona
  /// shodhana. [occupied] marks signs holding one of the seven planets.
  static List<int> ekadhipatyaShodhana(List<int> points, Set<Sign> occupied) {
    final out = [...points];
    const pairs = [
      (Sign.aries, Sign.scorpio),
      (Sign.taurus, Sign.libra),
      (Sign.gemini, Sign.virgo),
      (Sign.sagittarius, Sign.pisces),
      (Sign.capricorn, Sign.aquarius),
    ];
    for (final (a, b) in pairs) {
      final va = out[a.index], vb = out[b.index];
      if (va == 0 || vb == 0) continue;
      final oa = occupied.contains(a), ob = occupied.contains(b);
      if (oa && ob) continue;
      if (!oa && !ob) {
        final m = va < vb ? va : vb;
        out[a.index] = va == vb ? 0 : m;
        out[b.index] = va == vb ? 0 : m;
        continue;
      }
      // One sign occupied, the other empty.
      final (occ, emp) = oa ? (a, b) : (b, a);
      if (out[occ.index] < out[emp.index]) {
        out[emp.index] = out[occ.index];
      } else {
        out[emp.index] = 0;
      }
    }
    return out;
  }

  static Set<Sign> occupiedSigns(Chart chart) => {for (final p in planets) chart[p].sign};
}

class AshtakavargaResult {
  const AshtakavargaResult({required this.bav, required this.sav, required this.complete});

  /// Bhinnashtakavarga: bindus per sign (index 0 = Aries) for each planet.
  final Map<Planet, List<int>> bav;

  /// Sarvashtakavarga: total bindus per sign.
  final List<int> sav;

  /// False when the Lagna was unknown, so totals are below the classical ones.
  final bool complete;

  int get savTotal => sav.fold(0, (a, b) => a + b);
}
