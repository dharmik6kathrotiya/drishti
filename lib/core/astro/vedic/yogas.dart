import '../../i18n/text_ref.dart';
import '../chart.dart';
import '../constants.dart';

/// A yoga found in a chart, with the factual reason it was detected.
///
/// The English strings are kept for logs/tests; the UI renders [id],
/// [reasonRef], [noteRef] and [sourceKey] through EngineTexts so every
/// language is supported.
class Yoga {
  const Yoga({
    required this.id,
    required this.name,
    required this.reason,
    required this.meaning,
    required this.source,
    required this.reasonRef,
    required this.sourceKey,
    this.planets = const [],
    this.note,
    this.noteRef,
  });

  /// Stable id, e.g. 'gajakesari', 'ruchaka', 'raja', 'harsha'.
  final String id;
  final String name;

  /// Which planets/houses formed it, stated factually.
  final String reason;
  final String meaning;
  final String source;
  final List<Planet> planets;

  /// Cancellation or strength note, when relevant.
  final String? note;

  final TextRef reasonRef;
  final TextRef? noteRef;
  final String sourceKey;
}

/// Vedic graha drishti: every planet aspects the 7th sign from itself; Mars
/// also the 4th and 8th, Jupiter the 5th and 9th, Saturn the 3rd and 10th.
/// Rahu and Ketu are given only the 7th aspect here.
bool aspectsSign(Planet p, Sign from, Sign to) {
  final h = from.countTo(to);
  if (h == 7) return true;
  return switch (p) {
    Planet.mars => h == 4 || h == 8,
    Planet.jupiter => h == 5 || h == 9,
    Planet.saturn => h == 3 || h == 10,
    _ => false,
  };
}

const _kendra = {1, 4, 7, 10};
const _trikona = {1, 5, 9};
const _dusthana = {6, 8, 12};
const _upachaya = {3, 6, 10, 11};
const _seven = [Planet.sun, Planet.moon, Planet.mars, Planet.mercury, Planet.jupiter, Planet.venus, Planet.saturn];

/// Natural benefics used by the Moon- and Lagna-based yogas.
const _benefics = [Planet.mercury, Planet.jupiter, Planet.venus];

/// The five planets that form Sunapha/Anapha/Durudhara and Vesi/Vasi/
/// Ubhayachari (the Sun, Moon and nodes are excluded).
const _five = [Planet.mars, Planet.mercury, Planet.jupiter, Planet.venus, Planet.saturn];

String _n(Planet p) => p.name[0].toUpperCase() + p.name.substring(1);

/// Detects classical yogas. Only combinations whose full classical condition
/// is met are reported, each with its source; variants some apps add (any
/// association of wealth lords, Kala Sarpa, and so on) are not.
///
/// Houses are counted sign by sign from the Ascendant (whole-sign houses),
/// as the classical yoga definitions are, whatever house system the user
/// chose for the chart display.
class YogaDetector {
  YogaDetector._();

  static List<Yoga> detect(Chart chart) {
    final out = <Yoga>[];
    out.addAll(_moonBased(chart));
    out.addAll(_sunBased(chart));
    if (chart.ascendantSign != null) {
      out.addAll(_mahapurusha(chart));
      out.addAll(_rajaAndDhana(chart));
      out.addAll(_parivartana(chart));
      out.addAll(_neechaBhanga(chart));
      out.addAll(_viparita(chart));
      out.addAll(_amalaVasumati(chart));
      final s = _saraswati(chart);
      if (s != null) out.add(s);
      final l = _lakshmi(chart);
      if (l != null) out.add(l);
    }
    return out;
  }

  /// Whole-sign house of [p] counted from the Ascendant sign.
  static int _house(Chart c, Planet p) => c.ascendantSign!.countTo(c[p].sign);

  /// Lord of whole-sign house [h].
  static Planet _lordOf(Chart c, int h) => Sign.values[(c.ascendantSign!.index + h - 1) % 12].lord;

  static int _fromMoon(Chart c, Planet p) => c.moon.sign.countTo(c[p].sign);

  static bool _inKendraFromLagnaOrMoon(Chart c, Planet p) =>
      (c.ascendantSign != null && _kendra.contains(_house(c, p))) || _kendra.contains(_fromMoon(c, p));

