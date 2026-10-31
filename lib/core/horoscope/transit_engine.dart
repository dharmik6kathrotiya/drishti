import '../astro/constants.dart';
import '../astro/ephemeris.dart';
import '../astro/settings.dart';

/// The natal reference a horoscope is read from. Any field may be missing:
/// a sign-only subject has just [moonSign]/[sunSign].
class NatalReference {
  const NatalReference({
    required this.system,
    required this.moonSign,
    required this.sunSign,
    this.birthNakshatra,
    this.ascendantSign,
    this.natalLongitudes,
    this.moonApproximate = false,
    this.nakshatraApproximate = false,
    this.sunApproximate = false,
    this.signOnly = false,
  });

  final AstroSystem system;

  /// Vedic: sidereal natal Moon sign. Western: tropical (or the chosen sign).
  final Sign moonSign;
  final Sign sunSign;
  final Nakshatra? birthNakshatra;
  final Sign? ascendantSign;

  /// Natal longitudes in the system's zodiac (Western aspects).
  final Map<Planet, double>? natalLongitudes;
  final bool moonApproximate;
  final bool nakshatraApproximate;
  final bool sunApproximate;

  /// Generic horoscope for a sign chosen by the user.
  final bool signOnly;

  bool get anyApproximate => moonApproximate || nakshatraApproximate || sunApproximate;
}

/// One planet's Gochara (transit) counted from the natal Moon sign,
/// following Phaladeepika ch. 26.
class GocharaTransit {
  const GocharaTransit({
    required this.planet,
    required this.sign,
    required this.longitude,
    required this.houseFromMoon,
    required this.favourable,
    required this.retrograde,
    this.houseFromAscendant,
    this.obstructedBy,
    this.vedhaHouse,
  });

  final Planet planet;
  final Sign sign;
  final double longitude;
  final int houseFromMoon;
  final int? houseFromAscendant;
  final bool favourable;
  final bool retrograde;

  /// Planet occupying the vedha (obstruction) point, if any.
  final Planet? obstructedBy;
  final int? vedhaHouse;

  bool get obstructed => obstructedBy != null;

  /// +1 favourable, 0 favourable but obstructed, -1 unfavourable.
  double get polarity => favourable ? (obstructed ? 0 : 1) : -1;
}

class TaraBala {
  const TaraBala({required this.count, required this.transitNakshatra, required this.birthNakshatra});

  /// 1..27 counted from the birth star.
  final int count;
  final Nakshatra transitNakshatra;
  final Nakshatra birthNakshatra;

  /// 0..8: Janma, Sampat, Vipat, Kshema, Pratyari, Sadhaka, Naidhana, Mitra, Parama Mitra.
  int get tara => (count - 1) % 9;

  /// +1 good, -1 adverse, -0.3 Janma (mixed).
  double get polarity => switch (tara) {
    0 => -0.3,
    2 || 4 || 6 => -1,
    _ => 1,
  };
}

enum AspectType {
  conjunction(0),
  sextile(60),
  square(90),
  trine(120),
  opposition(180);

  const AspectType(this.angle);
  final double angle;

  static AspectType? fromSignDistance(int n) => switch (n) {
    1 => conjunction,
    3 || 11 => sextile,
    4 || 10 => square,
    5 || 9 => trine,
    7 => opposition,
    _ => null,
  };
}

class WesternAspect {
  const WesternAspect({
    required this.transiting,
    required this.type,
    required this.polarity,
    this.natal,
    this.orb,
    this.signDistance,
  });

  final Planet transiting;

  /// Natal planet aspected, or null for a whole-sign aspect to the Sun sign.
  final Planet? natal;
  final AspectType? type;
  final double? orb;

  /// 1..12, sign distance from the Sun sign (sign-only readings).
  final int? signDistance;
  final double polarity;
}

class TransitSnapshot {
  const TransitSnapshot({
    required this.time,
    required this.gochara,
    required this.aspects,
    required this.transitSigns,
    required this.transitLongitudes,
    required this.retrograde,
    this.tara,
  });

  final DateTime time;
  final List<GocharaTransit> gochara;
  final TaraBala? tara;
  final List<WesternAspect> aspects;
  final Map<Planet, Sign> transitSigns;
  final Map<Planet, double> transitLongitudes;
  final Map<Planet, bool> retrograde;

  Sign get moonSign => transitSigns[Planet.moon]!;
}

class TransitEngine {
  TransitEngine._();

  /// Favourable houses from the Moon sign (Phaladeepika ch. 26).
  static const favourableHouses = <Planet, Set<int>>{
    Planet.sun: {3, 6, 10, 11},
    Planet.moon: {1, 3, 6, 7, 10, 11},
    Planet.mars: {3, 6, 11},
    Planet.mercury: {2, 4, 6, 8, 10, 11},
    Planet.jupiter: {2, 5, 7, 9, 11},
    Planet.venus: {1, 2, 3, 4, 5, 8, 9, 11, 12},
    Planet.saturn: {3, 6, 11},
    Planet.rahu: {3, 6, 11},
    Planet.ketu: {3, 6, 11},
  };

