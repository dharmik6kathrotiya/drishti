import '../astro/chart.dart';
import '../astro/constants.dart';
import '../astro/ephemeris.dart';
import '../astro/settings.dart';
import '../astro/vedic/panchang.dart';
import '../models/profile.dart';
import 'interpretations.dart';
import 'sky_events.dart';
import 'transit_engine.dart';

enum HoroscopePeriod { daily, weekly, monthly, yearly }

enum LifeArea { career, money, love, health, mind }

enum ReasonKind { gochara, tara, aspect, event, approximation }

/// The factual basis behind a statement in the reading.
class Reason {
  const Reason(this.kind, this.text, {this.weight = 0});
  final ReasonKind kind;
  final String text;

  /// Signed influence used for ranking (positive = supportive).
  final double weight;
}

class HoroscopeSection {
  const HoroscopeSection({
    required this.area,
    required this.title,
    required this.score,
    required this.text,
    required this.reasons,
  });

  final LifeArea area;
  final String title;

  /// 1 (challenging) .. 5 (very favourable).
  final int score;
  final String text;
  final List<Reason> reasons;
}

/// Traditional weekday associations; shown as customs, not promises.
class LuckyInfo {
  const LuckyInfo({
    required this.planet,
    required this.color,
    required this.number,
    required this.note,
    this.timeWindow,
    this.windowStartUtc,
    this.windowEndUtc,
  });

  final Planet planet;
  final String color;
  final int number;
  final String note;
  final String? timeWindow;
  final DateTime? windowStartUtc;
  final DateTime? windowEndUtc;
}

class Horoscope {
  const Horoscope({
    required this.subjectId,
    required this.period,
    required this.start,
    required this.end,
    required this.system,
    required this.overallScore,
    required this.summary,
    required this.sections,
    required this.keyEvents,
    required this.reasons,
    required this.why,
    required this.approximate,
    required this.signOnly,
    this.lucky,
  });

  final String subjectId;
  final HoroscopePeriod period;

  /// Local calendar range [start, end).
  final DateTime start;
  final DateTime end;
  final AstroSystem system;
  final int overallScore;
  final String summary;
  final List<HoroscopeSection> sections;
  final List<String> keyEvents;

  /// All factual reasons behind the reading.
  final List<Reason> reasons;
  final String why;
  final bool approximate;
  final bool signOnly;
  final LuckyInfo? lucky;
}

/// Who the horoscope is for: a saved profile (any amount of data) or just a
/// sign chosen by the user.
class HoroscopeSubject {
  HoroscopeSubject.fromProfile(Profile this.profile) : id = profile.id, chosenSign = null;

  HoroscopeSubject.forSign(Sign this.chosenSign) : id = 'sign-${chosenSign.index}', profile = null;

  final String id;
  final Profile? profile;
  final Sign? chosenSign;

  /// Whether a reading is possible (a sign, or at least a birth date).
  bool get isUsable => chosenSign != null || (profile?.canCastMoonChart ?? false);

  NatalReference natalFor(CalcSettings settings) {
    final sign = chosenSign;
    if (sign != null) {
      return NatalReference(system: settings.system, moonSign: sign, sunSign: sign, signOnly: true);
    }
    final p = profile!;
    final utc = p.birthUtc();
    if (utc == null) {
      throw ArgumentError('Profile ${p.id} has no birth date; choose a sign instead.');
    }
    final vedic = settings.system == AstroSystem.vedic;
    final chart = ChartCalculator.cast(
      utc: utc,
      settings: settings,
      latitude: p.place?.latitude,
      longitude: p.place?.longitude,
      withHouses: p.canCastFullChart,
    );

    var moonApprox = false, nakApprox = false, sunApprox = false;
    if (!p.hasTime) {
      final offset = Duration(minutes: p.birthUtcOffsetMinutes() ?? 0);
      final d = p.birthDate!;
      final dayStart = DateTime.utc(d.year, d.month, d.day).subtract(offset);
      final dayEnd = dayStart.add(const Duration(hours: 23, minutes: 59, seconds: 59));
      final ayan = vedic ? settings.ayanamsa : null;
      double lon(DateTime t, Planet pl) => Ephemeris.position(Ephemeris.julianDay(t), pl, ayanamsa: ayan).longitude;
      moonApprox = Sign.fromLongitude(lon(dayStart, Planet.moon)) != Sign.fromLongitude(lon(dayEnd, Planet.moon));
      nakApprox =
          Nakshatra.fromLongitude(lon(dayStart, Planet.moon)).index !=
          Nakshatra.fromLongitude(lon(dayEnd, Planet.moon)).index;
      sunApprox = Sign.fromLongitude(lon(dayStart, Planet.sun)) != Sign.fromLongitude(lon(dayEnd, Planet.sun));
    }

    Map<Planet, double>? natalLons;
    if (!vedic) {
      natalLons = {
        for (final e in chart.planets.entries)
          if (!e.key.isNode && !(e.key == Planet.moon && moonApprox)) e.key: e.value.longitude,
      };
    }

    return NatalReference(
      system: settings.system,
      moonSign: chart.moon.sign,
      sunSign: chart.sun.sign,
      birthNakshatra: chart.moon.nakshatra,
      ascendantSign: chart.ascendantSign,
      natalLongitudes: natalLons,
      moonApproximate: moonApprox,
      nakshatraApproximate: nakApprox && vedic,
      sunApproximate: sunApprox && !vedic,
    );
  }
}

