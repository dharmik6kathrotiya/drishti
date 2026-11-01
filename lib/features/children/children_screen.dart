import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/astro/settings.dart';
import '../../core/astro/vedic/children.dart';
import '../../core/content/tool_guides/tool_guides.dart';
import '../../core/i18n/engine_texts.dart';
import '../../core/models/profile.dart';
import '../../core/services/ads_service.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/format.dart';
import '../../ui/widgets/common.dart';
import '../../ui/widgets/reward_gate.dart';
import '../../ui/widgets/tool_info_button.dart';

/// Children (Santana) for one person or a couple: the plain outcome and the
/// marked periods first, the chart reasons under "Why?". Nothing here says
/// whether a child will be a boy or a girl; the tradition page explains why.
class ChildrenScreen extends ConsumerStatefulWidget {
  const ChildrenScreen({super.key});

  @override
  ConsumerState<ChildrenScreen> createState() => _ChildrenScreenState();
}

class _ChildrenScreenState extends ConsumerState<ChildrenScreen> {
  bool _couple = false;
  String? _one;
  String? _father;
  String? _mother;

  /// The selection whose result was unlocked with a rewarded ad.
  String? _shown;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final profiles = ref.watch(profilesProvider).where((p) => p.hasDate).toList();
    Profile? find(String? id) => profiles.where((p) => p.id == id).firstOrNull;

    Widget picker(String label, String? value, Set<String?> exclude, ValueChanged<String?> onChanged) =>
        DropdownButtonFormField<String>(
          key: ValueKey('$label|$value'),
          isExpanded: true,
          initialValue: value,
          decoration: InputDecoration(labelText: label),
          items: [
            for (final p in profiles)
              if (!exclude.contains(p.id))
                DropdownMenuItem(
                  value: p.id,
                  child: Text('${p.name} · ${Fmt.birthSummary(p)}', overflow: TextOverflow.ellipsis),
                ),
          ],
          onChanged: onChanged,
        );

    Widget body;
    if (settings.isTeen) {
      body = EmptyState(icon: Icons.child_care, title: l.childrenTitle, message: l.childrenAdultsOnly);
    } else if (profiles.isEmpty) {
      body = EmptyState(
        icon: Icons.person_add_alt,
        title: l.childrenTitle,
        message: l.childrenNeedProfiles,
        action: FilledButton(onPressed: () => context.push('/profile/new'), child: Text(l.addProfile)),
      );
    } else {
      final one = find(_one), father = find(_father), mother = find(_mother);
      final ready = _couple ? father != null && mother != null : one != null;
      final key = _couple ? 'c|${father?.id}|${mother?.id}' : 'o|${one?.id}';
      final calc = settings.calc.copyWith(system: AstroSystem.vedic);
      body = ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          SourceNote(l.childrenIntro),
          const SizedBox(height: 12),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, label: Text(l.childrenOne), icon: const Icon(Icons.person_outline)),
              ButtonSegment(value: true, label: Text(l.childrenCouple), icon: const Icon(Icons.people_outline)),
            ],
            selected: {_couple},
            onSelectionChanged: (s) => setState(() => _couple = s.first),
          ),
          const SizedBox(height: 12),
          if (!_couple)
            picker(l.childrenPerson, _one, const {}, (v) => setState(() => _one = v))
          else if (profiles.length < 2)
            SourceNote(l.childrenNeedTwo)
          else ...[
            picker(l.childrenFather, _father, {_mother}, (v) => setState(() => _father = v)),
            const SizedBox(height: 8),
            picker(l.childrenMother, _mother, {_father}, (v) => setState(() => _mother = v)),
          ],
          const SizedBox(height: 16),
          if (ready && _shown != key)
            FilledButton.icon(
              icon: const Icon(Icons.child_care),
              label: Text(l.rewardShowResult),
              onPressed: () async {
                if (!await watchAdToContinue(context)) return;
                setState(() => _shown = key);
              },
            )
          else if (ready && _couple)
            ChildrenCoupleResult(father: father!, mother: mother!, calc: calc)
          else if (ready)
            ChildrenSingleResult(person: one!, calc: calc),
          const SizedBox(height: 10),
          const NativeSlot(medium: false),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: Text(l.childrenTradTitle),
              subtitle: Text(l.childrenTradSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showTradition(context),
            ),
          ),
          const BannerSlot(),
        ],
      );
    }

    return InterstitialOnLeave(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.childrenTitle),
          actions: const [ToolInfoButton(toolId: 'children')],
        ),
        body: body,
      ),
    );
  }
}

