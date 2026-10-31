/// Calculation options the user can choose. Every option carries a short
/// explanation and the popular default is marked as recommended.
library;

enum AstroSystem { vedic, western }

enum Ayanamsa {
  lahiri(
    'Lahiri (Chitrapaksha)',
    'Official ayanamsa of the Indian government (Calendar Reform Committee, 1955). Used by most Indian astrologers and apps.',
    recommended: true,
  ),
  kp('KP (Krishnamurti)', 'Used in the Krishnamurti Paddhati system. About 6 arc-minutes less than Lahiri.'),
  raman('B.V. Raman', 'Popularised by B.V. Raman. About 1.5° less than Lahiri.'),
  trueChitra('True Chitra', 'Keeps the star Spica (Chitra) exactly at 0° Libra using its true position.'),
  yukteshwar('Sri Yukteshwar', 'From "The Holy Science" by Sri Yukteshwar.'),
  jnBhasin('J.N. Bhasin', 'Ayanamsa used by astrologer J.N. Bhasin.'),
  trueRevati('True Revati', 'Places the star Revati (zeta Piscium) at the end of Pisces.'),
  truePushya('True Pushya', 'Places delta Cancri at 16° Cancer (P.V.R. Narasimha Rao suggestion).'),
  faganBradley('Fagan-Bradley', 'Standard ayanamsa of Western sidereal astrology.');

  const Ayanamsa(this.label, this.description, {this.recommended = false});
  final String label;
  final String description;
  final bool recommended;
}

enum HouseSystem {
  wholeSign(
    'Whole Sign',
    'Each sign is one house, starting from the rising sign. The traditional method in Vedic (Parashari) astrology and Hellenistic astrology.',
  ),
  placidus(
    'Placidus',
    'The most widely used house system in modern Western astrology. Houses divide the time a degree takes to rise.',
  ),
  koch('Koch', 'Popular in Germany and the US; similar to Placidus but uses the birthplace\'s horizon differently.'),
  equal('Equal', 'Each house is exactly 30° starting from the Ascendant degree.'),
  porphyry('Porphyry', 'Divides each quadrant between Ascendant and Midheaven into three equal parts.'),
  regiomontanus('Regiomontanus', 'Medieval system dividing the celestial equator; used in horary astrology.'),
  campanus('Campanus', 'Divides the prime vertical into 12 equal parts.'),
  sripati(
    'Sripati (Bhava Chalit)',
    'Indian quadrant system: Porphyry cusps used as house middles (Bhava Chalit chart).',
  ),
  placidusKp('Placidus (KP cusps)', 'KP system uses Placidus cusps with the KP ayanamsa.');

  const HouseSystem(this.label, this.description);
  final String label;
  final String description;
}

enum NodeType {
  mean('Mean node', 'Average position of the Moon\'s node. Used by most Vedic astrologers.'),
  trueNode(
    'True node',
    'Actual oscillating position of the Moon\'s node. Preferred by many Western and KP astrologers.',
  );

  const NodeType(this.label, this.description);
  final String label;
  final String description;
}

enum ChartStyle {
  northIndian(
    'North Indian',
    'Diamond chart with fixed houses; the Ascendant is always at the top. Common in North and Central India.',
  ),
  southIndian('South Indian', 'Square chart with fixed signs; Pisces is at the top-left. Common in South India.'),
  eastIndian(
    'East Indian',
    'Square chart with fixed signs, Aries at the top centre. Common in Bengal, Odisha and Assam.',
  ),
  westernWheel('Western wheel', 'Circular chart used in Western astrology, showing exact degrees and aspects.');

  const ChartStyle(this.label, this.description);
  final String label;
  final String description;
}

class CalcSettings {
  const CalcSettings({
    this.system = AstroSystem.vedic,
    this.ayanamsa = Ayanamsa.lahiri,
    this.vedicHouses = HouseSystem.wholeSign,
    this.westernHouses = HouseSystem.placidus,
    this.nodeType = NodeType.mean,
  });

  final AstroSystem system;
  final Ayanamsa ayanamsa;
  final HouseSystem vedicHouses;
  final HouseSystem westernHouses;
  final NodeType nodeType;

  bool get sidereal => system == AstroSystem.vedic;
  HouseSystem get houseSystem => sidereal ? vedicHouses : westernHouses;

  CalcSettings copyWith({
    AstroSystem? system,
    Ayanamsa? ayanamsa,
    HouseSystem? vedicHouses,
    HouseSystem? westernHouses,
    NodeType? nodeType,
  }) => CalcSettings(
    system: system ?? this.system,
    ayanamsa: ayanamsa ?? this.ayanamsa,
    vedicHouses: vedicHouses ?? this.vedicHouses,
    westernHouses: westernHouses ?? this.westernHouses,
    nodeType: nodeType ?? this.nodeType,
  );

  Map<String, dynamic> toJson() => {
    'system': system.name,
    'ayanamsa': ayanamsa.name,
    'vedicHouses': vedicHouses.name,
    'westernHouses': westernHouses.name,
    'nodeType': nodeType.name,
  };

  factory CalcSettings.fromJson(Map json) => CalcSettings(
    system: _byName(AstroSystem.values, json['system'], AstroSystem.vedic),
    ayanamsa: _byName(Ayanamsa.values, json['ayanamsa'], Ayanamsa.lahiri),
    vedicHouses: _byName(HouseSystem.values, json['vedicHouses'], HouseSystem.wholeSign),
    westernHouses: _byName(HouseSystem.values, json['westernHouses'], HouseSystem.placidus),
    nodeType: _byName(NodeType.values, json['nodeType'], NodeType.mean),
  );
}

T _byName<T extends Enum>(List<T> values, Object? name, T fallback) =>
    values.where((v) => v.name == name).firstOrNull ?? fallback;
