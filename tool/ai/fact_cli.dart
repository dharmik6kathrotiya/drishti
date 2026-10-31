// Prints grounded training examples as JSON Lines: a fact sheet computed by
// Drishti's own engine for random birth data, questions in the app's eight
// languages, and target answers composed from the rule-based answerer. Labels
// therefore always come from our calculations, never from a model.
//
// Each line is one chart with several chat examples whose user message is
// built by the app's own buildGroundedPrompt, so training and runtime prompts
// are identical.
//
// Usage (from the project root):
//   dart run tool/ai/fact_cli.dart --count 3000 --seed 1 > tool/ai/out/facts.jsonl
//   dart run tool/ai/fact_cli.dart --check     # intent/safety routing of every question
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:drishti/core/ai/answerer.dart';
import 'package:drishti/core/ai/fact_sheet.dart';
import 'package:drishti/core/ai/prompt.dart';
import 'package:drishti/core/ai/safety.dart';
import 'package:drishti/core/astro/ephemeris.dart';
import 'package:drishti/core/astro/settings.dart';
import 'package:drishti/core/models/profile.dart';
import 'package:sweph/sweph.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

const _places = [
  Place(name: 'Mumbai', countryCode: 'IN', latitude: 19.0728, longitude: 72.8826, timezoneId: 'Asia/Kolkata'),
  Place(name: 'Delhi', countryCode: 'IN', latitude: 28.6139, longitude: 77.2090, timezoneId: 'Asia/Kolkata'),
  Place(name: 'Chennai', countryCode: 'IN', latitude: 13.0827, longitude: 80.2707, timezoneId: 'Asia/Kolkata'),
  Place(name: 'Kolkata', countryCode: 'IN', latitude: 22.5726, longitude: 88.3639, timezoneId: 'Asia/Kolkata'),
  Place(name: 'Ahmedabad', countryCode: 'IN', latitude: 23.0225, longitude: 72.5714, timezoneId: 'Asia/Kolkata'),
  Place(name: 'Pune', countryCode: 'IN', latitude: 18.5204, longitude: 73.8567, timezoneId: 'Asia/Kolkata'),
  Place(name: 'Hyderabad', countryCode: 'IN', latitude: 17.3850, longitude: 78.4867, timezoneId: 'Asia/Kolkata'),
  Place(name: 'Bengaluru', countryCode: 'IN', latitude: 12.9716, longitude: 77.5946, timezoneId: 'Asia/Kolkata'),
  Place(name: 'Kochi', countryCode: 'IN', latitude: 9.9312, longitude: 76.2673, timezoneId: 'Asia/Kolkata'),
  Place(name: 'London', countryCode: 'GB', latitude: 51.5074, longitude: -0.1278, timezoneId: 'Europe/London'),
  Place(name: 'New York', countryCode: 'US', latitude: 40.7128, longitude: -74.0060, timezoneId: 'America/New_York'),
  Place(name: 'Dubai', countryCode: 'AE', latitude: 25.2048, longitude: 55.2708, timezoneId: 'Asia/Dubai'),
  Place(name: 'Singapore', countryCode: 'SG', latitude: 1.3521, longitude: 103.8198, timezoneId: 'Asia/Singapore'),
];

