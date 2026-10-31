import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/models/profile.dart';
import '../features/chart/chart_screen.dart';
import '../features/home/home_screen.dart';
import '../features/matching/matching_screen.dart';
import '../features/more/more_screen.dart';
import '../features/numerology/numerology_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/panchang/panchang_screen.dart';
import '../features/profiles/profile_editor_screen.dart';
import '../features/profiles/profiles_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/share/share_screens.dart';
import '../l10n/app_localizations.dart';
import '../ui/theme/app_themes.dart';
import '../ui/widgets/common.dart';
import 'feature_registry.dart';
import 'providers.dart';
import 'shell_back.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboarded = ref.read(settingsProvider).onboardingDone;
  return GoRouter(
    initialLocation: onboarded ? '/today' : '/onboarding',
    routes: [
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _Shell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/today', builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/kundli', builder: (_, _) => const ProfilesScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/panchang', builder: (_, _) => const PanchangScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/match', builder: (_, _) => const MatchingScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/more', builder: (_, _) => const MoreScreen())],
          ),
        ],
      ),
      GoRoute(
        path: '/profile/new',
        builder: (_, s) => ProfileEditorScreen(
          isSelf: s.uri.queryParameters['self'] == '1',
          initial: s.extra is Profile ? s.extra as Profile : null,
        ),
      ),
      GoRoute(
        path: '/profile/:id/edit',
        builder: (_, s) => ProfileEditorScreen(profileId: s.pathParameters['id']),
      ),
      GoRoute(
        path: '/chart/:id',
        builder: (_, s) => ChartScreen(profileId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/share/:id',
        builder: (_, s) => ShareProfileScreen(profileId: s.pathParameters['id']!),
      ),
      GoRoute(path: '/scan', builder: (_, _) => const ScanProfileScreen()),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/numerology', builder: (_, _) => const NumerologyScreen()),
      ...FeatureRegistry.routes,
    ],
  );
});

class _Shell extends ConsumerWidget {
  const _Shell({required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = ref.watch(settingsProvider.select((s) => s.theme));
    // Back: the open tab may use it first (closing a result), then it goes to
    // Today, and on Today it asks before closing the app.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || ShellBack.handle(shell.currentIndex)) return;
        if (shell.currentIndex != 0) {
          shell.goBranch(0);
          return;
        }
        final exit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l.exitTitle),
            content: Text(l.exitBody),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.exitConfirm)),
            ],
          ),
        );
        if (exit ?? false) await SystemNavigator.pop();
      },
      child: Scaffold(
        body: StarryBackground(enabled: AppThemes.isStarry(theme), child: shell),
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.wb_sunny_outlined),
              selectedIcon: const Icon(Icons.wb_sunny),
              label: l.navToday,
            ),
            NavigationDestination(
              icon: const Icon(Icons.grid_view_outlined),
              selectedIcon: const Icon(Icons.grid_view),
              label: l.navKundli,
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: const Icon(Icons.calendar_month),
              label: l.navPanchang,
            ),
            NavigationDestination(
              icon: const Icon(Icons.favorite_outline),
              selectedIcon: const Icon(Icons.favorite),
              label: l.navMatch,
            ),
            NavigationDestination(
              icon: const Icon(Icons.apps_outlined),
              selectedIcon: const Icon(Icons.apps),
              label: l.navMore,
            ),
          ],
        ),
      ),
    );
  }
}