  static List<Yoga> _moonBased(Chart c) {
    final out = <Yoga>[];

    // Gajakesari: Jupiter in a kendra from the Moon (Phaladeepika 6; Raman #1).
    final jFromMoon = _fromMoon(c, Planet.jupiter);
    if (_kendra.contains(jFromMoon)) {
      out.add(
        Yoga(
          id: 'gajakesari',
          name: 'Gajakesari Yoga',
          reason: 'Jupiter is in house $jFromMoon from the Moon (a kendra).',
          reasonRef: TextRef('yoga.gajakesari.reason', {'house': jFromMoon}),
          meaning: 'Traditionally linked with good reputation, wisdom and the ability to overcome opponents. Its effect depends on the strength of Jupiter and the Moon.',
          source: 'Phaladeepika ch. 6',
          sourceKey: 'phaladeepika6',
          planets: const [Planet.jupiter, Planet.moon],
        ),
      );
    }

    // Budhaditya: Sun and Mercury together (Raman #24). Raman adds that
    // Mercury should be more than 10° from the Sun for the yoga to work.
    if (c.sun.sign == c[Planet.mercury].sign) {
      final gap = angularDistance(c.sun.longitude, c[Planet.mercury].longitude);
      out.add(
        Yoga(
          id: 'budhaditya',
          name: 'Budhaditya Yoga',
          reason: 'The Sun and Mercury are in the same sign.',
          reasonRef: const TextRef('yoga.budhaditya.reason'),
          meaning: 'Associated with intelligence, communication skills and learning. It is very common because Mercury is always close to the Sun.',
          source: 'B.V. Raman, Three Hundred Important Combinations, no. 24',
          sourceKey: 'raman24',
          planets: const [Planet.sun, Planet.mercury],
          note: gap < 10 ? 'Mercury is within 10° of the Sun, so Raman considers the yoga weak.' : null,
          noteRef: gap < 10 ? TextRef('yoga.budhaditya.weak', {'deg': gap.toStringAsFixed(1)}) : null,
        ),
      );
    }

    // Chandra-Mangala: Moon and Mars together (Raman #6).
    if (c.moon.sign == c[Planet.mars].sign) {
      out.add(
        const Yoga(
          id: 'chandraMangala',
          name: 'Chandra-Mangala Yoga',
          reason: 'The Moon and Mars are in the same sign.',
          reasonRef: TextRef('yoga.chandraMangala.reason'),
          meaning: 'Associated with drive, enterprise and earning through one\'s own effort; can also indicate a quick temper.',
          source: 'B.V. Raman, Three Hundred Important Combinations, no. 6',
          sourceKey: 'raman6',
          planets: [Planet.moon, Planet.mars],
        ),
      );
    }

    // Sunapha / Anapha / Durudhara / Kemadruma: planets other than the Sun
    // and nodes in the 2nd and 12th from the Moon (BPHS 37.7, 37.11;
    // Phaladeepika 6.5-7; Raman #2-5).
    final second = [
      for (final p in _five)
        if (_fromMoon(c, p) == 2) p,
    ];
    final twelfth = [
      for (final p in _five)
        if (_fromMoon(c, p) == 12) p,
    ];
    if (second.isNotEmpty && twelfth.isNotEmpty) {
      out.add(
        Yoga(
          id: 'durudhara',
          name: 'Durudhara Yoga',
          reason:
              '${second.map(_n).join(', ')} in the 2nd and ${twelfth.map(_n).join(', ')} in the 12th from the Moon.',
          reasonRef: TextRef('yoga.durudhara.reason', {'second': second, 'twelfth': twelfth}),
          meaning: 'Associated with comforts, generosity and support from many sides.',
          source: 'BPHS 37; Phaladeepika ch. 6',
          sourceKey: 'bphs37Phaladeepika6',
          planets: [...second, ...twelfth],
        ),
      );
    } else if (second.isNotEmpty) {
      out.add(
        Yoga(
          id: 'sunapha',
          name: 'Sunapha Yoga',
          reason: '${second.map(_n).join(', ')} in the 2nd from the Moon.',
          reasonRef: TextRef('yoga.sunapha.reason', {'planets': second}),
          meaning: 'Associated with self-earned wealth, intelligence and a good name.',
          source: 'BPHS 37; Phaladeepika ch. 6',
          sourceKey: 'bphs37Phaladeepika6',
          planets: second,
        ),
      );
    } else if (twelfth.isNotEmpty) {
      out.add(
        Yoga(
          id: 'anapha',
          name: 'Anapha Yoga',
          reason: '${twelfth.map(_n).join(', ')} in the 12th from the Moon.',
          reasonRef: TextRef('yoga.anapha.reason', {'planets': twelfth}),
          meaning: 'Associated with good health, a pleasing personality and contentment.',
          source: 'BPHS 37; Phaladeepika ch. 6',
          sourceKey: 'bphs37Phaladeepika6',
          planets: twelfth,
        ),
      );
    } else {
      // Kemadruma is cancelled by any planet other than the Moon in a kendra
      // from the Ascendant (BPHS 37.11) or from the Moon (Phaladeepika 6.5),
      // or by a planet with the Moon.
      final withMoon = [
        for (final p in _five)
          if (_fromMoon(c, p) == 1) p,
      ];
      final cancelling = [
        for (final p in _seven)
          if (p != Planet.moon && (withMoon.contains(p) || _inKendraFromLagnaOrMoon(c, p))) p,
      ];
      out.add(
        Yoga(
          id: 'kemadruma',
          name: 'Kemadruma Yoga',
          reason: 'No planet other than the Sun or the nodes is in the 2nd or 12th from the Moon.',
          reasonRef: const TextRef('yoga.kemadruma.reason'),
          meaning: 'Traditionally associated with periods of feeling unsupported. Classical texts list several cancellations, and it is considered weak when cancelled.',
          source: 'BPHS 37; Phaladeepika ch. 6',
          sourceKey: 'bphs37Phaladeepika6',
          planets: const [Planet.moon],
          note: cancelling.isEmpty
              ? null
              : 'Considered cancelled: ${cancelling.map(_n).join(', ')} with the Moon or in a kendra from the Ascendant or Moon.',
          noteRef: cancelling.isEmpty ? null : TextRef('yoga.kemadruma.cancelled', {'planets': cancelling}),
        ),
      );
    }

    // Adhi yoga: benefics in the 6th, 7th and 8th from the Moon.
    final placed = _benefics.where((p) {
      final h = _fromMoon(c, p);
      return h >= 6 && h <= 8;
    }).toList();
    if (placed.length >= 2) {
      out.add(
        Yoga(
          id: 'adhi',
          name: 'Adhi Yoga',
          reason:
              '${placed.map(_n).join(', ')} ${placed.length == 1 ? 'is' : 'are'} in the 6th, 7th or 8th from the Moon.',
          reasonRef: TextRef('yoga.adhi.reason', {'planets': placed}),
          meaning: 'Associated with leadership, comfort and the support of others.',
          source: 'BPHS 37; Phaladeepika ch. 6',
          sourceKey: 'bphs37Phaladeepika6',
          planets: placed,
          note: placed.length == 3 ? 'Fully formed (all three benefics).' : 'Partially formed (two of three benefics).',
          noteRef: TextRef(placed.length == 3 ? 'yoga.adhi.full' : 'yoga.adhi.partial'),
        ),
      );
    }

    // Shakata: Moon in the 6th, 8th or 12th from Jupiter (Raman #12); not
    // formed when the Moon is in a kendra from the Ascendant.
    final mFromJ = c[Planet.jupiter].sign.countTo(c.moon.sign);
    if (_dusthana.contains(mFromJ)) {
      final cancelled = c.ascendantSign != null && _kendra.contains(_house(c, Planet.moon));
      out.add(
        Yoga(
          id: 'shakata',
          name: 'Shakata Yoga',
          reason: 'The Moon is in house $mFromJ from Jupiter.',
          reasonRef: TextRef('yoga.shakata.reason', {'house': mFromJ}),
          meaning: 'Traditionally associated with ups and downs in fortune, like the turning of a cart wheel; effort brings recovery.',
          source: 'B.V. Raman, Three Hundred Important Combinations, no. 12',
          sourceKey: 'raman12',
          planets: const [Planet.moon, Planet.jupiter],
          note: cancelled ? 'Not considered formed: the Moon is in a kendra from the Ascendant.' : null,
          noteRef: cancelled ? const TextRef('yoga.shakata.cancelled') : null,
        ),
      );
    }
    return out;
  }

