import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../core/astro/constants.dart';
import '../core/models/profile.dart';

/// Formatting helpers. Times are always shown in the relevant place's own
/// timezone (birthplace for natal data, Panchang place for daily timings).
class Fmt {
  Fmt._();

  static DateTime toLocal(DateTime utc, String? timezoneId) {
    if (timezoneId == null) return utc.toLocal();
    final loc = tz.getLocation(timezoneId);
    final t = tz.TZDateTime.from(utc, loc);
    return DateTime(t.year, t.month, t.day, t.hour, t.minute, t.second);
  }

  static String time(DateTime utc, String? timezoneId, [String? locale]) =>
      DateFormat.jm(locale).format(toLocal(utc, timezoneId));

  static String dateTime(DateTime utc, String? timezoneId, [String? locale]) =>
      DateFormat.yMMMd(locale).add_jm().format(toLocal(utc, timezoneId));

  static String date(DateTime d, [String? locale]) => DateFormat.yMMMd(locale).format(d);

  static String dateShort(DateTime d, [String? locale]) => DateFormat.yMMM(locale).format(d);

  static String longitude(double lon) => '${Sign.fromLongitude(lon).symbol} ${formatDms(lon % 30, seconds: false)}';

  static String birthSummary(Profile p, [String? locale]) {
    final parts = <String>[];
    if (p.birthDate != null) parts.add(date(p.birthDate!, locale));
    if (p.hasTime) {
      final t = DateTime(2000, 1, 1, p.birthHour!, p.birthMinute!);
      parts.add(DateFormat.jm(locale).format(t) + (p.timeAccuracy == TimeAccuracy.approximate ? ' (≈)' : ''));
    }
    if (p.place != null) parts.add(p.place!.name);
    return parts.join(' · ');
  }

  static String offset(int minutes) {
    final sign = minutes < 0 ? '-' : '+';
    final m = minutes.abs();
    return 'UTC$sign${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
  }

  static String capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
