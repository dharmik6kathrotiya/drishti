import '../astro/constants.dart';
import 'explain_texts_bn.dart';
import 'explain_texts_hi.dart';
import 'explain_texts_kn.dart';
import 'explain_texts_ml.dart';
import 'explain_texts_mr.dart';
import 'explain_texts_ta.dart';
import 'explain_texts_te.dart';
import 'safety.dart';

/// Language pack for offline explanations. Every language provides the same
/// keys; missing entries fall back to English ([ExplainTextsEn]).
abstract class ExplainTexts {
  String get code;

  /// What a planet traditionally signifies (karakatva).
  String? planetNature(Planet p);

  /// Character of a sign.
  String? signNature(Sign s);

  /// Life areas of a house (1..12), Vedic or Western framing.
  String? houseNature(int house, {required bool vedic});

  /// Short description of a nakshatra (index 0..26).
  String? nakshatraNature(int index);

  /// Theme of a dasha period ruled by a planet.
  String? dashaTheme(Planet p);

  /// Meaning of an Ashtakoot koota by name.
  String? kootaMeaning(String koota);

  /// Fixed phrases (keys documented in [ExplainTextsEn.phrases]).
  String? phrase(String key);
}

ExplainTexts explainTextsFor(String languageCode) => switch (languageCode) {
  'hi' => const ExplainTextsHi(),
  'mr' => const ExplainTextsMr(),
  'bn' => const ExplainTextsBn(),
  'ta' => const ExplainTextsTa(),
  'te' => const ExplainTextsTe(),
  'kn' => const ExplainTextsKn(),
  'ml' => const ExplainTextsMl(),
  _ => const ExplainTextsEn(),
};

/// Languages with a complete explanation pack.
const explainLanguages = ['en', 'hi', 'mr', 'bn', 'ta', 'te', 'kn', 'ml'];

/// Base for translated packs: every member is a lookup in plain maps so a
/// translation file is just data.
abstract class MapExplainTexts implements ExplainTexts {
  const MapExplainTexts();

  Map<Planet, String> get planets;
  List<String> get signs;
  List<String> get vedicHouses;
  List<String> get westernHouses;
  List<String> get nakshatras;
  Map<Planet, String> get dasha;
  Map<String, String> get kootas;
  Map<String, String> get phrases;

  @override
  String? planetNature(Planet p) => planets[p];
  @override
  String? signNature(Sign s) => signs.length == 12 ? signs[s.index] : null;
  @override
  String? houseNature(int house, {required bool vedic}) {
    final list = vedic ? vedicHouses : westernHouses;
    return list.length == 12 ? list[(house - 1) % 12] : null;
  }

  @override
  String? nakshatraNature(int index) => nakshatras.length == 27 ? nakshatras[index % 27] : null;
  @override
  String? dashaTheme(Planet p) => dasha[p];
  @override
  String? kootaMeaning(String koota) => kootas[koota];
  @override
  String? phrase(String key) => phrases[key];
}

/// Looks up a value in [primary] and falls back to English.
class FallbackTexts {
  const FallbackTexts(this.primary);
  final ExplainTexts primary;
  static const _en = ExplainTextsEn();

  String planetNature(Planet p) => primary.planetNature(p) ?? _en.planetNature(p)!;
  String signNature(Sign s) => primary.signNature(s) ?? _en.signNature(s)!;
  String houseNature(int h, {required bool vedic}) =>
      primary.houseNature(h, vedic: vedic) ?? _en.houseNature(h, vedic: vedic)!;
  String nakshatraNature(int i) => primary.nakshatraNature(i) ?? _en.nakshatraNature(i)!;
  String dashaTheme(Planet p) => primary.dashaTheme(p) ?? _en.dashaTheme(p)!;
  String kootaMeaning(String k) => primary.kootaMeaning(k) ?? _en.kootaMeaning(k) ?? '';
  String phrase(String key) => primary.phrase(key) ?? _en.phrase(key) ?? key;

  /// Phrase with `{name}` placeholders filled in.
  String fill(String key, [Map<String, String> values = const {}]) => fillTemplate(phrase(key), values);

  /// Planet name in this language (English: "Sun").
  String planetName(Planet p) => primary.phrase('planet.${p.name}') ?? capitalize(p.name);

