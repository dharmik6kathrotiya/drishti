import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/feature_registry.dart';
import 'rectification_screen.dart';

/// Routes, More-screen entries and chart tabs contributed by this feature.
final List<GoRoute> routes = [
  GoRoute(path: '/rectify', builder: (_, _) => const RectificationScreen()),
  GoRoute(
    path: '/rectify/:id',
    builder: (_, s) => RectificationScreen(profileId: s.pathParameters['id']),
  ),
];

final List<MoreEntry> moreEntries = [
  MoreEntry(icon: Icons.manage_search, title: (l) => l.rectTitle, subtitle: (l) => l.rectSubtitle, route: '/rectify'),
];

final List<ChartTabBuilder> chartTabs = [];
