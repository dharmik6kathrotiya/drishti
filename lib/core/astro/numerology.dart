/// Numerology (Pythagorean, Chaldean and Indian Mulank/Bhagyank).
///
/// Meanings are short, general descriptions of traditional associations,
/// not predictions.
library;

import 'constants.dart';

enum NumerologySystem { pythagorean, chaldean }

class NumerologyNumber {
  const NumerologyNumber(this.title, this.value, this.meaning, {this.compound, this.id = ''});
  final String title;

  /// Stable id for localization: lifePath, birthday, mulank, bhagyank,
  /// expression, soulUrge, personality, chaldeanName.
  final String id;

  /// Reduced number (1-9, or master number 11/22/33 where kept).
  final int value;

  /// Unreduced total before reduction (e.g. Chaldean compound number).
  final int? compound;
  final String meaning;
}

class NumerologyReport {
  const NumerologyReport(this.numbers);
  final List<NumerologyNumber> numbers;
  NumerologyNumber? byTitle(String t) => numbers.where((n) => n.title == t).firstOrNull;
}

class Numerology {
  Numerology._();

  static const _pythagorean = {
    'A': 1,
    'B': 2,
    'C': 3,
    'D': 4,
    'E': 5,
    'F': 6,
    'G': 7,
    'H': 8,
    'I': 9,
    'J': 1,
    'K': 2,
    'L': 3,
    'M': 4,
    'N': 5,
    'O': 6,
    'P': 7,
    'Q': 8,
    'R': 9,
    'S': 1,
    'T': 2,
    'U': 3,
    'V': 4,
    'W': 5,
    'X': 6,
    'Y': 7,
    'Z': 8,
  };

  static const _chaldean = {
    'A': 1,
    'B': 2,
    'C': 3,
    'D': 4,
    'E': 5,
    'F': 8,
    'G': 3,
    'H': 5,
    'I': 1,
    'J': 1,
    'K': 2,
    'L': 3,
    'M': 4,
    'N': 5,
    'O': 7,
    'P': 8,
    'Q': 1,
    'R': 2,
    'S': 3,
    'T': 4,
    'U': 6,
    'V': 6,
    'W': 6,
    'X': 5,
    'Y': 1,
    'Z': 7,
  };

  /// Vowels used for the soul-urge number (Y is treated as a consonant).
  static const _vowels = {'A', 'E', 'I', 'O', 'U'};

  static int letterValue(String letter, NumerologySystem system) =>
      (system == NumerologySystem.pythagorean ? _pythagorean : _chaldean)[letter.toUpperCase()] ?? 0;

  static int _digitSum(int n) {
    var s = 0;
    for (var x = n.abs(); x > 0; x ~/= 10) {
      s += x % 10;
    }
    return s;
  }

  /// Reduces to a single digit, keeping 11, 22 and 33 when [keepMasters].
  static int reduce(int n, {bool keepMasters = true}) {
    var x = n.abs();
    while (x > 9) {
      if (keepMasters && (x == 11 || x == 22 || x == 33)) return x;
      x = _digitSum(x);
    }
    return x;
  }

  static String _letters(String name) => name.toUpperCase().replaceAll(RegExp('[^A-Z]'), '');

  static int nameTotal(String name, NumerologySystem system, {bool Function(String)? filter}) {
    var total = 0;
    for (final ch in _letters(name).split('')) {
      if (ch.isEmpty) continue;
      if (filter != null && !filter(ch)) continue;
      total += letterValue(ch, system);
    }
    return total;
  }

  /// Life path: month, day and year reduced separately, then summed.
  static int lifePath(DateTime date) => reduce(reduce(date.month) + reduce(date.day) + reduce(date.year));

  static int expression(String name) => reduce(nameTotal(name, NumerologySystem.pythagorean));

  static int soulUrge(String name) => reduce(nameTotal(name, NumerologySystem.pythagorean, filter: _vowels.contains));

  static int personality(String name) =>
      reduce(nameTotal(name, NumerologySystem.pythagorean, filter: (c) => !_vowels.contains(c)));

  static int birthday(DateTime date) => reduce(date.day);

