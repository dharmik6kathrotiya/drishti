import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/feature_registry.dart';
import '../../app/providers.dart';
import '../../core/astro/ephemeris.dart';
import '../../core/services/ads_service.dart';
import '../../l10n/app_localizations.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final teen = ref.watch(settingsProvider.select((s) => s.isTeen));

    Widget tile(IconData icon, String title, String subtitle, VoidCallback onTap) => Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(backgroundColor: Colors.transparent, title: Text(l.navMore)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          for (final e in FeatureRegistry.moreEntries.where((e) => !(teen && e.adultOnly)))
            tile(e.icon, e.title(l), e.subtitle(l), () => context.push(e.route)),
          tile(Icons.tag, l.numerology, l.numerologySubtitle, () => context.push('/numerology')),
          tile(Icons.qr_code_scanner, l.scanProfile, l.scanProfileSubtitle, () => context.push('/scan')),
          tile(Icons.settings_outlined, l.settings, l.settingsSubtitle, () => context.push('/settings')),
          tile(Icons.info_outline, l.about, l.aboutSubtitle, () {
            showLicensePage(
              context: context,
              applicationName: 'Drishti',
              applicationLegalese: l.aboutLegal(Ephemeris.isReady ? Ephemeris.version : ''),
            );
          }),
          const BannerSlot(),
        ],
      ),
    );
  }
}
