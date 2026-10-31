import 'dart:convert';
import 'dart:io';

import 'package:drishti/core/ai/ai_memory.dart';
import 'package:drishti/core/ai/answerer.dart';
import 'package:drishti/core/ai/explain_service.dart';
import 'package:drishti/core/ai/explain_texts.dart';
import 'package:drishti/core/ai/fact_sheet.dart';
import 'package:drishti/core/ai/local_llm.dart';
import 'package:drishti/core/ai/model_manager.dart';
import 'package:drishti/core/ai/safety.dart';
import 'package:drishti/core/ai/sha256.dart';
import 'package:drishti/core/astro/constants.dart';
import 'package:drishti/core/astro/settings.dart';
import 'package:drishti/core/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

import '../helpers/ephemeris_setup.dart';

const mumbai = Place(
  name: 'Mumbai',
  region: 'Maharashtra',
  countryCode: 'IN',
  latitude: 19.0728,
  longitude: 72.8826,
  timezoneId: 'Asia/Kolkata',
);

Profile fullProfile() => Profile(
  id: 'p1',
  name: 'Asha',
  birthDate: DateTime(1990, 8, 15),
  birthHour: 10,
  birthMinute: 30,
  timeAccuracy: TimeAccuracy.exact,
  place: mumbai,
);

final _now = DateTime.utc(2026, 10, 27, 6);

