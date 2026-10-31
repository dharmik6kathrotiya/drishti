import '../astro/constants.dart';
import '../astro/vedic/longevity.dart';
import 'fact_texts.dart';

/// Fact lines of a [LongevityReport], keyed by fact id, in [ft]'s language.
/// The fact sheet uses English (model input); the renderer the app language.
Map<String, String> longevityFactTexts(
  LongevityReport r,
  FactTexts ft, {
  required String Function(Planet) planet,
  required String Function(Sign) sign,
  required String Function(DateTime) date,
}) {
  String withType(Sign s) => ft.t('f.signMod', {'sign': sign(s), 'mod': ft.t('mod.${s.modality.name}')});
  final span = r.span;
  return {
    'longevity.span': span == null
        ? ft.t('f.lifeOpen', {'why': ft.t(r.pairs.length < 2 ? 'f.whyNoTime' : 'f.whyDiffer')})
        : ft.t('f.life', {
            'span': ft.t('span.${span.name}'),
            'from': '${span.fromAge}',
            'to': '${span.toAge}',
            'rule': switch (r.rule) {
              'horaLagna' => ft.t('f.ruleHora'),
              'moonSaturn' => ft.t('f.ruleMoon'),
              _ => ft.t('f.ruleMajority', {'n': '${r.agreeing}', 'total': '${r.pairs.length}'}),
            },
            'past': r.pastSpan ? ft.t('f.lifePast', {'age': '${r.ageNow}'}) : '',
          }),
    'longevity.pairs': ft.t('f.pairs', {
      'list': [
        for (final p in r.pairs)
          ft.t('pair.${p.key}', {'a': withType(p.a), 'b': withType(p.b), 'span': ft.t('span.${p.span.name}')}),
      ].join('; '),
    }),
    if (r.marakas.isNotEmpty) 'maraka': ft.t('f.maraka', {'list': r.marakas.map(planet).join(', ')}),
    for (final (i, a) in r.sensitive.indexed)
      'maraka.${i + 1}': ft.t('f.marakaPeriod', {
        'maha': planet(a.parent?.lord ?? a.lord),
        'antar': planet(a.lord),
        'from': date(a.start),
        'to': date(a.end),
      }),
    if (span != null && !r.pastSpan && r.marakas.isNotEmpty && r.sensitive.isEmpty) 'maraka.none': ft.t('f.marakaNone'),
  };
}