  /// Western sign name in this language (English: "Aries").
  String signName(Sign s) => primary.phrase('sign.${s.name}') ?? capitalize(s.name);

  /// Vedic sign name in this language (English: "Mesha (Aries)").
  String rashiName(Sign s) => primary.phrase('rashi.${s.name}') ?? '${s.rashi} (${capitalize(s.name)})';

  /// Ordinal number ("7th"). Translations give a `{n}` template.
  String ordinal(int n) {
    final tpl = primary.phrase('ordinal');
    return tpl == null ? englishOrdinal(n) : fillTemplate(tpl, {'n': '$n'});
  }
}

/// Original English text library. Written for this app; tone rules: balanced,
/// never fear-based, never a guarantee, always "traditionally".
class ExplainTextsEn implements ExplainTexts {
  const ExplainTextsEn();

  @override
  String get code => 'en';

  static const _planets = {
    Planet.sun: 'The Sun traditionally represents the self, vitality, confidence, authority, the father and recognition. It is the natural significator (karaka) of the soul and of leadership.',
    Planet.moon: 'The Moon traditionally represents the mind, feelings, comfort, the mother, public life and how you respond to change. In Vedic astrology it is as important as the Ascendant.',
    Planet.mars: 'Mars traditionally represents energy, courage, initiative, siblings, land and technical skill. It is the planet of action and drive, which can also show up as impatience.',
    Planet.mercury: 'Mercury traditionally represents intellect, speech, learning, trade, writing, humour and adaptability. It signifies how you think and communicate.',
    Planet.jupiter: 'Jupiter traditionally represents wisdom, teachers, ethics, growth, children, wealth and good fortune. It is considered the greatest natural benefic.',
    Planet.venus: 'Venus traditionally represents love, partnership, beauty, art, comfort, vehicles and enjoyment. It shows what you value and how you relate.',
    Planet.saturn: 'Saturn traditionally represents discipline, time, patience, work, responsibility and endurance. Its results tend to come slowly but last long.',
    Planet.rahu: 'Rahu, the Moon\'s north node, traditionally represents ambition, the unconventional, foreign things, technology and strong desires. It amplifies whatever it touches.',
    Planet.ketu: 'Ketu, the Moon\'s south node, traditionally represents detachment, spirituality, past skills, research and letting go. It can bring insight through simplification.',
    Planet.uranus:
        'Uranus (used in Western astrology) represents change, originality, independence and sudden insight.',
    Planet.neptune: 'Neptune (used in Western astrology) represents imagination, compassion, dreams, spirituality and blurred boundaries.',
    Planet.pluto: 'Pluto (used in Western astrology) represents transformation, depth, power and renewal.',
  };

  static const _signs = [
    'Aries (Mesha) is a fiery, movable sign ruled by Mars: direct, pioneering and energetic.',
    'Taurus (Vrishabha) is an earthy, fixed sign ruled by Venus: steady, practical and pleasure-loving.',
    'Gemini (Mithuna) is an airy, dual sign ruled by Mercury: curious, communicative and versatile.',
    'Cancer (Karka) is a watery, movable sign ruled by the Moon: caring, protective and sensitive.',
    'Leo (Simha) is a fiery, fixed sign ruled by the Sun: dignified, generous and expressive.',
    'Virgo (Kanya) is an earthy, dual sign ruled by Mercury: analytical, helpful and detail-minded.',
    'Libra (Tula) is an airy, movable sign ruled by Venus: fair-minded, social and aesthetic.',
    'Scorpio (Vrishchika) is a watery, fixed sign ruled by Mars: intense, private and determined.',
    'Sagittarius (Dhanu) is a fiery, dual sign ruled by Jupiter: idealistic, philosophical and free-spirited.',
    'Capricorn (Makara) is an earthy, movable sign ruled by Saturn: ambitious, disciplined and patient.',
    'Aquarius (Kumbha) is an airy, fixed sign ruled by Saturn: independent, humanitarian and inventive.',
    'Pisces (Meena) is a watery, dual sign ruled by Jupiter: compassionate, imaginative and spiritual.',
  ];

