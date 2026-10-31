import '../../i18n/text_ref.dart';
import '../chart.dart';
import '../constants.dart';
import 'dasha.dart';
import 'divisional.dart';
import 'matching.dart';
import 'yogas.dart';

/// One classical factor and which way it points: +1 supportive, -1 a sign
/// of delay or difficulty, 0 mixed.
class ChildrenFactor {
  const ChildrenFactor(this.text, this.tone);
  final TextRef text;
  final int tone;
}

/// A dasha period the method marks for children, and why.
class ChildrenWindow {
  const ChildrenWindow(this.start, this.end, this.why);
  final DateTime start;
  final DateTime end;
  final List<TextRef> why;
}

/// Children (Santana) as one chart shows them.
class ChildrenReport {
  const ChildrenReport({
    required this.fromMoon,
    required this.fifthSign,
    required this.fifthLord,
    required this.factors,
    required this.windows,
  });

  /// No birth time: houses are counted from the Moon sign (Chandra Lagna).
  final bool fromMoon;
  final Sign fifthSign;
  final Planet fifthLord;
  final List<ChildrenFactor> factors;
  final List<ChildrenWindow> windows;

  int get score => factors.fold(0, (s, f) => s + f.tone);

  /// 1 supportive, 0 mixed, -1 needs patience.
  int get tone => Children.toneOf(score);
}

/// Beeja Sphuta (father) or Kshetra Sphuta (mother).
class Sphuta {
  const Sphuta(this.id, this.parts, this.longitude);

  /// 'beeja' or 'kshetra'.
  final String id;
  final List<PlanetPlacement> parts;
  final double longitude;

  Sign get sign => Sign.fromLongitude(longitude);
  Sign get navamsa => Varga.d9.signOf(longitude);

  /// Beeja is strong in an odd sign and odd navamsa, Kshetra in an even sign
  /// and even navamsa; both the other way is weak, a mix is moderate.
  int get tone {
    final wanted = id == 'beeja';
    final hits = (sign.isOdd == wanted ? 1 : 0) + (navamsa.isOdd == wanted ? 1 : 0);
    return hits - 1;
  }

  List<TextRef> get why => [
    for (final p in parts)
      TextRef('children.why.part', {
        'planet': p.planet,
        'sign': p.sign,
        'deg': formatDms(p.degreeInSign, seconds: false),
      }),
    TextRef('children.why.sum', {'sign': sign, 'deg': formatDms(longitude % 30, seconds: false), 'nav': navamsa}),
    TextRef('children.why.$id.rule'),
  ];
}

/// Both partners together.
class CoupleChildren {
  const CoupleChildren({
    required this.father,
    required this.mother,
    required this.beeja,
    required this.kshetra,
    required this.nadiDosha,
    required this.shared,
  });

  final ChildrenReport father;
  final ChildrenReport mother;
  final Sphuta beeja;
  final Sphuta kshetra;

  /// The same nadi with no classical exception, which tradition links with
  /// children.
  final bool nadiDosha;

  /// Times when both charts run a period the method marks for children.
  final List<(DateTime, DateTime)> shared;

  int get tone => Children.toneOf(father.tone + mother.tone + beeja.tone + kshetra.tone - (nadiDosha ? 1 : 0));
}

/// Children as classical Vedic texts read them. A traditional calculation,
/// never a medical assessment.
///
/// * The 5th house, its lord and Jupiter (the natural significator of
///   children), with benefic and malefic influence on the 5th: BPHS, chapter
///   on the 5th house (Putra Bhava); Phaladeepika ch. 12.
/// * Jupiter in the Saptamsha (D7), the varga for children: BPHS ch. 6-7.
/// * Beeja Sphuta (Sun + Venus + Jupiter of the man) and Kshetra Sphuta (Moon
///   + Mars + Jupiter of the woman): Phaladeepika ch. 12.
/// * Timing: Vimshottari Antardashas of the 5th lord, Jupiter and planets in
///   the 5th.
///
/// Houses are whole signs from the Ascendant, or from the Moon without a
/// birth time. Nothing here says whether a child will be a boy or a girl.
class Children {
  Children._();

