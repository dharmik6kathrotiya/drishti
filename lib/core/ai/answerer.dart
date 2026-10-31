import '../astro/constants.dart';
import '../astro/vedic/dasha.dart';
import '../i18n/engine_texts.dart';
import 'explain_service.dart';
import 'explain_texts.dart';
import 'fact_render.dart';
import 'fact_sheet.dart';
import 'fact_texts.dart';
import 'safety.dart';

enum Intent {
  career,
  money,
  relationships,
  health,
  education,
  travel,
  children,
  property,
  spirituality,
  personality,
  general,
}

/// Topic rules: houses and natural significators (karakas) per intent.
class IntentRule {
  const IntentRule(this.houses, this.karakas, this.label);
  final List<int> houses;
  final List<Planet> karakas;

  /// English label; translated labels come from the `intent.*` phrases.
  final String label;
}

const intentRules = {
  Intent.career: IntentRule([10, 6, 11], [Planet.sun, Planet.saturn, Planet.mercury], 'career and work'),
  Intent.money: IntentRule([2, 11, 5, 9], [Planet.jupiter, Planet.venus], 'money and gains'),
  Intent.relationships: IntentRule([7, 2, 11], [Planet.venus, Planet.jupiter], 'relationships and marriage'),
  Intent.health: IntentRule([1, 6, 8], [Planet.sun, Planet.moon], 'general vitality'),
  Intent.education: IntentRule([4, 5, 9], [Planet.mercury, Planet.jupiter], 'education and learning'),
  Intent.travel: IntentRule([9, 12, 3], [Planet.rahu, Planet.moon], 'travel and life abroad'),
  Intent.children: IntentRule([5, 9], [Planet.jupiter], 'children'),
  Intent.property: IntentRule([4, 11], [Planet.mars, Planet.venus, Planet.saturn], 'home and property'),
  Intent.spirituality: IntentRule([9, 12, 5], [Planet.jupiter, Planet.ketu], 'spirituality'),
  Intent.personality: IntentRule([1], [Planet.sun, Planet.moon], 'personality'),
  Intent.general: IntentRule([1, 10, 7], [Planet.moon], 'life in general'),
};

class DetectedQuestion {
  const DetectedQuestion(this.intent, {required this.asksTiming});
  final Intent intent;
  final bool asksTiming;
}

/// English and romanised Indian-language keywords (matched with a leading
/// space so they start a word).
const _latinKeywords = <Intent, List<String>>{
  Intent.relationships: [
    ' marr',
    ' wedding',
    ' spouse',
    ' husband',
    ' wife',
    ' partner',
    ' love',
    ' relationship',
    ' shaadi',
    ' shadi',
    ' vivah',
    ' rishta',
    ' boyfriend',
    ' girlfriend',
    ' pyaar',
    ' pyar',
    ' kalyanam',
    ' thirumanam',
    ' pelli',
    ' maduve',
    ' biye',
    ' biya',
    ' lagnacha',
    ' prem ',
  ],
  Intent.career: [
    ' job',
    ' career',
    ' work',
    ' promotion',
    ' business',
    ' naukri',
    ' naukari',
    ' kaam',
    ' vyapar',
    ' office',
    ' boss',
    ' profession',
    ' nokri',
    ' velai',
    ' udyogam',
    ' udyog',
    ' kelasa',
    ' joli',
    ' chakri',
    ' vyavasay',
  ],
  Intent.money: [
    ' money',
    ' wealth',
    ' income',
    ' finance',
    ' rich',
    ' salary',
    ' paisa',
    ' paise',
    ' dhan',
    ' loan',
    ' debt',
    ' karz',
    ' panam',
    ' dabbu',
    ' hana ',
    ' taka',
    ' poisa',
    ' sampatti',
  ],
  Intent.health: [
    ' health',
    ' sick',
    ' ill',
    ' disease',
    ' sehat',
    ' swasthya',
    ' energy',
    ' fitness',
    ' bimar',
    ' arogya',
    ' tabiyat',
    ' tabyet',
  ],
  Intent.education: [
    ' study',
    ' studies',
    ' exam',
    ' education',
    ' college',
    ' degree',
    ' padhai',
    ' school',
    ' learning',
    ' result',
    ' padippu',
    ' chaduvu',
    ' pariksha',
    ' porashona',
    ' shikshan',
    ' abhyas',
  ],
  Intent.travel: [
    ' abroad',
    ' foreign',
    ' travel',
    ' visa',
    ' videsh',
    ' settle',
    ' relocat',
    ' move to',
    ' pardes',
    ' videsam',
    ' velinadu',
    ' bidesh',
    ' pravas',
    ' yatra',
  ],
  Intent.children: [
    ' child',
    ' children',
    ' baby',
    ' kids',
    ' santan',
    ' bachch',
    ' son ',
    ' daughter',
    ' kuzhandai',
    ' pillalu',
    ' makkalu',
    ' kutti',
    ' santhanam',
  ],
  Intent.property: [
    ' house',
    ' home',
    ' property',
    ' land',
    ' flat',
    ' apartment',
    ' ghar',
    ' makaan',
    ' makan',
    ' zameen',
    ' vehicle',
    ' car ',
    ' veedu',
    ' illu',
    ' mane ',
    ' bari ',
    ' jameen',
  ],
  Intent.spirituality: [
    ' spiritual',
    ' god',
    ' meditat',
    ' moksha',
    ' dharma',
    ' adhyatm',
    ' bhakti',
    ' karma',
    ' purpose',
    ' dhyan',
  ],
  Intent.personality: [
    ' personality',
    ' nature',
    ' who am i',
    ' strength',
    ' weakness',
    ' swabhav',
    ' character',
    ' about me',
    ' swabhavam',
    ' gunam',
  ],
};

