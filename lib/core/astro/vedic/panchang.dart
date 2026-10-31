import '../constants.dart';
import '../ephemeris.dart';
import '../settings.dart';

const tithiNames = [
  'Pratipada',
  'Dwitiya',
  'Tritiya',
  'Chaturthi',
  'Panchami',
  'Shashthi',
  'Saptami',
  'Ashtami',
  'Navami',
  'Dashami',
  'Ekadashi',
  'Dwadashi',
  'Trayodashi',
  'Chaturdashi',
];

const yogaNames = [
  'Vishkambha',
  'Priti',
  'Ayushman',
  'Saubhagya',
  'Shobhana',
  'Atiganda',
  'Sukarma',
  'Dhriti',
  'Shoola',
  'Ganda',
  'Vriddhi',
  'Dhruva',
  'Vyaghata',
  'Harshana',
  'Vajra',
  'Siddhi',
  'Vyatipata',
  'Variyana',
  'Parigha',
  'Shiva',
  'Siddha',
  'Sadhya',
  'Shubha',
  'Shukla',
  'Brahma',
  'Indra',
  'Vaidhriti',
];

const _movableKaranas = ['Bava', 'Balava', 'Kaulava', 'Taitila', 'Garaja', 'Vanija', 'Vishti'];

const varaNames = ['Ravivara', 'Somavara', 'Mangalavara', 'Budhavara', 'Guruvara', 'Shukravara', 'Shanivara'];

/// Weekday lords, Sunday first.
const varaLords = [Planet.sun, Planet.moon, Planet.mars, Planet.mercury, Planet.jupiter, Planet.venus, Planet.saturn];

const lunarMonthNames = [
  'Chaitra',
  'Vaishakha',
  'Jyeshtha',
  'Ashadha',
  'Shravana',
  'Bhadrapada',
  'Ashwin',
  'Kartika',
  'Margashirsha',
  'Pausha',
  'Magha',
  'Phalguna',
];

/// Karana name for karana number 1..60 within the lunar month.
String karanaName(int n) {
  if (n == 1) return 'Kimstughna';
  if (n >= 58) return const ['Shakuni', 'Chatushpada', 'Naga'][n - 58];
  return _movableKaranas[(n - 2) % 7];
}

enum ChoghadiyaKind {
  amrit('Amrit', true),
  shubh('Shubh', true),
  labh('Labh', true),
  char('Char', true),
  udveg('Udveg', false),
  kaal('Kaal', false),
  rog('Rog', false);

  const ChoghadiyaKind(this.label, this.auspicious);
  final String label;
  final bool auspicious;
}

class TimeSpan {
  const TimeSpan(this.start, this.end, this.label, {this.good});
  final DateTime start;
  final DateTime end;
  final String label;
  final bool? good;
  bool contains(DateTime t) => !t.isBefore(start) && t.isBefore(end);
}

/// An element (tithi, nakshatra ...) with the moment it ends.
class PanchangElement {
  const PanchangElement(this.index, this.name, this.endsAt);
  final int index;
  final String name;
  final DateTime? endsAt;
}

class Panchang {
  Panchang({
    required this.date,
    required this.sunrise,
    required this.sunset,
    required this.nextSunrise,
    required this.moonrise,
    required this.moonset,
    required this.vara,
    required this.tithi,
    required this.paksha,
    required this.nakshatra,
    required this.yoga,
    required this.karana,
    required this.moonSign,
    required this.sunSign,
    required this.lunarMonthAmanta,
    required this.lunarMonthPurnimanta,
    required this.isAdhikaMasa,
    required this.vikramSamvat,
    required this.shakaSamvat,
    required this.rahuKaal,
    required this.yamaganda,
    required this.gulika,
    required this.abhijit,
    required this.dayChoghadiya,
    required this.nightChoghadiya,
    required this.horas,
  });

  final DateTime date;
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime nextSunrise;
  final DateTime? moonrise;
  final DateTime? moonset;
  final int vara; // 0 = Sunday
  final PanchangElement tithi; // index 1..30
  final String paksha; // Shukla / Krishna
  final PanchangElement nakshatra; // index 0..26
  final PanchangElement yoga; // index 0..26
  final PanchangElement karana; // index 1..60
  final Sign moonSign;
  final Sign sunSign;
  final String lunarMonthAmanta;
  final String lunarMonthPurnimanta;
  final bool isAdhikaMasa;
  final int vikramSamvat;
  final int shakaSamvat;
  final TimeSpan rahuKaal;
  final TimeSpan yamaganda;
  final TimeSpan gulika;
  final TimeSpan? abhijit;
  final List<TimeSpan> dayChoghadiya;
  final List<TimeSpan> nightChoghadiya;
  final List<TimeSpan> horas;

  String get varaName => varaNames[vara];
  Planet get varaLord => varaLords[vara];
}

class PanchangCalculator {
  PanchangCalculator._();

