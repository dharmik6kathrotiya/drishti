import 'package:timezone/timezone.dart' as tz;

import '../../horoscope/sky_events.dart';
import '../constants.dart';
import '../ephemeris.dart';
import '../settings.dart';
import 'festivals.dart';

/// Muhurat (auspicious time) finder based on general Panchang-shuddhi rules.
///
/// Lists of favourable nakshatras, tithis and weekdays follow those commonly
/// given in muhurta texts and popular panchangs; exact lists differ between
/// traditions and regions, and many families also consult a personal
/// astrologer. Every window lists the rules it meets and misses.
enum MuhuratActivity {
  marriage,
  grihaPravesh,
  vehiclePurchase,
  propertyPurchase,
  businessStart,
  travel,
  namingCeremony,
  mundan,
  educationStart,
}

class _ActivityRules {
  const _ActivityRules(this.nakshatras, this.varas, {this.night = false});

  /// Favourable nakshatra indices (0 = Ashwini).
  final Set<int> nakshatras;

  /// Favourable weekdays (0 = Sunday).
  final Set<int> varas;

  /// Search the night too (marriages are often performed at night).
  final bool night;
}

// Nakshatra indices: 0 Ashwini, 1 Bharani, 2 Krittika, 3 Rohini, 4 Mrigashira,
// 5 Ardra, 6 Punarvasu, 7 Pushya, 8 Ashlesha, 9 Magha, 10 P.Phalguni,
// 11 U.Phalguni, 12 Hasta, 13 Chitra, 14 Swati, 15 Vishakha, 16 Anuradha,
// 17 Jyeshtha, 18 Mula, 19 P.Ashadha, 20 U.Ashadha, 21 Shravana,
// 22 Dhanishta, 23 Shatabhisha, 24 P.Bhadrapada, 25 U.Bhadrapada, 26 Revati.
const _rules = {
  MuhuratActivity.marriage: _ActivityRules({3, 4, 9, 11, 12, 14, 16, 18, 20, 25, 26}, {1, 3, 4, 5}, night: true),
  MuhuratActivity.grihaPravesh: _ActivityRules({3, 4, 11, 13, 16, 20, 25, 26}, {1, 3, 4, 5}),
  MuhuratActivity.vehiclePurchase: _ActivityRules({0, 3, 4, 6, 7, 12, 13, 14, 16, 21, 22, 23, 26}, {1, 3, 4, 5}),
  MuhuratActivity.propertyPurchase: _ActivityRules({3, 4, 7, 11, 13, 16, 20, 25, 26}, {1, 3, 4, 5}),
  MuhuratActivity.businessStart: _ActivityRules({0, 3, 4, 6, 7, 11, 12, 13, 16, 20, 21, 22, 23, 25, 26}, {1, 3, 4, 5}),
  MuhuratActivity.travel: _ActivityRules({0, 4, 6, 7, 12, 16, 21, 22, 26}, {1, 3, 4, 5}),
  MuhuratActivity.namingCeremony: _ActivityRules(
    {0, 3, 4, 6, 7, 11, 12, 13, 14, 16, 20, 21, 22, 23, 25, 26},
    {1, 3, 4, 5},
  ),
  MuhuratActivity.mundan: _ActivityRules({0, 4, 6, 7, 12, 13, 14, 17, 21, 22, 23, 26}, {1, 3, 4, 5}),
  MuhuratActivity.educationStart: _ActivityRules(
    {0, 5, 6, 7, 10, 12, 13, 14, 18, 19, 21, 22, 23, 24, 26},
    {0, 3, 4, 5},
  ),
};

/// Tithis (within each paksha) commonly preferred for auspicious beginnings;
/// Rikta tithis (4, 9, 14), Amavasya and Ashtami are avoided.
const _goodPakshaTithis = {2, 3, 5, 7, 10, 11, 12, 13};

/// Yogas commonly avoided (soft) and the two always avoided (hard).
const _inauspiciousYogas = {0, 5, 8, 9, 12, 14, 18};
const _vyatipata = 16, _vaidhriti = 26;

class MuhuratOptions {
  const MuhuratOptions({
    this.avoidKharmas = true,
    this.avoidCombustion = true,
    this.avoidChaturmas = true,
    this.minimumMinutes = 30,
  });

  /// Sun in sidereal Sagittarius or Pisces (Kharmas / Malmas).
  final bool avoidKharmas;

  /// Jupiter or Venus combust (Guru/Shukra asta).
  final bool avoidCombustion;