/// Marked periods that touch each other are shown as one range.
List<(DateTime, DateTime)> _merge(Iterable<(DateTime, DateTime)> ranges) {
  final out = <(DateTime, DateTime)>[];
  for (final r in [...ranges]..sort((a, b) => a.$1.compareTo(b.$1))) {
    if (out.isNotEmpty && !r.$1.isAfter(out.last.$2.add(const Duration(days: 1)))) {
      if (r.$2.isAfter(out.last.$2)) out[out.length - 1] = (out.last.$1, r.$2);
    } else {
      out.add(r);
    }
  }
  return out;
}

String _range(BuildContext context, (DateTime, DateTime) r) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return '${Fmt.dateShort(r.$1, locale)} – ${Fmt.dateShort(r.$2, locale)}';
}

Widget _bullet(String text) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 3),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('•  '),
      Expanded(child: Text(text)),
    ],
  ),
);

Widget _heading(BuildContext context, String text) => Padding(
  padding: const EdgeInsets.only(top: 12, bottom: 4),
  child: Text(text, style: Theme.of(context).textTheme.titleSmall),
);

/// The factors of one chart with an icon for which way each points.
List<Widget> _factors(BuildContext context, EngineTexts et, ChildrenReport r) {
  final theme = Theme.of(context);
  return [
    Text(
      et.t('children.why.fifth', {'moon': r.fromMoon, 'sign': r.fifthSign, 'planet': r.fifthLord}),
      style: theme.textTheme.bodySmall,
    ),
    for (final f in r.factors)
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              f.tone > 0 ? Icons.add_circle_outline : (f.tone < 0 ? Icons.remove_circle_outline : Icons.adjust),
              size: 18,
              color: f.tone > 0
                  ? theme.colorScheme.primary
                  : (f.tone < 0 ? theme.colorScheme.error : theme.colorScheme.secondary),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(et.ref(f.text), style: theme.textTheme.bodySmall)),
          ],
        ),
      ),
  ];
}

List<Widget> _windowReasons(BuildContext context, EngineTexts et, ChildrenReport r) => [
  for (final w in r.windows)
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        '${_range(context, (w.start, w.end))}: ${w.why.map(et.ref).join(' ')}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ),
];

Widget _whyCard(BuildContext context, List<Widget> children) {
  final theme = Theme.of(context);
  return Card(
    child: ExpansionTile(
      shape: const Border(),
      leading: const Icon(Icons.manage_search),
      title: Text(AppLocalizations.of(context).aiWhy, style: theme.textTheme.titleSmall),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: children,
    ),
  );
}

/// The reading for one person.
class ChildrenSingleResult extends StatelessWidget {
  const ChildrenSingleResult({super.key, required this.person, required this.calc});
  final Profile person;
  final CalcSettings calc;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final et = EngineTexts.of(Localizations.localeOf(context).languageCode);
    final r = Children.single(chartForProfile(person, calc)!, birthUtc: person.birthUtc()!, now: DateTime.now());
    final windows = _merge(r.windows.map((w) => (w.start, w.end)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: l.compConclusion,
          icon: Icons.child_care,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(et.raw('children.tone.${r.tone}'), style: theme.textTheme.bodyLarge),
              _heading(context, l.childrenWindows),
              if (windows.isEmpty) Text(et.raw('children.noWindows')),
              for (final w in windows) _bullet(_range(context, w)),
              const SizedBox(height: 10),
              SourceNote(et.raw('children.health')),
              if (!person.hasTime) ...[const SizedBox(height: 6), SourceNote(l.childrenApproxNote)],
            ],
          ),
        ),
        const SizedBox(height: 10),
        _whyCard(context, [
          ..._factors(context, et, r),
          if (r.windows.isNotEmpty) _heading(context, l.childrenWindows),
          ..._windowReasons(context, et, r),
          const SizedBox(height: 10),
          SourceNote(et.raw('children.source')),
        ]),
      ],
    );
  }
}

