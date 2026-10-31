import 'dart:math' as math;

import 'package:sweph/sweph.dart';

import '../chart.dart';
import '../constants.dart';
import '../ephemeris.dart';
import 'divisional.dart';

/// Shadbala, the six-fold planetary strength of BPHS ch. 27.
///
/// All values are in virupas (shashtiamsas); 60 virupas = 1 rupa.
///
/// Formula choices (software differs on several of these, so they are
/// documented here and in the UI):
/// * Saptavargaja: moolatrikona (45) is applied in the D1 only; own sign 30,
///   then compound (panchadha) relationship with the varga sign's lord:
///   great friend 22.5, friend 15, neutral 7.5, enemy 3.75, great enemy 1.875.
/// * Kendradi: houses are counted by whole signs from the Lagna.
/// * Dig bala: angular distance from the powerless point / 3, using the
///   Ascendant and MC degrees (not bhava madhyas of another house system).
/// * Nathonnatha: from the Sun's hour angle at birth.
/// * Paksha: Moon-Sun elongation / 3 for benefics (Jupiter, Venus, Mercury,
///   Moon), 60 minus that for malefics; the Moon's value is doubled.
/// * Abda/Masa lords: weekday on which the current 360-day year / 30-day month
///   began, counted from the Kali Yuga epoch (JD 588465.5, Surya Siddhanta).
/// * Ayana: (24 ± declination) / 48 × 60 using the true declination; Sun's
///   value doubled.
/// * Chesta: the Sun takes its Ayana bala and the Moon its Paksha bala (BPHS);
///   for the others the classical eight motions are mapped from the observed
///   daily speed relative to the mean speed. The chesta-kendra method of
///   Surya Siddhanta gives different numbers.
/// * Yuddha: Mars–Saturn within 1° are in war; the one with the greater
///   northern latitude wins and the difference of their totals is moved.
/// * Drik: BPHS aspect-value formula with the special aspects of Mars,
///   Jupiter and Saturn; benefic minus malefic aspects, divided by 4.
class Shadbala {
  Shadbala._();

  static const planets = [
    Planet.sun,
    Planet.moon,
    Planet.mars,
    Planet.mercury,
    Planet.jupiter,
    Planet.venus,
    Planet.saturn,
  ];

  /// Naisargika (natural) strength in virupas.
  static const naisargika = {
    Planet.sun: 60.0,
    Planet.moon: 51.43,
    Planet.venus: 42.86,
    Planet.jupiter: 34.29,
    Planet.mercury: 25.71,
    Planet.mars: 17.14,
    Planet.saturn: 8.57,
  };

  /// Minimum total required for a planet to be considered strong, in rupas.
  static const requiredRupas = {
    Planet.sun: 6.5,
    Planet.moon: 6.0,
    Planet.mars: 5.0,
    Planet.mercury: 7.0,
    Planet.jupiter: 6.5,
    Planet.venus: 5.5,
    Planet.saturn: 5.0,
  };

  /// Mean geocentric daily motion (degrees/day) used for Chesta bala.
  static const _meanSpeed = {
    Planet.mars: 0.524,
    Planet.mercury: 0.9856,
    Planet.venus: 0.9856,
    Planet.jupiter: 0.0831,
    Planet.saturn: 0.0335,
  };

  static const _benefics = {Planet.jupiter, Planet.venus, Planet.mercury};

  /// Computes Shadbala for a Vedic chart with houses (birth time and place).
  static ShadbalaResult compute(Chart chart) {
    if (!chart.hasHouses || chart.latitude == null || chart.longitude == null) {
      throw ArgumentError('Shadbala needs a chart with birth time and place.');
    }
    final jd = chart.jd;
    final lat = chart.latitude!, lon = chart.longitude!;

    // Sun's hour angle (0 = local apparent noon).
    final eq = SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_EQUATORIAL;
    final sunEq = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_SUN, eq);
    final armc = Ephemeris.houses(jd, lat, lon, chart.settings.houseSystem).armc;
    final hourAngle = norm360(armc - sunEq.longitude);
    final fromNoon = hourAngle > 180 ? 360 - hourAngle : hourAngle; // 0..180

    // Day/night and sunrise for Tribhaga, Vara and Hora.
    final riseBefore = _lastSunrise(jd, lat, lon);
    final setAfterRise = Ephemeris.riseSet(riseBefore, Planet.sun, lat, lon, rise: false) ?? riseBefore + 0.5;
    final nextRise = Ephemeris.riseSet(setAfterRise, Planet.sun, lat, lon, rise: true) ?? riseBefore + 1;
    final isDay = jd < setAfterRise;
    final varaLord = _weekdayLord(Sweph.swe_day_of_week(riseBefore + _lmtOffset(lon)));

