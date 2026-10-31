import '../../core/services/ads_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/astro/constants.dart';
import '../../core/astro/settings.dart';
import '../../core/content/remedies/remedies_content.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets/common.dart';
import 'personal_remedies.dart';
import '../../ui/i18n.dart';
import '../../ui/widgets/tool_info_button.dart';

class RemediesScreen extends ConsumerWidget {
  const RemediesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final content = remediesFor(Localizations.localeOf(context).languageCode);
    final teen = ref.watch(settingsProvider.select((s) => s.isTeen));

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.remedyTitle),
          actions: const [ToolInfoButton(toolId: 'remedies')],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: l.remedyTabForYou),
              Tab(text: l.remedyTabPlanets),
              Tab(text: l.remedyTabDoshas),
              Tab(text: l.remedyTabBooks),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ForYouTab(content: content),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SourceNote(content.intro),
                const SizedBox(height: 12),
                for (final g in content.grahas)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(g.planet.symbol)),
                      title: Text(g.name),
                      subtitle: Text(g.signifies, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/remedies/graha/${g.planet.name}'),
                    ),
                  ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final d in content.doshas.where((d) => !(teen && d.adultOnly)))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DoshaRemediesCard(dosha: d),
                  ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final b in content.books)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.menu_book_outlined),
                      title: Text(b.title),
                      subtitle: Text('${b.author}\n${b.description}'),
                      isThreeLine: true,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DoshaRemediesCard extends StatelessWidget {
  const DoshaRemediesCard({super.key, required this.dosha, this.initiallyExpanded = false});
  final DoshaRemedies dosha;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ExpansionTile(
        shape: const Border(),
        initiallyExpanded: initiallyExpanded,
        title: Text(dosha.name, style: theme.textTheme.titleMedium),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dosha.about),
          const SizedBox(height: 8),
          for (final p in dosha.practices) ...[
            const SizedBox(height: 6),
            Text(p.title, style: theme.textTheme.titleSmall),
            Text(p.detail),
            SourceNote(p.source),
          ],
        ],
      ),
    );
  }
}

class _ForYouTab extends ConsumerWidget {
  const _ForYouTab({required this.content});
  final RemediesContent content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final profile = ref.watch(activeProfileProvider);
    final settings = ref.watch(settingsProvider);
    if (profile == null || !profile.hasDate) {
      return EmptyState(icon: Icons.spa_outlined, title: l.remedyNeedProfile);
    }
    // Remedies follow Vedic rules, so always use a sidereal chart here.
    final calc = settings.calc.copyWith(system: AstroSystem.vedic);
    final chart = chartForProfile(profile, calc)!;
    final suggestions = personalRemedySuggestions(
      chart: chart,
      birthUtc: profile.birthUtc()!,
      now: DateTime.now().toUtc(),
      ayanamsa: calc.ayanamsa,
      includeMarriageTopics: !settings.isTeen,
    );

    String reasonText(RemedySuggestion s) {
      final name = s.planet == null ? '' : content.graha(s.planet!).name;
      return switch (s.reason) {
        SuggestionReason.mahadasha => l.remedyReasonDasha(name),
        SuggestionReason.antardasha => l.remedyReasonAntardasha(name),
        SuggestionReason.debilitated => l.remedyReasonDebilitated(name),
        SuggestionReason.sadeSati => l.remedyReasonSadeSati(s.phase ?? 1),
        SuggestionReason.manglik => l.remedyReasonManglik,
      };
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(profile.name, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        SourceNote(content.personalNote),
        const SizedBox(height: 12),
        if (suggestions.isEmpty) Text(l.remedyNoSuggestions),
        for (final s in suggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: s.doshaId != null && content.dosha(s.doshaId!) != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reasonText(s), style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 4),
                      DoshaRemediesCard(dosha: content.dosha(s.doshaId!)!),
                    ],
                  )
                : _PlanetSuggestionCard(graha: content.graha(s.planet!), reason: reasonText(s)),
          ),
      ],
    );
  }
}

class _PlanetSuggestionCard extends StatelessWidget {
  const _PlanetSuggestionCard({required this.graha, required this.reason});
  final GrahaRemedy graha;
  final String reason;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SectionCard(
      title: graha.name,
      icon: Icons.spa_outlined,
      onTap: () => context.push('/remedies/graha/${graha.planet.name}'),
      trailing: const Icon(Icons.chevron_right),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(reason, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          // Devanagari readers get the mantra in their script, everyone gets IAST.
          KeyValueRow(
            l.remedyBeejMantra,
            const {'hi', 'mr'}.contains(Localizations.localeOf(context).languageCode)
                ? '${graha.beej.devanagari}\n${graha.beej.iast}'
                : graha.beej.iast,
          ),
          KeyValueRow(l.remedyCharity, graha.charity),
          KeyValueRow(l.remedyLifestyle, graha.lifestyle.first),
        ],
      ),
    );
  }
}

class GrahaRemedyScreen extends ConsumerWidget {
  const GrahaRemedyScreen({super.key, required this.planet});
  final Planet planet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final content = remediesFor(Localizations.localeOf(context).languageCode);
    final g = content.graha(planet);
    final theme = Theme.of(context);

    Widget mantra(String title, Mantra m) => SectionCard(
      title: title,
      icon: Icons.record_voice_over_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(m.devanagari, style: theme.textTheme.titleMedium?.copyWith(height: 1.6)),
          const SizedBox(height: 6),
          SelectableText(m.iast, style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
          const SizedBox(height: 6),
          Text('${l.remedyMeaning}: ${m.meaning}'),
          const SizedBox(height: 6),
          SourceNote(m.source),
        ],
      ),
    );

    return InterstitialOnLeave(
      child: Scaffold(
        appBar: AppBar(
          title: Text(g.name),
          actions: const [ToolInfoButton(toolId: 'remedies')],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SectionCard(
              child: Column(
                children: [
                  KeyValueRow(l.remedySignifies, g.signifies),
                  KeyValueRow(l.remedyDeity, g.deity),
                  KeyValueRow(l.remedyDay, g.day),
                  KeyValueRow(l.remedyColour, g.colour),
                  KeyValueRow(l.remedyDirection, g.direction),
                ],
              ),
            ),
            const SizedBox(height: 10),
            mantra(l.remedyBeejMantra, g.beej),
            const SizedBox(height: 10),
            mantra(l.remedyStotra, g.stotra),
            const SizedBox(height: 10),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KeyValueRow(l.remedyJapa, g.japa),
                  KeyValueRow(l.remedyCharity, g.charity),
                  KeyValueRow(l.remedyFasting, g.fasting),
                  KeyValueRow(l.remedyRudraksha, g.rudraksha),
                  KeyValueRow(l.remedyYantra, g.yantra),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SectionCard(
              title: l.remedyLifestyle,
              icon: Icons.self_improvement,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [for (final s in g.lifestyle) Text('• $s')],
              ),
            ),
            const SizedBox(height: 10),
            SectionCard(
              title: l.remedyGemstone,
              icon: Icons.diamond_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KeyValueRow(l.remedyGemstone, g.gem.primary),
                  KeyValueRow(l.remedyUpratna, g.gem.upratna),
                  const SizedBox(height: 6),
                  SourceNote(content.gemNote),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SourceNote(content.intro),
            const SizedBox(height: 4),
            Text(context.names.planet(planet), style: theme.textTheme.bodySmall),
            const BannerSlot(),
          ],
        ),
      ),
    );
  }
}
