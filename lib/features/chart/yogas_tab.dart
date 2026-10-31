import '../../core/services/ads_service.dart';

import 'package:flutter/material.dart';

import '../../core/ai/explain_service.dart';
import '../../core/astro/chart.dart';
import '../../core/astro/vedic/yogas.dart';
import '../../core/i18n/engine_texts.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets/common.dart';
import '../ai/explain_sheet.dart';
import '../../ui/widgets/tool_info_button.dart';

class YogasTab extends StatelessWidget implements HasToolGuide {
  @override
  String get toolGuideId => 'yogas';

  const YogasTab({super.key, required this.chart});
  final Chart chart;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final yogas = YogaDetector.detect(chart);
    final et = EngineTexts.of(Localizations.localeOf(context).languageCode);
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SourceNote(l.yogasIntro),
        const SizedBox(height: 6),
        // Why other apps may list more: only full classical conditions count.
        SourceNote(et.raw('yoga.fewer')),
        const SizedBox(height: 12),
        if (yogas.isEmpty) EmptyState(icon: Icons.auto_awesome_outlined, title: l.noYogasFound),
        // What each yoga is for first; its condition and the chart reason
        // are one tap away.
        for (final (i, y) in yogas.indexed) ...[
          if (i == 3) const NativeSlot(medium: false),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SectionCard(
              title: et.yogaName(y),
              icon: Icons.auto_awesome,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showYoga(context, y),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(et.yogaMeaning(y)),
                  if (et.yogaNote(y) != null) ...[
                    const SizedBox(height: 6),
                    Text(et.yogaNote(y)!, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  static void _showYoga(BuildContext context, Yoga y) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (context) {
      final l = AppLocalizations.of(context);
      final theme = Theme.of(context);
      final et = EngineTexts.of(Localizations.localeOf(context).languageCode);
      Widget heading(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
            ),
          ],
        ),
      );
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Row(
              children: [
                Expanded(child: Text(et.yogaName(y), style: theme.textTheme.headlineSmall)),
                ExplainButton(topic: YogaTopic(y)),
              ],
            ),
            heading(Icons.menu_book_outlined, l.kootaWhatItIs),
            Text(et.yogaDef(y)),
            heading(Icons.lightbulb_outline, l.yogaWhatFor),
            Text(et.yogaMeaning(y), style: theme.textTheme.bodyLarge),
            if (et.yogaNote(y) != null) ...[const SizedBox(height: 6), Text(et.yogaNote(y)!)],
            const SizedBox(height: 12),
            Card(
              child: ExpansionTile(
                shape: const Border(),
                leading: const Icon(Icons.manage_search),
                title: Text(l.aiWhy, style: theme.textTheme.titleSmall),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [Text(et.yogaReason(y)), const SizedBox(height: 10), SourceNote(et.yogaSource(y))],
              ),
            ),
          ],
        ),
      );
    },
  );
}
