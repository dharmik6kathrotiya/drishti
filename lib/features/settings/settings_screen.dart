import '../../ui/widgets/reward_gate.dart';

import 'package:flutter/material.dart';

import '../../core/services/ads_service.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../core/astro/settings.dart';
import '../../core/i18n/engine_texts.dart';
import '../../core/models/app_settings.dart';
import '../../core/services/notification_service.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets/option_picker.dart';
import '../onboarding/onboarding_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final deviceLang = Localizations.localeOf(context).languageCode;
    final et = EngineTexts.of(Localizations.localeOf(context).languageCode);

    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        children: [
          header(l.appearance),
          OptionSettingTile<String?>(
            icon: Icons.translate,
            title: l.language,
            value: s.localeCode ?? deviceLang,
            options: [
              for (final (code, name) in appLanguages)
                PickOption(value: code, label: name, recommended: code == deviceLang),
            ],
            onChanged: (v) => n.update((x) => x.copyWith(localeCode: () => v)),
          ),
          OptionSettingTile<AppThemeId>(
            icon: Icons.palette_outlined,
            title: l.theme,
            value: s.theme,
            options: [
              for (final t in AppThemeId.values)
                PickOption(value: t, label: et.themeLabel(t), description: et.themeDesc(t), recommended: t.recommended),
            ],
            onChanged: (v) => n.update((x) => x.copyWith(theme: v)),
          ),
          header(l.astrology),
          OptionSettingTile<AstroSystem>(
            icon: Icons.public,
            title: l.astrologySystem,
            value: s.calc.system,
            options: [
              PickOption(
                value: AstroSystem.vedic,
                label: l.systemVedic,
                description: l.systemVedicInfo,
                recommended: true,
              ),
              PickOption(value: AstroSystem.western, label: l.systemWestern, description: l.systemWesternInfo),
            ],
            onChanged: (v) => n.updateCalc((c) => c.copyWith(system: v)),
          ),
          if (s.calc.system == AstroSystem.vedic) ...[
            OptionSettingTile<Ayanamsa>(
              icon: Icons.track_changes,
              title: l.ayanamsaLabel,
              subtitle: l.ayanamsaInfo,
              value: s.calc.ayanamsa,
              options: [
                for (final a in Ayanamsa.values)
                  PickOption(
                    value: a,
                    label: et.ayanamsaLabel(a),
                    description: et.ayanamsaDesc(a),
                    recommended: a.recommended,
                  ),
              ],
              onChanged: (v) => n.updateCalc((c) => c.copyWith(ayanamsa: v)),
            ),
            OptionSettingTile<ChartStyle>(
              icon: Icons.grid_view,
              title: l.chartStyle,
              value: s.chartStyle == ChartStyle.westernWheel ? ChartStyle.northIndian : s.chartStyle,
              options: [
                for (final c in ChartStyle.values.where((c) => c != ChartStyle.westernWheel))
                  PickOption(
                    value: c,
                    label: et.chartStyleLabel(c),
                    description: et.chartStyleDesc(c),
                    recommended: c == defaultChartStyleFor(s.localeCode ?? deviceLang),
                  ),
              ],
              onChanged: (v) => n.update((x) => x.copyWith(chartStyle: v)),
            ),
            OptionSettingTile<HouseSystem>(
              icon: Icons.home_work_outlined,
              title: l.houseSystem,
              value: s.calc.vedicHouses,
              options: [
                for (final h in [HouseSystem.wholeSign, HouseSystem.sripati, HouseSystem.placidus, HouseSystem.equal])
                  PickOption(
                    value: h,
                    label: et.houseLabel(h),
                    description: et.houseDesc(h),
                    recommended: h == HouseSystem.wholeSign,
                  ),
              ],
              onChanged: (v) => n.updateCalc((c) => c.copyWith(vedicHouses: v)),
            ),
          ] else
            OptionSettingTile<HouseSystem>(
              icon: Icons.home_work_outlined,
              title: l.houseSystem,
              value: s.calc.westernHouses,
              options: [
                for (final h in HouseSystem.values.where(
                  (h) => h != HouseSystem.sripati && h != HouseSystem.placidusKp,
                ))
                  PickOption(
                    value: h,
                    label: et.houseLabel(h),
                    description: et.houseDesc(h),
                    recommended: h == HouseSystem.placidus,
                  ),
              ],
              onChanged: (v) => n.updateCalc((c) => c.copyWith(westernHouses: v)),
            ),
          OptionSettingTile<NodeType>(
            icon: Icons.swap_vert_circle_outlined,
            title: l.nodeType,
            value: s.calc.nodeType,
            options: [
              for (final t in NodeType.values)
                PickOption(
                  value: t,
                  label: et.nodeLabel(t),
                  description: et.nodeDesc(t),
                  recommended: t == NodeType.mean,
                ),
            ],
            onChanged: (v) => n.updateCalc((c) => c.copyWith(nodeType: v)),
          ),
          header(l.notifications),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l.notificationsInfo, style: Theme.of(context).textTheme.bodySmall),
          ),
          for (final t in NotificationType.values)
            SwitchListTile(
              title: Text(et.notifLabel(t)),
              subtitle: Text(et.notifDesc(t)),
              value: s.notifications.contains(t),
              onChanged: (on) async {
                if (on && !await NotificationService.instance.requestPermission()) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.notificationsDenied)));
                  }
                  return;
                }
                n.update(
                  (x) => x.copyWith(notifications: on ? {...x.notifications, t} : ({...x.notifications}..remove(t))),
                );
              },
            ),
          header(l.privacyData),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(l.privacyPromiseTitle),
            subtitle: Text(l.privacyPromise),
          ),
          FutureBuilder<bool>(
            future: AdsService.instance.privacyOptionsRequired(),
            builder: (context, snap) => snap.data == true
                ? ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: Text(l.adPrivacyChoices),
                    subtitle: Text(l.adPrivacyChoicesInfo),
                    onTap: AdsService.instance.showPrivacyOptions,
                  )
                : const SizedBox.shrink(),
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: Text(l.exportData),
            subtitle: Text(l.exportDataInfo),
            onTap: () async {
              if (!await watchAdToContinue(context)) return;
              final json = ref.read(localStoreProvider).exportAll();
              AdsService.instance.skipNextAppOpen();
              SharePlus.instance.share(ShareParams(text: json, subject: 'Drishti backup'));
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_outlined),
            title: Text(l.importData),
            onTap: () async {
              final data = await Clipboard.getData(Clipboard.kTextPlain);
              final text = data?.text;
              if (text == null || !context.mounted) return;
              try {
                final count = await ref.read(localStoreProvider).importAll(text);
                ref.read(profilesProvider.notifier).reload();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.importedProfiles(count))));
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.importFailed)));
                }
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: Theme.of(context).colorScheme.error),
            title: Text(l.deleteAllData),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: Text(l.deleteAllData),
                  content: Text(l.deleteAllDataConfirm),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancel)),
                    FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.delete)),
                  ],
                ),
              );
              if (ok != true) return;
              await ref.read(localStoreProvider).wipe();
              ref.invalidate(settingsProvider);
              ref.read(profilesProvider.notifier).reload();
              if (context.mounted) context.go('/onboarding');
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
