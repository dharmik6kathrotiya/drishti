import 'package:drishti/core/astro/chart.dart';
import 'package:drishti/core/astro/constants.dart';
import 'package:drishti/core/astro/western/aspects.dart';
import 'package:flutter_test/flutter_test.dart';

PlanetPlacement pp(Planet p, double lon, [double speed = 1]) =>
    PlanetPlacement(planet: p, longitude: lon, latitude: 0, speed: speed);

void main() {
  test('trine within orb is found and applying', () {
    // Moon (fast) at 0°, Saturn at 125°: separation 125, moving towards 120? No:
    // Moon moves forward, separation shrinks -> applying.
    final a = {Planet.moon: pp(Planet.moon, 0, 13), Planet.saturn: pp(Planet.saturn, 125, 0.03)};
    final asp = aspectsBetween(a, null);
    expect(asp.length, 1);
    expect(asp.first.type, AspectType.trine);
    expect(asp.first.orb, closeTo(5, 1e-9));
    expect(asp.first.applying, isTrue);
  });

  test('wraps around 0° Aries', () {
    final a = {Planet.venus: pp(Planet.venus, 358), Planet.mars: pp(Planet.mars, 2, 0.5)};
    expect(aspectsBetween(a, null).single.type, AspectType.conjunction);
  });

  test('outside orb is ignored; luminaries get a bonus', () {
    final noLum = {Planet.mars: pp(Planet.mars, 0), Planet.jupiter: pp(Planet.jupiter, 99)};
    expect(aspectsBetween(noLum, null), isEmpty); // 9° > 7°
    final lum = {Planet.sun: pp(Planet.sun, 0), Planet.jupiter: pp(Planet.jupiter, 98.5)};
    expect(aspectsBetween(lum, null).single.type, AspectType.square); // 8.5° <= 9°
  });

  test('synastry compares every pair across charts', () {
    final a = {Planet.sun: pp(Planet.sun, 10)};
    final b = {Planet.moon: pp(Planet.moon, 190), Planet.venus: pp(Planet.venus, 70)};
    final asp = aspectsBetween(a, b);
    expect(asp.map((x) => x.type), containsAll([AspectType.opposition, AspectType.sextile]));
  });

  test('minor aspects can be switched off', () {
    final a = {Planet.mars: pp(Planet.mars, 0), Planet.venus: pp(Planet.venus, 150)};
    expect(aspectsBetween(a, null).single.type, AspectType.quincunx);
    expect(aspectsBetween(a, null, orbs: const AspectOrbs(includeMinor: false)), isEmpty);
  });
}
