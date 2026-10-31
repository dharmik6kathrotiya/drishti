import 'package:flutter/material.dart';

import '../../core/astro/vedic/matching.dart';
import '../../core/i18n/engine_texts.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets/common.dart';

/// One koota in depth: what it is and the couple's result first, then on
/// "Why?" each person's value, the rule, the score and any dosha with the
/// classical exceptions checked.
Future<void> showKootaDetail(BuildContext context, KootaResult k) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useRootNavigator: true,
  showDragHandle: true,
  builder: (_) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.75,
    maxChildSize: 0.95,
    builder: (context, controller) => _KootaDetail(k: k, controller: controller),
  ),
);

class _KootaDetail extends StatelessWidget {
  const _KootaDetail({required this.k, required this.controller});
  final KootaResult k;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final et = EngineTexts.of(Localizations.localeOf(context).languageCode);
    final color = k.score >= k.max
        ? theme.colorScheme.primary
        : (k.score > 0 ? theme.colorScheme.secondary : theme.colorScheme.error);
    String fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
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

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Row(
          children: [
            Expanded(child: Text(et.kootaName(k), style: theme.textTheme.headlineSmall)),
            Text('${fmt(k.score)} / ${fmt(k.max)}', style: theme.textTheme.headlineSmall?.copyWith(color: color)),
          ],
        ),
        Text(et.kootaMeaning(k), style: theme.textTheme.bodyMedium),
        heading(Icons.menu_book_outlined, l.kootaWhatItIs),
        Text(et.kootaAbout(k)),
        heading(Icons.favorite_outline, l.kootaYourResult),
        Text(et.kootaResult(k), style: theme.textTheme.bodyLarge),
        if (k.doshaId != null) ...[
          const SizedBox(height: 10),
          Text(et.raw('match.dosha.${k.doshaId}.name'), style: theme.textTheme.titleSmall?.copyWith(color: color)),
          Text(et.raw('match.dosha.${k.doshaId}')),
          if (k.exceptions.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(et.raw(k.doshaCancelled ? 'match.dosha.cancelled' : 'match.dosha.counted')),
          ],
        ],
        const SizedBox(height: 12),
        // The real reasons stay one tap away, as everywhere in the app.
        Card(
          child: ExpansionTile(
            shape: const Border(),
            leading: const Icon(Icons.manage_search),
            title: Text(l.aiWhy, style: theme.textTheme.titleSmall),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              for (final (i, step) in et.kootaWhy(k).indexed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 24, child: Text('${i + 1}.', style: theme.textTheme.bodyMedium)),
                      Expanded(child: Text(step)),
                    ],
                  ),
                ),
              if (k.exceptions.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(l.kootaExceptionsChecked, style: theme.textTheme.titleSmall),
                for (final e in k.exceptions)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          e.applies ? Icons.check_circle_outline : Icons.remove_circle_outline,
                          size: 18,
                          color: e.applies ? theme.colorScheme.primary : theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text('${et.ref(e.rule)} · ${e.applies ? l.kootaApplies : l.kootaNotApplies}')),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 10),
              SourceNote(et.raw('match.source')),
            ],
          ),
        ),
      ],
    );
  }
}