/// The reading for a couple.
class ChildrenCoupleResult extends StatelessWidget {
  const ChildrenCoupleResult({super.key, required this.father, required this.mother, required this.calc});
  final Profile father;
  final Profile mother;
  final CalcSettings calc;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final et = EngineTexts.of(Localizations.localeOf(context).languageCode);
    final c = Children.couple(
      chartForProfile(father, calc)!,
      chartForProfile(mother, calc)!,
      fatherUtc: father.birthUtc()!,
      motherUtc: mother.birthUtc()!,
      now: DateTime.now(),
    );
    final shared = _merge(c.shared);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: l.compConclusion,
          icon: Icons.child_care,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(et.raw('children.couple.${c.tone}'), style: theme.textTheme.bodyLarge),
              const SizedBox(height: 8),
              _bullet(et.raw('children.beeja.${c.beeja.tone}')),
              _bullet(et.raw('children.kshetra.${c.kshetra.tone}')),
              _bullet('${father.name}: ${et.raw('children.tone.${c.father.tone}')}'),
              _bullet('${mother.name}: ${et.raw('children.tone.${c.mother.tone}')}'),
              if (c.nadiDosha) _bullet(et.raw('children.nadi')),
              _heading(context, l.childrenWindows),
              for (final (p, r) in [(father, c.father), (mother, c.mother)])
                _bullet(
                  '${p.name}: ${r.windows.isEmpty ? et.raw('children.noWindows') : _merge(r.windows.map((w) => (w.start, w.end))).map((w) => _range(context, w)).join('; ')}',
                ),
              _heading(context, l.childrenSharedWindows),
              if (shared.isEmpty) Text(et.raw('children.noShared')),
              for (final w in shared) _bullet(_range(context, w)),
              const SizedBox(height: 10),
              SourceNote(et.raw('children.health')),
              if (!father.hasTime || !mother.hasTime) ...[const SizedBox(height: 6), SourceNote(l.childrenApproxNote)],
            ],
          ),
        ),
        const SizedBox(height: 10),
        _whyCard(context, [
          for (final s in [c.beeja, c.kshetra]) ...[
            _heading(context, et.raw('children.${s.id}.${s.tone}')),
            for (final w in s.why) Text('• ${et.ref(w)}', style: theme.textTheme.bodySmall),
          ],
          if (c.nadiDosha) ...[
            _heading(context, et.raw('children.nadi')),
            Text('• ${et.raw('children.why.nadi')}', style: theme.textTheme.bodySmall),
          ],
          for (final (p, r) in [(father, c.father), (mother, c.mother)]) ...[
            _heading(context, p.name),
            ..._factors(context, et, r),
            ..._windowReasons(context, et, r),
          ],
          const SizedBox(height: 10),
          SourceNote(et.raw('children.source')),
        ]),
      ],
    );
  }
}

/// What the classical texts say about sons and daughters, as history, with
/// the science and the law. It never applies the rules to anyone.
void _showTradition(BuildContext context) {
  final et = EngineTexts.of(Localizations.localeOf(context).languageCode);
  final l = AppLocalizations.of(context);
  final refs = ToolGuides.of('children', et.lang)?.references ?? const <String>[];
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, controller) {
        final theme = Theme.of(context);
        return ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text(l.childrenTradTitle, style: theme.textTheme.headlineSmall),
            for (final k in ['intro', 'rules', 'science', 'law', 'equal']) ...[
              const SizedBox(height: 12),
              Text(et.raw('children.trad.$k')),
            ],
            const SizedBox(height: 16),
            Text(l.toolInfoReferences, style: theme.textTheme.titleSmall),
            for (final r in refs) Text('• $r', style: theme.textTheme.bodySmall),
          ],
        );
      },
    ),
  );
}
