import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/feature_registry.dart';
import '../../core/astro/vedic/festivals.dart';
import 'festival_calendar_screen.dart';
import 'festival_detail_screen.dart';
import 'muhurat_screen.dart';

/// Routes, More-screen entries and chart tabs contributed by this feature.
final List<GoRoute> routes = [
  GoRoute(path: '/festivals', builder: (_, _) => const FestivalCalendarScreen()),
  GoRoute(
    path: '/festivals/event',
    builder: (_, s) => FestivalDetailScreen(event: s.extra! as FestivalEvent),
  ),
  GoRoute(path: '/festivals/muhurat', builder: (_, _) => const MuhuratScreen()),
];

final List<MoreEntry> moreEntries = [
  MoreEntry(
    icon: Icons.celebration_outlined,
    title: (l) => l.festTitle,
    subtitle: (l) => l.festSubtitle,
    route: '/festivals',
  ),
  MoreEntry(
    icon: Icons.event_available_outlined,
    title: (l) => l.muhuratTitle,
    subtitle: (l) => l.muhuratSubtitle,
    route: '/festivals/muhurat',
  ),
];

final List<ChartTabBuilder> chartTabs = [];
