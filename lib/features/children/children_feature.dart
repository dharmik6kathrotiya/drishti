import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/feature_registry.dart';
import 'children_screen.dart';

/// Routes and More-screen entries contributed by this feature.
final List<GoRoute> routes = [GoRoute(path: '/children', builder: (_, _) => const ChildrenScreen())];

final List<MoreEntry> moreEntries = [
  MoreEntry(
    icon: Icons.child_care,
    title: (l) => l.childrenTitle,
    subtitle: (l) => l.childrenSubtitle,
    route: '/children',
    adultOnly: true,
  ),
];
