import '../astro/chart.dart';
import '../astro/constants.dart';
import '../astro/settings.dart';
import '../astro/vedic/dasha.dart';
import '../astro/vedic/doshas.dart';
import '../astro/vedic/longevity.dart';
import '../astro/vedic/yogas.dart';
import '../horoscope/horoscope_generator.dart';
import '../horoscope/transit_engine.dart';
import '../models/profile.dart';
import 'explain_texts.dart';
import 'fact_texts.dart';
import 'longevity_facts.dart';

enum FactKind {
  ascendant,
  planet,
  moonSign,
  nakshatra,
  dasha,
  period,
  sadeSati,
  yoga,
  dosha,
  transit,
  longevity,
  missing,
}

/// One grounded fact computed by the engine. The AI may only talk about
/// facts that appear in a [FactSheet].
class Fact {
  const Fact({
    required this.id,
    required this.kind,
    required this.text,
    this.source = '',
    this.planet,
    this.house,
    this.sign,
  });

  /// Stable identifier, e.g. `planet.saturn` or `dasha.maha`.
  final String id;
  final FactKind kind;
  final String text;
  final String source;
  final Planet? planet;
  final int? house;
  final Sign? sign;

  Map<String, dynamic> toJson() => {'id': id, 'kind': kind.name, 'text': text, if (source.isNotEmpty) 'source': source};
}

/// Everything the engine knows about one person, in a compact form usable by
/// both the rule-based answerer and the language model.
class FactSheet {
  FactSheet({
    required this.profile,
    required this.settings,
    required this.chart,
    required this.facts,
    required this.running,
    required this.upcomingAntardashas,
    required this.yogas,
    required this.doshas,
    required this.sadeSati,
    required this.transits,
    required this.generatedAt,
    this.longevity,
  });

  final Profile profile;
  final CalcSettings settings;
  final Chart chart;
  final List<Fact> facts;

  /// Running Vimshottari chain (Mahadasha, Antardasha, Pratyantardasha).
  final List<DashaPeriod> running;

  /// The next few Antardashas, for "when" questions.
  final List<DashaPeriod> upcomingAntardashas;
  final List<Yoga> yogas;
  final List<DoshaReport> doshas;
  final SadeSatiStatus? sadeSati;
  final TransitSnapshot? transits;
  final DateTime generatedAt;

  /// Classical longevity calculation (Vedic only).
  final LongevityReport? longevity;

  bool get vedic => settings.system == AstroSystem.vedic;
  bool get hasHouses => chart.hasHouses;

  Fact? byId(String id) => facts.where((f) => f.id == id).firstOrNull;
  Iterable<Fact> ofKind(FactKind k) => facts.where((f) => f.kind == k);

  /// Houses a planet occupies or rules (empty without a birth time).
  Set<int> housesOf(Planet p) {
    if (!hasHouses) return const {};
    return {
      if (chart.planets[p]?.house != null) chart.planets[p]!.house!,
      for (var h = 1; h <= 12; h++)
        if (chart.houseLord(h) == p) h,
    };
  }

  /// Compact plain-text form for the language model prompt. Longevity facts
  /// are included only for lifespan questions, so other answers stay short
  /// and never bring the topic up unasked.
  String toPromptText({bool longevity = false, bool periods = false}) {
    final b = StringBuffer()
      ..writeln('PERSON: ${profile.name}')
      ..writeln('SYSTEM: ${vedic ? 'Vedic (sidereal, ${settings.ayanamsa.label})' : 'Western (tropical)'}');
    for (final f in facts) {
      if (f.kind == FactKind.longevity && !longevity) continue;
      if (f.kind == FactKind.period && !periods) continue;
      b.writeln('- [${f.id}] ${f.text}');
    }
    return b.toString();
  }

  Map<String, dynamic> toJson() => {
    'name': profile.name,
    'system': settings.system.name,
    'hasHouses': hasHouses,
    'facts': facts.map((f) => f.toJson()).toList(),
  };

