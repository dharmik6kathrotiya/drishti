import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// One selectable option with an optional explanation. The popular default
/// is flagged [recommended] and shown with a badge.
class PickOption<T> {
  const PickOption({required this.value, required this.label, this.description, this.recommended = false});

  final T value;
  final String label;
  final String? description;
  final bool recommended;
}

/// Bottom sheet implementing the "choose, learn, or use the popular default"
/// pattern: every option can be selected, each has a hidden "What's this?"
/// explanation, and the recommended one is marked.
Future<T?> showOptionPicker<T>(
  BuildContext context, {
  required String title,
  required List<PickOption<T>> options,
  required T selected,
  String? subtitle,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: options.length > 5 ? 0.75 : 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.92,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 12),
          for (final o in options)
            OptionCard<T>(option: o, selected: o.value == selected, onTap: () => Navigator.of(context).pop(o.value)),
        ],
      ),
    ),
  );
}

class OptionCard<T> extends StatefulWidget {
  const OptionCard({super.key, required this.option, required this.selected, required this.onTap});

  final PickOption<T> option;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<OptionCard<T>> createState() => _OptionCardState<T>();
}

class _OptionCardState<T> extends State<OptionCard<T>> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final o = widget.option;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: widget.selected ? scheme.primary.withValues(alpha: 0.12) : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: widget.selected ? scheme.primary : scheme.outline,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(o.label, style: Theme.of(context).textTheme.titleSmall),
                          if (o.recommended) RecommendedBadge(label: l.recommended),
                        ],
                      ),
                    ),
                    if (o.description != null)
                      IconButton(
                        tooltip: l.whatsThis,
                        icon: Icon(_expanded ? Icons.expand_less : Icons.info_outline, size: 20),
                        onPressed: () => setState(() => _expanded = !_expanded),
                      ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(34, 4, 12, 2),
                    child: Text(o.description ?? '', style: Theme.of(context).textTheme.bodySmall),
                  ),
                  crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 180),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RecommendedBadge extends StatelessWidget {
  const RecommendedBadge({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.secondary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.secondary)),
    );
  }
}

/// Settings row that shows the current choice and opens [showOptionPicker].
class OptionSettingTile<T> extends StatelessWidget {
  const OptionSettingTile({
    super.key,
    required this.title,
    required this.options,
    required this.value,
    required this.onChanged,
    this.icon,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<PickOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final current = options.firstWhere((o) => o.value == value, orElse: () => options.first);
    return ListTile(
      leading: icon == null ? null : Icon(icon),
      title: Text(title),
      subtitle: Text(current.label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final v = await showOptionPicker<T>(
          context,
          title: title,
          subtitle: subtitle,
          options: options,
          selected: value,
        );
        if (v != null) onChanged(v);
      },
    );
  }
}
