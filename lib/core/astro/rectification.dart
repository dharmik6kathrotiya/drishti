import '../models/profile.dart';
import 'chart.dart';
import 'constants.dart';
import 'ephemeris.dart';
import 'settings.dart';
import 'vedic/dasha.dart';
import 'vedic/divisional.dart';
import 'vedic/yogas.dart';

/// Houses and natural significators traditionally linked with each kind of
/// life event (counted from the candidate Lagna).
class EventRule {
  const EventRule(this.houses, this.karakas, this.description);
  final List<int> houses;
  final List<Planet> karakas;
  final String description;
}

const eventRules = {
  LifeEventType.marriage: EventRule([7, 2, 11], [Planet.venus, Planet.jupiter], 'marriage (7th, 2nd, 11th)'),
  LifeEventType.childBirth: EventRule([5, 2, 11], [Planet.jupiter], 'birth of a child (5th, 2nd, 11th)'),
  LifeEventType.jobStart: EventRule([10, 6, 11], [Planet.saturn, Planet.sun], 'starting work (10th, 6th, 11th)'),
  LifeEventType.jobLoss: EventRule([12, 8], [Planet.saturn], 'leaving or losing work (12th, 8th)'),
  LifeEventType.relocation: EventRule([4, 12, 3, 9], [Planet.moon], 'relocation (4th, 12th, 3rd, 9th)'),
  LifeEventType.accident: EventRule([6, 8, 12], [Planet.mars, Planet.saturn], 'difficult events (6th, 8th, 12th)'),
  LifeEventType.illness: EventRule([6, 8, 12], [Planet.saturn], 'health setbacks (6th, 8th, 12th)'),
  // Loss of a parent: the 8th counted from the 9th (father) is the 4th, and
  // the 8th from the 4th (mother) is the 11th. Stated as tradition only.
  LifeEventType.parentDeath: EventRule(
    [4, 11],
    [Planet.sun, Planet.moon, Planet.saturn],
    'events concerning a parent (houses traditionally counted as the 8th from the 9th and 4th)',
  ),
  LifeEventType.education: EventRule([4, 5, 9], [Planet.mercury, Planet.jupiter], 'education (4th, 5th, 9th)'),
};

class EventMatch {
  const EventMatch(this.event, this.score, this.reasons);
  final LifeEvent event;
  final double score;
  final List<String> reasons;
}

/// A span of birth times that share the same Lagna, Navamsa and Dasamsa
/// lagna, with its score.
class RectCandidate {
  const RectCandidate({
    required this.startLocal,
    required this.endLocal,
    required this.bestLocal,
    required this.lagna,
    required this.d9Lagna,
    required this.d10Lagna,
    required this.score,
    required this.matches,
  });

  final DateTime startLocal;
  final DateTime endLocal;

  /// Middle of the span, suggested as the rectified time.
  final DateTime bestLocal;
  final Sign lagna;
  final Sign d9Lagna;
  final Sign d10Lagna;
  final double score;
  final List<EventMatch> matches;
}

class RectificationResult {
  const RectificationResult(this.candidates, this.scannedTimes);

  /// Best first.
  final List<RectCandidate> candidates;
  final int scannedTimes;
}

/// Scores candidate birth times against known life events.
///
/// Method (traditional, simplified): for each event, the Vimshottari
/// Mahadasha, Antardasha and Pratyantardasha lords running at that date
/// should signify the event's houses (by occupation or ownership, counted
/// from the candidate Lagna) or be its natural significator; transiting
/// Jupiter and Saturn at the event should occupy or aspect those houses.
/// Times are grouped into spans with identical D1/D9/D10 lagnas.
class Rectifier {
  Rectifier({this.settings = const CalcSettings(), this.stepMinutes = 2});

  final CalcSettings settings;
  final int stepMinutes;

  static const _levelWeights = [1.0, 1.5, 2.0];

