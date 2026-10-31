/// Safety rules shared by the rule-based answerer and the language model.
///
/// These encode the product's promise: no fear, no selling, nothing hidden,
/// crisis support first. Lifespan questions are answered with what the
/// classical calculation says (see [asksDeath]), never with certainty. The English messages below are
/// the reference texts; translations live in the explanation language packs
/// under the `safety.*` keys (helpline numbers must never change).
class Safety {
  Safety._();

  static const crisisMessage =
      'I\'m really sorry you\'re feeling this way. You don\'t have to go through it alone. '
      'Please talk to someone right now: in India you can call Tele-MANAS at 14416 (free, 24×7) '
      'or the KIRAN helpline at 1800-599-0019. If you are in immediate danger, please contact '
      'your local emergency services or go to the nearest hospital. Talking to a trusted friend '
      'or family member can also help. Astrology can wait; you matter.';

  static const professionalMedical =
      'For anything about health, please consult a qualified doctor. Astrology can describe '
      'traditional tendencies only and cannot diagnose or treat anything.';
  static const professionalLegal =
      'For legal matters, please consult a qualified lawyer. Astrology cannot judge a legal case.';
  static const professionalFinancial =
      'For investments or money decisions, please consult a qualified financial adviser. '
      'Astrology cannot predict markets or returns.';
  static const professionalPregnancy =
      'For pregnancy and fertility questions, please consult a qualified doctor. '
      'Astrology can only describe traditional themes of the 5th house.';

  // English and romanised Indian-language patterns (ASCII word boundaries).
  static final _crisis = RegExp(
    r"\b(suicid\w*|kill(ing)? (my ?self|myself)|end(ing)? (my|this) life|end it all|want to die|"
    r"(don'?t|do not|no longer) want to (live|be alive)|self[- ]?harm|hurt(ing)? myself|cut myself|"
    r"no reason to live|take my (own )?life|end everything|aatmhatya|atmahatya|marna chahta|marna chahti|jeena nahi|jina nahi|khudkushi)\b",
    caseSensitive: false,
  );

  static final _death = RegExp(
    r"\b(when (will|would) (i|he|she|they|my \w+) die|death date|date of death|how long will (i|he|she) live|"
    r"(when|what age) will (i|he|she|they|my \w+) pass away|lifespan|life span|longevity|ayu|maut|mrityu|mrtyu|kab marunga|kab marega|kab maregi|die soon)\b",
    caseSensitive: false,
  );

  static final _medical = RegExp(
    r"\b(disease|illness|cancer|diabetes|surgery|operation|medicine|tablet|symptom|depress\w*|anxiety|"
    r"bimari|bimaari|rog|dawai|ilaj)\b",
    caseSensitive: false,
  );
  static final _legal = RegExp(
    r"\b(court|case|lawsuit|legal|police|divorce case|mukadma|kanoon)\b",
    caseSensitive: false,
  );
  static final _financial = RegExp(
    r"\b(stock|share market|shares|crypto|bitcoin|invest\w*|trading|lottery|satta|betting|gamble)\b",
    caseSensitive: false,
  );
  static final _pregnancy = RegExp(r"\b(pregnan\w*|conceive|fertility|ivf|garbh)\b", caseSensitive: false);

  // Native-script phrases (hi, mr, bn, ta, te, kn, ml). Indic letters are not
  // regex "word" characters, so these are matched as plain substrings.
  static const _crisisNative = [
    'आत्महत्या',
    'खुदकुशी',
    'मरना चाहता',
    'मरना चाहती',
    'मर जाना चाहता',
    'मर जाना चाहती',
    'जीना नहीं',
    'जान देना चाहत',
    'अपनी जान ले',
    'जगायचं नाही',
    'जगायचे नाही',
    'मरायचे आहे',
    'मरायचं आहे',
    'जीव द्यायचा',
    'আত্মহত্যা',
    'মরতে চাই',
    'বাঁচতে চাই না',
    'தற்கொலை',
    'சாக வேண்டும்',
    'சாகணும்',
    'வாழ விருப்பமில்லை',
    'ఆత్మహత్య',
    'చనిపోవాలని',
    'చావాలని',
    'బతకాలని లేదు',
    'ಆತ್ಮಹತ್ಯೆ',
    'ಸಾಯಬೇಕು',
    'ಸಾಯಲು ಬಯಸ',
    'ಬದುಕಲು ಇಷ್ಟವಿಲ್ಲ',
    'ആത്മഹത്യ',
    'മരിക്കണം',
    'മരിക്കാൻ തോന്നുന്നു',
    'ജീവിക്കണ്ട',
  ];

  static const _deathNative = [
    'मृत्यु',
    'मृत्यू',
    'मौत',
    'कब मरूंगा',
    'कब मरूँगा',
    'कब मरेगा',
    'कब मरेगी',
    'आयु कितनी',
    'उम्र कितनी होगी',
    'मरण कधी',
    'आयुष्य किती',
    'মৃত্যু',
    'কবে মারা যাব',
    'কবে মারা যাবে',
    'আয়ু কত',
    'மரணம்',
    'எப்போது இறப்பேன்',
    'எப்போது இறப்பார்',
    'ஆயுள் எவ்வளவு',
    'మరణం',
    'ఎప్పుడు చనిపోతాను',
    'ఎప్పుడు చనిపోతారు',
    'ఆయుష్షు ఎంత',
    'ಮರಣ',
    'ಯಾವಾಗ ಸಾಯುತ್ತೇನೆ',
    'ಯಾವಾಗ ಸಾಯುತ್ತಾರೆ',
    'ಆಯುಷ್ಯ ಎಷ್ಟು',
    'മരണം',
    'എപ്പോൾ മരിക്കും',
    'ആയുസ്സ് എത്ര',
  ];