  /// Devshayani to Prabodhini Ekadashi (North Indian practice).
  final bool avoidChaturmas;
  final int minimumMinutes;

  /// Which of the seasonal toggles apply to an activity.
  static bool seasonalApplies(MuhuratActivity a) => switch (a) {
    MuhuratActivity.marriage || MuhuratActivity.grihaPravesh || MuhuratActivity.mundan => true,
    _ => false,
  };
}

/// One rule check with its outcome; [hard] failures exclude a window.
class MuhuratCheck {
  const MuhuratCheck(this.id, this.passed, {this.hard = false, this.value});

  /// Rule id, e.g. 'nakshatra', 'tithi', 'vara', 'yoga', 'rahu_kaal',
  /// 'yamaganda', 'gulika', 'vishti', 'eclipse', 'kharmas', 'combust_jupiter',
  /// 'combust_venus', 'chaturmas', 'tara_bala', 'chandra_bala'.
  final String id;
  final bool passed;
  final bool hard;

  /// The value checked (e.g. the nakshatra name), for display.
  final String? value;
}

class MuhuratWindow {
  const MuhuratWindow({
    required this.date,
    required this.startUtc,
    required this.endUtc,
    required this.score,
    required this.checks,
    required this.tithi,
    required this.nakshatra,
    required this.yoga,
  });

  /// Local date the window belongs to (Hindu day, sunrise to sunrise).
  final DateTime date;
  final DateTime startUtc;
  final DateTime endUtc;

  /// 0..100, higher = more rules met.
  final int score;
  final List<MuhuratCheck> checks;
  final int tithi; // 1..30
  final int nakshatra; // 0..26
  final int yoga; // 0..26

  Duration get length => endUtc.difference(startUtc);
}

class MuhuratFinder {
  MuhuratFinder({
    required this.latitude,
    required this.longitude,
    required this.timezoneId,
    this.ayanamsa = Ayanamsa.lahiri,
  }) : _loc = tz.getLocation(timezoneId);

  final double latitude;
  final double longitude;
  final String timezoneId;
  final Ayanamsa ayanamsa;
  final tz.Location _loc;

  static const rahuPart = [7, 1, 6, 4, 5, 3, 2];
  static const yamaPart = [4, 3, 2, 1, 0, 6, 5];
  static const gulikaPart = [6, 5, 4, 3, 2, 1, 0];

