import '../astro/constants.dart';
import '../astro/settings.dart';
import '../astro/vedic/divisional.dart';
import '../astro/vedic/doshas.dart';
import '../astro/vedic/matching.dart';
import '../astro/vedic/yogas.dart';
import '../models/app_settings.dart';
import 'astro_names.dart';
import 'engine_texts_bn.dart';
import 'engine_texts_hi.dart';
import 'engine_texts_kn.dart';
import 'engine_texts_ml.dart';
import 'engine_texts_mr.dart';
import 'engine_texts_ta.dart';
import 'engine_texts_te.dart';
import 'text_ref.dart';

/// Localized texts for engine output (calculation options, vargas, dashas,
/// matching, doshas, yogas, numerology).
///
/// Texts are keyed strings with simple placeholders:
/// - `{name}`            a parameter (Planet, Sign, int, String, lists)
/// - `{name|and}`        a list joined with the language's "and"
/// - `{flag?yes|no}`     choose a text by a bool parameter
/// Missing translations fall back to English, then to the key itself.
class EngineTexts {
  EngineTexts._(this.lang, this._map) : names = AstroNames.of(lang);

  final String lang;
  final AstroNames names;
  final Map<String, String> _map;

  static final _cache = <String, EngineTexts>{};

  static EngineTexts of(String lang) =>
      _cache.putIfAbsent(lang, () => EngineTexts._(lang, _languages[lang] ?? const {}));

  static const _languages = <String, Map<String, String>>{
    'hi': engineTextsHi,
    'mr': engineTextsMr,
    'bn': engineTextsBn,
    'ta': engineTextsTa,
    'te': engineTextsTe,
    'kn': engineTextsKn,
    'ml': engineTextsMl,
  };

  /// Raw lookup with fallback to English.
  String raw(String key) => _map[key] ?? engineTextsEn[key] ?? key;

  bool has(String key) => _map.containsKey(key) || engineTextsEn.containsKey(key);

  /// Looks up [key] and fills in [params].
  String t(String key, [Map<String, Object> params = const {}]) => _fill(raw(key), params);

  String ref(TextRef r) => t(r.key, r.params);

  static final _placeholder = RegExp(r'\{(\w+)(?:\?([^|}]*)\|([^}]*)|\|(and))?\}');

  String _fill(String template, Map<String, Object> params) {
    if (params.isEmpty) return template;
    return template.replaceAllMapped(_placeholder, (m) {
      final name = m.group(1)!;
      final value = params[name];
      if (m.group(2) != null) {
        // {flag?yes|no}
        return value == true ? m.group(2)! : m.group(3)!;
      }
      if (value == null) return m.group(0)!;
      return _format(value, and: m.group(4) != null);
    });
  }

  String _format(Object v, {bool and = false}) {
    if (v is Planet) return names.planet(v);
    if (v is Sign) return names.rashi(v);
    if (v is Nakshatra) return names.nakshatraOf(v);
    if (v is TextRef) return ref(v);
    if (v is List) {
      final parts = v.map((e) => _format(e as Object)).toList();
      if (v.isNotEmpty && v.first is TextRef && !and) return parts.join(raw('list.semicolon'));
      if (and && parts.length > 1) {
        return '${parts.sublist(0, parts.length - 1).join(raw('list.comma'))}${raw('list.and')}${parts.last}';
      }
      return parts.join(raw('list.comma'));
    }
    return v.toString();
  }

  // ---- Calculation options -------------------------------------------------

  String ayanamsaLabel(Ayanamsa a) => raw('ayanamsa.${a.name}.label');
  String ayanamsaDesc(Ayanamsa a) => raw('ayanamsa.${a.name}.desc');
  String houseLabel(HouseSystem h) => raw('house.${h.name}.label');
  String houseDesc(HouseSystem h) => raw('house.${h.name}.desc');
  String nodeLabel(NodeType n) => raw('node.${n.name}.label');
  String nodeDesc(NodeType n) => raw('node.${n.name}.desc');
  String chartStyleLabel(ChartStyle s) => raw('chartStyle.${s.name}.label');
  String chartStyleDesc(ChartStyle s) => raw('chartStyle.${s.name}.desc');
  String themeLabel(AppThemeId t) => raw('theme.${t.name}.label');
  String themeDesc(AppThemeId t) => raw('theme.${t.name}.desc');
  String notifLabel(NotificationType n) => raw('notif.${n.name}.label');
  String notifDesc(NotificationType n) => raw('notif.${n.name}.desc');

  // ---- Vargas and dashas ---------------------------------------------------

  String vargaName(Varga v) => raw('varga.${v.code.toLowerCase()}.name');
  String vargaSignifies(Varga v) => raw('varga.${v.code.toLowerCase()}.sig');

  /// [system] is the engine's name ('Vimshottari' / 'Yogini').
  String dashaName(String system) => raw('dasha.${system.toLowerCase()}.name');
  String dashaDesc(String system) => raw('dasha.${system.toLowerCase()}.desc');
  String yoginiName(String english) => raw('yogini.$english');

  // ---- Matching ------------------------------------------------------------

  String kootaName(KootaResult k) => raw('match.koota.${k.id}.name');
  String kootaMeaning(KootaResult k) => raw('match.koota.${k.id}.meaning');

  /// Localized value shown for the groom or bride in a koota row.
  String kootaValue(KootaResult k, {required bool boy}) {
    final i = boy ? k.boyIndex : k.girlIndex;
    return switch (k.id) {
      'maitri' => names.planet(Planet.values[i]),
      'bhakoot' => names.rashi(Sign.values[i]),
      _ => raw('match.${k.id}.$i'),
    };
  }

  /// What a koota is and what it looks at, in some detail.
  String kootaAbout(KootaResult k) => raw('match.koota.${k.id}.about');

  /// The couple's result for one koota in plain words.
  String kootaResult(KootaResult k) {
    final level = k.score >= k.max ? 'full' : (k.score > 0 ? 'part' : 'zero');
    final s = k.score == k.score.roundToDouble() ? k.score.toStringAsFixed(0) : k.score.toStringAsFixed(1);
    return t('match.koota.${k.id}.res.$level', {'score': s});
  }

  /// How the score was reached (each person's value, the rule, the result).
  List<String> kootaWhy(KootaResult k) => [for (final r in k.why) ref(r)];

  String verdict(double total) => raw('match.verdict.${Ashtakoot.verdictId(total)}');

  // ---- Doshas --------------------------------------------------------------

  String doshaName(DoshaReport d) => raw('dosha.${d.id}.name');
  String doshaSummary(DoshaReport d) => ref(d.summaryRef);
  List<String> doshaFactors(DoshaReport d) => [for (final r in d.factorRefs) ref(r)];
  List<String> doshaMitigations(DoshaReport d) => [for (final r in d.mitigationRefs) ref(r)];
  String doshaSource(DoshaReport d) => raw('dosha.${d.id}.source');

  // ---- Yogas ---------------------------------------------------------------

  String yogaName(Yoga y) => raw('yoga.${y.id}.name');
  String yogaReason(Yoga y) => ref(y.reasonRef);
  String yogaMeaning(Yoga y) => raw('yoga.${y.id}.meaning');

  /// What the yoga is: its classical condition in plain words.
  String yogaDef(Yoga y) => raw('yoga.${y.id}.def');
  String? yogaNote(Yoga y) => y.noteRef == null ? null : ref(y.noteRef!);
  String yogaSource(Yoga y) => raw('source.${y.sourceKey}');

  // ---- Numerology ----------------------------------------------------------

  String numerologyTitle(String id) => raw('numerology.title.$id');
  String numerologyMeaning(int n) => raw('numerology.meaning.$n');
}

