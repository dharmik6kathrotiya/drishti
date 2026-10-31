import '../../../core/services/ads_service.dart';
import 'tarot_astro_label.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/content/tarot/tarot_deck.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/format.dart';
import '../../../ui/widgets/common.dart';
import 'tarot_card_view.dart';
import 'tarot_store.dart';
import '../../../ui/widgets/tool_info_button.dart';

List<String> spreadPositions(TarotSpread s, AppLocalizations l) => switch (s) {
  TarotSpread.three => [l.tarotPositionPast, l.tarotPositionPresent, l.tarotPositionFuture],
  TarotSpread.celtic => [
    l.tarotPositionSituation,
    l.tarotPositionChallenge,
    l.tarotPositionFoundation,
    l.tarotPositionRecentPast,
    l.tarotPositionPossibility,
    l.tarotPositionNearFuture,
    l.tarotPositionSelf,
    l.tarotPositionEnvironment,
    l.tarotPositionHopesFears,
    l.tarotPositionOutcome,
  ],
  TarotSpread.relationship => [
    l.tarotPositionYou,
    l.tarotPositionThem,
    l.tarotPositionConnection,
    l.tarotPositionStrength,
    l.tarotPositionAdvice,
  ],
};

String spreadTitle(TarotSpread s, AppLocalizations l) => switch (s) {
  TarotSpread.three => l.tarotSpreadThree,
  TarotSpread.celtic => l.tarotSpreadCeltic,
  TarotSpread.relationship => l.tarotSpreadRelationship,
};

String spreadInfo(TarotSpread s, AppLocalizations l) => switch (s) {
  TarotSpread.three => l.tarotSpreadThreeInfo,
  TarotSpread.celtic => l.tarotSpreadCelticInfo,
  TarotSpread.relationship => l.tarotSpreadRelationshipInfo,
};

class TarotScreen extends ConsumerStatefulWidget {
  const TarotScreen({super.key});

  @override
  ConsumerState<TarotScreen> createState() => _TarotScreenState();
}

class _TarotScreenState extends ConsumerState<TarotScreen> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final texts = tarotFor(Localizations.localeOf(context).languageCode);
    final teen = ref.watch(settingsProvider.select((s) => s.isTeen));
    final profile = ref.watch(activeProfileProvider);
    final now = DateTime.now();
    final daily = dailyCard(profile?.id ?? 'anonymous', now);
    final dailyText = texts.cards[daily.card.id];
    final history = ref.watch(tarotHistoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.tarotTitle),
        actions: const [ToolInfoButton(toolId: 'tarot')],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: l.tarotDailyCard,
            icon: Icons.style_outlined,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _revealed = true),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: TarotCardView(
                      key: ValueKey(_revealed),
                      card: daily.card,
                      name: dailyText.name,
                      reversed: daily.reversed,
                      faceDown: !_revealed,
                      width: 140,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (!_revealed)
                  Text(l.tarotTapToReveal, style: theme.textTheme.bodySmall)
                else
                  CardMeaning(card: daily.card, reversed: daily.reversed, texts: texts),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(l.tarotSpreads, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final s in TarotSpread.values.where((s) => !(teen && s.adultOnly)))
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text('${s.size}')),
                title: Text(spreadTitle(s, l)),
                subtitle: Text(spreadInfo(s, l)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/tarot/spread/${s.name}'),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text(l.tarotHistory, style: theme.textTheme.titleMedium)),
              if ((history.value ?? const []).isNotEmpty)
                TextButton(
                  onPressed: () => ref.read(tarotHistoryProvider.notifier).clear(),
                  child: Text(l.tarotClearHistory),
                ),
            ],
          ),
          history.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('$e'),
            data: (list) => list.isEmpty
                ? Text(l.tarotNoHistory, style: theme.textTheme.bodySmall)
                : Column(
                    children: [
                      for (final r in list.take(30))
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.history),
                          title: Text(
                            r.question.isEmpty ? spreadTitle(r.spread, l) : r.question,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${Fmt.date(r.date)} · ${r.cards.map((c) => texts.cards[c.card.id].name).take(3).join(', ')}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => context.push('/tarot/reading/${r.id}'),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          SourceNote(texts.disclaimer),
        ],
      ),
    );
  }
}

