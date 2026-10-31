// Generates the free daily content feed (static JSON, no server needed).
//
// Runs as a Flutter test so it can use the same astronomy engine as the app:
//   flutter test tool/feed/generate_feed_test.dart --dart-define=FEED_DATE=2026-10-27
// Output: feed/latest.json and feed/<date>.json (publish with GitHub Pages).
// Editorial announcements come from tool/feed/announcements.json.
import 'dart:convert';
import 'dart:io';

import 'package:drishti/core/astro/constants.dart';
import 'package:drishti/core/astro/settings.dart';
import 'package:drishti/core/astro/vedic/panchang.dart';
import 'package:drishti/core/horoscope/horoscope_generator.dart';
import 'package:drishti/core/horoscope/sky_events.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../test/helpers/ephemeris_setup.dart';

const feedVersion = 1;

/// Cities with a ready-made Panchang in the feed (the app still computes the
/// user's own location on the phone).
const cities = [
  ('New Delhi', 28.6139, 77.2090, 'Asia/Kolkata'),
  ('Mumbai', 19.0760, 72.8777, 'Asia/Kolkata'),
  ('Kolkata', 22.5726, 88.3639, 'Asia/Kolkata'),
  ('Chennai', 13.0827, 80.2707, 'Asia/Kolkata'),
  ('Bengaluru', 12.9716, 77.5946, 'Asia/Kolkata'),
  ('Hyderabad', 17.3850, 78.4867, 'Asia/Kolkata'),
  ('Ahmedabad', 23.0225, 72.5714, 'Asia/Kolkata'),
  ('Pune', 18.5204, 73.8567, 'Asia/Kolkata'),
  ('Varanasi', 25.3176, 82.9739, 'Asia/Kolkata'),
  ('London', 51.5072, -0.1276, 'Europe/London'),
  ('New York', 40.7128, -74.0060, 'America/New_York'),
  ('Dubai', 25.2048, 55.2708, 'Asia/Dubai'),
  ('Singapore', 1.3521, 103.8198, 'Asia/Singapore'),
];

void main() {
  setUpAll(setUpEphemeris);

  test('generate feed', () {
    const dateArg = String.fromEnvironment('FEED_DATE');
    final now = DateTime.now().toUtc();
    final date = dateArg.isEmpty ? DateTime(now.year, now.month, now.day) : DateTime.parse(dateArg);
    final dateKey = date.toIso8601String().substring(0, 10);

    Map<String, dynamic> horoscopes(AstroSystem system) => {
          for (final s in Sign.values)
            s.name: () {
              final h = generate(
                subject: HoroscopeSubject.forSign(s),
                period: HoroscopePeriod.daily,
                date: date,
                settings: CalcSettings(system: system),
                utcOffset: const Duration(hours: 5, minutes: 30),
              );
              return {'score': h.overallScore, 'summary': h.summary};
            }(),
        };

    final panchang = <String, dynamic>{};
    for (final (name, lat, lon, tzId) in cities) {
      final loc = tz.getLocation(tzId);
      final offset = tz.TZDateTime(loc, date.year, date.month, date.day, 12).timeZoneOffset;
      final p = PanchangCalculator.compute(date: date, latitude: lat, longitude: lon, utcOffset: offset);
      panchang[name] = {
        'tz': tzId,
        'vara': p.varaName,
        'tithi': '${p.paksha} ${p.tithi.name}',
        'tithiEnds': p.tithi.endsAt?.toIso8601String(),
        'nakshatra': p.nakshatra.name,
        'nakshatraEnds': p.nakshatra.endsAt?.toIso8601String(),
        'yoga': p.yoga.name,
        'karana': p.karana.name,
        'sunrise': p.sunrise.toIso8601String(),
        'sunset': p.sunset.toIso8601String(),
        'rahuKaal': [p.rahuKaal.start.toIso8601String(), p.rahuKaal.end.toIso8601String()],
        'month': p.lunarMonthAmanta,
      };
    }

    final from = DateTime.utc(date.year, date.month, date.day);
    final to = from.add(const Duration(days: 30));
    final events = [
      ...SkyEvents.ingresses(from, to, Planet.vedic, ayanamsa: Ayanamsa.lahiri),
      ...SkyEvents.stations(from, to, ayanamsa: Ayanamsa.lahiri),
      ...SkyEvents.eclipses(from, to.add(const Duration(days: 150))),
    ]..sort((a, b) => a.time.compareTo(b.time));

    final announcementsFile = File('tool/feed/announcements.json');
    final announcements = announcementsFile.existsSync()
        ? jsonDecode(announcementsFile.readAsStringSync())
        : <dynamic>[];

    final feed = {
      'version': feedVersion,
      'date': dateKey,
      'generatedAt': now.toIso8601String(),
      'announcements': announcements,
      'horoscopes': {'vedic': horoscopes(AstroSystem.vedic), 'western': horoscopes(AstroSystem.western)},
      'panchang': panchang,
      'skyEvents': [
        for (final e in events)
          {
            'type': e.type.name,
            'time': e.time.toIso8601String(),
            if (e.planet != null) 'planet': e.planet!.name,
            if (e.sign != null) 'sign': e.sign!.name,
            if (e.eclipseKind != null) 'kind': e.eclipseKind,
          },
      ],
    };

    final json = const JsonEncoder.withIndent('  ').convert(feed);
    Directory('feed').createSync(recursive: true);
    File('feed/$dateKey.json').writeAsStringSync(json);
    File('feed/latest.json').writeAsStringSync(json);
    expect(File('feed/latest.json').existsSync(), isTrue);
  });
}