/// Native-script keywords for hi, mr, bn, ta, te, kn and ml (plain substrings,
/// since Indic letters are not regex word characters).
const _nativeKeywords = <Intent, List<String>>{
  Intent.relationships: [
    'शादी',
    'विवाह',
    'पति',
    'पत्नी',
    'प्रेम',
    'प्यार',
    'रिश्ता',
    'जीवनसाथी',
    'लग्न कधी',
    'लग्नाचा',
    'नवरा',
    'बायको',
    'বিয়ে',
    'বিবাহ',
    'প্রেম',
    'স্বামী',
    'স্ত্রী',
    'திருமணம்',
    'கல்யாணம்',
    'காதல்',
    'கணவர்',
    'மனைவி',
    'పెళ్లి',
    'పెళ్ళి',
    'వివాహం',
    'ప్రేమ',
    'భర్త',
    'భార్య',
    'ಮದುವೆ',
    'ವಿವಾಹ',
    'ಪ್ರೀತಿ',
    'ಗಂಡ',
    'ಹೆಂಡತಿ',
    'വിവാഹം',
    'കല്യാണം',
    'പ്രണയം',
    'ഭർത്താവ്',
    'ഭാര്യ',
  ],
  Intent.career: [
    'नौकरी',
    'नोकरी',
    'करियर',
    'व्यापार',
    'व्यवसाय',
    'पदोन्नति',
    'प्रमोशन',
    'धंदा',
    'काम',
    'চাকরি',
    'ব্যবসা',
    'কর্মজীবন',
    'পেশা',
    'வேலை',
    'தொழில்',
    'உத்தியோகம்',
    'பதவி உயர்வு',
    'ఉద్యోగం',
    'ఉద్యోగ',
    'వ్యాపారం',
    'కెరీర్',
    'ಉದ್ಯೋಗ',
    'ಕೆಲಸ',
    'ವ್ಯಾಪಾರ',
    'ವೃತ್ತಿ',
    'ജോലി',
    'തൊഴിൽ',
    'ഉദ്യോഗം',
    'ബിസിനസ്',
  ],
  Intent.money: [
    'पैसा',
    'पैसे',
    'धन',
    'कमाई',
    'आमदनी',
    ' आय ',
    'वेतन',
    'कर्ज',
    'ऋण',
    'पगार',
    'টাকা',
    'উপার্জন',
    'রোজগার',
    'বেতন',
    'ঋণ',
    'பணம்',
    'செல்வம்',
    'வருமானம்',
    'சம்பளம்',
    'கடன்',
    'డబ్బు',
    'ధనం',
    'ఆదాయం',
    'జీతం',
    'అప్పు',
    'ಹಣ',
    'ಸಂಪತ್ತು',
    'ಆದಾಯ',
    'ಸಂಬಳ',
    'ಸಾಲ',
    'പണം',
    'സമ്പത്ത്',
    'വരുമാനം',
    'ശമ്പളം',
    'കടം',
  ],
  Intent.health: [
    'स्वास्थ्य',
    'सेहत',
    'तबीयत',
    'तब्येत',
    'आरोग्य',
    'স্বাস্থ্য',
    'শরীর',
    'ஆரோக்கியம்',
    'உடல்நலம்',
    'உடல் நலம்',
    'ఆరోగ్యం',
    'ఆరోగ్య',
    'ಆರೋಗ್ಯ',
    'ആരോഗ്യം',
  ],
  Intent.education: [
    'पढ़ाई',
    'पढाई',
    'शिक्षा',
    'परीक्षा',
    'परीक्षे',
    'कॉलेज',
    'अभ्यास',
    'शिक्षण',
    'পড়াশোনা',
    'শিক্ষা',
    'পরীক্ষা',
    'படிப்பு',
    'படிக்க',
    'கல்வி',
    'தேர்வ',
    'பரீட்சை',
    'చదువు',
    'విద్య',
    'పరీక్ష',
    'ಓದು',
    'ಶಿಕ್ಷಣ',
    'ಪರೀಕ್ಷೆ',
    'ವಿದ್ಯಾಭ್ಯಾಸ',
    'വിദ്യാഭ്യാസം',
    'പഠനം',
    'പരീക്ഷ',
  ],
  Intent.travel: [
    'विदेश',
    'परदेश',
    'यात्रा',
    'प्रवास',
    'বিদেশ',
    'ভ্রমণ',
    'வெளிநாடு',
    'வெளிநாட்',
    'பயணம்',
    'విదేశ',
    'ప్రయాణం',
    'ವಿದೇಶ',
    'ಪ್ರಯಾಣ',
    'വിദേശ',
    'യാത്ര',
  ],
  Intent.children: [
    'संतान',
    'बच्चे',
    'बच्चा',
    'बेटा',
    'बेटी',
    'मुलं',
    'अपत्य',
    'সন্তান',
    'বাচ্চা',
    'குழந்தை',
    'பிள்ளை',
    'సంతానం',
    'పిల్లలు',
    'ಮಕ್ಕಳು',
    'ಸಂತಾನ',
    'ಮಗು',
    'കുട്ടി',
    'സന്താന',
    'കുഞ്ഞ്',
  ],
  Intent.property: [
    'घर',
    'मकान',
    'जमीन',
    'ज़मीन',
    'संपत्ति',
    'प्रॉपर्टी',
    'वाहन',
    'गाड़ी',
    'फ्लैट',
    'जागा',
    'বাড়ি',
    'জমি',
    'সম্পত্তি',
    'গাড়ি',
    'வீடு',
    'நிலம்',
    'சொத்து',
    'வாகனம்',
    'ఇల్లు',
    'ఇంటి',
    'భూమి',
    'ఆస్తి',
    'వాహనం',
    'ಮನೆ',
    'ಭೂಮಿ',
    'ಆಸ್ತಿ',
    'ವಾಹನ',
    'വീട്',
    'ഭൂമി',
    'സ്വത്ത്',
    'വാഹനം',
  ],
  Intent.spirituality: [
    'आध्यात्म',
    'अध्यात्म',
    'भक्ति',
    'मोक्ष',
    'ध्यान',
    'धर्म',
    'আধ্যাত্মিক',
    'ভক্তি',
    'ধ্যান',
    'ஆன்மீகம்',
    'பக்தி',
    'தியானம்',
    'ఆధ్యాత్మిక',
    'భక్తి',
    'ధ్యానం',
    'ಆಧ್ಯಾತ್ಮ',
    'ಭಕ್ತಿ',
    'ಧ್ಯಾನ',
    'ആത്മീയ',
    'ഭക്തി',
    'ധ്യാനം',
  ],
  Intent.personality: [
    'स्वभाव',
    'व्यक्तित्व',
    'मेरे बारे में',
    'माझ्याबद्दल',
    'माझा स्वभाव',
    'স্বভাব',
    'ব্যক্তিত্ব',
    'আমার সম্পর্কে',
    'குணம்',
    'சுபாவம்',
    'ஆளுமை',
    'స్వభావం',
    'వ్యక్తిత్వం',
    'ಸ್ವಭಾವ',
    'ವ್ಯಕ್ತಿತ್ವ',
    'സ്വഭാവം',
    'വ്യക്തിത്വം',
  ],
};