/// Topic questions per app language. Romanised Hindi counts as Hindi.
const _questions = <String, List<String>>{
  'en': [
    'How does my chart look for career?',
    'When will I get married?',
    'Will I have good income?',
    'What does my chart say about my nature?',
    'Is studying abroad indicated?',
    'What does my current dasha mean?',
    'How is my health in general?',
    'When is a good time to buy property?',
    'What does my chart say about spirituality?',
    'What does my chart say about children?',
    'Will I do well in my studies?',
    'Will my business grow?',
    'Tell me about myself.',
  ],
  'hi': [
    'मेरा करियर कैसा रहेगा?',
    'मेरी शादी कब होगी?',
    'मेरी कमाई कैसी रहेगी?',
    'मेरा स्वभाव कैसा है?',
    'क्या विदेश में पढ़ाई का योग है?',
    'मेरी वर्तमान दशा का क्या अर्थ है?',
    'मेरा स्वास्थ्य कैसा रहेगा?',
    'घर कब खरीद पाऊंगा?',
    'अध्यात्म के बारे में मेरी कुंडली क्या कहती है?',
    'संतान के बारे में क्या योग है?',
    'पढ़ाई में सफलता मिलेगी?',
    'meri shaadi kab hogi?',
    'naukri kab lagegi?',
    'mera career kaisa rahega?',
  ],
  'mr': [
    'माझं करिअर कसं असेल? नोकरी मिळेल का?',
    'माझं लग्न कधी होईल?',
    'माझी कमाई कशी राहील? पैसे किती मिळतील?',
    'माझा स्वभाव कसा आहे?',
    'परदेशात शिक्षणाचा योग आहे का?',
    'माझ्या सध्याच्या दशेचा अर्थ काय?',
    'माझं आरोग्य कसं राहील?',
    'घर कधी घेता येईल?',
    'अध्यात्माबद्दल माझी कुंडली काय सांगते?',
    'अपत्याबद्दल काय योग आहे?',
    'परीक्षेत यश मिळेल का?',
  ],
  'bn': [
    'আমার কর্মজীবন কেমন হবে?',
    'আমার বিয়ে কবে হবে?',
    'আমার রোজগার কেমন হবে?',
    'আমার স্বভাব কেমন?',
    'বিদেশে পড়াশোনার যোগ আছে কি?',
    'আমার বর্তমান দশার অর্থ কী?',
    'আমার স্বাস্থ্য কেমন থাকবে?',
    'বাড়ি কবে কিনতে পারব?',
    'আধ্যাত্মিকতা নিয়ে আমার কুষ্ঠি কী বলে?',
    'সন্তান নিয়ে কী যোগ আছে?',
    'পরীক্ষায় সাফল্য পাব কি?',
  ],
  'ta': [
    'என் தொழில் எப்படி இருக்கும்?',
    'என் திருமணம் எப்போது நடக்கும்?',
    'என் வருமானம் எப்படி இருக்கும்?',
    'என் குணம் எப்படி?',
    'வெளிநாட்டில் படிக்கும் யோகம் உண்டா?',
    'என் தற்போதைய தசையின் பொருள் என்ன?',
    'என் ஆரோக்கியம் எப்படி இருக்கும்?',
    'வீடு எப்போது வாங்க முடியும்?',
    'ஆன்மீகம் பற்றி என் ஜாதகம் என்ன சொல்கிறது?',
    'குழந்தை பாக்கியம் பற்றி என்ன?',
    'தேர்வில் வெற்றி கிடைக்குமா?',
  ],
  'te': [
    'నా కెరీర్ ఎలా ఉంటుంది?',
    'నా పెళ్లి ఎప్పుడు అవుతుంది?',
    'నా ఆదాయం ఎలా ఉంటుంది?',
    'నా స్వభావం ఎలాంటిది?',
    'విదేశాల్లో చదువుకునే యోగం ఉందా?',
    'నా ప్రస్తుత దశ అర్థం ఏమిటి?',
    'నా ఆరోగ్యం ఎలా ఉంటుంది?',
    'ఇల్లు ఎప్పుడు కొనగలను?',
    'ఆధ్యాత్మికత గురించి నా జాతకం ఏమి చెబుతుంది?',
    'సంతానం గురించి ఏ యోగం ఉంది?',
    'పరీక్షల్లో విజయం వస్తుందా?',
  ],
  'kn': [
    'ನನ್ನ ವೃತ್ತಿ ಹೇಗಿರುತ್ತದೆ?',
    'ನನ್ನ ಮದುವೆ ಯಾವಾಗ ಆಗುತ್ತದೆ?',
    'ನನ್ನ ಆದಾಯ ಹೇಗಿರುತ್ತದೆ?',
    'ನನ್ನ ಸ್ವಭಾವ ಹೇಗಿದೆ?',
    'ವಿದೇಶದಲ್ಲಿ ಓದುವ ಯೋಗ ಇದೆಯೇ?',
    'ನನ್ನ ಈಗಿನ ದಶೆಯ ಅರ್ಥವೇನು?',
    'ನನ್ನ ಆರೋಗ್ಯ ಹೇಗಿರುತ್ತದೆ?',
    'ಮನೆ ಯಾವಾಗ ಖರೀದಿಸಬಹುದು?',
    'ಆಧ್ಯಾತ್ಮದ ಬಗ್ಗೆ ನನ್ನ ಜಾತಕ ಏನು ಹೇಳುತ್ತದೆ?',
    'ಸಂತಾನದ ಬಗ್ಗೆ ಏನು ಯೋಗವಿದೆ?',
    'ಪರೀಕ್ಷೆಯಲ್ಲಿ ಯಶಸ್ಸು ಸಿಗುತ್ತದೆಯೇ?',
  ],
  'ml': [
    'എന്റെ ജോലി എങ്ങനെയായിരിക്കും?',
    'എന്റെ വിവാഹം എപ്പോൾ നടക്കും?',
    'എന്റെ വരുമാനം എങ്ങനെയായിരിക്കും?',
    'എന്റെ സ്വഭാവം എങ്ങനെയാണ്?',
    'വിദേശത്ത് പഠിക്കാൻ യോഗമുണ്ടോ?',
    'എന്റെ ഇപ്പോഴത്തെ ദശയുടെ അർത്ഥം എന്താണ്?',
    'എന്റെ ആരോഗ്യം എങ്ങനെയായിരിക്കും?',
    'വീട് എപ്പോൾ വാങ്ങാൻ കഴിയും?',
    'ആത്മീയതയെക്കുറിച്ച് എന്റെ ജാതകം എന്ത് പറയുന്നു?',
    'സന്താനത്തെക്കുറിച്ച് എന്ത് യോഗമാണ്?',
    'പരീക്ഷയിൽ വിജയം കിട്ടുമോ?',
  ],
};

