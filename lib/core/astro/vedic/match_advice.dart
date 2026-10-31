import '../../i18n/text_ref.dart';
import '../constants.dart';
import '../western/aspects.dart';
import 'matching.dart';

/// One point of the overall advice and the chart reasons behind it (shown on
/// "Why?").
class AdvicePoint {
  const AdvicePoint(this.text, [this.why = const []]);
  final TextRef text;
  final List<TextRef> why;
}

/// The whole match in plain words: a conclusion, what is strong, what needs
/// care, practical steps and (Vedic only) the traditional remedies, which are
/// optional and never tied to buying anything.
class MatchAdvice {
  const MatchAdvice({
    required this.conclusion,
    required this.summary,
    required this.strengths,
    required this.cautions,
    required this.steps,
    this.remedies = const [],
  });

  /// Vedic: the score card's verdict ('excellent', 'good', 'average'), or
  /// 'dosha' or 'weak'. Western: 'good', 'mixed' or 'hard'.
  final String conclusion;
  final TextRef summary;
  final List<AdvicePoint> strengths;
  final List<AdvicePoint> cautions;
  final List<TextRef> steps;
  final List<TextRef> remedies;

  /// The two doshas tradition weighs most. Gana and Yoni doshas are smaller
  /// and appear as cautions only.
  static const _major = {'nadi', 'bhakoot'};

  /// Advice from the Ashtakoota result and both Manglik checks.
  ///
  /// The conclusion follows the usual reading: below 18 of 36 is under the
  /// traditional minimum; a Nadi or Bhakoot dosha with no classical exception
  /// is treated as serious whatever the total; otherwise the score card's
  /// verdict (average, good, excellent) stands.
  static MatchAdvice vedic(
    AshtakootResult r, {
    required Sign groomMoon,
    required Sign brideMoon,
    required bool groomManglik,
    required bool brideManglik,
    List<TextRef> groomManglikWhy = const [],
    List<TextRef> brideManglikWhy = const [],
  }) {
    final counted = [
      for (final k in r.kootas)
        if (_major.contains(k.doshaId) && !k.doshaCancelled) k,
    ];
    // The verdict is the score card's own, so the two never disagree.
    final verdict = Ashtakoot.verdictId(r.total);
    final conclusion = verdict == 'below' ? 'weak' : (counted.isNotEmpty ? 'dosha' : verdict);
    final summary = TextRef(conclusion == 'weak' || conclusion == 'dosha' ? 'advice.v.$conclusion' : 'advice.v.ok', {
      'total': _fmt(r.total),
      'verdict': TextRef('match.verdict.$verdict'),
      'doshas': [for (final k in counted) TextRef('match.dosha.${k.doshaId}.name')],
    });

    List<TextRef> kootaWhy(KootaResult k) => [
      TextRef('advice.why.koota', {
        'koota': TextRef('match.koota.${k.id}.name'),
        'score': _fmt(k.score),
        'max': _fmt(k.max),
      }),
      ...k.why,
      for (final e in k.exceptions) TextRef('advice.why.exception', {'rule': e.rule, 'applies': e.applies}),
    ];

    // Heaviest kootas first: they matter most to the total.
    final byWeight = [...r.kootas]..sort((a, b) => b.max.compareTo(a.max));
    final strengths = [
      for (final k in byWeight.where((k) => k.score >= k.max).take(3))
        AdvicePoint(TextRef('advice.s.${k.id}'), kootaWhy(k)),
    ];
    final zero = byWeight.where((k) => k.score == 0).toList();
    final cautions = [
      for (final k in zero) AdvicePoint(TextRef('advice.c.${k.id}', {'cancelled': k.doshaCancelled}), kootaWhy(k)),
    ];

    final steps = <TextRef>[const TextRef('advice.step.talk')];
    final remedies = <TextRef>[];
    bool zeroIn(String id) => zero.any((k) => k.id == id);
    bool countedIn(String id) => counted.any((k) => k.id == id);
    if (zeroIn('nadi')) steps.add(const TextRef('advice.step.health'));
    if (zeroIn('bhakoot')) steps.add(const TextRef('advice.step.money'));
    if (zeroIn('gana') || zeroIn('maitri')) steps.add(const TextRef('advice.step.understand'));
    if (zeroIn('yoni') || zeroIn('vashya')) steps.add(const TextRef('advice.step.patience'));
    if (zeroIn('tara')) steps.add(const TextRef('advice.step.care'));
    if (countedIn('nadi')) remedies.add(const TextRef('advice.rem.nadi'));
    if (countedIn('bhakoot')) {
      remedies.add(TextRef('advice.rem.bhakoot', {'a': groomMoon.lord, 'b': brideMoon.lord}));
    }

    // Manglik: balanced when both or neither have it (the common rule).
    if (groomManglik != brideManglik) {
      cautions.add(
        AdvicePoint(const TextRef('advice.c.manglik'), [
          TextRef('advice.why.manglik', {'groom': true, 'present': groomManglik}),
          ...groomManglikWhy,
          TextRef('advice.why.manglik', {'groom': false, 'present': brideManglik}),
          ...brideManglikWhy,
        ]),
      );
      steps.add(const TextRef('advice.step.manglik'));
      remedies.add(const TextRef('advice.rem.manglik'));
    } else if (groomManglik) {
      strengths.add(
        AdvicePoint(const TextRef('advice.s.manglikBoth'), [
          TextRef('advice.why.manglik', {'groom': true, 'present': true}),
          ...groomManglikWhy,
          TextRef('advice.why.manglik', {'groom': false, 'present': true}),
          ...brideManglikWhy,
        ]),
      );
    }

    steps.add(const TextRef('advice.step.fullChart'));
    if (remedies.isNotEmpty) remedies.add(const TextRef('advice.rem.note'));
    return MatchAdvice(
      conclusion: conclusion,
      summary: summary,
      strengths: strengths,
      cautions: cautions,
      steps: steps,
      remedies: remedies,
    );
  }