/// English master texts. Every other language file uses the same keys.
const engineTextsEn = <String, String>{
  'list.comma': ', ',
  'list.and': ' and ',
  'list.semicolon': '; ',

  // Ayanamsa
  'ayanamsa.lahiri.label': 'Lahiri (Chitrapaksha)',
  'ayanamsa.lahiri.desc': 'Official ayanamsa of the Indian government (Calendar Reform Committee, 1955). Used by most Indian astrologers and apps.',
  'ayanamsa.kp.label': 'KP (Krishnamurti)',
  'ayanamsa.kp.desc': 'Used in the Krishnamurti Paddhati system. About 6 arc-minutes less than Lahiri.',
  'ayanamsa.raman.label': 'B.V. Raman',
  'ayanamsa.raman.desc': 'Popularised by B.V. Raman. About 1.5° less than Lahiri.',
  'ayanamsa.trueChitra.label': 'True Chitra',
  'ayanamsa.trueChitra.desc': 'Keeps the star Spica (Chitra) exactly at 0° Libra using its true position.',
  'ayanamsa.yukteshwar.label': 'Sri Yukteshwar',
  'ayanamsa.yukteshwar.desc': 'From "The Holy Science" by Sri Yukteshwar.',
  'ayanamsa.jnBhasin.label': 'J.N. Bhasin',
  'ayanamsa.jnBhasin.desc': 'Ayanamsa used by astrologer J.N. Bhasin.',
  'ayanamsa.trueRevati.label': 'True Revati',
  'ayanamsa.trueRevati.desc': 'Places the star Revati (zeta Piscium) at the end of Pisces.',
  'ayanamsa.truePushya.label': 'True Pushya',
  'ayanamsa.truePushya.desc': 'Places delta Cancri at 16° Cancer (P.V.R. Narasimha Rao suggestion).',
  'ayanamsa.faganBradley.label': 'Fagan-Bradley',
  'ayanamsa.faganBradley.desc': 'Standard ayanamsa of Western sidereal astrology.',

  // House systems
  'house.wholeSign.label': 'Whole Sign',
  'house.wholeSign.desc': 'Each sign is one house, starting from the rising sign. The traditional method in Vedic (Parashari) astrology and Hellenistic astrology.',
  'house.placidus.label': 'Placidus',
  'house.placidus.desc':
      'The most widely used house system in modern Western astrology. Houses divide the time a degree takes to rise.',
  'house.koch.label': 'Koch',
  'house.koch.desc':
      'Popular in Germany and the US; similar to Placidus but uses the birthplace\'s horizon differently.',
  'house.equal.label': 'Equal',
  'house.equal.desc': 'Each house is exactly 30° starting from the Ascendant degree.',
  'house.porphyry.label': 'Porphyry',
  'house.porphyry.desc': 'Divides each quadrant between Ascendant and Midheaven into three equal parts.',
  'house.regiomontanus.label': 'Regiomontanus',
  'house.regiomontanus.desc': 'Medieval system dividing the celestial equator; used in horary astrology.',
  'house.campanus.label': 'Campanus',
  'house.campanus.desc': 'Divides the prime vertical into 12 equal parts.',
  'house.sripati.label': 'Sripati (Bhava Chalit)',
  'house.sripati.desc': 'Indian quadrant system: Porphyry cusps used as house middles (Bhava Chalit chart).',
  'house.placidusKp.label': 'Placidus (KP cusps)',
  'house.placidusKp.desc': 'KP system uses Placidus cusps with the KP ayanamsa.',

  // Node type
  'node.mean.label': 'Mean node',
  'node.mean.desc': 'Average position of the Moon\'s node. Used by most Vedic astrologers.',
  'node.trueNode.label': 'True node',
  'node.trueNode.desc':
      'Actual oscillating position of the Moon\'s node. Preferred by many Western and KP astrologers.',

  // Chart styles
  'chartStyle.northIndian.label': 'North Indian',
  'chartStyle.northIndian.desc':
      'Diamond chart with fixed houses; the Ascendant is always at the top. Common in North and Central India.',
  'chartStyle.southIndian.label': 'South Indian',
  'chartStyle.southIndian.desc': 'Square chart with fixed signs; Pisces is at the top-left. Common in South India.',
  'chartStyle.eastIndian.label': 'East Indian',
  'chartStyle.eastIndian.desc':
      'Square chart with fixed signs, Aries at the top centre. Common in Bengal, Odisha and Assam.',
  'chartStyle.westernWheel.label': 'Western wheel',
  'chartStyle.westernWheel.desc': 'Circular chart used in Western astrology, showing exact degrees and aspects.',

  // Themes
  'theme.cosmic.label': 'Cosmic Night',
  'theme.cosmic.desc': 'Deep night sky with gold accents.',
  'theme.devotional.label': 'Traditional',
  'theme.devotional.desc': 'Warm saffron, maroon and gold, inspired by temple art.',
  'theme.minimal.label': 'Minimal Light',
  'theme.minimal.desc': 'Clean, calm and light.',
  'theme.midnight.label': 'Pure Black',
  'theme.midnight.desc': 'True black, easy on the eyes and battery (AMOLED).',
  'theme.lotus.label': 'Lotus',
  'theme.lotus.desc': 'Soft pink and teal, gentle and modern.',

  // Notifications
  'notif.dailyHoroscope.label': 'Daily horoscope',
  'notif.dailyHoroscope.desc': 'A short reading every morning.',
  'notif.transitAlerts.label': 'Important transits',
  'notif.transitAlerts.desc': 'When a slow planet changes sign or turns retrograde for you.',
  'notif.festivals.label': 'Festivals and vrats',
  'notif.festivals.desc': 'Upcoming festivals and fasting days.',
  'notif.rahuKaal.label': 'Rahu Kaal',
  'notif.rahuKaal.desc': 'A reminder when Rahu Kaal begins for your location.',
  'notif.panchang.label': 'Daily Panchang',
  'notif.panchang.desc': 'Tithi, nakshatra and auspicious times each morning.',

  // Vargas
  'varga.d1.name': 'Rashi', 'varga.d1.sig': 'Body, overall life',
  'varga.d2.name': 'Hora', 'varga.d2.sig': 'Wealth',
  'varga.d3.name': 'Drekkana', 'varga.d3.sig': 'Siblings, courage',
  'varga.d4.name': 'Chaturthamsa', 'varga.d4.sig': 'Property, fortune, home',
  'varga.d7.name': 'Saptamsa', 'varga.d7.sig': 'Children',
  'varga.d9.name': 'Navamsa', 'varga.d9.sig': 'Spouse, dharma, inner strength',
  'varga.d10.name': 'Dasamsa', 'varga.d10.sig': 'Career, status',
  'varga.d12.name': 'Dwadasamsa', 'varga.d12.sig': 'Parents',
  'varga.d16.name': 'Shodasamsa', 'varga.d16.sig': 'Vehicles, comforts',
  'varga.d20.name': 'Vimsamsa', 'varga.d20.sig': 'Spiritual practice',
  'varga.d24.name': 'Chaturvimsamsa', 'varga.d24.sig': 'Education, learning',
  'varga.d27.name': 'Saptavimsamsa (Bhamsa)', 'varga.d27.sig': 'Strength, weakness',
  'varga.d30.name': 'Trimsamsa', 'varga.d30.sig': 'Misfortunes, character',
  'varga.d40.name': 'Khavedamsa', 'varga.d40.sig': 'Maternal legacy, auspicious effects',
  'varga.d45.name': 'Akshavedamsa', 'varga.d45.sig': 'Paternal legacy, general conduct',
  'varga.d60.name': 'Shashtiamsa', 'varga.d60.sig': 'Past karma, all matters',

  // Dashas
  'dasha.vimshottari.name': 'Vimshottari',
  'dasha.vimshottari.desc': 'The most widely used dasha system (BPHS). A 120-year cycle of nine planetary periods starting from the Moon\'s nakshatra at birth.',
  'dasha.yogini.name': 'Yogini',
  'dasha.yogini.desc':
      'A 36-year cycle of eight Yoginis, each ruled by a planet. Popular in North India for timing events.',
  'yogini.Mangala': 'Mangala', 'yogini.Pingala': 'Pingala', 'yogini.Dhanya': 'Dhanya', 'yogini.Bhramari': 'Bhramari',
  'yogini.Bhadrika': 'Bhadrika', 'yogini.Ulka': 'Ulka', 'yogini.Siddha': 'Siddha', 'yogini.Sankata': 'Sankata',

  // Matching
  'match.koota.varna.name': 'Varna', 'match.koota.varna.meaning': 'Spiritual and ego compatibility.',
  'match.koota.vashya.name': 'Vashya', 'match.koota.vashya.meaning': 'Mutual attraction and influence.',
  'match.koota.tara.name': 'Tara',
  'match.koota.tara.meaning': 'Health and well-being of the couple (birth-star harmony).',
  'match.koota.yoni.name': 'Yoni', 'match.koota.yoni.meaning': 'Physical and intimate compatibility.',
  'match.koota.maitri.name': 'Graha Maitri',
  'match.koota.maitri.meaning': 'Mental compatibility and friendship (Moon-sign lords).',
  'match.koota.gana.name': 'Gana', 'match.koota.gana.meaning': 'Temperament and nature.',
  'match.koota.bhakoot.name': 'Bhakoot', 'match.koota.bhakoot.meaning': 'Family welfare, finances and growth together.',
  'match.koota.nadi.name': 'Nadi', 'match.koota.nadi.meaning': 'Health and genetic compatibility, progeny.',
  'match.varna.0': 'Brahmin', 'match.varna.1': 'Kshatriya', 'match.varna.2': 'Vaishya', 'match.varna.3': 'Shudra',
  'match.vashya.0': 'Chatushpada',
  'match.vashya.1': 'Manava',
  'match.vashya.2': 'Jalachara',
  'match.vashya.3': 'Vanachara',
  'match.vashya.4': 'Keeta',
  'match.tara.0': 'Janma',
  'match.tara.1': 'Sampat',
  'match.tara.2': 'Vipat',
  'match.tara.3': 'Kshema',
  'match.tara.4': 'Pratyari',
  'match.tara.5': 'Sadhaka', 'match.tara.6': 'Naidhana', 'match.tara.7': 'Mitra', 'match.tara.8': 'Parama Mitra',
  'match.yoni.0': 'Horse',
  'match.yoni.1': 'Elephant',
  'match.yoni.2': 'Sheep',
  'match.yoni.3': 'Serpent',
  'match.yoni.4': 'Dog',
  'match.yoni.5': 'Cat',
  'match.yoni.6': 'Rat',
  'match.yoni.7': 'Cow',
  'match.yoni.8': 'Buffalo',
  'match.yoni.9': 'Tiger',
  'match.yoni.10': 'Deer', 'match.yoni.11': 'Monkey', 'match.yoni.12': 'Mongoose', 'match.yoni.13': 'Lion',
  'match.gana.0': 'Deva', 'match.gana.1': 'Manushya', 'match.gana.2': 'Rakshasa',
  'match.nadi.0': 'Adi (Vata)', 'match.nadi.1': 'Madhya (Pitta)', 'match.nadi.2': 'Antya (Kapha)',
  'match.verdict.below': 'Below the traditional minimum of 18',
  'match.verdict.average': 'Average match',
  'match.verdict.good': 'Good match',
  'match.verdict.excellent': 'Excellent match',
  'match.note.bhakootSameLord':
      'Bhakoot dosha is traditionally cancelled because both Moon signs have the same lord ({planet}).',
  'match.note.bhakootFriends':
      'Bhakoot dosha is traditionally considered cancelled because the Moon-sign lords are mutual friends.',
  'match.note.nadiSameSign': 'Nadi dosha is traditionally cancelled: same Moon sign but different nakshatras.',
  'match.note.nadiDiffPada': 'Nadi dosha is traditionally cancelled: same nakshatra but different padas.',
  'match.note.nadiDiffSign': 'Nadi dosha is traditionally cancelled: same nakshatra but different Moon signs.',
  // Composite chart reading (Robert Hand's method), plain words first.
  'comp.tone.good':
      'By the composite method, this relationship looks mostly supportive: its parts work together more than they '
      'pull apart.',
  'comp.tone.mixed':
      'By the composite method, this relationship is mixed: some parts flow easily and some ask for effort from '
      'both of you.',
  'comp.tone.hard':
      'By the composite method, this relationship asks for work: more of its parts pull in different directions '
      'than flow together. It can still be strong with patience and honest talk.',
  'comp.sun.fire': 'Its main purpose is shared action: goals, adventure and doing things together.',
  'comp.sun.earth': 'Its main purpose is building something practical and lasting together: home, work and security.',
  'comp.sun.air': 'Its main purpose is ideas and connection: talking, learning and a shared social life.',
  'comp.sun.water': 'Its main purpose is emotional closeness: care, trust and looking after each other.',
  'comp.moon.fire': 'Emotionally it feels lively and spontaneous, with quick ups and downs.',
  'comp.moon.earth': 'Emotionally it feels steady and practical; care is shown through actions.',
  'comp.moon.air': 'Emotionally it is light and talkative; feelings are worked through by talking.',
  'comp.moon.water': 'Emotionally it runs deep and sensitive; moods are felt strongly by both of you.',
  'comp.asp.sunMoon.good': 'You are naturally in step: what the relationship wants and how it feels agree.',
  'comp.asp.sunMoon.hard':
      'What the relationship wants and how it feels can pull apart; both of you need to say what you need.',
  'comp.asp.venusMars.good': 'Attraction and affection flow easily together.',
  'comp.asp.venusMars.hard': 'Strong attraction that can turn into friction; give each other space.',
  'comp.asp.venusMars.mixed': 'Intense attraction and passion, which can also bring quick sparks of conflict.',
  'comp.asp.moonVenus.good': 'Warmth and affection come naturally; the bond feels comforting.',
  'comp.asp.moonVenus.hard': 'Your ways of showing love and care differ; small gestures and patience help.',
  'comp.asp.sunVenus.good': 'Fondness and enjoying each other are at the centre of the bond.',
  'comp.asp.sunVenus.hard': 'The affection is real, but expectations may differ; say what you value.',
  'comp.asp.mercuryMoon.good': 'Talking about feelings comes easily.',
  'comp.asp.mercuryMoon.hard': 'Feelings and words can get crossed; listen before replying.',
  'comp.asp.saturn.good': 'Commitment and loyalty give the bond stability over time.',
  'comp.asp.saturn.hard': 'Duty or seriousness can weigh on the bond; make room for lightness and fun.',
  'comp.asp.jupiter.good': 'Generosity, optimism and growing together are strong themes.',
  'comp.asp.jupiter.hard': 'Big hopes may run ahead of reality; keep expectations shared and realistic.',
  'comp.caveat':
      'The composite chart is a modern Western technique (Robert Hand, Planets in Composite, 1975). It reads the '
      'relationship as its own "third person". It is not a prediction; how two people treat each other matters '
      'most.',
  'comp.why.method':
      'How it is made: each planet is placed at the nearer midpoint between the two people\'s positions, and the '
      'houses at the midpoints of the two people\'s house cusps.',
  'comp.why.sun': 'Composite Sun in {sign}, a {element} sign: this gives the purpose line.',
  'comp.why.moon': 'Composite Moon in {sign}, a {element} sign: this gives the feelings line.',
  'comp.why.count':
      'Supportive aspects (trine, sextile, conjunctions except with Saturn or Mars): {good}. Challenging aspects '
      '(square, opposition, conjunctions with Saturn): {hard}. The verdict is supportive when supportive aspects '
      'lead by 2 or more, needs work when challenging ones lead by 2 or more, and mixed otherwise.',
  'comp.element.fire': 'fire',
  'comp.element.earth': 'earth',
  'comp.element.air': 'air',
  'comp.element.water': 'water',
  'match.note.ganaLords':
      'Gana dosha is traditionally considered reduced because the Moon-sign lords are the same or mutual friends.',
  // One koota in depth: what it is, the couple's result, the dosha it forms.
  'match.koota.varna.about':
      'Varna is the first and smallest koota (1 of the 36 points). It sorts the twelve Moon signs into four '
      'traditional groups by element: water signs are Brahmin, fire signs Kshatriya, earth signs Vaishya and air '
      'signs Shudra. In this method these are labels for outlook and way of working, not a person\'s caste or '
      'family. It looks at whether the two outlooks sit easily together.',
  'match.koota.vashya.about':
      'Vashya (2 points) looks at mutual attraction and influence: how naturally the two of you are drawn to each '
      'other and can influence each other. Each Moon sign belongs to one of five groups: Chatushpada (four-footed), '
      'Manava (human), Jalachara (water), Vanachara (wild) and Keeta (insect). Sagittarius and Capricorn change '
      'group at 15°. A classical table gives the points for each pair of groups.',
  'match.koota.tara.about':
      'Tara (3 points), also called Dina koota, compares the two birth stars (Moon nakshatras). Counting from one '
      'nakshatra to the other gives a number that falls on one of nine taras: Janma, Sampat, Vipat, Kshema, '
      'Pratyari, Sadhaka, Naidhana, Mitra and Parama Mitra. Tradition reads it as the couple\'s well-being and how '
      'each supports the other\'s fortune. It is counted both ways, 1.5 points each way.',
  'match.koota.yoni.about':
      'Yoni (4 points) looks at physical and intimate compatibility and instinctive comfort with each other. Each '
      'of the 27 nakshatras is linked with one of 14 animals. The pair of animals is scored from 4 (the same '
      'animal) down to 0 (animals traditionally seen as sworn enemies).',
  'match.koota.maitri.about':
      'Graha Maitri (5 points) looks at mental compatibility and friendship: how well your minds and ways of '
      'thinking get along. It compares the lords of the two Moon signs and their classical natural friendship '
      '(Parashara): friend, neutral or enemy, seen from each side.',
  'match.koota.gana.about':
      'Gana (6 points) looks at temperament. Each nakshatra belongs to one of three ganas: Deva (gentle and '
      'giving), Manushya (balanced and worldly) or Rakshasa (strong-willed and independent). Rakshasa does not mean '
      'bad; it describes intensity. Similar temperaments score higher.',
  'match.koota.bhakoot.about':
      'Bhakoot (7 points), also called Rashi koota, looks at family welfare, finances and growth together. It '
      'counts how far apart the two Moon signs are. Three positions, 2/12, 6/8 and 5/9, score 0 and are called '
      'Bhakoot dosha; every other position scores the full 7.',
  'match.koota.nadi.about':
      'Nadi (8 points) carries the most weight of all. It links each nakshatra with one of three nadis, Adi (Vata), '
      'Madhya (Pitta) and Antya (Kapha), named after the three constitutions of Ayurveda. Tradition reads it for '
      'health and children. Different nadis score 8; the same nadi scores 0 and is called Nadi dosha.',
  'match.koota.varna.res.full': 'Your outlooks fit together by this rule: 1 of 1.',
  'match.koota.varna.res.zero':
      'This rule gives 0 of 1. It is the smallest part of the match, and tradition gives it little weight on its '
      'own.',
  'match.koota.vashya.res.full': 'Strong natural attraction and influence by tradition: 2 of 2.',
  'match.koota.vashya.res.part':
      'Some natural attraction, with one side traditionally having more influence: {score} of 2.',
  'match.koota.vashya.res.zero':
      'Tradition sees little natural pull between these groups: 0 of 2. Attraction can grow through shared '
      'interests and time together.',
  'match.koota.tara.res.full': 'Both birth stars support each other: 3 of 3.',
  'match.koota.tara.res.part': 'One direction is favourable and the other is not: {score} of 3.',
  'match.koota.tara.res.zero':
      'Both counts fall on unfavourable taras: 0 of 3. Tradition advises looking after each other\'s health and '
      'well-being.',
  'match.koota.yoni.res.full': 'The same yoni: the strongest physical and instinctive match by tradition, 4 of 4.',
  'match.koota.yoni.res.part': 'Physical and instinctive comfort partly matches: {score} of 4.',
  'match.koota.yoni.res.zero':
      'The two yonis are traditional sworn enemies: 0 of 4. Tradition reads this as a need for patience and care '
      'in intimacy.',
  'match.koota.maitri.res.full': 'Your minds get along well by tradition: 5 of 5.',
  'match.koota.maitri.res.part': 'Your ways of thinking partly agree: {score} of 5.',
  'match.koota.maitri.res.zero':
      'The Moon-sign lords are natural enemies: 0 of 5. Tradition reads this as different ways of thinking that '
      'need conscious understanding.',
  'match.koota.gana.res.full': 'Similar temperaments: 6 of 6.',
  'match.koota.gana.res.part': 'Your temperaments partly match: {score} of 6.',
  'match.koota.gana.res.zero': 'Very different temperaments: 0 of 6. Tradition calls this Gana dosha.',
  'match.koota.bhakoot.res.full': 'Your Moon signs sit well with each other: 7 of 7.',
  'match.koota.bhakoot.res.zero':
      'Your Moon signs are in a dosha position: 0 of 7. Tradition calls this Bhakoot dosha.',
  'match.koota.nadi.res.full': 'Different nadis: the full 8 of 8, in the most important part of the match.',
  'match.koota.nadi.res.zero':
      'The same nadi: 0 of 8. Tradition calls this Nadi dosha, the most weighted dosha in matching.',
  'match.dosha.nadi.name': 'Nadi dosha',
  'match.dosha.bhakoot.name': 'Bhakoot dosha',
  'match.dosha.gana.name': 'Gana dosha',
  'match.dosha.yoni.name': 'Yoni dosha',
  'match.dosha.nadi':
      'Tradition reads Nadi dosha as a concern for the couple\'s health and for children. It is a traditional rule, '
      'not a medical finding; for real health questions, a doctor\'s advice and medical tests matter far more.',
  'match.dosha.bhakoot':
      'Tradition reads Bhakoot dosha as strain on family welfare and growing together. Open talks about money and '
      'family plans help in any marriage.',
  'match.dosha.gana':
      'Tradition reads Gana dosha as a clash of temperaments, one more intense and one gentler. Respecting each '
      'other\'s nature is the traditional advice.',
  'match.dosha.yoni':
      'Some almanacs call this Yoni dosha and read it as different physical and emotional needs. Patience and open '
      'communication are the usual advice.',
  'match.dosha.cancelled':
      'A classical exception applies to your charts, so tradition treats this dosha as cancelled or much reduced, '
      'even though the points stay at 0.',
  'match.dosha.counted':
      'None of the classical exceptions applies to your charts, so tradition counts this dosha. The whole charts, '
      'and the two of you as people, matter more than one rule.',
  'match.bhakoot.pair.2': '2/12: tradition links this position with money matters and family expenses.',
  'match.bhakoot.pair.5': '5/9: tradition links this position with children and differences in outlook.',
  'match.bhakoot.pair.6': '6/8: tradition links this position with disagreements and strain on health.',
  'match.why.result': 'Result from the classical table: {score} of {max}.',
  'match.why.nak.of': '{groom?Groom|Bride}: Moon in {nak} nakshatra → {value}.',
  'match.why.varna.of': '{groom?Groom|Bride}: Moon in {sign} → {value} varna.',
  'match.why.varna.rule':
      'Rule: 1 point when the groom\'s varna is the same as or above the bride\'s, in the order Brahmin, Kshatriya, '
      'Vaishya, Shudra; otherwise 0.',
  'match.why.varna.result':
      '{ok?The groom\'s varna is the same or above, so 1 of 1.|The groom\'s varna is below the bride\'s, so 0 of 1.}',
  'match.why.vashya.of': '{groom?Groom|Bride}: Moon in {sign} at {deg} → {value} group.',
  'match.why.vashya.rule':
      'Rule: the classical Vashya table gives 2 for the same group, 1 or 0.5 when one group is traditionally under '
      'the other\'s influence, and 0 when the groups are unrelated.',
  'match.why.tara.count':
      'Counting from {from} to {to} (both included) gives {n}. In groups of nine this is tara {t}, {value}: '
      '{good?a favourable tara.|one of the three unfavourable taras (Vipat, Pratyari, Naidhana).}',
  'match.why.tara.rule': 'Rule: each favourable direction gives 1.5 points.',
  'match.why.yoni.result': 'The classical Yoni table gives this pair {score} of 4: {rel}.',
  'match.yoni.rel.4': 'the same animal',
  'match.yoni.rel.3': 'friendly animals',
  'match.yoni.rel.2': 'neutral animals',
  'match.yoni.rel.1': 'unfriendly animals',
  'match.yoni.rel.0': 'sworn enemies',
  'match.why.maitri.of': '{groom?Groom|Bride}: Moon sign {sign}, ruled by {planet}.',
  'match.why.maitri.same': 'Both Moon signs are ruled by {planet}, the best case.',
  'match.why.maitri.rel':
      'By the natural friendships (Parashara), {a} regards {b} as {rel}, and {b} regards {a} as {rel2}.',
  'match.rel.friend': 'a friend',
  'match.rel.neutral': 'neutral',
  'match.rel.enemy': 'an enemy',
  'match.why.gana.rule':
      'Rule (classical Gana table): the same gana gives 6; Deva with Manushya 5 or 6; Deva with Rakshasa 0 or 1; '
      'Manushya with Rakshasa 0.',
  'match.why.bhakoot.count':
      'Counting from the groom\'s Moon sign {a} to the bride\'s {b} gives {n}; from the bride\'s to the groom\'s '
      'gives {m} (both signs included).',
  'match.why.bhakoot.rule': 'Rule: the positions 2/12, 6/8 and 5/9 score 0 (Bhakoot dosha); all others score 7.',
  'match.why.bhakoot.bad': 'This is a {n}/{m} position, so 0 of 7. {pair}',
  'match.why.bhakoot.ok': 'This is a {n}/{m} position, not one of the dosha positions, so 7 of 7.',
  'match.why.nadi.rule':
      'Rule: from Ashwini onwards the nakshatras follow the repeating order Adi, Madhya, Antya, Antya, Madhya, Adi. '
      'Different nadis give 8, the same nadi 0.',
  'match.why.nadi.result':
      '{same?Both have the same nadi, so 0 of 8 (Nadi dosha).|The nadis are different, so 8 of 8.}',
  'match.exc.lordsFriendly': 'The two Moon-sign lords are the same planet or mutual friends.',
  'match.exc.sameLord': 'Both Moon signs have the same lord.',
  'match.exc.lordsMutualFriends': 'The two Moon-sign lords are mutual friends.',
  'match.exc.nadiSameSign': 'Same Moon sign but different nakshatras.',
  'match.exc.nadiDiffPada': 'Same nakshatra but different padas.',
  'match.exc.nadiDiffSign': 'Same nakshatra but different Moon signs.',
  'match.source':
      'Rules as given in Muhurta Chintamani (Vivaha Prakarana) and used in North Indian almanacs. Point tables '
      'differ slightly between almanacs.',

  // Match: overall advice (Vedic)
  'advice.v.ok':
      'According to this calculation the result is: {verdict}, {total} of 36, above the traditional minimum of '
      '18, with no counted Nadi or Bhakoot dosha. By the traditional rules this match is approved.',
  'advice.v.dosha':
      'The total of {total} of 36 is above the traditional minimum of 18, but {doshas|and} is counted: no '
      'classical exception applies. Many astrologers treat this as serious and would not approve the match on '
      'the points alone without studying both full charts.',
  'advice.v.weak':
      'According to this calculation this match is below the traditional minimum: {total} of 36, under 18. By '
      'the strict rule tradition does not recommend it. Many astrologers still study both full charts before '
      'deciding.',
  'advice.s.nadi': 'Health and family plans: the most weighted part of the match is fully in your favour.',
  'advice.s.bhakoot': 'Family life, money and growing together go well by tradition.',
  'advice.s.gana': 'Your temperaments are alike, which makes daily life together easier.',
  'advice.s.maitri': 'Your minds and ways of thinking get along well.',
  'advice.s.yoni': 'Strong physical and instinctive comfort with each other.',
  'advice.s.tara': 'Your birth stars support each other\'s well-being.',
  'advice.s.vashya': 'A strong natural attraction and influence between you.',
  'advice.s.varna': 'Your outlooks and ways of working fit together.',
  'advice.s.manglikBoth': 'Both of you have Manglik dosha, which tradition treats as balancing each other.',
  'advice.c.nadi':
      'Nadi dosha (health and children): {cancelled?a classical exception applies, so tradition treats it as '
      'reduced.|counted, and tradition treats it as the most serious dosha in matching.}',
  'advice.c.bhakoot':
      'Bhakoot dosha (family welfare and money): {cancelled?a classical exception applies, so tradition treats '
      'it as cancelled.|counted, so tradition expects strain on family matters and finances.}',
  'advice.c.gana':
      'Gana dosha (temperament): {cancelled?reduced by a classical exception, but|counted:} one of you is more '
      'intense and the other gentler, which can lead to clashes.',
  'advice.c.maitri': 'Your ways of thinking differ, so understanding each other takes conscious effort.',
  'advice.c.yoni': 'Physical and emotional needs differ; tradition advises patience and care in intimacy.',
  'advice.c.tara': 'Your birth stars do not support each other; tradition advises looking after each other\'s health.',
  'advice.c.vashya': 'Little natural pull between you by tradition; attraction grows through time together.',
  'advice.c.varna': 'Your outlooks differ by this rule; tradition gives it little weight on its own.',
  'advice.c.manglik': 'Only one of you has Manglik dosha. Tradition links this imbalance with friction in marriage.',
  'advice.step.talk':
      'Talk openly before deciding: expectations, money, where you will live, family roles and children.',
  'advice.step.health':
      'Get a pre-marriage health check together, including blood tests such as thalassemia screening. Tradition '
      'reads Nadi as health; medical tests give real answers.',
  'advice.step.money': 'Agree early on how you will handle money, savings and family expenses.',
  'advice.step.understand': 'Learn how the other thinks and reacts; agree how you will handle disagreements calmly.',
  'advice.step.patience': 'Build closeness slowly, with patience and honest talk about each other\'s needs.',
  'advice.step.care': 'Support each other\'s health and routines; regular check-ups help any couple.',
  'advice.step.manglik':
      'Many astrologers check Manglik dosha from the Ascendant only and weigh many cancelling factors; ask about '
      'the full charts before giving it too much weight.',
  'advice.step.fullChart':
      'These points come only from the two Moon positions. Your full charts, and above all who you are as people, '
      'matter more than any score.',
  'advice.rem.nadi':
      'Nadi dosha: commonly suggested are chanting the Mahamrityunjaya mantra, a Nadi dosha shanti puja, and '
      'charity (daan) of grain or clothes to those in need.',
  'advice.rem.bhakoot':
      'Bhakoot dosha: commonly suggested are prayers to the lords of both Moon signs ({a} and {b}) and charity '
      'on their weekdays.',
  'advice.rem.manglik':
      'Manglik imbalance: commonly suggested are a Mangal shanti puja, Hanuman worship on Tuesdays, and for '
      'strong cases a symbolic Kumbh vivah, which some families choose.',
  'advice.rem.note':
      'Remedies are optional traditional practices. Nothing needs to be bought from anyone: a puja can be done '
      'at home or at any temple you choose.',
  'advice.why.koota': '{koota}: {score} of {max}.',
  'advice.why.exception': 'Exception checked: {rule} {applies?Applies.|Does not apply.}',
  'advice.why.manglik': '{groom?Groom|Bride}: Manglik dosha {present?present|not present}.',

  // Match: overall advice (Western synastry)
  'advice.w.good':
      'According to this synastry the relationship is mostly supportive: {good} supportive aspects against {hard} '
      'challenging ones between your personal planets.',
  'advice.w.mixed':
      'According to this synastry the relationship is mixed: {good} supportive and {hard} challenging aspects '
      'between your personal planets. It works with effort from both sides.',
  'advice.w.hard':
      'According to this synastry the relationship needs work: {hard} challenging aspects against {good} '
      'supportive ones between your personal planets.',
  'advice.w.good.sunMoon': 'You understand each other naturally; who one is suits what the other needs.',
  'advice.w.good.venusMars': 'Attraction and affection flow easily between you.',
  'advice.w.good.saturn': 'Steady commitment: you bring each other stability and loyalty.',
  'advice.w.good.moon': 'Emotional comfort: you feel at home with each other.',
  'advice.w.good.venus': 'Affection, shared tastes and enjoyment of each other\'s company.',
  'advice.w.good.mercury': 'Easy communication: you talk and plan well together.',
  'advice.w.good.mars': 'You energise each other and work well as a team.',
  'advice.w.good.sun': 'You support each other\'s goals and confidence.',
  'advice.w.good.jupiter': 'You help each other grow, with optimism and generosity.',
  'advice.w.hard.sunMoon': 'What one wants and what the other needs can pull apart; it takes understanding.',
  'advice.w.hard.venusMars': 'Strong attraction that can turn into friction or jealousy.',
  'advice.w.hard.saturn': 'Duty and pressure: one can feel restricted or judged by the other.',
  'advice.w.hard.moon': 'Different emotional needs and moods can cause hurt.',
  'advice.w.hard.venus': 'Different ideas of love and value can cause disappointment.',
  'advice.w.hard.mercury': 'Misunderstandings happen easily; you think and speak differently.',
  'advice.w.hard.mars': 'Tempers can clash; arguments flare quickly.',
  'advice.w.hard.sun': 'Strong wills that can compete for the lead.',
  'advice.w.hard.jupiter': 'Different beliefs or expectations can cause excess or disagreement.',
  'advice.step.w.feelings': 'Make room for each other\'s feelings; ask before assuming.',
  'advice.step.w.talk': 'Slow down in important talks; repeat back what you heard.',
  'advice.step.w.anger': 'Agree on a way to pause arguments before they escalate.',
  'advice.step.w.duty': 'Share responsibilities fairly and say when one feels pressured.',
  'advice.step.w.fullChart':
      'These points come only from aspects between your planets. Your full charts, and above all who you are as '
      'people, matter more.',
  'advice.w.why': '{a}\'s {pa} {aspect} {b}\'s {pb} (orb {orb}°).',
  'advice.w.aspect.conjunction': 'conjunct',
  'advice.w.aspect.sextile': 'sextile',
  'advice.w.aspect.square': 'square',
  'advice.w.aspect.trine': 'trine',
  'advice.w.aspect.opposition': 'opposite',

  // Children (Santana)
  'children.tone.1': 'According to this calculation, the chart\'s signs for children are supportive.',
  'children.tone.0':
      'According to this calculation, the chart\'s signs for children are mixed: some support, and some '
      'signs of delay or effort.',
  'children.tone.-1':
      'According to this calculation, the chart shows several classical signs of delay or difficulty with '
      'children. Tradition reads this as a need for patience and care, not as a final answer.',
  'children.couple.1': 'According to this calculation, the signs for children are supportive for you as a couple.',
  'children.couple.0':
      'According to this calculation, the signs for children are mixed for you as a couple: some support, and '
      'some signs of delay or effort.',
  'children.couple.-1':
      'According to this calculation, several classical signs point to delay or difficulty with children for you '
      'as a couple. Tradition reads this as a need for patience and care, not as a final answer.',
  'children.beeja.1': 'Father\'s traditional fertility indicator (Beeja Sphuta): strong.',
  'children.beeja.0':
      'Father\'s traditional fertility indicator (Beeja Sphuta): mixed; tradition reads this as possible delay.',
  'children.beeja.-1': 'Father\'s traditional fertility indicator (Beeja Sphuta): weak.',
  'children.kshetra.1': 'Mother\'s traditional fertility indicator (Kshetra Sphuta): strong.',
  'children.kshetra.0':
      'Mother\'s traditional fertility indicator (Kshetra Sphuta): mixed; tradition reads this as possible delay.',
  'children.kshetra.-1': 'Mother\'s traditional fertility indicator (Kshetra Sphuta): weak.',
  'children.nadi': 'Your Moon nakshatras share the same nadi (Nadi dosha), which tradition links with children.',
  'children.noWindows': 'The method marks no period for children in the next 12 years.',
  'children.health':
      'This is a traditional reading of the chart, not a medical assessment. Having children depends on health; '
      'a doctor can check what really matters, and treatment helps many couples.',
  'children.f.lordGood': 'The 5th lord {planet} is in house {house}, a kendra or trikona: supportive.',
  'children.f.lordDusthana':
      'The 5th lord {planet} is in house {house}, a dusthana (6, 8 or 12): a classical sign of delay.',
  'children.f.lordOther': 'The 5th lord {planet} is in house {house}: neither strong nor weak.',
  'children.f.lordExalted': 'The 5th lord {planet} is exalted in {sign}: strong.',
  'children.f.lordDebilitated': 'The 5th lord {planet} is debilitated in {sign}: weak.',
  'children.f.jupGood': 'Jupiter, the significator of children, is in house {house}, a kendra or trikona.',
  'children.f.jupDusthana': 'Jupiter, the significator of children, is in house {house}, a dusthana.',
  'children.f.jupStrong': 'Jupiter is strong in {sign} (own or exaltation sign).',
  'children.f.jupDebilitated': 'Jupiter is debilitated in {sign}.',
  'children.f.jupCombust': 'Jupiter is combust: only {deg}° from the Sun.',
  'children.f.beneficIn': '{planets|and} in the 5th house: benefic support.',
  'children.f.jupAspect': 'Jupiter aspects the 5th house: a classical protection.',
  'children.f.maleficIn': '{planets|and} in the 5th house with no benefic help: a classical sign of delay.',
  'children.f.maleficHelped': '{planets|and} in the 5th house, eased by benefic influence.',
  'children.f.d7JupStrong': 'In the Saptamsha (D7, the chart for children), Jupiter is strong in {sign}.',
  'children.f.d7JupWeak': 'In the Saptamsha (D7, the chart for children), Jupiter is debilitated in {sign}.',
  'children.why.fifth': 'Counted from the {moon?Moon sign|Ascendant}, the 5th house is {sign}, ruled by {planet}.',
  'children.why.window': '{md} Mahadasha, {ad} Antardasha: {role}.',
  'children.why.windowMd': 'The Mahadasha lord {planet} is also a significator: {role}.',
  'children.role.lord': '{planet} rules the 5th house',
  'children.role.jupiter': 'Jupiter is the significator of children',
  'children.role.in5': '{planet} is in the 5th house',
  'children.why.part': '{planet}: {deg} in {sign}.',
  'children.why.sum': 'Sum: {deg} in {sign}, navamsa {nav}.',
  'children.why.beeja.rule':
      'Rule (Phaladeepika ch. 12): Beeja Sphuta is the Sun, Venus and Jupiter added together. An odd sign and odd '
      'navamsa is strong; one odd and one even is mixed (possible delay); both even is weak.',
  'children.why.kshetra.rule':
      'Rule (Phaladeepika ch. 12): Kshetra Sphuta is the Moon, Mars and Jupiter added together. An even sign and '
      'even navamsa is strong; one even and one odd is mixed (possible delay); both odd is weak.',
  'children.why.nadi': 'Both Moon nakshatras have the same nadi and no classical exception applies.',
  'children.source':
      'BPHS (Putra Bhava) and Phaladeepika ch. 12 for the 5th house, Jupiter and the sphutas; BPHS ch. 6-7 for '
      'the Saptamsha; Vimshottari dasha for timing.',
  'children.trad.intro':
      'Classical texts such as Brihat Parashara Hora Shastra and Phaladeepika contain rules about whether '
      'children would be sons or daughters. This page explains what those rules say, as history. Drishti does '
      'not apply them to anyone\'s chart or pregnancy.',
  'children.trad.rules':
      'The texts class planets as male (Sun, Mars, Jupiter), female (Moon, Venus) or neutral (Mercury, Saturn), '
      'and signs as male (odd) or female (even). They read the 5th house, its lord, Jupiter and the Saptamsha '
      '(D7) with these labels, and link a Beeja Sphuta in an odd sign and navamsa with sons.',
  'children.trad.science':
      'Science: a baby\'s sex is fixed at conception by whether the father\'s sperm carries an X or a Y '
      'chromosome, close to an even chance (about 105 boys are born for every 100 girls). No study has shown that '
      'a birth chart can predict it.',
  'children.trad.law':
      'In India the PCPNDT Act, 1994 forbids revealing the sex of an unborn baby and forbids advertising any way '
      'of finding it out. Sex selection is a crime.',
  'children.trad.equal':
      'In Drishti, daughters and sons are equal blessings. Every reading here is about children, never about '
      'which sex they will be.',

  // Doshas
  'dosha.manglik.name': 'Mangal (Manglik) Dosha',
  'dosha.manglik.none': 'Mars is not in houses 1, 2, 4, 7, 8 or 12 from the Ascendant, Moon or Venus.',
  'dosha.manglik.present': 'Traditional texts link Mars in these houses with friction in marriage. Many astrologers consider it only from the Ascendant, and most consider it neutralised when both partners have it.',
  'dosha.manglik.fromLagna': 'Mars is in house {house} from the Ascendant.',
  'dosha.manglik.fromMoon': 'Mars is in house {house} from the Moon.',
  'dosha.manglik.fromVenus': 'Mars is in house {house} from Venus.',
  'dosha.manglik.ownSign': 'Mars is in its own sign ({sign}).',
  'dosha.manglik.exalted': 'Mars is exalted (Makara).',
  'dosha.manglik.jupiter': 'Jupiter is conjunct Mars.',
  'dosha.manglik.source': 'Commonly cited from Brihat Parashara Hora Shastra and later South Indian texts; the 2nd house is included in some traditions only.',
  'dosha.kaalSarp.name': 'Kaal Sarp Dosha',
  'dosha.kaalSarp.present': 'All seven planets lie on one side of the Rahu-Ketu axis.',
  'dosha.kaalSarp.absent': 'The planets are spread on both sides of the Rahu-Ketu axis.',
  'dosha.kaalSarp.source': 'Kaal Sarp is a later (20th century) concept not found in classical texts such as BPHS; many traditional astrologers do not use it.',

  // Yogas: names and meanings
  'yoga.gajakesari.name': 'Gajakesari Yoga',
  'yoga.gajakesari.meaning': 'Traditionally linked with good reputation, wisdom and the ability to overcome opponents. Its effect depends on the strength of Jupiter and the Moon.',
  'yoga.budhaditya.name': 'Budhaditya Yoga',
  'yoga.budhaditya.meaning': 'Associated with intelligence, communication skills and learning. It is very common because Mercury is always close to the Sun.',
  'yoga.chandraMangala.name': 'Chandra-Mangala Yoga',
  'yoga.chandraMangala.meaning':
      'Associated with drive, enterprise and earning through one\'s own effort; can also indicate a quick temper.',
  'yoga.kemadruma.name': 'Kemadruma Yoga',
  'yoga.kemadruma.meaning': 'Traditionally associated with periods of feeling unsupported. Classical texts list several cancellations, and it is considered weak when cancelled.',
  'yoga.adhi.name': 'Adhi Yoga',
  'yoga.adhi.meaning': 'Associated with leadership, comfort and the support of others.',
  'yoga.ruchaka.name': 'Ruchaka Yoga (Pancha Mahapurusha)',
  'yoga.ruchaka.meaning': 'Associated with courage, physical strength and leadership.',
  'yoga.bhadra.name': 'Bhadra Yoga (Pancha Mahapurusha)',
  'yoga.bhadra.meaning': 'Associated with intellect, eloquence and skill in trade or learning.',
  'yoga.hamsa.name': 'Hamsa Yoga (Pancha Mahapurusha)',
  'yoga.hamsa.meaning': 'Associated with wisdom, righteousness and respect from others.',
  'yoga.malavya.name': 'Malavya Yoga (Pancha Mahapurusha)',
  'yoga.malavya.meaning': 'Associated with refinement, comforts and artistic taste.',
  'yoga.shasha.name': 'Shasha Yoga (Pancha Mahapurusha)',
  'yoga.shasha.meaning': 'Associated with discipline, perseverance and authority over groups.',
  'yoga.raja.name': 'Raja Yoga',
  'yoga.raja.meaning':
      'Associated with status, authority and success, especially during the dashas of the planets involved.',
  'yoga.dhana.name': 'Dhana Yoga',
  'yoga.dhana.meaning': 'Associated with accumulation of wealth, especially during the dashas of the planets involved.',
  'yoga.yogakaraka.name': 'Yogakaraka',
  'yoga.yogakaraka.meaning': 'Such a planet is considered especially beneficial for this Ascendant.',
  'yoga.neechaBhanga.name': 'Neecha Bhanga Raja Yoga',
  'yoga.neechaBhanga.meaning': 'The weakness of a debilitated planet is traditionally considered cancelled, and it may even give rise after early struggles.',
  'yoga.harsha.name': 'Viparita Raja Yoga (Harsha)',
  'yoga.harsha.meaning':
      'Associated with gains or rise that come through difficulties, or through the setbacks of opponents.',
  'yoga.sarala.name': 'Viparita Raja Yoga (Sarala)',
  'yoga.sarala.meaning':
      'Associated with gains or rise that come through difficulties, or through the setbacks of opponents.',
  'yoga.vimala.name': 'Viparita Raja Yoga (Vimala)',
  'yoga.vimala.meaning':
      'Associated with gains or rise that come through difficulties, or through the setbacks of opponents.',
  'yoga.saraswati.name': 'Saraswati Yoga',
  'yoga.saraswati.meaning': 'Associated with learning, eloquence and artistic or literary talent.',
  'yoga.lakshmi.name': 'Lakshmi Yoga',
  'yoga.lakshmi.meaning': 'Associated with prosperity, good fortune and a generous nature.',

  // Yogas: reasons and notes
  'yoga.gajakesari.reason': 'Jupiter is in house {house} from the Moon (a kendra).',
  'yoga.budhaditya.reason': 'The Sun and Mercury are in the same sign.',
  'yoga.chandraMangala.reason': 'The Moon and Mars are in the same sign.',
  'yoga.kemadruma.reason': 'No planet other than the Sun or the nodes is in the 2nd or 12th from the Moon.',
  'yoga.kemadruma.cancelled':
      'Considered cancelled: {planets|and} with the Moon or in a kendra from the Ascendant or Moon.',
  'yoga.adhi.reason': '{planets} are in the 6th, 7th or 8th from the Moon.',
  'yoga.adhi.full': 'Fully formed (all three benefics).',
  'yoga.adhi.partial': 'Partially formed (two of three benefics).',
  'yoga.mahapurusha.reason': '{planet} is {exalted?exalted|in its own sign} ({sign}) in house {house}, a kendra.',
  'yoga.pair.together': '{a} (lord of {aHouses}) and {b} (lord of {bHouses}) are together in {sign}.',
  'yoga.pair.exchange': '{a} (lord of {aHouses}) and {b} (lord of {bHouses}) exchange signs (parivartana).',
  'yoga.yogakaraka.reason': '{planet} rules houses {houses|and} (a kendra and a trikona).',
  'yoga.neecha.reason': '{planet} is debilitated in {sign}, and {parts}.',
  'yoga.neecha.debLord': '{planet}, lord of the debilitation sign, is in a kendra from the Ascendant or Moon',
  'yoga.neecha.exLord': '{planet}, lord of its exaltation sign, is in a kendra from the Ascendant or Moon',
  'yoga.neecha.exaltedHere': '{planet}, which is exalted in {sign}, is in a kendra from the Ascendant or Moon',
  'yoga.viparita.reason': '{planet}, lord of house {house}, is in house {at}.',
  'yoga.saraswati.reason': 'Jupiter, Venus and Mercury are in kendras, trikonas or the 2nd house (houses {houses}), and Jupiter is in its own, exalted or a friend\'s sign.',
  'yoga.lakshmi.reason': '{planet}, the 9th lord, is {exalted?exalted|in its own sign} in house {house}, and the Ascendant lord {lagnaLord} is strong.',
  'yoga.budhaditya.weak':
      'Mercury is {deg}° from the Sun. B.V. Raman notes it should be more than 10° away for this yoga to give its '
      'results, so it is considered weak here.',
  'yoga.sunapha.reason': '{planets|and} in the 2nd from the Moon.',
  'yoga.anapha.reason': '{planets|and} in the 12th from the Moon.',
  'yoga.durudhara.reason': '{second|and} in the 2nd and {twelfth|and} in the 12th from the Moon.',
  'yoga.shakata.reason': 'The Moon is in house {house} counted from Jupiter.',
  'yoga.shakata.cancelled': 'Not considered formed: the Moon is in a kendra from the Ascendant.',
  'yoga.vesi.reason': '{second|and} in the 2nd from the Sun.',
  'yoga.vasi.reason': '{twelfth|and} in the 12th from the Sun.',
  'yoga.ubhayachari.reason': '{second|and} in the 2nd and {twelfth|and} in the 12th from the Sun.',
  'yoga.pair.inHouse': '{a} (lord of {aHouses}) and {b} (lord of {bHouses}): {who} is placed in house {house}.',
  'yoga.pair.aspect': '{a} (lord of {aHouses}) and {b} (lord of {bHouses}) aspect each other.',
  'yoga.parivartana.reason': '{a}, lord of house {i}, is in house {j}, and {b}, lord of house {j}, is in house {i}.',
  'yoga.neecha.aspect': '{planet}, lord of the debilitation sign, aspects it',
  'yoga.amala.reason': '{planets|and} in the 10th from the Ascendant or the Moon.',
  'yoga.vasumati.reason':
      'Mercury, Jupiter and Venus are all in upachaya houses (3, 6, 10, 11) from the {fromMoon?Moon|Ascendant}.',
  // Yogas: names and meanings of the yogas added after the first release.
  'yoga.sunapha.name': 'Sunapha Yoga',
  'yoga.sunapha.meaning': 'Associated with self-earned wealth, intelligence and a good name.',
  'yoga.anapha.name': 'Anapha Yoga',
  'yoga.anapha.meaning': 'Associated with good health, a pleasing personality and contentment.',
  'yoga.durudhara.name': 'Durudhara Yoga',
  'yoga.durudhara.meaning': 'Associated with comforts, generosity and support from many sides.',
  'yoga.shakata.name': 'Shakata Yoga',
  'yoga.shakata.meaning':
      'Traditionally associated with ups and downs in fortune, like the turning of a cart wheel; effort brings '
      'recovery.',
  'yoga.vesi.name': 'Vesi Yoga',
  'yoga.vesi.meaning': 'Associated with truthfulness, steady effort and a balanced outlook.',
  'yoga.vasi.name': 'Vasi Yoga',
  'yoga.vasi.meaning': 'Associated with skill, generosity and recognition from others.',
  'yoga.ubhayachari.name': 'Ubhayachari Yoga',
  'yoga.ubhayachari.meaning': 'Associated with eloquence, balance and a respected, comfortable life.',
  'yoga.parivartanaMaha.name': 'Maha Parivartana Yoga',
  'yoga.parivartanaMaha.meaning':
      'A strong exchange: the two houses support each other, traditionally bringing prosperity.',
  'yoga.parivartanaKhala.name': 'Khala Parivartana Yoga',
  'yoga.parivartanaKhala.meaning': 'Associated with a changeable course: periods of effort alternating with gains.',
  'yoga.parivartanaDainya.name': 'Dainya Parivartana Yoga',
  'yoga.parivartanaDainya.meaning':
      'Associated with obstacles in the matters of the houses involved, which ease with effort.',
  'yoga.amala.name': 'Amala Yoga',
  'yoga.amala.meaning': 'Associated with a good name, ethical conduct and lasting reputation.',
  'yoga.vasumati.name': 'Vasumati Yoga',
  'yoga.vasumati.meaning': 'Associated with steadily growing wealth and independence.',
  // Yogas: what each one is (its classical condition in plain words).
  'yoga.gajakesari.def': 'Formed when Jupiter is in a kendra (1st, 4th, 7th or 10th) counted from the Moon.',
  'yoga.budhaditya.def':
      'Formed when the Sun and Mercury are in the same sign. B.V. Raman adds that Mercury should be more than 10° '
      'from the Sun.',
  'yoga.chandraMangala.def': 'Formed when the Moon and Mars are in the same sign.',
  'yoga.kemadruma.def':
      'Formed when no planet (other than the Sun, Rahu and Ketu) is in the 2nd or 12th sign from the Moon. It is '
      'cancelled when a planet is with the Moon or in a kendra from the Ascendant or Moon.',
  'yoga.sunapha.def': 'Formed when a planet other than the Sun, Rahu and Ketu is in the 2nd sign from the Moon.',
  'yoga.anapha.def': 'Formed when a planet other than the Sun, Rahu and Ketu is in the 12th sign from the Moon.',
  'yoga.durudhara.def': 'Formed when planets (other than the Sun, Rahu and Ketu) are on both sides of the Moon.',
  'yoga.adhi.def':
      'Formed when the natural benefics Mercury, Jupiter and Venus are in the 6th, 7th and 8th from the Moon (two of '
      'the three count as partial).',
  'yoga.shakata.def':
      'Formed when the Moon is in the 6th, 8th or 12th from Jupiter; not formed when the Moon is in a kendra from '
      'the Ascendant.',
  'yoga.vesi.def': 'Formed when a planet other than the Moon, Rahu and Ketu is in the 2nd sign from the Sun.',
  'yoga.vasi.def': 'Formed when a planet other than the Moon, Rahu and Ketu is in the 12th sign from the Sun.',
  'yoga.ubhayachari.def': 'Formed when planets (other than the Moon, Rahu and Ketu) are on both sides of the Sun.',
  'yoga.ruchaka.def': 'One of the five Mahapurusha yogas: Mars in its own sign or exalted, in a kendra.',
  'yoga.bhadra.def': 'One of the five Mahapurusha yogas: Mercury in its own sign or exalted, in a kendra.',
  'yoga.hamsa.def': 'One of the five Mahapurusha yogas: Jupiter in its own sign or exalted, in a kendra.',
  'yoga.malavya.def': 'One of the five Mahapurusha yogas: Venus in its own sign or exalted, in a kendra.',
  'yoga.shasha.def': 'One of the five Mahapurusha yogas: Saturn in its own sign or exalted, in a kendra.',
  'yoga.raja.def':
      'Formed when the lord of a kendra (1, 4, 7, 10) and the lord of a trikona (1, 5, 9) are together, exchange '
      'those houses, one sits in the other\'s house, or they aspect each other.',
  'yoga.dhana.def':
      'Formed when a lord of a wealth house (2nd or 11th) and a lord of a fortune house (5th or 9th) are together '
      'or exchange those houses.',
  'yoga.yogakaraka.def':
      'A planet that rules both a kendra and a trikona (other than the 1st house) for this Ascendant.',
  'yoga.parivartanaMaha.def':
      'Two house lords sit in each other\'s signs (an exchange), and neither house is the 3rd, 6th, 8th or 12th.',
  'yoga.parivartanaKhala.def': 'An exchange between two house lords in which one of the houses is the 3rd.',
  'yoga.parivartanaDainya.def':
      'An exchange between two house lords in which one of the houses is the 6th, 8th or 12th.',
  'yoga.neechaBhanga.def':
      'A debilitated planet whose weakness is cancelled: the lord of its sign or of its exaltation sign is in a '
      'kendra from the Ascendant or Moon, a planet exalted in that sign is in such a kendra, or the sign\'s lord '
      'aspects it.',
  'yoga.harsha.def': 'Viparita Raja yoga: the lord of the 6th house is in the 6th, 8th or 12th.',
  'yoga.sarala.def': 'Viparita Raja yoga: the lord of the 8th house is in the 6th, 8th or 12th.',
  'yoga.vimala.def': 'Viparita Raja yoga: the lord of the 12th house is in the 6th, 8th or 12th.',
  'yoga.amala.def':
      'Formed when a natural benefic (Mercury, Jupiter or Venus) is in the 10th from the Ascendant or Moon.',
  'yoga.vasumati.def':
      'Formed when the natural benefics Mercury, Jupiter and Venus are all in upachaya houses (3, 6, 10, 11) from '
      'the Ascendant or from the Moon.',
  'yoga.saraswati.def':
      'Formed when Jupiter, Venus and Mercury are in kendras, trikonas or the 2nd house, and Jupiter is in its own, '
      'exalted or a friend\'s sign.',
  'yoga.lakshmi.def':
      'Formed when the 9th lord is in its own or exaltation sign in a kendra or trikona, and the Ascendant lord is '
      'strong.',
  'yoga.fewer':
      'Drishti shows a yoga only when its full classical condition is met, with its source. Other apps may show more '
      'because they also count looser variants, ignore cancellations, or include modern combinations such as Kala '
      'Sarpa that are not in the classical texts.',

  // Sources
  'source.phaladeepika6': 'Phaladeepika ch. 6',
  'source.common': 'Commonly cited in classical texts',
  'source.bphsPhaladeepika6': 'BPHS; Phaladeepika ch. 6',
  'source.bphsRaja': 'BPHS (Raja Yoga chapter)',
  'source.bphsDhana': 'BPHS (Dhana Yoga chapter)',
  'source.bphs': 'BPHS',
  'source.commonPhaladeepika': 'Commonly cited in classical texts (e.g. Phaladeepika)',
  'source.raman6': 'B.V. Raman, Three Hundred Important Combinations, no. 6',
  'source.raman12': 'B.V. Raman, Three Hundred Important Combinations, no. 12',
  'source.raman24': 'B.V. Raman, Three Hundred Important Combinations, no. 24',
  'source.raman27': 'B.V. Raman, Three Hundred Important Combinations, no. 27; BPHS 36',
  'source.bphs37Phaladeepika6': 'BPHS ch. 37; Phaladeepika ch. 6',
  'source.phaladeepika6Raman16': 'Phaladeepika ch. 6; B.V. Raman, nos. 16-18',
  'source.phaladeepika6Raman13': 'Phaladeepika 6.19; B.V. Raman, no. 13',
  'source.phaladeepika6Raman9': 'Phaladeepika 6.19; B.V. Raman, no. 9',
  'source.bphs34': 'BPHS ch. 34 (vv. 11-13)',
  'source.parashariDhana':
      'Parashari principle of the wealth-house lords (2, 11) joining the fortune-house lords (5, 9), as summarised by '
      'later authors',
  'source.phaladeepika6Parivartana': 'Phaladeepika 6.32-34',
  'source.phaladeepika6Viparita': 'Phaladeepika 6.57, 6.63-69',
  'source.phaladeepika7': 'Phaladeepika 7.26-30',

  // Numerology
  'numerology.title.lifePath': 'Life Path',
  'numerology.title.birthday': 'Birthday',
  'numerology.title.mulank': 'Mulank',
  'numerology.title.bhagyank': 'Bhagyank',
  'numerology.title.expression': 'Expression',
  'numerology.title.soulUrge': 'Soul Urge',
  'numerology.title.personality': 'Personality',
  'numerology.title.chaldeanName': 'Name Number (Chaldean)',
  'numerology.meaning.1': 'Associated with independence, initiative and leadership. Traditionally linked with the Sun.',
  'numerology.meaning.2':
      'Associated with cooperation, sensitivity and partnership. Traditionally linked with the Moon.',
  'numerology.meaning.3': 'Associated with creativity, expression and optimism. Traditionally linked with Jupiter.',
  'numerology.meaning.4':
      'Associated with structure, hard work and practicality. Traditionally linked with Rahu (Uranus in Western use).',
  'numerology.meaning.5': 'Associated with curiosity, change and communication. Traditionally linked with Mercury.',
  'numerology.meaning.6':
      'Associated with care, responsibility and harmony in relationships. Traditionally linked with Venus.',
  'numerology.meaning.7':
      'Associated with reflection, research and inner life. Traditionally linked with Ketu (Neptune in Western use).',
  'numerology.meaning.8': 'Associated with discipline, ambition and patience. Traditionally linked with Saturn.',
  'numerology.meaning.9': 'Associated with compassion, courage and completion. Traditionally linked with Mars.',
  'numerology.meaning.11':
      'A master number associated with intuition and inspiration; also carries the qualities of 2.',
  'numerology.meaning.22':
      'A master number associated with building large, practical goals; also carries the qualities of 4.',
  'numerology.meaning.33': 'A master number associated with teaching and service; also carries the qualities of 6.',
};
