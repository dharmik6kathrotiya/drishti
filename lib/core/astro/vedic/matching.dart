import '../../i18n/text_ref.dart';
import '../constants.dart';

/// Ashtakoot (Guna Milan) matching, 36 points.
///
/// Score tables follow the widely used North Indian tables (as published in
/// PyJHora / saravali.de). Tables differ slightly between almanacs, which the
/// app explains to the user.
class KootaResult {
  const KootaResult(
    this.name,
    this.max,
    this.score,
    this.boyValue,
    this.girlValue,
    this.meaning, {
    required this.id,
    required this.boyIndex,
    required this.girlIndex,
    this.why = const [],
    this.doshaId,
    this.exceptions = const [],
  });

  /// How the score was reached, step by step: each person's value, the rule
  /// and the result (shown on "Why?").
  final List<TextRef> why;

  /// The traditional dosha this score forms ('nadi', 'bhakoot', 'gana',
  /// 'yoni'), if any.
  final String? doshaId;

  /// The classical exceptions checked for that dosha.
  final List<KootaException> exceptions;

  /// A classical exception cancels or reduces the dosha.
  bool get doshaCancelled => exceptions.any((e) => e.applies);

  /// 'varna', 'vashya', 'tara', 'yoni', 'maitri', 'gana', 'bhakoot', 'nadi'.
  /// The UI localizes name/meaning by id and values by index: category index
  /// for varna/vashya/tara/yoni/gana/nadi, Planet index for maitri and Sign
  /// index for bhakoot.
  final String id;
  final int boyIndex;
  final int girlIndex;
  final String name;
  final double max;
  final double score;
  final String boyValue;
  final String girlValue;
  final String meaning;
}

/// One classical exception to a dosha and whether it applies to this couple.
class KootaException {
  const KootaException(this.rule, this.applies);
  final TextRef rule;
  final bool applies;
}

class MatchInput {
  const MatchInput({required this.moonLongitude});

  /// Sidereal Moon longitude.
  final double moonLongitude;
  Sign get sign => Sign.fromLongitude(moonLongitude);
  Nakshatra get nakshatra => Nakshatra.fromLongitude(moonLongitude);
  int get pada => Nakshatra.padaOf(moonLongitude);
  double get degreeInSign => moonLongitude % 30;
}

class AshtakootResult {
  const AshtakootResult(this.kootas, this.notes, [this.noteRefs = const []]);

  /// Localizable versions of [notes].
  final List<TextRef> noteRefs;
  final List<KootaResult> kootas;

  /// Traditional exceptions (dosha cancellations) found, for transparency.
  final List<String> notes;
  double get total => kootas.fold(0, (s, k) => s + k.score);
}

class Ashtakoot {
  Ashtakoot._();

  static const _varnaNames = ['Brahmin', 'Kshatriya', 'Vaishya', 'Shudra'];

  static int _varna(Sign s) => switch (s) {
    Sign.cancer || Sign.scorpio || Sign.pisces => 0,
    Sign.aries || Sign.leo || Sign.sagittarius => 1,
    Sign.taurus || Sign.virgo || Sign.capricorn => 2,
    _ => 3,
  };

  static const _vashyaNames = ['Chatushpada', 'Manava', 'Jalachara', 'Vanachara', 'Keeta'];

  static int _vashya(MatchInput m) {
    final firstHalf = m.degreeInSign < 15;
    return switch (m.sign) {
      Sign.aries || Sign.taurus => 0,
      Sign.gemini || Sign.virgo || Sign.libra || Sign.aquarius => 1,
      Sign.cancer || Sign.pisces => 2,
      Sign.leo => 3,
      Sign.scorpio => 4,
      Sign.sagittarius => firstHalf ? 1 : 0,
      Sign.capricorn => firstHalf ? 0 : 2,
    };
  }

  // Rows: girl, columns: boy.
  static const _vashyaTable = [
    [2.0, 0.5, 1.0, 0.0, 2.0],
    [0.5, 2.0, 0.0, 0.0, 0.0],
    [1.0, 0.0, 2.0, 2.0, 2.0],
    [0.0, 0.0, 2.0, 2.0, 0.0],
    [1.0, 0.0, 1.0, 0.0, 2.0],
  ];