  /// Finds windows between local dates [from] and [to] (inclusive).
  /// [birthNakshatra] / [birthMoonSign] enable personal Tara and Chandra Bala.
  List<MuhuratWindow> find({
    required MuhuratActivity activity,
    required DateTime from,
    required DateTime to,
    Nakshatra? birthNakshatra,
    Sign? birthMoonSign,
    MuhuratOptions options = const MuhuratOptions(),
  }) {
    final rules = _rules[activity]!;
    final jdFrom = _midnight(from);
    final jdTo = _midnight(to.add(const Duration(days: 2)));
    final cal = LunarCalendar(ayanamsa, jdFrom - 2, jdTo + 2);
    final eclipseDays = {
      for (final e in SkyEvents.eclipses(Ephemeris.dateTimeFromJd(jdFrom - 1), Ephemeris.dateTimeFromJd(jdTo)))
        _dateOf(Ephemeris.julianDay(e.time)),
    };
    final seasonal = MuhuratOptions.seasonalApplies(activity);
    final out = <MuhuratWindow>[];

    for (var d = DateTime(from.year, from.month, from.day); !d.isAfter(to); d = d.add(const Duration(days: 1))) {
      final jd0 = _midnight(d);
      final rise = Ephemeris.riseSet(jd0, Planet.sun, latitude, longitude, rise: true);
      if (rise == null) continue;
      final set = Ephemeris.riseSet(rise, Planet.sun, latitude, longitude, rise: false) ?? rise + 0.5;
      final nextRise = Ephemeris.riseSet(set, Planet.sun, latitude, longitude, rise: true) ?? rise + 1;
      final vara = _localWeekday(rise);
      final dayLen = set - rise;
      double part(int i) => rise + dayLen * i / 8;
      final bad = <(String, double, double)>[
        ('rahu_kaal', part(rahuPart[vara]), part(rahuPart[vara] + 1)),
        ('yamaganda', part(yamaPart[vara]), part(yamaPart[vara] + 1)),
        ('gulika', part(gulikaPart[vara]), part(gulikaPart[vara] + 1)),
      ];

      // Day-level checks, taken at sunrise.
      final dayChecks = <MuhuratCheck>[
        MuhuratCheck('vara', rules.varas.contains(vara), value: '$vara'),
        MuhuratCheck('eclipse', !eclipseDays.contains(d), hard: true),
      ];
      final sun = Ephemeris.position(rise, Planet.sun, ayanamsa: ayanamsa);
      if (seasonal && options.avoidKharmas) {
        final s = Sign.fromLongitude(sun.longitude);
        dayChecks.add(MuhuratCheck('kharmas', s != Sign.sagittarius && s != Sign.pisces, hard: true));
      }
      if (seasonal && options.avoidCombustion) {
        final jup = Ephemeris.position(rise, Planet.jupiter, ayanamsa: ayanamsa);
        final ven = Ephemeris.position(rise, Planet.venus, ayanamsa: ayanamsa);
        dayChecks.add(MuhuratCheck('combust_jupiter', angularDistance(jup.longitude, sun.longitude) >= 11, hard: true));
        final venusOrb = ven.isRetrograde ? 8.0 : 10.0;
        dayChecks.add(
          MuhuratCheck('combust_venus', angularDistance(ven.longitude, sun.longitude) >= venusOrb, hard: true),
        );
      }
      if (seasonal && options.avoidChaturmas) {
        final m = cal.monthAt(rise);
        final t = LunarCalendar.tithiAt(rise);
        final inChaturmas =
            m != null &&
            !m.adhika &&
            ((m.index == 3 && t >= 11) || (m.index >= 4 && m.index <= 6) || (m.index == 7 && t < 11));
        dayChecks.add(MuhuratCheck('chaturmas', !inChaturmas, hard: true));
      }

      // Walk the day (and night when relevant) segment by segment.
      final end = rules.night ? nextRise : set;
      final cuts = <double>{
        rise,
        end,
        for (final b in bad) ...[b.$2, b.$3],
      };
      var t = rise;
      while (t < end - 1e-6) {
        final next = _nextChange(t);
        cuts.add(next < end ? next : end);
        t = next;
      }
      final points = cuts.where((c) => c >= rise && c <= end).toList()..sort();

      MuhuratWindow? open;
      for (var i = 0; i + 1 < points.length; i++) {
        final a = points[i], b = points[i + 1];
        if (b - a < 1e-5) continue;
        final mid = (a + b) / 2;
        final checks = [...dayChecks, ..._segmentChecks(mid, rules, bad, birthNakshatra, birthMoonSign)];
        final hardFail = checks.any((c) => c.hard && !c.passed);
        final essential = checks.where((c) => c.id == 'nakshatra' || c.id == 'tithi').every((c) => c.passed);
        if (hardFail || !essential) {
          if (open != null) out.add(open);
          open = null;
          continue;
        }
        final el = _elements(mid);
        final score = _score(checks);
        if (open != null &&
            open.tithi == el.tithi &&
            open.nakshatra == el.nakshatra &&
            open.yoga == el.yoga &&
            Ephemeris.julianDay(open.endUtc) >= a - 1e-6) {
          open = MuhuratWindow(
            date: d,
            startUtc: open.startUtc,
            endUtc: Ephemeris.dateTimeFromJd(b),
            score: score < open.score ? score : open.score,
            checks: open.checks,
            tithi: el.tithi,
            nakshatra: el.nakshatra,
            yoga: el.yoga,
          );
        } else {
          if (open != null) out.add(open);
          open = MuhuratWindow(
            date: d,
            startUtc: Ephemeris.dateTimeFromJd(a),
            endUtc: Ephemeris.dateTimeFromJd(b),
            score: score,
            checks: checks,
            tithi: el.tithi,
            nakshatra: el.nakshatra,
            yoga: el.yoga,
          );
        }
      }
      if (open != null) out.add(open);
    }

    return out.where((w) => w.length.inMinutes >= options.minimumMinutes).toList();
  }

