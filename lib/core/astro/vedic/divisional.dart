import '../constants.dart';

/// Parashari divisional charts (vargas), BPHS ch. 6-7.
enum Varga {
  d1(1, 'Rashi', 'Body, overall life'),
  d2(2, 'Hora', 'Wealth'),
  d3(3, 'Drekkana', 'Siblings, courage'),
  d4(4, 'Chaturthamsa', 'Property, fortune, home'),
  d7(7, 'Saptamsa', 'Children'),
  d9(9, 'Navamsa', 'Spouse, dharma, inner strength'),
  d10(10, 'Dasamsa', 'Career, status'),
  d12(12, 'Dwadasamsa', 'Parents'),
  d16(16, 'Shodasamsa', 'Vehicles, comforts'),
  d20(20, 'Vimsamsa', 'Spiritual practice'),
  d24(24, 'Chaturvimsamsa', 'Education, learning'),
  d27(27, 'Saptavimsamsa (Bhamsa)', 'Strength, weakness'),
  d30(30, 'Trimsamsa', 'Misfortunes, character'),
  d40(40, 'Khavedamsa', 'Maternal legacy, auspicious effects'),
  d45(45, 'Akshavedamsa', 'Paternal legacy, general conduct'),
  d60(60, 'Shashtiamsa', 'Past karma, all matters');

  const Varga(this.division, this.name, this.signifies);
  final int division;
  final String name;
  final String signifies;

  String get code => 'D$division';

  /// Sign occupied in this varga by a body at sidereal [longitude].
  Sign signOf(double longitude) {
    final lon = norm360(longitude);
    final sign = Sign.fromLongitude(lon);
    final deg = lon % 30;
    final part = (deg / (30 / division)).floor().clamp(0, division - 1);
    final odd = sign.isOdd;

    switch (this) {
      case Varga.d1:
        return sign;
      case Varga.d2:
        // Odd signs: first half Sun (Leo), second Moon (Cancer); even reversed.
        final firstHalf = deg < 15;
        return (odd == firstHalf) ? Sign.leo : Sign.cancer;
      case Varga.d3:
        return sign + const [0, 4, 8][part];
      case Varga.d4:
        return sign + const [0, 3, 6, 9][part];
      case Varga.d7:
        return (odd ? sign : sign + 6) + part;
      case Varga.d9:
        // Continuous from Aries: fire→Aries, earth→Capricorn, air→Libra, water→Cancer.
        return Sign.values[(lon / (30 / 9)).floor() % 12];
      case Varga.d10:
        return (odd ? sign : sign + 8) + part;
      case Varga.d12:
        return sign + part;
      case Varga.d16:
        return _byModality(sign, Sign.aries, Sign.leo, Sign.sagittarius) + part;
      case Varga.d20:
        return _byModality(sign, Sign.aries, Sign.sagittarius, Sign.leo) + part;
      case Varga.d24:
        return (odd ? Sign.leo : Sign.cancer) + part;
      case Varga.d27:
        return Sign.values[(lon / (30 / 27)).floor() % 12];
      case Varga.d30:
        return _trimsamsa(odd, deg);
      case Varga.d40:
        return (odd ? Sign.aries : Sign.libra) + part;
      case Varga.d45:
        return _byModality(sign, Sign.aries, Sign.leo, Sign.sagittarius) + part;
      case Varga.d60:
        return sign + part;
    }
  }

  static Sign _byModality(Sign s, Sign movable, Sign fixed, Sign dual) => switch (s.modality) {
    Modality.movable => movable,
    Modality.fixed => fixed,
    Modality.dual => dual,
  };

  static Sign _trimsamsa(bool odd, double deg) {
    if (odd) {
      if (deg < 5) return Sign.aries; // Mars
      if (deg < 10) return Sign.aquarius; // Saturn
      if (deg < 18) return Sign.sagittarius; // Jupiter
      if (deg < 25) return Sign.gemini; // Mercury
      return Sign.libra; // Venus
    }
    if (deg < 5) return Sign.taurus; // Venus
    if (deg < 12) return Sign.virgo; // Mercury
    if (deg < 20) return Sign.pisces; // Jupiter
    if (deg < 25) return Sign.capricorn; // Saturn
    return Sign.scorpio; // Mars
  }
}
