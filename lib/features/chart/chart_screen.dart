import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/feature_registry.dart';
import '../../app/providers.dart';
import '../../core/astro/chart.dart';
import '../../core/astro/constants.dart';
import '../../core/astro/settings.dart';
import '../../core/astro/vedic/divisional.dart';
import '../../core/i18n/engine_texts.dart';
import '../../core/models/profile.dart';
import '../../core/services/ads_service.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/charts/chart_diagram.dart';
import '../../ui/format.dart';
import '../../ui/widgets/common.dart';
import '../../ui/widgets/option_picker.dart';
import '../../ui/widgets/tool_info_button.dart';
import 'dasha_tab.dart';
import 'doshas_tab.dart';
import 'kp_tab.dart';
import 'planets_tab.dart';
import 'yogas_tab.dart';

class ChartScreen extends ConsumerWidget {
  const ChartScreen({super.key, required this.profileId});
  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final profile = profileById(ref.watch(profilesProvider), profileId);
    if (profile == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(icon: Icons.error_outline, title: l.profileNotFound),
      );
    }
    final chart = ref.watch(natalChartProvider(profileId));
    final vedic = ref.watch(settingsProvider.select((s) => s.calc.system)) == AstroSystem.vedic;

    final tabs = <(String, Widget)>[
      if (chart != null) (l.tabChart, _ChartTab(profile: profile, chart: chart)),
      if (chart != null) (l.tabPlanets, PlanetsTab(chart: chart, profile: profile)),
      if (chart != null && vedic) (l.tabDasha, DashaTab(chart: chart, profile: profile)),
      if (chart != null && vedic) (l.tabYogas, YogasTab(chart: chart)),
      if (chart != null && vedic) (l.tabDoshas, DoshasTab(chart: chart, profile: profile)),
      if (chart != null && vedic) (l.tabKp, KpTab(profile: profile)),
      if (chart != null)
        for (final build in FeatureRegistry.chartTabs) ?build(context, l, profile, chart),
    ];

    // A natural break after reading a chart: the only place an interstitial
    // may appear (frequency-capped in AdsService).
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) AdsService.instance.maybeShowInterstitial();
      },
      child: DefaultTabController(
        length: tabs.isEmpty ? 1 : tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text(profile.name),
            actions: [
              // Opens the guide of the tab that is showing.
              Builder(
                builder: (ctx) => IconButton(
                  tooltip: l.toolInfoTooltip,
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    final i = DefaultTabController.maybeOf(ctx)?.index ?? 0;
                    showToolGuide(ctx, i < tabs.length ? _guideIdOf(tabs[i].$2) : 'chart');
                  },
                ),
              ),
              IconButton(
                tooltip: l.share,
                icon: const Icon(Icons.qr_code_2),
                onPressed: () => context.push('/share/${profile.id}'),
              ),
              IconButton(
                tooltip: l.edit,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/profile/${profile.id}/edit'),
              ),
            ],
            bottom: tabs.length > 1
                ? TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: [for (final t in tabs) Tab(text: t.$1)],
                  )
                : null,
          ),
          body: tabs.isEmpty
              ? EmptyState(
                  icon: Icons.cake_outlined,
                  title: l.needBirthDateTitle,
                  message: l.needBirthDateBody,
                  action: FilledButton(
                    onPressed: () => context.push('/profile/${profile.id}/edit'),
                    child: Text(l.addBirthDetails),
                  ),
                )
              : TabBarView(children: [for (final t in tabs) t.$2]),
        ),
      ),
    );
  }
}

/// Guide id for a chart tab. Feature tabs implement [HasToolGuide]; the
/// Dasha tab is matched by type.
String _guideIdOf(Widget tab) => switch (tab) {
  HasToolGuide(:final toolGuideId) => toolGuideId,
  DashaTab() => 'dasha',
  _ => 'chart',
};

class _ChartTab extends ConsumerStatefulWidget implements HasToolGuide {
  const _ChartTab({required this.profile, required this.chart});
  final Profile profile;
  final Chart chart;

