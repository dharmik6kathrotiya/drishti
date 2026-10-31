import 'package:flutter/material.dart';

import '../../app/providers.dart';
import '../../core/astro/constants.dart';
import '../../core/astro/kp/kp.dart';
import '../../core/i18n/astro_names.dart';
import '../../core/models/profile.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/format.dart';
import '../../ui/widgets/common.dart';
import '../../ui/widgets/tool_info_button.dart';

/// Krishnamurti Paddhati view: always cast with KP ayanamsa and Placidus cusps.
class KpTab extends StatelessWidget implements HasToolGuide {
  @override
  String get toolGuideId => 'kp';

  const KpTab({super.key, required this.profile});
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (!profile.canCastFullChart) {
      return EmptyState(icon: Icons.schedule, title: l.kpNeedsTime);
    }
    final chart = chartForProfile(profile, kpSettings)!;
    final cusps = kpCusps(chart);
    final planets = kpPlanetLords(chart);
    final sigs = kpSignificators(chart);
    final now = DateTime.now().toUtc();
    final place = profile.place!;
    final ruling = kpRulingPlanets(now, place.latitude, place.longitude);
    final names = AstroNames.of(Localizations.localeOf(context).languageCode);
    String n(Planet p) => names.planetAbbr(p);
    String lords(KpLords k) => '${n(k.signLord)} · ${n(k.starLord)} · ${n(k.subLord)} · ${n(k.subSubLord)}';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SourceNote(l.kpIntro),
        const SizedBox(height: 12),
        SectionCard(
          title: l.kpCusps,
          icon: Icons.grid_on,
          child: Column(
            children: [
              _header(theme, l.house, l.kpSignStarSubSub),
              for (final c in cusps) _row(theme, '${c.house}  ${Fmt.longitude(c.longitude)}', lords(c.lords)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SectionCard(
          title: l.kpPlanets,
          icon: Icons.public,
          child: Column(
            children: [
              _header(theme, l.planet, l.kpSignStarSubSub),
              for (final e in planets.entries)
                _row(theme, '${names.planet(e.key)}  ${Fmt.longitude(chart[e.key].longitude)}', lords(e.value)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SectionCard(
          title: l.kpSignificators,
          icon: Icons.account_tree_outlined,
          child: Column(
            children: [for (final s in sigs) _row(theme, '${l.house} ${s.house}', s.all.map(n).join(', '))],
          ),
        ),
        const SizedBox(height: 10),
        SectionCard(
          title: l.kpRulingPlanets,
          icon: Icons.access_time,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ruling.all.map(names.planet).join(', '), style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(l.kpRulingNote(place.name), style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _header(ThemeData theme, String a, String b) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Expanded(child: Text(a, style: theme.textTheme.labelMedium)),
        Text(b, style: theme.textTheme.labelMedium),
      ],
    ),
  );

  Widget _row(ThemeData theme, String a, String b) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(child: Text(a, style: theme.textTheme.bodyMedium)),
        Text(b, style: theme.textTheme.bodyMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
      ],
    ),
  );
}
