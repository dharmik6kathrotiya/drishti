import '../chart.dart';
import '../constants.dart';
import '../ephemeris.dart';
import 'dasha.dart';

/// Classical life-span classes of Jaimini's three-pair method.
enum LifeSpan {
  short(0, 32), // Alpayu
  middle(32, 64), // Madhyayu
  long(64, 96); // Purnayu

  const LifeSpan(this.fromAge, this.toAge);
  final int fromAge;
  final int toAge;

  String get sanskrit => const ['Alpayu', 'Madhyayu', 'Purnayu'][index];
}

/// One pair of the method: two signs whose modalities give a span.
class LongevityPair {
  const LongevityPair(this.key, this.a, this.b);

  /// `lords` (Lagna lord and 8th lord), `moonSaturn` or `horaLagna`
  /// (Lagna and Hora Lagna).
  final String key;
  final Sign a;
  final Sign b;

  LifeSpan get span => Longevity.pairSpan(a.modality, b.modality);
}

class LongevityReport {
  const LongevityReport({
    required this.pairs,
    required this.span,
    required this.rule,
    required this.marakas,
    required this.sensitive,
    required this.ageNow,
  });

  final List<LongevityPair> pairs;

  /// Null when the pairs cannot decide (e.g. without a birth time).
  final LifeSpan? span;

  /// How the span was chosen: `majority`, `horaLagna` or `moonSaturn`
  /// (tie-breaks when all three pairs differ), or `undecided`.
  final String rule;

  /// Maraka planets (lords of and planets in the 2nd and 7th).
  final List<Planet> marakas;

  /// Upcoming maraka Antardashas inside the span window.
  final List<DashaPeriod> sensitive;
  final int ageNow;

  int get agreeing => span == null ? 0 : pairs.where((p) => p.span == span).length;

  /// The person is already older than the span this method gives.
  bool get pastSpan => span != null && ageNow >= span!.toAge;
}

/// Longevity as classical Vedic texts compute it. This reports what the
/// method says; it is a traditional calculation, not a medical estimate.
///
/// * Span: Jaimini Upadesa Sutras 2.1, three pairs of signs (Lagna lord and
///   8th lord, Moon and Saturn, Lagna and Hora Lagna). Two agreeing pairs
///   decide; if all three differ the Lagna/Hora Lagna pair decides, or the
///   Moon/Saturn pair when the Moon is in the 1st or 7th.
/// * Maraka: BPHS ch. 44, lords of and planets in the 2nd and 7th houses
///   (the Lagna lord excluded); their periods inside the span are the ones
///   tradition marks as sensitive.
///
/// The classical span adjustments (kakshya vriddhi/hrasa) are not applied.
class Longevity {
  Longevity._();

  /// Movable+movable or fixed+dual: long; movable+fixed or dual+dual:
  /// middle; movable+dual or fixed+fixed: short.
  static LifeSpan pairSpan(Modality a, Modality b) {
    if (a == b) {
      return switch (a) {
        Modality.movable => LifeSpan.long,
        Modality.fixed => LifeSpan.short,
        _ => LifeSpan.middle,
      };
    }
    final s = {a, b};
    if (s.containsAll({Modality.movable, Modality.fixed})) return LifeSpan.middle;
    if (s.containsAll({Modality.fixed, Modality.dual})) return LifeSpan.long;
    return LifeSpan.short;
  }

  /// Hora Lagna: the Sun's sidereal longitude at the sunrise before birth,
  /// advancing one sign per hour (BPHS ch. 4). Null without a place or where
  /// the Sun does not rise.
  static Sign? horaLagna(Chart chart) {
    final lat = chart.latitude, lon = chart.longitude;
    if (lat == null || lon == null) return null;
    var rise = Ephemeris.riseSet(chart.jd - 1, Planet.sun, lat, lon, rise: true);
    if (rise == null || rise > chart.jd) return null;
    while (true) {
      final next = Ephemeris.riseSet(rise! + 0.01, Planet.sun, lat, lon, rise: true);
      if (next == null || next > chart.jd) break;
      rise = next;
    }
    final sun = Ephemeris.position(rise, Planet.sun, ayanamsa: chart.settings.ayanamsa).longitude;
    return Sign.fromLongitude(sun + (chart.jd - rise) * 24 * 30);
  }

  static LongevityReport compute(Chart chart, {required DateTime birthUtc, required DateTime now, Vimshottari? dasha}) {
    final moon = chart.moon.sign, saturn = chart[Planet.saturn].sign;
    final ageNow = _age(birthUtc, now);
    final lagna = chart.ascendantSign;
    if (lagna == null) {
      // Only the Moon/Saturn pair is known; one pair cannot decide.
      return LongevityReport(
        pairs: [LongevityPair('moonSaturn', moon, saturn)],
        span: null,
        rule: 'undecided',
        marakas: const [],
        sensitive: const [],
        ageNow: ageNow,
      );
    }
    final lords = LongevityPair('lords', chart[lagna.lord].sign, chart[(lagna + 7).lord].sign);
    final moonSaturn = LongevityPair('moonSaturn', moon, saturn);
    Sign? hl;
    try {
      hl = horaLagna(chart);
    } catch (_) {
      // Without a sunrise the method falls back to the other two pairs.
    }
    final pairs = [lords, moonSaturn, if (hl != null) LongevityPair('horaLagna', lagna, hl)];

    LifeSpan? span;
    var rule = 'majority';
    for (final s in LifeSpan.values) {
      if (pairs.where((p) => p.span == s).length >= 2) span = s;
    }
    if (span == null) {
      final moonHouse = lagna.countTo(moon);
      if (moonHouse == 1 || moonHouse == 7) {
        span = moonSaturn.span;
        rule = 'moonSaturn';
      } else if (hl != null) {
        span = pairs.last.span;
        rule = 'horaLagna';
      } else {
        rule = 'undecided';
      }
    }

    final marakas = <Planet>{
      for (final h in [2, 7]) ...[
        (lagna + (h - 1)).lord,
        for (final p in chart.planets.values)
          if (Planet.vedic.contains(p.planet) && lagna.countTo(p.sign) == h) p.planet,
      ],
    }..remove(lagna.lord);

    var sensitive = <DashaPeriod>[];
    if (span != null) {
      final v = dasha ?? Vimshottari();
      final from = _addYears(birthUtc, span.fromAge), to = _addYears(birthUtc, span.toAge);
      final start = now.isAfter(from) ? now : from;
      sensitive = [
        for (final m in v.mahadashas(birthUtc, chart.moon.longitude))
          if (m.end.isAfter(start) && m.start.isBefore(to))
            for (final a in v.subPeriods(m))
              if (marakas.contains(a.lord) && a.end.isAfter(start) && a.start.isBefore(to)) a,
      ].take(3).toList();
    }

    return LongevityReport(
      pairs: pairs,
      span: span,
      rule: rule,
      marakas: [
        for (final p in Planet.vedic)
          if (marakas.contains(p)) p,
      ],
      sensitive: sensitive,
      ageNow: ageNow,
    );
  }

  static int _age(DateTime birth, DateTime now) {
    var y = now.year - birth.year;
    if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) y--;
    return y;
  }

  static DateTime _addYears(DateTime d, int years) => DateTime.utc(d.year + years, d.month, d.day);
}
