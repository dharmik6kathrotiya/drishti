import 'package:sweph/sweph.dart';

import '../astro/constants.dart';
import '../astro/ephemeris.dart';
import '../astro/settings.dart';

enum SkyEventType { ingress, stationRetrograde, stationDirect, solarEclipse, lunarEclipse }

/// A notable sky event: a planet changing sign, turning retrograde/direct,
/// or an eclipse.
class SkyEvent {
  const SkyEvent({required this.type, required this.time, this.planet, this.sign, this.eclipseKind});

  final SkyEventType type;
  final DateTime time; // UTC
  final Planet? planet;

  /// Sign entered (ingress) or occupied (station, eclipse = Moon's sign).
  final Sign? sign;

  /// 'total', 'annular', 'partial', 'penumbral' or 'hybrid' for eclipses.
  final String? eclipseKind;
}

class SkyEvents {
  SkyEvents._();

  /// Sign ingresses of [planets] between [from] and [to] (UTC).
  /// Sidereal when [ayanamsa] is given.
  static List<SkyEvent> ingresses(
    DateTime from,
    DateTime to,
    List<Planet> planets, {
    Ayanamsa? ayanamsa,
    NodeType node = NodeType.mean,
  }) {
    final out = <SkyEvent>[];
    final jd0 = Ephemeris.julianDay(from);
    final jd1 = Ephemeris.julianDay(to);
    for (final p in planets) {
      final step = _step(p);
      double lon(double jd) => Ephemeris.position(jd, p, ayanamsa: ayanamsa, node: node).longitude;
      var t = jd0;
      var sign = Sign.fromLongitude(lon(t));
      while (t < jd1) {
        final next = t + step > jd1 ? jd1 : t + step;
        final s = Sign.fromLongitude(lon(next));
        if (s != sign) {
          var lo = t, hi = next;
          for (var i = 0; i < 40; i++) {
            final mid = (lo + hi) / 2;
            if (Sign.fromLongitude(lon(mid)) == sign) {
              lo = mid;
            } else {
              hi = mid;
            }
          }
          out.add(SkyEvent(type: SkyEventType.ingress, time: Ephemeris.dateTimeFromJd(hi), planet: p, sign: s));
          sign = s;
        }
        t = next;
      }
    }
    out.sort((a, b) => a.time.compareTo(b.time));
    return out;
  }

  /// Retrograde and direct stations of the true planets between [from] and [to].
  static List<SkyEvent> stations(DateTime from, DateTime to, {Ayanamsa? ayanamsa}) {
    const planets = [
      Planet.mercury,
      Planet.venus,
      Planet.mars,
      Planet.jupiter,
      Planet.saturn,
      Planet.uranus,
      Planet.neptune,
      Planet.pluto,
    ];
    final out = <SkyEvent>[];
    final jd0 = Ephemeris.julianDay(from);
    final jd1 = Ephemeris.julianDay(to);
    for (final p in planets) {
      double speed(double jd) => Ephemeris.position(jd, p).speed;
      var t = jd0;
      var retro = speed(t) < 0;
      while (t < jd1) {
        final next = t + 1 > jd1 ? jd1 : t + 1;
        final r = speed(next) < 0;
        if (r != retro) {
          var lo = t, hi = next;
          for (var i = 0; i < 30; i++) {
            final mid = (lo + hi) / 2;
            if ((speed(mid) < 0) == retro) {
              lo = mid;
            } else {
              hi = mid;
            }
          }
          final lon = Ephemeris.position(hi, p, ayanamsa: ayanamsa).longitude;
          out.add(
            SkyEvent(
              type: r ? SkyEventType.stationRetrograde : SkyEventType.stationDirect,
              time: Ephemeris.dateTimeFromJd(hi),
              planet: p,
              sign: Sign.fromLongitude(lon),
            ),
          );
          retro = r;
        }
        t = next;
      }
    }
    out.sort((a, b) => a.time.compareTo(b.time));
    return out;
  }

  /// Solar and lunar eclipses (global) between [from] and [to].
  static List<SkyEvent> eclipses(DateTime from, DateTime to, {Ayanamsa? ayanamsa}) {
    final out = <SkyEvent>[];
    final jd1 = Ephemeris.julianDay(to);

    var t = Ephemeris.julianDay(from);
    while (true) {
      final e = Sweph.swe_sol_eclipse_when_glob(t, SwephFlag.SEFLG_SWIEPH, EclipseFlag.SE_ECL_ALLTYPES_SOLAR, false);
      final max = e.times?.first ?? jd1 + 1;
      if (max > jd1) break;
      out.add(
        SkyEvent(
          type: SkyEventType.solarEclipse,
          time: Ephemeris.dateTimeFromJd(max),
          sign: Sign.fromLongitude(Ephemeris.position(max, Planet.moon, ayanamsa: ayanamsa).longitude),
          eclipseKind: _kind(e.eclipseType?.value ?? 0),
        ),
      );
      t = max + 20;
    }

    t = Ephemeris.julianDay(from);
    while (true) {
      final e = Sweph.swe_lun_eclipse_when(t, SwephFlag.SEFLG_SWIEPH, EclipseFlag.SE_ECL_ALLTYPES_LUNAR, false);
      final max = e.times?.first ?? jd1 + 1;
      if (max > jd1) break;
      out.add(
        SkyEvent(
          type: SkyEventType.lunarEclipse,
          time: Ephemeris.dateTimeFromJd(max),
          sign: Sign.fromLongitude(Ephemeris.position(max, Planet.moon, ayanamsa: ayanamsa).longitude),
          eclipseKind: _kind(e.eclipseType?.value ?? 0),
        ),
      );
      t = max + 20;
    }
    out.sort((a, b) => a.time.compareTo(b.time));
    return out;
  }

  static String _kind(int v) {
    if (v & 32 != 0) return 'hybrid';
    if (v & 4 != 0) return 'total';
    if (v & 8 != 0) return 'annular';
    if (v & 16 != 0) return 'partial';
    if (v & 64 != 0) return 'penumbral';
    return 'partial';
  }

  static double _step(Planet p) => switch (p) {
    Planet.moon => 0.25,
    Planet.sun || Planet.mercury || Planet.venus => 1,
    Planet.mars => 2,
    _ => 5,
  };
}