const _timingLatin = [
  ' when ',
  ' kab ',
  ' which year',
  ' what age',
  ' how soon',
  ' time for ',
  ' timing',
  ' eppo',
  ' eppudu',
  ' yavaga',
  ' kobe ',
  ' kadhi ',
  ' kevha ',
  ' eppol',
];

/// Matched at a word start only ("কবে" must not match inside "থাকবে").
const _timingNative = ['कब', 'कधी', 'केव्हा', 'কবে', 'কখন', 'எப்போது', 'எப்போ', 'ఎప్పుడు', 'ಯಾವಾಗ', 'എപ്പോൾ', 'എന്ന്'];

/// Keyword intent detection for English, romanised Indian languages and the
/// seven supported Indian scripts.
DetectedQuestion detectIntent(String question) {
  final q = ' ${question.toLowerCase()} ';
  bool has(List<String> words) => words.any(q.contains);
  final timing = has(_timingLatin) || _timingNative.any((w) => q.contains(' $w'));
  for (final intent in _latinKeywords.keys) {
    if (has(_latinKeywords[intent]!) || has(_nativeKeywords[intent] ?? const [])) {
      return DetectedQuestion(intent, asksTiming: timing);
    }
  }
  return DetectedQuestion(Intent.general, asksTiming: timing);
}

/// One factor an answer was based on.
class AnswerFactor {
  const AnswerFactor(this.fact, this.explanation, this.source, {this.factId});
  final String fact;
  final String explanation;
  final String source;

  /// Fact sheet id this factor rests on, when there is one (used to teach the
  /// model its citations).
  final String? factId;
}

class AiAnswer {
  const AiAnswer({
    required this.text,
    this.factors = const [],
    this.notes = const [],
    this.improveWith = const [],
    this.fromModel = false,
    this.safetyResponse = false,
    this.detailed = true,
    this.why,
    this.tone,
    this.exact = false,
    this.keyPoints,
  });

  /// What a short answer must say (verdict, life areas, the running period),
  /// given to the model to put in words. Not saved.
  final String? keyPoints;

  final String text;

  /// The text states calculated details (positions, dignities, dates,
  /// periods, lifespan spans) that must reach the user word for word, so the
  /// model does not reword it. Not saved: it only steers [AskEngine].
  final bool exact;

  /// Chart reasons behind a short answer (planets, houses, periods), shown
  /// only when the user taps "Why?".
  final String? why;

  /// How the classical rules used here read the topic of a short answer:
  /// 1 favourable, 0 mixed, -1 needs more effort.
  final int? tone;
  final List<AnswerFactor> factors;

  /// Caveats and professional referrals.
  final List<String> notes;

  /// Missing birth details that would improve the answer.
  final List<String> improveWith;
  final bool fromModel;

  /// True when the answer is a safety response (crisis, teen-mode limits).
  final bool safetyResponse;

  /// False for the default short answer, which the user can expand.
  final bool detailed;

  /// [text] without the fact-id citations ("[planet.saturn]"), which are for
  /// checking the answer, not for reading.
  String get displayText => stripCitations(text);

  /// Fact ids this answer rests on, given to the model as its FOCUS FACTS:
  /// the citations, plus the first supporting facts of a detailed answer
  /// (the ones its training target lists).
  List<String> get focusIds =>
      {...citedIds(text), if (detailed) ...factors.map((f) => f.factId).nonNulls.take(3)}.toList();

  Map<String, dynamic> toJson() => {
    'text': text,
    'factors': [
      for (final f in factors)
        {'fact': f.fact, 'explanation': f.explanation, 'source': f.source, if (f.factId != null) 'factId': f.factId},
    ],
    'notes': notes,
    'improveWith': improveWith,
    'fromModel': fromModel,
    'detailed': detailed,
    if (why != null) 'why': why,
    if (tone != null) 'tone': tone,
  };

