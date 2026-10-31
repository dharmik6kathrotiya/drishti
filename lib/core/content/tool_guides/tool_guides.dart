import 'tool_guides_bn.dart';
import 'tool_guides_hi.dart';
import 'tool_guides_kn.dart';
import 'tool_guides_ml.dart';
import 'tool_guides_mr.dart';
import 'tool_guides_ta.dart';
import 'tool_guides_te.dart';

/// "About this tool" guides: what each tool is, why people use it, how it
/// works (the actual method and math used by this app), an honest science
/// note and references.
///
/// Texts are per language (`tool_guides_<code>.dart`); a missing language or
/// a missing tool in a language falls back to English. References are
/// bibliographic citations and are shared by all languages.
class ToolGuideText {
  const ToolGuideText({
    required this.title,
    required this.what,
    required this.why,
    required this.how,
    required this.science,
  });

  /// Name of the tool, shown as the sheet title.
  final String title;

  /// What it is.
  final String what;

  /// Why and when people use it.
  final String why;

  /// The method and the math, as this app actually does it. Paragraphs are
  /// separated by a blank line.
  final String how;

  /// Honest note: what is exact and verifiable, and what science has (not)
  /// shown.
  final String science;
}

/// A complete guide in one language.
class ToolGuide {
  const ToolGuide({required this.id, required this.text, required this.references});

  final String id;
  final ToolGuideText text;
  final List<String> references;

  String get title => text.title;
  String get what => text.what;
  String get why => text.why;
  String get how => text.how;
  String get science => text.science;
}

abstract final class ToolGuides {
  /// Every tool with a guide. Ids are stable; screens refer to them.
  static const ids = <String>[
    'chart',
    'divisional',
    'planets',
    'dasha',
    'yogas',
    'doshas',
    'sade_sati',
    'kp',
    'shadbala',
    'ashtakavarga',
    'jaimini',
    'lal_kitab',
    'forecast',
    'horoscope',
    'panchang',
    'festivals',
    'muhurat',
    'matching',
    'composite',
    'children',
    'numerology',
    'tarot',
    'palmistry',
    'meditation',
    'journal',
    'remedies',
    'rectification',
    'ai_guide',
    'profiles',
    'share_qr',
  ];

  /// Guide texts per language code.
  static const byLanguage = <String, Map<String, ToolGuideText>>{
    'en': toolGuidesEn,
    'hi': toolGuidesHi,
    'mr': toolGuidesMr,
    'bn': toolGuidesBn,
    'ta': toolGuidesTa,
    'te': toolGuidesTe,
    'kn': toolGuidesKn,
    'ml': toolGuidesMl,
  };

  /// The guide for [id] in [languageCode], falling back to English. Null only
  /// for an unknown id.
  static ToolGuide? of(String id, String languageCode) {
    final text = byLanguage[languageCode]?[id] ?? toolGuidesEn[id];
    if (text == null) return null;
    return ToolGuide(id: id, text: text, references: toolGuideReferences[id] ?? const []);
  }
}

// ---------------------------------------------------------------------------
// Shared references (citations stay in their usual, original form).
// ---------------------------------------------------------------------------

const _bphs =
    "Brihat Parashara Hora Shastra (attributed to Maharshi Parashara), English translation by R. Santhanam, "
    "Ranjan Publications, 1984";
const _phaladeepika = "Phaladeepika, Mantreswara (c. 14th–16th century)";
const _saravali = "Saravali, Kalyana Varma (c. 10th century)";
const _jatakaParijata = "Jataka Parijata, Vaidyanatha Dikshita (c. 15th century)";
const _brihatJataka = "Brihat Jataka, Varahamihira (6th century)";
const _muhurtaChintamani = "Muhurta Chintamani, Rama Daivajna (1600)";
const _suryaSiddhanta = "Surya Siddhanta, translated by Ebenezer Burgess, 1860 (reprinted by Motilal Banarsidass)";
const _jaiminiSutras = "Jaimini Upadesa Sutras (attributed to Maharshi Jaimini)";
const _kpReaders = "K.S. Krishnamurti, KP Reader I–VI (Krishnamurti Publications)";
const _swissEph =
    "Dieter Koch and Alois Treindl, Swiss Ephemeris documentation, Astrodienst AG, Zurich "
    "(based on NASA JPL DE431)";
const _iae =
    "Indian Astronomical Ephemeris and Rashtriya Panchang, Positional Astronomy Centre, India Meteorological "
    "Department, Kolkata (published annually)";
const _calendarReform = "Report of the Calendar Reform Committee, Government of India (CSIR), 1955";
const _reingold =
    "E.M. Reingold and N. Dershowitz, Calendrical Calculations, Cambridge University Press (4th ed., 2018)";
const _meeus = "Jean Meeus, Astronomical Algorithms, 2nd ed., Willmann-Bell, 1998";
const _raman300 = "B.V. Raman, Three Hundred Important Combinations, 1947";
const _ramanManual = "B.V. Raman, A Manual of Hindu Astrology, 1935";
const _carlson = "S. Carlson, \"A double-blind test of astrology\", Nature 318, 419–425 (1985)";
const _deanKelly =
    "G. Dean and I.W. Kelly, \"Is astrology relevant to consciousness and psi?\", Journal of Consciousness "
    "Studies 10(6–7), 175–198 (2003)";
const _narlikar =
    "J.V. Narlikar, S. Kunte, N. Dabholkar and P. Ghatpande, \"A statistical test of astrology\", Current "
    "Science 96(5), 641–643 (2009)";
const _forer =
    "B.R. Forer, \"The fallacy of personal validation\", Journal of Abnormal and Social Psychology 44(1), "
    "118–123 (1949)";
const _hand1976 = "Robert Hand, Planets in Transit, Whitford Press, 1976";

