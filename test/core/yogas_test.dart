import 'package:drishti/core/astro/constants.dart';
import 'package:drishti/core/astro/vedic/yogas.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/manual_chart.dart';

List<String> names(List<Yoga> y) => y.map((e) => e.name).toList();

void main() {
  test('Vedic aspects', () {
    expect(aspectsSign(Planet.sun, Sign.aries, Sign.libra), isTrue);
    expect(aspectsSign(Planet.sun, Sign.aries, Sign.cancer), isFalse);
    expect(aspectsSign(Planet.mars, Sign.aries, Sign.cancer), isTrue); // 4th
    expect(aspectsSign(Planet.mars, Sign.aries, Sign.scorpio), isTrue); // 8th
    expect(aspectsSign(Planet.jupiter, Sign.aries, Sign.leo), isTrue); // 5th
    expect(aspectsSign(Planet.jupiter, Sign.aries, Sign.sagittarius), isTrue); // 9th
    expect(aspectsSign(Planet.saturn, Sign.aries, Sign.gemini), isTrue); // 3rd
    expect(aspectsSign(Planet.saturn, Sign.aries, Sign.capricorn), isTrue); // 10th
  });

  test('Gajakesari, Hamsa and Budhaditya', () {
    // Ascendant Cancer; Jupiter exalted in Cancer (house 1); Moon in Libra
    // (Jupiter 10th from Moon); Sun and Mercury in Leo.
    final c = manualChart(
      ascendant: 95,
      longitudes: {
        Planet.jupiter: 95,
        Planet.moon: 190,
        Planet.sun: 130,
        Planet.mercury: 140,
        Planet.mars: 10,
        Planet.venus: 160,
        Planet.saturn: 250,
        Planet.rahu: 300,
        Planet.ketu: 120,
      },
    );
    final y = names(YogaDetector.detect(c));
    expect(y, contains('Gajakesari Yoga'));
    expect(y, contains('Hamsa Yoga (Pancha Mahapurusha)'));
    expect(y, contains('Budhaditya Yoga'));
    expect(y, isNot(contains('Chandra-Mangala Yoga')));
  });

  test('Kemadruma with an empty 2nd/12th from the Moon', () {
    final c = manualChart(
      longitudes: {
        Planet.moon: 5, // Aries
        Planet.sun: 35, // Taurus: Sun does not count
        Planet.mars: 95,
        Planet.mercury: 65,
        Planet.jupiter: 155,
        Planet.venus: 125,
        Planet.saturn: 215,
        Planet.rahu: 245,
        Planet.ketu: 65,
      },
    );
    expect(names(YogaDetector.detect(c)), contains('Kemadruma Yoga'));
  });

  test('Raja yoga by conjunction and yogakaraka Saturn for Taurus', () {
    // Taurus Ascendant: Saturn rules 9 and 10 -> yogakaraka.
    // Venus (1st lord) with Mercury (5th lord) in Gemini -> Raja yoga.
    final c = manualChart(
      ascendant: 40,
      longitudes: {
        Planet.venus: 70,
        Planet.mercury: 75,
        Planet.sun: 100,
        Planet.moon: 200,
        Planet.mars: 230,
        Planet.jupiter: 260,
        Planet.saturn: 320,
        Planet.rahu: 10,
        Planet.ketu: 190,
      },
    );
    final y = YogaDetector.detect(c);
    expect(names(y), contains('Raja Yoga'));
    expect(y.where((e) => e.name == 'Yogakaraka').single.planets, [Planet.saturn]);
  });

  test('Neecha Bhanga when the debilitation-sign lord is in a kendra', () {
    // Aries Ascendant; Sun debilitated in Libra (house 7); Venus (lord of
    // Libra) in Cancer (house 4, a kendra).
    final c = manualChart(
      ascendant: 5,
      longitudes: {
        Planet.sun: 190,
        Planet.venus: 100,
        Planet.moon: 40,
        Planet.mars: 300,
        Planet.mercury: 170,
        Planet.jupiter: 140,
        Planet.saturn: 330,
        Planet.rahu: 50,
        Planet.ketu: 230,
      },
    );
    final y = YogaDetector.detect(c).where((e) => e.name == 'Neecha Bhanga Raja Yoga');
    expect(y.single.planets, [Planet.sun]);
  });

  test('Viparita Raja yoga: 6th lord in the 8th', () {
    // Aries Ascendant: Mercury rules 6th (Virgo); place it in Scorpio (8th).
    final c = manualChart(
      ascendant: 5,
      longitudes: {
        Planet.mercury: 215,
        Planet.sun: 230,
        Planet.moon: 40,
        Planet.mars: 70,
        Planet.venus: 100,
        Planet.jupiter: 130,
        Planet.saturn: 330,
        Planet.rahu: 50,
        Planet.ketu: 230,
      },
    );
    expect(names(YogaDetector.detect(c)), contains('Viparita Raja Yoga (Harsha)'));
  });

  test('without houses only Moon-based yogas are evaluated', () {
    final c = manualChart(
      longitudes: {
        Planet.moon: 10,
        Planet.mars: 15,
        Planet.jupiter: 100,
        Planet.sun: 200,
        Planet.mercury: 210,
        Planet.venus: 230,
        Planet.saturn: 300,
        Planet.rahu: 20,
        Planet.ketu: 200,
      },
    );
    final y = names(YogaDetector.detect(c));
    expect(y, containsAll(['Chandra-Mangala Yoga', 'Gajakesari Yoga']));
    expect(y.where((n) => n.contains('Raja')), isEmpty);
  });

  test('an exchange counts only between the qualifying houses (audit bug)', () {
    // Aries Ascendant: Venus (lord of 2 and 7) in Pisces, Jupiter (lord of 9
    // and 12) in Taurus. This is a 2-12 exchange (Dainya), not a 7-9 Raja
    // yoga nor a 2-9 Dhana yoga.
    final c = manualChart(
      ascendant: 5,
      longitudes: {
        Planet.venus: 350,
        Planet.jupiter: 40,
        Planet.sun: 100,
        Planet.moon: 200,
        Planet.mars: 160,
        Planet.mercury: 110,
        Planet.saturn: 280,
        Planet.rahu: 70,
        Planet.ketu: 250,
      },
    );
    final y = YogaDetector.detect(c);
    bool venusJupiter(Yoga x) => x.planets.toSet().containsAll({Planet.venus, Planet.jupiter});
    expect(y.where((x) => (x.id == 'raja' || x.id == 'dhana') && venusJupiter(x)), isEmpty);
    expect(y.where((x) => x.id == 'parivartanaDainya' && venusJupiter(x)), hasLength(1));
  });

  test('the Moon in a kendra does not cancel Kemadruma (BPHS 37.11)', () {
    final c = manualChart(
      ascendant: 5,
      longitudes: {
        Planet.moon: 5, // Aries, house 1
        Planet.sun: 65,
        Planet.mercury: 75,
        Planet.mars: 125,
        Planet.jupiter: 155,
        Planet.venus: 215,
        Planet.saturn: 305,
        Planet.rahu: 245,
        Planet.ketu: 65,
      },
    );
    final k = YogaDetector.detect(c).firstWhere((x) => x.id == 'kemadruma');
    expect(k.noteRef, isNull);
  });

  test('Sunapha, Durudhara and Vesi', () {
    final base = {
      Planet.moon: 5.0, // Aries
      Planet.sun: 125.0, // Leo
      Planet.mercury: 155.0, // Virgo: 2nd from the Sun
      Planet.mars: 35.0, // Taurus: 2nd from the Moon
      Planet.jupiter: 245.0,
      Planet.venus: 185.0,
      Planet.saturn: 275.0,
      Planet.rahu: 65.0,
      Planet.ketu: 245.0,
    };
    final y = YogaDetector.detect(manualChart(longitudes: base)).map((x) => x.id).toList();
    expect(y, containsAll(['sunapha', 'vesi']));
    expect(y, isNot(contains('kemadruma')));
    final both = YogaDetector.detect(manualChart(longitudes: {...base, Planet.saturn: 335})).map((x) => x.id);
    expect(both, contains('durudhara'));
  });

  test('Budhaditya within 10 degrees is reported as weak (Raman #24)', () {
    final c = manualChart(longitudes: {Planet.sun: 130, Planet.mercury: 134, Planet.moon: 10});
    final b = YogaDetector.detect(c).firstWhere((x) => x.id == 'budhaditya');
    expect(b.noteRef?.key, 'yoga.budhaditya.weak');
  });
}
