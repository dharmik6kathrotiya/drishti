import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/astro/constants.dart';
import '../../../core/astro/vedic/panchang.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/common.dart';
import '../../../ui/widgets/option_picker.dart';
import '../../../ui/i18n.dart';
import '../../../ui/widgets/tool_info_button.dart';

enum _PhaseKind { inhale, hold, exhale, holdEmpty, chant }

class _Phase {
  const _Phase(this.kind, this.seconds, this.label);
  final _PhaseKind kind;
  final int seconds;
  final String Function(AppLocalizations) label;
}

enum BreathPattern { box, fourSevenEight, nadi, om }

List<_Phase> _phasesFor(BreathPattern p) => switch (p) {
  BreathPattern.box => [
    _Phase(_PhaseKind.inhale, 4, (l) => l.wellnessBreathIn),
    _Phase(_PhaseKind.hold, 4, (l) => l.wellnessHold),
    _Phase(_PhaseKind.exhale, 4, (l) => l.wellnessBreathOut),
    _Phase(_PhaseKind.holdEmpty, 4, (l) => l.wellnessHold),
  ],
  BreathPattern.fourSevenEight => [
    _Phase(_PhaseKind.inhale, 4, (l) => l.wellnessBreathIn),
    _Phase(_PhaseKind.hold, 7, (l) => l.wellnessHold),
    _Phase(_PhaseKind.exhale, 8, (l) => l.wellnessBreathOut),
  ],
  BreathPattern.nadi => [
    _Phase(_PhaseKind.inhale, 4, (l) => l.wellnessInLeft),
    _Phase(_PhaseKind.exhale, 6, (l) => l.wellnessOutRight),
    _Phase(_PhaseKind.inhale, 4, (l) => l.wellnessInRight),
    _Phase(_PhaseKind.exhale, 6, (l) => l.wellnessOutLeft),
  ],
  BreathPattern.om => [
    _Phase(_PhaseKind.inhale, 4, (l) => l.wellnessBreathIn),
    _Phase(_PhaseKind.chant, 8, (l) => l.wellnessChant),
  ],
};

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> with SingleTickerProviderStateMixin {
  BreathPattern _pattern = BreathPattern.box;
  int _minutes = 5;
  bool _running = false;
  bool _done = false;
  int _phaseIndex = 0;
  int _remainingSeconds = 0;
  Timer? _sessionTimer;
  late final AnimationController _anim = AnimationController(vsync: this);

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  void _start() {
    setState(() {
      _running = true;
      _done = false;
      _phaseIndex = 0;
      _remainingSeconds = _minutes * 60;
    });
    _runPhase();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remainingSeconds--);
      if (_remainingSeconds <= 0) _stop(completed: true);
    });
  }

  void _stop({bool completed = false}) {
    _sessionTimer?.cancel();
    _anim.stop();
    setState(() {
      _running = false;
      _done = completed;
    });
  }

  void _runPhase() {
    if (!_running) return;
    final phases = _phasesFor(_pattern);
    final phase = phases[_phaseIndex % phases.length];
    _anim.duration = Duration(seconds: phase.seconds);
    final future = switch (phase.kind) {
      _PhaseKind.inhale => _anim.forward(from: 0),
      _PhaseKind.exhale || _PhaseKind.chant => _anim.reverse(from: 1),
      _PhaseKind.hold || _PhaseKind.holdEmpty => Future<void>.delayed(Duration(seconds: phase.seconds)),
    };
    future.whenComplete(() {
      if (!mounted || !_running) return;
      setState(() => _phaseIndex++);
      _runPhase();
    });
  }

  String _patternLabel(BreathPattern p, AppLocalizations l) => switch (p) {
    BreathPattern.box => l.wellnessPatternBox,
    BreathPattern.fourSevenEight => l.wellnessPattern478,
    BreathPattern.nadi => l.wellnessPatternNadi,
    BreathPattern.om => l.wellnessPatternOm,
  };

  String _patternInfo(BreathPattern p, AppLocalizations l) => switch (p) {
    BreathPattern.box => l.wellnessPatternBoxInfo,
    BreathPattern.fourSevenEight => l.wellnessPattern478Info,
    BreathPattern.nadi => l.wellnessPatternNadiInfo,
    BreathPattern.om => l.wellnessPatternOmInfo,
  };

  String _dayTheme(Planet p, AppLocalizations l) => switch (p) {
    Planet.sun => l.wellnessThemeSun,
    Planet.moon => l.wellnessThemeMoon,
    Planet.mars => l.wellnessThemeMars,
    Planet.mercury => l.wellnessThemeMercury,
    Planet.jupiter => l.wellnessThemeJupiter,
    Planet.venus => l.wellnessThemeVenus,
    _ => l.wellnessThemeSaturn,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final phases = _phasesFor(_pattern);
    final phase = phases[_phaseIndex % phases.length];
    final dayLord = varaLords[DateTime.now().weekday % 7];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.wellnessMeditationTitle),
        actions: const [ToolInfoButton(toolId: 'meditation')],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!_running) ...[
            SourceNote(l.wellnessDayTheme(context.names.planet(dayLord), _dayTheme(dayLord, l))),
            const SizedBox(height: 12),
            for (final p in BreathPattern.values)
              OptionCard<BreathPattern>(
                option: PickOption(
                  value: p,
                  label: _patternLabel(p, l),
                  description: _patternInfo(p, l),
                  recommended: p == BreathPattern.box,
                ),
                selected: _pattern == p,
                onTap: () => setState(() => _pattern = p),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final m in const [1, 3, 5, 10, 15, 20])
                  ChoiceChip(
                    label: Text(l.wellnessMinutes(m)),
                    selected: _minutes == m,
                    onSelected: (_) => setState(() => _minutes = m),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            height: 300,
            child: Center(
              child: AnimatedBuilder(
                animation: _anim,
                builder: (context, _) {
                  final t = _running ? _anim.value : 0.35;
                  final d = 120 + 150 * t;
                  return Container(
                    width: d,
                    height: d,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.55),
                          theme.colorScheme.primary.withValues(alpha: 0.12),
                        ],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _running ? phase.label(l) : (_done ? '🙏' : _patternLabel(_pattern, l)),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_running)
            Text(
              '${_remainingSeconds ~/ 60}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
          if (_done) Text(l.wellnessSessionDone, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: Icon(_running ? Icons.stop : Icons.play_arrow),
            label: Text(_running ? l.wellnessStop : l.wellnessStart),
            onPressed: _running ? () => _stop() : _start,
          ),
          const SizedBox(height: 16),
          SourceNote(l.wellnessHealthNote),
        ],
      ),
    );
  }
}
