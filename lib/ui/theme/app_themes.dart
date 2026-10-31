import 'package:flutter/material.dart';

import '../../core/models/app_settings.dart';

/// Bundled Noto Sans Symbols (OFL) is tried before the system emoji font, so
/// zodiac and planet glyphs always render as text symbols on every phone.
const symbolFontFallback = ['NotoSansSymbols'];

/// Every theme is a complete look; the user picks one in onboarding or
/// Settings.
class AppThemes {
  AppThemes._();

  static ThemeData of(AppThemeId id) => switch (id) {
    AppThemeId.cosmic => _build(
      brightness: Brightness.dark,
      seed: const Color(0xFFE8C26E),
      background: const Color(0xFF0B1026),
      surface: const Color(0xFF141B3A),
      surfaceHigh: const Color(0xFF1D2650),
      primary: const Color(0xFFE8C26E),
      onPrimary: const Color(0xFF241A00),
      secondary: const Color(0xFF9DB0FF),
      onSurface: const Color(0xFFEDEAF6),
      outline: const Color(0xFF3A4475),
    ),
    AppThemeId.devotional => _build(
      brightness: Brightness.light,
      seed: const Color(0xFFD9640F),
      background: const Color(0xFFFFF8EC),
      surface: const Color(0xFFFFFFFF),
      surfaceHigh: const Color(0xFFFCEBD3),
      primary: const Color(0xFFC2560A),
      onPrimary: Colors.white,
      secondary: const Color(0xFF7A1E2C),
      onSurface: const Color(0xFF3A1F12),
      outline: const Color(0xFFE2C49A),
    ),
    AppThemeId.minimal => _build(
      brightness: Brightness.light,
      seed: const Color(0xFF3D4A5C),
      background: const Color(0xFFF8F8F5),
      surface: Colors.white,
      surfaceHigh: const Color(0xFFEFEFEA),
      primary: const Color(0xFF34404F),
      onPrimary: Colors.white,
      secondary: const Color(0xFF8A6F4D),
      onSurface: const Color(0xFF1E2329),
      outline: const Color(0xFFDADAD3),
    ),
    AppThemeId.midnight => _build(
      brightness: Brightness.dark,
      seed: const Color(0xFFB9A6FF),
      background: Colors.black,
      surface: const Color(0xFF0E0E11),
      surfaceHigh: const Color(0xFF1A1A20),
      primary: const Color(0xFFC3B3FF),
      onPrimary: const Color(0xFF1D0F4A),
      secondary: const Color(0xFF7FD8C8),
      onSurface: const Color(0xFFE9E7EF),
      outline: const Color(0xFF2E2C38),
    ),
    AppThemeId.lotus => _build(
      brightness: Brightness.light,
      seed: const Color(0xFFC04878),
      background: const Color(0xFFFFF6F8),
      surface: Colors.white,
      surfaceHigh: const Color(0xFFFBE6EC),
      primary: const Color(0xFFB03A6A),
      onPrimary: Colors.white,
      secondary: const Color(0xFF1E8C8C),
      onSurface: const Color(0xFF34202A),
      outline: const Color(0xFFEBC9D5),
    ),
  };

  static ThemeData _build({
    required Brightness brightness,
    required Color seed,
    required Color background,
    required Color surface,
    required Color surfaceHigh,
    required Color primary,
    required Color onPrimary,
    required Color secondary,
    required Color onSurface,
    required Color outline,
  }) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness).copyWith(
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerLowest: background,
      surfaceContainerLow: surface,
      surfaceContainer: surface,
      surfaceContainerHigh: surfaceHigh,
      surfaceContainerHighest: surfaceHigh,
      outline: outline,
      outlineVariant: outline.withValues(alpha: 0.6),
    );
    final base = ThemeData(colorScheme: scheme, useMaterial3: true, brightness: brightness);
    final text = base.textTheme.apply(
      bodyColor: onSurface,
      displayColor: onSurface,
      fontFamilyFallback: symbolFontFallback,
    );
    return base.copyWith(
      scaffoldBackgroundColor: background,
      textTheme: text.copyWith(
        headlineMedium: text.headlineMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.2),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: outline.withValues(alpha: 0.7)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStatePropertyAll(text.labelSmall),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceHigh.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: outline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      dividerTheme: DividerThemeData(color: outline.withValues(alpha: 0.6), space: 1),
    );
  }

  /// Themes with a night-sky background decoration.
  static bool isStarry(AppThemeId id) => id == AppThemeId.cosmic || id == AppThemeId.midnight;
}
