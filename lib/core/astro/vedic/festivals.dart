import 'package:timezone/timezone.dart' as tz;

import '../../horoscope/sky_events.dart';
import '../constants.dart';
import '../ephemeris.dart';
import '../settings.dart';
import 'panchang.dart';

/// Hindu festival and vrat calendar.
///
/// Dates follow the common North Indian (Smarta) observance rules used by
/// most printed panchangs: a festival is kept on the day its tithi prevails
/// during a particular part of the day (the "kala"). Regional and sectarian
/// traditions (Vaishnava, Tamil, Kerala ...) sometimes differ; each event
/// carries a note where that is common.

/// Part of the day in which a tithi must prevail.
enum Kala {
  /// At sunrise (udaya tithi), the default rule.
  sunrise,

  /// Third fifth of daytime.
  madhyahna,

  /// Fourth fifth of daytime.
  aparahna,

  /// Six ghatis (2 h 24 min) after sunset.
  pradosh,

  /// The 8th of the 15 night muhurtas (around local midnight).
  nishita,

  /// At moonrise.
  moonrise,
}

enum FestivalType { festival, vrat, sankranti, eclipse }

/// How the date was chosen, kept for transparency in the UI.
class ObservanceRule {
  const ObservanceRule({
    this.kala,
    this.tithi,
    this.amantaMonth,
    this.purnimantaMonth,
    this.adhika = false,
    this.special,
  });

  final Kala? kala;

  /// 1..30 (Shukla 1-15, Krishna 16-30).
  final int? tithi;

  /// Month index 0 = Chaitra ... 11 = Phalguna.
  final int? amantaMonth;
  final int? purnimantaMonth;
  final bool adhika;

  /// Identifier of a special rule (e.g. 'bhadra', 'sankranti_after_sunset',
  /// 'kshaya', 'vriddhi', 'second_day_pradosh').
  final String? special;
}

class FestivalEvent {
  const FestivalEvent({
    required this.id,
    required this.date,
    required this.type,
    required this.rule,
    this.tithiStartUtc,
    this.tithiEndUtc,
    this.windowStartUtc,
    this.windowEndUtc,
    this.instantUtc,
    this.detail,
  });

  /// Stable id used to look up names and descriptions in every language
  /// (e.g. 'diwali', 'ekadashi_nirjala', 'sankranti_capricorn').
  final String id;

  /// Local civil date at the chosen place.
  final DateTime date;
  final FestivalType type;
  final ObservanceRule rule;
  final DateTime? tithiStartUtc;
  final DateTime? tithiEndUtc;

  /// The kala window (or muhurta) on the chosen day, when meaningful.
  final DateTime? windowStartUtc;
  final DateTime? windowEndUtc;

  /// Exact moment for sankrantis and eclipses.
  final DateTime? instantUtc;

  /// Extra machine-readable detail (e.g. eclipse kind).
  final String? detail;
}

/// A lunar month from one new moon to the next.
class LunarMonth {
  const LunarMonth(this.startJd, this.endJd, this.index, this.adhika);
  final double startJd;
  final double endJd;

  /// Amanta month index, 0 = Chaitra ... 11 = Phalguna.
  final int index;
  final bool adhika;

  int get purnimantaIndexForKrishna => (index + 1) % 12;
}

/// Lunar months, tithis and their timing over a span of time.
class LunarCalendar {
  LunarCalendar(this.ayanamsa, double fromJd, double toJd) {
    final newMoons = <double>[];
    var t = _newMoonBefore(fromJd - 1);
    newMoons.add(t);
    while (t < toJd + 1) {
      t = timeOfElongation(0, t + 29.53);
      newMoons.add(t);
    }
    double sunSid(double jd) => Ephemeris.position(jd, Planet.sun, ayanamsa: ayanamsa).longitude;
    for (var i = 0; i + 1 < newMoons.length; i++) {
      final s1 = Sign.fromLongitude(sunSid(newMoons[i]));
      final s2 = Sign.fromLongitude(sunSid(newMoons[i + 1]));
      months.add(LunarMonth(newMoons[i], newMoons[i + 1], (s1.index + 1) % 12, s1 == s2));
    }
  }

  final Ayanamsa ayanamsa;
  final List<LunarMonth> months = [];

