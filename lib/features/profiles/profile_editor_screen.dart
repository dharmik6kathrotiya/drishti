import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/models/profile.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/format.dart';
import '../../ui/widgets/common.dart';
import 'place_search_sheet.dart';
import '../../ui/widgets/tool_info_button.dart';

/// Create or edit a profile. Only the name is required; every other detail is
/// optional and unlocks more results.
class ProfileEditorScreen extends ConsumerStatefulWidget {
  const ProfileEditorScreen({super.key, this.profileId, this.isSelf = false, this.initial});

  final String? profileId;
  final bool isSelf;

  /// Pre-filled data (e.g. from a scanned QR code).
  final Profile? initial;

  @override
  ConsumerState<ProfileEditorScreen> createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends ConsumerState<ProfileEditorScreen> {
  late Profile _p;
  late final TextEditingController _name;
  bool _showAdvanced = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.profileId == null ? null : profileById(ref.read(profilesProvider), widget.profileId!);
    _p =
        existing ??
        widget.initial ??
        Profile(
          id: ProfilesNotifier.newId(),
          name: '',
          isSelf: widget.isSelf || ref.read(profilesProvider).every((p) => !p.isSelf),
        );
    _name = TextEditingController(text: _p.name);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _isNew => widget.profileId == null;

  /// Closing a dialog restores focus to the name field, which pops the
  /// keyboard back up; drop focus before and after every picker.
  void _dropFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) => FocusManager.instance.primaryFocus?.unfocus());
  }

  Future<void> _pickDate() async {
    _dropFocus();
    final d = await showDatePicker(
      context: context,
      initialDate: _p.birthDate ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1800),
      lastDate: DateTime(2100, 12, 31),
      initialEntryMode: DatePickerEntryMode.input,
    );
    _dropFocus();
    if (d != null) setState(() => _p = _p.copyWith(birthDate: () => d));
  }

  Future<void> _pickTime() async {
    _dropFocus();
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _p.birthHour ?? 6, minute: _p.birthMinute ?? 0),
      initialEntryMode: TimePickerEntryMode.input,
    );
    _dropFocus();
    if (t != null) {
      setState(
        () => _p = _p.copyWith(
          birthHour: () => t.hour,
          birthMinute: () => t.minute,
          timeAccuracy: _p.timeAccuracy == TimeAccuracy.unknown ? TimeAccuracy.exact : _p.timeAccuracy,
        ),
      );
    }
  }

  Future<void> _pickPlace() async {
    _dropFocus();
    final place = await showPlaceSearch(context);
    _dropFocus();
    if (place != null) setState(() => _p = _p.copyWith(place: () => place));
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.nameRequired)));
      return;
    }
    final p = _p.copyWith(name: name);
    final notifier = ref.read(profilesProvider.notifier);
    if (p.isSelf) {
      // Only one profile can be "me".
      for (final other in ref.read(profilesProvider).where((o) => o.isSelf && o.id != p.id)) {
        await notifier.save(other.copyWith(isSelf: false));
      }
    }
    await notifier.save(p);
    if (!mounted) return;
    if (_isNew) {
      ref
          .read(settingsProvider.notifier)
          .update((s) => p.isSelf || s.activeProfileId == null ? s.copyWith(activeProfileId: () => p.id) : s);
      context.pushReplacement('/chart/${p.id}');
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final offset = _p.hasDate ? _p.birthUtcOffsetMinutes() : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? l.newProfile : l.editProfile),
        actions: [
          const ToolInfoButton(toolId: 'profiles'),
          if (!_isNew)
            IconButton(
              tooltip: l.delete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: Text(l.deleteProfileTitle),
                    content: Text(l.deleteProfileBody(_p.name)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancel)),
                      FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.delete)),
                    ],
                  ),
                );
                if (ok == true) {
                  await ref.read(profilesProvider.notifier).delete(_p.id);
                  if (context.mounted) context.go('/kundli');
                }
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: l.name, prefixIcon: const Icon(Icons.badge_outlined)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text(l.thisIsMe),
                selected: _p.isSelf,
                onSelected: (v) => setState(() => _p = _p.copyWith(isSelf: v)),
              ),
              for (final g in Gender.values)
                ChoiceChip(
                  label: Text(switch (g) {
                    Gender.male => l.male,
                    Gender.female => l.female,
                    Gender.other => l.otherGender,
                  }),
                  selected: _p.gender == g,
                  onSelected: (v) => setState(() => _p = _p.copyWith(gender: () => v ? g : null)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(l.optionalDetailsHint, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          _FieldTile(
            icon: Icons.cake_outlined,
            title: l.birthDate,
            value: _p.birthDate == null ? null : Fmt.date(_p.birthDate!),
            onTap: _pickDate,
            onClear: _p.birthDate == null ? null : () => setState(() => _p = _p.copyWith(birthDate: () => null)),
          ),
          _FieldTile(
            icon: Icons.schedule,
            title: l.birthTime,
            value: _p.birthHour == null
                ? null
                : TimeOfDay(hour: _p.birthHour!, minute: _p.birthMinute!).format(context),
            onTap: _pickTime,
            onClear: _p.birthHour == null
                ? null
                : () => setState(
                    () => _p = _p.copyWith(
                      birthHour: () => null,
                      birthMinute: () => null,
                      timeAccuracy: TimeAccuracy.unknown,
                    ),
                  ),
          ),
          if (_p.birthHour != null)
            Padding(
              padding: const EdgeInsets.only(left: 56, bottom: 8),
              child: SegmentedButton<TimeAccuracy>(
                segments: [
                  ButtonSegment(value: TimeAccuracy.exact, label: Text(l.timeExact)),
                  ButtonSegment(value: TimeAccuracy.approximate, label: Text(l.timeApprox)),
                ],
                selected: {_p.timeAccuracy == TimeAccuracy.unknown ? TimeAccuracy.exact : _p.timeAccuracy},
                onSelectionChanged: (s) => setState(() => _p = _p.copyWith(timeAccuracy: s.first)),
              ),
            ),
          _FieldTile(
            icon: Icons.place_outlined,
            title: l.birthPlace,
            value: _p.place?.displayName,
            onTap: _pickPlace,
            onClear: _p.place == null ? null : () => setState(() => _p = _p.copyWith(place: () => null)),
          ),
          if (offset != null && _p.hasPlace)
            Padding(
              padding: const EdgeInsets.only(left: 56, bottom: 8),
              child: Text(
                '${l.timezoneAtBirth}: ${_p.place!.timezoneId} (${Fmt.offset(offset)})',
                style: theme.textTheme.bodySmall,
              ),
            ),
          TextButton.icon(
            icon: Icon(_showAdvanced ? Icons.expand_less : Icons.tune),
            label: Text(l.advanced),
            onPressed: () => setState(() => _showAdvanced = !_showAdvanced),
          ),
          if (_showAdvanced)
            _AdvancedOffset(
              profile: _p,
              onChanged: (m) => setState(() => _p = _p.copyWith(utcOffsetOverrideMinutes: () => m)),
            ),
          const SizedBox(height: 16),
          _UnlockPanel(profile: _p),
          const SizedBox(height: 24),
          FilledButton.icon(icon: const Icon(Icons.check), label: Text(l.save), onPressed: _save),
        ],
      ),
    );
  }
}

