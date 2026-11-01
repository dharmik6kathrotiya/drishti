import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/astro/settings.dart';
import '../../core/i18n/engine_texts.dart';
import '../../core/models/app_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/theme/app_themes.dart';
import '../../ui/widgets/common.dart';
import '../../ui/widgets/option_picker.dart';

/// Languages offered at launch, with their own-script names.
const appLanguages = [
  ('en', 'English'),
  ('hi', 'हिन्दी'),
  ('mr', 'मराठी'),
  ('bn', 'বাংলা'),
  ('ta', 'தமிழ்'),
  ('te', 'తెలుగు'),
  ('kn', 'ಕನ್ನಡ'),
  ('ml', 'മലയാളം'),
];

ChartStyle defaultChartStyleFor(String lang) => switch (lang) {
  'ta' || 'te' || 'kn' || 'ml' => ChartStyle.southIndian,
  'bn' => ChartStyle.eastIndian,
  _ => ChartStyle.northIndian,
};

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  int _page = 0;
  bool _underThirteen = false;
  static const _pageCount = 5;

  /// The user picked an astrology system themselves.
  bool _systemChosen = false;

  /// Western is recommended only for English phones set to a region other
  /// than India; everyone else gets Vedic. Uses the phone's own region (the
  /// app's language setting has none).
  static bool get _westernFirst {
    final device = WidgetsBinding.instance.platformDispatcher.locale;
    return device.languageCode == 'en' && device.countryCode != null && device.countryCode != 'IN';
  }

  void _next() {
    // The system step opens with the recommended option already selected.
    if (_page == 1 && !_systemChosen) {
      ref
          .read(settingsProvider.notifier)
          .updateCalc((c) => c.copyWith(system: _westernFirst ? AstroSystem.western : AstroSystem.vedic));
    }
    if (_page < _pageCount - 1) {
      _pages.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
    }
  }

  void _finish({required bool createProfile}) {
    ref.read(settingsProvider.notifier).update((s) => s.copyWith(onboardingDone: true));
    context.go('/today');
    if (createProfile) context.push('/profile/new?self=1');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final deviceLang = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    return Scaffold(
      body: StarryBackground(
        enabled: AppThemes.isStarry(settings.theme),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    for (var i = 0; i < _pageCount; i++)
                      Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: i <= _page
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pages,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (p) => setState(() => _page = p),
                  children: [
                    _Step(
                      title: l.onboardingWelcomeTitle,
                      subtitle: l.onboardingWelcomeBody,
                      items: [
                        Text(l.chooseLanguage, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        for (final (code, name) in appLanguages)
                          OptionCard<String>(
                            option: PickOption(value: code, label: name, recommended: code == deviceLang),
                            selected: (settings.localeCode ?? deviceLang) == code,
                            onTap: () {
                              notifier.update(
                                (s) => s.copyWith(localeCode: () => code, chartStyle: defaultChartStyleFor(code)),
                              );
                            },
                          ),
                      ],
                      onNext: _next,
                    ),
                    _Step(
                      title: l.ageTitle,
                      subtitle: l.ageBody,
                      items: [
                        OptionCard<AgeGroup?>(
                          option: PickOption(value: AgeGroup.adult, label: l.age18plus),
                          selected: settings.ageGroup == AgeGroup.adult,
                          onTap: () {
                            setState(() => _underThirteen = false);
                            notifier.update((s) => s.copyWith(ageGroup: AgeGroup.adult));
                          },
                        ),
                        OptionCard<AgeGroup?>(
                          option: PickOption(value: AgeGroup.teen, label: l.age13to17, description: l.teenModeInfo),
                          selected: settings.ageGroup == AgeGroup.teen,
                          onTap: () {
                            setState(() => _underThirteen = false);
                            notifier.update((s) => s.copyWith(ageGroup: AgeGroup.teen));
                          },
                        ),
                        OptionCard<AgeGroup?>(
                          option: PickOption(value: null, label: l.ageUnder13),
                          selected: _underThirteen,
                          onTap: () => setState(() => _underThirteen = true),
                        ),
                        if (_underThirteen)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              l.under13Message,
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                            ),
                          ),
                      ],
                      onNext: settings.ageGroup != null && !_underThirteen ? _next : null,
                    ),
                    _Step(
                      title: l.systemTitle,
                      subtitle: l.systemBody,
                      items: [
                        OptionCard<AstroSystem>(
                          option: PickOption(
                            value: AstroSystem.vedic,
                            label: l.systemVedic,
                            description: l.systemVedicInfo,
                            recommended: !_westernFirst,
                          ),
                          selected: settings.calc.system == AstroSystem.vedic,
                          onTap: () {
                            _systemChosen = true;
                            notifier.updateCalc((c) => c.copyWith(system: AstroSystem.vedic));
                          },
                        ),
                        OptionCard<AstroSystem>(
                          option: PickOption(
                            value: AstroSystem.western,
                            label: l.systemWestern,
                            description: l.systemWesternInfo,
                            recommended: _westernFirst,
                          ),
                          selected: settings.calc.system == AstroSystem.western,
                          onTap: () {
                            _systemChosen = true;
                            notifier.updateCalc((c) => c.copyWith(system: AstroSystem.western));
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(l.changeLaterHint, style: theme.textTheme.bodySmall),
                      ],
                      onNext: _next,
                    ),
                    _Step(
                      title: l.themeTitle,
                      subtitle: l.themeBody,
                      items: [
                        for (final t in AppThemeId.values)
                          _ThemePreview(
                            id: t,
                            selected: settings.theme == t,
                            onTap: () => notifier.update((s) => s.copyWith(theme: t)),
                          ),
                      ],
                      onNext: _next,
                    ),
                    _Step(
                      title: l.profileIntroTitle,
                      subtitle: l.profileIntroBody,
                      items: [
                        _Bullet(icon: Icons.badge_outlined, text: l.profileIntroName),
                        _Bullet(icon: Icons.cake_outlined, text: l.profileIntroDate),
                        _Bullet(icon: Icons.schedule, text: l.profileIntroTime),
                        _Bullet(icon: Icons.place_outlined, text: l.profileIntroPlace),
                        const SizedBox(height: 12),
                        _Bullet(icon: Icons.lock_outline, text: l.privacyPromise),
                      ],
                      nextLabel: l.createMyProfile,
                      onNext: () => _finish(createProfile: true),
                      secondary: TextButton(onPressed: () => _finish(createProfile: false), child: Text(l.skipForNow)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.title,
    required this.subtitle,
    required this.items,
    required this.onNext,
    this.nextLabel,
    this.secondary,
  });

  final String title;
  final String subtitle;
  final List<Widget> items;
  final VoidCallback? onNext;
  final String? nextLabel;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            children: [
              Text(title, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(subtitle, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 20),
              ...items,
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: onNext, child: Text(nextLabel ?? l.continueLabel)),
              ),
              ?secondary,
            ],
          ),
        ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
      ],
    ),
  );
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.id, required this.selected, required this.onTap});
  final AppThemeId id;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(id);
    final s = t.colorScheme;
    final current = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: t.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? current.primary : s.outline, width: selected ? 2.5 : 1),
          ),
          child: Row(
            children: [
              for (final c in [s.primary, s.secondary, s.surfaceContainerHigh])
                Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(color: s.outline),
                  ),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          EngineTexts.of(Localizations.localeOf(context).languageCode).themeLabel(id),
                          style: t.textTheme.titleSmall?.copyWith(color: s.onSurface),
                        ),
                        if (id.recommended) ...[const SizedBox(width: 8), RecommendedBadge(label: l.recommended)],
                      ],
                    ),
                    Text(
                      EngineTexts.of(Localizations.localeOf(context).languageCode).themeDesc(id),
                      style: t.textTheme.bodySmall?.copyWith(color: s.onSurface.withValues(alpha: 0.75)),
                    ),
                  ],
                ),
              ),
              if (selected) Icon(Icons.check_circle, color: current.primary),
            ],
          ),
        ),
      ),
    );
  }
}