  static double elongation(double jd) =>
      norm360(Ephemeris.position(jd, Planet.moon).longitude - Ephemeris.position(jd, Planet.sun).longitude);

  /// Tithi 1..30 at [jd].
  static int tithiAt(double jd) => (elongation(jd) / 12).floor() % 30 + 1;

  /// Moment the Moon-Sun elongation reaches [target] nearest to [guess].
  static double timeOfElongation(double target, double guess) {
    var t = guess;
    for (var i = 0; i < 40; i++) {
      final diff = norm360(target - elongation(t) + 180) - 180;
      if (diff.abs() < 1e-7) break;
      t += diff / 12.19;
    }
    return t;
  }

  static double _newMoonBefore(double jd) {
    final e = elongation(jd);
    return timeOfElongation(0, jd - e / 12.19);
  }

  LunarMonth? monthAt(double jd) => months.where((m) => jd >= m.startJd && jd < m.endJd).firstOrNull;

  /// Start and end (UT Julian days) of [tithi] (1..30) within [m].
  (double, double) tithiInterval(LunarMonth m, int tithi) {
    final span = m.endJd - m.startJd;
    final s = tithi == 1 ? m.startJd : timeOfElongation((tithi - 1) * 12.0, m.startJd + span * (tithi - 1) / 30);
    final e = tithi == 30 ? m.endJd : timeOfElongation(tithi * 12.0, m.startJd + span * tithi / 30);
    return (s, e);
  }

  /// Vishti (Bhadra) karana inside [tithi] of [m], or null if it has none.
  /// Karana k (1..60) is Vishti when it is the 7th movable karana, i.e.
  /// (k - 2) % 7 == 6 for k in 2..57; Purnima's first half is one of them.
  (double, double)? vishtiInTithi(LunarMonth m, int tithi) {
    for (final k in [2 * tithi - 1, 2 * tithi]) {
      if (k >= 2 && k <= 57 && (k - 2) % 7 == 6) {
        final span = m.endJd - m.startJd;
        final s = timeOfElongation((k - 1) * 6.0, m.startJd + span * (k - 1) / 60);
        final e = timeOfElongation(k * 6.0, m.startJd + span * k / 60);
        return (s, e);
      }
    }
    return null;
  }
}

/// Sunrise/sunset/moonrise for local dates at one place (cached).
class _Sky {
  _Sky(this.lat, this.lon, this.location);
  final double lat;
  final double lon;
  final tz.Location location;
  final _cache = <DateTime, _DayTimes>{};

  double midnightJd(DateTime d) => Ephemeris.julianDay(tz.TZDateTime(location, d.year, d.month, d.day).toUtc());

  DateTime dateOf(double jd) {
    final t = tz.TZDateTime.from(Ephemeris.dateTimeFromJd(jd), location);
    return DateTime(t.year, t.month, t.day);
  }

  _DayTimes day(DateTime d) => _cache.putIfAbsent(d, () {
    final jd0 = midnightJd(d);
    final rise = Ephemeris.riseSet(jd0, Planet.sun, lat, lon, rise: true) ?? jd0 + 0.25;
    final set = Ephemeris.riseSet(rise, Planet.sun, lat, lon, rise: false) ?? rise + 0.5;
    final next = Ephemeris.riseSet(set, Planet.sun, lat, lon, rise: true) ?? rise + 1;
    final mr = Ephemeris.riseSet(jd0, Planet.moon, lat, lon, rise: true);
    return _DayTimes(rise, set, next, mr != null && mr < jd0 + 1 ? mr : null);
  });

  /// Kala window for date [d]. Instants are returned as zero-length windows.
  (double, double)? window(DateTime d, Kala k) {
    final t = day(d);
    final dayLen = t.set - t.rise;
    final night = t.nextRise - t.set;
    return switch (k) {
      Kala.sunrise => (t.rise, t.rise),
      Kala.madhyahna => (t.rise + dayLen * 2 / 5, t.rise + dayLen * 3 / 5),
      Kala.aparahna => (t.rise + dayLen * 3 / 5, t.rise + dayLen * 4 / 5),
      Kala.pradosh => (t.set, t.set + 0.1),
      Kala.nishita => (t.set + night * 7 / 15, t.set + night * 8 / 15),
      Kala.moonrise => t.moonrise == null ? null : (t.moonrise!, t.moonrise!),
    };
  }
}