  static const _vedicHouses = [
    '1st house (Lagna): self, body, personality and the overall direction of life.',
    '2nd house: family, savings, speech, food and early education.',
    '3rd house: courage, effort, siblings, short travel, communication and skills.',
    '4th house: home, mother, inner peace, property, vehicles and basic education.',
    '5th house: intelligence, creativity, children, romance and past merit (purva punya).',
    '6th house: work routines, service, competition, debts, health habits and overcoming obstacles.',
    '7th house: partnership, marriage, business dealings and the public.',
    '8th house: transformation, research, inheritance, sudden events and longevity themes.',
    '9th house: fortune, father, teachers, dharma, higher learning and long journeys.',
    '10th house: career, status, actions in the world and reputation.',
    '11th house: gains, income, friends, networks and fulfilment of wishes.',
    '12th house: expenses, foreign lands, rest, retreat, spirituality and letting go.',
  ];

  static const _westernHouses = [
    '1st house: identity, appearance and how you begin things.',
    '2nd house: money, possessions, values and self-worth.',
    '3rd house: communication, learning, siblings and the local environment.',
    '4th house: home, family, roots and private life.',
    '5th house: creativity, play, romance and children.',
    '6th house: daily work, health habits and service.',
    '7th house: partnerships, marriage and close one-to-one relationships.',
    '8th house: shared resources, intimacy, transformation and renewal.',
    '9th house: beliefs, higher education, travel and meaning.',
    '10th house: career, public role and ambitions.',
    '11th house: friends, communities, hopes and the future.',
    '12th house: solitude, the unconscious, healing and endings.',
  ];

  static const _nakshatras = [
    'Ashwini (ruled by Ketu, deity the Ashwini Kumaras, the divine healers): quick, helpful and pioneering.',
    'Bharani (Venus; Yama): responsible, intense and able to carry heavy loads.',
    'Krittika (Sun; Agni): sharp, purifying and decisive.',
    'Rohini (Moon; Brahma): creative, attractive and growth-oriented.',
    'Mrigashira (Mars; Soma): curious, searching and gentle.',
    'Ardra (Rahu; Rudra): emotional depth, renewal after storms, strong intellect.',
    'Punarvasu (Jupiter; Aditi): return of light, optimism and generosity.',
    'Pushya (Saturn; Brihaspati): nourishing, dutiful and dependable; considered very auspicious.',
    'Ashlesha (Mercury; Nagas): perceptive, strategic and intense.',
    'Magha (Ketu; the Pitris, ancestors): dignity, tradition and leadership.',
    'Purva Phalguni (Venus; Bhaga): enjoyment, warmth and creativity.',
    'Uttara Phalguni (Sun; Aryaman): reliability, patronage and commitments.',
    'Hasta (Moon; Savitar): skilful hands, wit and practicality.',
    'Chitra (Mars; Tvashtar, the cosmic architect): design, beauty and craftsmanship.',
    'Swati (Rahu; Vayu): independence, flexibility and trade.',
    'Vishakha (Jupiter; Indra-Agni): goal-focused determination.',
    'Anuradha (Saturn; Mitra): friendship, devotion and cooperation.',
    'Jyeshtha (Mercury; Indra): seniority, protection and responsibility.',
    'Mula (Ketu; Nirriti): getting to the root, research and transformation.',
    'Purva Ashadha (Venus; Apas): conviction, persuasion and refreshment.',
    'Uttara Ashadha (Sun; the Vishvadevas): lasting victory and principled effort.',
    'Shravana (Moon; Vishnu): listening, learning and connecting people.',
    'Dhanishta (Mars; the Vasus): rhythm, music, wealth and teamwork.',
    'Shatabhisha (Rahu; Varuna): healing, research and independence.',
    'Purva Bhadrapada (Jupiter; Aja Ekapada): idealism and intensity.',
    'Uttara Bhadrapada (Saturn; Ahir Budhnya): depth, wisdom and patience.',
    'Revati (Mercury; Pushan, the guide of travellers): kindness, guidance and completion.',
  ];

