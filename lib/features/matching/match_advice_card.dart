import 'package:flutter/material.dart';

import '../../core/astro/vedic/match_advice.dart';
import '../../core/i18n/engine_texts.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets/common.dart';

/// The whole match in plain words first: the conclusion, what is strong, what
/// needs care and what to do. The koota, dosha or aspect behind each point is
/// one tap away under "Why?".
class MatchAdviceCard extends StatelessWidget {
  const MatchAdviceCard({super.key, required this.advice});
  final MatchAdvice advice;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final et = EngineTexts.of(Localizations.localeOf(context).languageCode);

    Widget heading(IconData icon, String text, Color color) => Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: theme.textTheme.titleSmall?.copyWith(color: color)),
          ),
        ],
      ),
    );
    Widget bullet(String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
    final reasons = [...advice.strengths, ...advice.cautions].where((p) => p.why.isNotEmpty).toList();

    return SectionCard(
      title: l.matchAdviceTitle,
      icon: Icons.lightbulb_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(et.ref(advice.summary), style: theme.textTheme.bodyLarge),
          if (advice.strengths.isNotEmpty) ...[
            heading(Icons.check_circle_outline, l.matchAdviceStrengths, theme.colorScheme.primary),
            for (final p in advice.strengths) bullet(et.ref(p.text)),
          ],
          if (advice.cautions.isNotEmpty) ...[
            heading(Icons.error_outline, l.matchAdviceCautions, theme.colorScheme.error),
            for (final p in advice.cautions) bullet(et.ref(p.text)),
          ],
          heading(Icons.directions_walk, l.matchAdviceSteps, theme.colorScheme.secondary),
          for (final s in advice.steps) bullet(et.ref(s)),
          if (advice.remedies.isNotEmpty) ...[
            heading(Icons.self_improvement, l.matchAdviceRemedies, theme.colorScheme.secondary),
            for (final r in advice.remedies) bullet(et.ref(r)),
          ],
          if (reasons.isNotEmpty) ...[
            const SizedBox(height: 10),
            Card(
              margin: EdgeInsets.zero,
              child: ExpansionTile(
                shape: const Border(),
                leading: const Icon(Icons.manage_search),
                title: Text(l.aiWhy, style: theme.textTheme.titleSmall),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  for (final p in reasons) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 2),
                      child: Text(et.ref(p.text), style: theme.textTheme.titleSmall),
                    ),
                    for (final w in p.why) Text('• ${et.ref(w)}', style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
