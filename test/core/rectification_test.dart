import 'package:drishti/core/astro/chart.dart';
import 'package:drishti/core/astro/constants.dart';
import 'package:drishti/core/astro/rectification.dart';
import 'package:drishti/core/astro/settings.dart';
import 'package:drishti/core/astro/vedic/dasha.dart';
import 'package:drishti/core/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/ephemeris_setup.dart';

const mumbai = Place(
  name: 'Mumbai',
  region: 'Maharashtra',
  countryCode: 'IN',
  latitude: 19.0728,
  longitude: 72.8826,
  timezoneId: 'Asia/Kolkata',
);

void main() {
  setUpAll(setUpEphemeris);

  final truth = Profile(
    id: 't',
    name: 'Test',
    birthDate: DateTime(1990, 8, 15),
    birthHour: 10,
    birthMinute: 30,
    timeAccuracy: TimeAccuracy.exact,
    place: mumbai,
  );
  const settings = CalcSettings();

  /// Builds events that the true chart's dashas strongly support: for each
  /// event type, the middle of the first Pratyantardasha (age 18-55) in which
  /// all three running lords signify the event's houses.
  List<LifeEvent> syntheticEvents() {
    final utc = truth.birthUtc()!;
    final chart = ChartCalculator.cast(
      utc: utc,
      settings: settings,
      latitude: mumbai.latitude,
      longitude: mumbai.longitude,
    );
    Set<int> housesOf(Planet p) => {
      chart[p].house!,
      for (var h = 1; h <= 12; h++)
        if (chart.houseLord(h) == p) h,
    };
    final v = Vimshottari();
    final events = <LifeEvent>[];
    for (final type in [
      LifeEventType.marriage,
      LifeEventType.jobStart,
      LifeEventType.childBirth,
      LifeEventType.relocation,
    ]) {
      final rule = eventRules[type]!;
      bool links(Planet p) => housesOf(p).any(rule.houses.contains);
      outer:
      for (final m in v.mahadashas(utc, chart.moon.longitude)) {
        for (final a in v.subPeriods(m)) {
          for (final pd in v.subPeriods(a)) {
            final age = pd.start.difference(utc).inDays / 365.25;
            if (age < 18 || age > 55) continue;
            if (links(m.lord) && links(a.lord) && links(pd.lord)) {
              events.add(LifeEvent(type: type, date: pd.start.add(pd.length ~/ 2)));
              break outer;
            }
          }
        }
      }
    }
    return events;
  }

  test('scoring is deterministic', () {
    final events = syntheticEvents();
    final r1 = Rectifier(settings: settings).run(
      profile: truth,
      windowStartLocal: DateTime(1990, 8, 15, 9),
      windowEndLocal: DateTime(1990, 8, 15, 11),
      events: events,
    );
    final r2 = Rectifier(settings: settings).run(
      profile: truth,
      windowStartLocal: DateTime(1990, 8, 15, 9),
      windowEndLocal: DateTime(1990, 8, 15, 11),
      events: events,
    );
    expect(r1.scannedTimes, 61);
    expect([for (final c in r1.candidates) c.score], [for (final c in r2.candidates) c.score]);
    expect(r1.candidates.first.bestLocal, r2.candidates.first.bestLocal);
  });

  test('a synthetic case ranks the true Lagna first', () {
    final events = syntheticEvents();
    expect(events.length, greaterThanOrEqualTo(2));
    final trueLagna = ChartCalculator.cast(
      utc: truth.birthUtc()!,
      settings: settings,
      latitude: mumbai.latitude,
      longitude: mumbai.longitude,
    ).ascendantSign;
    final r = Rectifier(settings: settings).run(
      profile: truth,
      windowStartLocal: DateTime(1990, 8, 15, 6),
      windowEndLocal: DateTime(1990, 8, 15, 15),
      events: events,
    );
    expect(r.candidates.first.lagna, trueLagna);
    expect(r.candidates.first.matches.every((m) => m.reasons.isNotEmpty), isTrue);
  });

  test('events of type "other" are ignored and a place is required', () {
    final r = Rectifier().run(
      profile: truth,
      windowStartLocal: DateTime(1990, 8, 15, 10),
      windowEndLocal: DateTime(1990, 8, 15, 10, 10),
      events: [LifeEvent(type: LifeEventType.other, date: DateTime(2015))],
    );
    expect(r.candidates.every((c) => c.matches.isEmpty), isTrue);
    expect(
      () => Rectifier().run(
        profile: truth.copyWith(place: () => null),
        windowStartLocal: DateTime(1990, 8, 15, 10),
        windowEndLocal: DateTime(1990, 8, 15, 11),
      ),
      throwsArgumentError,
    );
  });
}