/// Generates a personal (or sign-based) horoscope for [date].
///
/// [utcOffset] is the user's current UTC offset (defaults to the offset of
/// [date]); [latitude]/[longitude] of the user's current location enable the
/// daily favourable time window.
Horoscope generate({
  required HoroscopeSubject subject,
  required HoroscopePeriod period,
  required DateTime date,
  required CalcSettings settings,
  Duration? utcOffset,
  double? latitude,
  double? longitude,
  String languageCode = 'en',
}) => HoroscopeGenerator(horoscopeTextsFor(languageCode)).generate(
  subject: subject,
  period: period,
  date: date,
  settings: settings,
  utcOffset: utcOffset,
  latitude: latitude,
  longitude: longitude,
);

class HoroscopeGenerator {
  HoroscopeGenerator(this.t);

  final HoroscopeTexts t;

  static const _planetArea = <Planet, List<double>>{
    // career, money, love, health, mind
    Planet.sun: [1, .4, .3, .8, .5],
    Planet.moon: [.3, .3, .6, .7, 1],
    Planet.mars: [.8, .4, .5, .9, .4],
    Planet.mercury: [.9, .8, .4, .3, .7],
    Planet.jupiter: [.8, 1, .7, .5, .7],
    Planet.venus: [.4, .8, 1, .4, .6],
    Planet.saturn: [.9, .7, .4, .8, .5],
    Planet.rahu: [.6, .6, .4, .4, .8],
    Planet.ketu: [.4, .4, .4, .6, .8],
    Planet.uranus: [.7, .5, .5, .3, .7],
    Planet.neptune: [.4, .3, .6, .5, .8],
    Planet.pluto: [.6, .6, .6, .4, .7],
  };

  static const _houseArea = <int, List<double>>{
    1: [.4, .2, .2, 1, .8],
    2: [.2, 1, .5, .3, .3],
    3: [.7, .3, .3, .4, .7],
    4: [.3, .3, .5, .5, 1],
    5: [.4, .5, 1, .3, .6],
    6: [.8, .3, .1, .9, .3],
    7: [.4, .4, 1, .3, .4],
    8: [.2, .6, .4, .8, .6],
    9: [.7, .5, .3, .3, .8],
    10: [1, .6, .2, .3, .4],
    11: [.7, 1, .5, .3, .5],
    12: [.2, .8, .4, .6, .7],
  };

  static const _taraArea = [.5, .5, .5, .6, 1.0];