class CardMeaning extends StatelessWidget {
  const CardMeaning({super.key, required this.card, required this.reversed, required this.texts, this.position});
  final TarotCard card;
  final bool reversed;
  final TarotTexts texts;
  final String? position;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = texts.cards[card.id];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (position != null)
          Text(position!, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
        Text('${t.name} · ${reversed ? l.tarotReversed : l.tarotUpright}', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (final k in reversed ? t.reversedKeywords : t.uprightKeywords)
              Chip(label: Text(k), visualDensity: VisualDensity.compact),
          ],
        ),
        const SizedBox(height: 4),
        Text(reversed ? t.reversed : t.upright),
        const SizedBox(height: 4),
        Text(
          '${l.tarotAstrology}: ${localizeTarotAstrology(card.astrology, Localizations.localeOf(context).languageCode)}',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class TarotSpreadScreen extends ConsumerStatefulWidget {
  const TarotSpreadScreen({super.key, required this.spread});
  final TarotSpread spread;

  @override
  ConsumerState<TarotSpreadScreen> createState() => _TarotSpreadScreenState();
}

class _TarotSpreadScreenState extends ConsumerState<TarotSpreadScreen> {
  final _question = TextEditingController();
  TarotReading? _reading;

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  Future<void> _draw() async {
    FocusScope.of(context).unfocus();
    final r = TarotReading.draw(widget.spread, question: _question.text.trim());
    setState(() => _reading = r);
    await ref.read(tarotHistoryProvider.notifier).save(r);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final reading = _reading;
    return Scaffold(
      appBar: AppBar(
        title: Text(spreadTitle(widget.spread, l)),
        actions: const [ToolInfoButton(toolId: 'tarot')],
      ),
      body: reading != null
          ? ReadingView(reading: reading)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(spreadInfo(widget.spread, l)),
                const SizedBox(height: 12),
                TextField(
                  controller: _question,
                  decoration: InputDecoration(hintText: l.tarotQuestionHint),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(icon: const Icon(Icons.shuffle), label: Text(l.tarotDraw), onPressed: _draw),
              ],
            ),
    );
  }
}

class TarotReadingScreen extends ConsumerWidget {
  const TarotReadingScreen({super.key, required this.readingId});
  final String readingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final reading = ref.watch(tarotHistoryProvider).value?.where((r) => r.id == readingId).firstOrNull;
    return InterstitialOnLeave(
      child: Scaffold(
        appBar: AppBar(
          title: Text(reading == null ? l.tarotTitle : spreadTitle(reading.spread, l)),
          actions: [
            const ToolInfoButton(toolId: 'tarot'),
            if (reading != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  await ref.read(tarotHistoryProvider.notifier).delete(reading.id);
                  if (context.mounted) context.pop();
                },
              ),
          ],
        ),
        body: reading == null ? const Center(child: CircularProgressIndicator()) : ReadingView(reading: reading),
      ),
    );
  }
}

class ReadingView extends StatelessWidget {
  const ReadingView({super.key, required this.reading});
  final TarotReading reading;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final texts = tarotFor(Localizations.localeOf(context).languageCode);
    final positions = spreadPositions(reading.spread, l);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (reading.question.isNotEmpty) ...[
          Text('“${reading.question}”', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
        ],
        Text(Fmt.date(reading.date), style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        for (var i = 0; i < reading.cards.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TarotCardView(
                      card: reading.cards[i].card,
                      name: texts.cards[reading.cards[i].card.id].name,
                      reversed: reading.cards[i].reversed,
                      width: 80,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CardMeaning(
                        card: reading.cards[i].card,
                        reversed: reading.cards[i].reversed,
                        texts: texts,
                        position: '${i + 1}. ${positions[i]}',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        SourceNote(texts.disclaimer),
      ],
    );
  }
}
