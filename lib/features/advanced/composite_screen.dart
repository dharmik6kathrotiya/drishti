import '../../core/services/ads_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/astro/constants.dart';
import '../../core/astro/settings.dart';
import '../../core/astro/western/composite.dart';
import '../../core/astro/western/composite_reading.dart';
import '../../core/i18n/engine_texts.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/charts/chart_diagram.dart';
import '../../ui/format.dart';
import '../../ui/widgets/common.dart';
import '../../ui/i18n.dart';
import '../../ui/widgets/tool_info_button.dart';

class CompositeScreen extends ConsumerStatefulWidget {
  const CompositeScreen({super.key});

  @override
  ConsumerState<CompositeScreen> createState() => _CompositeScreenState();
}

class _CompositeScreenState extends ConsumerState<CompositeScreen> {
  String? _a;
  String? _b;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final profiles = ref.watch(profilesProvider).where((p) => p.hasDate).toList();
    final calc = ref.watch(settingsProvider.select((s) => s.calc)).copyWith(system: AstroSystem.western);
    final a = profiles.where((p) => p.id == _a).firstOrNull;
    final b = profiles.where((p) => p.id == _b).firstOrNull;

    Widget picker(String label, String? value, ValueChanged<String?> onChanged) => DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final p in profiles)
          DropdownMenuItem(
            value: p.id,
            child: Text(p.name, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );

    return InterstitialOnLeave(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.advComposite),
          actions: const [ToolInfoButton(toolId: 'composite')],
        ),
        body: profiles.length < 2
            ? EmptyState(icon: Icons.people_outline, title: l.advComposite, message: l.advCompositeNeedProfiles)
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SourceNote(l.advCompositeIntro),
                  const SizedBox(height: 12),
                  picker(l.advPersonA, _a, (v) => setState(() => _a = v)),
                  const SizedBox(height: 8),
                  picker(l.advPersonB, _b, (v) => setState(() => _b = v)),
                  const SizedBox(height: 16),
                  if (a != null && b != null && a.id != b.id)
                    Builder(
                      builder: (context) {
                        final c = Composite.compute(chartForProfile(a, calc)!, chartForProfile(b, calc)!);
                        final reading = CompositeReading.of(c);
                        final theme = Theme.of(context);
                        final et = EngineTexts.of(Localizations.localeOf(context).languageCode);
                        final names = context.names;
                        String why(String key, Planet p) => et.t(key, {
                          'sign': names.sign(c[p].sign),
                          'element': et.raw('comp.element.${c[p].sign.element.name}'),
                        });
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // The conclusion in plain words; the chart and the
                            // reasons are one tap away.
                            SectionCard(
                              title: l.compConclusion,
                              icon: Icons.favorite_outline,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(et.ref(reading.points.first), style: theme.textTheme.titleMedium),
                                  const SizedBox(height: 8),
                                  for (final p in reading.points.skip(1))
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 3),
                                      child: Text('• ${et.ref(p)}'),
                                    ),
                                  const SizedBox(height: 8),
                                  SourceNote(et.raw('comp.caveat')),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Card(
                              child: ExpansionTile(
                                shape: const Border(),
                                leading: const Icon(Icons.manage_search),
                                title: Text(l.aiWhy, style: theme.textTheme.titleSmall),
                                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                children: [
                                  Text(et.raw('comp.why.method')),
                                  const SizedBox(height: 8),
                                  Text(why('comp.why.sun', Planet.sun)),
                                  Text(why('comp.why.moon', Planet.moon)),
                                  const SizedBox(height: 8),
                                  Text(
                                    et.t('comp.why.count', {
                                      'good': reading.harmonious.length,
                                      'hard': reading.challenging.length,
                                    }),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(l.compAspectsTitle, style: theme.textTheme.titleSmall),
                                  for (final x in reading.aspects)
                                    KeyValueRow(
                                      '${names.planet(x.a)} ${x.type.symbol} ${names.planet(x.b)}',
                                      '${x.orb.toStringAsFixed(1)}° · ${switch (CompositeReading.kind(x)) {
                                        1 => l.compSupportive,
                                        -1 => l.compChallenging,
                                        _ => l.compNotCounted,
                                      }}',
                                    ),
                                  const SizedBox(height: 12),
                                  Center(
                                    child: ChartDiagram(chart: c, style: ChartStyle.westernWheel, size: 320),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(l.advPositions, style: theme.textTheme.titleSmall),
                                  for (final p in c.planets.values.where((p) => p.planet != Planet.ketu))
                                    KeyValueRow(
                                      names.planet(p.planet),
                                      '${Fmt.longitude(p.longitude)}${p.house == null ? '' : ' · ${l.advHouseN(p.house!)}'}',
                                    ),
                                  if (c.ascendant != null) KeyValueRow('Asc', Fmt.longitude(c.ascendant!)),
                                  if (c.midheaven != null) KeyValueRow('MC', Fmt.longitude(c.midheaven!)),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
      ),
    );
  }
}
