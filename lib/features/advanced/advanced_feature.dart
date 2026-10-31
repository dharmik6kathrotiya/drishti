import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/feature_registry.dart';
import '../../core/astro/chart.dart';
import '../../core/astro/settings.dart';
import 'composite_screen.dart';
import 'forecast_tab.dart';
import 'jaimini_tab.dart';
import 'lal_kitab_tab.dart';
import 'strength_tab.dart';

/// Routes, More-screen entries and chart tabs contributed by this feature.
final List<GoRoute> routes = [GoRoute(path: '/composite', builder: (_, _) => const CompositeScreen())];

final List<MoreEntry> moreEntries = [
  MoreEntry(
    icon: Icons.join_inner,
    title: (l) => l.advComposite,
    subtitle: (l) => l.advCompositeSubtitle,
    route: '/composite',
  ),
];

bool _vedic(Chart chart) => chart.settings.system == AstroSystem.vedic;

final List<ChartTabBuilder> chartTabs = [
  // Shadbala and Ashtakavarga need the Lagna and the birth moment.
  (context, l, profile, chart) =>
      _vedic(chart) && profile.canCastFullChart ? (l.advTabStrength, StrengthTab(chart: chart)) : null,
  (context, l, profile, chart) =>
      _vedic(chart) && profile.canCastFullChart ? (l.advTabJaimini, JaiminiTab(chart: chart, profile: profile)) : null,
  // Lal Kitab uses signs only, so it works without a birth time.
  (context, l, profile, chart) => _vedic(chart) ? (l.advTabLalKitab, LalKitabTab(chart: chart)) : null,
  (context, l, profile, chart) =>
      !_vedic(chart) ? (l.advTabForecast, ForecastTab(chart: chart, profile: profile)) : null,
];