void main() {
  setUpAll(setUpEphemeris);

  group('Sha256', () {
    test('standard test vectors', () {
      expect(Sha256.of(const []), 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855');
      expect(Sha256.of(utf8.encode('abc')), 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
      expect(
        Sha256.of(utf8.encode('abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq')),
        '248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1',
      );
    });

    test('streaming in uneven chunks equals one-shot', () {
      final data = List<int>.generate(100000, (i) => (i * 31) % 256);
      final h = Sha256();
      for (var i = 0; i < data.length; i += 777) {
        h.add(data.sublist(i, (i + 777).clamp(0, data.length)));
      }
      expect(h.hex(), Sha256.of(data));
    });
  });

  group('Model catalogue', () {
    test('every model lists the languages it passed the release gate in', () {
      for (final m in loadCatalogue()) {
        expect(m.languages, isNotEmpty, reason: m.id);
        expect(m.languages.every(answerLanguageNames.containsKey), isTrue, reason: m.id);
      }
      final m = loadCatalogue(
        '[{"id":"x","name":"x","description":"","fileName":"x.gguf","url":"u",'
        '"sizeBytes":1,"license":"l","baseModel":"b"}]',
      ).single;
      expect(m.supports('en'), isTrue);
      expect(m.supports('hi'), isFalse);
      // An English-only model never sees Indian scripts; Indian-language
      // models take English questions too.
      expect(m.handles('en', 'How is my career?'), isTrue);
      expect(m.handles('en', 'मैं अपनी जान देना चाहता हूँ'), isFalse);
      expect(m.handles('hi', 'How is my career?'), isFalse);
    });
  });

  group('Safety', () {
    test('crisis questions get the helpline response first', () {
      final a = RuleBasedAnswerer.safetyGate('I want to end my life', teen: false)!;
      expect(a.safetyResponse, isTrue);
      expect(a.text, contains('14416'));
      expect(a.text, contains('1800-599-0019'));
      expect(RuleBasedAnswerer.safetyGate('mujhe jeena nahi hai', teen: false), isNotNull);
      for (final q in [
        'I feel like ending my life',
        "I don't want to live anymore",
        'I keep hurting myself',
        'I have decided to take my own life',
        'Nothing matters anymore, I want to end everything',
        'मैं अपनी जान देना चाहता हूँ',
      ]) {
        expect(RuleBasedAnswerer.safetyGate(q, teen: false)?.safetyResponse, isTrue, reason: q);
      }
    });

    test('native timing words only match at a word start', () {
      expect(detectIntent('আমার স্বাস্থ্য কেমন থাকবে?').asksTiming, isFalse);
      expect(detectIntent('என் தொழில் எப்படி இருக்கும்?').asksTiming, isFalse);
      expect(detectIntent('আমার বিয়ে কবে হবে?').asksTiming, isTrue);
      expect(detectIntent('আমার বর্তমান দশার অর্থ কী?').intent, isNot(Intent.money));
    });

    test('lifespan questions get the classical calculation, not a refusal', () {
      for (final q in ['When will I die?', 'meri mrityu kab hogi', 'At what age will I pass away?']) {
        expect(Safety.asksDeath(q), isTrue, reason: q);
        expect(RuleBasedAnswerer.safetyGate(q, teen: false), isNull, reason: q);
        expect(RuleBasedAnswerer.safetyGate(q, teen: true)!.text, contains('only for adults'), reason: q);
      }
      // Crisis wording still gets the helplines first.
      expect(RuleBasedAnswerer.safetyGate('I want to die', teen: false)!.text, contains('14416'));
      // "jaan-pehchaan" (acquaintance) must not trigger the crisis response.
      expect(Safety.isCrisis('मेरी जान पहचान वालों से रिश्ते कैसे रहेंगे?'), isFalse);

      final sheet = FactSheet.build(fullProfile(), const CalcSettings(), now: _now)!;
      final a = RuleBasedAnswerer().answer('When will I die?', sheet);
      expect(a.safetyResponse, isFalse);
      expect(a.text, contains('Jaimini three-pair method'));
      expect(a.text, contains('not a medical fact'));
      expect(Safety.violations(a.text), isEmpty);
      expect(a.notes.join(' '), contains('14416'));
      // The facts reach the model only for lifespan questions.
      expect(buildGroundedPrompt(sheet, 'How is my career?'), isNot(contains('[longevity.span]')));
      expect(buildGroundedPrompt(sheet, 'When will I die?'), contains('[longevity.span]'));
    });

    test('answers are short unless detail is asked for', () {
      final sheet = FactSheet.build(fullProfile(), const CalcSettings(), now: _now)!;
      final r = RuleBasedAnswerer();
      final full = r.answer('How does my chart look for career?', sheet);
      final short = r.answer('How does my chart look for career?', sheet, detailed: false);
      expect(short.detailed, isFalse);
      expect(short.text.length, lessThan(full.text.length));
      // Grounded: the short text cites real fact ids, and they never show.
      final ids = RegExp(r'\[([a-z0-9_.]+)\]').allMatches(short.text).map((m) => m[1]!).toList();
      expect(ids, isNotEmpty);
      expect(ids.every((id) => sheet.byId(id) != null), isTrue, reason: '$ids');
      expect(short.displayText, isNot(contains('[')));
      expect(short.factors, full.factors.length == short.factors.length ? anything : isNotEmpty);

      // The short answer says what to expect without positions; the chart
      // reasons are kept for "Why?", and the verdict goes to the model.
      for (final p in Planet.values.where((p) => !p.isOuter)) {
        expect(short.displayText, isNot(contains(capitalize(p.name))), reason: short.displayText);
      }
      expect(short.displayText, isNot(contains(' house')));
      expect(short.displayText, contains('According to your chart'));
      expect(short.why, contains('10th house'));
      expect(short.tone, isNotNull);
      final prompt = buildGroundedPrompt(
        sheet,
        'How is my career?',
        focus: short.focusIds,
        tone: short.tone,
        keyPoints: short.keyPoints,
      );
      expect(prompt, contains('CHART READING: '));
      expect(prompt, contains('KEY POINTS: According to your chart'));
      final nature = r.answer('Tell me about my personality', sheet, detailed: false);
      expect(nature.displayText, contains('By your chart'));
      expect(nature.why, contains('Moon'));
      expect(AiAnswer.fromJson(short.toJson()).why, short.why);
      final whenShort = r.answer('When will my career grow?', sheet, detailed: false);
      for (final p in Planet.values) {
        expect(whenShort.displayText, isNot(contains(capitalize(p.name))), reason: whenShort.displayText);
      }
      expect(whenShort.why, isNotNull);

      // A question about the running period gets just that period.
      final dasha = r.answer('What does my current dasha mean?', sheet, detailed: false);
      expect(dasha.text, contains('[dasha.1]'));
      expect(dasha.text, contains('mahadasha'));

      // Lifespan stays complete when short: span, periods, care and caveat.
      final life = r.answer('When will I die?', sheet, detailed: false);
      expect(life.text, contains('[longevity.span]'));
      expect(life.text, contains('[maraka.1]'));
      expect(life.text, contains('not a medical fact'));
      expect(Safety.violations(life.displayText), isEmpty);

      for (final q in [
        'Explain my career in detail',
        'करियर विस्तार से बताइए',
        'கல்வி பற்றி விரிவாக சொல்',
        'tell me more',
      ]) {
        expect(asksForDetail(q), isTrue, reason: q);
      }
      for (final q in ['How is my career?', 'क्या मेरा सपना पूरा होगा?', 'When will I get married?']) {
        expect(asksForDetail(q), isFalse, reason: q);
      }
      expect(buildGroundedPrompt(sheet, 'How is my career?'), contains('ANSWER LENGTH: short'));
      expect(buildGroundedPrompt(sheet, 'How is my career?', detailed: true), contains('ANSWER LENGTH: detailed'));
      expect(buildGroundedPrompt(sheet, 'How is my career?'), isNot(contains('FOCUS FACTS')));
      final focus = citedIds(short.text);
      expect(focus, isNotEmpty);
      expect(focus.toSet().length, focus.length);
      expect(
        buildGroundedPrompt(sheet, 'How is my career?', focus: focus),
        contains('FOCUS FACTS: ${focus.map((id) => '[$id]').join(' ')}'),
      );

      // "When" answers cite the period facts, which the model then sees.
      final when = r.answer('When will my career grow?', sheet, detailed: false);
      final periods = when.focusIds.where((id) => id.startsWith('period.')).toList();
      expect(periods, isNotEmpty, reason: when.text);
      for (final id in periods) {
        expect(sheet.byId(id), isNotNull, reason: id);
      }
      expect(buildGroundedPrompt(sheet, 'How is my career?', focus: focus), isNot(contains('[period.')));
      expect(
        buildGroundedPrompt(sheet, 'When will my career grow?', focus: when.focusIds),
        contains('- [${periods.first}] Antardasha: '),
      );
      // A detailed answer's focus is its first supporting facts.
      expect(r.answer('How is my career?', sheet).focusIds, isNotEmpty);
    });

    test('lifespan without a birth time or in Western mode says what is missing', () {
      final p = Profile(id: 'p2', name: 'Ravi', birthDate: DateTime(1985, 3, 2));
      final noTime = RuleBasedAnswerer().answer(
        'How long will I live?',
        FactSheet.build(p, const CalcSettings(), now: _now)!,
      );
      expect(noTime.text, contains('cannot be decided without a birth time'));
      expect(noTime.improveWith, isNotEmpty);
      final western = RuleBasedAnswerer().answer(
        'How long will I live?',
        FactSheet.build(fullProfile(), const CalcSettings(system: AstroSystem.western), now: _now)!,
      );
      expect(western.text, contains('Switch to Vedic'));
    });

    test('teen mode blocks marriage and health predictions only', () {
      expect(RuleBasedAnswerer.safetyGate('When will I get married?', teen: true), isNotNull);
      expect(RuleBasedAnswerer.safetyGate('How is my health?', teen: true), isNotNull);
      expect(RuleBasedAnswerer.safetyGate('How are my studies?', teen: true), isNull);
      expect(RuleBasedAnswerer.safetyGate('When will I get married?', teen: false), isNull);
    });

    test('output guard catches selling, guarantees and invented facts', () {
      final sheet = FactSheet.build(fullProfile(), const CalcSettings(), now: _now)!;
      expect(guardOutput('Saturn is in your 10th [planet.saturn]. This may or may not apply.', sheet), isNull);
      expect(guardOutput('You should buy a blue sapphire.', sheet), isNotNull);
      expect(guardOutput('Success is guaranteed.', sheet), isNotNull);
      expect(guardOutput('Pluto rules you [planet.pluto_x].', sheet), isNotNull);
      expect(guardOutput('You will die young.', sheet), isNotNull);
    });
  });

  group('Intent detection', () {
    test('English and Hinglish', () {
      expect(detectIntent('meri shaadi kab hogi').intent, Intent.relationships);
      expect(detectIntent('meri shaadi kab hogi').asksTiming, isTrue);
      expect(detectIntent('Will I get a promotion at my job?').intent, Intent.career);
      expect(detectIntent('videsh jaane ka yog hai?').intent, Intent.travel);
      expect(detectIntent('What is my nature?').intent, Intent.personality);
      expect(detectIntent('hello').intent, Intent.general);
    });
  });

  group('FactSheet and answers', () {
    test('full profile has houses, dashas and grounded facts', () {
      final sheet = FactSheet.build(fullProfile(), const CalcSettings(), now: _now)!;
      expect(sheet.hasHouses, isTrue);
      expect(sheet.byId('ascendant'), isNotNull);
      expect(sheet.byId('planet.saturn'), isNotNull);
      expect(sheet.running.length, 3);
      expect(sheet.byId('dasha.1'), isNotNull);
      expect(sheet.byId('sadesati'), isNotNull);
      expect(sheet.toPromptText(), contains('[planet.moon]'));
    });

    test('date-only profile says what is missing', () {
      final p = Profile(id: 'p2', name: 'Ravi', birthDate: DateTime(1985, 3, 2));
      final sheet = FactSheet.build(p, const CalcSettings(), now: _now)!;
      expect(sheet.hasHouses, isFalse);
      expect(sheet.byId('missing.time'), isNotNull);
      final a = RuleBasedAnswerer().answer('How is my career?', sheet);
      expect(a.improveWith, isNotEmpty);
      expect(a.factors, isNotEmpty);
    });

    test('answers are grounded, deterministic and free of forbidden phrases', () {
      final sheet = FactSheet.build(fullProfile(), const CalcSettings(), now: _now)!;
      final answerer = RuleBasedAnswerer();
      for (final q in [
        'How is my career?',
        'When will I get married?',
        'Will I earn money?',
        'How is my health?',
        'Should I study abroad?',
        'What is my personality?',
        'When can I buy a house?',
      ]) {
        final a = answerer.answer(q, sheet);
        expect(a.factors, isNotEmpty, reason: q);
        expect(Safety.violations('${a.text} ${a.factors.map((f) => f.explanation).join(' ')}'), isEmpty, reason: q);
        expect(answerer.answer(q, sheet).text, a.text);
      }
      expect(answerer.answer('How is my health?', sheet).notes, contains(Safety.professionalMedical));
    });

    test('western system works too', () {
      final sheet = FactSheet.build(fullProfile(), const CalcSettings(system: AstroSystem.western), now: _now)!;
      final a = RuleBasedAnswerer().answer('Tell me about my career', sheet);
      expect(a.factors, isNotEmpty);
      expect(sheet.running, isEmpty);
    });

    test('explanations exist for every planet placement', () {
      final sheet = FactSheet.build(fullProfile(), const CalcSettings(), now: _now)!;
      final service = ExplainService();
      for (final p in sheet.chart.planets.values) {
        final e = service.explain(PlanetPlacementTopic(p, vedic: true));
        expect(e.paragraphs.join(), isNotEmpty);
        expect(Safety.violations(e.body), isEmpty);
      }
      for (final y in sheet.yogas) {
        expect(service.explain(YogaTopic(y)).title, y.name);
      }
      expect(service.explain(DashaTopic(sheet.running[1], chart: sheet.chart)).paragraphs.length, greaterThan(1));
    });
  });

  group('AskEngine', () {
    test('without a model returns the rule-based answer', () async {
      final sheet = FactSheet.build(fullProfile(), const CalcSettings(), now: _now)!;
      final updates = await AskEngine(fallback: RuleBasedAnswerer()).ask('How is my career?', sheet).toList();
      expect(updates.single.isDone, isTrue);
      expect(updates.single.answer!.fromModel, isFalse);
    });

    test('unsafe model output is replaced by the rule-based answer', () async {
      final sheet = FactSheet.build(fullProfile(), const CalcSettings(), now: _now)!;
      final updates = await AskEngine(
        fallback: RuleBasedAnswerer(),
        llm: _FakeLlm(['Buy ', 'a gem now.']),
      ).ask('How is my career?', sheet).toList();
      expect(updates.last.replacedModelOutput, isTrue);
      expect(updates.last.answer!.fromModel, isFalse);
    });

    test('good model output is kept with factors attached', () async {
      final sheet = FactSheet.build(fullProfile(), const CalcSettings(), now: _now)!;
      final said = RuleBasedAnswerer().answer('What is my nature?', sheet, detailed: false).keyPoints!;
      final updates = await AskEngine(
        fallback: RuleBasedAnswerer(),
        llm: _FakeLlm(['Here is what I see. ', said]),
      ).ask('What is my nature?', sheet).toList();
      expect(updates.last.answer!.fromModel, isTrue);
      expect(updates.last.answer!.factors, isNotEmpty);
    });

    test('full readings, dates and lifespan come from the calculation, not the model', () async {
      final sheet = FactSheet.build(fullProfile(), const CalcSettings(), now: _now)!;
      final engine = AskEngine(fallback: RuleBasedAnswerer(), llm: _FakeLlm(['Model text [planet.moon].']));
      for (final (q, detailed) in [
        ('How is my career?', true),
        ('When will I get married?', false),
        ('Which dasha am I running?', false),
        ('How long will I live?', false),
      ]) {
        final updates = await engine.ask(q, sheet, detailed: detailed).toList();
        expect(updates.single.answer!.fromModel, isFalse, reason: q);
        expect(updates.single.answer!.text, isNot(contains('Model text')), reason: q);
      }
      // A short answer goes to the model, but text that leaves out the
      // calculated key points is replaced by the calculation.
      final short = await engine.ask('How is my career?', sheet).toList();
      expect(short.length, greaterThan(1));
      expect(short.last.replacedModelOutput, isTrue);
    });

    test('model text that changes the life area, verdict or year is replaced', () async {
      final sheet = FactSheet.build(fullProfile(), const CalcSettings(), now: _now)!;
      final rules = RuleBasedAnswerer();
      for (final q in ['How is my career?', 'How is my married life?', 'What is my nature?', 'Will I have money?']) {
        final rule = rules.answer(q, sheet, detailed: false);
        // The engine's own wording is always accepted.
        expect(rules.contradictions(rule.text, rule), isEmpty, reason: q);
        final kept = await AskEngine(fallback: rules, llm: _FakeLlm([rule.text])).ask(q, sheet).toList();
        expect(kept.last.answer!.fromModel, isTrue, reason: q);
      }
      final rule = rules.answer('How is my career?', sheet, detailed: false);
      final swaps = [
        rule.text.contains('looks favourable')
            ? rule.text.replaceFirst('looks favourable', 'may need more effort')
            : '${rule.text} It looks favourable.',
        '${rule.text} It is linked with expenses, foreign lands, rest, retreat, spirituality and letting go.',
        '${rule.text} Things change in 2091.',
        // A key point left out (here the running period) is not accepted.
        rule.text.split('. ').first,
        'Your career looks good overall.',
      ];
      for (final wrong in swaps) {
        if (rule.text.contains('expenses, foreign lands') && wrong.contains('expenses, foreign lands')) continue;
        final updates = await AskEngine(
          fallback: rules,
          llm: _FakeLlm([wrong]),
        ).ask('How is my career?', sheet).toList();
        expect(updates.last.replacedModelOutput, isTrue, reason: wrong);
      }
    });
  });

  test('AiMemory stores, trims and clears per profile', () async {
    final dir = await Directory.systemTemp.createTemp('ai_mem');
    Hive.init(dir.path);
    final box = await Hive.openBox<String>('ai_memory_test');
    final memory = AiMemory.withBox(box);
    await memory.add(
      'p1',
      MemoryEntry(
        question: 'q',
        answer: const AiAnswer(text: 'a'),
        at: DateTime(2026),
      ),
    );
    await memory.setLifeFacts('p1', ['I teach']);
    expect(memory.history('p1').single.question, 'q');
    expect(memory.lifeFacts('p1'), ['I teach']);
    expect(memory.wifiOnly, isTrue);
    await memory.clearAll();
    expect(memory.history('p1'), isEmpty);
    await box.close();
  });
}

class _FakeLlm implements LocalLlm {
  _FakeLlm(this.pieces);
  final List<String> pieces;

  @override
  bool get isReady => true;
  @override
  Future<void> load(String modelPath) async {}
  @override
  Stream<String> generate({required String system, required String user, int maxTokens = 0}) =>
      Stream.fromIterable(pieces);
  @override
  void cancel() {}
  @override
  Future<void> dispose() async {}
}