  /// Panchang for the civil [date] at a location. [utcOffset] converts the
  /// civil date's local midnight to UT. Elements are taken at sunrise, the
  /// traditional start of the Hindu day.
  static Panchang compute({
    required DateTime date,
    required double latitude,
    required double longitude,
    required Duration utcOffset,
    Ayanamsa ayanamsa = Ayanamsa.lahiri,
  }) {
    final midnightUtc = DateTime.utc(date.year, date.month, date.day).subtract(utcOffset);
    final jd0 = Ephemeris.julianDay(midnightUtc);

    double rise(double from) => Ephemeris.riseSet(from, Planet.sun, latitude, longitude, rise: true) ?? from + 0.25;
    double set(double from) => Ephemeris.riseSet(from, Planet.sun, latitude, longitude, rise: false) ?? from + 0.75;

    final jdRise = rise(jd0);
    final jdSet = set(jdRise);
    final jdNextRise = rise(jdSet);
    final moonRise = Ephemeris.riseSet(jd0, Planet.moon, latitude, longitude, rise: true);
    final moonSet = Ephemeris.riseSet(jd0, Planet.moon, latitude, longitude, rise: false);

    DateTime dt(double jd) => Ephemeris.dateTimeFromJd(jd);

    final sunTrop = Ephemeris.position(jdRise, Planet.sun).longitude;
    final moonTrop = Ephemeris.position(jdRise, Planet.moon).longitude;
    final sunSid = Ephemeris.position(jdRise, Planet.sun, ayanamsa: ayanamsa).longitude;
    final moonSid = Ephemeris.position(jdRise, Planet.moon, ayanamsa: ayanamsa).longitude;

    // Tithi: each 12° of Moon-Sun elongation.
    final elong = norm360(moonTrop - sunTrop);
    final tithiNum = (elong / 12).floor() + 1; // 1..30
    final tithiEnd = _findAngle(jdRise, (jd) => _elongation(jd), tithiNum * 12.0, 12.2);
    final paksha = tithiNum <= 15 ? 'Shukla' : 'Krishna';
    final tithiName = tithiNum == 15
        ? 'Purnima'
        : tithiNum == 30
        ? 'Amavasya'
        : tithiNames[(tithiNum - 1) % 15];

    // Nakshatra of the Moon.
    final nakIdx = (moonSid / Nakshatra.span).floor() % 27;
    final nakEnd = Ephemeris.moonCrossing(norm360((nakIdx + 1) * Nakshatra.span), jdRise, ayanamsa: ayanamsa);

    // Yoga: sum of sidereal Sun and Moon, in 13°20' steps.
    final yogaIdx = (norm360(sunSid + moonSid) / Nakshatra.span).floor() % 27;
    final yogaEnd = _findAngle(jdRise, (jd) => _yogaSum(jd, ayanamsa), (yogaIdx + 1) * Nakshatra.span, 13.2);

    // Karana: half of a tithi.
    final karanaNum = (elong / 6).floor() + 1; // 1..60
    final karanaEnd = _findAngle(jdRise, (jd) => _elongation(jd), karanaNum * 6.0, 12.2);

    // Weekday of the sunrise (local).
    final localRise = dt(jdRise).add(utcOffset);
    final vara = localRise.weekday % 7; // DateTime: Mon=1..Sun=7 -> Sun=0

    final dayLen = jdSet - jdRise;
    final nightLen = jdNextRise - jdSet;
    TimeSpan part(double base, double len, int idx, int parts, String label, {bool? good}) =>
        TimeSpan(dt(base + len * idx / parts), dt(base + len * (idx + 1) / parts), label, good: good);

    const rahuPart = [7, 1, 6, 4, 5, 3, 2];
    const yamaPart = [4, 3, 2, 1, 0, 6, 5];
    const gulikaPart = [6, 5, 4, 3, 2, 1, 0];

    // Abhijit: 8th of 15 daytime muhurtas. Traditionally not used on Wednesday.
    final abhijit = vara == 3 ? null : part(jdRise, dayLen, 7, 15, 'Abhijit', good: true);

    const dayCycle = [
      ChoghadiyaKind.udveg,
      ChoghadiyaKind.char,
      ChoghadiyaKind.labh,
      ChoghadiyaKind.amrit,
      ChoghadiyaKind.kaal,
      ChoghadiyaKind.shubh,
      ChoghadiyaKind.rog,
    ];
    const dayStart = [0, 3, 6, 2, 5, 1, 4]; // index into dayCycle per weekday
    const nightCycle = [
      ChoghadiyaKind.shubh,
      ChoghadiyaKind.amrit,
      ChoghadiyaKind.char,
      ChoghadiyaKind.rog,
      ChoghadiyaKind.kaal,
      ChoghadiyaKind.labh,
      ChoghadiyaKind.udveg,
    ];
    const nightStart = [0, 2, 4, 6, 1, 3, 5];

    final dayChog = [
      for (var i = 0; i < 8; i++)
        () {
          final k = dayCycle[(dayStart[vara] + i) % 7];
          return part(jdRise, dayLen, i, 8, k.label, good: k.auspicious);
        }(),
    ];
    final nightChog = [
      for (var i = 0; i < 8; i++)
        () {
          final k = nightCycle[(nightStart[vara] + i) % 7];
          return part(jdSet, nightLen, i, 8, k.label, good: k.auspicious);
        }(),
    ];

    // Horas follow the Chaldean order starting with the weekday lord.
    const chaldean = [
      Planet.sun,
      Planet.venus,
      Planet.mercury,
      Planet.moon,
      Planet.saturn,
      Planet.jupiter,
      Planet.mars,
    ];
    final firstHora = chaldean.indexOf(varaLords[vara]);
    final horas = <TimeSpan>[
      for (var i = 0; i < 24; i++)
        i < 12
            ? part(jdRise, dayLen, i, 12, chaldean[(firstHora + i) % 7].name)
            : part(jdSet, nightLen, i - 12, 12, chaldean[(firstHora + i) % 7].name),
    ];

    final month = _lunarMonth(jdRise, ayanamsa, tithiNum);
    final gregYear = localRise.year;
    // Vikram Samvat (Chaitradi) changes at Chaitra Shukla Pratipada, which
    // falls in March or April.
    final newYearPassed = localRise.month >= 5 || (localRise.month >= 3 && month.amantaIndex <= 1 && !month.adhika);
    final vikram = gregYear + (newYearPassed ? 57 : 56);

    return Panchang(
      date: DateTime(date.year, date.month, date.day),
      sunrise: dt(jdRise),
      sunset: dt(jdSet),
      nextSunrise: dt(jdNextRise),
      moonrise: moonRise == null || moonRise > jd0 + 1 ? null : dt(moonRise),
      moonset: moonSet == null || moonSet > jd0 + 1 ? null : dt(moonSet),
      vara: vara,
      tithi: PanchangElement(tithiNum, tithiName, dt(tithiEnd)),
      paksha: paksha,
      nakshatra: PanchangElement(nakIdx, Nakshatra.all[nakIdx].name, dt(nakEnd)),
      yoga: PanchangElement(yogaIdx, yogaNames[yogaIdx], dt(yogaEnd)),
      karana: PanchangElement(karanaNum, karanaName(karanaNum), dt(karanaEnd)),
      moonSign: Sign.fromLongitude(moonSid),
      sunSign: Sign.fromLongitude(sunSid),
      lunarMonthAmanta: (month.adhika ? 'Adhika ' : '') + lunarMonthNames[month.amantaIndex],
      lunarMonthPurnimanta: lunarMonthNames[month.purnimantaIndex],
      isAdhikaMasa: month.adhika,
      vikramSamvat: vikram,
      shakaSamvat: vikram - 135,
      rahuKaal: part(jdRise, dayLen, rahuPart[vara], 8, 'Rahu Kaal', good: false),
      yamaganda: part(jdRise, dayLen, yamaPart[vara], 8, 'Yamaganda', good: false),
      gulika: part(jdRise, dayLen, gulikaPart[vara], 8, 'Gulika Kaal', good: false),
      abhijit: abhijit,
      dayChoghadiya: dayChog,
      nightChoghadiya: nightChog,
      horas: horas,
    );
  }

