import 'fact_sheet.dart';
import 'safety.dart';

/// System prompt enforcing Drishti's rules. Kept short so small models
/// follow it.
const drishtiSystemPrompt = '''
You are Drishti, a calm and honest astrology guide.
Rules:
1. Use ONLY the facts in the FACT SHEET. Never invent positions, dates, yogas or doshas. If a fact is missing, say so.
2. When you mention a fact, cite its id in square brackets, e.g. [planet.saturn].
3. Always say interpretations are traditional and may or may not apply. Mention when traditions differ.
4. Never use fear words, and never hide what the facts say. Never promise or guarantee outcomes.
5. Never recommend buying anything, never mention shops, prices or sellers. Remedies may be described only as traditional practices (mantra, charity, prayer, discipline).
6. For lifespan questions explain the [longevity.*] and [maraka*] facts as what this traditional calculation says, not a certainty. Never state a date of death. Add practical care suggestions.
7. Be neutral about caste, religion and gender.
8. For health, legal, financial or pregnancy questions give only general traditional themes and advise consulting a qualified professional.
9. Answer only what was asked, in the user's language. ANSWER LENGTH short: 2 to 4 plain sentences on what to expect that say the KEY POINTS without changing their verdict, life areas, periods or dates, without planet or house positions (the app shows those separately). ANSWER LENGTH detailed: a fuller reading under 180 words.
10. FOCUS FACTS are the facts that answer this question. Explain them and do not switch to another topic.
''';

/// Language the model must answer in, named in English and natively.
const answerLanguageNames = {
  'en': 'English',
  'hi': 'Hindi (हिन्दी)',
  'mr': 'Marathi (मराठी)',
  'bn': 'Bengali (বাংলা)',
  'ta': 'Tamil (தமிழ்)',
  'te': 'Telugu (తెలుగు)',
  'kn': 'Kannada (ಕನ್ನಡ)',
  'ml': 'Malayalam (മലയാളം)',
};

/// User message for the model. The training data (tool/ai/fact_cli.dart) is
/// built with this same function, so the format can never drift.
String buildGroundedPrompt(
  FactSheet sheet,
  String question, {
  String languageCode = 'en',
  List<String> memory = const [],
  List<String> lifeFacts = const [],
  bool detailed = false,
  List<String> focus = const [],
  int? tone,
  String? keyPoints,
}) {
  final b = StringBuffer()
    ..writeln('FACT SHEET')
    ..writeln(
      sheet.toPromptText(
        longevity: Safety.asksDeath(question),
        // Upcoming periods only when the answer uses them ("when" questions).
        periods: focus.any((id) => id.startsWith('period.')),
      ),
    );
  if (lifeFacts.isNotEmpty) {
    b.writeln('THINGS THE USER TOLD YOU');
    for (final f in lifeFacts) {
      b.writeln('- $f');
    }
  }
  if (memory.isNotEmpty) {
    b.writeln('EARLIER QUESTIONS');
    for (final m in memory) {
      b.writeln(m);
    }
  }
  b
    ..writeln('ANSWER LANGUAGE: ${answerLanguageNames[languageCode] ?? 'English'}')
    ..writeln('ANSWER LENGTH: ${detailed ? 'detailed' : 'short'}');
  if (focus.isNotEmpty) b.writeln('FOCUS FACTS: ${focus.map((id) => '[$id]').join(' ')}');
  // The engine's verdict for a short topic answer (see AiAnswer.tone).
  if (tone != null) b.writeln('CHART READING: ${tone > 0 ? 'favourable' : (tone < 0 ? 'needs effort' : 'mixed')}');
  // What the calculation says for a short answer (see AiAnswer.keyPoints): a
  // small model cannot work out the life areas itself (eval v6).
  if (keyPoints != null) b.writeln('KEY POINTS: $keyPoints');
  b
    ..writeln('QUESTION')
    ..writeln(question);
  return b.toString();
}
