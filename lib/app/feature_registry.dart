import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../core/astro/chart.dart';
import '../core/models/profile.dart';
import '../features/advanced/advanced_feature.dart' as advanced;
import '../features/ai/ai_feature.dart' as ai;
import '../features/children/children_feature.dart' as children;
import '../features/festivals/festivals_feature.dart' as festivals;
import '../features/rectification/rectification_feature.dart' as rectification;
import '../features/remedies/remedies_feature.dart' as remedies;
import '../features/wellness/wellness_feature.dart' as wellness;
import '../l10n/app_localizations.dart';

/// An entry on the "More" screen contributed by a feature module.
class MoreEntry {
  const MoreEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    this.adultOnly = false,
  });

  final IconData icon;
  final String Function(AppLocalizations l) title;
  final String Function(AppLocalizations l) subtitle;
  final String route;

  /// Hidden in teen mode.
  final bool adultOnly;
}

/// A tab contributed to the chart screen.
typedef ChartTabBuilder = (String, Widget)? Function(
  BuildContext context,
  AppLocalizations l,
  Profile profile,
  Chart chart,
);

/// Feature modules register themselves here so the shell files (router, More
/// screen, chart screen) never need to change when a feature is added.
class FeatureRegistry {
  FeatureRegistry._();

  static List<GoRoute> get routes => [
    ...festivals.routes,
    ...remedies.routes,
    ...wellness.routes,
    ...advanced.routes,
    ...ai.routes,
    ...rectification.routes,
    ...children.routes,
  ];

  static List<MoreEntry> get moreEntries => [
    ...festivals.moreEntries,
    ...remedies.moreEntries,
    ...wellness.moreEntries,
    ...advanced.moreEntries,
    ...ai.moreEntries,
    ...rectification.moreEntries,
    ...children.moreEntries,
  ];

  static List<ChartTabBuilder> get chartTabs => [...advanced.chartTabs, ...ai.chartTabs, ...rectification.chartTabs];
}