/// Crisis and lifespan questions. Crisis questions are answered with helplines
/// before the model runs; lifespan questions get the classical longevity
/// reading. The model is trained on both so it can never get them wrong. Many
/// phrasings per language, so the model learns the situation, not a sentence.
const _safetyQuestions = <String, List<String>>{
  'en': [
    'I want to kill myself',
    'I feel like ending my life',
    "I don't want to live anymore",
    'I am thinking about suicide',
    'I want to die. What does my chart say?',
    'There is no reason to live',
    'I keep hurting myself',
    'Should I just end it all?',
    'When will I die?',
    'How long will I live?',
    'What is my lifespan?',
    'Tell me my death date',
    'When will my father die?',
    'Will I die soon?',
  ],
  'hi': [
    'मैं आत्महत्या करना चाहता हूँ',
    'मुझे अब जीना नहीं है',
    'मैं मर जाना चाहती हूँ',
    'मन करता है खुदकुशी कर लूँ',
    'mujhe ab jeena nahi hai',
    'main marna chahta hoon',
    'मेरी मृत्यु कब होगी?',
    'मैं कब मरूँगा?',
    'मेरी आयु कितनी है?',
    'meri maut kab hogi?',
  ],
  'mr': [
    'मला आता जगायचं नाही',
    'मला आत्महत्या करावीशी वाटते',
    'मला मरायचं आहे',
    'माझं मरण कधी आहे?',
    'माझं आयुष्य किती आहे?',
    'माझा मृत्यू कधी होईल?',
  ],
  'bn': [
    'আমি আর বাঁচতে চাই না',
    'আমি আত্মহত্যা করতে চাই',
    'আমি মরতে চাই',
    'আমি কবে মারা যাব?',
    'আমার আয়ু কত?',
    'আমার মৃত্যু কবে হবে?',
  ],
  'ta': [
    'எனக்கு வாழ விருப்பமில்லை',
    'நான் தற்கொலை செய்ய நினைக்கிறேன்',
    'நான் சாக வேண்டும்',
    'நான் எப்போது இறப்பேன்?',
    'என் ஆயுள் எவ்வளவு?',
    'என் மரணம் எப்போது?',
  ],
  'te': [
    'నాకు బతకాలని లేదు',
    'నేను ఆత్మహత్య చేసుకోవాలనుకుంటున్నాను',
    'నాకు చనిపోవాలని ఉంది',
    'నేను ఎప్పుడు చనిపోతాను?',
    'నా ఆయుష్షు ఎంత?',
    'నా మరణం ఎప్పుడు?',
  ],
  'kn': [
    'ನನಗೆ ಬದುಕಲು ಇಷ್ಟವಿಲ್ಲ',
    'ನಾನು ಆತ್ಮಹತ್ಯೆ ಮಾಡಿಕೊಳ್ಳಬೇಕೆನಿಸುತ್ತಿದೆ',
    'ನಾನು ಸಾಯಬೇಕು',
    'ನಾನು ಯಾವಾಗ ಸಾಯುತ್ತೇನೆ?',
    'ನನ್ನ ಆಯುಷ್ಯ ಎಷ್ಟು?',
    'ನನ್ನ ಮರಣ ಯಾವಾಗ?',
  ],
  'ml': [
    'എനിക്ക് മരിക്കാൻ തോന്നുന്നു',
    'ഞാൻ ആത്മഹത്യ ചെയ്യാൻ ആഗ്രഹിക്കുന്നു',
    'എനിക്ക് ഇനി ജീവിക്കണ്ട',
    'ഞാൻ എപ്പോൾ മരിക്കും?',
    'എന്റെ ആയുസ്സ് എത്ര?',
    'എന്റെ മരണം എപ്പോൾ?',
  ],
};

