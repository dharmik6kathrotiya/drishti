import '../../core/astro/constants.dart';
import '../../core/astro/vedic/festivals.dart';
import '../../core/astro/vedic/panchang.dart';

part 'festival_texts_hi.dart';
part 'festival_texts_mr.dart';
part 'festival_texts_bn.dart';
part 'festival_texts_ta.dart';
part 'festival_texts_te.dart';
part 'festival_texts_kn.dart';
part 'festival_texts_ml.dart';

/// Festival names, descriptions and rule explanations, keyed by language.
///
/// English is complete and is the fallback. To add a language, add a
/// `_FestivalLang` instance with the same keys to [_langs]; any missing key
/// falls back to English.
class FestivalTexts {
  FestivalTexts._(this._lang);
  final _FestivalLang _lang;

  static FestivalTexts of(String languageCode) => FestivalTexts._(_langs[languageCode] ?? _langs['en']!);

  _FestivalLang get _en => _langs['en']!;

  String name(FestivalEvent e) {
    final id = e.id;
    if (id.startsWith('ekadashi_')) {
      final key = id.substring(9);
      return _lang.ekadashiNames[key] ?? _en.ekadashiNames[key] ?? _en.names['ekadashi']!;
    }
    if (id.startsWith('sankranti_')) {
      final sign = Sign.values.byName(id.substring(10));
      return _lang.sankrantiName(sign);
    }
    return _lang.names[id] ?? _en.names[id] ?? id;
  }

  String description(FestivalEvent e) {
    final id = e.id.startsWith('ekadashi_')
        ? 'ekadashi'
        : e.id.startsWith('sankranti_')
        ? (_lang.descriptions.containsKey(e.id) ? e.id : 'sankranti')
        : e.id;
    return _lang.descriptions[id] ?? _en.descriptions[id] ?? '';
  }

  String? regionalNote(FestivalEvent e) {
    final id = e.id.startsWith('ekadashi_') ? 'ekadashi' : e.id;
    return _lang.regional[id] ?? _en.regional[id];
  }

  /// Plain-language explanation of how the date was decided.
  String rule(FestivalEvent e) => _lang.ruleText(e, this);

  /// e.g. "Shukla Ekadashi of Ashadha (amanta) / Ashadha (purnimanta)".
  String tithiLabel(int tithi) {
    final paksha = tithi <= 15 ? _lang.shukla : _lang.krishna;
    final name = tithi == 15
        ? _lang.purnima
        : tithi == 30
        ? _lang.amavasya
        : _lang.tithiName(tithiNames[(tithi - 1) % 15]);
    return tithi == 15 || tithi == 30 ? name : '$paksha $name';
  }

  String monthName(int index) => _lang.monthName(lunarMonthNames[index % 12]);
}

class _FestivalLang {
  const _FestivalLang({
    required this.names,
    required this.descriptions,
    required this.regional,
    required this.ekadashiNames,
    required this.shukla,
    required this.krishna,
    required this.purnima,
    required this.amavasya,
    required this.kalaText,
    required this.specialText,
    required this.sankrantiPrefix,
    required this.signNames,
    required this.ofMonth,
    this.tithiNames = const {},
    this.monthNames = const {},
    this.adhika = 'Adhika ',
  });

  final Map<String, String> names;
  final Map<String, String> descriptions;
  final Map<String, String> regional;
  final Map<String, String> ekadashiNames;
  final String shukla;
  final String krishna;
  final String purnima;
  final String amavasya;
  final Map<Kala, String> kalaText;
  final Map<String, String> specialText;
  final String sankrantiPrefix;
  final Map<Sign, String> signNames;

  /// Pattern with {tithi}, {amanta}, {purnimanta}.
  final String ofMonth;

  /// Tithi and lunar month names in the language's script, keyed by the
  /// Sanskrit names used in panchang.dart. Missing entries use the Sanskrit.
  final Map<String, String> tithiNames;
  final Map<String, String> monthNames;

  /// Prefix for an adhika (extra) lunar month.
  final String adhika;

