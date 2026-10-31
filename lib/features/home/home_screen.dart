import '../../ui/widgets/reward_gate.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/astro/settings.dart';
import '../../core/astro/vedic/dasha.dart';
import '../../core/astro/vedic/doshas.dart';
import '../../core/feed/feed_service.dart';
import '../../core/i18n/astro_names.dart';
import '../../core/models/profile.dart';
import '../../core/services/ads_service.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/format.dart';
import '../../ui/widgets/common.dart';
import '../panchang/panchang_screen.dart';
import 'horoscope_card.dart';
import '../../ui/widgets/tool_info_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final profile = ref.watch(activeProfileProvider);
    final profiles = ref.watch(profilesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Drishti',
          style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary, letterSpacing: 1.2),
        ),
        actions: [
          const ToolInfoButton(toolId: 'horoscope'),
          if (profiles.length > 1)
            PopupMenuButton<String>(
              tooltip: l.switchProfile,
              icon: const Icon(Icons.switch_account_outlined),
              onSelected: (id) async {
                if (id == profile?.id || !await watchAdToContinue(context)) return;
                ref.read(settingsProvider.notifier).update((s) => s.copyWith(activeProfileId: () => id));
              },
              itemBuilder: (_) => [
                for (final p in profiles)
                  CheckedPopupMenuItem(value: p.id, checked: p.id == profile?.id, child: Text(p.name)),
              ],
            ),
          IconButton(
            tooltip: l.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          if (profile == null)
            SectionCard(
              title: l.welcome,
              icon: Icons.waving_hand_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.homeNoProfile),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: () => context.push('/profile/new?self=1'), child: Text(l.createMyProfile)),
                ],
              ),
            )
          else ...[
            Text(l.hello(profile.name), style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(Fmt.date(todayAt(ref.watch(panchangPlaceProvider))), style: theme.textTheme.bodyMedium),
            const SizedBox(height: 14),
            HoroscopeCard(profile: profile),
            const NativeSlot(),
            const SizedBox(height: 12),
            _NatalSnapshot(profile: profile),
          ],
          const _Announcements(),
          const SizedBox(height: 12),
          const _TodayPanchang(),
          const BannerSlot(),
        ],
      ),
    );
  }
}

class _NatalSnapshot extends ConsumerWidget {
  const _NatalSnapshot({required this.profile});
  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final chart = ref.watch(natalChartProvider(profile.id));
    final calc = ref.watch(settingsProvider.select((s) => s.calc));
    if (chart == null) {
      return SectionCard(
        title: l.addBirthDetails,
        icon: Icons.cake_outlined,
        onTap: () => context.push('/profile/${profile.id}/edit'),
        child: Text(l.needBirthDateBody),
      );
    }
    final now = DateTime.now().toUtc();
    final names = AstroNames.of(Localizations.localeOf(context).languageCode);
    final vedic = calc.system == AstroSystem.vedic;
    final running = vedic
        ? Vimshottari().runningAt(profile.birthUtc()!, chart.moon.longitude, now, depth: 2)
        : const <DashaPeriod>[];
    final next = vedic
        ? Vimshottari().upcoming(profile.birthUtc()!, chart.moon.longitude, now, count: 1).firstOrNull
        : null;
    final sadeSati = vedic ? Doshas.sadeSati(chart.moon.sign, now, calc.ayanamsa) : null;

    return SectionCard(
      title: l.yourChart,
      icon: Icons.grid_view,
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/chart/${profile.id}'),
      child: Column(
        children: [
          if (chart.ascendantSign != null)
            KeyValueRow(
              vedic ? l.lagna : l.ascendant,
              vedic ? names.rashi(chart.ascendantSign!) : names.sign(chart.ascendantSign!),
            ),
          KeyValueRow(
            vedic ? l.rashi : l.sunSign,
            vedic ? names.rashi(chart.moon.sign) : names.sign(chart.sun.sign),
            highlight: true,
          ),
          if (vedic)
            KeyValueRow(l.nakshatra, '${names.nakshatraOf(chart.moon.nakshatra)} ${l.pada} ${chart.moon.pada}'),
          if (running.length >= 2)
            KeyValueRow(
              l.currentDasha,
              '${names.planet(running[0].lord)} / ${names.planet(running[1].lord)} · ${l.untilDate(Fmt.dateShort(running[1].end))}',
            ),
          if (next != null)
            KeyValueRow(
              l.dashaComingNext,
              '${names.planet(next.parent!.lord)} / ${names.planet(next.lord)} · ${l.dashaFromDate(Fmt.dateShort(next.start))}',
            ),
          if (sadeSati != null)
            KeyValueRow(l.sadeSati, sadeSati.running ? l.sadeSatiPhase(sadeSati.phase) : l.notRunning),
        ],
      ),
    );
  }
}

/// Editorial notes from the optional daily feed; shows nothing when offline
/// or when no feed is configured.
class _Announcements extends ConsumerWidget {
  const _Announcements();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final items = ref.watch(dailyFeedProvider).value?.announcements.where((a) => a.active).toList() ?? const [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SectionCard(
        title: l.skyNewsTitle,
        icon: Icons.campaign_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final a in items) ...[
              Text(a.title, style: Theme.of(context).textTheme.titleSmall),
              Text(a.body),
              const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }
}

class _TodayPanchang extends ConsumerWidget {
  const _TodayPanchang();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final place = ref.watch(panchangPlaceProvider);
    final p = ref.watch(panchangProvider(todayAt(place)));
    final tzId = place.timezoneId;
    final names = AstroNames.of(Localizations.localeOf(context).languageCode);
    return SectionCard(
      title: '${l.todaysPanchang} · ${place.name}',
      icon: Icons.calendar_month_outlined,
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go('/panchang'),
      child: Column(
        children: [
          KeyValueRow(l.tithi, '${names.pakshaFromEnglish(p.paksha)} ${names.tithi(p.tithi.index)}'),
          KeyValueRow(l.nakshatra, names.nakshatra(p.nakshatra.index)),
          KeyValueRow(l.sunriseSunset, '${Fmt.time(p.sunrise, tzId)} / ${Fmt.time(p.sunset, tzId)}'),
          KeyValueRow(l.rahuKaal, '${Fmt.time(p.rahuKaal.start, tzId)} – ${Fmt.time(p.rahuKaal.end, tzId)}'),
          if (p.abhijit != null)
            KeyValueRow(l.abhijit, '${Fmt.time(p.abhijit!.start, tzId)} – ${Fmt.time(p.abhijit!.end, tzId)}'),
        ],
      ),
    );
  }
}
