import '../../ui/widgets/reward_gate.dart';
import '../../core/services/ads_service.dart';

import 'package:flutter/material.dart';

import 'koota_detail_sheet.dart';
import 'match_advice_card.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/astro/constants.dart';
import '../../core/astro/settings.dart';
import '../../core/astro/vedic/doshas.dart';
import '../../core/astro/vedic/match_advice.dart';
import '../../core/astro/vedic/matching.dart';
import '../../core/astro/western/aspects.dart';
import '../../core/i18n/engine_texts.dart';
import '../../core/models/profile.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/format.dart';
import '../../ui/widgets/common.dart';
import '../../ui/widgets/tool_info_button.dart';

class MatchingScreen extends ConsumerStatefulWidget {
  const MatchingScreen({super.key});

  @override
  ConsumerState<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends ConsumerState<MatchingScreen> {
  String? _boyId;
  String? _girlId;

  /// The pair whose result was unlocked with a rewarded ad.
  String? _shownPair;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final profiles = ref.watch(profilesProvider).where((p) => p.hasDate).toList();

    Widget body;
    if (settings.isTeen) {
      body = EmptyState(icon: Icons.favorite_border, title: l.matchTeenTitle, message: l.matchTeenBody);
    } else if (profiles.length < 2) {
      body = EmptyState(
        icon: Icons.people_outline,
        title: l.matchNeedProfilesTitle,
        message: l.matchNeedProfilesBody,
        action: FilledButton(onPressed: () => context.push('/profile/new'), child: Text(l.addProfile)),
      );
    } else {
      final boy = profiles.where((p) => p.id == _boyId).firstOrNull;
      final girl = profiles.where((p) => p.id == _girlId).firstOrNull;
      body = ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Text(l.matchIntro, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          _PersonPicker(
            label: l.groom,
            // One person cannot be matched with themselves.
            profiles: [
              for (final p in profiles)
                if (p.id != _girlId) p,
            ],
            selected: boy,
            onChanged: (p) => setState(() => _boyId = p?.id),
          ),
          const SizedBox(height: 8),
          _PersonPicker(
            label: l.bride,
            profiles: [
              for (final p in profiles)
                if (p.id != _boyId) p,
            ],
            selected: girl,
            onChanged: (p) => setState(() => _girlId = p?.id),
          ),
          const SizedBox(height: 16),
          if (boy != null && girl != null && _shownPair != '${boy.id}|${girl.id}')
            FilledButton.icon(
              icon: const Icon(Icons.favorite_outline),
              label: Text(l.rewardShowResult),
              onPressed: () async {
                if (!await watchAdToContinue(context)) return;
                setState(() => _shownPair = '${boy.id}|${girl.id}');
              },
            )
          else if (boy != null && girl != null)
            settings.calc.system == AstroSystem.vedic
                ? _VedicResult(boy: boy, girl: girl, calc: settings.calc)
                : _WesternResult(a: boy, b: girl, calc: settings.calc),
          const BannerSlot(),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l.matchTitle),
        actions: const [ToolInfoButton(toolId: 'matching')],
      ),
      body: body,
    );
  }
}

class _PersonPicker extends StatelessWidget {
  const _PersonPicker({required this.label, required this.profiles, required this.selected, required this.onChanged});
  final String label;
  final List<Profile> profiles;
  final Profile? selected;
  final ValueChanged<Profile?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selected?.id,
      // Without this the longest "name · birth details" item sets the width
      // and overflows on phones.
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final p in profiles)
          DropdownMenuItem(
            value: p.id,
            child: Text('${p.name} · ${Fmt.birthSummary(p)}', overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (id) => onChanged(profiles.where((p) => p.id == id).firstOrNull),
    );
  }
}