  static double _periodWeight(HoroscopePeriod period, Planet p) {
    const daily = {
      Planet.moon: 3.0,
      Planet.sun: 1.0,
      Planet.mercury: 1.0,
      Planet.venus: 1.0,
      Planet.mars: 1.0,
      Planet.jupiter: .8,
      Planet.saturn: .8,
      Planet.rahu: .5,
      Planet.ketu: .5,
      Planet.uranus: .4,
      Planet.neptune: .4,
      Planet.pluto: .4,
    };
    const weekly = {
      Planet.moon: 1.2,
      Planet.sun: 1.0,
      Planet.mercury: 1.0,
      Planet.venus: 1.0,
      Planet.mars: 1.0,
      Planet.jupiter: 1.0,
      Planet.saturn: 1.0,
      Planet.rahu: .6,
      Planet.ketu: .6,
      Planet.uranus: .5,
      Planet.neptune: .5,
      Planet.pluto: .5,
    };
    const monthly = {
      Planet.moon: .3,
      Planet.sun: 1.2,
      Planet.mercury: 1.0,
      Planet.venus: 1.0,
      Planet.mars: 1.2,
      Planet.jupiter: 1.5,
      Planet.saturn: 1.5,
      Planet.rahu: 1.0,
      Planet.ketu: 1.0,
      Planet.uranus: 1.0,
      Planet.neptune: 1.0,
      Planet.pluto: 1.0,
    };
    const yearly = {
      Planet.moon: 0.0,
      Planet.sun: .2,
      Planet.mercury: .2,
      Planet.venus: .3,
      Planet.mars: .5,
      Planet.jupiter: 3.0,
      Planet.saturn: 3.0,
      Planet.rahu: 1.5,
      Planet.ketu: 1.5,
      Planet.uranus: 2.0,
      Planet.neptune: 2.0,
      Planet.pluto: 2.0,
    };
    return (switch (period) {
      HoroscopePeriod.daily => daily,
      HoroscopePeriod.weekly => weekly,
      HoroscopePeriod.monthly => monthly,
      HoroscopePeriod.yearly => yearly,
    })[p]!;
  }

  static double _taraWeight(HoroscopePeriod p) => switch (p) {
    HoroscopePeriod.daily => 2,
    HoroscopePeriod.weekly => .8,
    _ => 0,
  };

  static const _chaldeanNumber = {
    Planet.sun: 1,
    Planet.moon: 2,
    Planet.jupiter: 3,
    Planet.rahu: 4,
    Planet.mercury: 5,
    Planet.venus: 6,
    Planet.ketu: 7,
    Planet.saturn: 8,
    Planet.mars: 9,
  };

