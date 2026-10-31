import '../constants.dart';

/// One dasha period (any level).
class DashaPeriod {
  DashaPeriod({
    required this.lord,
    required this.start,
    required this.end,
    required this.level,
    this.label,
    this.parent,
  });

  final Planet lord;

  /// Display label, e.g. a Yogini name. Defaults to the lord's name.
  final String? label;
  final DateTime start;
  final DateTime end;

  /// 1 = Mahadasha, 2 = Antardasha, 3 = Pratyantardasha ...
  final int level;
  final DashaPeriod? parent;

  bool contains(DateTime t) => !t.isBefore(start) && t.isBefore(end);
  Duration get length => end.difference(start);
}

abstract class DashaSystem {
  String get name;
  String get description;

  /// Mahadashas covering roughly [years] years from birth.
  List<DashaPeriod> mahadashas(DateTime birthUtc, double moonLongitude);

  /// Sub-periods of [parent] (one level deeper).
  List<DashaPeriod> subPeriods(DashaPeriod parent);

  /// Chain of running periods at [at], from Mahadasha down to [depth].
  List<DashaPeriod> runningAt(DateTime birthUtc, double moonLongitude, DateTime at, {int depth = 3}) {
    final chain = <DashaPeriod>[];
    var level = mahadashas(birthUtc, moonLongitude);
    for (var d = 0; d < depth; d++) {
      final current = level.where((p) => p.contains(at)).firstOrNull;
      if (current == null) break;
      chain.add(current);
      level = subPeriods(current);
    }
    return chain;
  }

  /// Periods [depth] levels deep (3 = Pratyantardasha) that overlap
  /// [from, to), in time order: what runs in a given month.
  List<DashaPeriod> between(DateTime birthUtc, double moonLongitude, DateTime from, DateTime to, {int depth = 3}) {
    bool overlaps(DashaPeriod p) => p.end.isAfter(from) && p.start.isBefore(to);
    var level = mahadashas(birthUtc, moonLongitude).where(overlaps).toList();
    for (var d = 1; d < depth; d++) {
      level = [for (final p in level) ...subPeriods(p).where(overlaps)];
    }
    return level;
  }

  /// The next [count] periods at [level] (1 Mahadasha, 2 Antardasha,
  /// 3 Pratyantardasha) that start after [at].
  List<DashaPeriod> upcoming(DateTime birthUtc, double moonLongitude, DateTime at, {int level = 2, int count = 2}) {
    var periods = mahadashas(birthUtc, moonLongitude).where((m) => m.end.isAfter(at)).take(count + 1).toList();
    for (var d = 1; d < level; d++) {
      periods = [
        for (final p in periods)
          if (p.end.isAfter(at)) ...subPeriods(p),
      ];
    }
    return periods.where((p) => p.start.isAfter(at)).take(count).toList();
  }
}

/// Length of a dasha year in days. 365.25 (Julian year) is the most common
/// convention in Indian software.
const dashaYearDays = 365.25;

Duration _years(double y) => Duration(microseconds: (y * dashaYearDays * Duration.microsecondsPerDay).round());

/// Vimshottari dasha (120 years), BPHS ch. 46.
class Vimshottari extends DashaSystem {
  @override
  String get name => 'Vimshottari';
  @override
  String get description =>
      'The most widely used dasha system (BPHS). A 120-year cycle of nine planetary periods starting from the Moon\'s nakshatra at birth.';

  static const order = [
    Planet.ketu,
    Planet.venus,
    Planet.sun,
    Planet.moon,
    Planet.mars,
    Planet.rahu,
    Planet.jupiter,
    Planet.saturn,
    Planet.mercury,
  ];
  static const years = {
    Planet.ketu: 7.0,
    Planet.venus: 20.0,
    Planet.sun: 6.0,
    Planet.moon: 10.0,
    Planet.mars: 7.0,
    Planet.rahu: 18.0,
    Planet.jupiter: 16.0,
    Planet.saturn: 19.0,
    Planet.mercury: 17.0,
  };
  static const total = 120.0;