const toolGuideReferences = <String, List<String>>{
  'chart': [_bphs, _brihatJataka, _swissEph, _calendarReform, _carlson, _narlikar],
  'divisional': [_bphs, _saravali, _jatakaParijata, _narlikar],
  'planets': [
    _bphs,
    _suryaSiddhanta,
    _swissEph,
    "The Astronomical Almanac, U.S. Naval Observatory and HM Nautical Almanac Office (published annually)",
  ],
  'dasha': [_bphs, _ramanManual, _narlikar],
  'yogas': [_bphs, _phaladeepika, _saravali, _raman300, _narlikar],
  'doshas': [_bphs, _phaladeepika, _muhurtaChintamani, _narlikar],
  'sade_sati': [_phaladeepika, _bphs, _swissEph, _narlikar],
  'kp': [_kpReaders, _swissEph, _narlikar],
  'shadbala': [_bphs, "B.V. Raman, Graha and Bhava Balas, 1959", _suryaSiddhanta],
  'ashtakavarga': [_bphs, "B.V. Raman, Ashtakavarga System of Prediction, 1962", _narlikar],
  'jaimini': [
    _jaiminiSutras,
    "Sanjay Rath, Jaimini Maharishi's Upadesa Sutras, Sagar Publications, 1997",
    "K.N. Rao, Predicting through Jaimini's Chara Dasha, Vani Publications",
    _narlikar,
  ],
  'lal_kitab': ["Lal Kitab, Pt. Roop Chand Joshi (editions of 1939–1952)", _carlson, _narlikar],
  'forecast': ["Alan Leo, The Progressed Horoscope, 1905", _hand1976, _swissEph, _deanKelly],
  'horoscope': [_phaladeepika, _bphs, _hand1976, _forer, _carlson],
  'panchang': [_suryaSiddhanta, _iae, _calendarReform, _muhurtaChintamani, _reingold],
  'festivals': [
    "Nirnayasindhu, Kamalakara Bhatta (1612)",
    "Dharmasindhu, Kashinatha Upadhyaya (c. 1790)",
    _iae,
    _reingold,
  ],
  'muhurat': [_muhurtaChintamani, "B.V. Raman, Muhurtha (Electional Astrology)", _iae],
  'matching': [
    _muhurtaChintamani,
    _bphs,
    "B.I. Silverman, \"Studies of astrology\", Journal of Psychology 77, 141–149 (1971)",
    _carlson,
  ],
  'composite': ["Robert Hand, Planets in Composite, Whitford Press, 1975", _deanKelly],
  'children': [
    _bphs,
    "Mantreswara, Phaladeepika, ch. 12 (Putra Bhava), tr. V. Subrahmanya Sastri",
    "The Pre-Conception and Pre-Natal Diagnostic Techniques (PCPNDT) Act, 1994, Government of India",
    "World Health Organization, sex ratio at birth (about 105 boys per 100 girls)",
    _carlson,
  ],
  'numerology': [
    "Cheiro (William John Warner), Cheiro's Book of Numbers, 1926",
    "Underwood Dudley, Numerology: Or What Pythagoras Wrought, Mathematical Association of America, 1997",
    _forer,
  ],
  'tarot': [
    "A.E. Waite, The Pictorial Key to the Tarot, William Rider & Son, 1910",
    "Rachel Pollack, Seventy-Eight Degrees of Wisdom, 1980",
    "D.E. Knuth, The Art of Computer Programming, Vol. 2: Seminumerical Algorithms, §3.4.2 (random shuffling)",
    _forer,
  ],
  'palmistry': [
    "Cheiro (William John Warner), Cheiro's Language of the Hand, 1894",
    "William G. Benham, The Laws of Scientific Hand Reading, 1900",
    _forer,
  ],
  'meditation': [
    "A. Zaccaro et al., \"How breath-control can change your life: a systematic review on psycho-physiological "
        "correlates of slow breathing\", Frontiers in Human Neuroscience 12, 353 (2018)",
    "M. Goyal et al., \"Meditation programs for psychological stress and well-being: a systematic review and "
        "meta-analysis\", JAMA Internal Medicine 174(3), 357–368 (2014)",
    "Hatha Yoga Pradipika, Svatmarama (15th century), chapter 2 (pranayama)",
    "Patanjali, Yoga Sutras 2.49–2.51",
  ],
  'journal': [
    "J.W. Pennebaker, \"Writing about emotional experiences as a therapeutic process\", Psychological Science "
        "8(3), 162–166 (1997)",
    "J. Rotton and I.W. Kelly, \"Much ado about the full moon: a meta-analysis of lunar-lunacy research\", "
        "Psychological Bulletin 97(2), 286–306 (1985)",
    _swissEph,
  ],
  'remedies': [_bphs, _phaladeepika, "Lal Kitab, Pt. Roop Chand Joshi (editions of 1939–1952)", _carlson],
  'rectification': [_bphs, _phaladeepika, _kpReaders, _narlikar],
  'ai_guide': [
    "A. Vaswani et al., \"Attention is all you need\", Advances in Neural Information Processing Systems 30 (2017)",
    "Qwen Team, \"Qwen2.5 Technical Report\", arXiv:2412.15115 (2024)",
    "Z. Ji et al., \"Survey of hallucination in natural language generation\", ACM Computing Surveys 55(12) "
        "(2023)",
    _bphs,
  ],
  'profiles': [
    "GeoNames geographical database (geonames.org), CC BY 4.0",
    "IANA Time Zone Database (tz database), Internet Assigned Numbers Authority",
    _meeus,
  ],
  'share_qr': [
    "ISO/IEC 18004:2015, QR Code bar code symbology specification",
    "RFC 4648, The Base16, Base32, and Base64 Data Encodings (IETF, 2006)",
    "RFC 8259, The JavaScript Object Notation (JSON) Data Interchange Format (IETF, 2017)",
    "I.S. Reed and G. Solomon, \"Polynomial codes over certain finite fields\", Journal of the SIAM 8(2), "
        "300–304 (1960)",
  ],
};

// ---------------------------------------------------------------------------
// English (fallback for every language).
// ---------------------------------------------------------------------------