  List<MuhuratCheck> _segmentChecks(
    double jd,
    _ActivityRules rules,
    List<(String, double, double)> bad,
    Nakshatra? birthNak,
    Sign? birthMoon,
  ) {
    final el = _elements(jd);
    final pakshaTithi = (el.tithi - 1) % 15 + 1;
    final checks = <MuhuratCheck>[
      MuhuratCheck('nakshatra', rules.nakshatras.contains(el.nakshatra), value: Nakshatra.all[el.nakshatra].name),
      MuhuratCheck('tithi', el.tithi != 30 && _goodPakshaTithis.contains(pakshaTithi), value: '${el.tithi}'),
      MuhuratCheck('yoga', !_inauspiciousYogas.contains(el.yoga), value: '${el.yoga}'),
      MuhuratCheck('yoga_vyatipata_vaidhriti', el.yoga != _vyatipata && el.yoga != _vaidhriti, hard: true),
      MuhuratCheck('vishti', !_isVishti(el.karana), hard: true),
      for (final b in bad) MuhuratCheck(b.$1, !(jd >= b.$2 && jd < b.$3), hard: true),
    ];
    if (birthNak != null) {
      final n = ((el.nakshatra - birthNak.index) % 27) + 1;
      final tara = (n - 1) % 9; // 0 Janma ... 8 Parama Mitra
      checks.add(MuhuratCheck('tara_bala', tara != 2 && tara != 4 && tara != 6, value: '$tara'));
    }
    if (birthMoon != null) {
      final moon = Sign.fromLongitude(Ephemeris.position(jd, Planet.moon, ayanamsa: ayanamsa).longitude);
      final h = birthMoon.countTo(moon);
      checks.add(MuhuratCheck('chandra_bala', const {1, 3, 6, 7, 10, 11}.contains(h), value: '$h'));
    }
    return checks;
  }

  static int _score(List<MuhuratCheck> checks) {
    const weights = {'nakshatra': 30, 'tithi': 20, 'vara': 15, 'yoga': 10, 'tara_bala': 15, 'chandra_bala': 10};
    var total = 0, got = 0;
    for (final c in checks) {
      final w = weights[c.id];
      if (w == null) continue;
      total += w;
      if (c.passed) got += w;
    }
    return total == 0 ? 0 : (got * 100 / total).round();
  }

  static bool _isVishti(int karana) => karana >= 2 && karana <= 57 && (karana - 2) % 7 == 6;

  ({int tithi, int nakshatra, int yoga, int karana}) _elements(double jd) {
    final sunT = Ephemeris.position(jd, Planet.sun).longitude;
    final moonT = Ephemeris.position(jd, Planet.moon).longitude;
    final sunS = Ephemeris.position(jd, Planet.sun, ayanamsa: ayanamsa).longitude;
    final moonS = Ephemeris.position(jd, Planet.moon, ayanamsa: ayanamsa).longitude;
    final elong = norm360(moonT - sunT);
    return (
      tithi: (elong / 12).floor() % 30 + 1,
      nakshatra: (moonS / Nakshatra.span).floor() % 27,
      yoga: (norm360(sunS + moonS) / Nakshatra.span).floor() % 27,
      karana: (elong / 6).floor() % 60 + 1,
    );
  }

  /// Earliest moment after [jd] when tithi, karana, nakshatra or yoga changes.
  double _nextChange(double jd) {
    final el = _elements(jd);
    final karanaEnd = LunarCalendar.timeOfElongation(el.karana * 6.0, jd + 0.25);
    final nakEnd = Ephemeris.moonCrossing(norm360((el.nakshatra + 1) * Nakshatra.span), jd, ayanamsa: ayanamsa);
    final yogaEnd = _yogaEnd(jd, (el.yoga + 1) * Nakshatra.span);
    var next = karanaEnd;
    if (nakEnd < next) next = nakEnd;
    if (yogaEnd < next) next = yogaEnd;
    return next > jd + 1e-4 ? next : jd + 1 / 1440;
  }

  double _yogaEnd(double jd, double target) {
    double sum(double t) => norm360(
      Ephemeris.position(t, Planet.sun, ayanamsa: ayanamsa).longitude +
          Ephemeris.position(t, Planet.moon, ayanamsa: ayanamsa).longitude,
    );
    var t = jd;
    for (var i = 0; i < 30; i++) {
      final diff = norm360(norm360(target) - sum(t) + 180) - 180;
      if (diff.abs() < 1e-7) break;
      t += diff / 13.2;
    }
    return t;
  }

  double _midnight(DateTime d) => Ephemeris.julianDay(tz.TZDateTime(_loc, d.year, d.month, d.day).toUtc());

  DateTime _dateOf(double jd) {
    final t = tz.TZDateTime.from(Ephemeris.dateTimeFromJd(jd), _loc);
    return DateTime(t.year, t.month, t.day);
  }

  int _localWeekday(double jd) {
    final t = tz.TZDateTime.from(Ephemeris.dateTimeFromJd(jd), _loc);
    return t.weekday % 7;
  }
}