  factory AiAnswer.fromJson(Map json) => AiAnswer(
    text: json['text'] as String,
    factors: [
      for (final f in (json['factors'] as List? ?? const []))
        AnswerFactor(
          f['fact'] as String,
          f['explanation'] as String,
          f['source'] as String,
          factId: f['factId'] as String?,
        ),
    ],
    notes: [for (final n in (json['notes'] as List? ?? const [])) n as String],
    improveWith: [for (final n in (json['improveWith'] as List? ?? const [])) n as String],
    fromModel: (json['fromModel'] as bool?) ?? false,
    detailed: (json['detailed'] as bool?) ?? true,
    why: json['why'] as String?,
    tone: json['tone'] as int?,
  );
}

/// Removes fact-id citations such as " [planet.saturn]" from answer text.
String stripCitations(String text) =>
    text.replaceAll(RegExp(r' ?\[[a-z0-9_.]+\]'), '').replaceAll(RegExp(r' +([.,।])'), r'$1');

/// Fact ids cited in [text], in order, each once.
List<String> citedIds(String text) =>
    RegExp(r'\[([a-z0-9_.]+)\]').allMatches(text).map((m) => m.group(1)!).toSet().toList();

final _detailWords = RegExp(
  r'\b(detail|detailed|details|in depth|elaborate|explain more|tell me more|full reading|all planets|everything|long answer)\b'
  r'|vistar|vistaar|detail me|विस्तार|सब ग्रह|सविस्तर|तपशील|সব গ্রহ|বিস্তারিত|விரிவாக|விரிவான|వివరంగా|వివరమైన|ವಿವರವಾಗಿ|ವಿಸ್ತಾರವಾಗಿ|വിശദമായി|വിശദമായ',
  caseSensitive: false,
);

/// True when the user asks for a long, detailed answer ("explain in detail",
/// "विस्तार से बताइए"). Answers are short otherwise.
bool asksForDetail(String question) => _detailWords.hasMatch(question);

final _dashaWords = RegExp(
  r'\b(dasha|dasa|mahadasha|antardasha)\b|दशा|दशे|দশা|தசை|దశ|ದಶೆ|ದಶಾ|ദശ',
  caseSensitive: false,
);

/// Answers questions using only the fact sheet and the explanation library.
/// Used when no model is installed and as the safety fallback for the model.
class RuleBasedAnswerer {
  RuleBasedAnswerer([this.languageCode = 'en'])
    : explain = ExplainService(languageCode),
      t = FallbackTexts(explainTextsFor(languageCode)),
      fr = FactRenderer(languageCode),
      ft = FactTexts(languageCode),
      et = EngineTexts.of(languageCode);

  final String languageCode;
  final ExplainService explain;
  final FallbackTexts t;

  /// Localized fact lines and answer sentences.
  final FactRenderer fr;
  final FactTexts ft;
  final EngineTexts et;

  /// Returns a safety response if the question needs one, else null. Messages
  /// are in [languageCode] (English by default).
  static AiAnswer? safetyGate(String question, {required bool teen, String languageCode = 'en'}) {
    final t = FallbackTexts(explainTextsFor(languageCode));
    if (Safety.isCrisis(question)) {
      return AiAnswer(text: t.phrase('safety.crisis'), safetyResponse: true);
    }
    if (teen) {
      if (Safety.asksDeath(question)) {
        return AiAnswer(text: t.phrase('teenLongevity'), safetyResponse: true);
      }
      final i = detectIntent(question).intent;
      if (i == Intent.relationships || i == Intent.children) {
        return AiAnswer(text: t.phrase('teenRelationships'), safetyResponse: true);
      }
      if (i == Intent.health) {
        return AiAnswer(text: t.phrase('teenHealth'), safetyResponse: true);
      }
    }
    return null;
  }

  /// [safetyGate] in this answerer's language.
  AiAnswer? gate(String question, {required bool teen}) => safetyGate(question, teen: teen, languageCode: languageCode);