const toolGuidesEn = <String, ToolGuideText>{
  'chart': ToolGuideText(
    title: "Birth chart (Kundli)",
    what:
        "A map of the sky at the moment and place of birth: the rising sign (Lagna), the twelve houses, and where "
        "the Sun, Moon, planets and the lunar nodes Rahu and Ketu stood in the zodiac.",
    why:
        "It is the base for almost every other tool here: dashas, yogas, strengths, matching and horoscopes all "
        "read from it. People use it to see the classical picture of their temperament and life themes.",
    how:
        "The local birth time is converted to Universal Time with the IANA time-zone rules for that date, then to "
        "a Julian day. Swiss Ephemeris gives each body's geocentric ecliptic longitude. For Vedic charts, sidereal "
        "longitude = tropical longitude − ayanamsa (Lahiri by default; eight others can be chosen). "
        "Sign = floor(longitude ÷ 30°).\n\n"
        "The Ascendant is the ecliptic degree rising on the eastern horizon at the birth latitude and longitude. "
        "Houses are whole-sign by default in Vedic mode (house 1 = Lagna sign) and Placidus in Western mode. Rahu "
        "is the mean lunar node by default; Ketu is exactly 180° opposite.",
    science:
        "The positions are real astronomy, accurate to well under an arcsecond for 1800–2400 CE, and you can check "
        "them against any ephemeris. A 4-minute error in birth time shifts the Ascendant by about 1°. Controlled "
        "tests have not found that charts predict personality or events (Carlson 1985; Narlikar et al. 2009). "
        "Read it as a traditional, symbolic map.",
  ),
  'divisional': ToolGuideText(
    title: "Divisional charts (Vargas)",
    what:
        "Sixteen sub-charts, D1 to D60, made by dividing each 30° sign into equal parts. Each varga is read for "
        "one area of life, for example D9 (Navamsa) for marriage and dharma and D10 (Dasamsa) for career.",
    why:
        "Traditional astrologers confirm what the birth chart promises by checking the matching varga, and judge a "
        "planet's dignity across several vargas.",
    how:
        "For a planet at degree d inside its sign, part = floor(d ÷ (30° ÷ N)). Rules from BPHS ch. 6–7 then map "
        "the part to a sign. D9 counts continuously from Aries in 3°20′ steps (fire signs start from Aries, earth "
        "from Capricorn, air from Libra, water from Cancer). D2 gives Leo or Cancer by half and odd/even sign. D3 "
        "uses the sign, its 5th and its 9th. D10 starts from the sign (odd signs) or its 9th (even signs). D30 "
        "uses unequal portions of 5°, 5°, 8°, 7° and 5°. D60 counts 30′ parts from the sign itself.",
    science:
        "The arithmetic is exact. But fine vargas need a very precise birth time: the D60 sign of the Ascendant "
        "changes about every 2 minutes. The meanings given to each varga are tradition and have not been tested "
        "scientifically.",
  ),
  'planets': ToolGuideText(
    title: "Planet positions",
    what:
        "A table of each body's sign, exact degree, house, nakshatra and pada, its dignity (exalted, debilitated, "
        "own sign) and its daily speed.",
    why:
        "It is the raw data behind the chart: useful for checking against a printed almanac or another program, "
        "and for reading planetary dignities.",
    how:
        "Longitudes come from Swiss Ephemeris (sidereal in Vedic mode). Degree in sign = longitude mod 30°. "
        "Nakshatra = floor(longitude ÷ 13°20′), the zodiac split into 27 equal parts; each pada is a quarter, "
        "3°20′. Speed is the change in longitude per day. A negative speed means retrograde: an apparent backward "
        "motion seen from Earth when Earth overtakes an outer planet or an inner planet overtakes Earth. Dignities "
        "follow the classical exaltation and debilitation signs (for example, the Sun is exalted in Aries and "
        "debilitated in Libra).",
    science:
        "Positions and retrograde motion are real, observable astronomy and match published almanacs. The "
        "meanings linked to them are traditional and have not been shown scientifically.",
  ),
  'dasha': ToolGuideText(
    title: "Dasha periods (Vimshottari and Yogini)",
    what:
        "Planetary periods that divide life into chapters, each ruled by a planet, with sub-periods "
        "(Antardasha, Pratyantardasha).",
    why:
        "Dashas are the main timing tool of Vedic astrology: astrologers use them to say when the themes of a "
        "chart become active.",
    how:
        "Vimshottari is a 120-year cycle in a fixed order: Ketu 7, Venus 20, Sun 6, Moon 10, Mars 7, Rahu 18, "
        "Jupiter 16, Saturn 19, Mercury 17 years. The first period belongs to the lord of the Moon's birth "
        "nakshatra, and its remaining balance = its years × (unelapsed part of the nakshatra ÷ 13°20′). Sub-periods "
        "are proportional: Antardasha = Mahadasha years × sub-lord years ÷ 120, starting with the Mahadasha lord. "
        "A year is taken as 365.25 days.\n\n"
        "Yogini dasha is a 36-year cycle of eight Yoginis lasting 1 to 8 years, starting from "
        "(nakshatra number + 3) mod 8.",
    science:
        "The arithmetic is exact and reproducible; programs can differ by a few days because of the year length "
        "or ayanamsa used. No controlled study has shown that dasha periods predict life events.",
  ),
  'yogas': ToolGuideText(
    title: "Yogas (planetary combinations)",
    what:
        "Named combinations from classical texts, such as Gajakesari, the five Pancha Mahapurusha yogas, Raja, "
        "Dhana, Viparita Raja, Lakshmi, Saraswati, Neecha Bhanga and Kemadruma.",
    why: "Astrologers use them as a quick summary of the strengths and challenges a chart is said to show.",
    how:
        "Each yoga is a rule tested on your chart. Gajakesari: Jupiter in a kendra (1st, 4th, 7th or 10th) from "
        "the Moon. Pancha Mahapurusha: Mars, Mercury, Jupiter, Venus or Saturn in its own or exaltation sign in a "
        "kendra from the Lagna. Budhaditya: Sun and Mercury together. Kemadruma: no planet (other than the Sun, "
        "Rahu and Ketu) with the Moon or in the 2nd or 12th from it. Viparita Raja: lords of the 6th, 8th or 12th "
        "placed in one of those houses. Aspects use whole-sign graha drishti: every planet aspects the 7th sign; "
        "Mars also the 4th and 8th, Jupiter the 5th and 9th, Saturn the 3rd and 10th. Each result shows the reason "
        "found and any cancellation.",
    science:
        "Detection is pure logic, so every reason can be checked. Many yogas are very common (Mercury is never more "
        "than about 28° from the Sun, so Budhaditya is frequent), so their presence says little on its own. No "
        "controlled study supports their predictive claims.",
  ),
  'doshas': ToolGuideText(
    title: "Doshas (Manglik and Kaal Sarp)",
    what:
        "Traditional caution signs. Mangal (Manglik) dosha: Mars in certain houses. Kaal Sarp: all planets on one "
        "side of the Rahu–Ketu axis.",
    why:
        "Mostly checked before marriage (Manglik) or when people look for a reason for obstacles. The app shows "
        "them openly, together with their traditional cancellations.",
    how:
        "Manglik: Mars in the 1st, 2nd, 4th, 7th, 8th or 12th house, counted from the Lagna and also from the Moon "
        "and Venus; the result lists which reference points apply and any cancelling factors. Kaal Sarp: all seven "
        "classical planets lie within the 180° arc from Rahu to Ketu (or Ketu to Rahu). Sade Sati and Dhaiya are "
        "also shown in this tab; they have their own guide.",
    science:
        "These are simple counts. Mars falls in 6 of 12 houses from the Lagna in about half of all charts, and in "
        "most charts once the Moon and Venus are also counted, so being Manglik is common by construction. Kaal "
        "Sarp is a 20th-century idea not found in BPHS. There is no evidence that either affects marriage or "
        "fortune, so please do not let them frighten you.",
  ),
  'sade_sati': ToolGuideText(
    title: "Sade Sati and Dhaiya",
    what:
        "Sade Sati (\"seven and a half\") is the time when Saturn passes through the 12th, 1st and 2nd signs from "
        "your natal Moon sign. Dhaiya (Kantaka or Ashtama Shani) is Saturn in the 4th or 8th sign from the Moon.",
    why:
        "It is one of the most asked-about topics in Indian astrology. Tradition links it with effort, "
        "responsibility and maturing, not only with difficulty.",
    how:
        "Saturn's sidereal position is computed with Swiss Ephemeris, and the app finds when it enters and leaves "
        "the three signs around your Moon sign, merging short exits caused by retrograde motion. Saturn circles the "
        "zodiac in about 29.5 years, so it spends about 2.5 years in a sign and about 7.5 years in three. The "
        "phases are rising (12th), peak (1st) and setting (2nd). Sade Sati returns roughly every 29.5 years, "
        "usually two or three times in a life.",
    science:
        "The dates are exact astronomy. Since everyone is in Sade Sati for about a quarter of their life "
        "(7.5 ÷ 29.5), it does not single anyone out, and no study links it to misfortune. Its traditional message "
        "of patience and steady work is worth keeping, without fear.",
  ),
  'kp': ToolGuideText(
    title: "KP (Krishnamurti Paddhati)",
    what:
        "A 20th-century Vedic method created by Prof. K.S. Krishnamurti, built on sub lords, Placidus house cusps "
        "and the KP ayanamsa.",
    why: "Its followers use it for precise yes/no and timing questions, including horary (prashna) questions.",
    how:
        "Each nakshatra (13°20′) is divided into nine unequal subs in proportion to the Vimshottari years, starting "
        "from the nakshatra lord (a Venus sub is 20/120 of 13°20′ = 2°13′20″). Each sub is divided again the same "
        "way (sub-sub). So every degree has a sign lord, star lord, sub lord and sub-sub lord. The 27 × 9 = 243 "
        "subs, split at sign boundaries, give the 249 KP horary numbers.\n\n"
        "House cusps are Placidus with the KP ayanamsa. Significators are listed in four levels: planets in the "
        "star of the occupants, the occupants, planets in the star of the house lord, and the house lord; Rahu and "
        "Ketu act as agents. Ruling planets are the day lord and the sign, star and sub lords of the Ascendant and "
        "the Moon at the moment.",
    science:
        "The subdivisions are exact arithmetic, but a sub can be as narrow as 40′, so KP needs a birth time "
        "accurate to the minute or better. Its predictive claims have not been tested in controlled studies.",
  ),
  'shadbala': ToolGuideText(
    title: "Shadbala (six-fold strength)",
    what: "A numerical score of how able each of the seven planets is to give its results, from BPHS ch. 27.",
    why: "Astrologers use it to see which planets dominate a chart and how strongly a dasha lord can act.",
    how:
        "Six strengths are added in virupas (60 virupas = 1 rupa): Sthana (position: exaltation, dignity in seven "
        "vargas, odd/even sign, kendra, drekkana), Dig (direction: angular distance from the powerless point ÷ 3), "
        "Kala (time: day or night, lunar phase, year/month/weekday/hour lords, declination), Chesta (motion), "
        "Naisargika (natural: Sun 60 down to Saturn 8.57) and Drik (aspects received).\n\n"
        "The total in rupas is compared with the classical minimum: Sun 6.5, Moon 6, Mars 5, Mercury 7, "
        "Jupiter 6.5, Venus 5.5, Saturn 5. A bar past the marker means the planet counts as strong.",
    science:
        "It is a well-defined formula. Programs choose different sub-methods (for Chesta bala, year and month "
        "lords, planetary war), so expect small differences; this app documents its choices in its open-source "
        "code. The weights are traditional and were not derived from measured outcomes.",
  ),
  'ashtakavarga': ToolGuideText(
    title: "Ashtakavarga",
    what: "A point system in which every sign receives benefic points (bindus) from the seven planets and the Lagna.",
    why:
        "Used to judge which signs are supportive for transits (for example Saturn moving through a sign with many "
        "bindus) and the general strength of houses.",
    how:
        "In each planet's Bhinnashtakavarga (BAV), each of eight contributors (seven planets and the Lagna) gives "
        "one bindu to particular houses counted from its own position, following the BPHS tables. Each BAV has a "
        "fixed total: Sun 48, Moon 49, Mars 39, Mercury 54, Jupiter 56, Venus 52, Saturn 39. Adding the seven BAVs "
        "gives the Sarvashtakavarga (SAV), which always totals 337. The average is 337 ÷ 12 ≈ 28 per sign, which "
        "is why 28 or more counts as supportive.",
    science:
        "The tables are fixed counting rules, and the fixed totals are a good check that the calculation is "
        "right. The idea that bindus predict how transits turn out has not been tested scientifically.",
  ),
  'jaimini': ToolGuideText(
    title: "Jaimini astrology",
    what:
        "The system of the Jaimini Upadesa Sutras: chara (movable) karakas, arudha padas and the sign-based "
        "Chara dasha.",
    why:
        "Used alongside Parashari methods, especially for the self (Atmakaraka), public image (Arudha Lagna) and "
        "marriage (Upapada).",
    how:
        "Chara karakas: the seven planets (or eight with Rahu, whose degree is counted as 30° minus its degree) "
        "ranked by degree within their sign. The highest is the Atmakaraka, then Amatyakaraka and so on down to "
        "Darakaraka. Karakamsa is the navamsa sign of the Atmakaraka.\n\n"
        "Arudha pada of a house: count from the sign to its lord, then the same number again from the lord; if "
        "this lands on the sign itself or its 7th, take the 10th from there. Chara dasha (K.N. Rao's method): a "
        "sign's years = count from the sign to its lord minus 1 (12 if the lord is in its own sign); the direction "
        "follows the 9th sign from the Lagna.",
    science:
        "The rules are deterministic, but commentators disagree on several details, so results vary between "
        "schools. Their predictive value has not been tested scientifically.",
  ),
  'lal_kitab': ToolGuideText(
    title: "Lal Kitab",
    what:
        "A North Indian system from the Urdu Lal Kitab books (1939–1952, Pt. Roop Chand Joshi), known for its "
        "fixed-house chart and simple remedies.",
    why: "Many people use it for easy everyday remedies and its plain-language readings.",
    how:
        "Signs are fixed to houses: Aries is always house 1 and Pisces house 12. Each planet goes into the house of "
        "its sidereal sign; the rising sign is not used for numbering, so no birth time is needed. The app marks "
        "planets in their pakka ghar (permanent house: Sun 1, Jupiter 2, Mars 3, Moon 4, Ketu 6, Venus and "
        "Mercury 7, Saturn 10, Rahu 12) and shows simplified sleeping houses (an empty house with no planet in the "
        "opposite house). The annual Varshphal table is left out because it could not be verified against a "
        "primary source.",
    science:
        "The placement is simple arithmetic. Lal Kitab interpretations and remedies have not been tested "
        "scientifically; treat remedies as symbolic acts, never as a substitute for real help.",
  ),
  'forecast': ToolGuideText(
    title: "Progressions and returns",
    what: "Western forecasting tools: secondary progressions, the solar return and the lunar return.",
    why:
        "Western astrologers use them to describe themes for a year (solar return), a month (lunar return) and "
        "slow inner development (progressions).",
    how:
        "Secondary progressions use \"a day for a year\": the positions on the day that is as many days after birth "
        "as you are years old (one tropical year = 365.2422 days). The progressed MC = natal MC + solar arc "
        "(progressed Sun − natal Sun), and the Ascendant is derived from it at the birth latitude.\n\n"
        "Solar return: the exact moment the Sun comes back to its natal tropical longitude each year, found by a "
        "numerical search with Swiss Ephemeris and cast for the birthplace. Lunar return: the Moon back at its "
        "natal longitude, about every 27.3 days.",
    science:
        "The timings are exact astronomy. The \"day for a year\" rule is symbolism with no physical basis, and "
        "forecasting claims have not held up in tests (Dean & Kelly 2003).",
  ),
  'horoscope': ToolGuideText(
    title: "Horoscope (day, week, month, year)",
    what:
        "A personal reading for the chosen period, with 1–5 ratings for career, money, love, health and mind, and "
        "the reason behind each statement.",
    why:
        "A quick check-in for the day or period. Unlike a sun-sign column, it uses your own Moon sign and birth "
        "star when your profile has them.",
    how:
        "Vedic mode uses Gochara (transits) counted from your natal Moon sign. Each planet is favourable in certain "
        "houses (Phaladeepika ch. 26; for example Saturn in the 3rd, 6th and 11th), unless vedha applies: another "
        "planet in the obstructing house. Tara bala counts from your birth nakshatra to today's Moon nakshatra "
        "(nine taras). Western mode uses transit aspects (conjunction, sextile, square, trine, opposition) to your "
        "natal planets within orbs of 2–5°.\n\n"
        "Each factor is weighted by period (the Moon dominates daily readings; Jupiter, Saturn and the nodes "
        "dominate yearly ones), mapped to life areas, and turned into a rating and sentences.",
    science:
        "The transits are real positions, and every sentence cites its factor. Still, this is a rule-based "
        "template: studies have not found that transits predict daily events, and horoscopes often feel accurate "
        "because general statements fit most people (the Forer or Barnum effect). Enjoy it as a reflection prompt.",
  ),
  'panchang': ToolGuideText(
    title: "Panchang",
    what:
        "The Hindu almanac for a day and place: the five limbs (tithi, vara, nakshatra, yoga, karana) plus sunrise, "
        "sunset, moonrise, Rahu kaal, Yamaganda, Gulika, Abhijit, Choghadiya, Hora, lunar month and Samvat.",
    why: "Used to choose days for rituals, fasts and new beginnings, and to follow the traditional calendar.",
    how:
        "Elements are taken at local sunrise, when the Hindu day begins. Tithi = floor((Moon − Sun) ÷ 12°) + 1, "
        "30 per lunar month. Nakshatra = sidereal Moon ÷ 13°20′. Yoga = (sidereal Sun + Moon) ÷ 13°20′. Karana = "
        "half a tithi (6°). End times are found by solving when each angle reaches its next boundary. Sunrise is "
        "when the Sun's upper edge meets the horizon, with standard refraction.\n\n"
        "Rahu kaal, Yamaganda and Gulika are fixed eighths of daytime by weekday (Rahu kaal: the 8th part on "
        "Sunday, 2nd Monday, 7th Tuesday, 5th Wednesday, 6th Thursday, 4th Friday, 3rd Saturday). Horas follow the "
        "Chaldean order. A lunar month is named from the Sun's sign at its new moon; a month with no sankranti is "
        "adhika (extra).",
    science:
        "These are exact astronomical quantities that you can verify against the Rashtriya Panchang. Times may "
        "differ by a minute or two from printed panchangs because of place, refraction and ayanamsa choices. "
        "Whether a time is auspicious is a cultural tradition, not a measurable effect.",
  ),
  'festivals': ToolGuideText(
    title: "Festival and vrat calendar",
    what:
        "Hindu festivals, vrats (such as Ekadashi, Pradosh and Purnima), sankrantis and eclipses, calculated for "
        "your location.",
    why:
        "To know the correct local date, because the same tithi can fall on different civil dates in different "
        "places.",
    how:
        "Each festival is defined by a lunar month and tithi, plus the part of the day in which that tithi must "
        "prevail (the kala): sunrise (udaya tithi) by default, or a part of daytime such as madhyahna or "
        "aparahna, pradosha after sunset, nishita around midnight, or moonrise. The app computes the tithi "
        "boundaries and these local times, then picks the day using the common North Indian (Smarta) rules. A "
        "sankranti is the moment the Sun enters a sidereal sign. Eclipses come from the Swiss Ephemeris eclipse "
        "search.",
    science:
        "The astronomy is exact. Differences between calendars come from regional and sectarian rules, which the "
        "app notes where common. The meaning of festivals is cultural and religious, not a scientific claim.",
  ),
  'muhurat': ToolGuideText(
    title: "Muhurat finder",
    what:
        "A finder for auspicious time windows for activities such as marriage, griha pravesh, travel, business, "
        "vehicle or property purchase, naming, mundan and starting education.",
    why:
        "Choosing a good time for beginnings is a strong Indian custom. The tool shows which classical rules each "
        "window meets and misses.",
    how:
        "For each day it checks Panchang rules: favourable nakshatras and weekdays for the activity, preferred "
        "tithis (avoiding Rikta tithis 4, 9 and 14, Amavasya and Ashtami), yoga (Vyatipata and Vaidhriti always "
        "avoided), Vishti (Bhadra) karana, Rahu kaal, Yamaganda, Gulika and eclipses; optionally Kharmas (Sun in "
        "Sagittarius or Pisces), combust Jupiter or Venus, and Chaturmas. With a profile it adds Tara bala and "
        "Chandra bala.\n\n"
        "Each day is cut into segments wherever tithi, nakshatra, yoga or karana changes. Windows that break a hard "
        "rule are dropped; the rest get a score of 0–100 by the share of rules met.",
    science:
        "The timings are exact, but the rule lists differ by region and text, so the score summarises tradition "
        "rather than promising an outcome. No study shows that results depend on start times chosen this way.",
  ),
  'matching': ToolGuideText(
    title: "Kundli matching",
    what:
        "Compatibility for two people: the Ashtakoota (Guna Milan) score out of 36, a Manglik comparison, and a "
        "Western synastry summary.",
    why: "Traditionally consulted by families in India before a marriage.",
    how:
        "Ashtakoota compares the two Moon nakshatras and Moon signs over eight kootas with these maximum points: "
        "Varna 1, Vashya 2, Tara 3, Yoni 4, Graha Maitri 5, Gana 6, Bhakoot 7, Nadi 8, a total of 36. Tara counts "
        "nakshatras both ways (1.5 points per favourable direction); Bhakoot gives 0 for 2/12, 5/9 and 6/8 sign "
        "pairs; Nadi gives 0 when both have the same nadi. 18 is the traditional minimum, and traditional "
        "exceptions are listed.\n\n"
        "Manglik status is compared for both charts. Synastry counts aspects between the two people's planets: "
        "trines and sextiles as harmonious, squares and oppositions as challenging.",
    science:
        "The score follows exactly from two Moon positions, and tables differ slightly between almanacs. Studies "
        "have found no link between astrological compatibility and the success of marriages. Understanding, respect "
        "and communication matter more than any number.",
  ),
  'children': ToolGuideText(
    title: "Children (Santana)",
    what:
        "A traditional Vedic reading of children for one person or a couple: how supportive the chart is, and which "
        "periods the dasha method marks. It never says whether a child will be a boy or a girl.",
    why:
        "Families have long asked astrologers about children. This shows what the classical method says, plainly, "
        "with the reasons one tap away.",
    how:
        "Houses are counted as whole signs from the Ascendant, or from the Moon sign without a birth time. The "
        "reading looks at the 5th house lord (strong in a kendra or trikona, a sign of delay in the 6th, 8th or "
        "12th; exalted or debilitated), Jupiter as the significator of children (its house, dignity and whether it "
        "is within 11° of the Sun), benefics and malefics in the 5th and Jupiter's aspect on it, and Jupiter in the "
        "Saptamsha (D7). The classical texts list these factors but give no points; to sum them up, the app "
        "counts each as +1, 0 or -1, and calls a total of 2 or more supportive, -2 or less a sign of delay, and "
        "anything between mixed.\n\n"
        "Timing: Vimshottari Antardashas of the 5th lord, Jupiter and planets in the 5th in the next 12 years.\n\n"
        "For a couple: Beeja Sphuta = Sun + Venus + Jupiter of the man, strong in an odd sign and odd navamsa and mixed (possible delay) when one is odd; "
        "Kshetra Sphuta = Moon + Mars + Jupiter of the woman, strong in an even sign and even navamsa and mixed when one is even (Phaladeepika "
        "ch. 12). Nadi dosha between the two is also noted, and the periods marked for both are shown.",
    science:
        "These are traditional rules, not medical findings; no study has shown that a birth chart predicts "
        "fertility. A baby's sex is set at conception by the father's X or Y chromosome, and in India revealing an "
        "unborn baby's sex is forbidden by the PCPNDT Act. For real questions about having children, a doctor's "
        "advice and tests matter far more.",
  ),
  'composite': ToolGuideText(
    title: "Composite chart",
    what:
        "A Western relationship chart in which every planet and angle is placed midway between two people's positions.",
    why: "Western astrologers read it as the chart of the relationship itself.",
    how:
        "For two longitudes a and b, the nearer midpoint = a + (shortest signed difference from a to b) ÷ 2, "
        "normalised to 0–360°. So 350° and 10° give 0°, not 180°. House cusps are the nearer midpoints of the "
        "matching cusps (a common simple approach; the variant that derives cusps from the composite MC gives "
        "slightly different houses).",
    science:
        "This is exact geometry, but a midpoint is not a real position of anything in the sky at any moment. No "
        "controlled study supports relationship predictions from composite charts.",
  ),
  'numerology': ToolGuideText(
    title: "Numerology",
    what:
        "Numbers derived from your name and birth date: Pythagorean (Life Path, Expression, Soul Urge, "
        "Personality, Birthday), Indian Mulank and Bhagyank, and the Chaldean name number.",
    why: "People use it for self-reflection and when choosing names or dates.",
    how:
        "Digit reduction: add the digits again and again until one digit remains (Pythagorean numbers keep the "
        "master numbers 11, 22 and 33). Life Path = month, day and year each reduced, then added and reduced. "
        "Pythagorean letters run 1–9 in cycles (A = 1 … I = 9, J = 1 …). Chaldean values go from 1 to 8 by sound "
        "(no 9), and the compound total is shown before reduction, following Cheiro. Expression uses all letters, "
        "Soul Urge only the vowels A E I O U, Personality only consonants. Mulank = day of birth reduced; Bhagyank "
        "= all digits of the date reduced.",
    science:
        "The arithmetic is exact, but the letter tables are arbitrary conventions that change with alphabet and "
        "spelling. There is no evidence that these numbers describe personality or fate (Dudley 1997).",
  ),
  'tarot': ToolGuideText(
    title: "Tarot",
    what:
        "A 78-card deck (22 Major Arcana and 56 Minor Arcana in Wands, Cups, Swords and Pentacles), drawn in "
        "spreads such as three cards and the ten-card Celtic Cross, plus a card of the day.",
    why: "Used as a prompt to think about a question or situation from new angles.",
    how:
        "The app shuffles the whole deck with a cryptographically secure random generator (a uniform random "
        "permutation) and deals the first N cards; each card is reversed with probability 1/4. Any given card "
        "has a 1 in 78 chance of appearing in a given position, and there are 78 × 77 × 76 = 456,456 ordered "
        "three-card draws. The daily card is chosen from a hash of your id and the date, so it stays the same "
        "all day. Meanings follow the Rider–Waite–Smith tradition with Golden Dawn astrological attributions.",
    science:
        "The draw is pure chance by design, so the cards cannot carry information about the future. A reading "
        "feels personal because broad meanings fit many situations (the Forer or Barnum effect). Its value is as a "
        "mirror for your own thinking.",
  ),
  'palmistry': ToolGuideText(
    title: "Palm reading guide",
    what:
        "A guided self-reading of your hand: hand shape, the heart, head, life and fate lines, mounts, fingers and "
        "thumb.",
    why: "For curiosity and self-reflection, in the tradition of Indian Samudrika Shastra and Western chiromancy.",
    how:
        "Add a photo of your palm and, on Android, Drishti finds the hand with Google's MediaPipe hand model and "
        "suggests the heart, head, life and fate lines by picking out the creases in the image, all on your phone. "
        "You check each line and redraw any that is wrong, or skip the photo and simply look at your hand. Then you "
        "answer multiple-choice questions (your lines pre-fill four of them). Each answer maps to a short "
        "traditional meaning, and the answers are combined into a reading. By tradition, the dominant hand shows your present life and the other hand "
        "inborn tendencies.",
    science:
        "Palm lines are flexion creases that form before birth and change during life. A few features have medical "
        "relevance (a single crease across the palm is more common in some genetic conditions), but no study shows "
        "that lines predict character, health or lifespan. Treat the reading as reflection.",
  ),
  'meditation': ToolGuideText(
    title: "Meditation and breathing",
    what:
        "Guided breathing with a timer: box breathing (4-4-4-4), 4-7-8 breathing, nadi shodhana (alternate "
        "nostril) and Om chanting.",
    why:
        "To calm down, focus, or wind down before sleep. The weekday's traditional planetary lord suggests a theme "
        "for the day.",
    how:
        "Each pattern is a cycle of timed phases. Box: in 4 s, hold 4, out 4, hold 4 (16 s, about 3.75 breaths a "
        "minute). 4-7-8: in 4, hold 7, out 8 (19 s, about 3.2 breaths a minute). Nadi shodhana: in through the left "
        "4, out through the right 6, in through the right 4, out through the left 6. Om: in 4, chant 8. The "
        "animation and countdown repeat the cycle for the minutes you choose.",
    science:
        "Here there is real evidence: slow breathing (about 6 breaths a minute or slower) raises heart-rate "
        "variability and lowers reported stress in many studies, and meditation programmes show moderate benefits "
        "for anxiety and low mood. The planetary theme is tradition only. Stop if you feel dizzy, and ask a doctor "
        "first if you have a medical condition.",
  ),
  'journal': ToolGuideText(
    title: "Journal and mood",
    what: "A private journal of mood and energy that also records the Moon's tithi, nakshatra and sign for each day.",
    why:
        "To notice your own patterns over time, and to test for yourself whether the Moon's phase relates to your "
        "mood.",
    how:
        "Each entry stores mood and energy on a 1–5 scale, tags and a note, plus a snapshot of the sky computed "
        "with Swiss Ephemeris. The chart plots mood over time with full and new moons marked. After enough entries, "
        "insights show simple averages: mood in Shukla paksha (waxing Moon) versus Krishna paksha (waning Moon), by "
        "the Moon's element, and by weekday. Everything stays on your phone unless you export it.",
    science:
        "Writing about feelings has measurable benefits in research (Pennebaker 1997). A difference between "
        "averages is a correlation, not proof: with few entries, chance differences are common, and a large "
        "meta-analysis found no reliable lunar effect on behaviour (Rotton & Kelly 1985).",
  ),
  'remedies': ToolGuideText(
    title: "Remedies (Upayas)",
    what:
        "Traditional remedies for each planet and dosha (mantras, charity, fasting, colours, gemstones, "
        "rudraksha, yantra and lifestyle), suggestions for your chart, and a list of classical books.",
    why: "People turn to remedies for comfort, discipline and spiritual practice in hard times.",
    how:
        "The For you list uses simple, open rules: the lords of your running Vimshottari Mahadasha and Antardasha, "
        "debilitated planets, a running Sade Sati and, for adults, Mangal dosha. Each suggestion states its reason. "
        "Planet and dosha pages list the traditional remedies with their sources; mantras keep their original "
        "Devanagari and IAST text in every language.",
    science:
        "No controlled study shows that gemstones, mantras or rituals change planetary effects or outcomes. "
        "Charity, routine, prayer and meditation can still have real personal and social value. Never spend beyond "
        "your means or delay medical, legal or financial help because of a remedy; gemstones are optional.",
  ),
  'rectification': ToolGuideText(
    title: "Birth time rectification",
    what:
        "A helper that estimates your birth time when you know it only roughly, by testing which times best fit "
        "your major life events.",
    why:
        "Many people do not know their exact birth time, and the Lagna changes sign about every two hours, which "
        "changes the houses.",
    how:
        "The app casts charts across your time range and groups the times into spans that share the same Lagna, "
        "Navamsa (D9) Lagna and Dasamsa (D10) Lagna. For each event you enter (marriage, child, job, move …) it "
        "checks whether the Vimshottari Mahadasha, Antardasha and Pratyantardasha lords running on that date "
        "signify the event's houses (by occupying or owning them from the candidate Lagna) or are its natural "
        "karaka, and whether transiting Jupiter and Saturn occupy or aspect those houses. Spans are scored, and the "
        "middle of the best span is suggested.",
    science:
        "The search is systematic and open, but its rules are traditional and several spans may score about the "
        "same. A birth certificate or hospital record is always better. Treat the result as an estimate.",
  ),
  'ai_guide': ToolGuideText(
    title: "Ask Drishti (AI guide)",
    what: "A question-and-answer guide that explains your chart in plain language and runs on your phone.",
    why: "To get explanations without learning every term, and to ask follow-up questions privately.",
    how:
        "First the app builds a fact sheet from your chart: positions, houses, dashas, yogas, strengths and "
        "transits. Each question is matched to its topic houses and karakas (for example career: the 10th house, "
        "Sun and Saturn). If you install the optional language model (a small fine-tuned Qwen2.5 model with 0.5 or "
        "1.5 billion parameters, 4-bit quantised, run on the phone with llama.cpp), it writes the answer from those "
        "facts and cites them; without it, a rule-based answerer uses the same facts. Tap Why? to see the chart "
        "reasons.",
    science:
        "A language model predicts likely text and can make mistakes (\"hallucinate\"), which is why answers are tied "
        "to facts you can check. The chart facts are exact; their astrological meaning is traditional and not "
        "scientifically validated. For health, legal, money or crisis matters, please talk to a qualified person.",
  ),
  'profiles': ToolGuideText(
    title: "Profiles and birth details",
    what: "Saved people with name, birth date, time and place, used by every chart tool.",
    why:
        "Accurate birth data is the foundation of every calculation, and profiles keep family and friends in one "
        "place.",
    how:
        "Places come from an offline GeoNames database of towns and cities with their latitude, longitude and "
        "time zone, so search works without internet. The local birth time is converted to UTC with the historical "
        "rules of the IANA time-zone database for that date, including past daylight-saving changes. You can mark "
        "the time as exact, approximate or unknown; without a time, tools that need the Lagna are hidden and "
        "Moon-based tools are used. Profiles stay on your phone.",
    science:
        "Correct time zones matter: a one-hour error moves the Ascendant by about 15°. The IANA database is the "
        "same one used by phones and computers worldwide. If no time was recorded, no calculation can recover it "
        "exactly.",
  ),
  'share_qr': ToolGuideText(
    title: "Share and scan profiles",
    what: "Share a profile's birth details as a QR code or a text code, and scan or paste one to add a profile.",
    why: "A quick way to move a profile between phones without accounts or servers.",
    how:
        "The profile (name, date, time, place and time zone) is written as JSON, encoded with base64url, prefixed "
        "with DRISHTI1: and drawn as a QR code. QR codes use Reed–Solomon error correction, so they still scan "
        "when slightly damaged. Scanning reverses the steps and checks the data before saving.",
    science:
        "This is pure encoding, with no astrology involved. The code is not encrypted: anyone who sees it can read "
        "the birth details, so share it only with people you trust.",
  ),
};
