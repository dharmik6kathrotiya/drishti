import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/ai/explain_service.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets/common.dart';

/// Opens an offline explanation for [topic] in a bottom sheet.
Future<void> showExplainSheet(BuildContext context, ExplainTopic topic) {
  final lang = Localizations.localeOf(context).languageCode;
  final e = ExplainService(lang).explain(topic);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (sheetContext) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      builder: (_, controller) => _ExplainBody(explanation: e, controller: controller),
    ),
  );
}

class _ExplainBody extends StatelessWidget {
  const _ExplainBody({required this.explanation, required this.controller});
  final Explanation explanation;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final e = explanation;
    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(e.title, style: theme.textTheme.titleLarge)),
          ],
        ),
        const SizedBox(height: 12),
        for (final p in e.paragraphs.where((p) => p.trim().isNotEmpty))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(p, style: theme.textTheme.bodyLarge),
          ),
        if (e.source.isNotEmpty) ...[const SizedBox(height: 4), SourceNote(e.source)],
        const SizedBox(height: 8),
        SourceNote(e.caveat),
        if (e.suggestedQuestion != null) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.chat_bubble_outline),
            label: Text(l.aiAskMore),
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/ask', extra: e.suggestedQuestion);
            },
          ),
        ],
      ],
    );
  }
}

/// Small lightbulb button that opens an explanation.
class ExplainButton extends StatelessWidget {
  const ExplainButton({super.key, required this.topic, this.size = 20});
  final ExplainTopic topic;
  final double size;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: AppLocalizations.of(context).aiExplain,
    visualDensity: VisualDensity.compact,
    icon: Icon(Icons.lightbulb_outline, size: size, color: Theme.of(context).colorScheme.primary),
    onPressed: () => showExplainSheet(context, topic),
  );
}