  @override
  String get toolGuideId => 'chart';

  @override
  ConsumerState<_ChartTab> createState() => _ChartTabState();
}

class _ChartTabState extends ConsumerState<_ChartTab> {
  Varga _varga = Varga.d1;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final chart = widget.chart;
    final p = widget.profile;
    final vedic = settings.calc.system == AstroSystem.vedic;
    final style = vedic
        ? (settings.chartStyle == ChartStyle.westernWheel ? ChartStyle.northIndian : settings.chartStyle)
        : ChartStyle.westernWheel;
    final theme = Theme.of(context);
    final et = EngineTexts.of(Localizations.localeOf(context).languageCode);
    final names = et.names;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (!p.canCastFullChart)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SectionCard(
              icon: Icons.info_outline,
              title: l.partialChartTitle,
              child: Text(p.hasDate && !p.hasTime ? l.unknownTimeNote : l.noPlaceNote),
            ),
          ),
        if (vedic)
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final v in Varga.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(v.code),
                      selected: _varga == v,
                      onSelected: (_) => setState(() => _varga = v),
                    ),
                  ),
              ],
            ),
          ),
        if (vedic) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_varga.code} · ${et.vargaName(_varga)} — ${et.vargaSignifies(_varga)}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              const ToolInfoButton(toolId: 'divisional', compact: true),
            ],
          ),
        ],
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, c) => Center(
            child: ChartDiagram(
              chart: chart,
              style: style,
              varga: vedic ? _varga : Varga.d1,
              size: c.maxWidth.clamp(260, 460),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (vedic)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.swap_horiz),
              label: Text(et.chartStyleLabel(style)),
              onPressed: () async {
                final s = await showOptionPicker<ChartStyle>(
                  context,
                  title: l.chartStyle,
                  selected: style,
                  options: [
                    for (final cs in ChartStyle.values.where((c) => c != ChartStyle.westernWheel))
                      PickOption(
                        value: cs,
                        label: et.chartStyleLabel(cs),
                        description: et.chartStyleDesc(cs),
                        recommended: cs == ChartStyle.northIndian,
                      ),
                  ],
                );
                if (s != null) ref.read(settingsProvider.notifier).update((x) => x.copyWith(chartStyle: s));
              },
            ),
          ),
        const SizedBox(height: 8),
        SectionCard(
          title: l.keyFacts,
          icon: Icons.auto_awesome_outlined,
          child: Column(
            children: [
              if (chart.ascendant != null)
                KeyValueRow(
                  vedic ? l.lagna : l.ascendant,
                  '${names.signDisplay(chart.ascendantSign!, vedic: vedic)} ${formatDms(chart.ascendant! % 30, seconds: false)}',
                  highlight: true,
                ),
              KeyValueRow(
                vedic ? l.rashi : l.sunSign,
                vedic
                    ? names.signDisplay(chart.moon.sign, vedic: true)
                    : names.signDisplay(chart.sun.sign, vedic: false),
                highlight: true,
              ),
              if (!vedic) KeyValueRow(l.moonSign, names.signDisplay(chart.moon.sign, vedic: false)),
              if (vedic)
                KeyValueRow(l.nakshatra, '${names.nakshatraOf(chart.moon.nakshatra)} · ${l.pada} ${chart.moon.pada}'),
              if (vedic) KeyValueRow(l.nakshatraLord, names.planet(chart.moon.nakshatra.lord)),
              if (vedic) KeyValueRow(l.sunSignSidereal, names.signDisplay(chart.sun.sign, vedic: true)),
              if (vedic)
                KeyValueRow(
                  l.ayanamsaLabel,
                  '${et.ayanamsaLabel(settings.calc.ayanamsa)} ${formatDms(chart.ayanamsaValue)}',
                ),
              if (!vedic) KeyValueRow(l.houseSystem, et.houseLabel(settings.calc.westernHouses)),
              if (p.hasDate) KeyValueRow(l.birthDetails, Fmt.birthSummary(p)),
            ],
          ),
        ),
      ],
    );
  }
}
