import '../chart.dart';
import '../constants.dart';
import 'divisional.dart';

/// Jaimini astrology: chara karakas, arudha padas and Chara dasha.
class Jaimini {
  Jaimini._();

  static const karakaNames7 = [
    'Atmakaraka',
    'Amatyakaraka',
    'Bhratrikaraka',
    'Matrikaraka',
    'Putrakaraka',
    'Gnatikaraka',
    'Darakaraka',
  ];
  static const karakaNames8 = [
    'Atmakaraka',
    'Amatyakaraka',
    'Bhratrikaraka',
    'Matrikaraka',
    'Pitrikaraka',
    'Putrakaraka',
    'Gnatikaraka',
    'Darakaraka',
  ];
  static const karakaAbbr7 = ['AK', 'AmK', 'BK', 'MK', 'PK', 'GK', 'DK'];
  static const karakaAbbr8 = ['AK', 'AmK', 'BK', 'MK', 'PiK', 'PK', 'GK', 'DK'];

  /// Chara karakas ordered by degree within the sign, highest first.
  /// With [eight] = true Rahu is included and its degree is counted
  /// backwards (30° minus its degree), as Rahu moves in reverse.
  static List<Karaka> charaKarakas(Chart chart, {bool eight = false}) {
    final candidates = [
      Planet.sun,
      Planet.moon,
      Planet.mars,
      Planet.mercury,
      Planet.jupiter,
      Planet.venus,
      Planet.saturn,
      if (eight) Planet.rahu,
    ];
    double deg(Planet p) {
      final d = chart[p].degreeInSign;
      return p == Planet.rahu ? 30 - d : d;
    }

    final sorted = [...candidates]..sort((a, b) => deg(b).compareTo(deg(a)));
    final names = eight ? karakaNames8 : karakaNames7;
    final abbr = eight ? karakaAbbr8 : karakaAbbr7;
    return [
      for (var i = 0; i < sorted.length; i++)
        Karaka(name: names[i], abbr: abbr[i], planet: sorted[i], degree: deg(sorted[i])),
    ];
  }

  /// Karakamsa: navamsa sign of the Atmakaraka.
  static Sign karakamsa(Chart chart, {bool eight = false}) =>
      Varga.d9.signOf(chart[charaKarakas(chart, eight: eight).first.planet].longitude);

  /// Lord used for a sign. Scorpio and Aquarius have two lords (Mars/Ketu and
  /// Saturn/Rahu); the stronger is chosen by the common first rules:
  /// 1. if one lord occupies the sign, the other is used;
  /// 2. otherwise the lord conjoined with more planets;
  /// 3. otherwise the lord with the higher degree in its sign.
  static Planet lordOf(Chart chart, Sign sign) {
    final pair = switch (sign) {
      Sign.scorpio => (Planet.mars, Planet.ketu),
      Sign.aquarius => (Planet.saturn, Planet.rahu),
      _ => null,
    };
    if (pair == null) return sign.lord;
    final (a, b) = pair;
    final aIn = chart[a].sign == sign, bIn = chart[b].sign == sign;
    if (aIn && !bIn) return b;
    if (bIn && !aIn) return a;
    int company(Planet p) => chart.inSign(chart[p].sign).length - 1;
    if (company(a) != company(b)) return company(a) > company(b) ? a : b;
    return chart[a].degreeInSign >= chart[b].degreeInSign ? a : b;
  }

  /// Arudha pada of the [house]-th sign from the Lagna (1..12).
  ///
  /// Count from the sign to its lord, then the same count from the lord.
  /// If the result is the sign itself or the 7th from it, the 10th from the
  /// result is taken instead (the standard exception).
  static Sign arudha(Chart chart, int house) {
    final sign = chart.ascendantSign! + (house - 1);
    return arudhaOfSign(chart, sign);
  }

  static Sign arudhaOfSign(Chart chart, Sign sign) {
    final lordSign = chart[lordOf(chart, sign)].sign;
    final n = sign.countTo(lordSign);
    var pada = lordSign + (n - 1);
    final fromSign = sign.countTo(pada);
    if (fromSign == 1 || fromSign == 7) pada = pada + 9;
    return pada;
  }

  /// All twelve padas; index 0 = Arudha Lagna (AL), index 11 = Upapada (UL).
  static List<Sign> arudhas(Chart chart) => [for (var h = 1; h <= 12; h++) arudha(chart, h)];

  static const _savya = {Sign.aries, Sign.taurus, Sign.gemini, Sign.libra, Sign.scorpio, Sign.sagittarius};

  /// Signs counted forwards (savya) or backwards (apasavya) for dasha years.
  static bool isSavya(Sign s) => _savya.contains(s);

  /// Chara dasha years of a sign (K.N. Rao's method): count from the sign to
  /// its lord (forwards for savya signs, backwards otherwise) and subtract 1.
  /// A lord in its own sign gives 12 years. With [dignityAdjust], one year is
  /// added for an exalted lord and removed for a debilitated lord.
  static int charaYears(Chart chart, Sign sign, {bool dignityAdjust = true}) {
    final lord = lordOf(chart, sign);
    final lordSign = chart[lord].sign;
    final count = isSavya(sign) ? sign.countTo(lordSign) : lordSign.countTo(sign);
    var years = count - 1;
    if (years == 0) years = 12;
    if (dignityAdjust && !lord.isNode) {
      if (Dignity.exaltationSign(lord) == lordSign) years += 1;
      if (Dignity.debilitationSign(lord) == lordSign) years -= 1;
    }
    return years.clamp(1, 12);
  }

  /// Chara dasha sequence starting from the Lagna sign. The direction follows
  /// the 9th sign from the Lagna: savya → zodiacal, otherwise reverse. The
  /// second cycle uses 12 minus the first-cycle years.
  static List<CharaDashaPeriod> charaDasha(Chart chart, DateTime birthUtc, {int cycles = 2}) {
    final lagna = chart.ascendantSign!;
    final forward = isSavya(lagna + 8);
    final out = <CharaDashaPeriod>[];
    var start = birthUtc;
    for (var c = 0; c < cycles; c++) {
      for (var i = 0; i < 12; i++) {
        final sign = forward ? lagna + i : lagna + (12 - i) % 12;
        final first = charaYears(chart, sign);
        // Both cycles together give each sign 12 years; a sign that had 12
        // years in the first cycle is skipped in the second.
        final years = c == 0 ? first : 12 - first;
        if (years == 0) continue;
        final end = start.add(Duration(microseconds: (years * 365.25 * Duration.microsecondsPerDay).round()));
        out.add(CharaDashaPeriod(sign: sign, years: years, start: start, end: end));
        start = end;
      }
    }
    return out;
  }
}

class Karaka {
  const Karaka({required this.name, required this.abbr, required this.planet, required this.degree});
  final String name;
  final String abbr;
  final Planet planet;

  /// Degree used for ranking (reversed for Rahu).
  final double degree;
}

class CharaDashaPeriod {
  const CharaDashaPeriod({required this.sign, required this.years, required this.start, required this.end});
  final Sign sign;
  final int years;
  final DateTime start;
  final DateTime end;
  bool contains(DateTime t) => !t.isBefore(start) && t.isBefore(end);
}