  Horoscope generate({
    required HoroscopeSubject subject,
    required HoroscopePeriod period,
    required DateTime date,
    required CalcSettings settings,
    Duration? utcOffset,
    double? latitude,
    double? longitude,
  }) {
    final offset = utcOffset ?? date.timeZoneOffset;
    final natal = subject.natalFor(settings);
    final vedic = settings.system == AstroSystem.vedic;
    final (start, end) = _range(period, date);
    final samples = _samples(period, start, end, offset);

    // ---- collect factors across samples
    final factors = <String, _Factor>{};
    for (final utc in samples) {
      final snap = TransitEngine.snapshot(natal, utc, settings);
      if (vedic) {
        for (final g in snap.gochara) {
          final state = g.favourable ? (g.obstructed ? 'v' : 'f') : 'u';
          final key = 'g:${g.planet.name}:${g.houseFromMoon}:$state';
          factors.putIfAbsent(key, () => _Factor.gochara(g)).count++;
        }
        final tara = snap.tara;
        if (tara != null && _taraWeight(period) > 0) {
          factors.putIfAbsent('t:${tara.tara}:${tara.transitNakshatra.index}', () => _Factor.tara(tara)).count++;
        }
      } else {
        for (final a in snap.aspects) {
          if (a.type == null && a.signDistance == null) continue;
          final key = 'a:${a.transiting.name}:${a.natal?.name}:${a.type?.name}:${a.signDistance}';
          factors.putIfAbsent(key, () => _Factor.aspect(a, snap.transitSigns[a.transiting]!)).count++;
        }
      }
    }
    final n = samples.length;

    // ---- area scores
    final areaRaw = <LifeArea, double>{};
    final areaContrib = <LifeArea, List<(_Factor, double)>>{};
    for (final area in LifeArea.values) {
      var sum = 0.0, norm = 0.0;
      final list = <(_Factor, double)>[];
      for (final f in factors.values) {
        final frac = f.count / n;
        final w = _weight(f, area, period) * frac;
        if (w == 0) continue;
        final c = f.polarity * w;
        sum += c;
        norm += w;
        list.add((f, c));
      }
      areaRaw[area] = norm == 0 ? 0 : sum / norm;
      list.sort((a, b) => b.$2.abs().compareTo(a.$2.abs()));
      areaContrib[area] = list;
    }

    int score(double raw) => (3 + raw * 3).round().clamp(1, 5);

    final periodWord = t.one('period.${period.name}');
    final startKey = _isoDate(start);
    final signNames = vedic ? 'rashi' : 'sign';
    String signName(Sign s) => t.one('$signNames.${s.index}');
    String planetName(Planet p) => (!vedic && p.isNode) ? t.one('planet.${p.name}.western') : t.one('planet.${p.name}');
    // Name with an article where the language needs one ("the Moon").
    String planetRef(Planet p) => t.own('planet.${p.name}.the') ?? planetName(p);

    String reasonOf(_Factor f) {
      final frac = f.count / n;
      final span = period == HoroscopePeriod.daily || frac > 0.999
          ? ''
          : t.one(frac > 0.5 ? 'reason.span.most' : 'reason.span.part');
      switch (f.kind) {
        case ReasonKind.gochara:
          final g = f.gochara!;
          final args = {
            'planet': planetRef(g.planet),
            'sign': signName(g.sign),
            'nth': t.one('ordinal.${g.houseFromMoon}'),
            'moonSign': signName(natal.moonSign),
          };
          var s = g.favourable
              ? (g.obstructed
                    ? t.one('reason.gochara.vedha', {
                        ...args,
                        'other': planetRef(g.obstructedBy!),
                        'vnth': t.one('ordinal.${g.vedhaHouse}'),
                      })
                    : t.one('reason.gochara.fav', args))
              : t.one('reason.gochara.unfav', args);
          final asc = g.houseFromAscendant;
          if (asc != null) s += t.one('reason.gochara.asc', {'nth': t.one('ordinal.$asc')});
          if (g.retrograde && !g.planet.isNode) {
            s += t.one('reason.retro', {'planet': planetRef(g.planet)});
          }
          return s + span;
        case ReasonKind.tara:
          final tb = f.tara!;
          return t.one('reason.tara', {
                'nakshatra': t.one('nakshatra.${tb.transitNakshatra.index}'),
                'count': t.one('ordinal.${tb.count}'),
                'birth': t.one('nakshatra.${tb.birthNakshatra.index}'),
                'tara': t.one('tara.name.${tb.tara}'),
                'text': t.one('tara.text.${tb.tara}'),
              }) +
              span;
        case ReasonKind.aspect:
          final a = f.aspect!;
          if (a.natal != null) {
            return t.one('reason.aspect', {
                  'planet': planetRef(a.transiting),
                  'aspect': t.one('aspect.${a.type!.name}'),
                  'natal': planetName(a.natal!),
                  'orb': a.orb!.toStringAsFixed(1),
                }) +
                span;
          }
          final key = a.type == null ? 'reason.signaspect.none' : 'reason.signaspect';
          return t.one(key, {
                'planet': planetRef(a.transiting),
                'sign': signName(f.sign!),
                'nth': t.one('ordinal.${a.signDistance}'),
                'sun': signName(natal.sunSign),
                'aspect': a.type == null ? '' : t.one('aspect.${a.type!.name}'),
              }) +
              span;
        default:
          return '';
      }
    }

    String sentenceOf(_Factor f, LifeArea area, int hash) {
      final pos = f.polarity >= 0 ? 'pos' : 'neg';
      switch (f.kind) {
        case ReasonKind.gochara:
          final g = f.gochara!;
          return t.pick('transit.vedic', hash, {
            'planet': planetRef(g.planet),
            'nth': t.one('ordinal.${g.houseFromMoon}'),
            'theme': t.one('house.${g.houseFromMoon}'),
            'effect': t.pick('fx.${g.planet.name}.${area.name}.$pos', hash >> 3),
          });
        case ReasonKind.tara:
          return t.one('tara.text.${f.tara!.tara}');
        case ReasonKind.aspect:
          final a = f.aspect!;
          final effect = t.pick('fx.${a.transiting.name}.${area.name}.$pos', hash >> 3);
          if (a.natal != null) {
            return t.pick('transit.western', hash, {
              'planet': planetRef(a.transiting),
              'aspectPhrase': t.one('aspect.phrase.${a.type!.name}'),
              'aspectGerund': t.one('aspect.gerund.${a.type!.name}'),
              'natal': planetName(a.natal!),
              'effect': effect,
            });
          }
          return t.pick('transit.solar', hash, {
            'planet': planetRef(a.transiting),
            'nth': t.one('ordinal.${a.signDistance}'),
            'theme': t.one('house.${a.signDistance}'),
            'effect': effect,
          });
        default:
          return '';
      }
    }

    // ---- sections
    final sections = <HoroscopeSection>[];
    for (final area in LifeArea.values) {
      final s = score(areaRaw[area]!);
      final hash = stableHash('${subject.id}|$startKey|${period.name}|${area.name}');
      final sentences = <String>[
        t.pick('opener.${area.name}.$s', hash, {'period': periodWord}),
      ];
      final contribs = areaContrib[area]!;
      final used = <Object>{};
      for (final (f, _) in contribs) {
        if (sentences.length >= 3) break;
        if (!used.add(f.identity)) continue;
        sentences.add(sentenceOf(f, area, hash + sentences.length));
      }
      final tone = s <= 2 ? 'low' : (s == 3 ? 'mid' : 'high');
      sentences.add(t.pick('advice.${area.name}.$tone', hash >> 5));

      final reasons = [for (final (f, c) in contribs.take(3)) Reason(f.kind, _capitalise(reasonOf(f)), weight: c)];
      sections.add(
        HoroscopeSection(
          area: area,
          title: t.one('area.${area.name}'),
          score: s,
          text: sentences.map(_capitalise).join(' '),
          reasons: reasons,
        ),
      );
    }

    // ---- overall
    final overallRaw = areaRaw.values.reduce((a, b) => a + b) / areaRaw.length;
    final overall = score(overallRaw);
    final hash = stableHash('${subject.id}|$startKey|${period.name}|overall');
    var summary = _capitalise(
      t.pick('overall.$overall', hash, {'period': periodWord, 'periodNoun': t.one('periodNoun.${period.name}')}),
    );
    if (period == HoroscopePeriod.daily) {
      final tara = factors.values.where((f) => f.kind == ReasonKind.tara).firstOrNull;
      if (tara != null) summary += ' ${t.one('tara.text.${tara.tara!.tara}')}';
    }

    // ---- key events
    final keyEvents = _events(period, start, end, offset, settings, signName, planetRef);

    // ---- reasons (all factual bases)
    final allReasons = <Reason>[
      if (natal.moonApproximate) Reason(ReasonKind.approximation, t.one('reason.approx.moon')),
      if (natal.nakshatraApproximate) Reason(ReasonKind.approximation, t.one('reason.approx.nakshatra')),
      if (natal.sunApproximate) Reason(ReasonKind.approximation, t.one('reason.approx.sun')),
    ];
    final ranked = factors.values.toList()
      ..sort((a, b) => (b.count * b.polarity.abs()).compareTo(a.count * a.polarity.abs()));
    for (final f in ranked) {
      allReasons.add(Reason(f.kind, _capitalise(reasonOf(f)), weight: f.polarity * f.count / n));
    }
    for (final e in keyEvents) {
      allReasons.add(Reason(ReasonKind.event, e));
    }

    // ---- why
    final usesTara = factors.values.any((f) => f.kind == ReasonKind.tara);
    var why = vedic
        ? t.one('why.vedic', {
            'period': periodWord,
            'moonSign': signName(natal.moonSign),
            'tara': usesTara ? t.one('why.tara') : '',
          })
        : t.one('why.western', {
            'period': periodWord,
            'target': natal.signOnly || natal.natalLongitudes == null
                ? t.one('why.target.sun', {'sun': signName(natal.sunSign)})
                : t.one('why.target.natal'),
          });
    if (natal.signOnly) why += t.one('why.sign', {'sign': signName(natal.moonSign)});
    if (natal.anyApproximate) why += t.one('why.approx');

    return Horoscope(
      subjectId: subject.id,
      period: period,
      start: start,
      end: end,
      system: settings.system,
      overallScore: overall,
      summary: summary,
      sections: sections,
      keyEvents: keyEvents,
      reasons: allReasons,
      why: why,
      approximate: natal.anyApproximate,
      signOnly: natal.signOnly,
      lucky: period == HoroscopePeriod.daily ? _lucky(start, offset, settings, latitude, longitude, planetRef) : null,
    );
  }

