import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/astro/vedic/festivals.dart';
import '../core/models/app_settings.dart';
import '../core/services/ads_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/widget_service.dart';
import '../features/festivals/festival_texts.dart';
import '../features/panchang/panchang_screen.dart';
import '../l10n/app_localizations.dart';
import 'providers.dart';

/// Keeps reminders, the home-screen widget and ads in sync with the user's
/// settings, profile and Panchang place. Refreshes are debounced and run after
/// the first frame so they never delay app start.
class BackgroundRefresh extends ConsumerStatefulWidget {
  const BackgroundRefresh({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<BackgroundRefresh> createState() => _BackgroundRefreshState();
}

class _BackgroundRefreshState extends ConsumerState<BackgroundRefresh> with WidgetsBindingObserver {
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _schedule(const Duration(seconds: 2)));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _schedule(const Duration(seconds: 2));
  }

  void _schedule([Duration delay = const Duration(milliseconds: 800)]) {
    _debounce?.cancel();
    _debounce = Timer(delay, _run);
  }

  Future<void> _run() async {
    if (!mounted) return;
    final settings = ref.read(settingsProvider);
    if (!settings.onboardingDone) return;
    final l = AppLocalizations.of(context);
    final profile = ref.read(activeProfileProvider);
    final place = ref.read(panchangPlaceProvider);
    // Each step is independent: a failure in one must never block the others.
    Future<void> step(String name, Future<void> Function() body) async {
      try {
        await body();
      } catch (e, s) {
        debugPrint('Background refresh ($name) failed: $e\n$s');
      }
    }

    await step('ads', () => AdsService.instance.init(teen: settings.isTeen));
    await step('widget', () => WidgetService.refresh(profile: profile, place: place, calc: settings.calc, l: l));
    await step('notifications', () async {
      var festivals = const <({DateTime date, String name})>[];
      if (settings.notifications.contains(NotificationType.festivals)) {
        final calc = FestivalCalculator(
          latitude: place.latitude,
          longitude: place.longitude,
          timezoneId: place.timezoneId,
          ayanamsa: settings.calc.ayanamsa,
        );
        final now = DateTime.now();
        final until = now.add(const Duration(days: 60));
        final texts = FestivalTexts.of(l.localeName);
        festivals = [
          for (final year in {now.year, until.year})
            for (final f in calc.year(year))
              if (f.type == FestivalType.festival && f.date.isAfter(now) && f.date.isBefore(until))
                (date: f.date, name: texts.name(f)),
        ];
      }
      await NotificationService.instance.reschedule(
        settings: settings,
        profile: profile,
        place: place,
        l: l,
        festivals: festivals,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(settingsProvider, (_, _) => _schedule());
    ref.listen(activeProfileProvider, (_, _) => _schedule());
    ref.listen(panchangPlaceProvider, (_, _) => _schedule());
    return widget.child;
  }
}
