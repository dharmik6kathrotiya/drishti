import '../../core/services/ads_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/astro/settings.dart';
import '../../core/astro/vedic/muhurat.dart';
import '../../core/models/profile.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/format.dart';
import '../../ui/widgets/common.dart';
import '../../ui/widgets/option_picker.dart';
import '../panchang/panchang_screen.dart';
import '../../core/astro/constants.dart';
import '../../core/i18n/astro_names.dart';
import '../../ui/i18n.dart';
import '../../ui/widgets/tool_info_button.dart';

String muhuratActivityLabel(AppLocalizations l, MuhuratActivity a) => switch (a) {
  MuhuratActivity.marriage => l.muhuratActMarriage,
  MuhuratActivity.grihaPravesh => l.muhuratActGrihaPravesh,
  MuhuratActivity.vehiclePurchase => l.muhuratActVehicle,
  MuhuratActivity.propertyPurchase => l.muhuratActProperty,
  MuhuratActivity.businessStart => l.muhuratActBusiness,
  MuhuratActivity.travel => l.muhuratActTravel,
  MuhuratActivity.namingCeremony => l.muhuratActNaming,
  MuhuratActivity.mundan => l.muhuratActMundan,
  MuhuratActivity.educationStart => l.muhuratActEducation,
};

const _taraNames = ['Janma', 'Sampat', 'Vipat', 'Kshema', 'Pratyari', 'Sadhaka', 'Naidhana', 'Mitra', 'Parama Mitra'];

class MuhuratScreen extends ConsumerStatefulWidget {
  const MuhuratScreen({super.key});

  @override
  ConsumerState<MuhuratScreen> createState() => _MuhuratScreenState();
}

class _MuhuratScreenState extends ConsumerState<MuhuratScreen> {
  MuhuratActivity _activity = MuhuratActivity.vehiclePurchase;
  late DateTime _from;
  late DateTime _to;
  String? _profileId;
  bool _kharmas = true, _combust = true, _chaturmas = true;
  bool _busy = false;
  List<MuhuratWindow>? _results;

  @override
  void initState() {
    super.initState();
    _from = todayAt(ref.read(panchangPlaceProvider));
    _to = _from.add(const Duration(days: 30));
  }

  Future<void> _find() async {
    final l = AppLocalizations.of(context);
    if (_to.difference(_from).inDays > 180 || _to.isBefore(_from)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.muhuratRangeTooLong)));
      return;
    }
    setState(() {
      _busy = true;
      _results = null;
    });
    // Let the progress indicator paint before the (synchronous) search.
    await Future<void>.delayed(const Duration(milliseconds: 32));
    final place = ref.read(panchangPlaceProvider);
    final calc = ref.read(settingsProvider).calc;
    final profile = _profileId == null ? null : profileById(ref.read(profilesProvider), _profileId!);
    final natal = chartForProfile(profile, calc.copyWith(system: AstroSystem.vedic));
    final results =
        MuhuratFinder(
          latitude: place.latitude,
          longitude: place.longitude,
          timezoneId: place.timezoneId,
          ayanamsa: calc.ayanamsa,
        ).find(
          activity: _activity,
          from: _from,
          to: _to,
          birthNakshatra: natal?.moon.nakshatra,
          birthMoonSign: natal?.moon.sign,
          options: MuhuratOptions(avoidKharmas: _kharmas, avoidCombustion: _combust, avoidChaturmas: _chaturmas),
        );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _results = results;
    });
  }

  Future<void> _pickDate(bool from) async {
    final d = await showDatePicker(
      context: context,
      initialDate: from ? _from : _to,
      firstDate: DateTime(1900),
      lastDate: DateTime(2399),
    );
    if (d == null) return;
    setState(() {
      if (from) {
        _from = d;
        if (_to.isBefore(d)) _to = d.add(const Duration(days: 30));
      } else {
        _to = d;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final teen = ref.watch(settingsProvider.select((s) => s.isTeen));
    final profiles = ref.watch(profilesProvider).where((p) => p.hasDate).toList();
    final place = ref.watch(panchangPlaceProvider);
    final activities = MuhuratActivity.values.where((a) => !(teen && a == MuhuratActivity.marriage)).toList();
    if (!activities.contains(_activity)) _activity = activities.first;
    final seasonal = MuhuratOptions.seasonalApplies(_activity);
    final loc = MaterialLocalizations.of(context);

    return InterstitialOnLeave(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.muhuratTitle),
          actions: const [ToolInfoButton(toolId: 'muhurat')],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            OptionSettingTile<MuhuratActivity>(
              icon: Icons.flag_outlined,
              title: l.muhuratActivity,
              value: _activity,
              options: [for (final a in activities) PickOption(value: a, label: muhuratActivityLabel(l, a))],
              onChanged: (a) => setState(() {
                _activity = a;
                _results = null;
              }),
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.event),
                    title: Text(l.muhuratFrom),
                    subtitle: Text(loc.formatMediumDate(_from)),
                    onTap: () => _pickDate(true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(l.muhuratTo),
                    subtitle: Text(loc.formatMediumDate(_to)),
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),
            if (profiles.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButtonFormField<String?>(
                  isExpanded: true,
                  initialValue: _profileId,
                  decoration: InputDecoration(
                    labelText: l.muhuratPersonalise,
                    helperText: l.muhuratPersonaliseInfo,
                    helperMaxLines: 3,
                  ),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l.muhuratGeneral)),
                    for (final Profile p in profiles) DropdownMenuItem(value: p.id, child: Text(p.name)),
                  ],
                  onChanged: (v) => setState(() => _profileId = v),
                ),
              ),
            if (seasonal) ...[
              SwitchListTile(
                title: Text(l.muhuratAvoidKharmas),
                subtitle: Text(l.muhuratAvoidKharmasInfo),
                value: _kharmas,
                onChanged: (v) => setState(() => _kharmas = v),
              ),
              SwitchListTile(
                title: Text(l.muhuratAvoidCombust),
                subtitle: Text(l.muhuratAvoidCombustInfo),
                value: _combust,
                onChanged: (v) => setState(() => _combust = v),
              ),
              SwitchListTile(
                title: Text(l.muhuratAvoidChaturmas),
                subtitle: Text(l.muhuratAvoidChaturmasInfo),
                value: _chaturmas,
                onChanged: (v) => setState(() => _chaturmas = v),
              ),
            ],
            const SizedBox(height: 8),
            FilledButton.icon(
              icon: const Icon(Icons.search),
              label: Text(l.muhuratFind),
              onPressed: _busy ? null : _find,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                l.festCalculatedFor(place.displayName),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
            if (_busy)
              Center(
                child: Column(
                  children: [const CircularProgressIndicator(), const SizedBox(height: 8), Text(l.muhuratSearching)],
                ),
              ),
            if (_results != null) ...[
              Text(
                _results!.isEmpty ? l.muhuratNoResults : l.muhuratResults(_results!.length),
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              for (final w in _results!) _WindowCard(window: w, tzId: place.timezoneId),
            ],
            const SizedBox(height: 12),
            SourceNote(l.muhuratDisclaimer),
            const BannerSlot(),
          ],
        ),
      ),
    );
  }
}