  /// Vesi / Vasi / Ubhayachari: planets other than the Moon and nodes in the
  /// 2nd and 12th from the Sun (Phaladeepika 6.8-9; Raman #16-18).
  static List<Yoga> _sunBased(Chart c) {
    int fromSun(Planet p) => c.sun.sign.countTo(c[p].sign);
    final second = [
      for (final p in _five)
        if (fromSun(p) == 2) p,
    ];
    final twelfth = [
      for (final p in _five)
        if (fromSun(p) == 12) p,
    ];
    if (second.isEmpty && twelfth.isEmpty) return const [];
    final both = second.isNotEmpty && twelfth.isNotEmpty;
    final id = both ? 'ubhayachari' : (second.isNotEmpty ? 'vesi' : 'vasi');
    return [
      Yoga(
        id: id,
        name: '${id[0].toUpperCase()}${id.substring(1)} Yoga',
        reason: 'Planets in the ${both ? '2nd and 12th' : (second.isNotEmpty ? '2nd' : '12th')} from the Sun.',
        reasonRef: TextRef('yoga.$id.reason', {
          'planets': [...second, ...twelfth],
          'second': second,
          'twelfth': twelfth,
        }),
        meaning: switch (id) {
          'ubhayachari' => 'Associated with eloquence, balance and a respected, comfortable life.',
          'vesi' => 'Associated with truthfulness, steady effort and a balanced outlook.',
          _ => 'Associated with skill, generosity and recognition from others.',
        },
        source: 'Phaladeepika ch. 6; B.V. Raman, nos. 16-18',
        sourceKey: 'phaladeepika6Raman16',
        planets: [...second, ...twelfth],
      ),
    ];
  }