/// Added to some questions whose answer is the detailed reading, so the model
/// sees how people ask for more. Each one matches [asksForDetail].
const _detailPhrases = {
  'en': 'Explain in detail.',
  'hi': 'विस्तार से बताइए।',
  'mr': 'सविस्तर सांगा.',
  'bn': 'বিস্তারিত বলুন।',
  'ta': 'விரிவாகச் சொல்லுங்கள்.',
  'te': 'వివరంగా చెప్పండి.',
  'kn': 'ವಿವರವಾಗಿ ಹೇಳಿ.',
  'ml': 'വിശദമായി പറയൂ.',
};

/// Share of charts per app language (English and Hindi are the most used).
const _languageWeights = {'en': 30, 'hi': 22, 'mr': 8, 'bn': 8, 'ta': 8, 'te': 8, 'kn': 8, 'ml': 8};

Future<void> main(List<String> args) async {
  if (args.contains('--check')) return _check();
  final count = _arg(args, '--count', 20);
  final seed = _arg(args, '--seed', 1);
  // Percent of charts that also get a crisis or lifespan question.
  final safetyRate = _arg(args, '--safety-percent', 15) / 100;
  // Percent of answers that are the detailed reading (the app's default is short).
  final detailRate = _arg(args, '--detail-percent', 25) / 100;
  final rnd = Random(seed);
  // Separate streams, so changing the safety lists or the answer lengths
  // never changes the charts.
  final safetyRnd = Random(seed + 1000);
  final lengthRnd = Random(seed + 2000);

  tzdata.initializeTimeZones();
  final root = _swephRoot();
  await Ephemeris.init(
    modulePath: Platform.isWindows ? '$root/example.dart/sweph.dll' : '$root/example.dart/libsweph.so',
    assetLoader: _FileLoader(root),
    epheFilesPath: Directory.systemTemp.createTempSync('drishti_fact_cli').path,
  );

  for (var i = 0; i < count; i++) {
    final hasTime = rnd.nextDouble() > 0.2;
    final hasPlace = rnd.nextDouble() > 0.1;
    final profile = Profile(
      id: 'synthetic-$seed-$i',
      name: 'Person ${i + 1}',
      birthDate: DateTime(1950 + rnd.nextInt(60), 1 + rnd.nextInt(12), 1 + rnd.nextInt(28)),
      birthHour: hasTime ? rnd.nextInt(24) : null,
      birthMinute: hasTime ? rnd.nextInt(60) : null,
      timeAccuracy: hasTime ? TimeAccuracy.exact : TimeAccuracy.unknown,
      place: hasPlace ? _places[rnd.nextInt(_places.length)] : null,
    );
    final settings = CalcSettings(system: rnd.nextDouble() > 0.25 ? AstroSystem.vedic : AstroSystem.western);
    final sheet = FactSheet.build(
      profile,
      settings,
      now: DateTime.utc(2026, 1 + rnd.nextInt(12), 1 + rnd.nextInt(28)),
    )!;
    final lang = _pickLanguage(rnd);
    final answerer = RuleBasedAnswerer(lang);

    // Three topic questions in the app language; sometimes one in English,
    // since people often type English with an Indian-language app.
    final pool = List.of(_questions[lang]!)..shuffle(rnd);
    final picked = pool.take(3).toList();
    if (lang != 'en' && rnd.nextDouble() < 0.25) {
      picked[2] = _questions['en']![rnd.nextInt(_questions['en']!.length)];
    }
    if (safetyRnd.nextDouble() < safetyRate) {
      // Sometimes in English, as people often type English in any app language.
      final s = _safetyQuestions[lang != 'en' && safetyRnd.nextDouble() < 0.25 ? 'en' : lang]!;
      picked.add(s[safetyRnd.nextInt(s.length)]);
    }

    final examples = <Map<String, Object>>[];
    for (final (n, picked0) in picked.indexed) {
      var q = picked0;
      final detailed = lengthRnd.nextDouble() < detailRate;
      if (detailed && lengthRnd.nextDouble() < 0.5) q = '$q ${_detailPhrases[_phraseLanguage(q, lang)]}';
      // Later questions sometimes come with the earlier ones, as in the app.
      final memory = n > 0 && lengthRnd.nextDouble() < 0.35 ? [for (final e in picked.take(n)) '- $e'] : <String>[];
      final lifespan = Safety.asksDeath(q) && !Safety.isCrisis(q);
      // The same answer the app computes before asking the model.
      final engine = answerer.answer(q, sheet, detailed: detailed);
      examples.add({
        'question': q,
        'detailed': detailed,
        'system': drishtiSystemPrompt.trim(),
        'user': buildGroundedPrompt(
          sheet,
          q,
          languageCode: lang,
          memory: memory,
          detailed: detailed,
          focus: engine.focusIds,
          tone: engine.tone,
          keyPoints: engine.keyPoints,
        ),
        'assistant': detailed ? _target(engine, lifespan: lifespan) : engine.text.trim(),
      });
    }

    stdout.writeln(
      jsonEncode({
        'id': profile.id,
        'system': settings.system.name,
        'lang': lang,
        'facts': [for (final f in sheet.facts) f.id],
        'examples': examples,
      }),
    );
  }
}