class _WindowCard extends StatelessWidget {
  const _WindowCard({required this.window, required this.tzId});
  final MuhuratWindow window;
  final String tzId;

  static String _tithi(AstroNames names, int t) => t == 15 || t == 30 ? names.tithi(t) : names.tithiFull(t);

  String _label(AppLocalizations l, MuhuratCheck c, AstroNames names) {
    final v = c.value ?? '';
    return switch (c.id) {
      'nakshatra' => l.muhuratChkNakshatra(names.nakshatra(Nakshatra.all.indexWhere((n) => n.name == v))),
      'tithi' => l.muhuratChkTithi(_tithi(names, int.parse(v))),
      'vara' => l.muhuratChkVara(names.vara(int.parse(v))),
      'yoga' => l.muhuratChkYoga(names.yoga(int.parse(v))),
      'yoga_vyatipata_vaidhriti' => l.muhuratChkVyatipata,
      'vishti' => l.muhuratChkVishti,
      'rahu_kaal' => l.muhuratChkRahuKaal,
      'yamaganda' => l.muhuratChkYamaganda,
      'gulika' => l.muhuratChkGulika,
      'eclipse' => l.muhuratChkEclipse,
      'kharmas' => l.muhuratChkKharmas,
      'combust_jupiter' => l.muhuratChkCombustJupiter,
      'combust_venus' => l.muhuratChkCombustVenus,
      'chaturmas' => l.muhuratChkChaturmas,
      'tara_bala' => l.muhuratChkTara(_taraNames[int.parse(v)]),
      'chandra_bala' => l.muhuratChkChandra(v),
      _ => c.id,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final met = window.checks.where((c) => c.passed).toList();
    final missed = window.checks.where((c) => !c.passed).toList();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        shape: const Border(),
        title: Text(
          '${MaterialLocalizations.of(context).formatMediumDate(window.date)} · '
          '${Fmt.time(window.startUtc, tzId)} – ${Fmt.time(window.endUtc, tzId)}',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            LinearProgressIndicator(value: window.score / 100, borderRadius: BorderRadius.circular(6)),
            const SizedBox(height: 4),
            Text(l.muhuratScore(window.score), style: theme.textTheme.bodySmall),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.muhuratRulesMet, style: theme.textTheme.titleSmall),
          for (final c in met)
            Row(
              children: [
                Icon(Icons.check, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(child: Text(_label(l, c, context.names), style: theme.textTheme.bodySmall)),
              ],
            ),
          if (missed.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(l.muhuratRulesMissed, style: theme.textTheme.titleSmall),
            for (final c in missed)
              Row(
                children: [
                  Icon(Icons.close, size: 16, color: theme.colorScheme.error),
                  const SizedBox(width: 6),
                  Expanded(child: Text(_label(l, c, context.names), style: theme.textTheme.bodySmall)),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