  /// Builds the sheet. Returns null when the profile has no birth date.
  static FactSheet? build(Profile profile, CalcSettings settings, {DateTime? now}) {
    if (!profile.hasDate) return null;
    final at = (now ?? DateTime.now()).toUtc();
    final utc = profile.birthUtc()!;
    final vedic = settings.system == AstroSystem.vedic;
    final chart = ChartCalculator.cast(
      utc: utc,
      settings: settings,
      latitude: profile.place?.latitude,
      longitude: profile.place?.longitude,
      withHouses: profile.canCastFullChart,
    );
    final facts = <Fact>[];
    String pn(Planet p) => capitalize(p.name);
    String sn(Sign s) => vedic ? '${s.rashi} (${capitalize(s.name)})' : capitalize(s.name);

    if (!profile.hasTime) {
      facts.add(
        const Fact(
          id: 'missing.time',
          kind: FactKind.missing,
          text: 'Birth time is unknown: no Ascendant or houses; the Moon may be off by a few degrees.',
        ),
      );
    }
    if (!profile.hasPlace) {
      facts.add(
        const Fact(
          id: 'missing.place',
          kind: FactKind.missing,
          text: 'Birthplace is unknown: timezone assumed, no houses.',
        ),
      );
    }

    if (chart.ascendant != null) {
      final s = chart.ascendantSign!;
      facts.add(
        Fact(
          id: 'ascendant',
          kind: FactKind.ascendant,
          sign: s,
          text:
              '${vedic ? 'Lagna' : 'Ascendant'} is ${sn(s)} at ${formatDms(chart.ascendant! % 30, seconds: false)}; lagna lord ${pn(s.lord)}.',
        ),
      );
    }

    for (final p in chart.planets.values) {
      final dign = [
        if (p.isExalted) 'exalted',
        if (p.isDebilitated) 'debilitated',
        if (p.isOwnSign) 'own sign',
        if (p.isRetrograde && !p.planet.isNode) 'retrograde',
      ];
      final house = p.house == null ? '' : ', house ${p.house}';
      final nak = vedic ? ', ${p.nakshatra.name} pada ${p.pada}' : '';
      facts.add(
        Fact(
          id: 'planet.${p.planet.name}',
          kind: FactKind.planet,
          planet: p.planet,
          sign: p.sign,
          house: p.house,
          text:
              '${pn(p.planet)} in ${sn(p.sign)} ${formatDms(p.degreeInSign, seconds: false)}$house$nak'
              '${dign.isEmpty ? '' : ' (${dign.join(', ')})'}.',
        ),
      );
    }

    facts.add(
      Fact(
        id: 'moon.sign',
        kind: FactKind.moonSign,
        sign: chart.moon.sign,
        text: '${vedic ? 'Rashi (Moon sign)' : 'Moon sign'}: ${sn(chart.moon.sign)}; Sun sign: ${sn(chart.sun.sign)}.',
      ),
    );
    if (vedic) {
      facts.add(
        Fact(
          id: 'nakshatra',
          kind: FactKind.nakshatra,
          text:
              'Birth nakshatra: ${chart.moon.nakshatra.name} pada ${chart.moon.pada}, lord ${pn(chart.moon.nakshatra.lord)}.',
          source: 'Standard nakshatra list (BPHS)',
        ),
      );
    }

    var running = <DashaPeriod>[];
    var upcoming = <DashaPeriod>[];
    SadeSatiStatus? sadeSati;
    var yogas = <Yoga>[];
    var doshas = <DoshaReport>[];
    LongevityReport? longevity;
    if (vedic) {
      final v = Vimshottari();
      running = v.runningAt(utc, chart.moon.longitude, at);
      final names = ['Mahadasha', 'Antardasha', 'Pratyantardasha'];
      for (final d in running) {
        facts.add(
          Fact(
            id: 'dasha.${d.level}',
            kind: FactKind.dasha,
            planet: d.lord,
            text: '${names[d.level - 1]}: ${pn(d.lord)} from ${_date(d.start)} to ${_date(d.end)}.',
            source: 'Vimshottari dasha (BPHS)',
          ),
        );
      }
      if (running.isNotEmpty) {
        final maha = running.first;
        final mahas = v.mahadashas(utc, chart.moon.longitude);
        final idx = mahas.indexWhere((m) => m.start == maha.start);
        final candidates = [
          ...v.subPeriods(maha),
          if (idx >= 0 && idx + 1 < mahas.length) ...v.subPeriods(mahas[idx + 1]),
        ];
        upcoming = candidates.where((a) => a.end.isAfter(at)).take(8).toList();
        // The windows "when" answers name, so the model can cite them.
        for (final (i, a) in upcoming.indexed) {
          facts.add(
            Fact(
              id: 'period.${i + 1}',
              kind: FactKind.period,
              planet: a.lord,
              text:
                  'Antardasha: ${pn(a.parent?.lord ?? a.lord)}/${pn(a.lord)} from ${_date(a.start)} to ${_date(a.end)}.',
              source: 'Vimshottari dasha (BPHS)',
            ),
          );
        }
      }
      if (!profile.hasTime) {
        facts.add(
          const Fact(
            id: 'dasha.approx',
            kind: FactKind.missing,
            text: 'Dasha dates are approximate (birth time unknown).',
          ),
        );
      }

      longevity = Longevity.compute(chart, birthUtc: utc, now: at, dasha: v);
      longevityFactTexts(longevity, FactTexts('en'), planet: pn, sign: sn, date: _date).forEach((id, text) {
        facts.add(
          Fact(
            id: id,
            kind: FactKind.longevity,
            text: text,
            source: id.startsWith('maraka') ? 'Maraka, BPHS ch. 44' : 'Jaimini Upadesa Sutras 2.1',
          ),
        );
      });

      sadeSati = Doshas.sadeSati(chart.moon.sign, at, settings.ayanamsa);
      facts.add(
        Fact(
          id: 'sadesati',
          kind: FactKind.sadeSati,
          text: sadeSati.running
              ? 'Sade Sati running: phase ${sadeSati.phase} of 3 (Saturn in ${sn(sadeSati.saturnSign)}).'
              : 'Sade Sati not running; Saturn is ${ordinal(sadeSati.houseFromMoon)} from the Moon sign'
                    '${sadeSati.smallPanoti ? ' (Dhaiya / small panoti)' : ''}.',
          source: 'Saturn transit 12th/1st/2nd from natal Moon',
        ),
      );

      yogas = YogaDetector.detect(chart);
      final ids = yogaIds(yogas);
      for (final (i, y) in yogas.indexed) {
        facts.add(Fact(id: ids[i], kind: FactKind.yoga, text: '${y.name}: ${y.reason}', source: y.source));
      }

      doshas = [Doshas.manglik(chart), Doshas.kaalSarp(chart)];
      for (final d in doshas) {
        facts.add(
          Fact(
            id: 'dosha.${slug(d.name)}',
            kind: FactKind.dosha,
            text:
                '${d.name}: ${d.present ? 'present' : 'not present'}'
                '${d.factors.isEmpty ? '' : ' (${d.factors.join(' ')})'}'
                '${d.mitigations.isEmpty ? '' : ' Softening: ${d.mitigations.join(' ')}'}',
            source: d.source,
          ),
        );
      }
    }

    TransitSnapshot? transits;
    try {
      final natal = HoroscopeSubject.fromProfile(profile).natalFor(settings);
      transits = TransitEngine.snapshot(natal, at, settings);
      if (vedic) {
        for (final g in transits.gochara.where((g) => !const {Planet.moon}.contains(g.planet))) {
          final verdict = g.favourable
              ? (g.obstructed ? 'favourable but obstructed (vedha)' : 'favourable')
              : 'challenging';
          facts.add(
            Fact(
              id: 'transit.${g.planet.name}',
              kind: FactKind.transit,
              planet: g.planet,
              sign: g.sign,
              house: g.houseFromMoon,
              text:
                  'Transit ${pn(g.planet)} in ${sn(g.sign)}, ${ordinal(g.houseFromMoon)} from Moon sign'
                  '${g.houseFromAscendant == null ? '' : ' and ${ordinal(g.houseFromAscendant!)} from Lagna'}'
                  '${g.retrograde ? ', retrograde' : ''}: traditionally $verdict.',
              source: 'Gochara, Phaladeepika ch. 26',
            ),
          );
        }
      } else {
        for (final a in transits.aspects.where((a) => a.natal != null && a.type != null).take(8)) {
          facts.add(
            Fact(
              id: 'transit.${a.transiting.name}.${a.natal!.name}',
              kind: FactKind.transit,
              planet: a.transiting,
              text:
                  'Transit ${pn(a.transiting)} ${a.type!.name} natal ${pn(a.natal!)} (orb ${a.orb?.toStringAsFixed(1)}°).',
              source: 'Western transit aspects',
            ),
          );
        }
      }
    } catch (_) {
      // Transits are optional context; a failure must not block answers.
    }

    return FactSheet(
      profile: profile,
      settings: settings,
      chart: chart,
      facts: facts,
      running: running,
      upcomingAntardashas: upcoming,
      yogas: yogas,
      doshas: doshas,
      sadeSati: sadeSati,
      transits: transits,
      generatedAt: at,
      longevity: longevity,
    );
  }

  static String _date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Stable id fragment from an English name ("Raja Yoga" -> "raja_yoga").
  static String slug(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');

  /// Fact ids of [yogas] in order. A yoga that forms more than once (two Raja
  /// yogas, say) gets _2, _3 ... so each fact names its own planets.
  static List<String> yogaIds(List<Yoga> yogas) {
    final seen = <String, int>{};
    return [
      for (final y in yogas)
        () {
          final base = 'yoga.${slug(y.name)}';
          final n = seen[base] = (seen[base] ?? 0) + 1;
          return n == 1 ? base : '${base}_$n';
        }(),
    ];
  }
}