  String tithiName(String sanskrit) => tithiNames[sanskrit] ?? sanskrit;
  String monthName(String sanskrit) => monthNames[sanskrit] ?? sanskrit;

  String sankrantiName(Sign s) => names['sankranti_${s.name}'] ?? '${signNames[s]} $sankrantiPrefix';

  String ruleText(FestivalEvent e, FestivalTexts t) {
    final r = e.rule;
    final parts = <String>[];
    if (r.tithi != null && r.amantaMonth != null && r.kala != null && e.type != FestivalType.sankranti) {
      final tithi = t.tithiLabel(r.tithi!);
      final am = (r.adhika ? adhika : '') + t.monthName(r.amantaMonth!);
      final pm = t.monthName(r.purnimantaMonth ?? r.amantaMonth!);
      parts.add(ofMonth.replaceAll('{tithi}', tithi).replaceAll('{amanta}', am).replaceAll('{purnimanta}', pm));
      parts.add(kalaText[r.kala]!);
    }
    final special = r.special;
    if (special != null) {
      final key = '${e.id}:$special';
      final text = specialText[key] ?? specialText[special];
      if (text != null) {
        parts.add(text.replaceAll('{sign}', signNames[_signOf(e)] ?? ''));
      }
    }
    return parts.join(' ');
  }

  static Sign _signOf(FestivalEvent e) =>
      e.id.startsWith('sankranti_') ? Sign.values.byName(e.id.substring(10)) : Sign.aries;
}

