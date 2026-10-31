import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/ai_memory.dart';
import '../../core/ai/model_manager.dart';
import '../../core/ai/prompt.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets/common.dart';
import 'ai_providers.dart';
import '../../ui/widgets/tool_info_button.dart';

class ModelScreen extends ConsumerStatefulWidget {
  const ModelScreen({super.key});

  @override
  ConsumerState<ModelScreen> createState() => _ModelScreenState();
}

class _ModelScreenState extends ConsumerState<ModelScreen> {
  final _progress = <String, DownloadProgress>{};
  StreamSubscription<DownloadProgress>? _sub;
  String? _downloadingId;
  String? _error;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  static String _size(int bytes) =>
      bytes >= 1e9 ? '${(bytes / 1e9).toStringAsFixed(1)} GB' : '${(bytes / 1e6).toStringAsFixed(0)} MB';

  /// Wi-Fi or Ethernet. Unknown counts as "not on Wi-Fi", so the user is asked.
  static Future<bool> _onWifi() async {
    try {
      final r = await Connectivity().checkConnectivity();
      return r.contains(ConnectivityResult.wifi) || r.contains(ConnectivityResult.ethernet);
    } catch (_) {
      return false;
    }
  }

  Future<void> _download(ModelManager manager, ModelInfo m) async {
    final l = AppLocalizations.of(context);
    final memory = await ref.read(aiMemoryProvider.future);
    if (!mounted) return;
    if (memory.wifiOnly && !await _onWifi()) {
      if (!mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(l.aiNotOnWifiTitle),
          content: Text(l.aiNotOnWifiBody(_size(m.sizeBytes))),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.aiCancel)),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.aiDownloadAnyway)),
          ],
        ),
      );
      if (ok != true) return;
    }
    if (!mounted) return;
    setState(() {
      _downloadingId = m.id;
      _error = null;
    });
    _sub = manager
        .download(m)
        .listen(
          (p) => setState(() => _progress[m.id] = p),
          onError: (Object e) => setState(() {
            _error = '$e';
            _downloadingId = null;
            _sub = null;
          }),
          onDone: () => setState(() {
            _downloadingId = null;
            _sub = null;
          }),
          cancelOnError: true,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final managerAsync = ref.watch(modelManagerProvider);
    final memoryAsync = ref.watch(aiMemoryProvider);
    final catalogue = ref.watch(modelCatalogueProvider);
    final llm = ref.watch(llmControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.aiModelTitle),
        actions: const [ToolInfoButton(toolId: 'ai_guide')],
      ),
      body: managerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (manager) {
          final memory = memoryAsync.value;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SourceNote(l.aiModelIntro),
              const SizedBox(height: 8),
              if (memory != null)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.aiWifiOnly),
                  subtitle: Text(l.aiWifiOnlyInfo),
                  value: memory.wifiOnly,
                  onChanged: (v) async {
                    await memory.setWifiOnly(v);
                    setState(() {});
                  },
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                ),
              for (final m in catalogue)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SectionCard(
                    title: m.name,
                    icon: Icons.memory,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.description),
                        const SizedBox(height: 4),
                        Text('${_size(m.sizeBytes)} · ${l.aiMinRam(m.minRamGb)}', style: theme.textTheme.bodySmall),
                        Text(l.aiLicense(m.license), style: theme.textTheme.bodySmall),
                        Text(
                          l.aiModelLanguages([for (final c in m.languages) answerLanguageNames[c] ?? c].join(', ')),
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 10),
                        _actions(context, manager, m, memory, llm),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _actions(BuildContext context, ModelManager manager, ModelInfo m, AiMemory? memory, LlmState llm) {
    final l = AppLocalizations.of(context);
    // A copied-in (sideloaded) model can be tried before it is published.
    if (!m.isPublished && !manager.isInstalled(m)) return Chip(label: Text(l.aiNotReleased));
    if (_downloadingId == m.id) {
      final p = _progress[m.id];
      final pct = p?.fraction == null ? '…' : (p!.fraction! * 100).toStringAsFixed(0);
      return Row(
        children: [
          Expanded(child: LinearProgressIndicator(value: p?.fraction)),
          const SizedBox(width: 8),
          Text(l.aiDownloading(pct)),
          TextButton(onPressed: manager.cancel, child: Text(l.aiPause)),
        ],
      );
    }
    if (!manager.isInstalled(m)) {
      return FilledButton.icon(
        icon: const Icon(Icons.download),
        label: Text(manager.partialBytes(m) > 0 ? l.aiResume : l.aiDownload),
        onPressed: _downloadingId == null ? () => _download(manager, m) : null,
      );
    }
    final inUse = memory?.activeModelId == m.id;
    return Wrap(
      spacing: 8,
      children: [
        Chip(label: Text(inUse ? l.aiInUse : l.aiInstalled)),
        if (!inUse)
          FilledButton(
            onPressed: () async {
              await memory?.setActiveModelId(m.id);
              await ref.read(llmControllerProvider.notifier).unload();
              setState(() {});
            },
            child: Text(l.aiUse),
          )
        else
          OutlinedButton(
            onPressed: () async {
              await memory?.setActiveModelId(null);
              await ref.read(llmControllerProvider.notifier).unload();
              setState(() {});
            },
            child: Text(l.aiStopUsing),
          ),
        TextButton(
          onPressed: () async {
            if (inUse) {
              await memory?.setActiveModelId(null);
              await ref.read(llmControllerProvider.notifier).unload();
            }
            await manager.delete(m);
            setState(() {});
          },
          child: Text(l.aiDelete),
        ),
      ],
    );
  }
}