    final elong = angularDistance(chart.moon.longitude, chart.sun.longitude); // 0..180
    final moonWaxing = norm360(chart.moon.longitude - chart.sun.longitude) < 180;

    final declination = {for (final p in planets) p: Sweph.swe_calc_ut(jd, _body(p), eq).latitude};

    final rows = <Planet, ShadbalaRow>{};
    for (final p in planets) {
      final pl = chart[p];

      // --- Sthana bala ---
      final uchcha = angularDistance(pl.longitude, norm360(Dignity.exaltation[p]! + 180)) / 3;
      final saptavargaja = _saptavargaja(chart, p);
      final oddSign = pl.sign.isOdd;
      final oddNavamsa = Varga.d9.signOf(pl.longitude).isOdd;
      final femaleRule = p == Planet.moon || p == Planet.venus;
      final ojayugma =
          ((femaleRule ? !oddSign : oddSign) ? 15.0 : 0.0) + ((femaleRule ? !oddNavamsa : oddNavamsa) ? 15.0 : 0.0);
      final house = chart.ascendantSign!.countTo(pl.sign);
      final kendradi = const {1, 4, 7, 10}.contains(house)
          ? 60.0
          : const {2, 5, 8, 11}.contains(house)
          ? 30.0
          : 15.0;
      final decanate = (pl.degreeInSign ~/ 10);
      final drekkana = switch (p) {
        Planet.sun || Planet.mars || Planet.jupiter => decanate == 0 ? 15.0 : 0.0,
        Planet.mercury || Planet.saturn => decanate == 1 ? 15.0 : 0.0,
        _ => decanate == 2 ? 15.0 : 0.0,
      };
      final sthana = uchcha + saptavargaja + ojayugma + kendradi + drekkana;

      // --- Dig bala ---
      final asc = chart.ascendant!, mc = chart.midheaven!;
      final weakPoint = switch (p) {
        Planet.jupiter || Planet.mercury => norm360(asc + 180), // strong in 1st
        Planet.sun || Planet.mars => norm360(mc + 180), // strong in 10th
        Planet.saturn => asc, // strong in 7th
        _ => mc, // Moon, Venus strong in 4th
      };
      final dig = angularDistance(pl.longitude, weakPoint) / 3;

      // --- Kala bala ---
      final natha = fromNoon / 3; // 60 at midnight
      final nathonnatha = switch (p) {
        Planet.mercury => 60.0,
        Planet.moon || Planet.mars || Planet.saturn => natha,
        _ => 60 - natha,
      };
      final beneficForPaksha = _benefics.contains(p) || p == Planet.moon;
      var paksha = beneficForPaksha ? elong / 3 : 60 - elong / 3;
      if (p == Planet.moon) paksha *= 2;

      final tribhagaLord = _tribhagaLord(jd, riseBefore, setAfterRise, nextRise, isDay);
      final tribhaga = (p == Planet.jupiter || p == tribhagaLord) ? 60.0 : 0.0;

      final abdaLord = _kaliCycleLord(jd, 360);
      final masaLord = _kaliCycleLord(jd, 30);
      final horaLord = _horaLord(jd, riseBefore, setAfterRise, nextRise, varaLord);
      final abda = p == abdaLord ? 15.0 : 0.0;
      final masa = p == masaLord ? 30.0 : 0.0;
      final vara = p == varaLord ? 45.0 : 0.0;
      final hora = p == horaLord ? 60.0 : 0.0;

      final dec = declination[p]!;
      var ayana = switch (p) {
        Planet.moon || Planet.saturn => (24 - dec) / 48 * 60,
        Planet.mercury => (24 + dec.abs()) / 48 * 60,
        _ => (24 + dec) / 48 * 60,
      };
      ayana = ayana.clamp(0, 60).toDouble();
      if (p == Planet.sun) ayana *= 2;

      final kala = nathonnatha + paksha + tribhaga + abda + masa + vara + hora + ayana;

      // --- Chesta bala ---
      final chesta = switch (p) {
        Planet.sun => ayana,
        Planet.moon => paksha,
        _ => _chestaFromSpeed(pl.speed, _meanSpeed[p]!),
      };

      rows[p] = ShadbalaRow(
        planet: p,
        uchcha: uchcha,
        saptavargaja: saptavargaja,
        ojayugma: ojayugma,
        kendradi: kendradi,
        drekkana: drekkana,
        dig: dig,
        nathonnatha: nathonnatha,
        paksha: paksha,
        tribhaga: tribhaga,
        abda: abda,
        masa: masa,
        vara: vara,
        hora: hora,
        ayana: ayana,
        yuddha: 0,
        chesta: chesta,
        naisargika: naisargika[p]!,
        drik: _drik(chart, p, moonWaxing),
        sthana: sthana,
        kala: kala,
      );
    }

