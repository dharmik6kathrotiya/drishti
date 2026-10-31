import '../../i18n/text_ref.dart';
import '../chart.dart';
import '../constants.dart';
import 'aspects.dart';

/// A plain reading of a composite chart: an overall verdict and what the
/// relationship is about first, then (on "Why?") the aspects that decided it.
///
/// Follows the usual composite interpretation (Robert Hand, "Planets in
/// Composite", 1975): the composite Sun shows what the relationship is for,
/// the Moon how it feels, and aspects between the personal planets whether
/// its parts work together (trine, sextile) or pull apart (square,
/// opposition). Saturn conjunctions bring weight and duty; Mars conjunctions
/// bring energy that can go either way, so they are not counted.
class CompositeReading {
  const CompositeReading._({
    required this.tone,
    required this.harmonious,
    required this.challenging,
    required this.points,
    required this.aspects,
  });

  /// 1 mostly supportive, 0 mixed, -1 needs work.
  final int tone;
  final List<Aspect> harmonious;
  final List<Aspect> challenging;

  /// The conclusion in plain words, most important first.
  final List<TextRef> points;

  /// Every major aspect between the planets read here, tightest first.
  final List<Aspect> aspects;

  static const _read = {
    Planet.sun,
    Planet.moon,
    Planet.mercury,
    Planet.venus,
    Planet.mars,
    Planet.jupiter,
    Planet.saturn,
  };

  /// The pairs that have their own plain sentence, in order of importance.
  static String? _pairId(Planet a, Planet b) {
    bool pair(Planet x, Planet y) => (a == x && b == y) || (a == y && b == x);
    const close = {Planet.sun, Planet.moon, Planet.venus};
    if (pair(Planet.sun, Planet.moon)) return 'sunMoon';
    if (pair(Planet.venus, Planet.mars)) return 'venusMars';
    if (pair(Planet.moon, Planet.venus)) return 'moonVenus';
    if (pair(Planet.sun, Planet.venus)) return 'sunVenus';
    if (pair(Planet.mercury, Planet.moon)) return 'mercuryMoon';
    if ((a == Planet.saturn && close.contains(b)) || (b == Planet.saturn && close.contains(a))) return 'saturn';
    if ((a == Planet.jupiter && close.contains(b)) || (b == Planet.jupiter && close.contains(a))) return 'jupiter';
    return null;
  }

  /// +1 harmonious, -1 challenging, 0 not counted.
  static int kind(Aspect x) => switch (x.type) {
    AspectType.trine || AspectType.sextile => 1,
    AspectType.square || AspectType.opposition => -1,
    AspectType.conjunction =>
      (x.a == Planet.saturn || x.b == Planet.saturn) ? -1 : ((x.a == Planet.mars || x.b == Planet.mars) ? 0 : 1),
    _ => 0,
  };

  static CompositeReading of(Chart composite) {
    final planets = {
      for (final e in composite.planets.entries)
        if (_read.contains(e.key)) e.key: e.value,
    };
    final aspects = aspectsBetween(
      planets,
      null,
      orbs: const AspectOrbs(includeMinor: false),
    ).where((x) => x.type.major).toList();
    final good = aspects.where((x) => kind(x) > 0).toList();
    final hard = aspects.where((x) => kind(x) < 0).toList();
    final tone = good.length - hard.length >= 2 ? 1 : (hard.length - good.length >= 2 ? -1 : 0);

    final sun = composite[Planet.sun].sign.element.name;
    final moon = composite[Planet.moon].sign.element.name;
    final points = <TextRef>[
      TextRef('comp.tone.${const {1: 'good', 0: 'mixed', -1: 'hard'}[tone]}'),
      TextRef('comp.sun.$sun'),
      TextRef('comp.moon.$moon'),
    ];
    // Up to three of the most telling aspects, tightest first, one per pair.
    final seen = <String>{};
    for (final x in aspects) {
      final id = _pairId(x.a, x.b);
      if (id == null || !seen.add(id)) continue;
      final k = kind(x);
      points.add(TextRef('comp.asp.$id.${k > 0 ? 'good' : (k < 0 ? 'hard' : 'mixed')}'));
      if (seen.length == 3) break;
    }
    return CompositeReading._(tone: tone, harmonious: good, challenging: hard, points: points, aspects: aspects);
  }
}