  static List<Yoga> _mahapurusha(Chart c) {
    const names = {
      Planet.mars: ('ruchaka', 'Ruchaka', 'courage, physical strength and leadership'),
      Planet.mercury: ('bhadra', 'Bhadra', 'intellect, eloquence and skill in trade or learning'),
      Planet.jupiter: ('hamsa', 'Hamsa', 'wisdom, righteousness and respect from others'),
      Planet.venus: ('malavya', 'Malavya', 'refinement, comforts and artistic taste'),
      Planet.saturn: ('shasha', 'Shasha', 'discipline, perseverance and authority over groups'),
    };
    final out = <Yoga>[];
    for (final e in names.entries) {
      final p = c[e.key];
      final h = _house(c, e.key);
      if (!_kendra.contains(h)) continue;
      if (!(p.isOwnSign || p.isExalted)) continue;
      out.add(
        Yoga(
          id: e.value.$1,
          name: '${e.value.$2} Yoga (Pancha Mahapurusha)',
          reason:
              '${_n(e.key)} is ${p.isExalted ? 'exalted' : 'in its own sign'} (${p.sign.rashi}) in house $h, a kendra.',
          reasonRef: TextRef('yoga.mahapurusha.reason', {
            'planet': e.key,
            'exalted': p.isExalted,
            'sign': p.sign,
            'house': h,
          }),
          meaning: 'Associated with ${e.value.$3}.',
          source: 'BPHS; Phaladeepika ch. 6',
          sourceKey: 'bphsPhaladeepika6',
          planets: [e.key],
        ),
      );
    }
    return out;
  }

