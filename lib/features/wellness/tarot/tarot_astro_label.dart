import '../../../core/astro/constants.dart';
import '../../../core/i18n/astro_names.dart';

/// Localizes a tarot card's English astrological association, such as
/// "Mars in Aries", "Sagittarius", "Fire" or "Saturn (and Earth)".
String localizeTarotAstrology(String english, String lang) {
  final names = AstroNames.of(lang);
  final elements = _elements[lang] ?? _elements['en']!;
  final inTemplate = _inTemplate[lang] ?? _inTemplate['en']!;

  String term(String word) {
    final w = word.trim();
    for (final p in Planet.values) {
      if (_planetEn[p] == w) return names.planet(p);
    }
    for (final s in Sign.values) {
      if (_signEn[s.index] == w) return names.sign(s);
    }
    final e = const ['Fire', 'Water', 'Air', 'Earth'].indexOf(w);
    return e >= 0 ? elements[e] : w;
  }

  final root = RegExp(r'^Root of (\w+)$').firstMatch(english);
  if (root != null) return (_rootTemplate[lang] ?? _rootTemplate['en']!).replaceAll('{element}', term(root[1]!));
  // Court cards: "Earth of Fire" is the earthy side of Fire.
  final court = RegExp(r'^(Fire|Water|Air|Earth) of (Fire|Water|Air|Earth)$').firstMatch(english);
  if (court != null) {
    return (_ofTemplate[lang] ?? _ofTemplate['en']!)
        .replaceAll('{a}', term(court[1]!))
        .replaceAll('{b}', term(court[2]!));
  }
  // "Fire (Pluto in modern use)", "Air (Uranus in modern use)", "Water (Neptune in modern use)".
  final modern = RegExp(r'^(\w+) \((\w+) in modern use\)$').firstMatch(english);
  if (modern != null) return '${term(modern[1]!)} (${term(modern[2]!)})';
  if (english == 'Saturn (and Earth)') return '${names.planet(Planet.saturn)} (${term('Earth')})';
  final parts = english.split(' in ');
  if (parts.length == 2) {
    return inTemplate.replaceAll('{planet}', term(parts[0])).replaceAll('{sign}', term(parts[1]));
  }
  return term(english);
}

const _planetEn = {
  Planet.sun: 'Sun',
  Planet.moon: 'Moon',
  Planet.mars: 'Mars',
  Planet.mercury: 'Mercury',
  Planet.jupiter: 'Jupiter',
  Planet.venus: 'Venus',
  Planet.saturn: 'Saturn',
  Planet.rahu: 'Rahu',
  Planet.ketu: 'Ketu',
  Planet.uranus: 'Uranus',
  Planet.neptune: 'Neptune',
  Planet.pluto: 'Pluto',
};

const _signEn = [
  'Aries',
  'Taurus',
  'Gemini',
  'Cancer',
  'Leo',
  'Virgo',
  'Libra',
  'Scorpio',
  'Sagittarius',
  'Capricorn',
  'Aquarius',
  'Pisces',
];

const _inTemplate = {
  'en': '{planet} in {sign}',
  'hi': '{sign} में {planet}',
  'mr': '{sign} मध्ये {planet}',
  'bn': '{sign}-এ {planet}',
  'ta': '{sign} ராசியில் {planet}',
  'te': '{sign}లో {planet}',
  'kn': '{sign}ದಲ್ಲಿ {planet}',
  'ml': '{sign} രാശിയിൽ {planet}',
};

const _elements = {
  'en': ['Fire', 'Water', 'Air', 'Earth'],
  'hi': ['अग्नि', 'जल', 'वायु', 'पृथ्वी'],
  'mr': ['अग्नी', 'जल', 'वायू', 'पृथ्वी'],
  'bn': ['অগ্নি', 'জল', 'বায়ু', 'পৃথিবী'],
  'ta': ['நெருப்பு', 'நீர்', 'காற்று', 'நிலம்'],
  'te': ['అగ్ని', 'జలం', 'వాయువు', 'భూమి'],
  'kn': ['ಅಗ್ನಿ', 'ಜಲ', 'ವಾಯು', 'ಭೂಮಿ'],
  'ml': ['അഗ്നി', 'ജലം', 'വായു', 'ഭൂമി'],
};

/// Aces: the root (source) of their suit's element.
const _rootTemplate = {
  'en': 'Root of {element}',
  'hi': '{element} तत्व का मूल',
  'mr': '{element} तत्त्वाचे मूळ',
  'bn': '{element} তত্ত্বের মূল',
  'ta': '{element} தத்துவத்தின் மூலம்',
  'te': '{element} తత్త్వానికి మూలం',
  'kn': '{element} ತತ್ತ್ವದ ಮೂಲ',
  'ml': '{element} തത്ത്വത്തിന്റെ മൂലം',
};

/// Court cards: one element within another ("Earth of Fire").
const _ofTemplate = {
  'en': '{a} of {b}',
  'hi': '{b} में {a}',
  'mr': '{b} मधील {a}',
  'bn': '{b}-এর মধ্যে {a}',
  'ta': '{b}-இல் {a}',
  'te': '{b}లో {a}',
  'kn': '{b}ದಲ್ಲಿ {a}',
  'ml': '{b}-ലെ {a}',
};
