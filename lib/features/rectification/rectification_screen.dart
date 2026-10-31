import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/astro/rectification.dart';
import '../../core/models/profile.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/format.dart';
import '../../ui/widgets/common.dart';
import '../../ui/i18n.dart';
import '../../ui/widgets/tool_info_button.dart';

String lifeEventLabel(AppLocalizations l, LifeEventType t) => switch (t) {
  LifeEventType.marriage => l.rectEventMarriage,
  LifeEventType.childBirth => l.rectEventChildBirth,
  LifeEventType.jobStart => l.rectEventJobStart,
  LifeEventType.jobLoss => l.rectEventJobLoss,
  LifeEventType.relocation => l.rectEventRelocation,
  LifeEventType.accident => l.rectEventAccident,
  LifeEventType.illness => l.rectEventIllness,
  LifeEventType.parentDeath => l.rectEventParentDeath,
  LifeEventType.education => l.rectEventEducation,
  LifeEventType.other => l.rectEventOther,
};

class RectificationScreen extends ConsumerStatefulWidget {
  const RectificationScreen({super.key, this.profileId});
  final String? profileId;

  @override
  ConsumerState<RectificationScreen> createState() => _RectificationScreenState();
}

class _RectificationScreenState extends ConsumerState<RectificationScreen> {
  String? _profileId;
  TimeOfDay _from = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _to = const TimeOfDay(hour: 9, minute: 0);
  RectificationResult? _result;
  bool _running = false;
  bool _windowInitialised = false;

  /// Longest window scanned at once, to keep the phone responsive.
  static const _maxWindowMinutes = 12 * 60;

  Profile? get _profile {
    final profiles = ref.read(profilesProvider);
    final id = _profileId ?? widget.profileId ?? ref.read(activeProfileProvider)?.id;
    return id == null ? null : profileById(profiles, id);
  }

  void _initWindow(Profile p) {
    if (_windowInitialised) return;
    _windowInitialised = true;
    if (p.birthHour != null) {
      final center = p.birthHour! * 60 + p.birthMinute!;
      final from = (center - 60).clamp(0, 24 * 60 - 1);
      final to = (center + 60).clamp(0, 24 * 60 - 1);
      _from = TimeOfDay(hour: from ~/ 60, minute: from % 60);
      _to = TimeOfDay(hour: to ~/ 60, minute: to % 60);
    }
  }

