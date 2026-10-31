import 'package:flutter/material.dart';

import '../../core/astro/numerology.dart';
import '../../core/astro/numerology_texts.dart';
import '../../core/i18n/engine_texts.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets/common.dart';

/// Ids whose numbers are always reduced to a single digit.
const _alwaysReduced = {'mulank', 'bhagyank', 'chaldeanName'};

String _partLabel(AppLocalizations l, WorkingPart p) => switch (p) {
  WorkingPart.month => l.numeroPartMonth,
  WorkingPart.day => l.numeroPartDay,
  WorkingPart.year => l.numeroPartYear,
  WorkingPart.currentYear => l.numeroPartCurrentYear,
  WorkingPart.sum => l.numeroPartSum,
  WorkingPart.dateDigits => l.numeroPartDateDigits,
  WorkingPart.letters => l.numeroPartLetters,
  WorkingPart.vowels => l.numeroPartVowels,
  WorkingPart.consonants => l.numeroPartConsonants,
};

TextStyle? _dim(ThemeData theme) =>
    theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7));

/// Circle showing a number, as on the number cards.
class NumberBadge extends StatelessWidget {
  const NumberBadge(this.value, {super.key, this.radius = 26});
  final int value;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
      child: Text(
        '$value',
        style: (radius >= 24 ? theme.textTheme.titleLarge : theme.textTheme.titleMedium)?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// "Label: working" line, e.g. "Year: 1995 → 1+9+9+5 = 24 → 2+4 = 6".
class StepLine extends StatelessWidget {
  const StepLine(this.label, this.text, {super.key});
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withValues(alpha: 0.75)),
            ),
            TextSpan(text: text),
          ],
        ),
        style: theme.textTheme.bodyMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
      ),
    );
  }
}

class _SubHeading extends StatelessWidget {
  const _SubHeading(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
          ),
        ],
      ),
    );
  }
}

/// "Label — text" paragraph with a bold label.
class _Labeled extends StatelessWidget {
  const _Labeled(this.label, this.text);
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

/// Number card: value and one-line meaning; tap to expand the working
/// ("How it is calculated") and the fuller meaning ("What it means").
class NumberCard extends StatefulWidget {
  const NumberCard({super.key, required this.number, required this.detail, required this.et, required this.nt});
  final NumerologyNumber number;
  final NumberDetail? detail;
  final EngineTexts et;
  final NumerologyTexts nt;

  @override
  State<NumberCard> createState() => _NumberCardState();
}

class _NumberCardState extends State<NumberCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final n = widget.number;
    final et = widget.et;
    return SectionCard(
      onTap: () => setState(() => _open = !_open),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NumberBadge(n.value),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.compound == null ? et.numerologyTitle(n.id) : '${et.numerologyTitle(n.id)} (${n.compound})',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(et.numerologyMeaning(n.value)),
                  ],
                ),
              ),
              Icon(_open ? Icons.expand_less : Icons.expand_more, color: theme.colorScheme.primary),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: _open ? _body(context) : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final n = widget.number;
    final d = widget.detail;
    final nt = widget.nt;
    final v = n.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (d != null) ...[
          _SubHeading(Icons.calculate_outlined, l.numeroHowCalculated),
          if (d.letters.isNotEmpty) ...[
            Text(
              d.system == NumerologySystem.chaldean ? l.numeroLetterTableCh : l.numeroLetterTablePy,
              style: _dim(theme),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final lv in d.letters)
                  _LetterBox(
                    lv,
                    counted: switch (n.id) {
                      'soulUrge' => lv.isVowel,
                      'personality' => !lv.isVowel,
                      _ => true,
                    },
                  ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          for (final line in d.lines) StepLine(_partLabel(l, line.part), line.working.format()),
          if (d.lines.any((x) => x.working.masterKept)) _Bullet(l.numeroMasterKept(d.value)),
          if (_alwaysReduced.contains(n.id)) _Bullet(l.numeroAlwaysReduced),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l.numeroResult(d.value),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
        _SubHeading(Icons.lightbulb_outline, l.numeroWhatItMeans),
        _Labeled(l.numeroRepresents, nt.typeWhy(n.id)),
        if (v >= 1) ...[
          _Labeled(l.numeroStrengths, nt.strengths(v)),
          _Labeled(l.numeroChallenges, nt.challenges(v)),
          _Labeled(l.numeroGuidance, nt.guidance(v)),
          const SizedBox(height: 6),
          Text(l.numeroPlanetLine(widget.et.names.planet(Numerology.planetOf(v))), style: _dim(theme)),
        ],
      ],
    );
  }
}

