import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/app_localizations.dart';
import '../astro/settings.dart';
import '../astro/vedic/panchang.dart';
import '../horoscope/horoscope_generator.dart';
import '../i18n/astro_names.dart';
import '../models/profile.dart';

/// Pushes a week of pre-computed content to the Android home-screen widget.
/// The native widget picks today's entry by date, so it stays correct for
/// several days even if the app is not opened.
class WidgetService {
  WidgetService._();

  // The Kotlin package differs from the application id, so use the full name.
  static const _qualifiedAndroidName = 'app.drishti.drishti.TodayWidgetProvider';

  static Future<void> refresh({
    required Profile? profile,
    required Place place,
    required CalcSettings calc,
    required AppLocalizations l,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return;
    final loc = tz.getLocation(place.timezoneId);
    final now = tz.TZDateTime.now(loc);
    final days = <String, Map<String, String>>{};
    final names = AstroNames.of(l.localeName);
    String hm(DateTime utc) {
      final t = tz.TZDateTime.from(utc, loc);
      return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }

    for (var d = 0; d < 7; d++) {
      final date = DateTime(now.year, now.month, now.day).add(Duration(days: d));
      final offset = tz.TZDateTime(loc, date.year, date.month, date.day, 12).timeZoneOffset;
      final p = PanchangCalculator.compute(
        date: date,
        latitude: place.latitude,
        longitude: place.longitude,
        utcOffset: offset,
        ayanamsa: calc.ayanamsa,
      );
      var reading = '';
      if (profile != null && profile.hasDate) {
        final h = generate(
          subject: HoroscopeSubject.fromProfile(profile),
          period: HoroscopePeriod.daily,
          date: date,
          settings: calc,
          utcOffset: offset,
          languageCode: l.localeName,
        );
        reading = h.summary.split(RegExp(r'(?<=[.!?।])\s')).first;
      }
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      days[key] = {
        'title': '${names.vara(p.vara)} · ${names.pakshaFromEnglish(p.paksha)} ${names.tithi(p.tithi.index)}',
        'line1': reading.isEmpty ? '${l.nakshatra}: ${names.nakshatra(p.nakshatra.index)}' : reading,
        'line2': '${names.nakshatra(p.nakshatra.index)} · ${l.sunrise} ${hm(p.sunrise)} · ${place.name}',
        'line3': '${l.rahuKaal} ${hm(p.rahuKaal.start)}–${hm(p.rahuKaal.end)}',
      };
    }
    await HomeWidget.saveWidgetData<String>('days', jsonEncode(days));
    await HomeWidget.saveWidgetData<String>('fallback', l.widgetOpenApp);
    await HomeWidget.updateWidget(qualifiedAndroidName: _qualifiedAndroidName);
  }
}