class _VedicResult extends StatelessWidget {
  const _VedicResult({required this.boy, required this.girl, required this.calc});
  final Profile boy;
  final Profile girl;
  final CalcSettings calc;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final vedicCalc = calc.copyWith(system: AstroSystem.vedic);
    final bc = chartForProfile(boy, vedicCalc)!;
    final gc = chartForProfile(girl, vedicCalc)!;
    final r = Ashtakoot.match(
      boy: MatchInput(moonLongitude: bc.moon.longitude),
      girl: MatchInput(moonLongitude: gc.moon.longitude),
    );
    final bm = Doshas.manglik(bc), gm = Doshas.manglik(gc);
    final et = EngineTexts.of(Localizations.localeOf(context).languageCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          child: Column(
            children: [
              Text(
                '${_fmt(r.total)} / 36',
                style: theme.textTheme.displaySmall?.copyWith(color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 4),
              Text(et.verdict(r.total), style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: r.total / 36, minHeight: 8, borderRadius: BorderRadius.circular(8)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        MatchAdviceCard(
          advice: MatchAdvice.vedic(
            r,
            groomMoon: bc.moon.sign,
            brideMoon: gc.moon.sign,
            groomManglik: bm.present,
            brideManglik: gm.present,
            groomManglikWhy: bm.factorRefs,
            brideManglikWhy: gm.factorRefs,
          ),
        ),
        const SizedBox(height: 10),
        // What each part of the match means in life, without positions.
        SectionCard(
          title: l.matchWhatItMeans,
          icon: Icons.favorite_outline,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(l.kootaTapHint, style: theme.textTheme.bodySmall),
              ),
              for (final k in r.kootas)
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => showKootaDetail(context, k),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          k.score >= k.max
                              ? Icons.check_circle_outline
                              : (k.score > 0 ? Icons.adjust : Icons.error_outline),
                          size: 20,
                          color: k.score >= k.max
                              ? theme.colorScheme.primary
                              : (k.score > 0 ? theme.colorScheme.secondary : theme.colorScheme.error),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(_plain(l, k))),
                        const Icon(Icons.chevron_right, size: 20),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const NativeSlot(medium: false),
        const SizedBox(height: 10),
        SectionCard(
          title: l.manglikComparison,
          icon: Icons.brightness_5_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KeyValueRow(boy.name, bm.present ? l.present : l.notPresent),
              KeyValueRow(girl.name, gm.present ? l.present : l.notPresent),
              const SizedBox(height: 6),
              Text(
                bm.present == gm.present ? l.manglikBalanced : l.manglikUnbalanced,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // The chart reasons: Moon positions, each koota's values and score,
        // exceptions and the Manglik factors.
        Card(
          child: ExpansionTile(
            shape: const Border(),
            leading: const Icon(Icons.manage_search),
            title: Text(l.aiWhy, style: theme.textTheme.titleSmall),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              for (final (p, c) in [(boy, bc), (girl, gc)]) ...[
                Text(p.name, style: theme.textTheme.titleSmall),
                KeyValueRow(l.rashi, et.names.rashi(c.moon.sign)),
                KeyValueRow(l.nakshatra, '${et.names.nakshatraOf(c.moon.nakshatra)} ${l.pada} ${c.moon.pada}'),
                const SizedBox(height: 8),
              ],
              Text(l.kootaDetails, style: theme.textTheme.titleSmall),
              for (final k in r.kootas)
                InkWell(
                  onTap: () => showKootaDetail(context, k),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(et.kootaName(k), style: theme.textTheme.titleSmall)),
                            Text(
                              '${_fmt(k.score)} / ${_fmt(k.max)}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: k.score == 0 ? theme.colorScheme.error : theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${l.groom}: ${et.kootaValue(k, boy: true)} · ${l.bride}: ${et.kootaValue(k, boy: false)}',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(et.kootaMeaning(k), style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
              if (r.noteRefs.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(l.traditionalExceptions, style: theme.textTheme.titleSmall),
                for (final n in r.noteRefs) Text('• ${et.ref(n)}', style: theme.textTheme.bodySmall),
              ],
              for (final (p, m) in [(boy, bm), (girl, gm)])
                if (m.factorRefs.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('${l.manglikComparison} · ${p.name}', style: theme.textTheme.titleSmall),
                  for (final f in et.doshaFactors(m)) Text('• $f', style: theme.textTheme.bodySmall),
                ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        SourceNote(l.matchDisclaimer),
        if (!boy.hasTime || !girl.hasTime) ...[const SizedBox(height: 6), SourceNote(l.matchApproxNote)],
      ],
    );
  }

  static String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  /// One koota as a life area and how well it matches.
  static String _plain(AppLocalizations l, KootaResult k) {
    final area = switch (k.id) {
      'varna' => l.matchAreaVarna,
      'vashya' => l.matchAreaVashya,
      'tara' => l.matchAreaTara,
      'yoni' => l.matchAreaYoni,
      'maitri' => l.matchAreaMaitri,
      'gana' => l.matchAreaGana,
      'bhakoot' => l.matchAreaBhakoot,
      _ => l.matchAreaNadi,
    };
    if (k.score >= k.max) return l.matchLevelGood(area);
    return k.score > 0 ? l.matchLevelPart(area) : l.matchLevelLow(area);
  }
}

class _WesternResult extends StatelessWidget {
  const _WesternResult({required this.a, required this.b, required this.calc});
  final Profile a;
  final Profile b;
  final CalcSettings calc;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final westCalc = calc.copyWith(system: AstroSystem.western);
    final ca = chartForProfile(a, westCalc)!;
    final cb = chartForProfile(b, westCalc)!;
    const personal = {
      Planet.sun,
      Planet.moon,
      Planet.mercury,
      Planet.venus,
      Planet.mars,
      Planet.jupiter,
      Planet.saturn,
    };
    final aspects = aspectsBetween(
      ca.planets,
      cb.planets,
    ).where((x) => personal.contains(x.a) && personal.contains(x.b)).toList();
    final harmonious = aspects.where((x) => x.type == AspectType.trine || x.type == AspectType.sextile).length;
    final challenging = aspects.where((x) => x.type == AspectType.square || x.type == AspectType.opposition).length;
    final names = EngineTexts.of(Localizations.localeOf(context).languageCode).names;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MatchAdviceCard(
          advice: MatchAdvice.western(aspects, nameA: a.name, nameB: b.name),
        ),
        const SizedBox(height: 10),
        SectionCard(
          title: l.synastry,
          icon: Icons.all_inclusive,
          child: Column(
            children: [
              Text(
                harmonious > challenging
                    ? l.matchLevelGood(l.synastry)
                    : (harmonious == challenging ? l.matchLevelPart(l.synastry) : l.matchLevelLow(l.synastry)),
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              KeyValueRow(l.harmoniousAspects, '$harmonious', highlight: true),
              KeyValueRow(l.challengingAspects, '$challenging'),
              KeyValueRow(l.conjunctions, '${aspects.where((x) => x.type == AspectType.conjunction).length}'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: ExpansionTile(
            shape: const Border(),
            leading: const Icon(Icons.manage_search),
            title: Text(l.aiWhy, style: theme.textTheme.titleSmall),
            subtitle: Text(l.aspectList),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              for (final x in aspects)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          names.isEnglish
                              ? '${a.name}\'s ${names.planet(x.a)} ${x.type.symbol} ${b.name}\'s ${names.planet(x.b)}'
                              : '${a.name}: ${names.planet(x.a)} ${x.type.symbol} ${b.name}: ${names.planet(x.b)}',
                        ),
                      ),
                      Text('${x.orb.toStringAsFixed(1)}°', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SourceNote(l.matchDisclaimer),
      ],
    );
  }
}
