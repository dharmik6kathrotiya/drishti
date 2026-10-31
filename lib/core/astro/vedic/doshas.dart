import '../../i18n/text_ref.dart';
import '../chart.dart';
import '../constants.dart';
import '../ephemeris.dart';
import '../settings.dart';

class DoshaReport {
  const DoshaReport({
    required this.id,
    required this.name,
    required this.present,
    required this.summary,
    required this.summaryRef,
    this.factors = const [],
    this.factorRefs = const [],
    this.mitigations = const [],
    this.mitigationRefs = const [],
    this.source = '',
  });

  /// 'manglik' or 'kaalSarp'. The UI renders the localized name, summary
  /// and source from the id and the refs (see EngineTexts).
  final String id;
  final TextRef summaryRef;
  final List<TextRef> factorRefs;
  final List<TextRef> mitigationRefs;

  final String name;
  final bool present;
  final String summary;
  final List<String> factors;

  /// Traditional cancellations or softening factors found in the chart.
  final List<String> mitigations;
  final String source;
}

class Doshas {
  Doshas._();

  static const _manglikHouses = {1, 2, 4, 7, 8, 12};

  /// Mangal (Kuja) dosha checked from Lagna, Moon and Venus.
  static DoshaReport manglik(Chart chart) {
    final mars = chart[Planet.mars];
    final factors = <String>[];
    final factorRefs = <TextRef>[];
    if (chart.hasHouses && _manglikHouses.contains(mars.house)) {
      factors.add('Mars is in house ${mars.house} from the Ascendant.');
      factorRefs.add(TextRef('dosha.manglik.fromLagna', {'house': mars.house!}));
    }
    final fromMoon = chart.moon.sign.countTo(mars.sign);
    if (_manglikHouses.contains(fromMoon)) {
      factors.add('Mars is in house $fromMoon from the Moon.');
      factorRefs.add(TextRef('dosha.manglik.fromMoon', {'house': fromMoon}));
    }
    final fromVenus = chart[Planet.venus].sign.countTo(mars.sign);
    if (_manglikHouses.contains(fromVenus)) {
      factors.add('Mars is in house $fromVenus from Venus.');
      factorRefs.add(TextRef('dosha.manglik.fromVenus', {'house': fromVenus}));
    }

    final mitigations = <String>[];
    final mitigationRefs = <TextRef>[];
    if (mars.isOwnSign) {
      mitigations.add('Mars is in its own sign (${mars.sign.rashi}).');
      mitigationRefs.add(TextRef('dosha.manglik.ownSign', {'sign': mars.sign}));
    }
    if (mars.isExalted) {
      mitigations.add('Mars is exalted (Makara).');
      mitigationRefs.add(const TextRef('dosha.manglik.exalted'));
    }
    final jup = chart[Planet.jupiter];
    if (jup.sign == mars.sign) {
      mitigations.add('Jupiter is conjunct Mars.');
      mitigationRefs.add(const TextRef('dosha.manglik.jupiter'));
    }

    final fromLagna = chart.hasHouses && _manglikHouses.contains(mars.house);
    return DoshaReport(
      id: 'manglik',
      name: 'Mangal (Manglik) Dosha',
      summaryRef: TextRef(factors.isEmpty ? 'dosha.manglik.none' : 'dosha.manglik.present'),
      factorRefs: factorRefs,
      mitigationRefs: mitigationRefs,
      present: fromLagna || (!chart.hasHouses && _manglikHouses.contains(fromMoon)),
      summary: factors.isEmpty ? 'Mars is not in houses 1, 2, 4, 7, 8 or 12 from the Ascendant, Moon or Venus.' : 'Traditional texts link Mars in these houses with friction in marriage. Many astrologers consider it only from the Ascendant, and most consider it neutralised when both partners have it.',
      factors: factors,
      mitigations: mitigations,
      source: 'Commonly cited from Brihat Parashara Hora Shastra and later South Indian texts; the 2nd house is included in some traditions only.',
    );
  }

