import 'package:drishti/core/astro/chart.dart';
import 'package:drishti/core/astro/constants.dart';
import 'package:drishti/core/astro/settings.dart';
import 'package:drishti/core/astro/vedic/longevity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/ephemeris_setup.dart';

void main() {
  setUpAll(setUpEphemeris);

  test('Jaimini pair table', () {
    const m = Modality.movable, f = Modality.fixed, d = Modality.dual;
    expect(Longevity.pairSpan(m, m), LifeSpan.long);
    expect(Longevity.pairSpan(f, d), LifeSpan.long);
    expect(Longevity.pairSpan(d, f), LifeSpan.long);
    expect(Longevity.pairSpan(m, f), LifeSpan.middle);
    expect(Longevity.pairSpan(d, d), LifeSpan.middle);
    expect(Longevity.pairSpan(m, d), LifeSpan.short);
    expect(Longevity.pairSpan(f, f), LifeSpan.short);
  });

  // 15 Aug 1990, 10:30 IST, Mumbai.
  Chart cast({bool withHouses = true}) => ChartCalculator.cast(
    utc: DateTime.utc(1990, 8, 15, 5),
    settings: const CalcSettings(),
    latitude: 19.0728,
    longitude: 72.8826,
    withHouses: withHouses,
  );

  test('full chart: three pairs, a span and maraka periods inside it', () {
    final chart = cast();
    final birth = DateTime.utc(1990, 8, 15, 5);
    final r = Longevity.compute(chart, birthUtc: birth, now: DateTime.utc(2026, 10, 28));
    expect(r.pairs.map((p) => p.key), ['lords', 'moonSaturn', 'horaLagna']);
    expect(r.span, isNotNull);
    expect(r.ageNow, 36);
    final lagna = chart.ascendantSign!;
    expect(r.marakas, contains((lagna + 6).lord));
    if ((lagna + 1).lord != lagna.lord) expect(r.marakas, contains((lagna + 1).lord));
    expect(r.marakas, isNot(contains(lagna.lord)));
    final from = DateTime.utc(1990 + r.span!.fromAge, 8, 15), to = DateTime.utc(1990 + r.span!.toAge, 8, 15);
    for (final a in r.sensitive) {
      expect(r.marakas, contains(a.lord));
      expect(a.end.isAfter(from) && a.start.isBefore(to), isTrue);
    }
  });

  test('Hora Lagna starts at the Sun at sunrise and moves a sign an hour', () {
    final hl = Longevity.horaLagna(cast())!;
    // Sunrise about 06:15 IST with the sidereal Sun near 28° Cancer (118°);
    // 4 h 15 m later HL has moved 127.5° to about 6° Sagittarius.
    expect(hl, Sign.sagittarius);
  });

  test('without a birth time only the Moon/Saturn pair is known', () {
    final r = Longevity.compute(
      cast(withHouses: false),
      birthUtc: DateTime.utc(1990, 8, 15, 5),
      now: DateTime.utc(2026, 10, 28),
    );
    expect(r.span, isNull);
    expect(r.pairs.single.key, 'moonSaturn');
    expect(r.marakas, isEmpty);
  });
}