  static const _taraNames = [
    'Janma',
    'Sampat',
    'Vipat',
    'Kshema',
    'Pratyari',
    'Sadhaka',
    'Naidhana',
    'Mitra',
    'Parama Mitra',
  ];

  static const yoniNames = [
    'Horse',
    'Elephant',
    'Sheep',
    'Serpent',
    'Dog',
    'Cat',
    'Rat',
    'Cow',
    'Buffalo',
    'Tiger',
    'Deer',
    'Monkey',
    'Mongoose',
    'Lion',
  ];
  static const yoniOfNakshatra = [
    0,
    1,
    2,
    3,
    3,
    4,
    5,
    2,
    5,
    6,
    6,
    7,
    8,
    9,
    8,
    9,
    10,
    10,
    4,
    11,
    12,
    11,
    13,
    0,
    13,
    7,
    1,
  ];
  static const _yoniTable = [
    [4, 2, 2, 3, 2, 2, 2, 1, 0, 1, 1, 3, 2, 1],
    [2, 4, 3, 3, 2, 2, 2, 2, 3, 1, 2, 3, 2, 0],
    [2, 3, 4, 2, 1, 2, 1, 3, 3, 1, 2, 0, 3, 1],
    [3, 3, 2, 4, 2, 1, 1, 1, 1, 2, 2, 2, 0, 2],
    [2, 2, 1, 2, 4, 2, 1, 2, 2, 1, 0, 2, 1, 1],
    [2, 2, 2, 1, 2, 4, 0, 2, 2, 1, 3, 3, 2, 1],
    [2, 2, 1, 1, 1, 0, 4, 2, 2, 2, 2, 2, 1, 2],
    [1, 2, 3, 1, 2, 2, 2, 4, 3, 0, 3, 2, 2, 1],
    [0, 3, 3, 1, 2, 2, 2, 3, 4, 1, 2, 2, 2, 1],
    [1, 1, 1, 2, 1, 1, 2, 0, 1, 4, 1, 1, 2, 1],
    [1, 2, 2, 2, 0, 3, 2, 3, 2, 1, 4, 2, 2, 1],
    [3, 3, 0, 2, 2, 3, 2, 2, 2, 1, 2, 4, 3, 2],
    [2, 2, 3, 0, 1, 2, 1, 2, 2, 2, 2, 3, 4, 2],
    [1, 0, 1, 2, 1, 1, 2, 1, 1, 1, 1, 2, 2, 4],
  ];

  // Lords in order Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn.
  static const _lordOrder = [
    Planet.sun,
    Planet.moon,
    Planet.mars,
    Planet.mercury,
    Planet.jupiter,
    Planet.venus,
    Planet.saturn,
  ];
  static const _maitriTable = [
    [5.0, 5.0, 5.0, 4.0, 5.0, 0.0, 0.0],
    [5.0, 5.0, 4.0, 1.0, 4.0, 0.5, 0.5],
    [5.0, 4.0, 5.0, 0.5, 5.0, 3.0, 0.5],
    [4.0, 1.0, 0.5, 5.0, 0.5, 5.0, 4.0],
    [5.0, 4.0, 5.0, 0.5, 5.0, 0.5, 3.0],
    [0.0, 0.5, 3.0, 5.0, 0.5, 5.0, 5.0],
    [0.0, 0.5, 0.5, 4.0, 3.0, 5.0, 5.0],
  ];

  static const ganaNames = ['Deva', 'Manushya', 'Rakshasa'];
  static int gana(Nakshatra n) {
    const deva = [0, 4, 6, 7, 12, 14, 16, 21, 26];
    const manushya = [1, 3, 5, 10, 11, 19, 20, 24, 25];
    if (deva.contains(n.index)) return 0;
    if (manushya.contains(n.index)) return 1;
    return 2;
  }

  // Rows: girl, columns: boy.
  static const _ganaTable = [
    [6.0, 6.0, 0.0],
    [5.0, 6.0, 0.0],
    [1.0, 0.0, 6.0],
  ];