  /// Mulank (psychic number): day of birth reduced to 1-9.
  static int mulank(DateTime date) => reduce(date.day, keepMasters: false);

  /// Bhagyank (destiny number): all digits of the full date reduced to 1-9.
  static int bhagyank(DateTime date) =>
      reduce(_digitSum(date.day) + _digitSum(date.month) + _digitSum(date.year), keepMasters: false);

  /// Chaldean name number (compound total and reduced value).
  static (int compound, int reduced) chaldeanName(String name) {
    final total = nameTotal(name, NumerologySystem.chaldean);
    return (total, reduce(total, keepMasters: false));
  }

  /// Full report from whatever data is available.
  static NumerologyReport report({String? name, DateTime? birthDate}) {
    final out = <NumerologyNumber>[];
    if (birthDate != null) {
      final lp = lifePath(birthDate);
      out.add(NumerologyNumber('Life Path', lp, meaningOf(lp), id: 'lifePath'));
      final bd = birthday(birthDate);
      out.add(NumerologyNumber('Birthday', bd, meaningOf(bd), id: 'birthday'));
      final m = mulank(birthDate);
      out.add(NumerologyNumber('Mulank', m, meaningOf(m), id: 'mulank'));
      final b = bhagyank(birthDate);
      out.add(NumerologyNumber('Bhagyank', b, meaningOf(b), id: 'bhagyank'));
    }
    if (name != null && _letters(name).isNotEmpty) {
      final e = expression(name);
      out.add(NumerologyNumber('Expression', e, meaningOf(e), id: 'expression'));
      final s = soulUrge(name);
      if (s > 0) out.add(NumerologyNumber('Soul Urge', s, meaningOf(s), id: 'soulUrge'));
      final p = personality(name);
      if (p > 0) out.add(NumerologyNumber('Personality', p, meaningOf(p), id: 'personality'));
      final (compound, reduced) = chaldeanName(name);
      out.add(
        NumerologyNumber('Name Number (Chaldean)', reduced, meaningOf(reduced), compound: compound, id: 'chaldeanName'),
      );
    }
    return NumerologyReport(out);
  }

  // ---- Step-by-step working ("how it is calculated") ------------------------

  /// Public digit sum (e.g. 1995 -> 24).
  static int digitSum(int n) => _digitSum(n);

  /// Digits of [n] in written order (e.g. 1995 -> [1, 9, 9, 5]).
  static List<int> digitsOf(int n) => n.abs().toString().split('').map(int.parse).toList();

  static bool isMaster(int n) => n == 11 || n == 22 || n == 33;

  /// All letters of [name] with their values in [system].
  static List<LetterValue> letterValues(String name, NumerologySystem system) => [
    for (final ch in _letters(name).split(''))
      if (ch.isNotEmpty) LetterValue(ch, letterValue(ch, system), isVowel: _vowels.contains(ch)),
  ];

