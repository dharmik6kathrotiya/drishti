import 'package:drishti/core/astro/chart.dart';
import 'package:drishti/core/astro/constants.dart';
import 'package:drishti/core/astro/settings.dart';

/// Builds a whole-sign Vedic chart from hand-picked longitudes. Planets not
/// listed are placed at 0° of the sign after the Ascendant's 6th, far from
/// anything interesting, unless [defaults] is overridden.
Chart manualChart({double? ascendant, required Map<Planet, double> longitudes, Map<Planet, double> speeds = const {}}) {
  final ascSign = ascendant == null ? null : Sign.fromLongitude(ascendant);
  final planets = <Planet, PlanetPlacement>{
    for (final p in Planet.vedic)
      p: PlanetPlacement(
        planet: p,
        longitude: longitudes[p] ?? 0,
        latitude: 0,
        speed: speeds[p] ?? (p.isNode ? -0.05 : 1),
        house: ascSign?.countTo(Sign.fromLongitude(longitudes[p] ?? 0)),
      ),
  };
  return Chart(
    jd: 2451545,
    settings: const CalcSettings(),
    planets: planets,
    ayanamsaValue: 0,
    ascendant: ascendant,
    cusps: ascendant == null ? null : [for (var i = 0; i < 12; i++) ascSign!.index * 30.0 + i * 30],
  );
}
