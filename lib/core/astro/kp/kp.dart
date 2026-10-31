import '../chart.dart';
import '../constants.dart';
import '../ephemeris.dart';
import '../settings.dart';
import '../vedic/dasha.dart';

/// Krishnamurti Paddhati (KP) calculations.
///
/// Each nakshatra (13°20') is divided among the nine Vimshottari lords in
/// proportion to their dasha years, starting from the nakshatra lord. Each sub
/// is divided again the same way, starting from the sub lord (sub-sub).
class KpLords {
  const KpLords({required this.signLord, required this.starLord, required this.subLord, required this.subSubLord});

  final Planet signLord;
  final Planet starLord;
  final Planet subLord;
  final Planet subSubLord;

  @override
  String toString() => 'KpLords(${signLord.abbr}/${starLord.abbr}/${subLord.abbr}/${subSubLord.abbr})';
}

/// Default KP calculation settings: KP ayanamsa, Placidus cusps, mean node.
const kpSettings = CalcSettings(
  system: AstroSystem.vedic,
  ayanamsa: Ayanamsa.kp,
  vedicHouses: HouseSystem.placidusKp,
  nodeType: NodeType.mean,
);

const _order = Vimshottari.order;
const _years = Vimshottari.years;

/// Splits [span] degrees starting at lord [first] into the nine Vimshottari
/// proportions and returns (lord, offsetWithinSpan) of the part containing
/// [offset].
(Planet, double, double) _divide(double span, Planet first, double offset) {
  final startIdx = _order.indexOf(first);
  var acc = 0.0;
  for (var i = 0; i < 9; i++) {
    final lord = _order[(startIdx + i) % 9];
    final len = span * _years[lord]! / Vimshottari.total;
    if (offset < acc + len || i == 8) {
      return (lord, offset - acc, len);
    }
    acc += len;
  }
  throw StateError('unreachable');
}

/// Sign, star, sub and sub-sub lords of a sidereal longitude.
KpLords subLordsOf(double siderealLon) {
  final lon = norm360(siderealLon);
  final nak = Nakshatra.fromLongitude(lon);
  final inNak = lon % Nakshatra.span;
  final (sub, inSub, subLen) = _divide(Nakshatra.span, nak.lord, inNak);
  final (subSub, _, _) = _divide(subLen, sub, inSub);
  return KpLords(signLord: Sign.fromLongitude(lon).lord, starLord: nak.lord, subLord: sub, subSubLord: subSub);
}

/// One of the 249 KP horary divisions.
class KpHoraryDivision {
  const KpHoraryDivision(this.number, this.start, this.end, this.lords);
  final int number; // 1..249
  final double start;
  final double end;
  final KpLords lords;
}

List<KpHoraryDivision>? _horaryCache;

/// The 249 horary divisions: the 243 subs (27 × 9), with the six subs that
/// cross a sign boundary split in two.
List<KpHoraryDivision> kpHoraryTable() {
  final cached = _horaryCache;
  if (cached != null) return cached;
  final out = <KpHoraryDivision>[];
  for (var n = 0; n < 27; n++) {
    final nakStart = n * Nakshatra.span;
    final first = Nakshatra.all[n].lord;
    final startIdx = _order.indexOf(first);
    var start = nakStart;
    for (var i = 0; i < 9; i++) {
      final lord = _order[(startIdx + i) % 9];
      final end = i == 8 ? nakStart + Nakshatra.span : start + Nakshatra.span * _years[lord]! / 120;
      // Split at a sign boundary falling strictly inside the sub.
      final boundary = ((start / 30).floor() + 1) * 30.0;
      final pieces = boundary < end - 1e-9 && boundary > start + 1e-9
          ? [(start, boundary), (boundary, end)]
          : [(start, end)];
      for (final (s, e) in pieces) {
        out.add(KpHoraryDivision(out.length + 1, s, e, subLordsOf((s + e) / 2)));
      }
      start = end;
    }
  }
  return _horaryCache = out;
}

/// Starting sidereal longitude of KP horary number [n] (1..249).
double kpHoraryStart(int n) {
  if (n < 1 || n > 249) throw RangeError.range(n, 1, 249, 'n');
  return kpHoraryTable()[n - 1].start;
}

class KpCusp {
  const KpCusp(this.house, this.longitude, this.lords);
  final int house; // 1..12
  final double longitude;
  final KpLords lords;
  Sign get sign => Sign.fromLongitude(longitude);
}

/// Cusp table for a chart cast with Placidus cusps (ideally [kpSettings]).
List<KpCusp> kpCusps(Chart chart) {
  final cusps = chart.cusps;
  if (cusps == null) return const [];
  return [for (var i = 0; i < 12; i++) KpCusp(i + 1, cusps[i], subLordsOf(cusps[i]))];
}

/// Planet table: lords for every planet in the chart.
Map<Planet, KpLords> kpPlanetLords(Chart chart) => {
  for (final p in chart.planets.values) p.planet: subLordsOf(p.longitude),
};

/// House significators in the four classical KP levels (strongest first).
class KpHouseSignificators {
  const KpHouseSignificators({
    required this.house,
    required this.inStarOfOccupants,
    required this.occupants,
    required this.inStarOfLord,
    required this.lord,
  });