  double _weight(_Factor f, LifeArea area, HoroscopePeriod period) {
    final i = area.index;
    switch (f.kind) {
      case ReasonKind.gochara:
        final g = f.gochara!;
        final rel = .55 * _planetArea[g.planet]![i] + .45 * _houseArea[g.houseFromMoon]![i] + .1;
        return _periodWeight(period, g.planet) * rel;
      case ReasonKind.tara:
        return _taraWeight(period) * _taraArea[i];
      case ReasonKind.aspect:
        final a = f.aspect!;
        final second = a.natal != null ? _planetArea[a.natal!]![i] : _houseArea[a.signDistance!]![i];
        final rel = .55 * _planetArea[a.transiting]![i] + .45 * second + .1;
        // Natal aspects come and go quickly; tight orbs count fully.
        return _periodWeight(period, a.transiting) * rel;
      default:
        return 0;
    }
  }

  static (DateTime, DateTime) _range(HoroscopePeriod p, DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return switch (p) {
      HoroscopePeriod.daily => (d, DateTime(d.year, d.month, d.day + 1)),
      HoroscopePeriod.weekly => () {
        final monday = DateTime(d.year, d.month, d.day - (d.weekday - 1));
        return (monday, DateTime(monday.year, monday.month, monday.day + 7));
      }(),
      HoroscopePeriod.monthly => (DateTime(d.year, d.month), DateTime(d.year, d.month + 1)),
      HoroscopePeriod.yearly => (DateTime(d.year), DateTime(d.year + 1)),
    };
  }