class _DayTimes {
  const _DayTimes(this.rise, this.set, this.nextRise, this.moonrise);
  final double rise;
  final double set;
  final double nextRise;
  final double? moonrise;
}

/// What to do when the tithi prevails in the kala on two consecutive days.
enum _Tie {
  first,

  /// Second day if the tithi still covers at least one ghati (24 min) of
  /// the kala there (Diwali: Dharmasindhu-style rule).
  secondIfGhati,
}

class _Def {
  const _Def(this.id, this.month, this.tithi, this.kala, this.type, [this.tie = _Tie.first]);
  final String id;
  final int month;
  final int tithi;
  final Kala kala;
  final FestivalType type;
  final _Tie tie;
}

/// Annual tithi festivals (amanta month index, tithi).
const _annual = [
  _Def('ugadi', 0, 1, Kala.sunrise, FestivalType.festival),
  _Def('chaitra_navratri', 0, 1, Kala.sunrise, FestivalType.festival),
  _Def('ram_navami', 0, 9, Kala.madhyahna, FestivalType.festival),
  _Def('hanuman_jayanti', 0, 15, Kala.sunrise, FestivalType.festival),
  _Def('akshaya_tritiya', 1, 3, Kala.sunrise, FestivalType.festival),
  _Def('buddha_purnima', 1, 15, Kala.sunrise, FestivalType.festival),
  _Def('guru_purnima', 3, 15, Kala.sunrise, FestivalType.festival),
  _Def('nag_panchami', 4, 5, Kala.sunrise, FestivalType.festival),
  _Def('janmashtami', 4, 23, Kala.nishita, FestivalType.festival),
  _Def('ganesh_chaturthi', 5, 4, Kala.madhyahna, FestivalType.festival),
  _Def('sharad_navratri', 6, 1, Kala.sunrise, FestivalType.festival),
  _Def('dussehra', 6, 10, Kala.aparahna, FestivalType.festival),
  _Def('sharad_purnima', 6, 15, Kala.pradosh, FestivalType.festival),
  _Def('karva_chauth', 6, 19, Kala.moonrise, FestivalType.vrat),
  _Def('dhanteras', 6, 28, Kala.pradosh, FestivalType.festival),
  _Def('naraka_chaturdashi', 6, 29, Kala.sunrise, FestivalType.festival),
  _Def('diwali', 6, 30, Kala.pradosh, FestivalType.festival, _Tie.secondIfGhati),
  _Def('govardhan_puja', 7, 1, Kala.sunrise, FestivalType.festival),
  _Def('bhai_dooj', 7, 2, Kala.aparahna, FestivalType.festival),
  _Def('chhath', 7, 6, Kala.sunrise, FestivalType.festival),
  _Def('kartik_purnima', 7, 15, Kala.sunrise, FestivalType.festival),
  _Def('vasant_panchami', 10, 5, Kala.sunrise, FestivalType.festival),
  _Def('maha_shivaratri', 10, 29, Kala.nishita, FestivalType.festival),
];

/// Ekadashi ids by amanta month: (Shukla, Krishna).
const ekadashiIds = [
  ('kamada', 'varuthini'),
  ('mohini', 'apara'),
  ('nirjala', 'yogini'),
  ('devshayani', 'kamika'),
  ('shravana_putrada', 'aja'),
  ('parsva', 'indira'),
  ('papankusha', 'rama'),
  ('prabodhini', 'utpanna'),
  ('mokshada', 'saphala'),
  ('pausha_putrada', 'shattila'),
  ('jaya', 'vijaya'),
  ('amalaki', 'papmochani'),
];

class FestivalCalculator {
  FestivalCalculator({
    required this.latitude,
    required this.longitude,
    required this.timezoneId,
    this.ayanamsa = Ayanamsa.lahiri,
  }) : _sky = _Sky(latitude, longitude, tz.getLocation(timezoneId));

  final double latitude;
  final double longitude;
  final String timezoneId;
  final Ayanamsa ayanamsa;
  final _Sky _sky;