  static const _medicalNative = [
    'रोग',
    'बीमारी',
    'दवा',
    'इलाज',
    'ऑपरेशन',
    'आजार',
    'औषध',
    'রোগ',
    'অসুখ',
    'ওষুধ',
    'நோய்',
    'மருந்து',
    'அறுவை',
    'వ్యాధి',
    'రోగం',
    'మందు',
    'ರೋಗ',
    'ಕಾಯಿಲೆ',
    'ಔಷಧ',
    'രോഗം',
    'അസുഖം',
    'മരുന്ന്',
  ];
  static const _legalNative = [
    'अदालत',
    'कोर्ट',
    'मुकदमा',
    'न्यायालय',
    'আদালত',
    'মামলা',
    'நீதிமன்றம்',
    'வழக்கு',
    'కోర్టు',
    'న్యాయస్థానం',
    'ನ್ಯಾಯಾಲಯ',
    'കോടതി',
  ];
  static const _financialNative = [
    'शेयर',
    'निवेश',
    'सट्टा',
    'लॉटरी',
    'गुंतवणूक',
    'শেয়ার',
    'বিনিয়োগ',
    'লটারি',
    'பங்கு சந்தை',
    'முதலீடு',
    'லாட்டரி',
    'షేర్',
    'పెట్టుబడి',
    'లాటరీ',
    'ಷೇರು',
    'ಹೂಡಿಕೆ',
    'ಲಾಟರಿ',
    'ഓഹരി',
    'നിക്ഷേപം',
    'ലോട്ടറി',
  ];
  static const _pregnancyNative = ['गर्भ', 'প্রেগন্যান্সি', 'গর্ভ', 'கர்ப்ப', 'గర్భ', 'ಗರ್ಭ', 'ഗർഭ'];

  static bool _anyIn(String text, List<String> words) => words.any(text.contains);

  static bool isCrisis(String text) => _crisis.hasMatch(text) || _anyIn(text, _crisisNative);

  /// Lifespan or death-timing questions, answered by the longevity reading.
  static bool asksDeath(String text) => _death.hasMatch(text) || _anyIn(text, _deathNative);

  /// Language-pack keys (`safety.*`) of the professional referrals that apply.
  static List<String> referralKeysFor(String text) => [
    if (_medical.hasMatch(text) || _anyIn(text, _medicalNative)) 'safety.medical',
    if (_pregnancy.hasMatch(text) || _anyIn(text, _pregnancyNative)) 'safety.pregnancy',
    if (_legal.hasMatch(text) || _anyIn(text, _legalNative)) 'safety.legal',
    if (_financial.hasMatch(text) || _anyIn(text, _financialNative)) 'safety.financial',
  ];

  /// English professional-referral notes that apply to a question.
  static List<String> referralsFor(String text) => [
    for (final k in referralKeysFor(text))
      switch (k) {
        'safety.medical' => professionalMedical,
        'safety.pregnancy' => professionalPregnancy,
        'safety.legal' => professionalLegal,
        _ => professionalFinancial,
      },
  ];

  /// Phrases a generated answer must never contain.
  static final forbiddenOutput = <RegExp>[
    RegExp(r'\bguarante\w*', caseSensitive: false),
    RegExp(r'\b100 ?%', caseSensitive: false),
    RegExp(r'\b(definitely|certainly|surely) will\b', caseSensitive: false),
    RegExp(r'\bwill (definitely|certainly|surely)\b', caseSensitive: false),
    RegExp(r'\b(curse[ds]?|doomed|ruined|cursed)\b', caseSensitive: false),
    RegExp(r'\b(buy|purchase|order now|shop|store|price|discount|₹|rs\.? ?\d)', caseSensitive: false),
    RegExp(r'\b(you|he|she|they) will die\b', caseSensitive: false),
    RegExp(r'\b(death|accident) (will happen|in \d{4})', caseSensitive: false),
    RegExp(r'\b(caste|jaati|jati)\b.*\b(better|inferior|superior|lower|higher)\b', caseSensitive: false),
    // Native-script equivalents of "guaranteed", "definitely", "buy" and "curse".
    RegExp(
      'गारंटी|निश्चित रूप से होगा|ज़रूर होगा|खरीदें|खरीदिए|श्राप|शाप|গ্যারান্টি|কিনুন|অভিশাপ|'
      'உத்தரவாதம்|நிச்சயமாக நடக்கும்|வாங்குங்கள்|சாபம்|హామీ|ఖచ్చితంగా జరుగుతుంది|కొనండి|శాపం|'
      'ಖಾತರಿ|ಖಂಡಿತ ಆಗುತ್ತದೆ|ಖರೀದಿಸಿ|ಶಾಪ|ഉറപ്പായും സംഭവിക്കും|ഗ്യാരണ്ടി|വാങ്ങുക|ശാപം',
    ),
  ];

  /// Returns the reasons an output is unacceptable (empty = ok).
  static List<String> violations(String output) => [
    for (final r in forbiddenOutput)
      if (r.hasMatch(output)) r.pattern,
  ];
}
