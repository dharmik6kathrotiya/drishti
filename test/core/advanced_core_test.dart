import 'package:drishti/core/astro/chart.dart';
import 'package:drishti/core/astro/constants.dart';
import 'package:drishti/core/astro/settings.dart';
import 'package:drishti/core/astro/vedic/ashtakavarga.dart';
import 'package:drishti/core/astro/vedic/jaimini.dart';
import 'package:drishti/core/astro/vedic/lal_kitab.dart';
import 'package:drishti/core/astro/vedic/shadbala.dart';
import 'package:drishti/core/astro/western/composite.dart';
import 'package:drishti/core/astro/western/composite_reading.dart';
import 'package:drishti/core/i18n/engine_texts.dart';
import 'package:drishti/core/astro/western/progressions.dart';
import 'package:drishti/core/astro/western/returns.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/ephemeris_setup.dart';
import '../helpers/manual_chart.dart';

void main() {
  setUpAll(setUpEphemeris);

  // 15 Aug 1990 10:30 IST, Mumbai.
  final birth = DateTime.utc(1990, 8, 15, 5, 0);
  Chart vedic() =>
      ChartCalculator.cast(utc: birth, settings: const CalcSettings(), latitude: 19.076, longitude: 72.8777);
  Chart western() => ChartCalculator.cast(
    utc: birth,
    settings: const CalcSettings(system: AstroSystem.western),
    latitude: 19.076,
    longitude: 72.8777,
  );

  group('Ashtakavarga', () {
    test('table totals match BPHS', () {
      for (final p in Ashtakavarga.planets) {
        final sum = Ashtakavarga.benefic[p]!.fold<int>(0, (s, l) => s + l.length);
        expect(sum, Ashtakavarga.totals[p], reason: p.name);
      }
    });

    test('BAV totals and SAV 337 for a real chart', () {
      final r = Ashtakavarga.compute(vedic());
      for (final p in Ashtakavarga.planets) {
        expect(r.bav[p]!.fold<int>(0, (a, b) => a + b), Ashtakavarga.totals[p]);
      }
      expect(r.savTotal, 337);
      expect(r.complete, isTrue);
    });

    test('trikona shodhana', () {
      final pts = [4, 5, 6, 3, 3, 3, 0, 5, 2, 7, 6, 5];
      final out = Ashtakavarga.trikonaShodhana(pts);
      // Aries/Leo/Sag = 4,3,2 -> min 2 -> 2,1,0
      expect([out[0], out[4], out[8]], [2, 1, 0]);
      // Gemini/Libra/Aqu has a zero -> unchanged
      expect([out[2], out[6], out[10]], [6, 0, 6]);
      // Cancer/Scorpio/Pisces = 3,5,5 -> 0,2,2
      expect([out[3], out[7], out[11]], [0, 2, 2]);
    });
  });

  group('Shadbala', () {
    test('naisargika constants descend Sun to Saturn', () {
      expect(Shadbala.naisargika[Planet.sun], 60);
      expect(Shadbala.naisargika[Planet.saturn], closeTo(60 / 7, 0.01));
    });

    test('aspect values', () {
      expect(Shadbala.aspectValue(Planet.sun, 0, 180), 60);
      expect(Shadbala.aspectValue(Planet.sun, 0, 10), 0);
      expect(Shadbala.aspectValue(Planet.saturn, 0, 60), 60);
      expect(Shadbala.aspectValue(Planet.jupiter, 0, 240), 60);
      expect(Shadbala.aspectValue(Planet.mars, 0, 90), 60);
    });

    test('values in sane ranges', () {
      final r = Shadbala.compute(vedic());
      for (final row in r.rows.values) {
        expect(row.uchcha, inInclusiveRange(0, 60));
        expect(row.dig, inInclusiveRange(0, 60));
        expect(row.sthana, inInclusiveRange(0, 60 + 7 * 45 + 30 + 60 + 15));
        expect(row.rupas, inInclusiveRange(1, 15), reason: row.planet.name);
      }
    });
  });

  group('Jaimini', () {
    test('karakas ordered by degree, Rahu counted backwards', () {
      // Degrees in sign: Su 28, Mo 15, Ma 11, Me 10, Ju 5, Ve 2, Sa 23; Rahu 0.5 -> 29.5.
      final c = manualChart(
        ascendant: 5,
        longitudes: {
          Planet.sun: 28,
          Planet.moon: 45,
          Planet.mars: 71,
          Planet.mercury: 100,
          Planet.jupiter: 125,
          Planet.venus: 152,
          Planet.saturn: 203,
          Planet.rahu: 240.5,
          Planet.ketu: 60.5,
        },
      );
      final k = Jaimini.charaKarakas(c);
      expect(k.map((e) => e.planet).first, Planet.sun);
      expect(k.last.planet, Planet.venus); // 2°
      final k8 = Jaimini.charaKarakas(c, eight: true);
      expect(k8.first.planet, Planet.rahu); // 30 - 0.5 = 29.5
    });

    test('arudha exception: pada in the sign itself goes to the 10th', () {
      // Lagna Aries; Mars (lord) in Aries -> pada = Aries -> 10th = Capricorn.
      final c = manualChart(ascendant: 5, longitudes: {Planet.mars: 10});
      expect(Jaimini.arudha(c, 1), Sign.capricorn);
      // Mars in Libra (7th) -> count 7, pada 7th from Libra = Aries (1st) -> Capricorn.
      final c2 = manualChart(ascendant: 5, longitudes: {Planet.mars: 190});
      expect(Jaimini.arudha(c2, 1), Sign.capricorn);
      // Mars in Gemini (3rd) -> pada 3rd from Gemini = Leo.
      final c3 = manualChart(ascendant: 5, longitudes: {Planet.mars: 70});
      expect(Jaimini.arudha(c3, 1), Sign.leo);
    });

    test('chara dasha totals 144 years over two cycles', () {
      final c = vedic();
      final d = Jaimini.charaDasha(c, birth);
      expect(d.fold<int>(0, (s, p) => s + p.years), 144);
    });
  });

  test('Lal Kitab houses follow signs', () {
    final c = manualChart(ascendant: 100, longitudes: {Planet.sun: 5, Planet.moon: 95});
    expect(LalKitab.houseOf(c, Planet.sun), 1);
    expect(LalKitab.houseOf(c, Planet.moon), 4);
    expect(LalKitab.inPakkaGhar(c), containsAll([Planet.sun, Planet.moon]));
  });

  group('Western', () {
    test('solar return Sun matches natal Sun', () {
      final n = western();
      final r = Returns.solarReturn(n, birth, 2026);
      expect(angularDistance(r.sun.longitude, n.sun.longitude), lessThan(0.001));
      expect(r.hasHouses, isTrue);
    });

    test('progressed Sun moves about 1° per year', () {
      final n = western();
      final p = Progressions.progressed(n, birth, DateTime.utc(2020, 8, 15));
      final arc = norm360(p.sun.longitude - n.sun.longitude);
      expect(arc, closeTo(29, 2));
      expect(angularDistance(p.midheaven!, n.midheaven!), closeTo(arc, 0.01));
      expect(p.hasHouses, isTrue);
    });

    test('composite midpoints', () {
      expect(Composite.midpoint(350, 10), closeTo(0, 1e-9));
      expect(Composite.midpoint(10, 50), closeTo(30, 1e-9));
      final a = western();
      final b = ChartCalculator.cast(
        utc: DateTime.utc(1992, 3, 1, 12),
        settings: const CalcSettings(system: AstroSystem.western),
        latitude: 28.6,
        longitude: 77.2,
      );
      final c = Composite.compute(a, b);
      expect(c.hasHouses, isTrue);
      expect(angularDistance(c[Planet.rahu].longitude, c[Planet.ketu].longitude), closeTo(180, 1e-9));

      // The plain reading: a verdict that follows the aspect counts, the
      // purpose and feeling lines, and only known texts.
      final r = CompositeReading.of(c);
      final lead = r.harmonious.length - r.challenging.length;
      expect(r.tone, lead >= 2 ? 1 : (lead <= -2 ? -1 : 0));
      expect(r.points.first.key, startsWith('comp.tone.'));
      expect(r.points[1].key, 'comp.sun.${c[Planet.sun].sign.element.name}');
      expect(r.points[2].key, 'comp.moon.${c[Planet.moon].sign.element.name}');
      final en = EngineTexts.of('en');
      for (final pt in r.points) {
        expect(en.has(pt.key), isTrue, reason: pt.key);
      }
      for (final x in r.aspects) {
        expect(x.type.major, isTrue);
        expect({x.a, x.b}.intersection({Planet.uranus, Planet.neptune, Planet.pluto, Planet.rahu}), isEmpty);
      }
    });
  });
}
