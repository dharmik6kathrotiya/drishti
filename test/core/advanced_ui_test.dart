import 'package:drishti/core/astro/chart.dart';
import 'package:drishti/core/astro/settings.dart';
import 'package:drishti/core/models/profile.dart';
import 'package:drishti/features/advanced/forecast_tab.dart';
import 'package:drishti/features/advanced/jaimini_tab.dart';
import 'package:drishti/features/advanced/lal_kitab_tab.dart';
import 'package:drishti/features/advanced/strength_tab.dart';
import 'package:drishti/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/ephemeris_setup.dart';

void main() {
  setUpAll(setUpEphemeris);

  final profile = Profile(
    id: 'p',
    name: 'Test',
    birthDate: DateTime(1990, 8, 15),
    birthHour: 10,
    birthMinute: 30,
    timeAccuracy: TimeAccuracy.exact,
    place: const Place(name: 'Mumbai', latitude: 19.076, longitude: 72.8777, timezoneId: 'Asia/Kolkata'),
  );

  Chart cast(AstroSystem system) => ChartCalculator.cast(
    utc: profile.birthUtc()!,
    settings: CalcSettings(system: system),
    latitude: 19.076,
    longitude: 72.8777,
  );

  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  }

  testWidgets('Strength tab renders', (t) => pump(t, StrengthTab(chart: cast(AstroSystem.vedic))));
  testWidgets('Jaimini tab renders', (t) => pump(t, JaiminiTab(chart: cast(AstroSystem.vedic), profile: profile)));
  testWidgets('Lal Kitab tab renders', (t) => pump(t, LalKitabTab(chart: cast(AstroSystem.vedic))));
  testWidgets('Forecast tab renders', (t) => pump(t, ForecastTab(chart: cast(AstroSystem.western), profile: profile)));
}