  static DateTime _toUtc(DateTime localDate, int hour, Duration offset) =>
      DateTime.utc(localDate.year, localDate.month, localDate.day, hour).subtract(offset);

  static List<DateTime> _samples(HoroscopePeriod p, DateTime start, DateTime end, Duration offset) {
    final out = <DateTime>[];
    switch (p) {
      case HoroscopePeriod.daily:
        out.add(_toUtc(start, 6, offset));
        out.add(_toUtc(start, 18, offset));
      case HoroscopePeriod.weekly || HoroscopePeriod.monthly:
        for (var d = start; d.isBefore(end); d = DateTime(d.year, d.month, d.day + 1)) {
          out.add(_toUtc(d, 12, offset));
        }
      case HoroscopePeriod.yearly:
        for (var d = start; d.isBefore(end); d = DateTime(d.year, d.month, d.day + 7)) {
          out.add(_toUtc(d, 12, offset));
        }
    }
    return out;
  }

  List<String> _events(
    HoroscopePeriod period,
    DateTime start,
    DateTime end,
    Duration offset,
    CalcSettings settings,
    String Function(Sign) signName,
    String Function(Planet) planetName,
  ) {
    final vedic = settings.system == AstroSystem.vedic;
    final ayan = vedic ? settings.ayanamsa : null;
    final from = _toUtc(start, 0, offset);
    final to = _toUtc(end, 0, offset);
    // Dates and times are built from the text pack (not DateFormat) so every
    // language reads naturally and output never depends on the device locale.
    String date(DateTime utc) => _date(utc.add(offset), withYear: period == HoroscopePeriod.yearly);
    String time(DateTime utc) => _hm(utc.add(offset));

    final out = <String>[];
    if (period == HoroscopePeriod.daily) {
      for (final e in SkyEvents.ingresses(from, to, [Planet.moon], ayanamsa: ayan)) {
        out.add(_capitalise(t.one('event.moonsign', {'sign': signName(e.sign!), 'time': time(e.time)})));
      }
      return out;
    }

    final slow = vedic
        ? [Planet.jupiter, Planet.saturn, Planet.rahu]
        : [Planet.jupiter, Planet.saturn, Planet.uranus, Planet.neptune, Planet.pluto];
    final ingressPlanets = switch (period) {
      HoroscopePeriod.weekly => [Planet.moon, Planet.sun, Planet.mercury, Planet.venus, Planet.mars, ...slow],
      HoroscopePeriod.monthly => [Planet.sun, Planet.mercury, Planet.venus, Planet.mars, ...slow],
      _ => [Planet.mars, ...slow],
    };

    final events = <SkyEvent>[
      ...SkyEvents.ingresses(from, to, ingressPlanets, ayanamsa: ayan, node: settings.nodeType),
      ...SkyEvents.stations(
        from,
        to,
        ayanamsa: ayan,
      ).where((e) => period != HoroscopePeriod.yearly || !const [Planet.mercury, Planet.venus].contains(e.planet)),
      ...SkyEvents.eclipses(from, to, ayanamsa: ayan),
    ]..sort((a, b) => a.time.compareTo(b.time));

    for (final e in events) {
      if (!vedic && e.planet != null && !Planet.western.contains(e.planet)) continue;
      if (vedic && e.planet != null && e.planet!.isOuter) continue;
      final args = {
        'planet': e.planet == null ? '' : planetName(e.planet!),
        'sign': e.sign == null ? '' : signName(e.sign!),
        'date': date(e.time),
        'kind': t.one('eclipse.${e.eclipseKind ?? 'partial'}'),
      };
      out.add(
        _capitalise(switch (e.type) {
          SkyEventType.ingress =>
            e.planet == Planet.moon
                ? t.one('event.moonsign', {'sign': args['sign']!, 'time': '${date(e.time)} ${time(e.time)}'})
                : t.one('event.ingress', args),
          SkyEventType.stationRetrograde => t.one('event.retro', args),
          SkyEventType.stationDirect => t.one('event.direct', args),
          SkyEventType.solarEclipse => t.one('event.solar', args),
          SkyEventType.lunarEclipse => t.one('event.lunar', args),
        }),
      );
    }
    return out;
  }

