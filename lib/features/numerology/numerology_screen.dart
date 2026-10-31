import '../../core/services/ads_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/astro/numerology.dart';
import '../../core/astro/numerology_texts.dart';
import '../../core/i18n/engine_texts.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/format.dart';
import '../../ui/widgets/common.dart';
import 'numerology_widgets.dart';
import '../../ui/widgets/tool_info_button.dart';

class NumerologyScreen extends ConsumerStatefulWidget {
  const NumerologyScreen({super.key});

  @override
  ConsumerState<NumerologyScreen> createState() => _NumerologyScreenState();
}

class _NumerologyScreenState extends ConsumerState<NumerologyScreen> {
  late final TextEditingController _name;
  DateTime? _date;
  bool _loShuAddMB = true;

  @override
  void initState() {
    super.initState();
    final p = ref.read(activeProfileProvider);
    _name = TextEditingController(text: p?.name ?? '');
    _date = p?.birthDate;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final name = _name.text.trim();
    final report = Numerology.report(name: name.isEmpty ? null : name, birthDate: _date);
    final lang = Localizations.localeOf(context).languageCode;
    final et = EngineTexts.of(lang);
    final nt = NumerologyTexts.of(lang);
    final hasLatinName = Numerology.letterValues(name, NumerologySystem.pythagorean).isNotEmpty;
    final chaldean = report.numbers.where((n) => n.id == 'chaldeanName').firstOrNull;
    final today = DateTime.now();

    return InterstitialOnLeave(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.numerology),
          actions: const [ToolInfoButton(toolId: 'numerology')],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: l.fullName, prefixIcon: const Icon(Icons.badge_outlined)),
              onChanged: (_) => setState(() {}),
            ),
            if (name.isNotEmpty && !hasLatinName)
              Padding(padding: const EdgeInsets.only(top: 6), child: SourceNote(l.numeroNameLatinOnly)),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cake_outlined),
              title: Text(l.birthDate),
              subtitle: Text(_date == null ? l.notProvided : Fmt.date(_date!)),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _date ?? DateTime(1995),
                  firstDate: DateTime(1800),
                  lastDate: DateTime(2100),
                  initialEntryMode: DatePickerEntryMode.input,
                );
                if (d != null) setState(() => _date = d);
              },
            ),
            const SizedBox(height: 8),
            if (report.numbers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  l.numeroTapForDetails,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                ),
              ),
            for (final n in report.numbers)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: NumberCard(
                  key: ValueKey(n.id),
                  number: n,
                  detail: Numerology.detail(n.id, name: name, birthDate: _date),
                  et: et,
                  nt: nt,
                ),
              ),
            if (report.numbers.isEmpty) EmptyState(icon: Icons.tag, title: l.numerologyEmpty),
            if (report.numbers.isNotEmpty) ...[
              const NativeSlot(),
              const SizedBox(height: 12),
              Text(l.numeroCombinations, style: theme.textTheme.titleLarge),
              const SizedBox(height: 10),
              if (_date == null)
                Padding(padding: const EdgeInsets.only(bottom: 10), child: SourceNote(l.numeroNeedDate))
              else ...[
                PairCard(pair: Numerology.mulankBhagyankPair(_date!), et: et, nt: nt),
                const SizedBox(height: 10),
                LoShuCard(
                  grid: Numerology.loShu(_date!, addMulankBhagyank: _loShuAddMB),
                  addMulankBhagyank: _loShuAddMB,
                  onToggle: (v) => setState(() => _loShuAddMB = v),
                  nt: nt,
                ),
                const SizedBox(height: 10),
              ],
              if (chaldean != null) ...[
                CompoundCard(total: chaldean.compound ?? chaldean.value, nt: nt),
                const SizedBox(height: 10),
              ],
              if (_date != null) ...[
                PersonalCyclesCard(cycles: Numerology.personalCycles(_date!, today), today: today, nt: nt),
                const SizedBox(height: 10),
              ],
              AboutMethodsCard(nt: nt),
            ],
            const SizedBox(height: 8),
            SourceNote(l.numerologyNote),
            const BannerSlot(),
          ],
        ),
      ),
    );
  }
}