/// The detailed answer the model should learn, kept short because phones generate
/// slowly and Indian scripts take many tokens: the main placement paragraph
/// and the closing one (the current period, or the timing windows for "when"
/// questions), up to three supporting facts with their fact
/// ids, then the main caveat. Everything comes from the engine, in the app
/// language.
String _target(AiAnswer a, {bool lifespan = false}) {
  if (a.safetyResponse || a.factors.isEmpty) return a.text.trim();
  final paras = a.text.split('\n\n').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
  if (lifespan) return _lifespanTarget(paras, a);
  // The first paragraph is a generic intro and the last only points to the
  // factor list shown in the app; the substance is in between.
  final body = paras.length > 2 ? paras.sublist(1, paras.length - 1) : paras;
  final cited = [
    for (final f in a.factors)
      if (f.factId != null) '- ${f.fact.trim()} [${f.factId}]',
  ].take(3);
  return [
    body.first,
    if (body.length > 1) body.last,
    if (cited.isNotEmpty) cited.join('\n'),
    ...a.notes.where((n) => n.isNotEmpty).take(1),
    ...a.improveWith.take(1),
  ].join('\n\n');
}

/// Lifespan answers are kept whole (minus the pointer to the factor list):
/// the framing, the span, the maraka periods, care and the caveat all matter.
/// Fact ids are cited after the sentences that use them.
String _lifespanTarget(List<String> paras, AiAnswer a) {
  final body = paras.sublist(0, paras.length - 1);
  body[1] = '${body[1]} [longevity.span] [longevity.pairs]';
  final periods = [
    for (final f in a.factors)
      if (f.factId!.startsWith('maraka.')) '[${f.factId}]',
  ];
  // intro, span, maraka, care, caveat: the maraka paragraph is present.
  if (body.length == 5) body[2] = '${body[2]} [maraka] ${periods.join(' ')}'.trim();
  return [...body, ...a.improveWith.take(1)].join('\n\n');
}

/// Prints how every question is routed, so a keyword gap shows up before
/// training rather than as a generic answer.
void _check() {
  for (final lang in _questions.keys) {
    for (final q in _questions[lang]!) {
      final d = detectIntent(q);
      stdout.writeln('$lang\t${d.intent.name}${d.asksTiming ? '+timing' : ''}\t$q');
    }
    for (final q in _safetyQuestions[lang]!) {
      final kind = Safety.isCrisis(q)
          ? 'CRISIS'
          : Safety.asksDeath(q)
          ? 'LIFESPAN'
          : 'MISSED';
      stdout.writeln('$lang\t$kind\t$q');
    }
  }
}

/// English questions in an Indian-language app get the English phrase.
String _phraseLanguage(String q, String lang) => RegExp(r'^[\x00-\x7F]+$').hasMatch(q) ? 'en' : lang;

String _pickLanguage(Random rnd) {
  final total = _languageWeights.values.fold(0, (a, b) => a + b);
  var r = rnd.nextInt(total);
  for (final e in _languageWeights.entries) {
    if (r < e.value) return e.key;
    r -= e.value;
  }
  return 'en';
}

int _arg(List<String> args, String name, int fallback) {
  final i = args.indexOf(name);
  return i >= 0 && i + 1 < args.length ? int.tryParse(args[i + 1]) ?? fallback : fallback;
}

String _swephRoot() {
  final config = jsonDecode(File('.dart_tool/package_config.json').readAsStringSync()) as Map;
  final pkg = (config['packages'] as List).cast<Map>().firstWhere((p) => p['name'] == 'sweph');
  return Uri.parse(pkg['rootUri'] as String).toFilePath(windows: Platform.isWindows);
}

class _FileLoader implements AssetLoader {
  _FileLoader(this.root);
  final String root;
  @override
  Future<Uint8List> load(String assetPath) =>
      File('$root/${assetPath.replaceFirst('packages/sweph/', '')}').readAsBytes();
}