  /// Vedha points: favourable house -> obstructing house (from the Moon).
  static const vedha = <Planet, Map<int, int>>{
    Planet.sun: {3: 9, 6: 12, 10: 4, 11: 5},
    Planet.moon: {1: 5, 3: 9, 6: 12, 7: 2, 10: 4, 11: 8},
    Planet.mars: {3: 12, 6: 9, 11: 5},
    Planet.mercury: {2: 5, 4: 3, 6: 9, 8: 1, 10: 8, 11: 12},
    Planet.jupiter: {2: 12, 5: 4, 7: 3, 9: 10, 11: 8},
    Planet.venus: {1: 8, 2: 7, 3: 1, 4: 10, 5: 9, 8: 5, 9: 11, 11: 6, 12: 3},
    Planet.saturn: {3: 12, 6: 9, 11: 5},
  };

  static const _sevenPlanets = [
    Planet.sun,
    Planet.moon,
    Planet.mars,
    Planet.mercury,
    Planet.jupiter,
    Planet.venus,
    Planet.saturn,
  ];

  /// Sun-Saturn and Moon-Mercury do not obstruct each other (father-son pairs).
  static bool _vedhaExempt(Planet a, Planet b) =>
      (a == Planet.sun && b == Planet.saturn) ||
      (a == Planet.saturn && b == Planet.sun) ||
      (a == Planet.moon && b == Planet.mercury) ||
      (a == Planet.mercury && b == Planet.moon);

  static TransitSnapshot snapshot(NatalReference natal, DateTime utc, CalcSettings settings) {
    final jd = Ephemeris.julianDay(utc);
    final vedic = natal.system == AstroSystem.vedic;
    final ayan = vedic ? settings.ayanamsa : null;
    final bodies = vedic ? Planet.vedic : Planet.western;

    final lons = <Planet, double>{};
    final retro = <Planet, bool>{};
    for (final p in bodies) {
      final pos = Ephemeris.position(jd, p, ayanamsa: ayan, node: settings.nodeType);
      lons[p] = pos.longitude;
      retro[p] = p.isNode ? true : pos.isRetrograde;
    }
    final signs = {for (final e in lons.entries) e.key: Sign.fromLongitude(e.value)};

    final gochara = <GocharaTransit>[];
    TaraBala? tara;
    final aspects = <WesternAspect>[];

    if (vedic) {
      final houseOf = {for (final p in Planet.vedic) p: natal.moonSign.countTo(signs[p]!)};
      for (final p in Planet.vedic) {
        final h = houseOf[p]!;
        final fav = favourableHouses[p]!.contains(h);
        Planet? obstructor;
        int? vh;
        if (fav && vedha.containsKey(p)) {
          vh = vedha[p]![h];
          if (vh != null) {
            for (final o in _sevenPlanets) {
              if (o == p || _vedhaExempt(p, o)) continue;
              if (houseOf[o] == vh) {
                obstructor = o;
                break;
              }
            }
          }
        }
        gochara.add(
          GocharaTransit(
            planet: p,
            sign: signs[p]!,
            longitude: lons[p]!,
            houseFromMoon: h,
            houseFromAscendant: natal.ascendantSign?.countTo(signs[p]!),
            favourable: fav,
            retrograde: retro[p]!,
            obstructedBy: obstructor,
            vedhaHouse: obstructor == null ? null : vh,
          ),
        );
      }
      final birthNak = natal.birthNakshatra;
      if (birthNak != null) {
        final now = Nakshatra.fromLongitude(lons[Planet.moon]!);
        tara = TaraBala(
          count: ((now.index - birthNak.index) % 27) + 1,
          transitNakshatra: now,
          birthNakshatra: birthNak,
        );
      }
    } else {
      final natalLons = natal.natalLongitudes;
      final transiting = bodies.where((p) => !p.isNode);
      if (natalLons != null && !natal.signOnly) {
        for (final t in transiting) {
          for (final n in natalLons.keys) {
            final d = angularDistance(lons[t]!, natalLons[n]!);
            for (final a in AspectType.values) {
              final orb = (d - a.angle).abs();
              if (orb <= _orb(t)) {
                aspects.add(WesternAspect(transiting: t, natal: n, type: a, orb: orb, polarity: _aspectPolarity(a, t)));
              }
            }
          }
        }
      } else {
        for (final t in transiting) {
          final dist = natal.sunSign.countTo(signs[t]!);
          final type = AspectType.fromSignDistance(dist);
          aspects.add(
            WesternAspect(
              transiting: t,
              type: type,
              signDistance: dist,
              polarity: type == null ? -0.2 : _aspectPolarity(type, t),
            ),
          );
        }
      }
    }

    return TransitSnapshot(
      time: utc,
      gochara: gochara,
      tara: tara,
      aspects: aspects,
      transitSigns: signs,
      transitLongitudes: lons,
      retrograde: retro,
    );
  }

  /// Transit orbs: tighter for slow planets, which act over long periods.
  static double _orb(Planet p) => switch (p) {
    Planet.moon => 5,
    Planet.sun || Planet.mercury || Planet.venus || Planet.mars => 3,
    _ => 2,
  };

  static double _aspectPolarity(AspectType a, Planet t) => switch (a) {
    AspectType.trine => 1,
    AspectType.sextile => 0.7,
    AspectType.square => -0.8,
    AspectType.opposition => -0.6,
    AspectType.conjunction => switch (t) {
      Planet.jupiter || Planet.venus => 1,
      Planet.sun || Planet.moon || Planet.mercury => 0.4,
      Planet.mars || Planet.saturn || Planet.pluto => -0.6,
      _ => 0,
    },
  };
}
