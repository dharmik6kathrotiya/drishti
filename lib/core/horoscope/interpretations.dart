import 'interpretations_bn.dart';
import 'interpretations_en.dart';
import 'interpretations_hi.dart';
import 'interpretations_kn.dart';
import 'interpretations_ml.dart';
import 'interpretations_mr.dart';
import 'interpretations_ta.dart';
import 'interpretations_te.dart';

/// A language pack for horoscope texts.
///
/// Every language provides the same keys as [interpretationsEn]. Each key maps
/// to one or more variants; the generator picks a variant with a stable hash
/// so the same day always reads the same, while different days vary.
/// Placeholders are written as `{name}`.
class HoroscopeTexts {
  const HoroscopeTexts(this.languageCode, this.entries);

  final String languageCode;
  final Map<String, List<String>> entries;

  /// Looks up [key], falling back to English when a translation is missing.
  List<String> variants(String key) => entries[key] ?? interpretationsEn.entries[key] ?? <String>['[$key]'];

  String pick(String key, int hash, [Map<String, String> args = const {}]) {
    final v = variants(key);
    return fill(v[hash.abs() % v.length], args);
  }

  String one(String key, [Map<String, String> args = const {}]) => pick(key, 0, args);

  /// Like [one], but null when neither this language nor English has [key].
  String? maybe(String key) => (entries[key] ?? interpretationsEn.entries[key])?.first;

  /// This language's own text for [key], without the English fallback. Used
  /// for language-specific forms (e.g. English articles: "the Sun").
  String? own(String key) => entries[key]?.first;

  static String fill(String template, Map<String, String> args) {
    var out = template;
    args.forEach((k, v) => out = out.replaceAll('{$k}', v));
    return out;
  }
}

/// Languages with a horoscope text pack.
const horoscopeLanguages = ['en', 'hi', 'mr', 'bn', 'ta', 'te', 'kn', 'ml'];

/// Registry of available languages. New languages add a parallel file with
/// the same keys (e.g. interpretations_hi.dart) and register it here.
HoroscopeTexts horoscopeTextsFor(String languageCode) => switch (languageCode) {
  'hi' => interpretationsHi,
  'mr' => interpretationsMr,
  'bn' => interpretationsBn,
  'ta' => interpretationsTa,
  'te' => interpretationsTe,
  'kn' => interpretationsKn,
  'ml' => interpretationsMl,
  _ => interpretationsEn,
};

/// Stable 32-bit FNV-1a hash used to choose text variants deterministically.
int stableHash(String s) {
  var h = 0x811c9dc5;
  for (final c in s.codeUnits) {
    h ^= c;
    h = (h * 0x01000193) & 0xffffffff;
  }
  return h;
}