  /// All festivals, vrats, sankrantis and eclipses in Gregorian [year],
  /// sorted by date.
  List<FestivalEvent> year(int year) {
    final from = _sky.midnightJd(DateTime(year, 1, 1));
    final to = _sky.midnightJd(DateTime(year + 1, 1, 1));
    final cal = LunarCalendar(ayanamsa, from - 40, to + 40);
    final out = <FestivalEvent>[];

    for (final m in cal.months) {
      if (m.endJd < from - 35 || m.startJd > to + 35) continue;
      if (!m.adhika) {
        for (final d in _annual.where((d) => d.month == m.index)) {
          out.add(_resolve(cal, m, d.id, d.tithi, d.kala, d.type, d.tie));
        }
        if (m.index == 4) out.add(_rakshaBandhan(cal, m));
        if (m.index == 11) out.addAll(_holi(cal, m));
      }
      // Monthly vrats (also in adhika months).
      final names = ekadashiIds[m.index];
      out.add(_resolve(cal, m, 'ekadashi_${m.adhika ? 'padmini' : names.$1}', 11, Kala.sunrise, FestivalType.vrat));
      out.add(_resolve(cal, m, 'ekadashi_${m.adhika ? 'parama' : names.$2}', 26, Kala.sunrise, FestivalType.vrat));
      out.add(_resolve(cal, m, 'pradosh', 13, Kala.pradosh, FestivalType.vrat));
      out.add(_resolve(cal, m, 'pradosh', 28, Kala.pradosh, FestivalType.vrat));
      out.add(_resolve(cal, m, 'sankashti_chaturthi', 19, Kala.moonrise, FestivalType.vrat));
      if (m.index != 10 || m.adhika) {
        out.add(_resolve(cal, m, 'masik_shivaratri', 29, Kala.nishita, FestivalType.vrat));
      }
      out.add(_resolve(cal, m, 'purnima', 15, Kala.sunrise, FestivalType.vrat));
      out.add(_resolve(cal, m, 'amavasya', 30, Kala.sunrise, FestivalType.vrat));
    }

    out.addAll(_sankrantis(year));
    final onam = _onam(year);
    if (onam != null) out.add(onam);
    out.addAll(_eclipses(year));

    final kept = out.where((e) => e.date.year == year).toList()
      ..sort((a, b) {
        final c = a.date.compareTo(b.date);
        return c != 0 ? c : a.type.index.compareTo(b.type.index);
      });
    return kept;
  }

  /// Picks the day on which [tithi] of month [m] prevails during [kala].
  FestivalEvent _resolve(
    LunarCalendar cal,
    LunarMonth m,
    String id,
    int tithi,
    Kala kala,
    FestivalType type, [
    _Tie tie = _Tie.first,
  ]) {
    final (s, e) = cal.tithiInterval(m, tithi);
    final first = _sky.dateOf(s).subtract(const Duration(days: 1));
    final last = _sky.dateOf(e);

    final hits = <(DateTime, double, (double, double))>[];
    for (var d = first; !d.isAfter(last); d = d.add(const Duration(days: 1))) {
      final w = _sky.window(d, kala);
      if (w == null) continue;
      final overlap = w.$1 == w.$2 ? (w.$1 >= s && w.$1 < e ? 1e-6 : 0.0) : (_min(w.$2, e) - _max(w.$1, s));
      if (overlap > 0) hits.add((d, overlap, w));
    }

    String? special;
    DateTime date;
    (double, double)? window;
    if (hits.isEmpty) {
      // Tithi never prevails in the kala: fall back to the udaya tithi, or
      // to the day it begins when it touches no sunrise at all (kshaya).
      final sunriseDay = _sunriseDay(s, e);
      date = sunriseDay ?? _sky.dateOf(s);
      special = sunriseDay == null ? 'kshaya' : 'fallback_sunrise';
    } else if (hits.length == 1) {
      date = hits.first.$1;
      window = hits.first.$3;
    } else {
      var pick = hits.first;
      if (tie == _Tie.secondIfGhati && hits[1].$2 >= 1 / 60) pick = hits[1];
      date = pick.$1;
      window = pick.$3;
      special = kala == Kala.sunrise ? 'vriddhi' : 'both_days';
    }

    return FestivalEvent(
      id: id,
      date: date,
      type: type,
      rule: ObservanceRule(
        kala: kala,
        tithi: tithi,
        amantaMonth: m.index,
        purnimantaMonth: tithi > 15 ? m.purnimantaIndexForKrishna : m.index,
        adhika: m.adhika,
        special: special,
      ),
      tithiStartUtc: Ephemeris.dateTimeFromJd(s),
      tithiEndUtc: Ephemeris.dateTimeFromJd(e),
      windowStartUtc: window == null || window.$1 == window.$2 ? null : Ephemeris.dateTimeFromJd(window.$1),
      windowEndUtc: window == null || window.$1 == window.$2 ? null : Ephemeris.dateTimeFromJd(window.$2),
      instantUtc: window != null && window.$1 == window.$2 ? Ephemeris.dateTimeFromJd(window.$1) : null,
    );
  }

