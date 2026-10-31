import '../../../ui/widgets/reward_gate.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/astro/vedic/panchang.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/format.dart';
import '../../../ui/widgets/common.dart';
import '../../panchang/panchang_screen.dart';
import 'journal_store.dart';
import 'mood_chart.dart';
import '../../../ui/i18n.dart';
import '../../../core/i18n/astro_names.dart';
import 'journal_tags.dart';
import '../../../ui/widgets/tool_info_button.dart';

const journalTags = [
  'work',
  'family',
  'friends',
  'health',
  'exercise',
  'rest',
  'study',
  'travel',
  'spiritual',
  'stress',
  'creative',
];

const moodEmoji = ['😞', '🙁', '😐', '🙂', '😄'];

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final entries = ref.watch(journalProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.journalTitle),
        actions: [
          const ToolInfoButton(toolId: 'journal'),
          PopupMenuButton<String>(
            onSelected: (v) async {
              final n = ref.read(journalProvider.notifier);
              if (v == 'export') {
                if (!await watchAdToContinue(context)) return;
                await SharePlus.instance.share(ShareParams(text: n.exportJson(), subject: 'Drishti journal'));
              } else if (v == 'delete') {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: Text(l.journalDeleteAll),
                    content: Text(l.journalDeleteAllConfirm),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancel)),
                      FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.delete)),
                    ],
                  ),
                );
                if (ok == true) await n.clear();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'export', child: Text(l.journalExport)),
              PopupMenuItem(value: 'delete', child: Text(l.journalDeleteAll)),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.edit_note),
        label: Text(l.journalToday),
        onPressed: () => context.push('/journal/edit'),
      ),
      body: entries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            SourceNote(l.journalPrivacy),
            const SizedBox(height: 12),
            if (list.isEmpty)
              EmptyState(icon: Icons.mood, title: l.journalEmpty)
            else ...[
              SectionCard(
                title: l.journalChart,
                icon: Icons.show_chart,
                child: MoodChart(entries: list.take(60).toList().reversed.toList()),
              ),
              const SizedBox(height: 10),
              _InsightsCard(entries: list),
              const SizedBox(height: 10),
              Text(l.journalHistory, style: theme.textTheme.titleMedium),
              for (final e in list)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Text(moodEmoji[e.mood - 1], style: const TextStyle(fontSize: 28)),
                  title: Text(Fmt.date(e.date)),
                  subtitle: Text(
                    [
                      if (e.sky != null) _skyLabel(e.sky!, context.names),
                      if (e.tags.isNotEmpty)
                        e.tags.map((t) => journalTagLabel(t, Localizations.localeOf(context).languageCode)).join(', '),
                      if (e.note.isNotEmpty) e.note,
                    ].join(' · '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => context.push('/journal/edit', extra: e.date),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

String _skyLabel(JournalSky s, AstroNames names) {
  final t = s.tithi;
  return '${names.paksha(shukla: s.shukla)} ${names.tithi(t)} · ${names.nakshatra(s.nakshatra)} · ${names.rashi(s.moonSign)}';
}

class _InsightsCard extends StatelessWidget {
  const _InsightsCard({required this.entries});
  final List<JournalEntry> entries;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (entries.length < JournalInsights.minimumEntries) {
      return SectionCard(
        title: l.journalInsights,
        icon: Icons.insights,
        child: Text(l.journalInsightsNeedMore(JournalInsights.minimumEntries, entries.length)),
      );
    }
    final ins = JournalInsights(entries);
    String f(double? v) => v == null ? '—' : v.toStringAsFixed(1);
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return SectionCard(
      title: l.journalInsights,
      icon: Icons.insights,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KeyValueRow(l.journalAvgShukla, f(ins.shukla)),
          KeyValueRow(l.journalAvgKrishna, f(ins.krishna)),
          const SizedBox(height: 6),
          Text(l.journalAvgByElement, style: Theme.of(context).textTheme.titleSmall),
          for (final e in ins.byElement.entries) KeyValueRow(Fmt.capitalize(e.key.name), f(e.value)),
          const SizedBox(height: 6),
          Text(l.journalAvgByWeekday, style: Theme.of(context).textTheme.titleSmall),
          Wrap(
            spacing: 10,
            children: [for (final e in ins.byWeekday.entries) Text('${weekdays[e.key - 1]} ${f(e.value)}')],
          ),
          const SizedBox(height: 8),
          SourceNote(l.journalInsightsNote),
        ],
      ),
    );
  }
}