  static const _dasha = {
    Planet.sun: 'A Sun period traditionally brings focus on self-confidence, authority, government or senior people, and the father.',
    Planet.moon: 'A Moon period traditionally brings focus on emotions, home, the mother, public contact and changes of residence.',
    Planet.mars: 'A Mars period traditionally brings energy, initiative, competition, property matters and siblings.',
    Planet.mercury: 'A Mercury period traditionally brings learning, communication, trade, writing and networking.',
    Planet.jupiter:
        'A Jupiter period traditionally brings growth, learning, guidance, children and expansion of resources.',
    Planet.venus: 'A Venus period traditionally brings relationships, comforts, arts, vehicles and enjoyment.',
    Planet.saturn:
        'A Saturn period traditionally brings hard work, responsibility, structure and slow but steady results.',
    Planet.rahu: 'A Rahu period traditionally brings ambition, unconventional paths, foreign links and strong desires.',
    Planet.ketu: 'A Ketu period traditionally brings introspection, detachment, research and spiritual interests.',
  };

  static const _kootas = {
    'Varna': 'Varna compares the spiritual/temperamental class of the two Moon signs. It carries 1 point and is considered the least weighty koota.',
    'Vashya': 'Vashya looks at mutual attraction and influence based on the Moon-sign groups (2 points).',
    'Tara': 'Tara compares the birth stars counted from each other; favourable taras are linked with well-being (3 points).',
    'Yoni': 'Yoni compares the animal symbols of the two birth stars, traditionally linked with physical compatibility (4 points).',
    'Graha Maitri': 'Graha Maitri checks the friendship between the lords of the two Moon signs, linked with mental compatibility (5 points).',
    'Gana': 'Gana compares temperament: Deva (gentle), Manushya (human) and Rakshasa (intense) (6 points).',
    'Bhakoot': 'Bhakoot looks at the distance between the Moon signs, traditionally linked with family welfare and prosperity (7 points).',
    'Nadi': 'Nadi compares the Ayurvedic constitution of the birth stars, traditionally linked with health and progeny (8 points). Classical exceptions exist.',
  };

