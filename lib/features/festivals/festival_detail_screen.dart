import '../../core/services/ads_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/astro/vedic/festivals.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/format.dart';
import '../../ui/widgets/common.dart';
import '../panchang/panchang_screen.dart';
import 'festival_calendar_screen.dart';
import 'festival_texts.dart';
import '../../ui/widgets/tool_info_button.dart';

class FestivalDetailScreen extends ConsumerWidget {
  const FestivalDetailScreen({super.key, required this.event});
  final FestivalEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final place = ref.watch(panchangPlaceProvider);
    final tzId = place.timezoneId;
    final texts = FestivalTexts.of(Localizations.localeOf(context).languageCode);
    final regional = texts.regionalNote(event);
    String dt(DateTime utc) => Fmt.dateTime(utc, tzId);

    return InterstitialOnLeave(
      child: Scaffold(
        appBar: AppBar(
          title: Text(texts.name(event)),
          actions: const [ToolInfoButton(toolId: 'festivals')],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Icon(festivalIcon(event.type), color: festivalColor(theme.colorScheme, event.type), size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(texts.name(event), style: theme.textTheme.titleLarge),
                      Text(
                        MaterialLocalizations.of(context).formatFullDate(event.date),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(texts.description(event), style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            SectionCard(title: l.festHowDecided, icon: Icons.rule, child: Text(texts.rule(event))),
            if (event.tithiStartUtc != null || event.windowStartUtc != null || event.instantUtc != null) ...[
              const SizedBox(height: 10),
              SectionCard(
                title: l.festTimings,
                icon: Icons.schedule,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event.tithiStartUtc != null && event.tithiEndUtc != null)
                      Text(l.festTithiSpan(dt(event.tithiStartUtc!), dt(event.tithiEndUtc!))),
                    if (event.windowStartUtc != null && event.windowEndUtc != null)
                      Text(l.festWindow(Fmt.time(event.windowStartUtc!, tzId), Fmt.time(event.windowEndUtc!, tzId))),
                    if (event.instantUtc != null) Text(l.festMoment(dt(event.instantUtc!))),
                    const SizedBox(height: 6),
                    Text(l.festCalculatedFor(place.displayName), style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
            if (regional != null) ...[
              const SizedBox(height: 10),
              SectionCard(title: l.festRegionalNote, icon: Icons.map_outlined, child: Text(regional)),
            ],
            const SizedBox(height: 16),
            SourceNote(l.festDisclaimer),
            const BannerSlot(),
          ],
        ),
      ),
    );
  }
}