class _LetterBox extends StatelessWidget {
  const _LetterBox(this.lv, {required this.counted});
  final LetterValue lv;
  final bool counted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.colorScheme;
    return Opacity(
      opacity: counted ? 1 : 0.4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: counted ? c.primary.withValues(alpha: 0.12) : null,
          border: Border.all(color: c.outline.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(lv.letter, style: theme.textTheme.labelLarge),
            Text('${lv.value}', style: theme.textTheme.labelSmall?.copyWith(color: c.primary)),
          ],
        ),
      ),
    );
  }
}

/// Small coloured label.
class _Tag extends StatelessWidget {
  const _Tag(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color)),
    );
  }
}

/// Mulank-Bhagyank planetary pairing.
class PairCard extends StatelessWidget {
  const PairCard({super.key, required this.pair, required this.et, required this.nt});
  final NumberPair pair;
  final EngineTexts et;
  final NumerologyTexts nt;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Theme.of(context).colorScheme;
    final names = et.names;
    final pa = names.planet(pair.firstPlanet);
    final pb = names.planet(pair.secondPlanet);
    String view(int v) => v > 0
        ? l.numeroRelFriend
        : v < 0
        ? l.numeroRelEnemy
        : l.numeroRelNeutral;
    final (label, color) = switch (pair.relation) {
      PairRelation.same => (l.numeroPairSame, c.primary),
      PairRelation.friendly => (l.numeroPairFriendly, c.primary),
      PairRelation.neutral => (l.numeroPairNeutral, c.secondary),
      PairRelation.challenging => (l.numeroPairChallenging, c.tertiary),
    };
    return SectionCard(
      title: l.numeroPairTitle,
      icon: Icons.compare_arrows,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NumberBadge(pair.first, radius: 20),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Icon(Icons.add, size: 18)),
              NumberBadge(pair.second, radius: 20),
              const SizedBox(width: 12),
              Flexible(child: _Tag(label, color)),
            ],
          ),
          const SizedBox(height: 8),
          Text(l.numeroPairNumbers(pair.first, pa, pair.second, pb)),
          if (pair.relation != PairRelation.same) ...[
            const SizedBox(height: 4),
            _Bullet(l.numeroViewLine(pa, pb, view(pair.firstView))),
            _Bullet(l.numeroViewLine(pb, pa, view(pair.secondView))),
          ],
          const SizedBox(height: 6),
          Text(nt.pairRelation(pair.relation)),
          const SizedBox(height: 8),
          SourceNote(nt.pairIntro()),
          if (pair.firstPlanet.isNode || pair.secondPlanet.isNode) ...[
            const SizedBox(height: 6),
            SourceNote(nt.pairNodesNote()),
          ],
        ],
      ),
    );
  }
}

/// Lo Shu grid with repeated and missing numbers and complete planes.
class LoShuCard extends StatelessWidget {
  const LoShuCard({
    super.key,
    required this.grid,
    required this.addMulankBhagyank,
    required this.onToggle,
    required this.nt,
  });
  final LoShuGrid grid;
  final bool addMulankBhagyank;
  final ValueChanged<bool> onToggle;
  final NumerologyTexts nt;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final digits = grid.extra.isEmpty
        ? grid.dateDigits.join(', ')
        : '${grid.dateDigits.join(', ')} + ${grid.extra.join(', ')}';
    final planes = grid.completePlanes;
    return SectionCard(
      title: l.numeroLoShuTitle,
      icon: Icons.grid_3x3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: addMulankBhagyank,
            onChanged: onToggle,
            title: Text(l.numeroLoShuAddMB),
          ),
          Center(
            child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 240), child: LoShuGridView(grid)),
          ),
          const SizedBox(height: 8),
          Text(l.numeroLoShuDigits(digits), style: _dim(theme)),
          _SubHeading(Icons.repeat, l.numeroLoShuRepeated),
          if (grid.repeated.isEmpty) Text(l.numeroLoShuNoRepeated),
          for (final n in grid.repeated) _Bullet('${'$n' * grid.count(n)} — ${nt.loShuRepeated(n, grid.count(n))}'),
          _SubHeading(Icons.crop_square, l.numeroLoShuMissing),
          if (grid.missing.isEmpty) Text(l.numeroLoShuNoMissing),
          for (final n in grid.missing) _Bullet(nt.loShuMissing(n)),
          _SubHeading(Icons.linear_scale, l.numeroLoShuPlanes),
          if (planes.isEmpty) Text(l.numeroLoShuNoPlanes),
          for (final p in planes) _Labeled('${nt.planeName(p)} (${p.numbers.join('-')})', nt.planeMeaning(p)),
          const SizedBox(height: 10),
          SourceNote(nt.loShuIntro()),
          const SizedBox(height: 6),
          SourceNote(nt.loShuIndianNote()),
        ],
      ),
    );
  }
}