  DateTime? _sunriseDay(double s, double e) {
    for (var d = _sky.dateOf(s); !d.isAfter(_sky.dateOf(e)); d = d.add(const Duration(days: 1))) {
      final r = _sky.day(d).rise;
      if (r >= s && r < e) return d;
    }
    return null;
  }

  /// Raksha Bandhan: Shravana Purnima in the aparahna, avoiding Bhadra. If
  /// Bhadra spoils the aparahna and Purnima lasts at least 3 muhurtas after
  /// the next sunrise, the next day is used.
  FestivalEvent _rakshaBandhan(LunarCalendar cal, LunarMonth m) {
    final base = _resolve(cal, m, 'raksha_bandhan', 15, Kala.aparahna, FestivalType.festival);
    final (s, e) = cal.tithiInterval(m, 15);
    final vishti = cal.vishtiInTithi(m, 15)!;
    final w = _sky.window(base.date, Kala.aparahna)!;
    final clearOverlap = _min(w.$2, e) - _max(w.$1, _max(s, vishti.$2));
    if (clearOverlap > 0) return base;
    final next = base.date.add(const Duration(days: 1));
    final rise = _sky.day(next).rise;
    if (rise >= s && rise < e && e - rise >= 0.1) {
      return FestivalEvent(
        id: 'raksha_bandhan',
        date: next,
        type: FestivalType.festival,
        rule: ObservanceRule(
          kala: Kala.sunrise,
          tithi: 15,
          amantaMonth: m.index,
          purnimantaMonth: m.index,
          special: 'bhadra',
        ),
        tithiStartUtc: Ephemeris.dateTimeFromJd(s),
        tithiEndUtc: Ephemeris.dateTimeFromJd(e),
        windowStartUtc: Ephemeris.dateTimeFromJd(_max(rise, vishti.$2)),
        windowEndUtc: Ephemeris.dateTimeFromJd(e),
      );
    }
    return FestivalEvent(
      id: 'raksha_bandhan',
      date: base.date,
      type: FestivalType.festival,
      rule: ObservanceRule(
        kala: Kala.pradosh,
        tithi: 15,
        amantaMonth: m.index,
        purnimantaMonth: m.index,
        special: 'bhadra',
      ),
      tithiStartUtc: base.tithiStartUtc,
      tithiEndUtc: base.tithiEndUtc,
      windowStartUtc: Ephemeris.dateTimeFromJd(vishti.$2),
      windowEndUtc: Ephemeris.dateTimeFromJd(_min(e, _sky.day(base.date).set + 0.1)),
    );
  }

  /// Holika Dahan: Phalguna Purnima at pradosh, after Bhadra. If Bhadra lasts
  /// past the nishita, it moves to the next evening. Holi (Dhulandi) is the
  /// following day.
  List<FestivalEvent> _holi(LunarCalendar cal, LunarMonth m) {
    final base = _resolve(cal, m, 'holika_dahan', 15, Kala.pradosh, FestivalType.festival);
    final (s, e) = cal.tithiInterval(m, 15);
    final vishti = cal.vishtiInTithi(m, 15)!;
    var date = base.date;
    var special = 'bhadra';
    final pradosh = _sky.window(date, Kala.pradosh)!;
    final nishita = _sky.window(date, Kala.nishita)!;
    double start;
    if (vishti.$2 <= pradosh.$1) {
      start = pradosh.$1;
      special = 'no_bhadra';
    } else if (vishti.$2 <= nishita.$2) {
      start = _max(vishti.$2, pradosh.$1);
    } else {
      date = date.add(const Duration(days: 1));
      start = _sky.day(date).set;
      special = 'bhadra_next_evening';
    }
    final dahan = FestivalEvent(
      id: 'holika_dahan',
      date: date,
      type: FestivalType.festival,
      rule: ObservanceRule(
        kala: Kala.pradosh,
        tithi: 15,
        amantaMonth: m.index,
        purnimantaMonth: m.index,
        special: special,
      ),
      tithiStartUtc: Ephemeris.dateTimeFromJd(s),
      tithiEndUtc: Ephemeris.dateTimeFromJd(e),
      windowStartUtc: Ephemeris.dateTimeFromJd(start),
      windowEndUtc: Ephemeris.dateTimeFromJd(start + 0.1),
    );
    final holi = FestivalEvent(
      id: 'holi',
      date: date.add(const Duration(days: 1)),
      type: FestivalType.festival,
      rule: ObservanceRule(
        tithi: 16,
        amantaMonth: m.index,
        purnimantaMonth: (m.index + 1) % 12,
        special: 'day_after_dahan',
      ),
    );
    return [dahan, holi];
  }