  /// Fixed phrases. Placeholders use {name} style.
  static const phrases = {
    'caveat': 'This is a traditional interpretation. It may or may not apply to you, and the whole chart matters more than any single factor.',
    'caveatTraditionsDiffer': 'Different traditions weigh this differently.',
    'exalted': '{planet} is exalted in {sign}, where classical texts say it gives its best results.',
    'debilitated': '{planet} is debilitated in {sign}. Classical texts list several conditions (neecha bhanga) that can cancel or soften this, so it is not judged alone.',
    'ownSign': '{planet} is in its own sign, {sign}, which is traditionally considered comfortable and strong.',
    'moolatrikona': '{sign} is the moolatrikona sign of {planet}, considered a strong placement.',
    'friendSign': '{planet} is in the sign of a natural friend ({lord}), traditionally a supportive placement.',
    'enemySign':
        '{planet} is in the sign of a natural enemy ({lord}), traditionally a placement that asks for more effort.',
    'neutralSign': '{planet} is in the sign of a neutral planet ({lord}).',
    'retro': '{planet} was retrograde at birth. Many astrologers read retrograde planets as more internal or revisited themes; views differ.',
    'beneficKendra':
        'Natural benefics in angular houses (1, 4, 7, 10) are traditionally considered strengthening for the chart.',
    'maleficUpachaya': 'Natural malefics in upachaya houses (3, 6, 10, 11, "houses of growth") are traditionally said to improve with time and effort.',
    'dusthana': 'The 6th, 8th and 12th are called dusthanas. Planets here are traditionally linked with challenges that can also build resilience, research skills or spiritual depth.',
    'trikona': 'The 1st, 5th and 9th are trikonas, traditionally the most auspicious houses.',
    'houseSource': 'House effects are described in Brihat Parashara Hora Shastra (BPHS) and Phaladeepika.',
    'signSource': 'Dignities (exaltation, own sign, friendship) follow BPHS ch. 3.',
    'nakshatraSource': 'Nakshatra lords and deities follow the standard classical list (e.g. BPHS); the descriptions are general summaries.',
    'dashaSource':
        'Vimshottari dasha as described in BPHS. Results depend on the lord\'s strength and placement in your chart.',
    'transitSource': 'Gochara (transit) results counted from the Moon follow Phaladeepika ch. 26.',
    'kootaSource':
        'Ashtakoot matching as used in common North Indian practice; point tables vary slightly between almanacs.',
    'dashaPlacement': 'In your chart {planet} is in {sign}{house}, so this period may especially touch those themes.',
    'dashaPair': 'The sub-period of {antar} within {maha} blends both themes. {relation}',
    'relFriend': '{a} and {b} are natural friends, which tradition considers a smooth combination.',
    'relEnemy': '{a} and {b} are natural enemies, which tradition says can bring mixed results that need balance.',
    'relNeutral': '{a} and {b} are neutral to each other.',
    'transitGood': 'Transiting {planet} in the {house} from your Moon sign is traditionally considered favourable.',
    'transitHard': 'Transiting {planet} in the {house} from your Moon sign is traditionally considered a time to be more careful and patient.',
    'transitObstructed': 'Its good effect is traditionally obstructed (vedha) by {by} in the {vh} house from the Moon.',
    'noTime': 'Without an exact birth time, houses and the Ascendant cannot be judged; this explanation uses signs and the Moon only.',
    'westernNote': 'In Western (tropical) astrology this is read psychologically rather than predictively.',

    // Explanation building blocks.
    'occupies': 'It occupies your {text}',
    'nakshatraIs': 'Its nakshatra is {text}',
    'titlePlacement': '{planet} in {sign}',
    'titleHouseSuffix': ', house {n}',
    'askPlacement': 'What does {planet} in my chart mean for me?',
    'lagna': 'Lagna',
    'ascendant': 'Ascendant',
    'ascIntro': 'The rising sign shapes how you meet the world and is the starting point of every house in the chart.',
    'ascLord': 'Its lord, {lord}, becomes an important planet for you. {nature}',
    'askAscendant': 'What does my ascendant say about my personality?',
    'padaSuffix': ' pada {n}',
    'nakLord': 'Its lord {lord} also decides which Vimshottari dasha you were born in.',
    'askNakshatra': 'What does my birth nakshatra say about me?',
    'houseSuffix': ' (house {n})',
    'houseRelates': 'That house relates to: {text}',
    'mahadasha': 'Mahadasha',
    'antardasha': 'Antardasha',
    'pratyantardasha': 'Pratyantardasha',
    'askDasha': 'What does my current {planet} period mean for me?',
    'yogaTiming': 'Classical texts say a yoga gives its results mainly in the dashas of the planets that form it, and in proportion to their strength.',
    'askYoga': 'How does {yoga} work in my chart?',
    'softening': 'Softening factors: {list}',
    'doshaNote': 'A dosha is a traditional indicator, not a verdict. {differ}',
    'askDosha': 'Explain {dosha} in my chart calmly',
    'titleTransit': 'Transit {planet} in {sign}',
    'transitTouches': 'The transit touches: {text}',
    'askTransit': 'How long will {planet} affect me this way?',
    'groomBride': 'Groom: {boy}. Bride: {girl}.',
    'kootaZero': 'A zero here is one traditional factor among eight; astrologers also look at exceptions and at both full charts.',
    'askText': 'Tell me more about {title} for me',

    // Rule-based answers.
    'intent.career': 'career and work',
    'intent.money': 'money and gains',
    'intent.relationships': 'relationships and marriage',
    'intent.health': 'general vitality',
    'intent.education': 'education and learning',
    'intent.travel': 'travel and life abroad',
    'intent.children': 'children',
    'intent.property': 'home and property',
    'intent.spirituality': 'spirituality',
    'intent.personality': 'personality',
    'intent.general': 'life in general',
    'ansIntro': 'Here is what your chart traditionally shows about {label}, based only on calculated positions.',
    'moonSignDescribes': 'The Moon sign describes your emotional nature.',
    'classicalSigns': 'Classical sign descriptions',
    'houseFact': 'House {h}: lord {lord} in {sign}{house}{occupants}.',
    'occupiedBy': ', occupied by {list}',
    'noPlanets': ', no planets in it',
    'naturalSignificator': '{planet} is a natural significator of {label}.',
    'connectedTo': '{planet} is connected to {label} ({parts}).',
    'connHouse': 'house {list}',
    'connHouses': 'houses {list}',
    'connKaraka': 'as a natural significator',
    'runningPeriod': 'Running period: {maha} / {antar} until {date}.',
    'dashaLinked': 'Your current dasha lords are linked with this area, which tradition reads as a period when it becomes more active.',
    'dashaNotLinked': 'Your current dasha lords are not directly linked with this area, so tradition would not single out the present period for it.',
    'timingWindows': 'Periods that tradition considers more connected to {label}: {list}. These are windows of emphasis, not predictions of a specific event.',
    'periodRange': '{maha}/{antar} ({from} to {to})',
    'timingNone': 'None of the next few sub-periods is strongly linked with {label} by the rules used here. Choices and circumstances matter more than any timing rule.',
    'relationshipNote':
        'Relationships depend most on mutual respect, values and communication; astrology describes tendencies only.',
    'improveTime': 'Add your exact birth time to unlock houses, the Ascendant and precise dasha dates.',
    'improvePlace': 'Add your birthplace for the correct timezone and houses.',
    'factorsBelow': 'The factors below are what this reading is based on. Tap any to learn more.',
    'teenRelationships': 'Questions about marriage, romance and children are available only for adults. I\'m happy to talk about your strengths, studies or interests instead.',
    'teenHealth': 'Drishti does not make health predictions in teen mode. For anything about your health, please talk to a parent, guardian or doctor.',
    'lifeIntro': 'You asked about lifespan. Below is exactly what the classical calculation says for {name}\'s chart, without hiding anything. It is a traditional method, not a medical fact, and no method can give a true date of death.',
    'lifeMaraka': 'Tradition calls {list} the maraka planets of this chart. Inside this span it marks these periods as sensitive for health: {periods}.',
    'lifeMarakaNone': 'Tradition calls {list} the maraka planets of this chart. None of their periods falls in the rest of this span.',
    'lifePastNote': 'Classical texts adjust the span with further rules that Drishti does not apply, so being past it simply shows the limits of this method.',
    'lifeCare': 'What tradition and common sense both suggest, especially in those periods: regular health check-ups, careful driving and travel, enough rest, and avoiding risky habits. Traditional practices include the Mahamrityunjaya mantra, prayer and charity.',
    'lifeCaveat': 'Different schools use different year ranges and further corrections, and astrology has no proven power to predict lifespan. Treat this only as what this calculation says.',
    'lifeWestern': 'Western astrology as used in Drishti has no standard lifespan calculation. Switch to Vedic in Settings to see the classical Jaimini longevity method for this chart.',
    'lifeSupport': 'If this question comes from feeling low or unsafe, please talk to someone now: Tele-MANAS 14416 or KIRAN 1800-599-0019 (free, 24×7).',
    'lifeExplainSpan': 'Jaimini compares three pairs of signs. Each pair\'s sign types (movable, fixed, dual) give a short, middle or long span, and the span most pairs agree on is taken.',
    'lifeExplainMaraka': 'Maraka means \'one that can end\'. Classical texts name the lords of and planets in the 2nd and 7th houses, and read their periods as times to take extra care of health.',
    'teenLongevity': 'Lifespan readings are available only for adults. If something is worrying you, please talk to a parent, guardian or doctor.',

    // Safety (crisis helplines must stay: Tele-MANAS 14416, KIRAN 1800-599-0019).
    'safety.crisis': Safety.crisisMessage,
    'safety.medical': Safety.professionalMedical,
    'safety.legal': Safety.professionalLegal,
    'safety.financial': Safety.professionalFinancial,
    'safety.pregnancy': Safety.professionalPregnancy,
  };

  @override
  String? planetNature(Planet p) => _planets[p];

  @override
  String? signNature(Sign s) => _signs[s.index];

  @override
  String? houseNature(int house, {required bool vedic}) => (vedic ? _vedicHouses : _westernHouses)[(house - 1) % 12];

  @override
  String? nakshatraNature(int index) => _nakshatras[index % 27];

  @override
  String? dashaTheme(Planet p) => _dasha[p];

  @override
  String? kootaMeaning(String koota) => _kootas[koota];

  @override
  String? phrase(String key) => phrases[key];
}

/// Fills `{name}` placeholders.
String fillTemplate(String template, Map<String, String> values) {
  var out = template;
  values.forEach((k, v) => out = out.replaceAll('{$k}', v));
  return out;
}

/// English ordinal ("7th"); see [FallbackTexts.ordinal] for other languages.
String ordinal(int n) => englishOrdinal(n);

String englishOrdinal(int n) {
  if (n % 100 >= 11 && n % 100 <= 13) return '${n}th';
  return switch (n % 10) {
    1 => '${n}st',
    2 => '${n}nd',
    3 => '${n}rd',
    _ => '${n}th',
  };
}

String capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