    _applyYuddha(chart, rows);
    return ShadbalaResult(rows);
  }

  static HeavenlyBody _body(Planet p) => switch (p) {
    Planet.sun => HeavenlyBody.SE_SUN,
    Planet.moon => HeavenlyBody.SE_MOON,
    Planet.mars => HeavenlyBody.SE_MARS,
    Planet.mercury => HeavenlyBody.SE_MERCURY,
    Planet.jupiter => HeavenlyBody.SE_JUPITER,
    Planet.venus => HeavenlyBody.SE_VENUS,
    _ => HeavenlyBody.SE_SATURN,
  };

  static double _lmtOffset(double lon) => lon / 360;

  static double _lastSunrise(double jd, double lat, double lon) {
    var rise = Ephemeris.riseSet(jd - 1, Planet.sun, lat, lon, rise: true) ?? jd - 0.5;
    final next = Ephemeris.riseSet(rise + 0.01, Planet.sun, lat, lon, rise: true);
    if (next != null && next <= jd) rise = next;
    return rise;
  }

  /// swe_day_of_week: 0 = Monday .. 6 = Sunday.
  static Planet _weekdayLord(int sweDow) =>
      const [Planet.moon, Planet.mars, Planet.mercury, Planet.jupiter, Planet.venus, Planet.saturn, Planet.sun][sweDow];

  static const _chaldean = [
    Planet.sun,
    Planet.venus,
    Planet.mercury,
    Planet.moon,
    Planet.saturn,
    Planet.jupiter,
    Planet.mars,
  ];

  static Planet _horaLord(double jd, double rise, double set, double nextRise, Planet dayLord) {
    final idx = jd < set
        ? ((jd - rise) / ((set - rise) / 12)).floor()
        : 12 + ((jd - set) / ((nextRise - set) / 12)).floor();
    return _chaldean[(_chaldean.indexOf(dayLord) + idx.clamp(0, 23)) % 7];
  }

  /// Tribhaga lords: day thirds Mercury, Sun, Saturn; night thirds Moon,
  /// Venus, Mars.
  static Planet _tribhagaLord(double jd, double rise, double set, double nextRise, bool isDay) {
    if (isDay) {
      final third = ((jd - rise) / ((set - rise) / 3)).floor().clamp(0, 2);
      return const [Planet.mercury, Planet.sun, Planet.saturn][third];
    }
    final third = ((jd - set) / ((nextRise - set) / 3)).floor().clamp(0, 2);
    return const [Planet.moon, Planet.venus, Planet.mars][third];
  }

  static const kaliEpochJd = 588465.5;

  /// Weekday lord of the day on which the current [cycle]-day period began,
  /// counting from the Kali Yuga epoch.
  static Planet _kaliCycleLord(double jd, int cycle) {
    final days = (jd - kaliEpochJd).floor();
    final start = kaliEpochJd + (days ~/ cycle) * cycle;
    return _weekdayLord(Sweph.swe_day_of_week(start + 0.5));
  }

  /// Classical eight motions mapped from speed (BPHS ch. 27).
  static double _chestaFromSpeed(double speed, double mean) {
    if (speed < 0) return 60; // Vakra
    final r = speed / mean;
    if (r < 0.05) return 15; // Vikala (stationary)
    if (r < 0.5) return 15; // Mandatara
    if (r < 0.9) return 30; // Manda
    if (r < 1.1) return 7.5; // Sama
    if (r < 1.5) return 45; // Chara
    return 30; // Atichara
  }

  static double _saptavargaja(Chart chart, Planet p) {
    const vargas = [Varga.d1, Varga.d2, Varga.d3, Varga.d7, Varga.d9, Varga.d12, Varga.d30];
    var total = 0.0;
    final lon = chart[p].longitude;
    for (final v in vargas) {
      final sign = v.signOf(lon);
      if (v == Varga.d1 && Dignity.moolatrikona[p] == sign) {
        total += 45;
        continue;
      }
      final lord = sign.lord;
      if (lord == p) {
        total += 30;
        continue;
      }
      total += switch (compoundRelation(chart, p, lord)) {
        2 => 22.5,
        1 => 15,
        0 => 7.5,
        -1 => 3.75,
        _ => 1.875,
      };
    }
    return total;
  }

  /// Panchadha (compound) relationship of [a] towards [b]:
  /// 2 great friend, 1 friend, 0 neutral, -1 enemy, -2 great enemy.
  static int compoundRelation(Chart chart, Planet a, Planet b) {
    final natural = Dignity.naturalRelation(a, b);
    final h = chart[a].sign.countTo(chart[b].sign);
    final temporary = const {2, 3, 4, 10, 11, 12}.contains(h) ? 1 : -1;
    return natural + temporary;
  }

  /// BPHS aspect value (virupas) of a planet at [from] on a point at [to].
  static double aspectValue(Planet p, double from, double to) {
    final a = norm360(to - from);
    if (p == Planet.mars && ((a >= 90 && a < 120) || (a >= 210 && a < 240))) return 60;
    if (p == Planet.jupiter && ((a >= 120 && a < 150) || (a >= 240 && a < 270))) return 60;
    if (p == Planet.saturn && ((a >= 60 && a < 90) || (a >= 270 && a < 300))) return 60;
    if (a < 30) return 0;
    if (a < 60) return (a - 30) / 2;
    if (a < 90) return (a - 60) + 15;
    if (a < 120) return (120 - a) / 2 + 30;
    if (a < 150) return 150 - a;
    if (a < 180) return (a - 150) * 2;
    if (a < 300) return (300 - a) / 2;
    return 0;
  }

  static double _drik(Chart chart, Planet target, bool moonWaxing) {
    var benefic = 0.0, malefic = 0.0;
    for (final p in planets) {
      if (p == target) continue;
      final v = aspectValue(p, chart[p].longitude, chart[target].longitude);
      final isBenefic = _benefics.contains(p) || (p == Planet.moon && moonWaxing);
      if (isBenefic) {
        benefic += v;
      } else {
        malefic += v;
      }
    }
    return (benefic - malefic) / 4;
  }

  static void _applyYuddha(Chart chart, Map<Planet, ShadbalaRow> rows) {
    const fighters = [Planet.mars, Planet.mercury, Planet.jupiter, Planet.venus, Planet.saturn];
    for (var i = 0; i < fighters.length; i++) {
      for (var j = i + 1; j < fighters.length; j++) {
        final a = fighters[i], b = fighters[j];
        if (angularDistance(chart[a].longitude, chart[b].longitude) >= 1) continue;
        final winner = chart[a].latitude >= chart[b].latitude ? a : b;
        final loser = winner == a ? b : a;
        final diff = (rows[winner]!.total - rows[loser]!.total).abs();
        rows[winner] = rows[winner]!.withYuddha(rows[winner]!.yuddha + diff);
        rows[loser] = rows[loser]!.withYuddha(rows[loser]!.yuddha - diff);
      }
    }
  }
}