  @override
  List<DashaPeriod> mahadashas(DateTime birthUtc, double moonLongitude) {
    final nak = Nakshatra.fromLongitude(moonLongitude);
    final traversed = (norm360(moonLongitude) % Nakshatra.span) / Nakshatra.span;
    final startIdx = order.indexOf(nak.lord);
    final firstYears = years[nak.lord]!;

    // The first dasha started before birth by the traversed fraction.
    var start = birthUtc.subtract(_years(firstYears * traversed));
    final periods = <DashaPeriod>[];
    for (var i = 0; i < 9 * 2; i++) {
      final lord = order[(startIdx + i) % 9];
      final end = start.add(_years(years[lord]!));
      periods.add(DashaPeriod(lord: lord, start: start, end: end, level: 1));
      start = end;
    }
    return periods;
  }

  @override
  List<DashaPeriod> subPeriods(DashaPeriod parent) {
    final startIdx = order.indexOf(parent.lord);
    final parentMicros = parent.length.inMicroseconds;
    var start = parent.start;
    final out = <DashaPeriod>[];
    for (var i = 0; i < 9; i++) {
      final lord = order[(startIdx + i) % 9];
      final end = i == 8
          ? parent.end
          : start.add(Duration(microseconds: (parentMicros * years[lord]! / total).round()));
      out.add(DashaPeriod(lord: lord, start: start, end: end, level: parent.level + 1, parent: parent));
      start = end;
    }
    return out;
  }
}

/// Yogini dasha (36 years).
class YoginiDasha extends DashaSystem {
  @override
  String get name => 'Yogini';
  @override
  String get description =>
      'A 36-year cycle of eight Yoginis, each ruled by a planet. Popular in North India for timing events.';

  static const yoginis = [
    ('Mangala', Planet.moon, 1.0),
    ('Pingala', Planet.sun, 2.0),
    ('Dhanya', Planet.jupiter, 3.0),
    ('Bhramari', Planet.mars, 4.0),
    ('Bhadrika', Planet.mercury, 5.0),
    ('Ulka', Planet.saturn, 6.0),
    ('Siddha', Planet.venus, 7.0),
    ('Sankata', Planet.rahu, 8.0),
  ];
  static const total = 36.0;

  int _indexOfLabel(String? label) => yoginis.indexWhere((y) => y.$1 == label);

  @override
  List<DashaPeriod> mahadashas(DateTime birthUtc, double moonLongitude) {
    final nak = Nakshatra.fromLongitude(moonLongitude);
    // (nakshatra number + 3) mod 8, with remainder 0 meaning the 8th yogini.
    final startIdx = ((nak.index + 1 + 3) % 8 + 7) % 8;
    final traversed = (norm360(moonLongitude) % Nakshatra.span) / Nakshatra.span;
    final first = yoginis[startIdx];
    var start = birthUtc.subtract(_years(first.$3 * traversed));
    final out = <DashaPeriod>[];
    for (var i = 0; i < 8 * 4; i++) {
      final y = yoginis[(startIdx + i) % 8];
      final end = start.add(_years(y.$3));
      out.add(DashaPeriod(lord: y.$2, label: y.$1, start: start, end: end, level: 1));
      start = end;
    }
    return out;
  }

  @override
  List<DashaPeriod> subPeriods(DashaPeriod parent) {
    final startIdx = _indexOfLabel(parent.label);
    final micros = parent.length.inMicroseconds;
    var start = parent.start;
    final out = <DashaPeriod>[];
    for (var i = 0; i < 8; i++) {
      final y = yoginis[(startIdx + i) % 8];
      final end = i == 7 ? parent.end : start.add(Duration(microseconds: (micros * y.$3 / total).round()));
      out.add(DashaPeriod(lord: y.$2, label: y.$1, start: start, end: end, level: parent.level + 1, parent: parent));
      start = end;
    }
    return out;
  }
}
