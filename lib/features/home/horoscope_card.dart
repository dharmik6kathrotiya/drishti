import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../app/providers.dart';
import '../../core/ai/explain_service.dart';
import '../../core/astro/constants.dart';
import '../../core/horoscope/horoscope_generator.dart';
import '../../core/models/profile.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/format.dart';
import '../../ui/widgets/common.dart';
import '../ai/explain_sheet.dart';
import '../panchang/panchang_screen.dart';

typedef _HoroscopeKey = ({String profileId, int? signIndex, HoroscopePeriod period, String lang});

/// Cached horoscope per profile/period/language for today.
final _horoscopeProvider = Provider.family<Horoscope?, _HoroscopeKey>((ref, key) {
  final calc = ref.watch(settingsProvider.select((s) => s.calc));
  final place = ref.watch(panchangPlaceProvider);
  final profile = profileById(ref.watch(profilesProvider), key.profileId);
  final subject = key.signIndex != null
      ? HoroscopeSubject.forSign(Sign.values[key.signIndex!])
      : profile == null
      ? null
      : HoroscopeSubject.fromProfile(profile);
  if (subject == null || !subject.isUsable) return null;
  final now = tz.TZDateTime.now(tz.getLocation(place.timezoneId));
  return generate(
    subject: subject,
    period: key.period,
    date: DateTime(now.year, now.month, now.day),
    settings: calc,
    utcOffset: now.timeZoneOffset,
    latitude: place.latitude,
    longitude: place.longitude,
    languageCode: key.lang,
  );
});

class HoroscopeCard extends ConsumerStatefulWidget {
  const HoroscopeCard({super.key, required this.profile});
  final Profile profile;

  @override
  ConsumerState<HoroscopeCard> createState() => _HoroscopeCardState();
}

class _HoroscopeCardState extends ConsumerState<HoroscopeCard> {
  HoroscopePeriod _period = HoroscopePeriod.daily;
  Sign? _chosenSign;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final usesSign = !widget.profile.hasDate;
    // Teen mode: no romance/relationship readings.
    final teen = ref.watch(settingsProvider.select((s) => s.isTeen));

    if (usesSign && _chosenSign == null) {
      return SectionCard(
        title: l.horoscopeTitle,
        icon: Icons.auto_awesome,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.pickSignForHoroscope),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final s in Sign.values)
                  ActionChip(
                    label: Text('${s.symbol} ${Fmt.capitalize(s.name)}'),
                    onPressed: () => setState(() => _chosenSign = s),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    final h = ref.watch(
      _horoscopeProvider((
        profileId: widget.profile.id,
        signIndex: usesSign ? _chosenSign!.index : null,
        period: _period,
        lang: lang,
      )),
    );

    return SectionCard(
      title: l.horoscopeTitle,
      icon: Icons.auto_awesome,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<HoroscopePeriod>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: HoroscopePeriod.daily, label: Text(l.periodDay)),
              ButtonSegment(value: HoroscopePeriod.weekly, label: Text(l.periodWeek)),
              ButtonSegment(value: HoroscopePeriod.monthly, label: Text(l.periodMonth)),
              ButtonSegment(value: HoroscopePeriod.yearly, label: Text(l.periodYear)),
            ],
            selected: {_period},
            onSelectionChanged: (s) => setState(() => _period = s.first),
          ),
          const SizedBox(height: 12),
          if (h == null)
            Text(l.horoscopeUnavailable)
          else ...[
            Row(
              children: [
                _Stars(score: h.overallScore),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${Fmt.date(h.start)}${h.period == HoroscopePeriod.daily ? '' : ' – ${Fmt.date(h.end)}'}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(h.summary, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            for (final s in h.sections.where((s) => !(teen && s.area == LifeArea.love))) _SectionTile(section: s),
            if (h.keyEvents.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(l.keyEvents, style: theme.textTheme.titleSmall),
              for (final e in h.keyEvents) Text('• $e', style: theme.textTheme.bodySmall),
            ],
            if (h.lucky != null) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  Chip(avatar: const Icon(Icons.palette_outlined, size: 16), label: Text(h.lucky!.color)),
                  Chip(avatar: const Icon(Icons.tag, size: 16), label: Text('${h.lucky!.number}')),
                  if (h.lucky!.timeWindow != null)
                    Chip(avatar: const Icon(Icons.schedule, size: 16), label: Text(h.lucky!.timeWindow!)),
                ],
              ),
              Text(h.lucky!.note, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 10),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              shape: const Border(),
              leading: const Icon(Icons.menu_book_outlined),
              title: Text(l.whyThisReading),
              childrenPadding: const EdgeInsets.only(bottom: 8),
              children: [
                Text(h.why, style: theme.textTheme.bodySmall),
                const SizedBox(height: 6),
                for (final r in h.reasons) Text('• ${r.text}', style: theme.textTheme.bodySmall),
              ],
            ),
            if (h.approximate) SourceNote(l.horoscopeApproxNote),
            if (usesSign)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(onPressed: () => setState(() => _chosenSign = null), child: Text(l.changeSign)),
              ),
          ],
        ],
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({required this.section});
  final HoroscopeSection section;

  static const _icons = {
    LifeArea.career: Icons.work_outline,
    LifeArea.money: Icons.account_balance_wallet_outlined,
    LifeArea.love: Icons.favorite_outline,
    LifeArea.health: Icons.self_improvement,
    LifeArea.mind: Icons.psychology_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      shape: const Border(),
      leading: Icon(_icons[section.area], color: theme.colorScheme.primary),
      title: Text(section.title),
      trailing: _Stars(score: section.score, size: 14),
      childrenPadding: const EdgeInsets.only(left: 40, bottom: 8),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section.text),
        const SizedBox(height: 6),
        for (final r in section.reasons) Text('• ${r.text}', style: theme.textTheme.bodySmall),
        Align(
          alignment: Alignment.centerRight,
          child: ExplainButton(
            topic: TextTopic(
              section.title,
              section.text,
              reasons: [for (final r in section.reasons) r.text],
              source: section.reasons.isEmpty ? '' : 'Current transits; see "Why this reading?"',
            ),
          ),
        ),
      ],
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.score, this.size = 18});
  final int score;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(i <= score ? Icons.star_rounded : Icons.star_outline_rounded, size: size, color: c),
      ],
    );
  }
}
