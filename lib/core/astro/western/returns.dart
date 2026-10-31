import '../chart.dart';
import '../constants.dart';
import '../ephemeris.dart';
import '../settings.dart';

/// Solar and lunar return charts (tropical).
class Returns {
  Returns._();

  static double _tropical(Chart natal, double lon) =>
      norm360(lon + (natal.settings.sidereal ? natal.ayanamsaValue : 0));

  /// Moment (UTC) the transiting Sun returns to its natal tropical longitude
  /// in [year]. The search starts a few days before the birthday.
  static DateTime solarReturnTime(Chart natal, DateTime birthUtc, int year) {
    final start = DateTime.utc(year, birthUtc.month, birthUtc.day).subtract(const Duration(days: 5));
    final jd = Ephemeris.sunCrossing(_tropical(natal, natal.sun.longitude), Ephemeris.julianDay(start));
    return Ephemeris.dateTimeFromJd(jd);
  }

  /// Solar return chart for [year], cast for a place (usually where the
  /// person lives that year; defaults to the birthplace).
  static Chart solarReturn(
    Chart natal,
    DateTime birthUtc,
    int year, {
    double? latitude,
    double? longitude,
    CalcSettings? settings,
  }) => ChartCalculator.cast(
    utc: solarReturnTime(natal, birthUtc, year),
    settings: settings ?? natal.settings.copyWith(system: AstroSystem.western),
    latitude: latitude ?? natal.latitude,
    longitude: longitude ?? natal.longitude,
  );

  /// Next lunar return after [after]: the Moon back at its natal longitude.
  static Chart lunarReturn(Chart natal, DateTime after, {double? latitude, double? longitude, CalcSettings? settings}) {
    final jd = Ephemeris.moonCrossing(_tropical(natal, natal.moon.longitude), Ephemeris.julianDay(after));
    return ChartCalculator.cast(
      utc: Ephemeris.dateTimeFromJd(jd),
      settings: settings ?? natal.settings.copyWith(system: AstroSystem.western),
      latitude: latitude ?? natal.latitude,
      longitude: longitude ?? natal.longitude,
    );
  }
}