class ShadbalaRow {
  const ShadbalaRow({
    required this.planet,
    required this.uchcha,
    required this.saptavargaja,
    required this.ojayugma,
    required this.kendradi,
    required this.drekkana,
    required this.dig,
    required this.nathonnatha,
    required this.paksha,
    required this.tribhaga,
    required this.abda,
    required this.masa,
    required this.vara,
    required this.hora,
    required this.ayana,
    required this.yuddha,
    required this.chesta,
    required this.naisargika,
    required this.drik,
    required this.sthana,
    required this.kala,
  });

  final Planet planet;
  final double uchcha, saptavargaja, ojayugma, kendradi, drekkana;
  final double dig;
  final double nathonnatha, paksha, tribhaga, abda, masa, vara, hora, ayana, yuddha;
  final double chesta;
  final double naisargika;
  final double drik;

  /// Sthana bala (sum of its five parts).
  final double sthana;

  /// Kala bala before Yuddha.
  final double kala;

  double get kalaTotal => kala + yuddha;
  double get total => sthana + dig + kalaTotal + chesta + naisargika + drik;
  double get rupas => total / 60;
  double get required => Shadbala.requiredRupas[planet]!;

  /// Strength relative to the classical minimum (1.0 = exactly the minimum).
  double get ratio => rupas / required;

  ShadbalaRow withYuddha(double y) => ShadbalaRow(
    planet: planet,
    uchcha: uchcha,
    saptavargaja: saptavargaja,
    ojayugma: ojayugma,
    kendradi: kendradi,
    drekkana: drekkana,
    dig: dig,
    nathonnatha: nathonnatha,
    paksha: paksha,
    tribhaga: tribhaga,
    abda: abda,
    masa: masa,
    vara: vara,
    hora: hora,
    ayana: ayana,
    yuddha: y,
    chesta: chesta,
    naisargika: naisargika,
    drik: drik,
    sthana: sthana,
    kala: kala,
  );
}

class ShadbalaResult {
  const ShadbalaResult(this.rows);
  final Map<Planet, ShadbalaRow> rows;

  /// Planets sorted from strongest to weakest relative to their minimum.
  List<ShadbalaRow> get ranked => rows.values.toList()..sort((a, b) => b.ratio.compareTo(a.ratio));

  double get maxRupas => rows.values.map((r) => r.rupas).fold(0.0, math.max);
}