class JournalEntryScreen extends ConsumerStatefulWidget {
  const JournalEntryScreen({super.key, this.date});
  final DateTime? date;

  @override
  ConsumerState<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen> {
  late DateTime _date;
  int _mood = 3;
  int _energy = 3;
  final Set<String> _tags = {};
  final _note = TextEditingController();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _date = widget.date ?? DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _loadExisting(List<JournalEntry> list) {
    if (_loaded) return;
    _loaded = true;
    final e = list.where((x) => x.key == JournalEntry.keyFor(_date)).firstOrNull;
    if (e != null) {
      _mood = e.mood;
      _energy = e.energy;
      _tags.addAll(e.tags);
      _note.text = e.note;
    }
  }

  JournalSky? _sky() {
    try {
      final place = ref.read(panchangPlaceProvider);
      final loc = tz.getLocation(place.timezoneId);
      final offset = tz.TZDateTime(loc, _date.year, _date.month, _date.day, 12).timeZoneOffset;
      final p = PanchangCalculator.compute(
        date: _date,
        latitude: place.latitude,
        longitude: place.longitude,
        utcOffset: offset,
      );
      return JournalSky(tithi: p.tithi.index, nakshatra: p.nakshatra.index, moonSign: p.moonSign);
    } catch (_) {
      return null;
    }
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    await ref
        .read(journalProvider.notifier)
        .save(
          JournalEntry(
            date: _date,
            mood: _mood,
            energy: _energy,
            tags: _tags.toList()..sort(),
            note: _note.text.trim(),
            sky: _sky(),
          ),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.journalSaved)));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final list = ref.watch(journalProvider).value;
    if (list != null) _loadExisting(list);
    final exists = list?.any((x) => x.key == JournalEntry.keyFor(_date)) ?? false;
    final theme = Theme.of(context);

    Widget scale(String label, int value, ValueChanged<int> onChanged, {bool emoji = false}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 6),
        SegmentedButton<int>(
          showSelectedIcon: false,
          segments: [
            for (var i = 1; i <= 5; i++) ButtonSegment(value: i, label: Text(emoji ? moodEmoji[i - 1] : '$i')),
          ],
          selected: {value},
          onSelectionChanged: (s) => onChanged(s.first),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: _date,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (d != null) {
              setState(() {
                _date = d;
                _loaded = false;
                _tags.clear();
                _note.clear();
                _mood = 3;
                _energy = 3;
              });
            }
          },
          child: Text(Fmt.date(_date)),
        ),
        actions: [
          const ToolInfoButton(toolId: 'journal'),
          if (exists)
            IconButton(
              tooltip: l.journalDeleteEntry,
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await ref.read(journalProvider.notifier).delete(_date);
                if (context.mounted) context.pop();
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          scale(l.journalMood, _mood, (v) => setState(() => _mood = v), emoji: true),
          const SizedBox(height: 16),
          scale(l.journalEnergy, _energy, (v) => setState(() => _energy = v)),
          const SizedBox(height: 16),
          Text(l.journalTags, style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final t in journalTags)
                FilterChip(
                  label: Text(journalTagLabel(t, Localizations.localeOf(context).languageCode)),
                  selected: _tags.contains(t),
                  onSelected: (v) => setState(() => v ? _tags.add(t) : _tags.remove(t)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _note,
            maxLines: 6,
            decoration: InputDecoration(labelText: l.journalNote, hintText: l.journalNoteHint),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(icon: const Icon(Icons.check), label: Text(l.journalSave), onPressed: _save),
        ],
      ),
    );
  }
}