  Future<void> _editEvent(Profile p, [int? index]) async {
    final l = AppLocalizations.of(context);
    final existing = index == null ? null : p.lifeEvents[index];
    var type = existing?.type ?? LifeEventType.marriage;
    var date = existing?.date;
    final note = TextEditingController(text: existing?.note ?? '');
    final saved = await showDialog<LifeEvent>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setLocal) => AlertDialog(
          title: Text(l.rectAddEvent),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<LifeEventType>(
                isExpanded: true,
                initialValue: type,
                decoration: InputDecoration(labelText: l.rectEventType),
                items: [
                  for (final t in LifeEventType.values) DropdownMenuItem(value: t, child: Text(lifeEventLabel(l, t))),
                ],
                onChanged: (v) => setLocal(() => type = v ?? type),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: Text(l.rectEventDate),
                subtitle: Text(date == null ? '—' : Fmt.date(date!)),
                onTap: () async {
                  final d = await showDatePicker(
                    context: c,
                    initialDate: date ?? DateTime(2015),
                    firstDate: p.birthDate ?? DateTime(1900),
                    lastDate: DateTime.now(),
                    initialEntryMode: DatePickerEntryMode.input,
                  );
                  if (d != null) setLocal(() => date = d);
                },
              ),
              TextField(
                controller: note,
                decoration: InputDecoration(labelText: l.rectEventNote),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: Text(MaterialLocalizations.of(c).cancelButtonLabel)),
            FilledButton(
              onPressed: date == null
                  ? null
                  : () => Navigator.pop(c, LifeEvent(type: type, date: date!, note: note.text.trim())),
              child: Text(l.rectSaveEvent),
            ),
          ],
        ),
      ),
    );
    if (saved == null) return;
    final events = [...p.lifeEvents];
    if (index == null) {
      events.add(saved);
    } else {
      events[index] = saved;
    }
    events.sort((a, b) => a.date.compareTo(b.date));
    await ref.read(profilesProvider.notifier).save(p.copyWith(lifeEvents: events));
    setState(() => _result = null);
  }

  Future<void> _run(Profile p) async {
    final calc = ref.read(settingsProvider).calc;
    final d = p.birthDate!;
    final start = DateTime(d.year, d.month, d.day, _from.hour, _from.minute);
    var end = DateTime(d.year, d.month, d.day, _to.hour, _to.minute);
    if (!end.isAfter(start)) end = end.add(const Duration(days: 1)); // window across midnight
    if (end.difference(start).inMinutes > _maxWindowMinutes) {
      end = start.add(const Duration(minutes: _maxWindowMinutes));
    }
    setState(() => _running = true);
    await Future<void>.delayed(const Duration(milliseconds: 50)); // let the spinner paint
    final result = Rectifier(settings: calc).run(profile: p, windowStartLocal: start, windowEndLocal: end);
    if (!mounted) return;
    setState(() {
      _running = false;
      _result = result;
    });
  }

  Future<void> _apply(Profile p, RectCandidate c) async {
    final l = AppLocalizations.of(context);
    final t = c.bestLocal;
    await ref
        .read(profilesProvider.notifier)
        .save(
          p.copyWith(
            birthDate: () => DateTime(t.year, t.month, t.day),
            birthHour: () => t.hour,
            birthMinute: () => t.minute,
            timeAccuracy: TimeAccuracy.approximate,
          ),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.rectApplied(TimeOfDay.fromDateTime(t).format(context)))));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    ref.watch(profilesProvider);
    final profiles = ref.watch(profilesProvider).where((p) => p.hasDate && p.hasPlace).toList();
    final p = _profile;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.rectTitle),
        actions: const [ToolInfoButton(toolId: 'rectification')],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.rectIntro, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          if (profiles.isNotEmpty)
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: p != null && profiles.any((x) => x.id == p.id) ? p.id : null,
              decoration: InputDecoration(labelText: l.rectChooseProfile),
              items: [for (final x in profiles) DropdownMenuItem(value: x.id, child: Text(x.name))],
              onChanged: (id) => setState(() {
                _profileId = id;
                _result = null;
                _windowInitialised = false;
              }),
            ),
          const SizedBox(height: 12),
          if (p == null || !p.hasDate || !p.hasPlace)
            EmptyState(icon: Icons.schedule, title: l.rectNeedsDatePlace)
          else ...[
            () {
              _initWindow(p);
              return const SizedBox.shrink();
            }(),
            SectionCard(
              title: l.rectWindow,
              icon: Icons.schedule,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final t = await showTimePicker(context: context, initialTime: _from);
                        if (t != null) setState(() => _from = t);
                      },
                      child: Text(l.fromTime(_from.format(context))),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final t = await showTimePicker(context: context, initialTime: _to);
                        if (t != null) setState(() => _to = t);
                      },
                      child: Text(l.toTime(_to.format(context))),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SectionCard(
              title: l.rectEvents,
              icon: Icons.event_note,
              trailing: IconButton(
                icon: const Icon(Icons.add),
                tooltip: l.rectAddEvent,
                onPressed: () => _editEvent(p),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.rectEventsInfo, style: theme.textTheme.bodySmall),
                  if (p.lifeEvents.isEmpty)
                    Padding(padding: const EdgeInsets.only(top: 8), child: Text(l.rectNoEvents)),
                  for (var i = 0; i < p.lifeEvents.length; i++)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(lifeEventLabel(l, p.lifeEvents[i].type)),
                      subtitle: Text(
                        [Fmt.date(p.lifeEvents[i].date), p.lifeEvents[i].note].where((s) => s.isNotEmpty).join(' · '),
                      ),
                      onTap: () => _editEvent(p, i),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final events = [...p.lifeEvents]..removeAt(i);
                          await ref.read(profilesProvider.notifier).save(p.copyWith(lifeEvents: events));
                          setState(() => _result = null);
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: _running
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.manage_search),
              label: Text(_running ? l.rectRunning : l.rectRun),
              onPressed: _running || p.lifeEvents.isEmpty ? null : () => _run(p),
            ),
            const SizedBox(height: 12),
            SourceNote(l.rectCaveat),
            if (_result != null) ...[
              const SizedBox(height: 16),
              Text(l.rectResults, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final c in _result!.candidates.take(5))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SectionCard(
                    title:
                        '${TimeOfDay.fromDateTime(c.startLocal).format(context)} – '
                        '${TimeOfDay.fromDateTime(c.endLocal).format(context)}',
                    icon: Icons.access_time,
                    trailing: Text(l.rectScore(c.score.toStringAsFixed(1)), style: theme.textTheme.labelLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.rectLagnas(
                            context.names.rashi(c.lagna),
                            context.names.rashi(c.d9Lagna),
                            context.names.rashi(c.d10Lagna),
                          ),
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        for (final m in c.matches) ...[
                          Text(
                            '${lifeEventLabel(l, m.event.type)} · ${Fmt.date(m.event.date)}',
                            style: theme.textTheme.titleSmall,
                          ),
                          if (m.reasons.isEmpty) Text(l.rectNoMatch, style: theme.textTheme.bodySmall),
                          for (final r in m.reasons) Text('• $r', style: theme.textTheme.bodySmall),
                          const SizedBox(height: 4),
                        ],
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => _apply(p, c),
                            child: Text(l.rectApply(TimeOfDay.fromDateTime(c.bestLocal).format(context))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }
}