  static double _elongation(double jd) =>
      norm360(Ephemeris.position(jd, Planet.moon).longitude - Ephemeris.position(jd, Planet.sun).longitude);

  static double _yogaSum(double jd, Ayanamsa a) => norm360(
    Ephemeris.position(jd, Planet.moon, ayanamsa: a).longitude +
        Ephemeris.position(jd, Planet.sun, ayanamsa: a).longitude,
  );

  /// Finds when an increasing angle function reaches [target] after [jd].
  /// [rate] is the approximate speed in degrees/day.
  static double _findAngle(double jd, double Function(double) f, double target, double rate) {
    target = norm360(target);
    var t = jd;
    for (var i = 0; i < 30; i++) {
      final diff = norm360(target - f(t) + 180) - 180; // -180..180
      if (diff.abs() < 1e-7) break;
      t += diff / rate;
    }
    return t;
  }

  /// Amanta month: named after the sidereal sign the Sun occupies at the new
  /// moon that starts it (Sun in Pisces at new moon -> Chaitra).
  static ({int amantaIndex, int purnimantaIndex, bool adhika}) _lunarMonth(double jd, Ayanamsa a, int tithiNum) {
    final elong = _elongation(jd);
    final prevNewMoon = _findAngle(jd - elong / 12.2, _elongation, 0, 12.2);
    final nextNewMoon = _findAngle(prevNewMoon + 29.0, _elongation, 0, 12.2);
    final s1 = Sign.fromLongitude(Ephemeris.position(prevNewMoon, Planet.sun, ayanamsa: a).longitude);
    final s2 = Sign.fromLongitude(Ephemeris.position(nextNewMoon, Planet.sun, ayanamsa: a).longitude);
    final amanta = (s1.index + 1) % 12;
    // No sankranti between the two new moons -> adhika (extra) month.
    final adhika = s1 == s2;
    // Purnimanta: the Krishna paksha belongs to the following month.
    final purnimanta = tithiNum > 15 ? (amanta + 1) % 12 : amanta;
    return (amantaIndex: amanta, purnimantaIndex: purnimanta, adhika: adhika);
  }
}