  static const _kendraTrikona = {1, 4, 5, 7, 9, 10};
  static const _dusthana = {6, 8, 12};
  static const _benefics = [Planet.jupiter, Planet.venus, Planet.mercury];
  static const _malefics = [Planet.sun, Planet.mars, Planet.saturn, Planet.rahu, Planet.ketu];

  static int toneOf(int score) => score >= 2 ? 1 : (score <= -2 ? -1 : 0);

  static ChildrenReport single(Chart c, {required DateTime birthUtc, required DateTime now, int years = 12}) {
    final ref = c.ascendantSign ?? c.moon.sign;
    final fifth = ref + 4;
    final lord = fifth.lord;
    int house(Planet p) => ref.countTo(c[p].sign);
    final factors = <ChildrenFactor>[];

    // The 5th lord: where it sits and its dignity.
    final lh = house(lord);
    if (_dusthana.contains(lh)) {
      factors.add(ChildrenFactor(TextRef('children.f.lordDusthana', {'planet': lord, 'house': lh}), -1));
    } else if (_kendraTrikona.contains(lh)) {
      factors.add(ChildrenFactor(TextRef('children.f.lordGood', {'planet': lord, 'house': lh}), 1));
    } else {
      factors.add(ChildrenFactor(TextRef('children.f.lordOther', {'planet': lord, 'house': lh}), 0));
    }
    final lp = c[lord];
    if (lp.isExalted) {
      factors.add(ChildrenFactor(TextRef('children.f.lordExalted', {'planet': lord, 'sign': lp.sign}), 1));
    } else if (lp.isDebilitated) {
      factors.add(ChildrenFactor(TextRef('children.f.lordDebilitated', {'planet': lord, 'sign': lp.sign}), -1));
    }

    // Jupiter, the significator of children.
    final jup = c[Planet.jupiter];
    final jh = house(Planet.jupiter);
    if (_dusthana.contains(jh)) {
      factors.add(ChildrenFactor(TextRef('children.f.jupDusthana', {'house': jh}), -1));
    } else if (_kendraTrikona.contains(jh)) {
      factors.add(ChildrenFactor(TextRef('children.f.jupGood', {'house': jh}), 1));
    }
    if (jup.isDebilitated) {
      factors.add(ChildrenFactor(TextRef('children.f.jupDebilitated', {'sign': jup.sign}), -1));
    } else if (jup.isExalted || jup.isOwnSign) {
      factors.add(ChildrenFactor(TextRef('children.f.jupStrong', {'sign': jup.sign}), 1));
    }
    final fromSun = angularDistance(jup.longitude, c.sun.longitude);
    if (fromSun < 11) {
      factors.add(ChildrenFactor(TextRef('children.f.jupCombust', {'deg': fromSun.toStringAsFixed(1)}), -1));
    }

    // Planets in the 5th, and benefic aspects that protect it.
    final inFifth = [
      for (final p in Planet.vedic)
        if (c[p].sign == fifth) p,
    ];
    final beneficsIn = inFifth.where(_benefics.contains).toList();
    // The 5th lord in its own house protects it, malefic or not.
    final maleficsIn = inFifth.where((p) => _malefics.contains(p) && p != lord).toList();
    final jupiterAspects = !inFifth.contains(Planet.jupiter) && aspectsSign(Planet.jupiter, jup.sign, fifth);
    final beneficAspect = [
      for (final p in _benefics)
        if (!inFifth.contains(p) && aspectsSign(p, c[p].sign, fifth)) p,
    ];
    if (beneficsIn.isNotEmpty) {
      factors.add(ChildrenFactor(TextRef('children.f.beneficIn', {'planets': beneficsIn}), 1));
    }
    if (jupiterAspects) factors.add(const ChildrenFactor(TextRef('children.f.jupAspect'), 1));
    if (maleficsIn.isNotEmpty) {
      final helped = beneficsIn.isNotEmpty || beneficAspect.isNotEmpty;
      factors.add(
        helped
            ? ChildrenFactor(TextRef('children.f.maleficHelped', {'planets': maleficsIn}), 0)
            : ChildrenFactor(TextRef('children.f.maleficIn', {'planets': maleficsIn}), -1),
      );
    }

    // Jupiter in the Saptamsha.
    final d7 = Varga.d7.signOf(jup.longitude);
    if (d7 == Dignity.debilitationSign(Planet.jupiter)) {
      factors.add(ChildrenFactor(TextRef('children.f.d7JupWeak', {'sign': d7}), -1));
    } else if (d7 == Dignity.exaltationSign(Planet.jupiter) || d7.lord == Planet.jupiter) {
      factors.add(ChildrenFactor(TextRef('children.f.d7JupStrong', {'sign': d7}), 1));
    }

    // Timing: Antardashas of the significators in the coming years.
    final roles = <Planet, String>{for (final p in inFifth) p: 'in5', Planet.jupiter: 'jupiter', lord: 'lord'};
    final until = now.add(Duration(days: (years * dashaYearDays).round()));
    final windows = <ChildrenWindow>[];
    for (final ad in Vimshottari().between(birthUtc, c.moon.longitude, now, until, depth: 2)) {
      final role = roles[ad.lord];
      if (role == null) continue;
      final md = ad.parent!.lord;
      windows.add(
        ChildrenWindow(ad.start.isBefore(now) ? now : ad.start, ad.end, [
          TextRef('children.why.window', {
            'md': md,
            'ad': ad.lord,
            'role': TextRef('children.role.$role', {'planet': ad.lord}),
          }),
          if (roles[md] != null && md != ad.lord)
            TextRef('children.why.windowMd', {
              'planet': md,
              'role': TextRef('children.role.${roles[md]}', {'planet': md}),
            }),
        ]),
      );
    }

    return ChildrenReport(
      fromMoon: !c.hasHouses,
      fifthSign: fifth,
      fifthLord: lord,
      factors: factors,
      windows: windows,
    );
  }