  LuckyInfo _lucky(
    DateTime day,
    Duration offset,
    CalcSettings settings,
    double? latitude,
    double? longitude,
    String Function(Planet) planetName,
  ) {
    final weekday = day.weekday % 7; // Sunday = 0
    final lord = varaLords[weekday];
    String? window;
    DateTime? ws, we;
    if (latitude != null && longitude != null) {
      final p = PanchangCalculator.compute(
        date: day,
        latitude: latitude,
        longitude: longitude,
        utcOffset: offset,
        ayanamsa: settings.ayanamsa,
      );
      for (final pref in const [Planet.jupiter, Planet.venus, Planet.mercury, Planet.moon]) {
        final hora = p.horas
            .take(12)
            .where(
              (h) => h.label == pref.name && !(h.start.isBefore(p.rahuKaal.end) && h.end.isAfter(p.rahuKaal.start)),
            );
        if (hora.isNotEmpty) {
          final h = hora.first;
          ws = h.start;
          we = h.end;
          window =
              '${t.one('lucky.hora', {'planet': planetName(pref)})}: '
              '${_hm(h.start.add(offset))}–${_hm(h.end.add(offset))}';
          break;
        }
      }
    }
    return LuckyInfo(
      planet: lord,
      color: t.one('lucky.color.${lord.name}'),
      number: _chaldeanNumber[lord]!,
      note: t.one('lucky.note', {'planet': planetName(lord), 'weekday': t.one('weekday.$weekday')}),
      timeWindow: window,
      windowStartUtc: ws,
      windowEndUtc: we,
    );
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
  static String _isoDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';
  static String _hm(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

  String _date(DateTime d, {required bool withYear}) =>
      t.one(withYear ? 'date.dmy' : 'date.dm', {'d': '${d.day}', 'month': t.one('month.${d.month}'), 'y': '${d.year}'});

  static String _capitalise(String s) {
    final trimmed = s.trimLeft();
    if (trimmed.isEmpty) return s;
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }
}

class _Factor {
  _Factor.gochara(GocharaTransit this.gochara)
    : kind = ReasonKind.gochara,
      tara = null,
      aspect = null,
      sign = gochara.sign;
  _Factor.tara(TaraBala this.tara) : kind = ReasonKind.tara, gochara = null, aspect = null, sign = null;
  _Factor.aspect(WesternAspect this.aspect, Sign this.sign) : kind = ReasonKind.aspect, gochara = null, tara = null;

  final ReasonKind kind;
  final GocharaTransit? gochara;
  final TaraBala? tara;
  final WesternAspect? aspect;
  final Sign? sign;
  int count = 0;

  double get polarity => gochara?.polarity ?? tara?.polarity ?? aspect!.polarity;

  /// Used to avoid writing two sentences about the same planet.
  Object get identity => gochara?.planet ?? aspect?.transiting ?? 'tara';
}
