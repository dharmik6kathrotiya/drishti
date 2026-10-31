import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/ai/ai_memory.dart';
import '../../core/ai/answerer.dart';
import '../../core/ai/local_llm.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets/common.dart';
import 'ai_providers.dart';
import '../../ui/widgets/tool_info_button.dart';

/// "Ask Drishti": questions about the active profile's chart.
class AskScreen extends ConsumerStatefulWidget {
  const AskScreen({super.key, this.initialQuestion});
  final String? initialQuestion;

  @override
  ConsumerState<AskScreen> createState() => _AskScreenState();
}

class _Turn {
  _Turn(this.question, {this.detailed = false});
  final String question;

  /// Asked for the full reading ("More detail" or "explain in detail").
  final bool detailed;
  String partial = '';
  AiAnswer? answer;
  bool replaced = false;
}

class _AskScreenState extends ConsumerState<AskScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _turns = <_Turn>[];
  StreamSubscription<AskUpdate>? _sub;
  bool _historyLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuestion != null) _input.text = widget.initialQuestion!;
    // Load the model (if the user chose one) without blocking the screen.
    Future.microtask(() => ref.read(llmControllerProvider.notifier).ensureLoaded());
  }

  @override
  void dispose() {
    _sub?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadHistory(String profileId) async {
    if (_historyLoaded) return;
    _historyLoaded = true;
    final memory = await ref.read(aiMemoryProvider.future);
    if (!mounted) return;
    setState(() {
      for (final e in memory.history(profileId).reversed.take(10).toList().reversed) {
        _turns.add(_Turn(e.question)..answer = e.answer);
      }
    });
  }

  /// Asks [question] (or what was typed). Answers are short unless the user
  /// asks for detail in words or with the "More detail" button.
  Future<void> _send({String? question, bool detailed = false}) async {
    final q = question ?? _input.text.trim();
    detailed = detailed || asksForDetail(q);
    final profile = ref.read(activeProfileProvider);
    if (q.isEmpty || profile == null || _sub != null) return;
    final sheet = ref.read(factSheetProvider(profile.id));
    if (sheet == null) return;
    final lang = Localizations.localeOf(context).languageCode;
    final memory = await ref.read(aiMemoryProvider.future);
    final engine = AskEngine(
      fallback: RuleBasedAnswerer(lang),
      llm: ref.read(llmControllerProvider.notifier).llmFor(lang, q),
    );
    final turn = _Turn(q, detailed: detailed);
    setState(() {
      _turns.add(turn);
      if (question == null) _input.clear();
    });
    // Only the earlier questions, not their answers: long context makes small
    // models lose track of the current question.
    final recent = [
      for (final t
          in _turns.where((t) => t.answer != null && t.question != q).toList().reversed.take(3).toList().reversed)
        '- ${t.question}',
    ];
    _sub = engine
        .ask(
          q,
          sheet,
          teen: ref.read(settingsProvider).isTeen,
          memory: recent,
          lifeFacts: memory.lifeFacts(profile.id),
          detailed: detailed,
        )
        .listen(
          (u) {
            setState(() {
              if (u.isDone) {
                turn.answer = u.answer;
                turn.replaced = u.replacedModelOutput;
              } else {
                turn.partial = u.partialText!;
              }
            });
            _scrollToEnd();
          },
          onDone: () async {
            _sub = null;
            if (mounted) setState(() {});
            final a = turn.answer;
            if (a != null && !a.safetyResponse) {
              await memory.add(profile.id, MemoryEntry(question: q, answer: a, at: DateTime.now()));
            }
          },
        );
  }

  void _stop() {
    ref.read(llmControllerProvider.notifier).llm?.cancel();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final profile = ref.watch(activeProfileProvider);
    final llm = ref.watch(llmControllerProvider);

    if (profile == null || !profile.hasDate) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l.aiAskTitle),
          actions: const [ToolInfoButton(toolId: 'ai_guide')],
        ),
        body: EmptyState(icon: Icons.chat_bubble_outline, title: l.aiNoProfile),
      );
    }
    _loadHistory(profile.id);

    final suggestions = [l.aiSuggestPersonality, l.aiSuggestCareer, l.aiSuggestPeriod, l.aiSuggestStudies];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.aiAskTitle),
        actions: [
          const ToolInfoButton(toolId: 'ai_guide'),
          IconButton(
            tooltip: l.aiMemoryTitle,
            icon: const Icon(Icons.psychology_outlined),
            onPressed: () => context.push('/ai-memory'),
          ),
          IconButton(
            tooltip: l.aiModelTitle,
            icon: const Icon(Icons.memory),
            onPressed: () => context.push('/ai-model'),
          ),
        ],
      ),
      body: Column(
        children: [
          Material(
            color: theme.colorScheme.surfaceContainerHigh,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Icon(
                    llm.status == LlmStatus.ready ? Icons.memory : Icons.rule,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l.aiProfileFor(profile.name)} · '
                      '${switch (llm.status) {
                        LlmStatus.ready => l.aiModelMode,
                        LlmStatus.failed => l.aiLoadFailed,
                        _ => l.aiRuleMode,
                      }}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  if (llm.status == LlmStatus.loading)
                    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              children: [
                if (_turns.isEmpty) ...[
                  Text(l.aiTryAsking, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in suggestions)
                        ActionChip(label: Text(s), onPressed: () => setState(() => _input.text = s)),
                    ],
                  ),
                ],
                for (final t in _turns)
                  _TurnView(
                    turn: t,
                    onMoreDetail: _sub == null ? () => _send(question: t.question, detailed: true) : null,
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(hintText: l.aiAskHint),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _sub == null
                      ? IconButton.filled(tooltip: l.aiSend, icon: const Icon(Icons.send), onPressed: () => _send())
                      : IconButton.filledTonal(tooltip: l.aiStop, icon: const Icon(Icons.stop), onPressed: _stop),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TurnView extends StatelessWidget {
  const _TurnView({required this.turn, this.onMoreDetail});
  final _Turn turn;

  /// Asks the same question again for the full reading.
  final VoidCallback? onMoreDetail;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final a = turn.answer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8, left: 48),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(turn.detailed ? '${turn.question}\n(${l.aiMoreDetail})' : turn.question),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 16, right: 24),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: a == null
                ? Text(turn.partial.isEmpty ? '…' : stripCitations(turn.partial))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.displayText, style: theme.textTheme.bodyLarge),
                      if (!a.detailed && !a.safetyResponse && onMoreDetail != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            icon: const Icon(Icons.unfold_more),
                            label: Text(l.aiMoreDetail),
                            onPressed: onMoreDetail,
                          ),
                        ),
                      if (turn.replaced) ...[const SizedBox(height: 8), SourceNote(l.aiReplaced)],
                      // Short answers say what to expect; the chart reasons
                      // (planets, houses, periods) are one tap away.
                      if (a.factors.isNotEmpty || a.why != null)
                        ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          shape: const Border(),
                          title: Text(
                            a.why != null ? l.aiWhy : '${l.aiBasedOn} (${a.factors.length})',
                            style: theme.textTheme.titleSmall,
                          ),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (a.why != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(a.why!, style: theme.textTheme.bodyMedium),
                              ),
                            for (final f in a.factors)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(f.fact, style: theme.textTheme.titleSmall),
                                    Text(f.explanation, style: theme.textTheme.bodySmall),
                                    if (f.source.isNotEmpty)
                                      Text(
                                        '${l.aiSource}: ${f.source}',
                                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.secondary),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      if (a.improveWith.isNotEmpty) ...[
                        Text(l.aiImproveWith, style: theme.textTheme.titleSmall),
                        for (final s in a.improveWith) Text('• $s', style: theme.textTheme.bodySmall),
                        const SizedBox(height: 6),
                      ],
                      for (final n in a.notes) Padding(padding: const EdgeInsets.only(top: 4), child: SourceNote(n)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