  /// Step-by-step working for the number with [id] (see [NumerologyNumber.id]),
  /// or null when the needed input is missing. Results always match [report].
  static NumberDetail? detail(String id, {String? name, DateTime? birthDate}) {
    final d = birthDate;
    final nm = name ?? '';
    final hasName = _letters(nm).isNotEmpty;
    switch (id) {
      case 'lifePath':
        if (d == null) return null;
        final m = Working.reduce(d.month);
        final dd = Working.reduce(d.day);
        final y = Working.reduce(d.year);
        return NumberDetail(
          id: id,
          lines: [
            WorkingLine(WorkingPart.month, m),
            WorkingLine(WorkingPart.day, dd),
            WorkingLine(WorkingPart.year, y),
            WorkingLine(WorkingPart.sum, Working.sum([m.result, dd.result, y.result])),
          ],
        );
      case 'birthday':
        if (d == null) return null;
        return NumberDetail(id: id, lines: [WorkingLine(WorkingPart.day, Working.reduce(d.day))]);
      case 'mulank':
        if (d == null) return null;
        return NumberDetail(id: id, lines: [WorkingLine(WorkingPart.day, Working.reduce(d.day, keepMasters: false))]);
      case 'bhagyank':
        if (d == null) return null;
        final digits = [...digitsOf(d.day), ...digitsOf(d.month), ...digitsOf(d.year)];
        return NumberDetail(
          id: id,
          lines: [WorkingLine(WorkingPart.dateDigits, Working.sum(digits, keepMasters: false))],
        );
      case 'expression':
      case 'soulUrge':
      case 'personality':
        if (!hasName) return null;
        final letters = letterValues(nm, NumerologySystem.pythagorean);
        final picked = switch (id) {
          'soulUrge' => letters.where((l) => l.isVowel),
          'personality' => letters.where((l) => !l.isVowel),
          _ => letters,
        };
        final part = switch (id) {
          'soulUrge' => WorkingPart.vowels,
          'personality' => WorkingPart.consonants,
          _ => WorkingPart.letters,
        };
        return NumberDetail(
          id: id,
          letters: letters,
          system: NumerologySystem.pythagorean,
          lines: [
            WorkingLine(part, Working.sum([for (final l in picked) l.value])),
          ],
        );
      case 'chaldeanName':
        if (!hasName) return null;
        final letters = letterValues(nm, NumerologySystem.chaldean);
        return NumberDetail(
          id: id,
          letters: letters,
          system: NumerologySystem.chaldean,
          lines: [
            WorkingLine(WorkingPart.letters, Working.sum([for (final l in letters) l.value], keepMasters: false)),
          ],
        );
    }
    return null;
  }

  // ---- Ruling planets and Mulank-Bhagyank pair -------------------------------

  /// Traditional ruling planet in Indian numerology (1 Sun ... 9 Mars).
  /// Master numbers use the planet of their reduced digit.
  static Planet planetOf(int n) => const [
    Planet.sun,
    Planet.moon,
    Planet.jupiter,
    Planet.rahu,
    Planet.mercury,
    Planet.venus,
    Planet.ketu,
    Planet.saturn,
    Planet.mars,
  ][reduce(n, keepMasters: false) - 1];

  /// Rahu and Ketu are not in the classical (BPHS) friendship table; this is a
  /// common later convention, and schools differ.
  static const _nodeFriends = {
    Planet.rahu: [Planet.mercury, Planet.venus, Planet.saturn],
    Planet.ketu: [Planet.mars, Planet.venus, Planet.saturn],
  };
  static const _nodeEnemies = {
    Planet.rahu: [Planet.sun, Planet.moon, Planet.mars],
    Planet.ketu: [Planet.sun, Planet.moon],
  };

  static int _nodeView(Planet node, Planet other) {
    if (_nodeFriends[node]!.contains(other)) return 1;
    if (_nodeEnemies[node]!.contains(other)) return -1;
    return 0;
  }

  /// How planet [a] regards planet [b]: 1 friend, 0 neutral, -1 enemy.
  /// Classical natural friendships for the seven planets; for Rahu/Ketu the
  /// node's own view is used in both directions.
  static int planetRelation(Planet a, Planet b) {
    if (a == b) return 1;
    if (a.isNode) return _nodeView(a, b);
    if (b.isNode) return _nodeView(b, a);
    return Dignity.naturalRelation(a, b);
  }

  static NumberPair pair(int first, int second) {
    final a = reduce(first, keepMasters: false);
    final b = reduce(second, keepMasters: false);
    final pa = planetOf(a);
    final pb = planetOf(b);
    final ab = planetRelation(pa, pb);
    final ba = planetRelation(pb, pa);
    final s = ab + ba;
    final rel = a == b
        ? PairRelation.same
        : s > 0
        ? PairRelation.friendly
        : s < 0
        ? PairRelation.challenging
        : PairRelation.neutral;
    return NumberPair(a, b, pa, pb, ab, ba, rel);
  }

  static NumberPair mulankBhagyankPair(DateTime date) => pair(mulank(date), bhagyank(date));

  // ---- Lo Shu grid -------------------------------------------------------------