  /// Sun's entry into each sidereal sign. An ingress after sunset is
  /// observed the next day.
  List<FestivalEvent> _sankrantis(int year) {
    final out = <FestivalEvent>[];
    var jd = _sky.midnightJd(DateTime(year - 1, 12, 1));
    final end = _sky.midnightJd(DateTime(year + 1, 1, 10));
    while (true) {
      final sun = Ephemeris.position(jd, Planet.sun, ayanamsa: ayanamsa).longitude;
      final next = Sign.fromLongitude(sun) + 1;
      final t = Ephemeris.sunCrossing(next.index * 30.0, jd, ayanamsa: ayanamsa);
      if (t > end) break;
      final local = _sky.dateOf(t);
      final afterSunset = t > _sky.day(local).set;
      final date = afterSunset ? local.add(const Duration(days: 1)) : local;
      out.add(
        FestivalEvent(
          id: 'sankranti_${next.name}',
          date: date,
          type: FestivalType.sankranti,
          rule: ObservanceRule(special: afterSunset ? 'sankranti_after_sunset' : 'sankranti'),
          instantUtc: Ephemeris.dateTimeFromJd(t),
        ),
      );
      jd = t + 25;
    }
    return out;
  }

  /// Onam (Thiruvonam): the day in the solar month of Simha (Chingam) when
  /// the Moon is in Shravana (Thiruvonam) at sunrise.
  FestivalEvent? _onam(int year) {
    final leo = Ephemeris.sunCrossing(120, _sky.midnightJd(DateTime(year, 7, 1)), ayanamsa: ayanamsa);
    final virgo = Ephemeris.sunCrossing(150, leo + 1, ayanamsa: ayanamsa);
    for (var d = _sky.dateOf(leo); !d.isAfter(_sky.dateOf(virgo)); d = d.add(const Duration(days: 1))) {
      final rise = _sky.day(d).rise;
      if (rise < leo || rise > virgo) continue;
      final moon = Ephemeris.position(rise, Planet.moon, ayanamsa: ayanamsa).longitude;
      if (Nakshatra.fromLongitude(moon).index == 21) {
        return FestivalEvent(
          id: 'onam',
          date: d,
          type: FestivalType.festival,
          rule: const ObservanceRule(kala: Kala.sunrise, special: 'nakshatra_shravana_simha'),
        );
      }
    }
    return null;
  }

  List<FestivalEvent> _eclipses(int year) => [
    for (final e in SkyEvents.eclipses(
      DateTime.utc(year - 1, 12, 31),
      DateTime.utc(year + 1, 1, 2),
      ayanamsa: ayanamsa,
    ))
      FestivalEvent(
        id: e.type == SkyEventType.solarEclipse ? 'solar_eclipse' : 'lunar_eclipse',
        date: _sky.dateOf(Ephemeris.julianDay(e.time)),
        type: FestivalType.eclipse,
        rule: const ObservanceRule(special: 'eclipse_global'),
        instantUtc: e.time,
        detail: e.eclipseKind,
      ),
  ];

  static double _min(double a, double b) => a < b ? a : b;
  static double _max(double a, double b) => a > b ? a : b;
}

/// Month names re-exported for UI convenience.
String lunarMonthName(int index) => lunarMonthNames[index % 12];
