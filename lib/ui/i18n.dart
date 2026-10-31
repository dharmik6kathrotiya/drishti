import 'package:flutter/widgets.dart';

import '../core/i18n/astro_names.dart';
import '../core/i18n/engine_texts.dart';

/// Shortcuts for localized astro names and engine texts in widgets.
extension AstroI18nContext on BuildContext {
  String get languageCode => Localizations.maybeLocaleOf(this)?.languageCode ?? 'en';

  /// Planet, sign, nakshatra and Panchang names in the user's language.
  AstroNames get names => AstroNames.of(languageCode);

  /// Localized engine output (options, vargas, matching, doshas, yogas...).
  EngineTexts get engineTexts => EngineTexts.of(languageCode);
}