  /// Lo Shu grid from the birth date digits (zeros ignored). With
  /// [addMulankBhagyank] (usual Indian practice) the Bhagyank is added, and the
  /// Mulank too unless the birth day is 1-9, 10, 20 or 30 (already present).
  static LoShuGrid loShu(DateTime date, {bool addMulankBhagyank = true}) {
    final digits = [
      ...digitsOf(date.day),
      ...digitsOf(date.month),
      ...digitsOf(date.year),
    ].where((x) => x != 0).toList();
    final extra = <int>[];
    if (addMulankBhagyank) {
      if (date.day > 9 && date.day % 10 != 0) extra.add(mulank(date));
      extra.add(bhagyank(date));
    }
    return LoShuGrid(digits, extra);
  }

  // ---- Chaldean compound number ----------------------------------------------

  /// Compound number (10-52) read in Cheiro's tradition for a Chaldean total.
  /// Totals above 52 are reduced by adding digits until they are 52 or less;
  /// returns null when that leaves a single digit.
  static int? compoundOf(int total) {
    var x = total;
    while (x > 52) {
      x = _digitSum(x);
    }
    return x >= 10 ? x : null;
  }

  // ---- Personal year / month / day -----------------------------------------------

  static PersonalCycles personalCycles(DateTime birth, DateTime today) {
    final d = Working.reduce(birth.day, keepMasters: false);
    final m = Working.reduce(birth.month, keepMasters: false);
    final y = Working.reduce(today.year, keepMasters: false);
    final year = Working.sum([d.result, m.result, y.result], keepMasters: false);
    final month = Working.sum([year.result, today.month], keepMasters: false);
    final day = Working.sum([month.result, today.day], keepMasters: false);
    return PersonalCycles(
      yearLines: [
        WorkingLine(WorkingPart.day, d),
        WorkingLine(WorkingPart.month, m),
        WorkingLine(WorkingPart.currentYear, y),
        WorkingLine(WorkingPart.sum, year),
      ],
      monthWorking: month,
      dayWorking: day,
    );
  }

  static String meaningOf(int n) => _meanings[n] ?? '';

  static const _meanings = {
    1: 'Associated with independence, initiative and leadership. Traditionally linked with the Sun.',
    2: 'Associated with cooperation, sensitivity and partnership. Traditionally linked with the Moon.',
    3: 'Associated with creativity, expression and optimism. Traditionally linked with Jupiter.',
    4: 'Associated with structure, hard work and practicality. Traditionally linked with Rahu (Uranus in Western use).',
    5: 'Associated with curiosity, change and communication. Traditionally linked with Mercury.',
    6: 'Associated with care, responsibility and harmony in relationships. Traditionally linked with Venus.',
    7: 'Associated with reflection, research and inner life. Traditionally linked with Ketu (Neptune in Western use).',
    8: 'Associated with discipline, ambition and patience. Traditionally linked with Saturn.',
    9: 'Associated with compassion, courage and completion. Traditionally linked with Mars.',
    11: 'A master number associated with intuition and inspiration; also carries the qualities of 2.',
    22: 'A master number associated with building large, practical goals; also carries the qualities of 4.',
    33: 'A master number associated with teaching and service; also carries the qualities of 6.',
  };
}

/// A sum followed by digit reduction, e.g. 8 + 5 + 6 = 19 -> 10 -> 1.
class Working {
  const Working._(this.terms, this.chain, this.masterKept);

  /// Adds [terms] and reduces the total like [Numerology.reduce].
  factory Working.sum(List<int> terms, {bool keepMasters = true}) {
    final total = terms.fold<int>(0, (a, b) => a + b);
    final chain = <int>[total];
    var kept = false;
    var x = total;
    while (x > 9) {
      if (keepMasters && Numerology.isMaster(x)) {
        kept = true;
        break;
      }
      x = Numerology.digitSum(x);
      chain.add(x);
    }
    return Working._(List.unmodifiable(terms), List.unmodifiable(chain), kept);
  }

  /// Reduces a single number, e.g. 1995 -> 24 -> 6.
  factory Working.reduce(int n, {bool keepMasters = true}) => Working.sum([n], keepMasters: keepMasters);

  /// Values added together (a single value when only reducing).
  final List<int> terms;

  /// The total followed by each reduction; `chain.first` is the sum of
  /// [terms] and `chain.last` is the result.
  final List<int> chain;

