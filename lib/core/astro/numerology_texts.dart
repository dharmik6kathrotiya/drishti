/// Detailed numerology texts ("what it means", combinations, methods).
///
/// Plain keyed strings without placeholders. Every language map uses the same
/// keys as [numerologyTextsEn]; missing keys fall back to English. Tone:
/// traditional associations, balanced, never fear or guarantees.
library;

import 'numerology.dart';
import 'numerology_texts_bn.dart';
import 'numerology_texts_hi.dart';
import 'numerology_texts_kn.dart';
import 'numerology_texts_ml.dart';
import 'numerology_texts_mr.dart';
import 'numerology_texts_ta.dart';
import 'numerology_texts_te.dart';

class NumerologyTexts {
  NumerologyTexts._(this.lang, this._map);

  final String lang;
  final Map<String, String> _map;

  static final _cache = <String, NumerologyTexts>{};

  static NumerologyTexts of(String lang) =>
      _cache.putIfAbsent(lang, () => NumerologyTexts._(lang, languages[lang] ?? const {}));

  /// Translations by language code (English is [numerologyTextsEn]).
  static const languages = <String, Map<String, String>>{
    'hi': numerologyTextsHi,
    'mr': numerologyTextsMr,
    'bn': numerologyTextsBn,
    'ta': numerologyTextsTa,
    'te': numerologyTextsTe,
    'kn': numerologyTextsKn,
    'ml': numerologyTextsMl,
  };

  String t(String key) => _map[key] ?? numerologyTextsEn[key] ?? key;

  /// What a number type represents (lifePath, birthday, mulank, ...).
  String typeWhy(String id) => t('type.$id');

  String strengths(int n) => t('num.$n.strengths');
  String challenges(int n) => t('num.$n.challenges');
  String guidance(int n) => t('num.$n.guidance');

  String pairIntro() => t('pair.intro');
  String pairRelation(PairRelation r) => t('pair.${r.name}');
  String pairNodesNote() => t('pair.nodesNote');

  String loShuIntro() => t('loshu.intro');
  String loShuIndianNote() => t('loshu.indianNote');
  String loShuMissing(int n) => t('loshu.missing.$n');

  /// Meaning of [n] appearing [count] (2, or 3 and more) times.
  String loShuRepeated(int n, int count) => t('loshu.repeat.$n.${count >= 3 ? 3 : 2}');
  String planeName(LoShuPlane p) => t('loshu.plane.${p.name}.name');
  String planeMeaning(LoShuPlane p) => t('loshu.plane.${p.name}.meaning');

  String compoundIntro() => t('compound.intro');
  String compound(int c) => t('compound.$c');

  String cycleIntro(String kind) => t('cycle.$kind');
  String cycle(int n) => t('cycle.$n');

  String about(String id) => t('about.$id');

  /// All keys, for completeness tests.
  static Iterable<String> get keys => numerologyTextsEn.keys;
}

