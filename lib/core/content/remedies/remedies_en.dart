import '../../astro/constants.dart';
import 'remedies_content.dart';

const _stotraSource = 'Navagraha Stotra, attributed to Sage Vyasa (public domain)';
const _beejSource = 'Common practice (beej mantras as widely used in graha shanti)';
const _common = 'Common practice';
const _japaNote =
    'A commonly cited total, usually spread over many days (for example 108 repetitions daily). Traditions differ; some follow the Vimshottari years × 1000.';

const remediesEn = RemediesContent(
  intro:
      'Remedies (upayas) are traditional spiritual and ethical practices linked with the planets. '
      'They are optional, they are not a substitute for medical, legal or financial help, and '
      'their effects cannot be measured or promised. Many astrologers consider sincere conduct, '
      'service and discipline to be the most important remedies of all.',
  gemNote:
      'Gemstones are a traditional association only. Many astrologers recommend them only after a '
      'careful study of the whole chart, some advise against them entirely, and no gemstone is '
      'required. A stone may not suit everyone. Mantra, charity and conduct are free and are '
      'considered effective in the same traditions.',
  personalNote:
      'These suggestions are drawn automatically from traditional rules for your chart. They are '
      'optional spiritual practices, not predictions or prescriptions. Choose only what feels '
      'meaningful to you, and never let a remedy replace practical action or professional advice.',
  grahas: [
    GrahaRemedy(
      planet: Planet.sun,
      name: 'Surya (Sun)',
      signifies: 'Soul, vitality, father, authority, confidence and leadership.',
      deity: 'BPHS (ch. 3) names Agni as the deity of the Sun. In common worship: Surya, and Shiva.',
      day: 'Sunday (Ravivara)',
      colour: 'Copper red, saffron (BPHS ch. 3)',
      direction: 'East (BPHS ch. 3)',
      beej: Mantra(
        devanagari: 'ॐ ह्रां ह्रीं ह्रौं सः सूर्याय नमः',
        iast: 'oṃ hrāṃ hrīṃ hrauṃ saḥ sūryāya namaḥ',
        meaning: 'Om, salutations to Surya (with his seed syllables).',
        source: _beejSource,
      ),
      stotra: Mantra(
        devanagari: 'जपाकुसुमसंकाशं काश्यपेयं महाद्युतिम्।\nतमोऽरिं सर्वपापघ्नं प्रणतोऽस्मि दिवाकरम्॥',
        iast: 'japākusuma-saṅkāśaṃ kāśyapeyaṃ mahādyutim |\ntamo\'riṃ sarvapāpaghnaṃ praṇato\'smi divākaram ||',
        meaning:
            'I bow to the maker of the day, red like the hibiscus flower, son of Kashyapa, of great '
            'radiance, enemy of darkness and remover of all wrongs.',
        source: _stotraSource,
      ),
      japa: '7,000. $_japaNote',
      charity:
          'Wheat, jaggery, copper vessels or red/orange cloth, given to those in need, '
          'traditionally on Sunday morning.',
      fasting: 'Sunday fast (Ravivar vrat), often with one simple meal before sunset. Common practice.',
      gem: GemInfo(primary: 'Ruby (Manikya)', upratna: 'Red garnet, red spinel'),
      rudraksha: '1 mukhi or 12 mukhi (common association)',
      yantra: 'Surya Yantra',
      lifestyle: [
        'Rise before sunrise and offer water to the rising Sun (Surya arghya).',
        'Practise Surya Namaskar.',
        'Respect your father and people in authority; take responsibility without ego.',
        'Keep your word and act with integrity.',
      ],
    ),
    GrahaRemedy(
      planet: Planet.moon,
      name: 'Chandra (Moon)',
      signifies: 'Mind, emotions, mother, comfort, nourishment and public life.',
      deity: 'BPHS (ch. 3) names Varuna (the waters) as the deity of the Moon. In common worship: Shiva and Parvati (Gauri).',
      day: 'Monday (Somavara)',
      colour: 'White, silver (BPHS ch. 3)',
      direction: 'North-west (BPHS ch. 3)',
      beej: Mantra(
        devanagari: 'ॐ श्रां श्रीं श्रौं सः चन्द्रमसे नमः',
        iast: 'oṃ śrāṃ śrīṃ śrauṃ saḥ candramase namaḥ',
        meaning: 'Om, salutations to Chandra (with his seed syllables).',
        source: _beejSource,
      ),
      stotra: Mantra(
        devanagari: 'दधिशङ्खतुषाराभं क्षीरोदार्णवसम्भवम्।\nनमामि शशिनं सोमं शम्भोर्मुकुटभूषणम्॥',
        iast: 'dadhi-śaṅkha-tuṣārābhaṃ kṣīrodārṇava-sambhavam |\nnamāmi śaśinaṃ somaṃ śambhor mukuṭa-bhūṣaṇam ||',
        meaning:
            'I bow to the Moon, Soma, white like curd, conch and snow, born from the ocean of milk, '
            'the ornament on Shiva\'s crown.',
        source: _stotraSource,
      ),
      japa: '11,000. $_japaNote',
      charity: 'Rice, milk, white cloth, or silver, given to those in need, traditionally on Monday.',
      fasting: 'Monday fast (Somvar vrat), often observed with Shiva worship. Common practice.',
      gem: GemInfo(primary: 'Pearl (Moti)', upratna: 'Moonstone'),
      rudraksha: '2 mukhi (common association)',
      yantra: 'Chandra Yantra',
      lifestyle: [
        'Care for your mother and mother figures.',
        'Protect your sleep and rest; keep regular routines.',
        'Spend time near water, and drink enough water.',
        'Practise calming meditation or prayer, especially on full-moon evenings.',
      ],
    ),
    GrahaRemedy(
      planet: Planet.mars,
      name: 'Mangala (Mars)',
      signifies: 'Energy, courage, siblings, property, discipline and drive.',
      deity: 'BPHS (ch. 3) names Kartikeya (Skanda) as the deity of Mars. In common worship: Hanuman and Kartikeya.',
      day: 'Tuesday (Mangalavara)',
      colour: 'Blood red (BPHS ch. 3)',
      direction: 'South (BPHS ch. 3)',
      beej: Mantra(
        devanagari: 'ॐ क्रां क्रीं क्रौं सः भौमाय नमः',
        iast: 'oṃ krāṃ krīṃ krauṃ saḥ bhaumāya namaḥ',
        meaning: 'Om, salutations to Bhauma, son of the Earth (with his seed syllables).',
        source: _beejSource,
      ),
      stotra: Mantra(
        devanagari: 'धरणीगर्भसम्भूतं विद्युत्कान्तिसमप्रभम्।\nकुमारं शक्तिहस्तं तं मङ्गलं प्रणमाम्यहम्॥',
        iast:
            'dharaṇī-garbha-sambhūtaṃ vidyut-kānti-samaprabham |\nkumāraṃ śakti-hastaṃ taṃ maṅgalaṃ praṇamāmy aham ||',
        meaning:
            'I bow to Mangala, born of the Earth, shining like lightning, the youthful one who '
            'holds a spear.',
        source: _stotraSource,
      ),
      japa: '10,000. $_japaNote',
      charity: 'Red lentils (masoor), jaggery or red cloth, given to those in need, traditionally on Tuesday.',
      fasting: 'Tuesday fast, often with Hanuman worship. Common practice.',
      gem: GemInfo(primary: 'Red coral (Moonga)', upratna: 'Carnelian'),
      rudraksha: '3 mukhi (common association)',
      yantra: 'Mangal Yantra',
      lifestyle: [
        'Regular physical exercise and sport to channel energy.',
        'Pause before reacting in anger; practise patience.',
        'Support your siblings.',
        'Recite the Hanuman Chalisa (common practice).',
      ],
    ),
    GrahaRemedy(
      planet: Planet.mercury,
      name: 'Budha (Mercury)',
      signifies: 'Intellect, speech, learning, trade, writing and communication.',
      deity: 'BPHS (ch. 3) names Vishnu as the deity of Mercury. In common worship: Vishnu and Ganesha.',
      day: 'Wednesday (Budhavara)',
      colour: 'Green, like durva grass (BPHS ch. 3)',
      direction: 'North (BPHS ch. 3)',
      beej: Mantra(
        devanagari: 'ॐ ब्रां ब्रीं ब्रौं सः बुधाय नमः',
        iast: 'oṃ brāṃ brīṃ brauṃ saḥ budhāya namaḥ',
        meaning: 'Om, salutations to Budha (with his seed syllables).',
        source: _beejSource,
      ),
      stotra: Mantra(
        devanagari: 'प्रियङ्गुकलिकाश्यामं रूपेणाप्रतिमं बुधम्।\nसौम्यं सौम्यगुणोपेतं तं बुधं प्रणमाम्यहम्॥',
        iast: 'priyaṅgu-kalikā-śyāmaṃ rūpeṇāpratimaṃ budham |\nsaumyaṃ saumya-guṇopetaṃ taṃ budhaṃ praṇamāmy aham ||',
        meaning:
            'I bow to Budha, dark like the priyangu bud, of matchless form, gentle and endowed with '
            'gentle qualities.',
        source: _stotraSource,
      ),
      japa: '9,000. $_japaNote',
      charity:
          'Green moong lentils, green cloth, or books and stationery for students in need, traditionally on Wednesday.',
      fasting: 'Wednesday fast. Common practice.',
      gem: GemInfo(primary: 'Emerald (Panna)', upratna: 'Peridot, green tourmaline'),
      rudraksha: '4 mukhi (common association)',
      yantra: 'Budha Yantra',
      lifestyle: [
        'Read, write and keep learning something new.',
        'Speak truthfully and kindly; avoid gossip.',
        'Keep accounts and paperwork in order.',
        'Help children or students with their studies.',
      ],
    ),
    GrahaRemedy(
      planet: Planet.jupiter,
      name: 'Guru (Jupiter)',
      signifies: 'Wisdom, teachers, children, dharma, prosperity and guidance.',
      deity:
          'BPHS (ch. 3) names Indra as the deity of Jupiter. In common worship: Brihaspati, Vishnu and Dakshinamurti.',
      day: 'Thursday (Guruvara)',
      colour: 'Yellow, golden (BPHS ch. 3)',
      direction: 'North-east (BPHS ch. 3)',
      beej: Mantra(
        devanagari: 'ॐ ग्रां ग्रीं ग्रौं सः गुरवे नमः',
        iast: 'oṃ grāṃ grīṃ grauṃ saḥ gurave namaḥ',
        meaning: 'Om, salutations to the Guru (with his seed syllables).',
        source: _beejSource,
      ),
      stotra: Mantra(
        devanagari: 'देवानां च ऋषीणां च गुरुं काञ्चनसन्निभम्।\nबुद्धिभूतं त्रिलोकेशं तं नमामि बृहस्पतिम्॥',
        iast: 'devānāṃ ca ṛṣīṇāṃ ca guruṃ kāñcana-sannibham |\nbuddhi-bhūtaṃ trilokeśaṃ taṃ namāmi bṛhaspatim ||',
        meaning:
            'I bow to Brihaspati, teacher of the gods and sages, golden in hue, wisdom itself, '
            'lord of the three worlds.',
        source: _stotraSource,
      ),
      japa: '19,000. $_japaNote',
      charity: 'Chana dal, turmeric, yellow cloth, or books, given to those in need or to teachers and students, traditionally on Thursday.',
      fasting: 'Thursday fast (Guruvar vrat). Common practice.',
      gem: GemInfo(primary: 'Yellow sapphire (Pukhraj)', upratna: 'Citrine, yellow topaz'),
      rudraksha: '5 mukhi (common association)',
      yantra: 'Guru Yantra',
      lifestyle: [
        'Respect your teachers, elders and mentors.',
        'Study scriptures or wisdom literature regularly.',
        'Share knowledge freely and mentor others.',
        'Be generous within your means.',
      ],
    ),
    GrahaRemedy(
      planet: Planet.venus,
      name: 'Shukra (Venus)',
      signifies: 'Love, relationships, art, beauty, comfort and refinement.',
      deity: 'BPHS (ch. 3) names Shachi (Indrani) as the deity of Venus. In common worship: Lakshmi.',
      day: 'Friday (Shukravara)',
      colour: 'White, variegated (BPHS ch. 3)',
      direction: 'South-east (BPHS ch. 3)',
      beej: Mantra(
        devanagari: 'ॐ द्रां द्रीं द्रौं सः शुक्राय नमः',
        iast: 'oṃ drāṃ drīṃ drauṃ saḥ śukrāya namaḥ',
        meaning: 'Om, salutations to Shukra (with his seed syllables).',
        source: _beejSource,
      ),
      stotra: Mantra(
        devanagari: 'हिमकुन्दमृणालाभं दैत्यानां परमं गुरुम्।\nसर्वशास्त्रप्रवक्तारं भार्गवं प्रणमाम्यहम्॥',
        iast: 'hima-kunda-mṛṇālābhaṃ daityānāṃ paramaṃ gurum |\nsarva-śāstra-pravaktāraṃ bhārgavaṃ praṇamāmy aham ||',
        meaning:
            'I bow to Bhargava (Shukra), white like snow, jasmine and lotus stalk, the great '
            'teacher of the daityas and expounder of all the sciences.',
        source: _stotraSource,
      ),
      japa: '16,000. $_japaNote',
      charity: 'White rice, curd, sugar or white clothes, given to those in need, traditionally on Friday.',
      fasting: 'Friday fast, often with Lakshmi or Santoshi Mata worship. Common practice.',
      gem: GemInfo(primary: 'Diamond (Heera)', upratna: 'White sapphire, white zircon'),
      rudraksha: '6 mukhi (common association)',
      yantra: 'Shukra Yantra',
      lifestyle: [
        'Treat partners and everyone in relationships with respect and kindness.',
        'Make time for music, art or other creative work.',
        'Keep yourself and your surroundings clean and pleasant.',
        'Enjoy comforts with moderation.',
      ],
    ),
    GrahaRemedy(
      planet: Planet.saturn,
      name: 'Shani (Saturn)',
      signifies: 'Discipline, hard work, patience, service, longevity and karma.',
      deity: 'BPHS (ch. 3) names Brahma as the deity of Saturn. In common worship: Shani Dev and Hanuman.',
      day: 'Saturday (Shanivara)',
      colour: 'Black, dark blue (BPHS ch. 3)',
      direction: 'West (BPHS ch. 3)',
      beej: Mantra(
        devanagari: 'ॐ प्रां प्रीं प्रौं सः शनैश्चराय नमः',
        iast: 'oṃ prāṃ prīṃ prauṃ saḥ śanaiścarāya namaḥ',
        meaning: 'Om, salutations to Shanaishchara, the slow-moving one (with his seed syllables).',
        source: _beejSource,
      ),
      stotra: Mantra(
        devanagari: 'नीलाञ्जनसमाभासं रविपुत्रं यमाग्रजम्।\nछायामार्तण्डसम्भूतं तं नमामि शनैश्चरम्॥',
        iast: 'nīlāñjana-samābhāsaṃ ravi-putraṃ yamāgrajam |\nchāyā-mārtaṇḍa-sambhūtaṃ taṃ namāmi śanaiścaram ||',
        meaning:
            'I bow to Shanaishchara, dark like blue collyrium, son of the Sun and elder brother of '
            'Yama, born of Chhaya and Martanda.',
        source: _stotraSource,
      ),
      japa: '23,000. $_japaNote',
      charity:
          'Black sesame, mustard oil, iron utensils, black cloth or blankets, given to elderly '
          'people, workers or anyone in need, traditionally on Saturday.',
      fasting: 'Saturday fast (Shanivar vrat). Common practice.',
      gem: GemInfo(primary: 'Blue sapphire (Neelam)', upratna: 'Amethyst, lapis lazuli'),
      rudraksha: '7 mukhi (common association)',
      yantra: 'Shani Yantra',
      lifestyle: [
        'Serve elderly people, workers and those less fortunate.',
        'Be punctual, disciplined and honest in work.',
        'Finish what you start; practise patience.',
        'Recite the Hanuman Chalisa or Dasharatha\'s Shani Stotra (common practice).',
      ],
    ),
    GrahaRemedy(
      planet: Planet.rahu,
      name: 'Rahu (North node)',
      signifies: 'Ambition, the unconventional, foreign lands, technology and intense desires.',
      deity: 'Not listed with the seven planets in BPHS ch. 3. In common worship: Durga, and Bhairava.',
      day: 'Saturday (common practice)',
      colour: 'Smoky, dark (common association)',
      direction: 'South-west (BPHS ch. 3)',
      beej: Mantra(
        devanagari: 'ॐ भ्रां भ्रीं भ्रौं सः राहवे नमः',
        iast: 'oṃ bhrāṃ bhrīṃ bhrauṃ saḥ rāhave namaḥ',
        meaning: 'Om, salutations to Rahu (with his seed syllables).',
        source: _beejSource,
      ),
      stotra: Mantra(
        devanagari: 'अर्धकायं महावीर्यं चन्द्रादित्यविमर्दनम्।\nसिंहिकागर्भसम्भूतं तं राहुं प्रणमाम्यहम्॥',
        iast: 'ardha-kāyaṃ mahā-vīryaṃ candrāditya-vimardanam |\nsiṃhikā-garbha-sambhūtaṃ taṃ rāhuṃ praṇamāmy aham ||',
        meaning:
            'I bow to Rahu, the half-bodied one of great strength, who eclipses the Moon and the '
            'Sun, born of Simhika.',
        source: _stotraSource,
      ),
      japa: '18,000. $_japaNote',
      charity: 'Black gram (urad), blankets or coconut, given to those in need, traditionally on Saturday.',
      fasting: 'Saturday fast is commonly observed for Rahu as well. Common practice.',
      gem: GemInfo(primary: 'Hessonite garnet (Gomed)', upratna: 'Varies between traditions'),
      rudraksha: '8 mukhi (common association)',
      yantra: 'Rahu Yantra',
      lifestyle: [
        'Avoid intoxicants and shortcuts; stay truthful.',
        'Practise mindfulness to manage restlessness and cravings.',
        'Keep good company and limit compulsive screen use.',
        'Recite the Durga Saptashati or Durga Chalisa (common practice).',
      ],
    ),
    GrahaRemedy(
      planet: Planet.ketu,
      name: 'Ketu (South node)',
      signifies: 'Detachment, spirituality, intuition, past skills and liberation (moksha).',
      deity: 'Not listed with the seven planets in BPHS ch. 3. In common worship: Ganesha.',
      day: 'Tuesday or Thursday (common practice; traditions differ)',
      colour: 'Smoky, multicoloured (common association)',
      direction: 'Not listed in BPHS ch. 3 (often grouped with Rahu)',
      beej: Mantra(
        devanagari: 'ॐ स्रां स्रीं स्रौं सः केतवे नमः',
        iast: 'oṃ srāṃ srīṃ srauṃ saḥ ketave namaḥ',
        meaning: 'Om, salutations to Ketu (with his seed syllables).',
        source: _beejSource,
      ),
      stotra: Mantra(
        devanagari: 'पलाशपुष्पसंकाशं तारकाग्रहमस्तकम्।\nरौद्रं रौद्रात्मकं घोरं तं केतुं प्रणमाम्यहम्॥',
        iast: 'palāśa-puṣpa-saṅkāśaṃ tārakā-graha-mastakam |\nraudraṃ raudrātmakaṃ ghoraṃ taṃ ketuṃ praṇamāmy aham ||',
        meaning:
            'I bow to Ketu, coloured like the palasha flower, head among the stars and planets, '
            'fierce and powerful.',
        source: _stotraSource,
      ),
      japa: '17,000. $_japaNote',
      charity:
          'Multicoloured blankets, sesame, or food for stray animals, given in a spirit of service. Common practice.',
      fasting: 'Fasting on Tuesday or during Sankashti Chaturthi is common for Ketu. Common practice.',
      gem: GemInfo(primary: 'Cat\'s eye (Lahsuniya)', upratna: 'Varies between traditions'),
      rudraksha: '9 mukhi (common association)',
      yantra: 'Ketu Yantra',
      lifestyle: [
        'Meditate regularly and keep a spiritual practice.',
        'Practise letting go of what you cannot control.',
        'Worship Ganesha before starting new work (common practice).',
        'Care for animals.',
      ],
    ),
  ],
  doshas: [
    DoshaRemedies(
      id: 'sadeSati',
      name: 'Sade Sati',
      about:
          'Saturn\'s roughly 7½-year transit over the 12th, 1st and 2nd signs from the natal Moon. '
          'Tradition links it with hard work, responsibility and maturity; it is not only a '
          'difficult time, and many people achieve a great deal during it.',
      practices: [
        RemedyPractice(
          title: 'Hanuman Chalisa',
          detail: 'Reciting the Hanuman Chalisa, especially on Saturdays and Tuesdays.',
          source: _common,
        ),
        RemedyPractice(
          title: 'Dasharatha\'s Shani Stotra',
          detail: 'The prayer to Shani attributed to King Dasharatha, recited on Saturdays.',
          source: 'Padma Purana (as commonly cited)',
        ),
        RemedyPractice(
          title: 'Service and charity',
          detail:
              'Serving elderly people and workers; giving black sesame, oil or blankets to those in need on Saturdays.',
          source: _common,
        ),
        RemedyPractice(
          title: 'Discipline',
          detail: 'Saturn is traditionally pleased by patience, honesty, punctuality and steady effort.',
          source: _common,
        ),
      ],
    ),
    DoshaRemedies(
      id: 'manglik',
      name: 'Mangal dosha',
      adultOnly: true,
      about:
          'Mars in certain houses (1, 2, 4, 7, 8 or 12) is traditionally linked with friction in '
          'marriage. Many texts list cancellations, and when both partners have it, it is '
          'traditionally considered balanced. It is one factor among many, never a verdict.',
      practices: [
        RemedyPractice(
          title: 'Hanuman worship',
          detail: 'Reciting the Hanuman Chalisa or Sundarkand, especially on Tuesdays.',
          source: _common,
        ),
        RemedyPractice(
          title: 'Mangal Chandika Stotra',
          detail: 'A prayer to Devi as Mangal Chandika, commonly recited for Mars-related concerns.',
          source: 'Brahmavaivarta Purana (as commonly cited)',
        ),
        RemedyPractice(
          title: 'Tuesday charity',
          detail: 'Giving red lentils or jaggery to those in need on Tuesdays.',
          source: _common,
        ),
        RemedyPractice(
          title: 'Conduct',
          detail: 'Patience, calm communication and regular exercise are the practical side of Mars remedies.',
          source: _common,
        ),
      ],
    ),
    DoshaRemedies(
      id: 'kaalSarp',
      name: 'Kaal Sarp dosha',
      about:
          'All planets on one side of the Rahu-Ketu axis. This is a later (20th-century) concept '
          'that does not appear in classical texts such as BPHS, and many traditional astrologers '
          'do not use it.',
      practices: [
        RemedyPractice(
          title: 'Mahamrityunjaya mantra',
          detail: 'Japa of the Mahamrityunjaya mantra (Rigveda 7.59.12) is commonly suggested.',
          source: 'Rigveda 7.59.12 (the mantra); its use here is common practice',
        ),
        RemedyPractice(
          title: 'Nag Panchami worship',
          detail: 'Prayers on Nag Panchami, and worship of Shiva.',
          source: _common,
        ),
        RemedyPractice(
          title: 'Rahu and Ketu mantras',
          detail: 'The Navagraha Stotra verses for Rahu and Ketu.',
          source: _stotraSource,
        ),
      ],
    ),
    DoshaRemedies(
      id: 'pitru',
      name: 'Pitru dosha',
      about:
          'Definitions vary widely between astrologers (for example the Sun or the 9th house '
          'afflicted by Rahu or Saturn). It is generally understood as a reminder to honour '
          'one\'s ancestors.',
      practices: [
        RemedyPractice(
          title: 'Shraddha and tarpan',
          detail: 'Offering water and prayers to ancestors, especially during Pitru Paksha and on Amavasya.',
          source: 'Garuda Purana and household tradition (as commonly cited)',
        ),
        RemedyPractice(
          title: 'Feeding those in need',
          detail: 'Feeding people in need, cows, crows or dogs in memory of ancestors.',
          source: _common,
        ),
        RemedyPractice(
          title: 'Family duties',
          detail: 'Caring for elders and keeping family values alive are considered central.',
          source: _common,
        ),
      ],
    ),
  ],
  books: [
    ClassicBook(
      title: 'Brihat Parashara Hora Shastra (BPHS)',
      author: 'Attributed to Sage Parashara',
      description: 'The foundational text of Parashari Jyotish: signs, houses, vargas, dashas, yogas and graha shanti.',
    ),
    ClassicBook(
      title: 'Phaladeepika',
      author: 'Mantreswara',
      description: 'A concise, practical classic on chart interpretation, yogas and transits (Gochara).',
    ),
    ClassicBook(
      title: 'Saravali',
      author: 'Kalyana Varma',
      description: 'An encyclopaedic text on planetary combinations and their results.',
    ),
    ClassicBook(
      title: 'Brihat Jataka',
      author: 'Varahamihira',
      description: 'A compact and authoritative work on natal astrology from the 6th century.',
    ),
    ClassicBook(
      title: 'Jataka Parijata',
      author: 'Vaidyanatha Dikshita',
      description: 'A detailed treatise on natal astrology, yogas and dashas.',
    ),
    ClassicBook(
      title: 'Hora Sara',
      author: 'Prithuyasas (son of Varahamihira)',
      description: 'A natal astrology text building on Brihat Jataka.',
    ),
    ClassicBook(
      title: 'Uttara Kalamrita',
      author: 'Kalidasa (the astrologer)',
      description: 'Known for its lists of house significations and planetary karakatvas.',
    ),
    ClassicBook(
      title: 'Jaimini Sutras (Upadesa Sutras)',
      author: 'Attributed to Sage Jaimini',
      description: 'The basis of the Jaimini system: chara karakas, arudhas and sign dashas.',
    ),
    ClassicBook(
      title: 'Lal Kitab',
      author: 'Pt. Roop Chand Joshi (1939–1952 editions)',
      description: 'A distinctive North Indian system known for its simple, practical remedies.',
    ),
    ClassicBook(
      title: 'KP Readers',
      author: 'Prof. K.S. Krishnamurti',
      description: 'The six-volume series that introduced Krishnamurti Paddhati and its sub-lord theory.',
    ),
  ],
);
