import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/ai/ai_memory.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/format.dart';
import '../../ui/widgets/common.dart';
import 'ai_providers.dart';
import '../../ui/widgets/tool_info_button.dart';

/// Shows and deletes what the AI helper remembers for the active profile.
class MemoryScreen extends ConsumerStatefulWidget {
  const MemoryScreen({super.key});

  @override
  ConsumerState<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends ConsumerState<MemoryScreen> {
  Future<bool> _confirm() async {
    final l = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            content: Text(l.aiClearConfirm),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.aiCancel)),
              FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.aiConfirm)),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _addFact(AiMemory memory, String profileId) async {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.aiAddLifeFact),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l.aiLifeFactHint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text(l.aiCancel)),
          FilledButton(onPressed: () => Navigator.pop(c, controller.text.trim()), child: Text(l.aiAdd)),
        ],
      ),
    );
    if (text == null || text.isEmpty) return;
    await memory.setLifeFacts(profileId, [...memory.lifeFacts(profileId), text]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final profile = ref.watch(activeProfileProvider);
    final memoryAsync = ref.watch(aiMemoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.aiMemoryTitle),
        actions: const [ToolInfoButton(toolId: 'ai_guide')],
      ),
      body: memoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (memory) {
          if (profile == null) return EmptyState(icon: Icons.psychology_outlined, title: l.aiNoProfile);
          final facts = memory.lifeFacts(profile.id);
          final history = memory.history(profile.id).reversed.toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SectionCard(
                title: l.aiLifeFacts,
                icon: Icons.sticky_note_2_outlined,
                trailing: IconButton(icon: const Icon(Icons.add), onPressed: () => _addFact(memory, profile.id)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.aiLifeFactsInfo, style: theme.textTheme.bodySmall),
                    for (var i = 0; i < facts.length; i++)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(facts[i]),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () async {
                            await memory.setLifeFacts(profile.id, [...facts]..removeAt(i));
                            setState(() {});
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(l.aiHistory, style: theme.textTheme.titleMedium),
              if (history.isEmpty) Padding(padding: const EdgeInsets.all(8), child: Text(l.aiMemoryEmpty)),
              for (final e in history)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(e.question),
                  subtitle: Text(e.answer.text, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Text(Fmt.dateShort(e.at), style: theme.textTheme.bodySmall),
                ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: Text(l.aiClearHistory),
                onPressed: () async {
                  if (await _confirm()) {
                    await memory.clearProfile(profile.id);
                    setState(() {});
                  }
                },
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                icon: Icon(Icons.delete_forever_outlined, color: theme.colorScheme.error),
                label: Text(l.aiClearAll, style: TextStyle(color: theme.colorScheme.error)),
                onPressed: () async {
                  if (await _confirm()) {
                    await memory.clearAll();
                    setState(() {});
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