const numerologyTextsEn = <String, String>{
  // What each number type represents
  'type.lifePath': 'The Life Path comes from the whole birth date. Tradition reads it as the main theme of a lifetime: the lessons, interests and direction that keep returning.',
  'type.birthday': 'The Birthday number comes from the day of the month alone. It is read as a particular talent or way of working that you bring to the Life Path.',
  'type.mulank': 'Mulank (root number) comes from the birth day. Indian numerology reads it as your basic temperament: how you think and act from day to day.',
  'type.bhagyank': 'Bhagyank (destiny number) comes from all the digits of the birth date. Indian numerology reads it as the wider direction of life and the kind of opportunities that come with it.',
  'type.expression': 'The Expression number comes from every letter of the full name. It is read as your natural abilities and the way you express them in work and life.',
  'type.soulUrge': 'The Soul Urge comes from the vowels of the name. It is read as inner motivation: what you deeply want, even when you do not show it.',
  'type.personality': 'The Personality number comes from the consonants of the name. It is read as the first impression you give and how others tend to see you.',
  'type.chaldeanName': 'The Chaldean name number uses an older letter table based on the sound of letters. It is read as the overall vibration of the name you are known by.',

  // Fuller meanings: strengths, challenges, practical guidance
  'num.1.strengths': 'Initiative, independence, courage to start things and lead.',
  'num.1.challenges': 'Can become impatient, stubborn or reluctant to accept help.',
  'num.1.guidance': 'Take the lead on new work, but listen before deciding and share credit.',
  'num.2.strengths': 'Tact, patience, sensitivity to others and a gift for cooperation.',
  'num.2.challenges': 'Can be over-sensitive, indecisive or too eager to please.',
  'num.2.guidance': 'Partnerships and teamwork suit you; practise saying no calmly when needed.',
  'num.3.strengths': 'Creativity, cheerful expression, good with words and people.',
  'num.3.challenges': 'Energy can scatter across too many interests; may avoid routine.',
  'num.3.guidance': 'Choose one or two projects to finish, and use your voice to encourage others.',
  'num.4.strengths': 'Reliability, method, hard work and practical problem-solving.',
  'num.4.challenges': 'Can be rigid, overworked or resistant to sudden change.',
  'num.4.guidance': 'Build step by step, keep some flexibility, and plan rest as seriously as work.',
  'num.5.strengths': 'Curiosity, adaptability, quick thinking and communication.',
  'num.5.challenges': 'Restlessness, impulsive decisions, difficulty with commitment.',
  'num.5.guidance': 'Welcome change but keep a few steady habits; think twice before big risks.',
  'num.6.strengths': 'Care, responsibility, a sense of beauty and harmony at home.',
  'num.6.challenges': 'Can take on too much for others, worry, or try to control.',
  'num.6.guidance': 'Serve others without neglecting yourself; let people solve their own problems.',
  'num.7.strengths': 'Depth of thought, research, intuition and a rich inner life.',
  'num.7.challenges': 'Can withdraw, overthink or find it hard to trust.',
  'num.7.guidance': 'Make time for study and quiet, and share your thoughts with a few trusted people.',
  'num.8.strengths': 'Discipline, ambition, patience and skill in managing resources.',
  'num.8.challenges': 'Can be overly serious, work-focused, or feel that results come slowly.',
  'num.8.guidance': 'Steady effort is traditionally rewarded over time; balance work with family and health.',
  'num.9.strengths': 'Compassion, courage, generosity and a wide outlook.',
  'num.9.challenges': 'Can be impatient, quick to anger, or give until exhausted.',
  'num.9.guidance': 'Channel energy into causes you care about; finish what you start and let go gracefully.',
  'num.11.strengths': 'Intuition, inspiration and the ability to uplift others.',
  'num.11.challenges': 'Nervous tension, self-doubt, and high expectations of oneself.',
  'num.11.guidance': 'Ground ideas in daily practice; on ordinary days the qualities of 2 apply.',
  'num.22.strengths': 'Vision combined with practical skill to build things that last.',
  'num.22.challenges': 'Pressure to achieve a lot; can feel overwhelmed by big plans.',
  'num.22.guidance': 'Break large goals into small steps; on ordinary days the qualities of 4 apply.',
  'num.33.strengths': 'Compassionate teaching, healing and service to others.',
  'num.33.challenges': 'Self-sacrifice, carrying others\' burdens, perfectionism.',
  'num.33.guidance': 'Care for yourself as well as others; on ordinary days the qualities of 6 apply.',

  // Mulank-Bhagyank pair
  'pair.intro': 'Mulank shows how you act from day to day; Bhagyank shows the wider direction of life. Indian numerology compares their ruling planets using the classical natural friendships of the planets.',
  'pair.same': 'Both numbers share one planet, so its qualities are traditionally read as reinforced: its strengths are amplified, and so are its usual challenges.',
  'pair.friendly': 'The ruling planets are natural friends, so tradition reads your temperament (Mulank) and life direction (Bhagyank) as supporting each other.',
  'pair.neutral': 'The planets are neutral, or regard each other differently, so tradition reads the pairing as workable: the two influences neither strongly help nor hinder each other.',
  'pair.challenging': 'The planets are natural enemies in the classical table, so tradition suggests some inner tension between temperament and life direction. It is read as something to balance consciously, not as a bad sign.',
  'pair.nodesNote': 'Rahu (4) and Ketu (7) are not in the classical friendship table. The app uses a common later convention (Rahu: friends Mercury, Venus, Saturn; Ketu: friends Mars, Venus, Saturn), and schools differ.',

  // Lo Shu grid
  'loshu.intro': 'The Lo Shu square is an ancient Chinese magic square in which every row, column and diagonal adds up to 15. Each digit of the birth date is placed in its box (layout 4-9-2 / 3-5-7 / 8-1-6); zeros are ignored.',
  'loshu.indianNote': 'Usual Indian practice also adds the Bhagyank, and the Mulank unless the birth day is 1-9, 10, 20 or 30 (then it is already in the grid). Turn this off to see the grid of the date alone.',
  'loshu.missing.1': 'Missing 1: expressing yourself and your feelings may need conscious effort.',
  'loshu.missing.2': 'Missing 2: patience and sensitivity to others may need to be developed.',
  'loshu.missing.3': 'Missing 3: imagination and confidence in your ideas may need encouragement.',
  'loshu.missing.4': 'Missing 4: order, discipline and routine may need deliberate attention.',
  'loshu.missing.5': 'Missing 5: emotional balance and steady focus may take practice.',
  'loshu.missing.6': 'Missing 6: home, family responsibilities and comfort may need more care.',
  'loshu.missing.7': 'Missing 7: lessons often come through experience; time for reflection helps.',
  'loshu.missing.8': 'Missing 8: attention to detail and careful money management may need effort.',
  'loshu.missing.9': 'Missing 9: ambition and a wider purpose may need to be consciously nurtured.',
  'loshu.repeat.1.2': '1 twice: traditionally read as balanced, clear self-expression.',
  'loshu.repeat.1.3': '1 three or more times: may talk a lot, or find deep feelings hard to put into words.',
  'loshu.repeat.2.2': '2 twice: strong intuition and sensitivity; a good judge of people.',
  'loshu.repeat.2.3': '2 three or more times: easily hurt; protecting your emotional energy helps.',
  'loshu.repeat.3.2': '3 twice: rich imagination and a creative, lively mind.',
  'loshu.repeat.3.3': '3 three or more times: thoughts may scatter or turn to worry; writing things down helps.',
  'loshu.repeat.4.2': '4 twice: very organised and hard-working, good with practical skills.',
  'loshu.repeat.4.3': '4 three or more times: may become rigid or too focused on material matters.',
  'loshu.repeat.5.2': '5 twice: strong drive and determination.',
  'loshu.repeat.5.3': '5 three or more times: may act or speak in haste; pausing before reacting helps.',
  'loshu.repeat.6.2': '6 twice: deep care for home and family.',
  'loshu.repeat.6.3': '6 three or more times: may worry about loved ones or become over-protective.',
  'loshu.repeat.7.2': '7 twice: learns deeply from experience; drawn to study and inner questions.',
  'loshu.repeat.7.3': '7 three or more times: life lessons may feel heavy at times; rest and support matter.',
  'loshu.repeat.8.2': '8 twice: methodical, attentive to detail and reliable.',
  'loshu.repeat.8.3': '8 three or more times: may become restless or perfectionist.',
  'loshu.repeat.9.2': '9 twice: idealistic, ambitious and quick to understand.',
  'loshu.repeat.9.3': '9 three or more times: may become critical or impatient with others.',
  'loshu.plane.mental.name': 'Mental plane',
  'loshu.plane.mental.meaning': 'Top row complete: traditionally linked with good memory, analysis and planning.',
  'loshu.plane.emotional.name': 'Emotional plane',
  'loshu.plane.emotional.meaning': 'Middle row complete: traditionally linked with emotional depth and empathy.',
  'loshu.plane.practical.name': 'Practical plane',
  'loshu.plane.practical.meaning':
      'Bottom row complete: traditionally linked with practical skill and getting things done.',
  'loshu.plane.thought.name': 'Thought plane',
  'loshu.plane.thought.meaning': 'Left column complete: traditionally linked with ideas, planning and organising.',
  'loshu.plane.will.name': 'Will plane',
  'loshu.plane.will.meaning': 'Middle column complete: traditionally linked with determination and persistence.',
  'loshu.plane.action.name': 'Action plane',
  'loshu.plane.action.meaning': 'Right column complete: traditionally linked with turning ideas into action.',
  'loshu.plane.golden.name': 'Golden plane',
  'loshu.plane.golden.meaning': 'Diagonal 4-5-6 complete: some Indian numerologists call it the "Golden Yog" and read it as steady effort turning into progress.',
  'loshu.plane.silver.name': 'Silver plane',
  'loshu.plane.silver.meaning': 'Diagonal 2-5-8 complete: some Indian numerologists call it the "Silver Yog" and link it with intuition and property matters.',

  // Chaldean compound numbers (Cheiro's tradition, in neutral words)
  'compound.intro': 'In Cheiro\'s tradition the Chaldean total before reduction (10-52) has its own meaning, read alongside the single digit.',
  'compound.10':
      'Called the "Wheel of Fortune": honour, self-confidence and rise and fall in turns; a name that becomes known.',
  'compound.11':
      'Tradition advises care with hidden obstacles and with whom you trust; faith and patience are emphasised.',
  'compound.12':
      'Linked with sacrifice for others; tradition advises guarding your own interests while helping people.',
  'compound.13': 'Linked with change, transformation and new beginnings after endings; power that needs wise use.',
  'compound.14': 'Movement, trade and dealings with people; tradition advises caution with speculation and relying on others\' judgment.',
  'compound.15': 'Charm, eloquence and artistic gifts; help comes from others. Tradition asks it be used honestly.',
  'compound.16': 'Linked with sudden changes to plans or position; tradition advises careful planning and humility.',
  'compound.17': 'Called the "Star of the Magi": peace, love and rising above trials; a name that is remembered.',
  'compound.18': 'Linked with tension between material and spiritual aims; tradition advises care in disputes.',
  'compound.19': 'Called the "Prince of Heaven": happiness, esteem and success; one of the most favourable numbers.',
  'compound.20':
      'Called "The Awakening": a call to a new purpose and plans; read more as inner growth than material gain.',
  'compound.21': 'Called the "Crown of the Magi": advancement and recognition, often after long effort.',
  'compound.22':
      'Tradition advises care against illusions, over-trust and poor advice from others; keep your own judgment.',
  'compound.23': 'Called the "Royal Star of the Lion": success in plans and help from people in authority.',
  'compound.24': 'Favourable: help from people in higher positions, and warmth in love and partnership.',
  'compound.25': 'Strength gained through experience and observation; early trials, later steadiness.',
  'compound.26': 'Tradition advises care with partnerships, speculation and others\' advice; keep agreements clear.',
  'compound.27': 'Called "The Sceptre": authority and reward from your own thinking and creative work.',
  'compound.28': 'Promise and progress that can be lost through misplaced trust; tradition advises careful agreements and saving for the future.',
  'compound.29': 'Tradition advises care in close relationships and in choosing whom to rely on.',
  'compound.30': 'Thoughtful reflection and mental strength; neither fortunate nor unfortunate, it depends on outlook.',
  'compound.31': 'Like 30 but more self-contained; a thinker who may prefer solitude.',
  'compound.32': 'Linked with bringing people together and persuasion; favourable when you hold to your own judgment.',
  'compound.33': 'Cheiro reads it like 24: help from people in higher positions and warmth in relationships.',
  'compound.34': 'Cheiro reads it like 25: strength gained through experience; early trials, later steadiness.',
  'compound.35': 'Cheiro reads it like 26: tradition advises care with partnerships and speculation.',
  'compound.36': 'Cheiro reads it like 27: authority and reward from your own thinking and work.',
  'compound.37': 'Favourable for friendship, love and partnership; harmonious associations.',
  'compound.38': 'Cheiro reads it like 29: tradition advises care in choosing whom to rely on.',
  'compound.39': 'Cheiro reads it like 30: thoughtful reflection; it depends on outlook.',
  'compound.40': 'Cheiro reads it like 31: self-contained, thoughtful, may prefer solitude.',
  'compound.41': 'Cheiro reads it like 32: bringing people together; favourable with independent judgment.',
  'compound.42': 'Cheiro reads it like 24: help from people in higher positions and warmth in relationships.',
  'compound.43':
      'Linked with upheaval and opposition; tradition advises patience, flexibility and avoiding needless conflict.',
  'compound.44': 'Cheiro reads it like 26: tradition advises care with partnerships and speculation.',
  'compound.45': 'Cheiro reads it like 27: authority and reward from your own thinking and work.',
  'compound.46': 'Cheiro reads it like 37: favourable for friendship, love and partnership.',
  'compound.47': 'Cheiro reads it like 29: tradition advises care in choosing whom to rely on.',
  'compound.48': 'Cheiro reads it like 30: thoughtful reflection; it depends on outlook.',
  'compound.49': 'Cheiro reads it like 31: self-contained, thoughtful, may prefer solitude.',
  'compound.50': 'Cheiro reads it like 32: bringing people together; favourable with independent judgment.',
  'compound.51':
      'Linked with bold action and sudden advancement; tradition advises watching for rivals and acting with care.',
  'compound.52': 'Cheiro reads it like 43: tradition advises patience and flexibility in times of upheaval.',

  // Personal year / month / day
  'cycle.year': 'Personal year = birth day + birth month + current year, reduced to one digit. It is read as your theme for the calendar year, within a nine-year cycle.',
  'cycle.month': 'Personal month = personal year + calendar month, reduced. A shorter theme within the year.',
  'cycle.day': 'Personal day = personal month + calendar day, reduced. The tone of a single day.',
  'cycle.1': 'New beginnings: start projects, take initiative, plant seeds.',
  'cycle.2': 'Patience and cooperation: relationships, slower progress, listening.',
  'cycle.3': 'Expression: creativity, social life, communication and joy.',
  'cycle.4': 'Foundations: steady work, organising, health routines.',
  'cycle.5': 'Change: travel, variety, freedom; stay adaptable.',
  'cycle.6': 'Home and responsibility: family, care, commitments.',
  'cycle.7': 'Reflection: study, rest, inner work and review.',
  'cycle.8': 'Effort and results: career, finances, practical decisions.',
  'cycle.9': 'Completion: finishing, letting go, generosity; making room for what comes next.',

  // About the methods
  'about.pythagorean': 'Pythagorean (Western): letters A-Z take the values 1-9 in order (A=1 ... I=9, J=1 ...). It gives the Life Path, Expression, Soul Urge and Personality numbers; the master numbers 11, 22 and 33 are kept unreduced.',
  'about.chaldean': 'Chaldean: an older system that gives letters the values 1-8 by their sound (9 is held sacred and not given to any letter). The total before reduction is read as a compound number in Cheiro\'s tradition.',
  'about.indian': 'Indian numerology: Mulank (birth day) and Bhagyank (whole date) are each tied to a planet: 1 Sun, 2 Moon, 3 Jupiter, 4 Rahu, 5 Mercury, 6 Venus, 7 Ketu, 8 Saturn, 9 Mars. They are always reduced to 1-9.',
  'about.loshu': 'Lo Shu: an ancient Chinese 3×3 magic square. Birth date digits are placed in it to see which numbers are strong, repeated or missing; Indian numerologists commonly add the Mulank and Bhagyank.',
  'about.honest': 'Numerology is a traditional, symbolic system. There is no scientific evidence that numbers predict events or character. Read this as a prompt for reflection; your choices and efforts matter more than any number.',
};
