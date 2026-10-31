/// Core astrological reference data shared by Vedic and Western modules.
library;

enum Planet {
  sun,
  moon,
  mars,
  mercury,
  jupiter,
  venus,
  saturn,
  rahu,
  ketu,
  uranus,
  neptune,
  pluto;

  bool get isNode => this == rahu || this == ketu;
  bool get isOuter => this == uranus || this == neptune || this == pluto;

  /// The nine grahas used in Vedic astrology.
  static const vedic = [sun, moon, mars, mercury, jupiter, venus, saturn, rahu, ketu];

  /// Bodies used in Western astrology (Rahu = North Node, Ketu = South Node).
  static const western = [sun, moon, mercury, venus, mars, jupiter, saturn, uranus, neptune, pluto, rahu, ketu];

  /// Planet glyph followed by U+FE0E so phones draw it as text, not emoji.
  String get symbol => '$_glyph\uFE0E';

  String get _glyph => const {
    Planet.sun: '☉',
    Planet.moon: '☽',
    Planet.mars: '♂',
    Planet.mercury: '☿',
    Planet.jupiter: '♃',
    Planet.venus: '♀',
    Planet.saturn: '♄',
    Planet.rahu: '☊',
    Planet.ketu: '☋',
    Planet.uranus: '♅',
    Planet.neptune: '♆',
    Planet.pluto: '♇',
  }[this]!;

  /// Short abbreviation used inside chart drawings.
  String get abbr => const {
    Planet.sun: 'Su',
    Planet.moon: 'Mo',
    Planet.mars: 'Ma',
    Planet.mercury: 'Me',
    Planet.jupiter: 'Ju',
    Planet.venus: 'Ve',
    Planet.saturn: 'Sa',
    Planet.rahu: 'Ra',
    Planet.ketu: 'Ke',
    Planet.uranus: 'Ur',
    Planet.neptune: 'Ne',
    Planet.pluto: 'Pl',
  }[this]!;
}

enum Sign {
  aries,
  taurus,
  gemini,
  cancer,
  leo,
  virgo,
  libra,
  scorpio,
  sagittarius,
  capricorn,
  aquarius,
  pisces;

  static Sign fromLongitude(double lon) => Sign.values[(norm360(lon) ~/ 30) % 12];

  Sign operator +(int n) => Sign.values[(index + n) % 12];

  /// 1-based count from this sign to [other] (same sign = 1).
  int countTo(Sign other) => ((other.index - index) % 12) + 1;

  /// Zodiac glyph followed by U+FE0E so phones draw it as text, not emoji.
  String get symbol => '${const ['♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓'][index]}\uFE0E';

  /// Sanskrit rashi name.
  String get rashi => const [
    'Mesha',
    'Vrishabha',
    'Mithuna',
    'Karka',
    'Simha',
    'Kanya',
    'Tula',
    'Vrishchika',
    'Dhanu',
    'Makara',
    'Kumbha',
    'Meena',
  ][index];

  Planet get lord => const [
    Planet.mars,
    Planet.venus,
    Planet.mercury,
    Planet.moon,
    Planet.sun,
    Planet.mercury,
    Planet.venus,
    Planet.mars,
    Planet.jupiter,
    Planet.saturn,
    Planet.saturn,
    Planet.jupiter,
  ][index];

  Element get element => Element.values[index % 4];
  Modality get modality => Modality.values[index % 3];
  bool get isOdd => index.isEven; // Aries (index 0) is the 1st, an odd sign.
}

enum Element { fire, earth, air, water }

enum Modality { movable, fixed, dual }

class Nakshatra {
  const Nakshatra._(this.index, this.name, this.lord, this.deity);

  final int index; // 0..26
  final String name;
  final Planet lord;
  final String deity;

  static const span = 360 / 27; // 13°20'
  static const padaSpan = span / 4; // 3°20'

  static Nakshatra fromLongitude(double lon) => all[(norm360(lon) / span).floor() % 27];

  /// Pada 1..4 for a sidereal longitude.
  static int padaOf(double lon) => ((norm360(lon) % span) / padaSpan).floor() + 1;