const _en = _FestivalLang(
  shukla: 'Shukla',
  krishna: 'Krishna',
  purnima: 'Purnima',
  amavasya: 'Amavasya',
  sankrantiPrefix: 'Sankranti',
  ofMonth: 'Tithi: {tithi} of {amanta} (amanta calendar) / {purnimanta} (purnimanta calendar).',
  signNames: {
    Sign.aries: 'Mesha',
    Sign.taurus: 'Vrishabha',
    Sign.gemini: 'Mithuna',
    Sign.cancer: 'Karka',
    Sign.leo: 'Simha',
    Sign.virgo: 'Kanya',
    Sign.libra: 'Tula',
    Sign.scorpio: 'Vrishchika',
    Sign.sagittarius: 'Dhanu',
    Sign.capricorn: 'Makara',
    Sign.aquarius: 'Kumbha',
    Sign.pisces: 'Meena',
  },
  kalaText: {
    Kala.sunrise: 'It is kept on the day this tithi prevails at sunrise (udaya tithi).',
    Kala.madhyahna: 'It is kept on the day this tithi prevails at midday (madhyahna, the middle fifth of the daytime).',
    Kala.aparahna:
        'It is kept on the day this tithi prevails in the afternoon (aparahna, the fourth fifth of the daytime).',
    Kala.pradosh:
        'It is kept on the day this tithi prevails in the evening (pradosh kaal, about 2 h 24 min after sunset).',
    Kala.nishita: 'It is kept on the day this tithi prevails at midnight (nishita kaal, the 8th muhurta of the night).',
    Kala.moonrise: 'It is kept on the day this tithi prevails at moonrise.',
  },
  specialText: {
    'kshaya': 'This time the tithi does not touch any sunrise (a kshaya tithi), so it is kept on the day it begins.',
    'fallback_sunrise': 'This time the tithi does not fall in that part of the day, so the sunrise rule is used.',
    'vriddhi': 'The tithi touches two sunrises (vriddhi); the first day is used, as in Smarta practice.',
    'both_days':
        'The tithi falls in that part of the day on two days; the customary rule for this festival chooses this one.',
    'diwali:both_days': 'Amavasya covers the evening on two days; the second day is preferred only if Amavasya lasts at least one ghati (24 minutes) into its evening.',
    'raksha_bandhan:bhadra': 'Bhadra (Vishti karana) is avoided for tying the rakhi, as tradition advises; the window shown begins after Bhadra.',
    'holika_dahan:bhadra': 'Holika Dahan is done after Bhadra (Vishti karana) ends, within the night of Purnima.',
    'holika_dahan:no_bhadra': 'Bhadra ends before the evening, so Holika Dahan can be done in the pradosh kaal.',
    'holika_dahan:bhadra_next_evening':
        'Bhadra lasts through the whole night of Purnima, so many panchangs move Holika Dahan to the next evening.',
    'day_after_dahan': 'Holi with colours (Dhulandi) is played on the morning after Holika Dahan.',
    'sankranti':
        'The Sun enters sidereal {sign} at the moment shown, before sunset, so the day itself is the Sankranti.',
    'sankranti_after_sunset':
        'The Sun enters sidereal {sign} after sunset, so the observance (punya kaal) moves to the next day.',
    'nakshatra_shravana_simha': 'It is kept on the day the Moon is in Thiruvonam (Shravana nakshatra) at sunrise during the solar month of Chingam (Sun in Simha).',
    'eclipse_global':
        'The time shown is the eclipse maximum. Whether and how much of it is visible depends on your location.',
  },
  names: {
    'ugadi': 'Ugadi / Gudi Padwa',
    'chaitra_navratri': 'Chaitra Navratri begins',
    'ram_navami': 'Ram Navami',
    'hanuman_jayanti': 'Hanuman Jayanti',
    'akshaya_tritiya': 'Akshaya Tritiya',
    'buddha_purnima': 'Buddha Purnima',
    'guru_purnima': 'Guru Purnima',
    'nag_panchami': 'Nag Panchami',
    'raksha_bandhan': 'Raksha Bandhan',
    'janmashtami': 'Krishna Janmashtami',
    'ganesh_chaturthi': 'Ganesh Chaturthi',
    'sharad_navratri': 'Sharad Navratri begins',
    'dussehra': 'Dussehra (Vijayadashami)',
    'sharad_purnima': 'Sharad Purnima',
    'karva_chauth': 'Karva Chauth',
    'dhanteras': 'Dhanteras',
    'naraka_chaturdashi': 'Naraka Chaturdashi',
    'diwali': 'Diwali (Lakshmi Puja)',
    'govardhan_puja': 'Govardhan Puja',
    'bhai_dooj': 'Bhai Dooj',
    'chhath': 'Chhath Puja',
    'kartik_purnima': 'Kartik Purnima / Dev Deepawali',
    'vasant_panchami': 'Vasant Panchami',
    'maha_shivaratri': 'Maha Shivaratri',
    'holika_dahan': 'Holika Dahan',
    'holi': 'Holi',
    'onam': 'Onam (Thiruvonam)',
    'pradosh': 'Pradosh Vrat',
    'sankashti_chaturthi': 'Sankashti Chaturthi',
    'masik_shivaratri': 'Masik Shivaratri',
    'purnima': 'Purnima',
    'amavasya': 'Amavasya',
    'solar_eclipse': 'Solar eclipse',
    'lunar_eclipse': 'Lunar eclipse',
    'ekadashi': 'Ekadashi',
    'sankranti_capricorn': 'Makar Sankranti',
    'sankranti_aries': 'Mesha Sankranti',
  },
  ekadashiNames: {
    'kamada': 'Kamada Ekadashi',
    'varuthini': 'Varuthini Ekadashi',
    'mohini': 'Mohini Ekadashi',
    'apara': 'Apara Ekadashi',
    'nirjala': 'Nirjala Ekadashi',
    'yogini': 'Yogini Ekadashi',
    'devshayani': 'Devshayani Ekadashi',
    'kamika': 'Kamika Ekadashi',
    'shravana_putrada': 'Shravana Putrada Ekadashi',
    'aja': 'Aja Ekadashi',
    'parsva': 'Parsva (Parivartini) Ekadashi',
    'indira': 'Indira Ekadashi',
    'papankusha': 'Papankusha Ekadashi',
    'rama': 'Rama Ekadashi',
    'prabodhini': 'Prabodhini (Devutthana) Ekadashi',
    'utpanna': 'Utpanna Ekadashi',
    'mokshada': 'Mokshada Ekadashi',
    'saphala': 'Saphala Ekadashi',
    'pausha_putrada': 'Pausha Putrada Ekadashi',
    'shattila': 'Shattila Ekadashi',
    'jaya': 'Jaya Ekadashi',
    'vijaya': 'Vijaya Ekadashi',
    'amalaki': 'Amalaki Ekadashi',
    'papmochani': 'Papmochani Ekadashi',
    'padmini': 'Padmini Ekadashi (Adhika month)',
    'parama': 'Parama Ekadashi (Adhika month)',
  },
  descriptions: {
    'ugadi': 'The lunar new year in much of India, on the first day of Chaitra. Homes are cleaned and decorated, and many families hear the new year\'s Panchang read aloud.',
    'chaitra_navratri': 'Nine nights dedicated to the Goddess in her nine forms, ending with Ram Navami.',
    'ram_navami': 'The birth of Lord Rama, celebrated at midday with prayers, recitation of the Ramayana and community gatherings.',
    'hanuman_jayanti':
        'Celebrates Lord Hanuman, remembered for strength, devotion and service. Many recite the Hanuman Chalisa.',
    'akshaya_tritiya': '"Akshaya" means never-diminishing. Traditionally considered an auspicious day to begin good work, give in charity and make vows.',
    'buddha_purnima':
        'Marks the birth, enlightenment and passing of the Buddha, observed with meditation, kindness and charity.',
    'guru_purnima': 'A day to honour teachers and the tradition of learning, also associated with Sage Vyasa.',
    'nag_panchami': 'Serpent deities are honoured with prayers; in many places it is also a day of respect for living snakes and nature.',
    'raksha_bandhan': 'Siblings celebrate their bond: a rakhi is tied as a symbol of care and mutual protection.',
    'janmashtami': 'The birth of Lord Krishna, celebrated with fasting, devotional songs and midnight worship.',
    'ganesh_chaturthi': 'The festival of Lord Ganesha, remover of obstacles. Images of Ganesha are welcomed into homes and public pandals.',
    'sharad_navratri': 'Nine nights of worship of the Goddess in autumn, celebrated with Garba, Durga Puja and fasting in different regions.',
    'dussehra': 'Celebrates the victory of good over evil, remembering Rama\'s victory and the Goddess\'s triumph over Mahishasura.',
    'sharad_purnima': 'The autumn full moon, traditionally said to be the brightest of the year; kheer is often kept under moonlight.',
    'karva_chauth':
        'A fast observed by many married women for the well-being of their spouse, broken after seeing the Moon.',
    'dhanteras': 'The first day of the Diwali festival, honouring Dhanvantari and Lakshmi; lamps are lit and new utensils are traditionally bought.',
    'naraka_chaturdashi': 'Also called Choti Diwali; remembers Krishna\'s victory over Narakasura. In South India this day is celebrated as Deepavali.',
    'diwali': 'The festival of lights. Lakshmi and Ganesha are worshipped in the evening and homes are lit with lamps.',
    'govardhan_puja': 'Remembers Krishna lifting Govardhan hill; food offerings (Annakut) are prepared. Also Bali Pratipada in some regions.',
    'bhai_dooj': 'Sisters pray for their brothers\' well-being and brothers express their care in return.',
    'chhath': 'A festival dedicated to the Sun and Chhathi Maiya. This day is the evening offering (Sandhya Arghya) at sunset; the morning offering follows the next day.',
    'kartik_purnima': 'The full moon of Kartika, when lamps are offered at rivers and ghats; also Dev Deepawali in Varanasi and Guru Nanak Jayanti for Sikhs.',
    'vasant_panchami': 'Welcomes spring and honours Saraswati, the goddess of learning and the arts.',
    'maha_shivaratri': 'The great night of Lord Shiva, observed with fasting, night-long worship and meditation.',
    'holika_dahan':
        'A bonfire on the night of Phalguna Purnima remembers Prahlad\'s devotion and the burning away of negativity.',
    'holi': 'The festival of colours, celebrating spring, friendship and new beginnings.',
    'onam':
        'Kerala\'s harvest festival welcoming King Mahabali, celebrated with pookalam, sadya feasts and boat races.',
    'pradosh': 'A twice-monthly evening observance for Lord Shiva on Trayodashi. It is often named after its weekday (e.g. Soma Pradosh on Monday).',
    'sankashti_chaturthi': 'A monthly fast for Lord Ganesha on Krishna Chaturthi, completed after seeing the Moon.',
    'masik_shivaratri':
        'The monthly Shivaratri on Krishna Chaturdashi, observed with night-time worship of Lord Shiva.',
    'purnima': 'Full Moon day, traditionally used for fasting, Satyanarayan puja and charity.',
    'amavasya': 'New Moon day, traditionally used for remembering ancestors (pitru tarpan) and quiet reflection.',
    'ekadashi': 'The 11th day of each lunar fortnight, traditionally kept as a fast day dedicated to Lord Vishnu.',
    'sankranti': 'The day the Sun moves into a new sidereal sign, traditionally a time for charity and holy baths.',
    'sankranti_capricorn': 'The Sun enters Makara, marking the start of Uttarayana in tradition. Celebrated as Makar Sankranti, Pongal, Uttarayan and Magh Bihu.',
    'sankranti_aries': 'The Sun enters Mesha, the start of the solar year in many regions: Vishu, Puthandu, Baisakhi and Pana Sankranti.',
    'solar_eclipse': 'A solar eclipse. Never look at the Sun directly; use certified eclipse glasses. Many traditions observe prayers and a holy bath around the eclipse.',
    'lunar_eclipse': 'A lunar eclipse, safe to watch with the naked eye. Many traditions observe prayers and a holy bath after the eclipse ends.',
  },
  regional: {
    'ugadi': 'Called Gudi Padwa in Maharashtra and Ugadi in Karnataka, Andhra Pradesh and Telangana. Sindhi communities celebrate Cheti Chand around the same time.',
    'hanuman_jayanti': 'Dates differ by region: Chaitra Purnima in much of North India, Margazhi Amavasya in Tamil Nadu, Margashirsha Shukla Trayodashi in Karnataka, and Vaishakha Krishna Dashami in Andhra Pradesh and Telangana.',
    'janmashtami': 'Vaishnava traditions (including ISKCON) and those who give weight to Rohini nakshatra sometimes observe it a day later.',
    'ekadashi':
        'Vaishnava traditions (including ISKCON) use slightly different rules, so their Ekadashi can fall a day later.',
    'diwali': 'In South India the main Deepavali celebration is usually on Naraka Chaturdashi morning.',
    'sharad_navratri': 'In Bengal and eastern India, Durga Puja is celebrated mainly from Shashthi to Vijayadashami.',
    'dussehra': 'In Bengal it marks the immersion of Durga images; in Mysuru it is celebrated as Dasara.',
    'chhath': 'Chhath is a four-day festival: Nahay Khay, Kharna, Sandhya Arghya (this day) and Usha Arghya at the next sunrise.',
    'karva_chauth': 'Observed mainly in North and Northwest India.',
    'onam': 'Kerala panchangs also check how long Thiruvonam lasts after sunrise, so a published date can occasionally differ.',
    'sankranti_capricorn': 'In Tamil Nadu this is Thai Pongal; in Gujarat Uttarayan with kite flying; in Assam Magh Bihu; Lohri is celebrated the evening before in Punjab.',
    'sankranti_aries': 'Kerala\'s Vishu and Tamil Puthandu follow local rules about the time of the ingress, so they can differ by a day.',
    'holi': 'In Braj (Mathura, Vrindavan) Holi celebrations run for several days, and in some places colours are played on Rang Panchami.',
    'raksha_bandhan': 'Many families also follow a local almanac or family custom for the exact time.',
  },
);

const _langs = {'en': _en, 'hi': _hi, 'mr': _mr, 'bn': _bn, 'ta': _ta, 'te': _te, 'kn': _kn, 'ml': _ml};