  static List<Yoga> _rajaAndDhana(Chart c) {
    final out = <Yoga>[];
    final lordOf = {for (var h = 1; h <= 12; h++) h: _lordOf(c, h)};
    Set<int> housesOwned(Planet p) => {
      for (final e in lordOf.entries)
        if (e.value == p) e.key,
    };

    final seen = <String>{};
    // [relations] are the classical ways two lords combine: in one sign, in
    // each other's houses (exchange), one in the other's house, or mutual
    // aspect (BPHS 34.11-12). The house numbers are the ones that qualify:
    // an exchange must be between those houses, not any other houses the
    // two planets also rule.
    void pairYogas(
      Set<int> groupA,
      Set<int> groupB,
      String id,
      String name,
      String meaning,
      String source,
      String sourceKey, {
      required bool allRelations,
    }) {
      for (final ha in groupA) {
        for (final hb in groupB) {
          final a = lordOf[ha]!, b = lordOf[hb]!;
          if (a == b) continue;
          final key = '$name:${[a.index, b.index]..sort()}';
          if (seen.contains(key)) continue;
          final String relation;
          if (c[a].sign == c[b].sign) {
            relation = 'together';
          } else if (_house(c, a) == hb && _house(c, b) == ha) {
            relation = 'exchange';
          } else if (allRelations && (_house(c, a) == hb || _house(c, b) == ha)) {
            relation = 'inHouse';
          } else if (allRelations && aspectsSign(a, c[a].sign, c[b].sign) && aspectsSign(b, c[b].sign, c[a].sign)) {
            relation = 'aspect';
          } else {
            continue;
          }
          seen.add(key);
          final inA = _house(c, a) == hb;
          out.add(
            Yoga(
              id: id,
              name: name,
              reason:
                  '${_n(a)} (lord of $ha) and ${_n(b)} (lord of $hb): ${switch (relation) {
                    'together' => 'together in ${c[a].sign.rashi}',
                    'exchange' => 'exchange houses $ha and $hb',
                    'inHouse' => inA ? '${_n(a)} is in house $hb' : '${_n(b)} is in house $ha',
                    _ => 'aspect each other',
                  }}.',
              reasonRef: TextRef('yoga.pair.$relation', {
                'a': a,
                'aHouses': [ha],
                'b': b,
                'bHouses': [hb],
                'sign': c[a].sign,
                'who': inA ? a : b,
                'house': inA ? hb : ha,
              }),
              meaning: meaning,
              source: source,
              sourceKey: sourceKey,
              planets: [a, b],
            ),
          );
        }
      }
    }

    pairYogas(
      _kendra,
      _trikona,
      'raja',
      'Raja Yoga',
      'Associated with status, authority and success, especially during the dashas of the planets involved.',
      'BPHS 34.11-12',
      'bphs34',
      allRelations: true,
    );
    // Wealth houses (2, 11) joined with fortune houses (5, 9) by conjunction
    // or exchange: a Parashari rule as summarised by later authors.
    pairYogas(
      {2, 11},
      {5, 9},
      'dhana',
      'Dhana Yoga',
      'Associated with accumulation of wealth, especially during the dashas of the planets involved.',
      'Parashari principle of wealth-house lords (as summarised by later authors)',
      'parashariDhana',
      allRelations: false,
    );

    // Yogakaraka: one planet owning both a kendra and a trikona (other than the 1st).
    for (final p in _seven) {
      final owned = housesOwned(p);
      if (owned.any((h) => h != 1 && _kendra.contains(h)) && owned.any((h) => h != 1 && _trikona.contains(h))) {
        out.add(
          Yoga(
            id: 'yogakaraka',
            name: 'Yogakaraka',
            reason: '${_n(p)} rules houses ${owned.join(' and ')} (a kendra and a trikona).',
            reasonRef: TextRef('yoga.yogakaraka.reason', {'planet': p, 'houses': owned.toList()}),
            meaning: 'Such a planet is considered especially beneficial for this Ascendant.',
            source: 'BPHS 34.13',
            sourceKey: 'bphs34',
            planets: [p],
          ),
        );
      }
    }
    return out;
  }

  /// Parivartana: two lords in each other's signs. Phaladeepika 6.32-34
  /// names it Dainya when one house is 6, 8 or 12, Khala when one is the
  /// 3rd, and Maha otherwise.
  static List<Yoga> _parivartana(Chart c) {
    final out = <Yoga>[];
    for (var i = 1; i <= 12; i++) {
      for (var j = i + 1; j <= 12; j++) {
        final a = _lordOf(c, i), b = _lordOf(c, j);
        if (a == b || _house(c, a) != j || _house(c, b) != i) continue;
        final kind = (_dusthana.contains(i) || _dusthana.contains(j))
            ? 'Dainya'
            : ((i == 3 || j == 3) ? 'Khala' : 'Maha');
        out.add(
          Yoga(
            id: 'parivartana$kind',
            name: '$kind Parivartana Yoga',
            reason: '${_n(a)} (lord of $i) is in house $j and ${_n(b)} (lord of $j) is in house $i.',
            reasonRef: TextRef('yoga.parivartana.reason', {'a': a, 'i': i, 'b': b, 'j': j}),
            meaning: switch (kind) {
              'Maha' => 'A strong exchange: the two houses support each other, traditionally bringing prosperity.',
              'Khala' => 'Associated with a changeable course: periods of effort alternating with gains.',
              _ => 'Associated with obstacles in the matters of the houses involved, which ease with effort.',
            },
            source: 'Phaladeepika 6.32-34',
            sourceKey: 'phaladeepika6Parivartana',
            planets: [a, b],
          ),
        );
      }
    }
    return out;
  }

  static List<Yoga> _neechaBhanga(Chart c) {
    final out = <Yoga>[];
    for (final p in _seven) {
      final pl = c[p];
      if (!pl.isDebilitated) continue;
      final reasons = <String>[];
      final refs = <TextRef>[];
      final debLord = pl.sign.lord;
      if (debLord != p && _inKendraFromLagnaOrMoon(c, debLord)) {
        reasons.add('${_n(debLord)}, lord of the debilitation sign, is in a kendra from the Ascendant or Moon');
        refs.add(TextRef('yoga.neecha.debLord', {'planet': debLord}));
      }
      final exSign = Dignity.exaltationSign(p)!;
      final exLord = exSign.lord;
      if (exLord != p && _inKendraFromLagnaOrMoon(c, exLord)) {
        reasons.add('${_n(exLord)}, lord of its exaltation sign, is in a kendra from the Ascendant or Moon');
        refs.add(TextRef('yoga.neecha.exLord', {'planet': exLord}));
      }
      for (final q in _seven) {
        if (q != p && Dignity.exaltationSign(q) == pl.sign && _inKendraFromLagnaOrMoon(c, q)) {
          reasons.add('${_n(q)}, which is exalted in ${pl.sign.rashi}, is in a kendra from the Ascendant or Moon');
          refs.add(TextRef('yoga.neecha.exaltedHere', {'planet': q, 'sign': pl.sign}));
        }
      }
      // Phaladeepika 7.28: the lord of the debilitation sign aspects it.
      if (debLord != p && c[debLord].sign != pl.sign && aspectsSign(debLord, c[debLord].sign, pl.sign)) {
        reasons.add('${_n(debLord)}, lord of the debilitation sign, aspects it');
        refs.add(TextRef('yoga.neecha.aspect', {'planet': debLord}));
      }
      if (reasons.isEmpty) continue;
      out.add(
        Yoga(
          id: 'neechaBhanga',
          name: 'Neecha Bhanga Raja Yoga',
          reason: '${_n(p)} is debilitated in ${pl.sign.rashi}, and ${reasons.join('; ')}.',
          reasonRef: TextRef('yoga.neecha.reason', {'planet': p, 'sign': pl.sign, 'parts': refs}),
          meaning: 'The weakness of a debilitated planet is traditionally considered cancelled, and it may even give rise after early struggles.',
          source: 'Phaladeepika 7.26-30',
          sourceKey: 'phaladeepika7',
          planets: [p],
        ),
      );
    }
    return out;
  }

  static List<Yoga> _viparita(Chart c) {
    const names = {6: ('harsha', 'Harsha'), 8: ('sarala', 'Sarala'), 12: ('vimala', 'Vimala')};
    final out = <Yoga>[];
    for (final h in _dusthana) {
      final lord = _lordOf(c, h);
      final at = _house(c, lord);
      if (!_dusthana.contains(at)) continue;
      out.add(
        Yoga(
          id: names[h]!.$1,
          name: 'Viparita Raja Yoga (${names[h]!.$2})',
          reason: '${_n(lord)}, lord of house $h, is in house $at.',
          reasonRef: TextRef('yoga.viparita.reason', {'planet': lord, 'house': h, 'at': at}),
          meaning:
              'Associated with gains or rise that come through difficulties, or through the setbacks of opponents.',
          source: 'Phaladeepika 6.57, 6.63-69',
          sourceKey: 'phaladeepika6Viparita',
          planets: [lord],
        ),
      );
    }
    return out;
  }

  /// Amala: a benefic in the 10th from the Ascendant or Moon (Phaladeepika
  /// 6.19; Raman #13). Vasumati: all benefics in upachayas (3, 6, 10, 11)
  /// from the Ascendant or from the Moon (Phaladeepika 6.19; Raman #9).
  static List<Yoga> _amalaVasumati(Chart c) {
    final out = <Yoga>[];
    final tenth = [
      for (final p in _benefics)
        if (_house(c, p) == 10 || _fromMoon(c, p) == 10) p,
    ];
    if (tenth.isNotEmpty) {
      out.add(
        Yoga(
          id: 'amala',
          name: 'Amala Yoga',
          reason: '${tenth.map(_n).join(', ')} in the 10th from the Ascendant or Moon.',
          reasonRef: TextRef('yoga.amala.reason', {'planets': tenth}),
          meaning: 'Associated with a good name, ethical conduct and lasting reputation.',
          source: 'Phaladeepika ch. 6; B.V. Raman, no. 13',
          sourceKey: 'phaladeepika6Raman13',
          planets: tenth,
        ),
      );
    }
    final fromLagna = _benefics.every((p) => _upachaya.contains(_house(c, p)));
    final fromMoon = _benefics.every((p) => _upachaya.contains(_fromMoon(c, p)));
    if (fromLagna || fromMoon) {
      out.add(
        Yoga(
          id: 'vasumati',
          name: 'Vasumati Yoga',
          reason: 'Mercury, Jupiter and Venus are all in upachaya houses (3, 6, 10, 11).',
          reasonRef: TextRef('yoga.vasumati.reason', {'fromMoon': !fromLagna}),
          meaning: 'Associated with steadily growing wealth and independence.',
          source: 'Phaladeepika ch. 6; B.V. Raman, no. 9',
          sourceKey: 'phaladeepika6Raman9',
          planets: _benefics,
        ),
      );
    }
    return out;
  }

  static Yoga? _saraswati(Chart c) {
    const good = {1, 2, 4, 5, 7, 9, 10};
    final three = [Planet.jupiter, Planet.venus, Planet.mercury];
    if (!three.every((p) => good.contains(_house(c, p)))) return null;
    final jup = c[Planet.jupiter];
    final jupStrong = jup.isOwnSign || jup.isExalted || Dignity.naturalRelation(Planet.jupiter, jup.sign.lord) == 1;
    if (!jupStrong) return null;
    final houses = three.map((p) => _house(c, p)).toList();
    return Yoga(
      id: 'saraswati',
      name: 'Saraswati Yoga',
      reason:
          'Jupiter, Venus and Mercury are in kendras, trikonas or the 2nd house (houses ${houses.join(', ')}), and Jupiter is in its own, exalted or a friend\'s sign.',
      reasonRef: TextRef('yoga.saraswati.reason', {'houses': houses}),
      meaning: 'Associated with learning, eloquence and artistic or literary talent.',
      source: 'Phaladeepika ch. 6',
      sourceKey: 'phaladeepika6',
      planets: three,
    );
  }

  static Yoga? _lakshmi(Chart c) {
    final ninthLord = _lordOf(c, 9);
    final nl = c[ninthLord];
    final nh = _house(c, ninthLord);
    final ninthStrong = (nl.isOwnSign || nl.isExalted) && (_kendra.contains(nh) || _trikona.contains(nh));
    if (!ninthStrong) return null;
    // A "powerful" Ascendant lord (Raman #27): own or exaltation sign, or
    // in a kendra or trikona without being debilitated or combust.
    final lagnaLord = _lordOf(c, 1);
    final ll = c[lagnaLord];
    final lh = _house(c, lagnaLord);
    final combust = lagnaLord != Planet.sun && angularDistance(ll.longitude, c.sun.longitude) < 8;
    final lagnaStrong =
        ll.isOwnSign ||
        ll.isExalted ||
        ((_kendra.contains(lh) || _trikona.contains(lh)) && !ll.isDebilitated && !combust);
    if (!lagnaStrong) return null;
    return Yoga(
      id: 'lakshmi',
      name: 'Lakshmi Yoga',
      reason:
          '${_n(ninthLord)}, the 9th lord, is ${nl.isExalted ? 'exalted' : 'in its own sign'} in house $nh, and the Ascendant lord ${_n(lagnaLord)} is strong.',
      reasonRef: TextRef('yoga.lakshmi.reason', {
        'planet': ninthLord,
        'exalted': nl.isExalted,
        'house': nh,
        'lagnaLord': lagnaLord,
      }),
      meaning: 'Associated with prosperity, good fortune and a generous nature.',
      source: 'B.V. Raman, no. 27; BPHS 36',
      sourceKey: 'raman27',
      planets: {ninthLord, lagnaLord}.toList(),
    );
  }
}
