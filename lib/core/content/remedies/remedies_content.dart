import '../../astro/constants.dart';
import 'remedies_bn.dart';
import 'remedies_en.dart';
import 'remedies_hi.dart';
import 'remedies_kn.dart';
import 'remedies_ml.dart';
import 'remedies_mr.dart';
import 'remedies_ta.dart';
import 'remedies_te.dart';

/// Traditional remedies (upayas), presented as information only.
///
/// Content is grouped per language: add `remedies_<code>.dart` with a
/// [RemediesContent] instance and register it in [remediesByLanguage].
/// Missing languages fall back to English.
class Mantra {
  const Mantra({required this.devanagari, required this.iast, required this.meaning, required this.source});

  final String devanagari;

  /// Romanised (IAST) transliteration.
  final String iast;
  final String meaning;
  final String source;
}

class GemInfo {
  const GemInfo({required this.primary, required this.upratna});
  final String primary;

  /// Traditional substitute stone(s).
  final String upratna;
}

class GrahaRemedy {
  const GrahaRemedy({
    required this.planet,
    required this.name,
    required this.deity,
    required this.day,
    required this.colour,
    required this.direction,
    required this.beej,
    required this.stotra,
    required this.japa,
    required this.charity,
    required this.fasting,
    required this.gem,
    required this.rudraksha,
    required this.yantra,
    required this.lifestyle,
    required this.signifies,
  });

  final Planet planet;
  final String name;

  /// Short description of what the planet signifies in Jyotish.
  final String signifies;
  final String deity;
  final String day;
  final String colour;
  final String direction;
  final Mantra beej;
  final Mantra stotra;
  final String japa;
  final String charity;
  final String fasting;
  final GemInfo gem;
  final String rudraksha;
  final String yantra;
  final List<String> lifestyle;
}

class RemedyPractice {
  const RemedyPractice({required this.title, required this.detail, required this.source});
  final String title;
  final String detail;
  final String source;
}

class DoshaRemedies {
  const DoshaRemedies({
    required this.id,
    required this.name,
    required this.about,
    required this.practices,
    this.adultOnly = false,
  });

  final String id;
  final String name;
  final String about;
  final List<RemedyPractice> practices;

  /// Marriage-related content, hidden in teen mode.
  final bool adultOnly;
}

class ClassicBook {
  const ClassicBook({required this.title, required this.author, required this.description});
  final String title;
  final String author;
  final String description;
}

class RemediesContent {
  const RemediesContent({
    required this.intro,
    required this.gemNote,
    required this.grahas,
    required this.doshas,
    required this.books,
    required this.personalNote,
  });

  final String intro;

  /// General honest note shown wherever gemstones appear.
  final String gemNote;
  final List<GrahaRemedy> grahas;
  final List<DoshaRemedies> doshas;
  final List<ClassicBook> books;

  /// Shown on the personal suggestions screen.
  final String personalNote;

  GrahaRemedy graha(Planet p) => grahas.firstWhere((g) => g.planet == p);
  DoshaRemedies? dosha(String id) => doshas.where((d) => d.id == id).firstOrNull;
}

final remediesByLanguage = <String, RemediesContent>{
  'en': remediesEn,
  'hi': remediesHi,
  'mr': remediesMr,
  'bn': remediesBn,
  'ta': remediesTa,
  'te': remediesTe,
  'kn': remediesKn,
  'ml': remediesMl,
};

/// A translated mantra: the Devanagari and IAST text are always taken from
/// the English content, so the Sanskrit can never drift between languages.
Mantra translatedMantra(Mantra english, {required String meaning, required String source}) =>
    Mantra(devanagari: english.devanagari, iast: english.iast, meaning: meaning, source: source);

RemediesContent remediesFor(String languageCode) => remediesByLanguage[languageCode] ?? remediesEn;