  /// Kaal Sarp: all seven classical planets on one side of the Rahu-Ketu axis.
  static DoshaReport kaalSarp(Chart chart) {
    final rahu = chart[Planet.rahu].longitude;
    var rahuSide = 0, ketuSide = 0;
    for (final p in [
      Planet.sun,
      Planet.moon,
      Planet.mars,
      Planet.mercury,
      Planet.jupiter,
      Planet.venus,
      Planet.saturn,
    ]) {
      final d = norm360(chart[p].longitude - rahu);
      if (d < 180) {
        rahuSide++;
      } else {
        ketuSide++;
      }
    }
    final present = rahuSide == 7 || ketuSide == 7;
    return DoshaReport(
      id: 'kaalSarp',
      name: 'Kaal Sarp Dosha',
      summaryRef: TextRef(present ? 'dosha.kaalSarp.present' : 'dosha.kaalSarp.absent'),
      present: present,
      summary: present
          ? 'All seven planets lie on one side of the Rahu-Ketu axis.'
          : 'The planets are spread on both sides of the Rahu-Ketu axis.',
      source: 'Kaal Sarp is a later (20th century) concept not found in classical texts such as BPHS; many traditional astrologers do not use it.',
    );
  }

  /// Sade Sati: Saturn transiting the 12th, 1st and 2nd sign from the natal Moon.
  static SadeSatiStatus sadeSati(Sign natalMoon, DateTime at, Ayanamsa ayanamsa) {
    final jd = Ephemeris.julianDay(at);
    final saturn = Sign.fromLongitude(Ephemeris.position(jd, Planet.saturn, ayanamsa: ayanamsa).longitude);
    final h = natalMoon.countTo(saturn);
    final phase = switch (h) {
      12 => 1,
      1 => 2,
      2 => 3,
      _ => 0,
    };
    final dhaiya = h == 4 || h == 8;
    return SadeSatiStatus(phase: phase, saturnSign: saturn, smallPanoti: dhaiya, houseFromMoon: h);
  }

  /// Periods when Saturn transits signs 12, 1 and 2 from [natalMoon]
  /// between [from] and [to]. Retrograde re-entries are merged.
  static List<(DateTime, DateTime)> sadeSatiPeriods(Sign natalMoon, DateTime from, DateTime to, Ayanamsa ayanamsa) {
    bool active(double jd) {
      final s = Sign.fromLongitude(Ephemeris.position(jd, Planet.saturn, ayanamsa: ayanamsa).longitude);
      final h = natalMoon.countTo(s);
      return h == 12 || h == 1 || h == 2;
    }

    final periods = <(DateTime, DateTime)>[];
    var jd = Ephemeris.julianDay(from);
    final jdEnd = Ephemeris.julianDay(to);
    var state = active(jd);
    double? start = state ? jd : null;
    const step = 10.0;
    while (jd < jdEnd) {
      final next = jd + step;
      final s = active(next);
      if (s != state) {
        var lo = jd, hi = next;
        for (var i = 0; i < 30; i++) {
          final mid = (lo + hi) / 2;
          if (active(mid) == state) {
            lo = mid;
          } else {
            hi = mid;
          }
        }
        if (s) {
          start = hi;
        } else if (start != null) {
          periods.add((Ephemeris.dateTimeFromJd(start), Ephemeris.dateTimeFromJd(hi)));
          start = null;
        }
        state = s;
      }
      jd = next;
    }
    if (start != null) periods.add((Ephemeris.dateTimeFromJd(start), Ephemeris.dateTimeFromJd(jdEnd)));

    // Merge gaps shorter than a year (retrograde exits).
    final merged = <(DateTime, DateTime)>[];
    for (final p in periods) {
      if (merged.isNotEmpty && p.$1.difference(merged.last.$2).inDays < 365) {
        merged[merged.length - 1] = (merged.last.$1, p.$2);
      } else {
        merged.add(p);
      }
    }
    return merged;
  }
}

class SadeSatiStatus {
  const SadeSatiStatus({
    required this.phase,
    required this.saturnSign,
    required this.smallPanoti,
    required this.houseFromMoon,
  });

  /// 0 = not running, 1 = rising (12th), 2 = peak (1st), 3 = setting (2nd).
  final int phase;
  final Sign saturnSign;

  /// Saturn in the 4th or 8th from the Moon (Dhaiya / Kantaka Shani).
  final bool smallPanoti;
  final int houseFromMoon;

  bool get running => phase > 0;
}
