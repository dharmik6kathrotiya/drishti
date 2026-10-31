import '../astro/constants.dart';
import '../i18n/astro_names.dart';
import '../i18n/engine_texts.dart';
import 'explain_texts.dart';
import 'fact_sheet.dart';
import 'fact_texts.dart';
import 'longevity_facts.dart';

/// Renders [Fact]s for display in the user's language.
///
/// [Fact.text] stays English: it is the stable form given to the language
/// model and used by the output guard. Everything shown to the user goes
/// through [render], which rebuilds the sentence from the fact sheet data.
class FactRenderer {
  FactRenderer(this.lang)
    : names = AstroNames.of(lang),
      ft = FactTexts(lang),
      et = EngineTexts.of(lang),
      t = FallbackTexts(explainTextsFor(lang));

  final String lang;
  final AstroNames names;
  final FactTexts ft;
  final EngineTexts et;
  final FallbackTexts t;

  bool get _english => lang == 'en';

  String planet(Planet p) => names.planet(p);
  String sign(Sign s, {required bool vedic}) => names.signDisplay(s, vedic: vedic);

  /// Display text of a fact (English facts are returned unchanged).
  String render(Fact f, FactSheet s) {
    if (_english) return f.text;
    try {
      return _render(f, s) ?? f.text;
    } catch (_) {
      return f.text;
    }
  }

  String? _render(Fact f, FactSheet s) {
    final chart = s.chart;
    final vedic = s.vedic;
    String sn(Sign x) => sign(x, vedic: vedic);
    String deg(double lon) => formatDms(lon % 30, seconds: false);

    switch (f.id) {
      case 'missing.time':
        return ft.t('f.noTime');
      case 'missing.place':
        return ft.t('f.noPlace');
      case 'dasha.approx':
        return ft.t('f.dashaApprox');
      case 'ascendant':
        final a = chart.ascendantSign!;
        return ft.t(vedic ? 'f.asc' : 'f.ascW', {'sign': sn(a), 'deg': deg(chart.ascendant!), 'lord': planet(a.lord)});
      case 'moon.sign':
        return ft.t(vedic ? 'f.moon' : 'f.moonW', {'moon': sn(chart.moon.sign), 'sun': sn(chart.sun.sign)});
      case 'nakshatra':
        final m = chart.moon;
        return ft.t('f.nakshatra', {
          'nak': names.nakshatra(m.nakshatra.index),
          'n': '${m.pada}',
          'lord': planet(m.nakshatra.lord),
        });
      case 'sadesati':
        final ss = s.sadeSati!;
        return ss.running
            ? ft.t('f.ssOn', {'phase': '${ss.phase}', 'sign': sn(ss.saturnSign)})
            : ft.t('f.ssOff', {'ord': t.ordinal(ss.houseFromMoon), 'dhaiya': ss.smallPanoti ? ft.t('f.dhaiya') : ''});
    }

    if (f.kind == FactKind.longevity) {
      final r = s.longevity;
      if (r == null) return null;
      return longevityFactTexts(r, ft, planet: planet, sign: sn, date: ft.dayMonthYear)[f.id];
    }

    if (f.id.startsWith('planet.')) {
      final p = chart[f.planet!];
      final dign = [
        if (p.isExalted) ft.t('d.exalted'),
        if (p.isDebilitated) ft.t('d.debilitated'),
        if (p.isOwnSign) ft.t('d.own'),
        if (p.isRetrograde && !p.planet.isNode) ft.t('d.retro'),
      ];
      return ft.t('f.planet', {
        'planet': planet(p.planet),
        'sign': sn(p.sign),
        'deg': deg(p.longitude),
        'house': p.house == null ? '' : ft.t('f.house', {'n': '${p.house}'}),
        'nak': vedic ? ft.t('f.nak', {'nak': names.nakshatra(p.nakshatra.index), 'n': '${p.pada}'}) : '',
        'dign': dign.isEmpty ? '' : ft.t('f.dign', {'list': dign.join(', ')}),
      });
    }

    if (f.id.startsWith('dasha.')) {
      final level = int.tryParse(f.id.substring(6));
      if (level == null || level < 1 || level > s.running.length) return null;
      final d = s.running[level - 1];
      return ft.t('f.dasha', {
        'level': ft.t('lvl.$level'),
        'planet': planet(d.lord),
        'from': ft.dayMonthYear(d.start),
        'to': ft.dayMonthYear(d.end),
      });
    }

    if (f.id.startsWith('period.')) {
      final i = int.tryParse(f.id.substring(7));
      if (i == null || i < 1 || i > s.upcomingAntardashas.length) return null;
      final a = s.upcomingAntardashas[i - 1];
      return t.fill('periodRange', {
        'maha': planet(a.parent?.lord ?? a.lord),
        'antar': planet(a.lord),
        'from': ft.monthYear(a.start),
        'to': ft.monthYear(a.end),
      });
    }

    if (f.id.startsWith('yoga.')) {
      final i = FactSheet.yogaIds(s.yogas).indexOf(f.id);
      if (i < 0) return null;
      final y = s.yogas[i];
      return ft.t('f.yoga', {'name': et.yogaName(y), 'reason': et.yogaReason(y)});
    }

    if (f.id.startsWith('dosha.')) {
      final d = s.doshas.where((d) => 'dosha.${FactSheet.slug(d.name)}' == f.id).firstOrNull;
      if (d == null) return null;
      final factors = et.doshaFactors(d);
      final soft = et.doshaMitigations(d);
      return ft.t('f.dosha', {
        'name': et.doshaName(d),
        'status': ft.t(d.present ? 'st.present' : 'st.absent'),
        'factors': factors.isEmpty ? '' : ft.t('f.factors', {'list': factors.join(' ')}),
        'soft': soft.isEmpty ? '' : ft.t('f.soft', {'list': soft.join(' ')}),
      });
    }

    if (f.id.startsWith('transit.')) {
      final tr = s.transits;
      if (tr == null) return null;
      if (vedic) {
        final g = tr.gochara.where((g) => g.planet == f.planet).firstOrNull;
        if (g == null) return null;
        final verdict = g.favourable ? (g.obstructed ? 'v.obstructed' : 'v.good') : 'v.hard';
        return ft.t('f.transit', {
          'planet': planet(g.planet),
          'sign': sn(g.sign),
          'ord': t.ordinal(g.houseFromMoon),
          'lagna': g.houseFromAscendant == null ? '' : ft.t('f.fromLagna', {'ord': t.ordinal(g.houseFromAscendant!)}),
          'retro': g.retrograde ? ft.t('f.retro') : '',
          'verdict': ft.t(verdict),
        });
      }
      final a = tr.aspects
          .where((a) => a.natal != null && a.type != null && f.id == 'transit.${a.transiting.name}.${a.natal!.name}')
          .firstOrNull;
      if (a == null) return null;
      return ft.t('f.transitW', {
        'planet': planet(a.transiting),
        'aspect': ft.t('a.${a.type!.name}'),
        'natal': planet(a.natal!),
        'orb': a.orb?.toStringAsFixed(1) ?? '',
      });
    }
    return null;
  }
}