  /// True when reduction stopped at a master number (11, 22, 33).
  final bool masterKept;

  int get total => chain.first;
  int get result => chain.last;

  /// Language-neutral working, e.g. "1995 → 1+9+9+5 = 24 → 2+4 = 6" or
  /// "8 + 5 + 6 = 19 → 1+9 = 10 → 1+0 = 1".
  String format() {
    final b = StringBuffer(terms.length > 1 ? '${terms.join(' + ')} = $total' : '$total');
    for (var i = 1; i < chain.length; i++) {
      b.write(' → ${Numerology.digitsOf(chain[i - 1]).join('+')} = ${chain[i]}');
    }
    return b.toString();
  }
}

/// What a working line adds up.
enum WorkingPart { month, day, year, currentYear, sum, dateDigits, letters, vowels, consonants }

class WorkingLine {
  const WorkingLine(this.part, this.working);
  final WorkingPart part;
  final Working working;
}

class LetterValue {
  const LetterValue(this.letter, this.value, {required this.isVowel});
  final String letter;
  final int value;
  final bool isVowel;
}

/// Step-by-step working for one number. The last line gives the result.
class NumberDetail {
  const NumberDetail({required this.id, required this.lines, this.letters = const [], this.system});
  final String id;
  final List<WorkingLine> lines;

  /// Every letter of the name with its value in [system] (name numbers only).
  final List<LetterValue> letters;
  final NumerologySystem? system;

  int get value => lines.last.working.result;
  int get total => lines.last.working.total;
}

enum PairRelation { same, friendly, neutral, challenging }

/// Two numbers and the natural relationship of their ruling planets.
class NumberPair {
  const NumberPair(
    this.first,
    this.second,
    this.firstPlanet,
    this.secondPlanet,
    this.firstView,
    this.secondView,
    this.relation,
  );
  final int first;
  final int second;
  final Planet firstPlanet;
  final Planet secondPlanet;

  /// How [firstPlanet] regards [secondPlanet] (1 friend, 0 neutral, -1 enemy).
  final int firstView;

  /// How [secondPlanet] regards [firstPlanet].
  final int secondView;
  final PairRelation relation;
}

/// Lo Shu planes (rows, columns and diagonals of the 4-9-2 / 3-5-7 / 8-1-6 square).
enum LoShuPlane {
  mental([4, 9, 2]),
  emotional([3, 5, 7]),
  practical([8, 1, 6]),
  thought([4, 3, 8]),
  will([9, 5, 1]),
  action([2, 7, 6]),
  golden([4, 5, 6]),
  silver([2, 5, 8]);

  const LoShuPlane(this.numbers);
  final List<int> numbers;
}

class LoShuGrid {
  LoShuGrid(this.dateDigits, this.extra);

  /// Standard layout, top row first.
  static const layout = [
    [4, 9, 2],
    [3, 5, 7],
    [8, 1, 6],
  ];

  /// Non-zero digits of the birth date.
  final List<int> dateDigits;

  /// Mulank/Bhagyank digits added (Indian practice); may be empty.
  final List<int> extra;

  List<int> get digits => [...dateDigits, ...extra];

  int count(int n) => digits.where((d) => d == n).length;

  List<int> get missing => [
    for (var n = 1; n <= 9; n++)
      if (count(n) == 0) n,
  ];

  /// Numbers that appear two or more times.
  List<int> get repeated => [
    for (var n = 1; n <= 9; n++)
      if (count(n) >= 2) n,
  ];

  List<LoShuPlane> get completePlanes => [
    for (final p in LoShuPlane.values)
      if (p.numbers.every((n) => count(n) > 0)) p,
  ];
}

class PersonalCycles {
  const PersonalCycles({required this.yearLines, required this.monthWorking, required this.dayWorking});

  /// Birth day, birth month, current year and their sum.
  final List<WorkingLine> yearLines;

  /// Personal year + calendar month.
  final Working monthWorking;

  /// Personal month + calendar day.
  final Working dayWorking;

  int get year => yearLines.last.working.result;
  int get month => monthWorking.result;
  int get day => dayWorking.result;
}
