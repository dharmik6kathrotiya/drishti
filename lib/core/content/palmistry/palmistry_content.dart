import 'palmistry_bn.dart';
import 'palmistry_en.dart';
import 'palmistry_hi.dart';
import 'palmistry_kn.dart';
import 'palmistry_ml.dart';
import 'palmistry_mr.dart';
import 'palmistry_ta.dart';
import 'palmistry_te.dart';

/// Guided, honest self-reading of the palm. A photo can pre-fill the line
/// questions (see PalmLineDetector), but the user confirms every answer:
/// the user looks at their own hand (or a photo of it) and answers questions.
enum PalmArea { hand, heartLine, headLine, lifeLine, fateLine, mounts, fingers, thumb }

class PalmOption {
  const PalmOption(this.label, this.meaning);
  final String label;
  final String meaning;
}

class PalmQuestion {
  const PalmQuestion({
    required this.id,
    required this.area,
    required this.title,
    required this.help,
    required this.options,
  });

  final String id;
  final PalmArea area;
  final String title;

  /// How to find the feature on the hand.
  final String help;
  final List<PalmOption> options;
}

class PalmistryTexts {
  const PalmistryTexts({
    required this.intro,
    required this.noScanNote,
    required this.whichHand,
    required this.questions,
    required this.closing,
  });

  final String intro;
  final String noScanNote;
  final String whichHand;
  final List<PalmQuestion> questions;
  final String closing;
}

const palmistryByLanguage = <String, PalmistryTexts>{
  'en': palmistryEn,
  'hi': palmistryHi,
  'mr': palmistryMr,
  'bn': palmistryBn,
  'ta': palmistryTa,
  'te': palmistryTe,
  'kn': palmistryKn,
  'ml': palmistryMl,
};

PalmistryTexts palmistryFor(String languageCode) => palmistryByLanguage[languageCode] ?? palmistryEn;