  RectificationResult run({
    required Profile profile,
    required DateTime windowStartLocal,
    required DateTime windowEndLocal,
    List<LifeEvent>? events,
  }) {
    final evs = (events ?? profile.lifeEvents).where((e) => eventRules.containsKey(e.type)).toList();
    final place = profile.place;
    if (place == null) throw ArgumentError('A birthplace is needed for rectification.');
    final vedic = settings.copyWith(system: AstroSystem.vedic, vedicHouses: HouseSystem.wholeSign);

    // Transits at each event do not depend on the birth time.
    final transitSigns = {
      for (final e in evs)
        e: {
          for (final p in [Planet.jupiter, Planet.saturn])
            p: Sign.fromLongitude(
              Ephemeris.position(
                Ephemeris.julianDay(DateTime.utc(e.date.year, e.date.month, e.date.day, 6)),
                p,
                ayanamsa: vedic.ayanamsa,
              ).longitude,
            ),
        },
    };

    final samples = <_Sample>[];
    var t = windowStartLocal;
    while (!t.isAfter(windowEndLocal)) {
      final candidateProfile = profile.copyWith(
        birthDate: () => DateTime(t.year, t.month, t.day),
        birthHour: () => t.hour,
        birthMinute: () => t.minute,
        timeAccuracy: TimeAccuracy.approximate,
      );
      final utc = candidateProfile.birthUtc()!;
      final chart = ChartCalculator.cast(
        utc: utc,
        settings: vedic,
        latitude: place.latitude,
        longitude: place.longitude,
      );
      final matches = [for (final e in evs) _scoreEvent(e, chart, utc, transitSigns[e]!)];
      samples.add(
        _Sample(
          t,
          chart.ascendantSign!,
          Varga.d9.signOf(chart.ascendant!),
          Varga.d10.signOf(chart.ascendant!),
          matches.fold(0.0, (s, m) => s + m.score),
          matches,
        ),
      );
      t = t.add(Duration(minutes: stepMinutes));
    }

    // Group consecutive samples with the same D1/D9/D10 lagna.
    final groups = <List<_Sample>>[];
    for (final s in samples) {
      final last = groups.isEmpty ? null : groups.last.last;
      if (last != null && last.lagna == s.lagna && last.d9 == s.d9 && last.d10 == s.d10) {
        groups.last.add(s);
      } else {
        groups.add([s]);
      }
    }
    final candidates =
        [
          for (final g in groups)
            () {
              final mid = g[g.length ~/ 2];
              final avg = g.fold(0.0, (s, x) => s + x.score) / g.length;
              return RectCandidate(
                startLocal: g.first.time,
                endLocal: g.last.time,
                bestLocal: mid.time,
                lagna: mid.lagna,
                d9Lagna: mid.d9,
                d10Lagna: mid.d10,
                score: double.parse(avg.toStringAsFixed(3)),
                matches: mid.matches,
              );
            }(),
        ]..sort((a, b) {
          final c = b.score.compareTo(a.score);
          return c != 0 ? c : a.startLocal.compareTo(b.startLocal);
        });
    return RectificationResult(candidates, samples.length);
  }

  EventMatch _scoreEvent(LifeEvent e, Chart chart, DateTime birthUtc, Map<Planet, Sign> transit) {
    final rule = eventRules[e.type]!;
    final eventUtc = DateTime.utc(e.date.year, e.date.month, e.date.day, 12);
    final chain = Vimshottari().runningAt(birthUtc, chart.moon.longitude, eventUtc);
    final reasons = <String>[];
    var score = 0.0;
    final names = ['Mahadasha', 'Antardasha', 'Pratyantardasha'];

    Set<int> housesOf(Planet p) => {
      if (chart.planets[p]?.house != null) chart.planets[p]!.house!,
      for (var h = 1; h <= 12; h++)
        if (chart.houseLord(h) == p) h,
    };

    for (var i = 0; i < chain.length; i++) {
      final lord = chain[i].lord;
      final hits = housesOf(lord).where(rule.houses.contains).toList()..sort();
      final w = _levelWeights[i];
      if (hits.isNotEmpty) {
        score += w * hits.length;
        reasons.add(
          '${names[i]} lord ${_n(lord)} is linked with house${hits.length > 1 ? 's' : ''} ${hits.join(', ')}.',
        );
      }
      if (rule.karakas.contains(lord)) {
        score += w * 0.5;
        reasons.add('${names[i]} lord ${_n(lord)} is a natural significator of this kind of event.');
      }
    }

    final lagna = chart.ascendantSign!;
    for (final entry in transit.entries) {
      final h = lagna.countTo(entry.value);
      if (rule.houses.contains(h)) {
        score += 1;
        reasons.add('Transiting ${_n(entry.key)} was in house $h from this Lagna.');
      } else {
        final aspected = [
          for (final rh in rule.houses)
            if (aspectsSign(entry.key, entry.value, lagna + (rh - 1))) rh,
        ];
        if (aspected.isNotEmpty) {
          score += 0.5;
          reasons.add('Transiting ${_n(entry.key)} aspected house ${aspected.first} from this Lagna.');
        }
      }
    }
    return EventMatch(e, score, reasons);
  }

  static String _n(Planet p) => p.name[0].toUpperCase() + p.name.substring(1);
}

class _Sample {
  _Sample(this.time, this.lagna, this.d9, this.d10, this.score, this.matches);
  final DateTime time;
  final Sign lagna;
  final Sign d9;
  final Sign d10;
  final double score;
  final List<EventMatch> matches;
}