  static Sphuta beeja(Chart man) {
    final parts = [man.sun, man[Planet.venus], man[Planet.jupiter]];
    return Sphuta('beeja', parts, norm360(parts.fold(0.0, (s, p) => s + p.longitude)));
  }

  static Sphuta kshetra(Chart woman) {
    final parts = [woman.moon, woman[Planet.mars], woman[Planet.jupiter]];
    return Sphuta('kshetra', parts, norm360(parts.fold(0.0, (s, p) => s + p.longitude)));
  }

  static CoupleChildren couple(
    Chart father,
    Chart mother, {
    required DateTime fatherUtc,
    required DateTime motherUtc,
    required DateTime now,
  }) {
    final f = single(father, birthUtc: fatherUtc, now: now);
    final m = single(mother, birthUtc: motherUtc, now: now);
    final match = Ashtakoot.match(
      boy: MatchInput(moonLongitude: father.moon.longitude),
      girl: MatchInput(moonLongitude: mother.moon.longitude),
    );
    final nadi = match.kootas.firstWhere((k) => k.id == 'nadi');
    final shared = <(DateTime, DateTime)>[];
    for (final a in f.windows) {
      for (final b in m.windows) {
        final s = a.start.isAfter(b.start) ? a.start : b.start;
        final e = a.end.isBefore(b.end) ? a.end : b.end;
        if (s.isBefore(e)) shared.add((s, e));
      }
    }
    shared.sort((x, y) => x.$1.compareTo(y.$1));
    return CoupleChildren(
      father: f,
      mother: m,
      beeja: beeja(father),
      kshetra: kshetra(mother),
      nadiDosha: nadi.doshaId != null && !nadi.doshaCancelled,
      shared: shared,
    );
  }
}
