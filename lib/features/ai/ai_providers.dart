import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../app/providers.dart';
import '../../core/ai/ai_memory.dart';
import '../../core/ai/fact_sheet.dart';
import '../../core/ai/local_llm.dart';
import '../../core/ai/model_manager.dart';

final aiMemoryProvider = FutureProvider<AiMemory>((ref) => AiMemory.open());

final modelManagerProvider = FutureProvider<ModelManager>((ref) async {
  final dir = await getApplicationSupportDirectory();
  return ModelManager(Directory('${dir.path}/models'));
});

final modelCatalogueProvider = Provider<List<ModelInfo>>((ref) => loadCatalogue());

/// Fact sheet for a profile with the current calculation settings.
final factSheetProvider = Provider.family<FactSheet?, String>((ref, profileId) {
  final profile = profileById(ref.watch(profilesProvider), profileId);
  final calc = ref.watch(settingsProvider.select((s) => s.calc));
  if (profile == null) return null;
  return FactSheet.build(profile, calc);
});

enum LlmStatus { off, loading, ready, failed }

class LlmState {
  const LlmState(this.status, {this.modelId, this.error});
  final LlmStatus status;
  final String? modelId;
  final String? error;
}

/// Holds the loaded on-phone model (if any). Loading happens only when the
/// user has chosen a model and opens the chat.
class LlmController extends Notifier<LlmState> {
  LocalLlm? _llm;
  ModelInfo? _info;
  LocalLlm? get llm => state.status == LlmStatus.ready ? _llm : null;

  /// The loaded model, if it is reliable for [question] in [languageCode];
  /// otherwise null and the rule-based answerer is used.
  LocalLlm? llmFor(String languageCode, String question) =>
      (_info?.handles(languageCode, question) ?? false) ? llm : null;

  @override
  LlmState build() {
    ref.onDispose(() => _llm?.dispose());
    return const LlmState(LlmStatus.off);
  }

  /// Loads the model chosen in memory settings if it is installed.
  Future<void> ensureLoaded() async {
    if (state.status == LlmStatus.ready || state.status == LlmStatus.loading) return;
    final memory = await ref.read(aiMemoryProvider.future);
    final id = memory.activeModelId;
    if (id == null) return;
    final manager = await ref.read(modelManagerProvider.future);
    final info = ref.read(modelCatalogueProvider).where((m) => m.id == id).firstOrNull;
    if (info == null || !manager.isInstalled(info)) return;
    state = LlmState(LlmStatus.loading, modelId: id);
    try {
      final llm = _llm ?? LlamadartLlm();
      await llm.load(manager.fileFor(info).path);
      _llm = llm;
      _info = info;
      state = LlmState(LlmStatus.ready, modelId: id);
    } catch (e) {
      state = LlmState(LlmStatus.failed, modelId: id, error: '$e');
    }
  }

  Future<void> unload() async {
    await _llm?.dispose();
    _llm = null;
    _info = null;
    state = const LlmState(LlmStatus.off);
  }
}

final llmControllerProvider = NotifierProvider<LlmController, LlmState>(LlmController.new);
