import 'package:flutter/material.dart';

import '../../core/content/tool_guides/tool_guides.dart';
import '../../l10n/app_localizations.dart';
import '../i18n.dart';

/// Implemented by tabs that have a guide, so the screen hosting them (such as
/// the chart screen) can open the guide of the tab that is showing.
abstract interface class HasToolGuide {
  /// A stable id from [ToolGuides.ids].
  String get toolGuideId;
}

/// Info button that opens the "About this tool" guide for [toolId]: what the
/// tool is, why it is used, how it works, the math and science, and
/// references. Put it in AppBar `actions`, or (with [compact]) in a card
/// header such as [SectionCard.trailing].
class ToolInfoButton extends StatelessWidget {
  const ToolInfoButton({super.key, required this.toolId, this.compact = false});

  /// A stable id from [ToolGuides.ids].
  final String toolId;

  /// Smaller icon and padding, for card headers.
  final bool compact;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: AppLocalizations.of(context).toolInfoTooltip,
    icon: const Icon(Icons.info_outline),
    iconSize: compact ? 20 : null,
    visualDensity: compact ? VisualDensity.compact : null,
    onPressed: () => showToolGuide(context, toolId),
  );
}

/// Opens the guide for [toolId] in a scrollable bottom sheet, in the app's
/// language (English fallback). Does nothing for an unknown id.
Future<void> showToolGuide(BuildContext context, String toolId) async {
  final guide = ToolGuides.of(toolId, context.languageCode);
  if (guide == null) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, controller) => ToolGuideView(guide: guide, controller: controller),
    ),
  );
}

/// The body of a guide: title, the four text sections and the references.
class ToolGuideView extends StatelessWidget {
  const ToolGuideView({super.key, required this.guide, this.controller});

  final ToolGuide guide;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final body = theme.textTheme.bodyMedium?.copyWith(height: 1.45);

    Widget section(IconData icon, String heading, List<Widget> children) => Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(heading, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );

    List<Widget> paragraphs(String text) => [
      for (final p in text.split('\n\n').where((p) => p.trim().isNotEmpty))
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(p.trim(), style: body),
        ),
    ];

    return SelectionArea(
      child: ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Text(guide.title, style: theme.textTheme.titleLarge),
          section(Icons.help_outline, l.toolInfoWhat, paragraphs(guide.what)),
          section(Icons.lightbulb_outline, l.toolInfoWhy, paragraphs(guide.why)),
          section(Icons.settings_suggest_outlined, l.toolInfoHow, paragraphs(guide.how)),
          section(Icons.science_outlined, l.toolInfoScience, paragraphs(guide.science)),
          if (guide.references.isNotEmpty)
            section(Icons.menu_book_outlined, l.toolInfoReferences, [
              for (final (i, r) in guide.references.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 26, child: Text('${i + 1}.', style: theme.textTheme.bodySmall)),
                      Expanded(child: Text(r, style: theme.textTheme.bodySmall?.copyWith(height: 1.4))),
                    ],
                  ),
                ),
            ]),
        ],
      ),
    );
  }
}