class _FieldTile extends StatelessWidget {
  const _FieldTile({required this.icon, required this.title, required this.value, required this.onTap, this.onClear});
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value ?? l.notProvided),
      trailing: onClear == null
          ? const Icon(Icons.add)
          : IconButton(icon: const Icon(Icons.close), tooltip: l.clear, onPressed: onClear),
      onTap: onTap,
    );
  }
}

class _AdvancedOffset extends StatelessWidget {
  const _AdvancedOffset({required this.profile, required this.onChanged});
  final Profile profile;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final override = profile.utcOffsetOverrideMinutes;
    return SectionCard(
      title: l.utcOffsetOverride,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.utcOffsetOverrideInfo, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  override == null ? l.automatic : Fmt.offset(override),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => onChanged((override ?? profile.birthUtcOffsetMinutes() ?? 330) - 15),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => onChanged((override ?? profile.birthUtcOffsetMinutes() ?? 330) + 15),
              ),
              if (override != null) TextButton(onPressed: () => onChanged(null), child: Text(l.reset)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shows what the current data unlocks, so the user knows what adding more
/// details would give them.
class _UnlockPanel extends StatelessWidget {
  const _UnlockPanel({required this.profile});
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = <(bool, String)>[
      (true, l.unlockNameNumerology),
      (profile.hasDate, l.unlockDate),
      (profile.hasDate && profile.hasPlace, l.unlockPlace),
      (profile.canCastFullChart, l.unlockFullChart),
    ];
    return SectionCard(
      title: l.whatYouGet,
      icon: Icons.auto_awesome_outlined,
      child: Column(
        children: [
          for (final (ok, text) in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    ok ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 18,
                    color: ok ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(text)),
                ],
              ),
            ),
          if (profile.hasDate && !profile.hasTime) ...[const SizedBox(height: 8), SourceNote(l.unknownTimeNote)],
        ],
      ),
    );
  }
}
