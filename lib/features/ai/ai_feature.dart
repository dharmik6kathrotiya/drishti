import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/feature_registry.dart';
import 'ask_screen.dart';
import 'memory_screen.dart';
import 'model_screen.dart';

/// Routes, More-screen entries and chart tabs contributed by this feature.
final List<GoRoute> routes = [
  GoRoute(
    path: '/ask',
    builder: (_, s) => AskScreen(initialQuestion: s.extra is String ? s.extra as String : null),
  ),
  GoRoute(path: '/ai-model', builder: (_, _) => const ModelScreen()),
  GoRoute(path: '/ai-memory', builder: (_, _) => const MemoryScreen()),
];

final List<MoreEntry> moreEntries = [
  MoreEntry(
    icon: Icons.chat_bubble_outline,
    title: (l) => l.aiAskTitle,
    subtitle: (l) => l.aiAskSubtitle,
    route: '/ask',
  ),
  MoreEntry(icon: Icons.memory, title: (l) => l.aiModelTitle, subtitle: (l) => l.aiModelSubtitle, route: '/ai-model'),
];

final List<ChartTabBuilder> chartTabs = [];
