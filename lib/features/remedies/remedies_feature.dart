import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/feature_registry.dart';
import '../../core/astro/constants.dart';
import 'remedies_screen.dart';

/// Routes, More-screen entries and chart tabs contributed by this feature.
final List<GoRoute> routes = [
  GoRoute(path: '/remedies', builder: (_, _) => const RemediesScreen()),
  GoRoute(
    path: '/remedies/graha/:planet',
    builder: (_, s) => GrahaRemedyScreen(
      planet: Planet.values.firstWhere((p) => p.name == s.pathParameters['planet'], orElse: () => Planet.sun),
    ),
  ),
];

final List<MoreEntry> moreEntries = [
  MoreEntry(
    icon: Icons.spa_outlined,
    title: (l) => l.remedyTitle,
    subtitle: (l) => l.remedySubtitle,
    route: '/remedies',
  ),
];

final List<ChartTabBuilder> chartTabs = [];