  /// The full reading when [detailed], otherwise a short answer to just what
  /// was asked, with its fact ids cited inline (see [AiAnswer.displayText]).
  AiAnswer answer(String question, FactSheet sheet, {bool teen = false, bool detailed = true}) {
    final g = gate(question, teen: teen);
    if (g != null) return g;
    if (Safety.asksDeath(question)) return _longevity(sheet, detailed: detailed);

    final detected = detectIntent(question);
    final rule = intentRules[detected.intent]!;
    final label = t.phrase('intent.${detected.intent.name}');
    final chart = sheet.chart;
    final vedic = sheet.vedic;
    final factors = <AnswerFactor>[];
    final paras = <String>[];
    final personal = detected.intent == Intent.personality || detected.intent == Intent.general;
    // The short answer: only the paragraphs that answer the question, each
    // followed by the ids of the facts it uses.
    final short = <String>[];
    String? dashaShort;
    String? timingShort;
    String? timingOutcome;
    // What to expect, in plain words (the short answer), and the chart
    // reasons behind it (shown under "Why?").
    final outcome = <String>[];
    final reasons = <String>[];
    String cite(String text, Iterable<String> ids) => [
      text,
      for (final id in ids)
        if (sheet.byId(id) != null) '[$id]',
    ].join(' ');

    String pn(Planet p) => fr.planet(p);
    String sn(Sign s) => fr.sign(s, vedic: vedic);
    String fact(String id) => fr.render(sheet.byId(id)!, sheet);
    String inHouse(Planet p) {
      final h = chart[p].house;
      return h == null ? '' : ft.t('b.inHouse', {'ord': t.ordinal(h)});
    }

    String withDignity(String sentence, Planet p, Sign s) {
      final d = explain.dignity(p, s);
      return d.isEmpty ? sentence : '$sentence $d';
    }

    paras.add(t.fill('ansIntro', {'label': label}));

    // ---- Body: the few most relevant concrete facts, in plain language.
    if (personal) {
      final asc = chart.ascendantSign;
      if (asc != null) {
        final lp = chart[asc.lord];
        final para = withDignity(
          ft.t(vedic ? 'b.asc' : 'b.ascW', {
            'sign': sn(asc),
            'lord': pn(asc.lord),
            'lordSign': sn(lp.sign),
            'lordHouse': inHouse(asc.lord),
          }),
          asc.lord,
          lp.sign,
        );
        paras.add(para);
        short.add(cite(para, ['ascendant']));
      }
      final m = chart.moon;
      final moonPara =
          '${ft.t('b.moon', {
            'sign': sn(m.sign),
            'nak': vedic ? ft.t('b.moonNak', {'nak': fr.names.nakshatra(m.nakshatra.index)}) : '',
          })} ${t.signNature(m.sign)}';
      paras.add(moonPara);
      short.add(cite(moonPara, ['moon.sign', if (vedic) 'nakshatra']));
      reasons.addAll(short);
      outcome.add(
        cite(
          asc == null
              ? ft.t('o.natureMoon', {'moon': _traits(m.sign)})
              : ft.t('o.nature', {'asc': _traits(asc), 'moon': _traits(m.sign)}),
          [if (asc != null) 'ascendant', 'moon.sign'],
        ),
      );
    } else if (sheet.hasHouses) {
      final h = rule.houses.first;
      final lord = chart.houseLord(h)!;
      final lp = chart[lord];
      final occupants = chart.inHouse(h).map((p) => pn(p.planet)).toList();
      final houseSentence = ft.t('b.house', {
        'ord': t.ordinal(h),
        'topic': label,
        'sign': sn(chart.houseSign(h)!),
        'lord': pn(lord),
        'lordSign': sn(lp.sign),
        'lordHouse': inHouse(lord),
      });
      final lordArea = lp.house == null
          ? ''
          : ft.t('b.lordArea', {'ord': t.ordinal(lp.house!), 'text': _area(lp.house!, vedic), 'topic': label});
      final para = [
        houseSentence,
        occupants.isEmpty ? ft.t('b.noOcc') : ft.t('b.occ', {'list': occupants.join(', ')}),
        lordArea,
        explain.dignity(lord, lp.sign),
      ].where((s) => s.isNotEmpty).join(' ');
      paras.add(para);
      reasons.add(para);
      // Short: where the topic's house lord sits and what that means.
      short.add(cite([houseSentence, lordArea].where((s) => s.isNotEmpty).join(' '), ['planet.${lord.name}']));
    }
    if (!sheet.hasHouses) {
      paras.add(ft.t('b.noHouses'));
      short.add(ft.t('b.noHouses'));
      if (!personal) reasons.add(ft.t('b.noHouses'));
    }

    if (!personal) {
      final k = rule.karakas.where((k) => chart.planets[k] != null).firstOrNull;
      if (k != null) {
        final pl = chart[k];
        final para = withDignity(
          ft.t('b.karaka', {'planet': pn(k), 'topic': label, 'sign': sn(pl.sign), 'house': inHouse(k)}),
          k,
          pl.sign,
        );
        paras.add(para);
        reasons.add(para);
        // Without houses the significator is the main answer.
        if (!sheet.hasHouses) short.add(cite(para, ['planet.${k.name}']));
      }
    }

    // Current period and its link to the topic.
    String? nowOutcome;
    if (sheet.running.length >= 2) {
      final maha = sheet.running[0], antar = sheet.running[1];
      final linked = [
        for (final d in {maha.lord, antar.lord})
          if (_connects(sheet, d, rule)) d,
      ];
      final para = [
        ft.t('b.dasha', {'maha': pn(maha.lord), 'antar': pn(antar.lord), 'date': ft.monthYear(antar.end)}),
        if (linked.isEmpty) t.phrase('dashaNotLinked'),
        for (final (i, p) in linked.indexed)
          ft.t(i == 0 ? 'b.dashaLink' : 'b.dashaLink2', {
            'planet': pn(p),
            'topic': label,
            'parts': _connectionParts(sheet, p, rule),
          }),
      ].join(' ');
      paras.add(para);
      dashaShort = cite(para, ['dasha.1', 'dasha.${antar.level}']);
      if (!personal) {
        reasons.add(para);
        nowOutcome = cite(
          ft.t(linked.isEmpty ? 'o.nowQuiet' : 'o.nowActive', {'topic': label, 'date': ft.monthYear(antar.end)}),
          ['dasha.1', 'dasha.${antar.level}'],
        );
      }

      final de = explain.explain(DashaTopic(antar, chart: chart));
      factors.add(
        AnswerFactor(
          t.fill('runningPeriod', {'maha': pn(maha.lord), 'antar': pn(antar.lord), 'date': ft.monthYear(antar.end)}),
          [de.paragraphs.first, if (de.paragraphs.length > 1) de.paragraphs[1]].join(' '),
          de.source,
          factId: 'dasha.${antar.level}',
        ),
      );
    }

    // The short answer to a topic question: how it looks, what shapes it and
    // whether now is an active time for it, without positions.
    int? tone;
    if (!personal) {
      final lord = sheet.hasHouses ? chart.houseLord(rule.houses.first) : null;
      final k = rule.karakas.where((k) => chart.planets[k] != null).firstOrNull;
      tone = _tone(sheet, rule);
      outcome.add(
        cite(ft.t(tone > 0 ? 'o.good' : (tone < 0 ? 'o.hard' : 'o.mixed'), {'topic': label}), [
          if (lord != null) 'planet.${lord.name}',
          if (k != null) 'planet.${k.name}',
        ]),
      );
      final lordHouse = lord == null ? null : chart[lord].house;
      if (lordHouse != null) outcome.add(ft.t('o.themes', {'text': _area(lordHouse, vedic)}));
      if (nowOutcome != null) outcome.add(nowOutcome);
    }

    // ---- Factors: the full basis, each with its source.
    if (personal) {
      if (chart.ascendantSign != null) {
        final e = explain.explain(AscendantTopic(chart.ascendantSign!, vedic: vedic));
        factors.add(AnswerFactor(fact('ascendant'), e.paragraphs.skip(1).join(' '), e.source, factId: 'ascendant'));
      }
      factors.add(
        AnswerFactor(
          fact('moon.sign'),
          '${t.signNature(chart.moon.sign)} ${t.phrase('moonSignDescribes')}',
          t.phrase('classicalSigns'),
          factId: 'moon.sign',
        ),
      );
      if (vedic) {
        final n = explain.explain(NakshatraTopic(chart.moon.nakshatra, pada: chart.moon.pada));
        factors.add(AnswerFactor(fact('nakshatra'), n.paragraphs.first, n.source, factId: 'nakshatra'));
      }
    }

    // Houses of the topic: occupants and lords.
    if (sheet.hasHouses) {
      for (final h in rule.houses.take(2)) {
        final lord = chart.houseLord(h)!;
        final lordPl = chart[lord];
        final occupants = chart.inHouse(h).map((p) => pn(p.planet)).toList();
        final factText = t.fill('houseFact', {
          'h': '$h',
          'lord': pn(lord),
          'sign': sn(lordPl.sign),
          'house': lordPl.house == null ? '' : t.fill('houseSuffix', {'n': '${lordPl.house}'}),
          'occupants': occupants.isEmpty ? t.phrase('noPlanets') : t.fill('occupiedBy', {'list': occupants.join(', ')}),
        });
        final dign = explain.dignity(lord, lordPl.sign);
        factors.add(
          AnswerFactor(
            factText,
            '${t.houseNature(h, vedic: vedic)} ${dign.isEmpty ? '' : dign}'.trim(),
            t.phrase('houseSource'),
          ),
        );
      }
    }

    // Natural significators of the topic.
    for (final k in rule.karakas.take(2)) {
      final pl = chart.planets[k];
      if (pl == null) continue;
      final dign = explain.dignity(k, pl.sign);
      factors.add(
        AnswerFactor(
          fact('planet.${k.name}'),
          '${t.fill('naturalSignificator', {'planet': pn(k), 'label': label})} ${dign.isEmpty ? '' : dign}'.trim(),
          t.phrase('signSource'),
          factId: 'planet.${k.name}',
        ),
      );
    }

    // Related yogas.
    final yogaIds = FactSheet.yogaIds(sheet.yogas);
    for (final (i, y) in sheet.yogas.indexed) {
      final related = y.planets.any((p) => rule.karakas.contains(p) || sheet.housesOf(p).any(rule.houses.contains));
      if (related) {
        factors.add(
          AnswerFactor(
            et.yogaName(y),
            '${et.yogaReason(y)} ${et.yogaMeaning(y)}',
            et.yogaSource(y),
            factId: yogaIds[i],
          ),
        );
      }
    }
    if (detected.intent == Intent.relationships) {
      for (final d in sheet.doshas.where((d) => d.present)) {
        factors.add(
          AnswerFactor(
            et.doshaName(d),
            '${et.doshaSummary(d)} ${et.doshaMitigations(d).join(' ')}'.trim(),
            et.doshaSource(d),
            factId: 'dosha.${FactSheet.slug(d.name)}',
          ),
        );
      }
    }

    // Timing questions: upcoming Antardashas whose lords relate to the topic.
    if (detected.asksTiming && vedic) {
      final supportive = sheet.upcomingAntardashas
          .where((a) => _connects(sheet, a.lord, rule) && a.end.isAfter(sheet.generatedAt))
          .take(3)
          .toList();
      if (supportive.isNotEmpty) {
        final list = supportive
            .map(
              (a) => t.fill('periodRange', {
                'maha': pn(a.parent?.lord ?? a.lord),
                'antar': pn(a.lord),
                'from': ft.monthYear(a.start),
                'to': ft.monthYear(a.end),
              }),
            )
            .join('; ');
        final ids = [for (final a in supportive) 'period.${sheet.upcomingAntardashas.indexOf(a) + 1}'];
        paras.add(cite(t.fill('timingWindows', {'label': label, 'list': list}), ids));
        // The short answer gives the dates only; the periods' planets are the "why".
        timingOutcome = cite(
          ft.t('o.windows', {
            'topic': label,
            'list': _mergeRanges([for (final a in supportive) (a.start, a.end)])
                .map((r) => ft.t('o.range', {'from': ft.monthYear(r.$1), 'to': ft.monthYear(r.$2)}))
                .join('; '),
          }),
          ids,
        );
      } else {
        paras.add(t.fill('timingNone', {'label': label}));
        timingOutcome = paras.last;
      }
      timingShort = paras.last;
    }

    // Relevant transits now.
    for (final f in [sheet.byId('transit.jupiter'), sheet.byId('transit.saturn')]) {
      if (f == null) continue;
      factors.add(
        AnswerFactor(
          fr.render(f, sheet),
          t.houseNature(f.house ?? 1, vedic: true),
          vedic ? t.phrase('transitSource') : f.source,
          factId: f.id,
        ),
      );
    }

    final notes = <String>[
      for (final k in Safety.referralKeysFor(question)) t.phrase(k),
      if (detected.intent == Intent.health) t.phrase('safety.medical'),
      t.phrase('caveat'),
      if (detected.intent == Intent.relationships) t.phrase('relationshipNote'),
    ];

    final improve = <String>[
      if (!sheet.profile.hasTime) t.phrase('improveTime'),
      if (!sheet.profile.hasPlace) t.phrase('improvePlace'),
    ];

    paras.add(t.phrase('factorsBelow'));

    if (!detailed) {
      // A question about the running period is answered by that period alone.
      // "When" questions get the timing, period questions the running period.
      // Everything else answers what to expect; the chart reasons go to "Why?".
      final timing = detected.asksTiming && timingShort != null;
      final period = !timing && _dashaWords.hasMatch(question) && dashaShort != null;
      final body = timing ? timingOutcome! : (period ? dashaShort : outcome.join(' '));
      final why = timing
          ? [if (!sheet.hasHouses) ft.t('b.noHouses'), if (timingShort != timingOutcome) timingShort]
          : (period ? <String>[] : reasons);
      return AiAnswer(
        text: [body, t.phrase('caveat')].join('\n\n'),
        factors: factors,
        notes: notes.where((n) => n != t.phrase('caveat')).toSet().toList(),
        improveWith: improve,
        detailed: false,
        why: why.isEmpty ? null : stripCitations(why.join('\n\n')),
        tone: timing || period ? null : tone,
        exact: timing || period,
        keyPoints: timing || period ? null : body,
      );
    }
    return AiAnswer(
      text: paras.join('\n\n'),
      factors: factors,
      notes: notes.toSet().toList(),
      improveWith: improve,
      exact: true,
    );
  }

  /// Lifespan questions: exactly what the classical calculation says for this
  /// chart, framed as a traditional method, with care suggestions. Nothing is
  /// softened or left out, and no date of death is ever given.
  AiAnswer _longevity(FactSheet sheet, {bool detailed = true}) {
    final notes = [t.phrase('safety.medical'), t.phrase('lifeSupport')];
    final r = sheet.longevity;
    if (r == null) return AiAnswer(text: t.phrase('lifeWestern'), notes: notes);

    String pn(Planet p) => fr.planet(p);
    String fact(String id) => fr.render(sheet.byId(id)!, sheet);
    final marakas = r.marakas.map(pn).join(', ');
    // Short answers drop only the pointer to the factor list: the framing,
    // the span, the periods, care and the caveat are always said.
    final ids = [for (final f in sheet.ofKind(FactKind.longevity)) f.id];
    final paras = [
      t.fill('lifeIntro', {'name': sheet.profile.name}),
      [
        fact('longevity.span'),
        if (r.pastSpan) t.phrase('lifePastNote'),
        if (!detailed) ...['[longevity.span]', if (ids.contains('longevity.pairs')) '[longevity.pairs]'],
      ].join(' '),
      if (r.span != null && !r.pastSpan && r.marakas.isNotEmpty)
        (r.sensitive.isEmpty
                ? t.fill('lifeMarakaNone', {'list': marakas})
                : t.fill('lifeMaraka', {
                    'list': marakas,
                    'periods': r.sensitive
                        .map(
                          (a) => t.fill('periodRange', {
                            'maha': pn(a.parent?.lord ?? a.lord),
                            'antar': pn(a.lord),
                            'from': ft.monthYear(a.start),
                            'to': ft.monthYear(a.end),
                          }),
                        )
                        .join('; '),
                  })) +
            (detailed
                ? ''
                : ' ${[for (final id in ids)
                    if (id.startsWith('maraka')) '[$id]'].join(' ')}'),
      t.phrase('lifeCare'),
      t.phrase('lifeCaveat'),
      if (detailed) t.phrase('factorsBelow'),
    ];
    return AiAnswer(
      detailed: detailed,
      exact: true,
      text: paras.join('\n\n'),
      factors: [
        for (final f in sheet.ofKind(FactKind.longevity))
          AnswerFactor(
            fr.render(f, sheet),
            t.phrase(f.id.startsWith('maraka') ? 'lifeExplainMaraka' : 'lifeExplainSpan'),
            f.source,
            factId: f.id,
          ),
      ],
      notes: notes,
      improveWith: [if (!sheet.profile.hasTime) t.phrase('improveTime')],
    );
  }

  /// Joins back-to-back periods into one date range.
  static List<(DateTime, DateTime)> _mergeRanges(List<(DateTime, DateTime)> ranges) {
    final out = <(DateTime, DateTime)>[];
    for (final r in ranges) {
      if (out.isNotEmpty && !r.$1.isAfter(out.last.$2.add(const Duration(days: 2)))) {
        out.last = (out.last.$1, r.$2.isAfter(out.last.$2) ? r.$2 : out.last.$2);
      } else {
        out.add(r);
      }
    }
    return out;
  }

  /// Traits part of a sign description ("… ruled by Mars: direct, pioneering
  /// and energetic." gives "direct, pioneering and energetic").
  /// Statements in a model's rewording of [rule] that the calculation did not
  /// make: a life area, sign traits, verdict, "now" status or year that is
  /// not in the engine's own answer. A small model mixes these up (eval v6:
  /// the wrong life area in 18 of 20 answers), so any such statement means
  /// the model's text is not shown.
  List<String> contradictions(String modelText, AiAnswer rule) {
    final out = <String>[];
    bool says(String text, String phrase) => phrase.isNotEmpty && text.toLowerCase().contains(phrase.toLowerCase());
    void check(String phrase, String what) {
      if (says(modelText, phrase) && !says(rule.text, phrase)) out.add('$what not in the calculation: $phrase');
    }

    // Every key point must be said as calculated: the verdict, the life area
    // and the running period are never left out or reworded.
    String norm(String s) => stripCitations(s).toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    final said = norm(modelText);
    for (final sentence in norm(rule.keyPoints ?? '').split(RegExp(r'(?<=[.।])\s+'))) {
      if (sentence.isNotEmpty && !said.contains(sentence)) out.add('key point missing: $sentence');
    }

    for (var h = 1; h <= 12; h++) {
      check(_area(h, true), 'life area');
      check(_area(h, false), 'life area');
    }
    for (final s in Sign.values) {
      check(_traits(s), 'sign traits');
    }
    for (final group in const [
      ['o.good', 'o.mixed', 'o.hard'],
      ['o.nowActive', 'o.nowQuiet'],
    ]) {
      for (final key in group) {
        check(_distinctive(key, group), key);
      }
    }
    for (final y in RegExp(r'\b(1[89]|2[01])\d\d\b').allMatches(modelText)) {
      check(y.group(0)!, 'year');
    }
    return out;
  }

  /// The longest literal part of template [key] that its [siblings] lack,
  /// e.g. "looks favourable" for 'o.good'.
  String _distinctive(String key, List<String> siblings) {
    const gap = '\u0000';
    String render(String k) => ft.t(k, {'topic': gap, 'date': gap});
    final others = [
      for (final k in siblings)
        if (k != key) render(k),
    ];
    final parts = [
      for (final p in render(key).split(gap))
        if (p.trim().length > 3 && !others.any((o) => o.contains(p.trim()))) p.trim(),
    ]..sort((a, b) => b.length.compareTo(a.length));
    return parts.firstOrNull ?? '';
  }

  String _traits(Sign s) {
    final d = t.signNature(s);
    final i = d.lastIndexOf(':');
    return (i >= 0 ? d.substring(i + 1) : d).trim().replaceAll(RegExp(r'[.।]\s*$'), '');
  }

  /// Classical strength of a planet in a sign: +2 exalted, moolatrikona or
  /// own sign, +1 a friend's sign, -1 an enemy's sign, -2 debilitated.
  int _dignityScore(Planet p, Sign s) {
    if (Dignity.exaltationSign(p) == s) return 2;
    if (Dignity.debilitationSign(p) == s) return -2;
    if (Dignity.moolatrikona[p] == s || s.lord == p) return 2;
    if (p.isNode || p.isOuter) return 0;
    return Dignity.naturalRelation(p, s.lord);
  }

  /// How the classical rules used here read a topic, from the reasons shown
  /// under "Why?": the topic house lord's dignity and house (kendra, trikona
  /// or 11th help, 6th, 8th and 12th strain), planets in the house (benefics
  /// help, malefics strain outside the 3rd, 6th, 10th and 11th) and the
  /// natural significator's dignity. 1 favourable, 0 mixed, -1 needs effort.
  int _tone(FactSheet sheet, IntentRule rule) {
    final chart = sheet.chart;
    final k = rule.karakas.where((k) => chart.planets[k] != null).firstOrNull;
    final karaka = k == null ? 0 : _dignityScore(k, chart[k].sign).clamp(-1, 1);
    if (!sheet.hasHouses) return karaka;
    final h = rule.houses.first;
    final lord = chart.houseLord(h)!;
    final lp = chart[lord];
    final place = switch (lp.house) {
      1 || 4 || 5 || 7 || 9 || 10 || 11 => 1,
      6 || 8 || 12 => -1,
      _ => 0,
    };
    const benefics = {Planet.jupiter, Planet.venus, Planet.mercury, Planet.moon};
    var occupants = 0;
    for (final p in chart.inHouse(h)) {
      if (benefics.contains(p.planet)) {
        occupants++;
      } else if (!p.planet.isOuter && !const {3, 6, 10, 11}.contains(h)) {
        occupants--;
      }
    }
    final score = _dignityScore(lord, lp.sign) + place + occupants.clamp(-1, 1) + karaka;
    return score >= 2 ? 1 : (score <= -1 ? -1 : 0);
  }

  bool _connects(FactSheet sheet, Planet p, IntentRule rule) =>
      rule.karakas.contains(p) || sheet.housesOf(p).any(rule.houses.contains);

  String _connectionParts(FactSheet sheet, Planet p, IntentRule rule) {
    final houses = sheet.housesOf(p).where(rule.houses.contains).toList()..sort();
    return [
      if (houses.isNotEmpty) t.fill(houses.length > 1 ? 'connHouses' : 'connHouse', {'list': houses.join(', ')}),
      if (rule.karakas.contains(p)) t.phrase('connKaraka'),
    ].join(', ');
  }

  /// Life areas of a house without its leading label ("12th house: ...").
  String _area(int house, bool vedic) {
    var s = t.houseNature(house, vedic: vedic);
    final i = s.indexOf(':');
    if (i >= 0 && i < 60) s = s.substring(i + 1).trim();
    return s.replaceAll(RegExp(r'[.।]\s*$'), '');
  }
}

/// Formats the running dasha chain for display.
String describeRunning(List<DashaPeriod> running) => running.map((d) => capitalize(d.lord.name)).join(' / ');