  static const all = [
    Nakshatra._(0, 'Ashwini', Planet.ketu, 'Ashwini Kumaras'),
    Nakshatra._(1, 'Bharani', Planet.venus, 'Yama'),
    Nakshatra._(2, 'Krittika', Planet.sun, 'Agni'),
    Nakshatra._(3, 'Rohini', Planet.moon, 'Brahma'),
    Nakshatra._(4, 'Mrigashira', Planet.mars, 'Soma'),
    Nakshatra._(5, 'Ardra', Planet.rahu, 'Rudra'),
    Nakshatra._(6, 'Punarvasu', Planet.jupiter, 'Aditi'),
    Nakshatra._(7, 'Pushya', Planet.saturn, 'Brihaspati'),
    Nakshatra._(8, 'Ashlesha', Planet.mercury, 'Nagas'),
    Nakshatra._(9, 'Magha', Planet.ketu, 'Pitris'),
    Nakshatra._(10, 'Purva Phalguni', Planet.venus, 'Bhaga'),
    Nakshatra._(11, 'Uttara Phalguni', Planet.sun, 'Aryaman'),
    Nakshatra._(12, 'Hasta', Planet.moon, 'Savitar'),
    Nakshatra._(13, 'Chitra', Planet.mars, 'Tvashtar'),
    Nakshatra._(14, 'Swati', Planet.rahu, 'Vayu'),
    Nakshatra._(15, 'Vishakha', Planet.jupiter, 'Indra-Agni'),
    Nakshatra._(16, 'Anuradha', Planet.saturn, 'Mitra'),
    Nakshatra._(17, 'Jyeshtha', Planet.mercury, 'Indra'),
    Nakshatra._(18, 'Mula', Planet.ketu, 'Nirriti'),
    Nakshatra._(19, 'Purva Ashadha', Planet.venus, 'Apas'),
    Nakshatra._(20, 'Uttara Ashadha', Planet.sun, 'Vishvadevas'),
    Nakshatra._(21, 'Shravana', Planet.moon, 'Vishnu'),
    Nakshatra._(22, 'Dhanishta', Planet.mars, 'Vasus'),
    Nakshatra._(23, 'Shatabhisha', Planet.rahu, 'Varuna'),
    Nakshatra._(24, 'Purva Bhadrapada', Planet.jupiter, 'Aja Ekapada'),
    Nakshatra._(25, 'Uttara Bhadrapada', Planet.saturn, 'Ahir Budhnya'),
    Nakshatra._(26, 'Revati', Planet.mercury, 'Pushan'),
  ];
}

/// Classical dignities (Parashari, BPHS ch. 3).
class Dignity {
  static const exaltation = {
    Planet.sun: 10.0, // Aries 10°
    Planet.moon: 33.0, // Taurus 3°
    Planet.mars: 298.0, // Capricorn 28°
    Planet.mercury: 165.0, // Virgo 15°
    Planet.jupiter: 95.0, // Cancer 5°
    Planet.venus: 357.0, // Pisces 27°
    Planet.saturn: 200.0, // Libra 20°
  };

  static Sign? exaltationSign(Planet p) {
    final e = exaltation[p];
    return e == null ? null : Sign.fromLongitude(e);
  }

  static Sign? debilitationSign(Planet p) => exaltationSign(p)?.let((s) => s + 6);

  static const moolatrikona = {
    Planet.sun: Sign.leo,
    Planet.moon: Sign.taurus,
    Planet.mars: Sign.aries,
    Planet.mercury: Sign.virgo,
    Planet.jupiter: Sign.sagittarius,
    Planet.venus: Sign.libra,
    Planet.saturn: Sign.aquarius,
  };

  static bool ownsSign(Planet p, Sign s) => s.lord == p;

  /// Naisargika (natural) friendships, BPHS ch. 3.
  static const _friends = {
    Planet.sun: [Planet.moon, Planet.mars, Planet.jupiter],
    Planet.moon: [Planet.sun, Planet.mercury],
    Planet.mars: [Planet.sun, Planet.moon, Planet.jupiter],
    Planet.mercury: [Planet.sun, Planet.venus],
    Planet.jupiter: [Planet.sun, Planet.moon, Planet.mars],
    Planet.venus: [Planet.mercury, Planet.saturn],
    Planet.saturn: [Planet.mercury, Planet.venus],
  };
  static const _enemies = {
    Planet.sun: [Planet.venus, Planet.saturn],
    Planet.moon: <Planet>[],
    Planet.mars: [Planet.mercury],
    Planet.mercury: [Planet.moon],
    Planet.jupiter: [Planet.mercury, Planet.venus],
    Planet.venus: [Planet.sun, Planet.moon],
    Planet.saturn: [Planet.sun, Planet.moon, Planet.mars],
  };

  /// 1 = friend, 0 = neutral, -1 = enemy. Nodes are treated as neutral.
  static int naturalRelation(Planet a, Planet b) {
    if (a == b) return 1;
    if (_friends[a]?.contains(b) ?? false) return 1;
    if (_enemies[a]?.contains(b) ?? false) return -1;
    return 0;
  }
}

extension Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}

double norm360(double x) {
  final r = x % 360.0;
  return r < 0 ? r + 360.0 : r;
}

/// Smallest angular distance between two longitudes (0..180).
double angularDistance(double a, double b) {
  final d = norm360(a - b);
  return d > 180 ? 360 - d : d;
}

/// Formats a longitude inside its sign as 12°34'56".
String formatDms(double degrees, {bool seconds = true}) {
  final totalSec = (degrees.abs() * 3600).round();
  final d = totalSec ~/ 3600;
  final m = (totalSec % 3600) ~/ 60;
  final s = totalSec % 60;
  final str = seconds ? "$d°${_two(m)}'${_two(s)}\"" : "$d°${_two(m)}'";
  return degrees < 0 ? '-$str' : str;
}

String _two(int n) => n.toString().padLeft(2, '0');