  static const _personal = {
    Planet.sun,
    Planet.moon,
    Planet.mercury,
    Planet.venus,
    Planet.mars,
    Planet.jupiter,
    Planet.saturn,
  };

  /// Advice from Western synastry: aspects between the two people's personal
  /// planets. Trines and sextiles support, squares and oppositions challenge
  /// (as on the synastry card); conjunctions are left out of the count.
  static MatchAdvice western(List<Aspect> synastry, {required String nameA, required String nameB}) {
    final aspects = synastry.where((x) => _personal.contains(x.a) && _personal.contains(x.b) && x.type.major).toList()
      ..sort((x, y) => x.orb.compareTo(y.orb));
    bool good(Aspect x) => x.type == AspectType.trine || x.type == AspectType.sextile;
    bool hard(Aspect x) => x.type == AspectType.square || x.type == AspectType.opposition;
    final g = aspects.where(good).toList(), h = aspects.where(hard).toList();
    final conclusion = g.length > h.length ? 'good' : (g.length == h.length ? 'mixed' : 'hard');

    TextRef why(Aspect x) => TextRef('advice.w.why', {
      'a': nameA,
      'pa': x.a,
      'b': nameB,
      'pb': x.b,
      'aspect': TextRef('advice.w.aspect.${x.type.name}'),
      'orb': x.orb.toStringAsFixed(1),
    });

    // One point per theme, tightest aspect first.
    List<AdvicePoint> points(List<Aspect> list, String kind) {
      final seen = <String>{};
      return [
        for (final x in list)
          if (seen.add(_theme(x.a, x.b)) && seen.length <= 4)
            AdvicePoint(TextRef('advice.w.$kind.${_theme(x.a, x.b)}'), [why(x)]),
      ];
    }

    final strengths = points(g, 'good');
    final cautions = points(h, 'hard');
    final steps = <TextRef>[const TextRef('advice.step.talk')];
    bool hardWith(Planet p) => h.any((x) => x.a == p || x.b == p);
    if (hardWith(Planet.moon)) steps.add(const TextRef('advice.step.w.feelings'));
    if (hardWith(Planet.mercury)) steps.add(const TextRef('advice.step.w.talk'));
    if (hardWith(Planet.mars)) steps.add(const TextRef('advice.step.w.anger'));
    if (hardWith(Planet.saturn)) steps.add(const TextRef('advice.step.w.duty'));
    steps.add(const TextRef('advice.step.w.fullChart'));
    return MatchAdvice(
      conclusion: conclusion,
      summary: TextRef('advice.w.$conclusion', {'good': g.length, 'hard': h.length}),
      strengths: strengths,
      cautions: cautions,
      steps: steps,
    );
  }

  /// The life theme of an aspect between two planets: the pair's own theme
  /// for the classic relationship pairs, otherwise the theme of the more
  /// personal planet.
  static String _theme(Planet a, Planet b) {
    bool pair(Planet x, Planet y) => (a == x && b == y) || (a == y && b == x);
    if (pair(Planet.sun, Planet.moon)) return 'sunMoon';
    if (pair(Planet.venus, Planet.mars)) return 'venusMars';
    if (a == Planet.saturn || b == Planet.saturn) return 'saturn';
    if (a == Planet.moon || b == Planet.moon) return 'moon';
    if (a == Planet.venus || b == Planet.venus) return 'venus';
    if (a == Planet.mercury || b == Planet.mercury) return 'mercury';
    if (a == Planet.mars || b == Planet.mars) return 'mars';
    if (a == Planet.sun || b == Planet.sun) return 'sun';
    return 'jupiter';
  }

  static String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}
