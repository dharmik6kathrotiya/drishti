import '../astro/chart.dart';
import '../astro/constants.dart';
import '../astro/vedic/dasha.dart';
import '../astro/vedic/doshas.dart';
import '../astro/vedic/matching.dart';
import '../astro/vedic/yogas.dart';
import '../horoscope/transit_engine.dart';
import 'explain_texts.dart';

/// Something the user can tap "Explain" on.
sealed class ExplainTopic {
  const ExplainTopic();
}

class PlanetPlacementTopic extends ExplainTopic {
  const PlanetPlacementTopic(this.placement, {required this.vedic});
  final PlanetPlacement placement;
  final bool vedic;
}

class AscendantTopic extends ExplainTopic {
  const AscendantTopic(this.sign, {required this.vedic});
  final Sign sign;
  final bool vedic;
}

class NakshatraTopic extends ExplainTopic {
  const NakshatraTopic(this.nakshatra, {this.pada});
  final Nakshatra nakshatra;
  final int? pada;
}

class DashaTopic extends ExplainTopic {
  const DashaTopic(this.period, {this.chart});
  final DashaPeriod period;

  /// Natal chart, used to describe where the lord sits.
  final Chart? chart;
}

class YogaTopic extends ExplainTopic {
  const YogaTopic(this.yoga);
  final Yoga yoga;
}

class DoshaTopic extends ExplainTopic {
  const DoshaTopic(this.report);
  final DoshaReport report;
}

class TransitTopic extends ExplainTopic {
  const TransitTopic(this.transit);
  final GocharaTransit transit;
}

class KootaTopic extends ExplainTopic {
  const KootaTopic(this.koota);
  final KootaResult koota;
}

/// Free text with reasons, e.g. a horoscope section.
class TextTopic extends ExplainTopic {
  const TextTopic(this.title, this.body, {this.reasons = const [], this.source = ''});
  final String title;
  final String body;
  final List<String> reasons;
  final String source;
}

class Explanation {
  const Explanation({
    required this.title,
    required this.paragraphs,
    required this.source,
    required this.caveat,
    this.suggestedQuestion,
  });

  final String title;
  final List<String> paragraphs;
  final String source;
  final String caveat;

  /// A follow-up question for the "Ask more" button.
  final String? suggestedQuestion;

  String get body => paragraphs.join('\n\n');
}

/// Offline, deterministic explanations built from the text library. Works on
/// every phone with no model.
class ExplainService {
  ExplainService([String languageCode = 'en']) : t = FallbackTexts(explainTextsFor(languageCode));

  final FallbackTexts t;

  String _p(String key, [Map<String, String> v = const {}]) => t.fill(key, v);
  String _n(Planet p) => t.planetName(p);
  String _s(Sign s, bool vedic) => vedic ? t.rashiName(s) : t.signName(s);

  Explanation explain(ExplainTopic topic) => switch (topic) {
    PlanetPlacementTopic() => _placement(topic),
    AscendantTopic() => _ascendant(topic),
    NakshatraTopic() => _nakshatra(topic),
    DashaTopic() => _dasha(topic),
    YogaTopic() => _yoga(topic),
    DoshaTopic() => _dosha(topic),
    TransitTopic() => _transit(topic),
    KootaTopic() => _koota(topic),
    TextTopic() => Explanation(
      title: topic.title,
      paragraphs: [topic.body, if (topic.reasons.isNotEmpty) topic.reasons.map((r) => '• $r').join('\n')],
      source: topic.source,
      caveat: _p('caveat'),
      suggestedQuestion: _p('askText', {'title': topic.title.toLowerCase()}),
    ),
  };

  /// Dignity sentence for a planet in a sign.
  String dignity(Planet planet, Sign sign) {
    final v = {'planet': _n(planet), 'sign': t.signName(sign), 'lord': _n(sign.lord)};
    if (Dignity.exaltationSign(planet) == sign) return _p('exalted', v);
    if (Dignity.debilitationSign(planet) == sign) return _p('debilitated', v);
    if (Dignity.moolatrikona[planet] == sign) return _p('moolatrikona', v);
    if (sign.lord == planet) return _p('ownSign', v);
    if (planet.isNode || planet.isOuter) return '';
    return switch (Dignity.naturalRelation(planet, sign.lord)) {
      1 => _p('friendSign', v),
      -1 => _p('enemySign', v),
      _ => _p('neutralSign', v),
    };
  }

  /// Classical house-group notes for a planet in a house.
  List<String> houseNotes(Planet planet, int house) {
    const benefics = {Planet.jupiter, Planet.venus, Planet.mercury, Planet.moon};
    const malefics = {Planet.sun, Planet.mars, Planet.saturn, Planet.rahu, Planet.ketu};
    return [
      if (benefics.contains(planet) && const {1, 4, 7, 10}.contains(house)) _p('beneficKendra'),
      if (malefics.contains(planet) && const {3, 6, 10, 11}.contains(house)) _p('maleficUpachaya'),
      if (const {6, 8, 12}.contains(house)) _p('dusthana'),
      if (const {1, 5, 9}.contains(house)) _p('trikona'),
    ];
  }

