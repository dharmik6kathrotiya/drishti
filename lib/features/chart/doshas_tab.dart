import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/ai/explain_service.dart';
import '../../core/astro/chart.dart';
import '../../core/astro/vedic/doshas.dart';
import '../../core/i18n/engine_texts.dart';
import '../../core/models/profile.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/format.dart';
import '../../ui/widgets/common.dart';
import '../ai/explain_sheet.dart';
import '../../ui/widgets/tool_info_button.dart';

class DoshasTab extends ConsumerWidget implements HasToolGuide {
  @override
  String get toolGuideId => 'doshas';

  const DoshasTab({super.key, required this.chart, required this.profile});
  final Chart chart;
  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final names = EngineTexts.of(Localizations.localeOf(context).languageCode).names;
    final ayanamsa = ref.watch(settingsProvider.select((s) => s.calc.ayanamsa));
    final now = DateTime.now().toUtc();
    final sadeSati = Doshas.sadeSati(chart.moon.sign, now, ayanamsa);
    final periods = Doshas.sadeSatiPeriods(chart.moon.sign, profile.birthUtc()!, DateTime.utc(now.year + 40), ayanamsa);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SourceNote(l.doshaIntro),
        const SizedBox(height: 12),
        _DoshaCard(report: Doshas.manglik(chart)),
        const SizedBox(height: 10),
        SectionCard(
          title: l.sadeSati,
          icon: Icons.public,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StatusChip(present: sadeSati.running),
              const ToolInfoButton(toolId: 'sade_sati', compact: true),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sadeSati.running
                    ? l.sadeSatiRunning(sadeSati.phase, names.rashi(sadeSati.saturnSign))
                    : l.sadeSatiNotRunning(names.rashi(sadeSati.saturnSign), sadeSati.houseFromMoon),
              ),
              if (sadeSati.smallPanoti) ...[const SizedBox(height: 6), Text(l.dhaiyaNote(sadeSati.houseFromMoon))],
              const SizedBox(height: 10),
              Text(l.sadeSatiPeriods, style: Theme.of(context).textTheme.titleSmall),
              for (final (s, e) in periods) Text('• ${Fmt.dateShort(s)} → ${Fmt.dateShort(e)}'),
              const SizedBox(height: 8),
              SourceNote(l.sadeSatiSource),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _DoshaCard(report: Doshas.kaalSarp(chart)),
      ],
    );
  }
}

class _DoshaCard extends StatelessWidget {
  const _DoshaCard({required this.report});
  final DoshaReport report;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final et = EngineTexts.of(Localizations.localeOf(context).languageCode);
    final mitigations = et.doshaMitigations(report);
    return SectionCard(
      title: et.doshaName(report),
      icon: Icons.brightness_5_outlined,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusChip(present: report.present),
          ExplainButton(topic: DoshaTopic(report)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(et.doshaSummary(report)),
          for (final f in et.doshaFactors(report)) Text('• $f'),
          if (mitigations.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(l.mitigatingFactors, style: Theme.of(context).textTheme.titleSmall),
            for (final m in mitigations) Text('• $m'),
          ],
          if (report.source.isNotEmpty) ...[const SizedBox(height: 8), SourceNote(et.doshaSource(report))],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.present});
  final bool present;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(present ? l.present : l.notPresent),
      backgroundColor: (present ? scheme.tertiary : scheme.secondary).withValues(alpha: 0.12),
    );
  }
}
