import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../ui/theme/app_themes.dart';
import 'background_refresh.dart';
import 'providers.dart';
import 'router.dart';

class DrishtiApp extends ConsumerWidget {
  const DrishtiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(settingsProvider.select((s) => s.theme));
    final localeCode = ref.watch(settingsProvider.select((s) => s.localeCode));
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Drishti',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.of(theme),
      locale: localeCode == null ? null : Locale(localeCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        // Dates and numbers follow the app language, not only the device.
        Intl.defaultLocale = Localizations.localeOf(context).toLanguageTag();
        return BackgroundRefresh(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