  Explanation _placement(PlanetPlacementTopic topic) {
    final p = topic.placement;
    final vedic = topic.vedic;
    final paras = <String>[
      t.planetNature(p.planet),
      t.signNature(p.sign),
      if (dignity(p.planet, p.sign).isNotEmpty) dignity(p.planet, p.sign),
      if (p.house != null) ...[
        _p('occupies', {'text': t.houseNature(p.house!, vedic: vedic)}),
        ...houseNotes(p.planet, p.house!),
      ] else
        _p('noTime'),
      if (vedic) _p('nakshatraIs', {'text': t.nakshatraNature(p.nakshatra.index)}),
      if (p.isRetrograde && !p.planet.isNode) _p('retro', {'planet': _n(p.planet)}),
      if (!vedic) _p('westernNote'),
    ];
    return Explanation(
      title:
          _p('titlePlacement', {'planet': _n(p.planet), 'sign': _s(p.sign, vedic)}) +
          (p.house == null ? '' : _p('titleHouseSuffix', {'n': '${p.house}'})),
      paragraphs: paras,
      source: '${_p('signSource')} ${_p('houseSource')}',
      caveat: _p('caveat'),
      suggestedQuestion: _p('askPlacement', {'planet': _n(p.planet)}),
    );
  }

  Explanation _ascendant(AscendantTopic topic) => Explanation(
    title: '${_p(topic.vedic ? 'lagna' : 'ascendant')}: ${_s(topic.sign, topic.vedic)}',
    paragraphs: [
      _p('ascIntro'),
      t.signNature(topic.sign),
      _p('ascLord', {'lord': _n(topic.sign.lord), 'nature': t.planetNature(topic.sign.lord)}),
    ],
    source: _p('houseSource'),
    caveat: _p('caveat'),
    suggestedQuestion: _p('askAscendant'),
  );

  Explanation _nakshatra(NakshatraTopic topic) => Explanation(
    title: topic.nakshatra.name + (topic.pada == null ? '' : _p('padaSuffix', {'n': '${topic.pada}'})),
    paragraphs: [
      t.nakshatraNature(topic.nakshatra.index),
      _p('nakLord', {'lord': _n(topic.nakshatra.lord)}),
    ],
    source: _p('nakshatraSource'),
    caveat: _p('caveat'),
    suggestedQuestion: _p('askNakshatra'),
  );

  Explanation _dasha(DashaTopic topic) {
    final d = topic.period;
    final chart = topic.chart;
    final paras = <String>[t.dashaTheme(d.lord)];
    final parent = d.parent;
    if (parent != null) {
      final rel = Dignity.naturalRelation(d.lord, parent.lord);
      final relKey = rel == 1
          ? 'relFriend'
          : rel == -1
          ? 'relEnemy'
          : 'relNeutral';
      paras.add(
        _p('dashaPair', {
          'antar': _n(d.lord),
          'maha': _n(parent.lord),
          'relation': d.lord == parent.lord ? '' : _p(relKey, {'a': _n(parent.lord), 'b': _n(d.lord)}),
        }).trim(),
      );
    }
    if (chart != null && chart.planets[d.lord] != null) {
      final pl = chart.planets[d.lord]!;
      paras.add(
        _p('dashaPlacement', {
          'planet': _n(d.lord),
          'sign': _s(pl.sign, chart.settings.sidereal),
          'house': pl.house == null ? '' : _p('houseSuffix', {'n': '${pl.house}'}),
        }),
      );
      if (pl.house != null) paras.add(_p('houseRelates', {'text': t.houseNature(pl.house!, vedic: true)}));
    }
    const levels = ['mahadasha', 'antardasha', 'pratyantardasha'];
    return Explanation(
      title: '${_n(d.lord)} ${_p(levels[(d.level - 1).clamp(0, 2)])}',
      paragraphs: paras,
      source: _p('dashaSource'),
      caveat: _p('caveat'),
      suggestedQuestion: _p('askDasha', {'planet': _n(d.lord)}),
    );
  }

  Explanation _yoga(YogaTopic topic) => Explanation(
    title: topic.yoga.name,
    paragraphs: [
      topic.yoga.reason,
      topic.yoga.meaning,
      if (topic.yoga.note != null) topic.yoga.note!,
      _p('yogaTiming'),
    ],
    source: topic.yoga.source,
    caveat: _p('caveat'),
    suggestedQuestion: _p('askYoga', {'yoga': topic.yoga.name}),
  );

  Explanation _dosha(DoshaTopic topic) => Explanation(
    title: topic.report.name,
    paragraphs: [
      topic.report.summary,
      ...topic.report.factors,
      if (topic.report.mitigations.isNotEmpty) _p('softening', {'list': topic.report.mitigations.join(' ')}),
      _p('doshaNote', {'differ': _p('caveatTraditionsDiffer')}),
    ],
    source: topic.report.source,
    caveat: _p('caveat'),
    suggestedQuestion: _p('askDosha', {'dosha': topic.report.name}),
  );

  Explanation _transit(TransitTopic topic) {
    final g = topic.transit;
    final v = {'planet': _n(g.planet), 'house': t.ordinal(g.houseFromMoon)};
    return Explanation(
      title: _p('titleTransit', {'planet': _n(g.planet), 'sign': t.signName(g.sign)}),
      paragraphs: [
        _p(g.favourable ? 'transitGood' : 'transitHard', v),
        if (g.obstructed) _p('transitObstructed', {'by': _n(g.obstructedBy!), 'vh': t.ordinal(g.vedhaHouse ?? 0)}),
        _p('transitTouches', {'text': t.houseNature(g.houseFromMoon, vedic: true)}),
        t.planetNature(g.planet),
      ],
      source: _p('transitSource'),
      caveat: _p('caveat'),
      suggestedQuestion: _p('askTransit', {'planet': _n(g.planet)}),
    );
  }

  Explanation _koota(KootaTopic topic) {
    final k = topic.koota;
    return Explanation(
      title: '${k.name}: ${_fmt(k.score)} / ${_fmt(k.max)}',
      paragraphs: [
        t.kootaMeaning(k.name),
        _p('groomBride', {'boy': k.boyValue, 'girl': k.girlValue}),
        if (k.score == 0) _p('kootaZero'),
      ],
      source: _p('kootaSource'),
      caveat: _p('caveat'),
    );
  }

  static String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}