/// The 3×3 Lo Shu square (4-9-2 / 3-5-7 / 8-1-6). Present numbers are shown
/// as many times as they occur; missing ones are shown faintly.
class LoShuGridView extends StatelessWidget {
  const LoShuGridView(this.grid, {super.key});
  final LoShuGrid grid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.colorScheme;
    return Column(
      children: [
        for (final row in LoShuGrid.layout)
          Row(
            children: [
              for (final n in row)
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: grid.count(n) > 0 ? c.primary.withValues(alpha: 0.12) : null,
                        border: Border.all(color: c.outline.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(6),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: grid.count(n) > 0
                            ? Text(
                                '$n' * grid.count(n),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: c.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : Text(
                                '$n',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: c.onSurface.withValues(alpha: 0.18),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// Chaldean compound number (Cheiro's tradition).
class CompoundCard extends StatelessWidget {
  const CompoundCard({super.key, required this.total, required this.nt});
  final int total;
  final NumerologyTexts nt;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final compound = Numerology.compoundOf(total);
    var reducedTo = total;
    while (reducedTo > 52) {
      reducedTo = Numerology.digitSum(reducedTo);
    }
    return SectionCard(
      title: l.numeroCompoundTitle,
      icon: Icons.layers_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (total > 52) ...[Text(l.numeroCompoundReduced(total, reducedTo)), const SizedBox(height: 8)],
          if (compound != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NumberBadge(compound, radius: 22),
                const SizedBox(width: 12),
                Expanded(child: Text(nt.compound(compound))),
              ],
            )
          else
            Text(l.numeroCompoundNone),
          const SizedBox(height: 8),
          SourceNote(nt.compoundIntro()),
        ],
      ),
    );
  }
}

/// Personal year, month and day for today.
class PersonalCyclesCard extends StatelessWidget {
  const PersonalCyclesCard({super.key, required this.cycles, required this.today, required this.nt});
  final PersonalCycles cycles;
  final DateTime today;
  final NumerologyTexts nt;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    Widget cycle(String label, int value, List<Widget> steps, String intro) => Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NumberBadge(value, radius: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(nt.cycle(value)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...steps,
          const SizedBox(height: 4),
          SourceNote(intro),
        ],
      ),
    );

    return SectionCard(
      title: l.numeroPersonalTitle,
      icon: Icons.event_repeat,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.numeroPersonalFor(MaterialLocalizations.of(context).formatMediumDate(today)), style: _dim(theme)),
          cycle(l.numeroPersonalYear, cycles.year, [
            for (final line in cycles.yearLines) StepLine(_partLabel(l, line.part), line.working.format()),
          ], nt.cycleIntro('year')),
          cycle(l.numeroPersonalMonth, cycles.month, [
            StepLine(l.numeroPersonalMonth, cycles.monthWorking.format()),
          ], nt.cycleIntro('month')),
          cycle(l.numeroPersonalDay, cycles.day, [
            StepLine(l.numeroPersonalDay, cycles.dayWorking.format()),
          ], nt.cycleIntro('day')),
        ],
      ),
    );
  }
}

/// Collapsible note on the methods used and their limits.
class AboutMethodsCard extends StatefulWidget {
  const AboutMethodsCard({super.key, required this.nt});
  final NumerologyTexts nt;

  @override
  State<AboutMethodsCard> createState() => _AboutMethodsCardState();
}

class _AboutMethodsCardState extends State<AboutMethodsCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final nt = widget.nt;
    return SectionCard(
      title: l.numeroAboutTitle,
      icon: Icons.info_outline,
      trailing: Icon(_open ? Icons.expand_less : Icons.expand_more, color: theme.colorScheme.primary),
      onTap: () => setState(() => _open = !_open),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.topCenter,
        child: _open
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final id in const ['pythagorean', 'chaldean', 'indian', 'loshu'])
                    Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(nt.about(id))),
                  SourceNote(nt.about('honest')),
                ],
              )
            : SizedBox(
                width: double.infinity,
                child: Text(nt.about('honest'), maxLines: 2, overflow: TextOverflow.ellipsis, style: _dim(theme)),
              ),
      ),
    );
  }
}
