import 'dart:async';

import 'package:llamadart/llamadart.dart';

import 'answerer.dart';
import 'fact_sheet.dart';
import 'prompt.dart';
import 'safety.dart';

export 'prompt.dart';

/// A local language model that can stream an answer.
abstract class LocalLlm {
  bool get isReady;
  Future<void> load(String modelPath);
  Stream<String> generate({required String system, required String user, int maxTokens});
  void cancel();
  Future<void> dispose();
}

/// llama.cpp (GGUF) model via the llamadart package. All failures are thrown
/// as [LocalLlmUnavailable] so callers can fall back to rule-based answers.
class LlamadartLlm implements LocalLlm {
  LlamaEngine? _engine;

  @override
  bool get isReady => _engine?.isReady ?? false;

  @override
  Future<void> load(String modelPath) async {
    try {
      final previous = _engine;
      if (previous != null) {
        await previous.setModel(LlamaModel(ModelSource.path(modelPath)), params: const ModelParams(contextSize: 4096));
        return;
      }
      _engine = await LlamaEngine.load(
        LlamaModel(ModelSource.path(modelPath)),
        params: const ModelParams(contextSize: 4096),
      );
    } catch (e) {
      throw LocalLlmUnavailable('Could not load the model: $e');
    }
  }

  @override
  Stream<String> generate({required String system, required String user, int maxTokens = 1400}) async* {
    final engine = _engine;
    if (engine == null || !engine.isReady) throw LocalLlmUnavailable('Model not loaded');
    try {
      await for (final chunk in engine.create(
        [
          LlamaChatMessage.fromText(role: LlamaChatRole.system, text: system),
          LlamaChatMessage.fromText(role: LlamaChatRole.user, text: user),
        ],
        params: GenerationParams(maxTokens: maxTokens, temp: 0.4, topP: 0.9),
        enableThinking: false,
      )) {
        if (chunk.text.isNotEmpty) yield chunk.text;
      }
    } on LocalLlmUnavailable {
      rethrow;
    } catch (e) {
      throw LocalLlmUnavailable('Generation failed: $e');
    }
  }

  @override
  void cancel() {
    try {
      _engine?.cancelGeneration();
    } catch (_) {}
  }

  @override
  Future<void> dispose() async {
    final e = _engine;
    _engine = null;
    if (e != null) await e.dispose();
  }
}

class LocalLlmUnavailable implements Exception {
  LocalLlmUnavailable(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Checks a generated answer. Returns null if it is acceptable, otherwise the
/// list of problems (the caller then shows the rule-based answer instead).
List<String>? guardOutput(String text, FactSheet sheet) {
  final problems = Safety.violations(text);
  // Every fact id the model cites must exist in the sheet.
  for (final m in RegExp(r'\[([a-z0-9_.]+)\]').allMatches(text)) {
    final id = m.group(1)!;
    if (sheet.byId(id) == null) problems.add('unknown fact id $id');
  }
  return problems.isEmpty ? null : problems;
}

/// Orchestrates: safety gate → model (if installed) with guard → rule-based
/// fallback. Emits partial text while the model streams.
class AskEngine {
  AskEngine({required this.fallback, this.llm});

  final RuleBasedAnswerer fallback;
  final LocalLlm? llm;

  Stream<AskUpdate> ask(
    String question,
    FactSheet sheet, {
    bool teen = false,
    List<String> memory = const [],
    List<String> lifeFacts = const [],
    bool detailed = false,
  }) async* {
    final gate = fallback.gate(question, teen: teen);
    if (gate != null) {
      yield AskUpdate.done(gate);
      return;
    }
    final ruleAnswer = fallback.answer(question, sheet, teen: teen, detailed: detailed);
    final model = llm;
    // The model only rewords short "what to expect" answers. Full readings,
    // dates, periods and lifespan come from the calculation word for word:
    // a small model misstates such details too often (eval v6).
    if (model == null || !model.isReady || ruleAnswer.exact) {
      yield AskUpdate.done(ruleAnswer);
      return;
    }
    final buffer = StringBuffer();
    try {
      await for (final piece in model.generate(
        system: drishtiSystemPrompt,
        user: buildGroundedPrompt(
          sheet,
          question,
          languageCode: fallback.languageCode,
          memory: memory,
          lifeFacts: lifeFacts,
          detailed: detailed,
          // The engine's own answer decides which facts answer the question,
          // so a small model only has to explain them.
          focus: ruleAnswer.focusIds,
          tone: ruleAnswer.tone,
          keyPoints: ruleAnswer.keyPoints,
        ),
        // Short answers need few tokens; a cap also stops a small model rambling.
        maxTokens: detailed ? 700 : 260,
      )) {
        buffer.write(piece);
        // Stop as soon as a forbidden phrase appears instead of showing it.
        if (Safety.violations(buffer.toString()).isNotEmpty) {
          model.cancel();
          yield AskUpdate.done(ruleAnswer, replacedModelOutput: true);
          return;
        }
        yield AskUpdate.partial(buffer.toString());
      }
    } on LocalLlmUnavailable {
      yield AskUpdate.done(ruleAnswer);
      return;
    }
    final text = buffer.toString().trim();
    final contradictions = text.isEmpty ? const <String>[] : fallback.contradictions(text, ruleAnswer);
    final problems = text.isEmpty
        ? ['empty']
        : (guardOutput(text, sheet) ?? (contradictions.isEmpty ? null : contradictions));
    if (problems != null) {
      yield AskUpdate.done(ruleAnswer, replacedModelOutput: true);
      return;
    }
    yield AskUpdate.done(
      AiAnswer(
        text: text,
        factors: ruleAnswer.factors,
        notes: ruleAnswer.notes,
        improveWith: ruleAnswer.improveWith,
        fromModel: true,
        detailed: detailed,
        why: ruleAnswer.why,
        tone: ruleAnswer.tone,
      ),
    );
  }
}

class AskUpdate {
  AskUpdate.partial(this.partialText) : answer = null, replacedModelOutput = false;
  AskUpdate.done(AiAnswer this.answer, {this.replacedModelOutput = false}) : partialText = null;

  final String? partialText;
  final AiAnswer? answer;

  /// The model's text failed the safety/grounding guard and was replaced.
  final bool replacedModelOutput;
  bool get isDone => answer != null;
}