  final int house;

  /// Level 1: planets in the nakshatra of the occupants.
  final List<Planet> inStarOfOccupants;

  /// Level 2: planets occupying the house.
  final List<Planet> occupants;

  /// Level 3: planets in the nakshatra of the house lord.
  final List<Planet> inStarOfLord;

  /// Level 4: the house lord (sign lord of the cusp).
  final Planet lord;

  /// All significators, strongest level first, without duplicates.
  List<Planet> get all {
    final seen = <Planet>{};
    return [
      for (final p in [...inStarOfOccupants, ...occupants, ...inStarOfLord, lord])
        if (seen.add(p)) p,
    ];
  }
}

/// Four-level significators of each house.
///
/// Rahu and Ketu additionally act as agents: a node signifies the houses its
/// sign lord and the planets conjunct it (same sign) signify as occupant or
/// owner (levels 2 and 4). Those node agencies are merged into the level-2
/// list of the house so they appear among the significators.
List<KpHouseSignificators> kpSignificators(Chart chart) {
  if (!chart.hasHouses) return const [];
  final star = {for (final p in chart.planets.values) p.planet: p.nakshatra.lord};
  final lords = [for (var h = 1; h <= 12; h++) chart.houseLord(h)!];

  // Houses each planet occupies or owns (levels 2 and 4).
  Set<int> directHouses(Planet p) => {
    if (chart.planets[p]?.house != null) chart.planets[p]!.house!,
    for (var h = 1; h <= 12; h++)
      if (lords[h - 1] == p) h,
  };

  final nodeAgency = <Planet, Set<int>>{};
  for (final node in [Planet.rahu, Planet.ketu]) {
    final np = chart.planets[node];
    if (np == null) continue;
    final agents = <Planet>{np.sign.lord, for (final c in chart.inSign(np.sign)) c.planet}..remove(node);
    nodeAgency[node] = {for (final a in agents) ...directHouses(a)};
  }

  List<Planet> inStarOf(Iterable<Planet> of) => [
    for (final p in chart.planets.keys)
      if (of.contains(star[p])) p,
  ];

  return [
    for (var h = 1; h <= 12; h++)
      () {
        final occupants = [
          for (final p in chart.inHouse(h)) p.planet,
          for (final e in nodeAgency.entries)
            if (e.value.contains(h) && chart.planets[e.key]!.house != h) e.key,
        ];
        final realOccupants = chart.inHouse(h).map((p) => p.planet);
        return KpHouseSignificators(
          house: h,
          inStarOfOccupants: inStarOf(realOccupants),
          occupants: occupants,
          inStarOfLord: inStarOf([lords[h - 1]]),
          lord: lords[h - 1],
        );
      }(),
  ];
}

class KpRulingPlanets {
  const KpRulingPlanets({
    required this.ascendantSignLord,
    required this.ascendantStarLord,
    required this.ascendantSubLord,
    required this.moonSignLord,
    required this.moonStarLord,
    required this.dayLord,
  });

  final Planet ascendantSignLord;
  final Planet ascendantStarLord;
  final Planet ascendantSubLord;
  final Planet moonSignLord;
  final Planet moonStarLord;

  /// Lord of the weekday, which in Vedic reckoning starts at sunrise.
  final Planet dayLord;

  List<Planet> get all {
    final seen = <Planet>{};
    return [
      for (final p in [ascendantSubLord, ascendantStarLord, ascendantSignLord, moonStarLord, moonSignLord, dayLord])
        if (seen.add(p)) p,
    ];
  }
}

const _weekdayLords = [
  Planet.sun,
  Planet.moon,
  Planet.mars,
  Planet.mercury,
  Planet.jupiter,
  Planet.venus,
  Planet.saturn,
];

/// Ruling planets at [utc] for a place.
KpRulingPlanets kpRulingPlanets(DateTime utc, double latitude, double longitude, {CalcSettings settings = kpSettings}) {
  final chart = ChartCalculator.cast(utc: utc, settings: settings, latitude: latitude, longitude: longitude);
  final asc = subLordsOf(chart.ascendant!);
  final moon = subLordsOf(chart.moon.longitude);

  // Day lord: weekday of the most recent sunrise, in local mean time.
  final jd = chart.jd;
  var rise = Ephemeris.riseSet(jd - 1, Planet.sun, latitude, longitude, rise: true);
  if (rise != null) {
    final next = Ephemeris.riseSet(rise + 0.01, Planet.sun, latitude, longitude, rise: true);
    if (next != null && next <= jd) rise = next;
  }
  final riseUtc = rise == null ? utc : Ephemeris.dateTimeFromJd(rise);
  final lmt = riseUtc.add(Duration(minutes: (longitude * 4).round()));
  final dayLord = _weekdayLords[lmt.weekday % 7];

  return KpRulingPlanets(
    ascendantSignLord: asc.signLord,
    ascendantStarLord: asc.starLord,
    ascendantSubLord: asc.subLord,
    moonSignLord: moon.signLord,
    moonStarLord: moon.starLord,
    dayLord: dayLord,
  );
}
