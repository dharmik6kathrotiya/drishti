import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/feature_registry.dart';
import 'journal/journal_screens.dart';
import 'meditation/meditation_screen.dart';
import 'palmistry/palmistry_screen.dart';
import 'tarot/tarot_screens.dart';
import 'tarot/tarot_store.dart';

/// Routes, More-screen entries and chart tabs contributed by this feature.
final List<GoRoute> routes = [
  GoRoute(path: '/tarot', builder: (_, _) => const TarotScreen()),
  GoRoute(
    path: '/tarot/spread/:spread',
    builder: (_, s) => TarotSpreadScreen(
      spread: TarotSpread.values.firstWhere(
        (x) => x.name == s.pathParameters['spread'],
        orElse: () => TarotSpread.three,
      ),
    ),
  ),
  GoRoute(
    path: '/tarot/reading/:id',
    builder: (_, s) => TarotReadingScreen(readingId: s.pathParameters['id']!),
  ),
  GoRoute(path: '/journal', builder: (_, _) => const JournalScreen()),
  GoRoute(
    path: '/journal/edit',
    builder: (_, s) => JournalEntryScreen(date: s.extra is DateTime ? s.extra as DateTime : null),
  ),
  GoRoute(path: '/meditation', builder: (_, _) => const MeditationScreen()),
  GoRoute(path: '/palmistry', builder: (_, _) => const PalmistryScreen()),
];

final List<MoreEntry> moreEntries = [
  MoreEntry(icon: Icons.style_outlined, title: (l) => l.tarotTitle, subtitle: (l) => l.tarotSubtitle, route: '/tarot'),
  MoreEntry(
    icon: Icons.mood_outlined,
    title: (l) => l.journalTitle,
    subtitle: (l) => l.journalSubtitle,
    route: '/journal',
  ),
  MoreEntry(
    icon: Icons.self_improvement,
    title: (l) => l.wellnessMeditationTitle,
    subtitle: (l) => l.wellnessMeditationSubtitle,
    route: '/meditation',
  ),
  MoreEntry(
    icon: Icons.back_hand_outlined,
    title: (l) => l.palmTitle,
    subtitle: (l) => l.palmSubtitle,
    route: '/palmistry',
  ),
];

final List<ChartTabBuilder> chartTabs = [];