  static const nadiNames = ['Adi (Vata)', 'Madhya (Pitta)', 'Antya (Kapha)'];
  static int nadi(Nakshatra n) => const [0, 1, 2, 2, 1, 0][n.index % 6];

  static AshtakootResult match({required MatchInput boy, required MatchInput girl}) {
    final notes = <String>[];
    final noteRefs = <TextRef>[];
    final bl = boy.sign.lord, gl = girl.sign.lord;
    final lordsFriendly = bl == gl || (Dignity.naturalRelation(bl, gl) == 1 && Dignity.naturalRelation(gl, bl) == 1);

    // 1. Varna
    final bv = _varna(boy.sign), gv = _varna(girl.sign);
    final varnaScore = bv <= gv ? 1.0 : 0.0;
    final varna = KootaResult(
      'Varna',
      1,
      varnaScore,
      _varnaNames[bv],
      _varnaNames[gv],
      'Spiritual and ego compatibility.',
      id: 'varna',
      boyIndex: bv,
      girlIndex: gv,
      why: [
        TextRef('match.why.varna.of', {'groom': true, 'sign': boy.sign, 'value': TextRef('match.varna.$bv')}),
        TextRef('match.why.varna.of', {'groom': false, 'sign': girl.sign, 'value': TextRef('match.varna.$gv')}),
        const TextRef('match.why.varna.rule'),
        TextRef('match.why.varna.result', {'ok': varnaScore > 0}),
      ],
    );

    // 2. Vashya
    final bva = _vashya(boy), gva = _vashya(girl);
    final vashyaScore = _vashyaTable[gva][bva];
    final vashya = KootaResult(
      'Vashya',
      2,
      vashyaScore,
      _vashyaNames[bva],
      _vashyaNames[gva],
      'Mutual attraction and influence.',
      id: 'vashya',
      boyIndex: bva,
      girlIndex: gva,
      why: [
        for (final (groom, m, g) in [(true, boy, bva), (false, girl, gva)])
          TextRef('match.why.vashya.of', {
            'groom': groom,
            'sign': m.sign,
            'deg': _deg(m.degreeInSign),
            'value': TextRef('match.vashya.$g'),
          }),
        const TextRef('match.why.vashya.rule'),
        TextRef('match.why.result', {'score': _fmt(vashyaScore), 'max': '2'}),
      ],
    );

    // 3. Tara: counted both ways, 1.5 points per favourable direction.
    final g2b = ((boy.nakshatra.index - girl.nakshatra.index) % 27) + 1;
    final b2g = ((girl.nakshatra.index - boy.nakshatra.index) % 27) + 1;
    int taraOf(int n) => ((n - 1) % 9);
    bool good(int t) => t != 2 && t != 4 && t != 6; // Vipat, Pratyari, Naidhana
    final t1 = taraOf(g2b), t2 = taraOf(b2g);
    final taraScore = (good(t1) ? 1.5 : 0.0) + (good(t2) ? 1.5 : 0.0);
    final tara = KootaResult(
      'Tara',
      3,
      taraScore,
      _taraNames[t2],
      _taraNames[t1],
      'Health and well-being of the couple (birth-star harmony).',
      id: 'tara',
      boyIndex: t2,
      girlIndex: t1,
      why: [
        for (final (from, to, n, t) in [
          (girl.nakshatra, boy.nakshatra, g2b, t1),
          (boy.nakshatra, girl.nakshatra, b2g, t2),
        ])
          TextRef('match.why.tara.count', {
            'from': from,
            'to': to,
            'n': n,
            't': t + 1,
            'value': TextRef('match.tara.$t'),
            'good': good(t),
          }),
        const TextRef('match.why.tara.rule'),
        TextRef('match.why.result', {'score': _fmt(taraScore), 'max': '3'}),
      ],
    );

    // 4. Yoni
    final by = yoniOfNakshatra[boy.nakshatra.index], gy = yoniOfNakshatra[girl.nakshatra.index];
    final yoniScore = _yoniTable[gy][by];
    final yoni = KootaResult(
      'Yoni',
      4,
      yoniScore.toDouble(),
      yoniNames[by],
      yoniNames[gy],
      'Physical and intimate compatibility.',
      id: 'yoni',
      boyIndex: by,
      girlIndex: gy,
      why: [
        for (final (groom, m, y) in [(true, boy, by), (false, girl, gy)])
          TextRef('match.why.nak.of', {'groom': groom, 'nak': m.nakshatra, 'value': TextRef('match.yoni.$y')}),
        TextRef('match.why.yoni.result', {'score': '$yoniScore', 'rel': TextRef('match.yoni.rel.$yoniScore')}),
      ],
      doshaId: yoniScore == 0 ? 'yoni' : null,
    );

    // 5. Graha Maitri
    final maitriScore = _maitriTable[_lordOrder.indexOf(gl)][_lordOrder.indexOf(bl)];
    String rel(Planet a, Planet b) => const ['enemy', 'neutral', 'friend'][Dignity.naturalRelation(a, b) + 1];
    final maitri = KootaResult(
      'Graha Maitri',
      5,
      maitriScore,
      _cap(bl.name),
      _cap(gl.name),
      'Mental compatibility and friendship (Moon-sign lords).',
      id: 'maitri',
      boyIndex: bl.index,
      girlIndex: gl.index,
      why: [
        for (final (groom, m) in [(true, boy), (false, girl)])
          TextRef('match.why.maitri.of', {'groom': groom, 'sign': m.sign, 'planet': m.sign.lord}),
        if (bl == gl)
          TextRef('match.why.maitri.same', {'planet': bl})
        else
          TextRef('match.why.maitri.rel', {
            'a': bl,
            'b': gl,
            'rel': TextRef('match.rel.${rel(bl, gl)}'),
            'rel2': TextRef('match.rel.${rel(gl, bl)}'),
          }),
        TextRef('match.why.result', {'score': _fmt(maitriScore), 'max': '5'}),
      ],
    );

    // 6. Gana
    final bg = gana(boy.nakshatra), gg = gana(girl.nakshatra);
    final ganaScore = _ganaTable[gg][bg];
    final ganaR = KootaResult(
      'Gana',
      6,
      ganaScore,
      ganaNames[bg],
      ganaNames[gg],
      'Temperament and nature.',
      id: 'gana',
      boyIndex: bg,
      girlIndex: gg,
      why: [
        for (final (groom, m, g) in [(true, boy, bg), (false, girl, gg)])
          TextRef('match.why.nak.of', {'groom': groom, 'nak': m.nakshatra, 'value': TextRef('match.gana.$g')}),
        const TextRef('match.why.gana.rule'),
        TextRef('match.why.result', {'score': _fmt(ganaScore), 'max': '6'}),
      ],
      doshaId: ganaScore == 0 ? 'gana' : null,
      exceptions: ganaScore == 0 ? [KootaException(const TextRef('match.exc.lordsFriendly'), lordsFriendly)] : const [],
    );
    if (ganaScore == 0 && lordsFriendly) noteRefs.add(const TextRef('match.note.ganaLords'));

    // 7. Bhakoot: 2/12, 5/9 and 6/8 sign relationships score zero.
    final dist = boy.sign.countTo(girl.sign), back = girl.sign.countTo(boy.sign);
    const badDistances = {2, 12, 5, 9, 6, 8};
    final bhakootBad = badDistances.contains(dist);
    final pair = dist < back ? dist : back;
    final bhakoot = KootaResult(
      'Bhakoot',
      7,
      bhakootBad ? 0 : 7,
      boy.sign.rashi,
      girl.sign.rashi,
      'Family welfare, finances and growth together.',
      id: 'bhakoot',
      boyIndex: boy.sign.index,
      girlIndex: girl.sign.index,
      why: [
        TextRef('match.why.bhakoot.count', {'a': boy.sign, 'b': girl.sign, 'n': dist, 'm': back}),
        const TextRef('match.why.bhakoot.rule'),
        if (bhakootBad)
          TextRef('match.why.bhakoot.bad', {'n': pair, 'm': 14 - pair, 'pair': TextRef('match.bhakoot.pair.$pair')})
        else
          TextRef('match.why.bhakoot.ok', {'n': pair, 'm': pair == 1 ? 1 : 14 - pair}),
      ],
      doshaId: bhakootBad ? 'bhakoot' : null,
      exceptions: bhakootBad
          ? [
              KootaException(TextRef('match.exc.sameLord', {'planet': bl}), bl == gl),
              KootaException(const TextRef('match.exc.lordsMutualFriends'), bl != gl && lordsFriendly),
            ]
          : const [],
    );
    if (bhakootBad) {
      if (bl == gl) {
        notes.add(
          'Bhakoot dosha is traditionally cancelled because both Moon signs have the same lord (${_cap(bl.name)}).',
        );
        noteRefs.add(TextRef('match.note.bhakootSameLord', {'planet': bl}));
      } else if (lordsFriendly) {
        notes.add(
          'Bhakoot dosha is traditionally considered cancelled because the Moon-sign lords are mutual friends.',
        );
        noteRefs.add(const TextRef('match.note.bhakootFriends'));
      }
    }

    // 8. Nadi
    final bn = nadi(boy.nakshatra), gn = nadi(girl.nakshatra);
    final sameNak = boy.nakshatra.index == girl.nakshatra.index;
    final nadiR = KootaResult(
      'Nadi',
      8,
      bn == gn ? 0 : 8,
      nadiNames[bn],
      nadiNames[gn],
      'Health and genetic compatibility, progeny.',
      id: 'nadi',
      boyIndex: bn,
      girlIndex: gn,
      why: [
        for (final (groom, m, n) in [(true, boy, bn), (false, girl, gn)])
          TextRef('match.why.nak.of', {'groom': groom, 'nak': m.nakshatra, 'value': TextRef('match.nadi.$n')}),
        const TextRef('match.why.nadi.rule'),
        TextRef('match.why.nadi.result', {'same': bn == gn}),
      ],
      doshaId: bn == gn ? 'nadi' : null,
      exceptions: bn == gn
          ? [
              KootaException(const TextRef('match.exc.nadiSameSign'), boy.sign == girl.sign && !sameNak),
              KootaException(const TextRef('match.exc.nadiDiffPada'), sameNak && boy.pada != girl.pada),
              KootaException(const TextRef('match.exc.nadiDiffSign'), sameNak && boy.sign != girl.sign),
            ]
          : const [],
    );
    if (bn == gn) {
      if (boy.sign == girl.sign && !sameNak) {
        notes.add('Nadi dosha is traditionally cancelled: same Moon sign but different nakshatras.');
        noteRefs.add(const TextRef('match.note.nadiSameSign'));
      } else if (sameNak && boy.pada != girl.pada) {
        notes.add('Nadi dosha is traditionally cancelled: same nakshatra but different padas.');
        noteRefs.add(const TextRef('match.note.nadiDiffPada'));
      } else if (sameNak && boy.sign != girl.sign) {
        notes.add('Nadi dosha is traditionally cancelled: same nakshatra but different Moon signs.');
        noteRefs.add(const TextRef('match.note.nadiDiffSign'));
      }
    }

    return AshtakootResult([varna, vashya, tara, yoni, maitri, ganaR, bhakoot, nadiR], notes, noteRefs);
  }

  /// Verdict id for a total: 'below', 'average', 'good' or 'excellent'.
  static String verdictId(double total) {
    if (total < 18) return 'below';
    if (total <= 24) return 'average';
    if (total <= 32) return 'good';
    return 'excellent';
  }

  /// Traditional reading of a total score.
  static String verdict(double total) {
    if (total < 18) return 'Below the traditional minimum of 18';
    if (total <= 24) return 'Average match';
    if (total <= 32) return 'Good match';
    return 'Excellent match';
  }

  static String _cap(String s) => s[0].toUpperCase() + s.substring(1);

  static String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  /// Degrees within the sign as 25°57′.
  static String _deg(double d) {
    final m = (d * 60).floor();
    return '${m ~/ 60}°${(m % 60).toString().padLeft(2, '0')}′';
  }
}
