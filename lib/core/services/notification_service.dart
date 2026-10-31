import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/app_localizations.dart';
import '../astro/constants.dart';
import '../astro/settings.dart';
import '../astro/vedic/panchang.dart';
import '../horoscope/horoscope_generator.dart';
import '../horoscope/sky_events.dart';
import '../i18n/astro_names.dart';
import '../models/app_settings.dart';
import '../models/profile.dart';

/// Opt-in local reminders. Everything is computed on the phone and scheduled
/// ahead of time (a week of daily items, a month of transit alerts); the app
/// refreshes the schedule whenever it is opened or settings change.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _channel = AndroidNotificationDetails(
    'drishti_daily',
    'Daily reminders',
    channelDescription: 'Horoscope, Panchang and timing reminders you turned on',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    styleInformation: BigTextStyleInformation(''),
  );
  static const _details = NotificationDetails(android: _channel, iOS: DarwinNotificationDetails());

  // Id ranges per notification type so each type can be rescheduled alone.
  static const _base = {
    NotificationType.dailyHoroscope: 1000,
    NotificationType.panchang: 2000,
    NotificationType.rahuKaal: 3000,
    NotificationType.transitAlerts: 4000,
    NotificationType.festivals: 5000,
  };

  Future<void> init() async {
    if (_ready || kIsWeb) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  /// Asks the OS for permission (Android 13+, iOS). Only called when the user
  /// turns a reminder on.
  Future<bool> requestPermission() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) return await android.requestNotificationsPermission() ?? false;
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) return await ios.requestPermissions(alert: true, sound: true) ?? false;
    return true;
  }

  /// Rebuilds the whole schedule from the current settings.
  Future<void> reschedule({
    required AppSettings settings,
    required Profile? profile,
    required Place place,
    required AppLocalizations l,
    List<({DateTime date, String name})> festivals = const [],
  }) async {
    if (kIsWeb) return;
    await init();
    await _plugin.cancelAllPendingNotifications();
    final enabled = settings.notifications;
    if (enabled.isEmpty) return;

    final loc = tz.getLocation(place.timezoneId);
    final now = tz.TZDateTime.now(loc);
    final today = DateTime(now.year, now.month, now.day);
    final names = AstroNames.of(l.localeName);

    Future<void> at(int id, tz.TZDateTime when, String title, String body) async {
      if (!when.isAfter(now)) return;
      await _plugin.zonedSchedule(
        id: id,
        scheduledDate: when,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: title,
        body: body,
      );
    }

    for (var d = 0; d < 7; d++) {
      final date = today.add(Duration(days: d));
      final offset = tz.TZDateTime(loc, date.year, date.month, date.day, 12).timeZoneOffset;
      final p = PanchangCalculator.compute(
        date: date,
        latitude: place.latitude,
        longitude: place.longitude,
        utcOffset: offset,
        ayanamsa: settings.calc.ayanamsa,
      );
      final sunrise = tz.TZDateTime.from(p.sunrise, loc);
      final morning = tz.TZDateTime(loc, date.year, date.month, date.day, 7);
      final morningTime = sunrise.isAfter(morning) ? sunrise : morning;

      if (enabled.contains(NotificationType.panchang)) {
        await at(
          _base[NotificationType.panchang]! + d,
          morningTime,
          l.notifPanchangTitle(names.vara(p.vara)),
          '${names.pakshaFromEnglish(p.paksha)} ${names.tithi(p.tithi.index)} · ${names.nakshatra(p.nakshatra.index)} · ${l.rahuKaal} '
          '${_hm(tz.TZDateTime.from(p.rahuKaal.start, loc))}–${_hm(tz.TZDateTime.from(p.rahuKaal.end, loc))}',
        );
      }
      if (enabled.contains(NotificationType.rahuKaal)) {
        final start = tz.TZDateTime.from(p.rahuKaal.start, loc);
        await at(
          _base[NotificationType.rahuKaal]! + d,
          start.subtract(const Duration(minutes: 5)),
          l.notifRahuKaalTitle,
          l.notifRahuKaalBody(_hm(start), _hm(tz.TZDateTime.from(p.rahuKaal.end, loc))),
        );
      }
      if (enabled.contains(NotificationType.dailyHoroscope) && profile != null && profile.hasDate) {
        final h = generate(
          subject: HoroscopeSubject.fromProfile(profile),
          period: HoroscopePeriod.daily,
          date: date,
          settings: settings.calc,
          utcOffset: offset,
          languageCode: l.localeName,
        );
        await at(
          _base[NotificationType.dailyHoroscope]! + d,
          morningTime.add(const Duration(minutes: 1)),
          l.notifHoroscopeTitle(profile.name),
          h.summary,
        );
      }
    }

    if (enabled.contains(NotificationType.transitAlerts)) {
      final from = DateTime.now().toUtc();
      final to = from.add(const Duration(days: 45));
      final ayan = settings.calc.system == AstroSystem.vedic ? settings.calc.ayanamsa : null;
      final events = [
        ...SkyEvents.ingresses(
          from,
          to,
          const [Planet.jupiter, Planet.saturn, Planet.rahu, Planet.mars, Planet.sun],
          ayanamsa: ayan,
          node: settings.calc.nodeType,
        ),
        ...SkyEvents.stations(from, to, ayanamsa: ayan),
      ]..sort((a, b) => a.time.compareTo(b.time));
      var i = 0;
      for (final e in events.take(30)) {
        final when = tz.TZDateTime.from(e.time, loc);
        final planet = e.planet == null ? '' : names.planet(e.planet!);
        final sign = e.sign == null ? '' : (ayan != null ? names.rashi(e.sign!) : names.sign(e.sign!));
        final body = switch (e.type) {
          SkyEventType.ingress => l.notifIngress(planet, sign),
          SkyEventType.stationRetrograde => l.notifRetro(planet, sign),
          SkyEventType.stationDirect => l.notifDirect(planet, sign),
          _ => '',
        };
        if (body.isEmpty) continue;
        await at(_base[NotificationType.transitAlerts]! + i++, when, l.notifTransitTitle, body);
      }
    }

    if (enabled.contains(NotificationType.festivals)) {
      var i = 0;
      for (final f in festivals) {
        final eve = tz.TZDateTime(loc, f.date.year, f.date.month, f.date.day).subtract(const Duration(hours: 5));
        await at(_base[NotificationType.festivals]! + i++, eve, l.notifFestivalTitle, l.notifFestivalBody(f.name));
        if (i >= 60) break;
      }
    }
  }

  static String _hm(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
