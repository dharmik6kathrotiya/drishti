import '../../ui/widgets/reward_gate.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/models/profile.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/format.dart';
import '../../ui/widgets/common.dart';
import '../../ui/widgets/tool_info_button.dart';

/// Kundli tab: all profiles ("IDs") the user has created.
class ProfilesScreen extends ConsumerWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final profiles = ref.watch(profilesProvider);
    final activeId = ref.watch(activeProfileProvider)?.id;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l.profilesTitle),
        actions: [
          const ToolInfoButton(toolId: 'profiles'),
          IconButton(
            tooltip: l.scanProfile,
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => context.push('/scan'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(l.addProfile),
        onPressed: () => context.push('/profile/new'),
      ),
      body: profiles.isEmpty
          ? EmptyState(
              icon: Icons.person_outline,
              title: l.noProfilesTitle,
              message: l.noProfilesBody,
              action: FilledButton(
                onPressed: () => context.push('/profile/new?self=1'),
                child: Text(l.createMyProfile),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: profiles.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _ProfileCard(profile: profiles[i], active: profiles[i].id == activeId),
            ),
    );
  }
}

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard({required this.profile, required this.active});
  final Profile profile;
  final bool active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final summary = Fmt.birthSummary(profile);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Another person's chart: offer a rewarded ad first (your own is free).
        onTap: () async {
          if (!active && !await watchAdToContinue(context)) return;
          if (context.mounted) context.push('/chart/${profile.id}');
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                child: Text(
                  profile.name.isEmpty ? '?' : profile.name.characters.first.toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.name,
                            style: theme.textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (profile.isSelf) ...[
                          const SizedBox(width: 6),
                          Chip(label: Text(l.me), visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      summary.isEmpty ? l.onlyName : summary,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (active) Icon(Icons.star, color: theme.colorScheme.primary, size: 20),
              PopupMenuButton<String>(
                onSelected: (v) {
                  switch (v) {
                    case 'active':
                      ref.read(settingsProvider.notifier).update((s) => s.copyWith(activeProfileId: () => profile.id));
                    case 'edit':
                      context.push('/profile/${profile.id}/edit');
                    case 'share':
                      context.push('/share/${profile.id}');
                  }
                },
                itemBuilder: (_) => [
                  if (!active) PopupMenuItem(value: 'active', child: Text(l.showOnToday)),
                  PopupMenuItem(value: 'edit', child: Text(l.edit)),
                  PopupMenuItem(value: 'share', child: Text(l.share)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
