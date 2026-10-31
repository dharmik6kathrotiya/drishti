import '../chart.dart';
import '../constants.dart';

enum AspectType {
  conjunction(0, 'Conjunction', '☌', major: true),
  semiSextile(30, 'Semi-sextile', '⚺', major: false),
  sextile(60, 'Sextile', '⚹', major: true),
  square(90, 'Square', '□', major: true),
  trine(120, 'Trine', '△', major: true),
  quincunx(150, 'Quincunx', '⚻', major: false),
  opposition(180, 'Opposition', '☍', major: true);

  const AspectType(this.angle, this.label, this.symbol, {required this.major});
  final double angle;
  final String label;
  final String symbol;
  final bool major;
}

/// Orb settings in degrees. Luminaries (Sun, Moon) get [luminaryBonus] extra.
class AspectOrbs {
  const AspectOrbs({
    this.conjunction = 8,
    this.opposition = 8,
    this.trine = 7,
    this.square = 7,
    this.sextile = 5,
    this.minor = 2,
    this.luminaryBonus = 2,
    this.includeMinor = true,
  });

  final double conjunction;
  final double opposition;
  final double trine;
  final double square;
  final double sextile;
  final double minor;
  final double luminaryBonus;
  final bool includeMinor;

  double orbFor(AspectType t, Planet a, Planet b) {
    final base = switch (t) {
      AspectType.conjunction => conjunction,
      AspectType.opposition => opposition,
      AspectType.trine => trine,
      AspectType.square => square,
      AspectType.sextile => sextile,
      AspectType.semiSextile || AspectType.quincunx => minor,
    };
    final lum = {Planet.sun, Planet.moon};
    return base + (lum.contains(a) || lum.contains(b) ? luminaryBonus : 0);
  }
}

class Aspect {
  const Aspect({required this.a, required this.b, required this.type, required this.orb, required this.applying});

  final Planet a;
  final Planet b;
  final AspectType type;

  /// Deviation from the exact angle, in degrees.
  final double orb;

  /// True when the aspect is getting closer to exact.
  final bool applying;

  @override
  String toString() =>
      '${a.abbr} ${type.symbol} ${b.abbr} (${orb.toStringAsFixed(2)}° ${applying ? 'applying' : 'separating'})';
}

/// Aspects within one set of placements ([b] null) or between two sets
/// (synastry or transits to natal). When [moveB] is false the second set is
/// treated as fixed (natal points) while judging applying/separating; by
/// default it is fixed whenever [b] is given.
List<Aspect> aspectsBetween(
  Map<Planet, PlanetPlacement> a,
  Map<Planet, PlanetPlacement>? b, {
  AspectOrbs orbs = const AspectOrbs(),
  bool? moveB,
}) {
  final out = <Aspect>[];
  final second = b ?? a;
  final secondMoves = moveB ?? (b == null);
  final listA = a.values.toList();
  final listB = second.values.toList();

  for (var i = 0; i < listA.length; i++) {
    for (var j = 0; j < listB.length; j++) {
      if (b == null && j <= i) continue;
      final pa = listA[i], pb = listB[j];
      // Rahu/Ketu are always opposite: skip that pair within one chart.
      if (b == null && pa.planet.isNode && pb.planet.isNode) continue;
      final sep = angularDistance(pa.longitude, pb.longitude);
      for (final t in AspectType.values) {
        if (!t.major && !orbs.includeMinor) continue;
        final dev = (sep - t.angle).abs();
        if (dev > orbs.orbFor(t, pa.planet, pb.planet)) continue;
        const dt = 0.01; // days
        final la = pa.longitude + pa.speed * dt;
        final lb = pb.longitude + (secondMoves ? pb.speed * dt : 0);
        final devLater = (angularDistance(la, lb) - t.angle).abs();
        out.add(Aspect(a: pa.planet, b: pb.planet, type: t, orb: dev, applying: devLater < dev));
        break;
      }
    }
  }
  out.sort((x, y) => x.orb.compareTo(y.orb));
  return out;
}
