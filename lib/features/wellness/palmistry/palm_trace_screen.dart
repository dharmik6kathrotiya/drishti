import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/content/palmistry/palm_trace.dart';
import '../../../core/content/palmistry/palmistry_content.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/common.dart';
import 'palm_auto.dart';

/// Guided tracing on the user's own palm photo: three reference taps, then
/// each main line traced by finger over a dotted guide. Returns the
/// suggested option per question id ('heart', 'head', 'life', 'fate'),
/// which the reading then shows for the user to confirm or change.
class PalmTraceScreen extends StatefulWidget {
  const PalmTraceScreen({super.key, required this.photoPath});
  final String photoPath;

  @override
  State<PalmTraceScreen> createState() => _PalmTraceScreenState();
}

class _PalmTraceScreenState extends State<PalmTraceScreen> {
  static const _lines = ['heart', 'head', 'life', 'fate'];

  double? _aspect; // image width / height
  final _taps = <Offset>[]; // index base, little base, wrist
  final _traced = <String, List<List<Offset>>>{for (final l in _lines) l: []};
  final _skipped = <String>{};
  int _line = 0;

  /// Searching the photo for the hand and lines.
  bool _detecting = true;

  /// The hand was found automatically (the three points are set).
  bool _handFound = false;

  /// Lines drawn by the detector and not changed by the user.
  final _auto = <String>{};

  @override
  void initState() {
    super.initState();
    File(widget.photoPath).readAsBytes().then(ui.instantiateImageCodec).then((c) => c.getNextFrame()).then((f) {
      if (mounted) setState(() => _aspect = f.image.width / f.image.height);
    });
    PalmAuto.run(widget.photoPath).then((found) {
      if (!mounted) return;
      setState(() {
        _detecting = false;
        if (found == null) return;
        _handFound = true;
        _taps
          ..clear()
          ..addAll([found.frame.indexBase, found.frame.littleBase, found.frame.wrist]);
        for (final e in found.lines.entries) {
          _traced[e.key] = [e.value];
          _auto.add(e.key);
        }
      });
      if (found == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).palmHandNotFound)));
      }
    });
  }

  bool get _calibrating => _taps.length < 3;
  String get _current => _lines[_line];

  PalmFrame get _frame => PalmFrame(indexBase: _taps[0], littleBase: _taps[1], wrist: _taps[2]);

  /// Points are kept in image units: y from 0 to 1, x from 0 to the aspect
  /// ratio, so distances are the same in both directions.
  Offset _toImage(Offset local, Size box) => Offset(local.dx / box.width * _aspect!, local.dy / box.height);

  void _finish() {
    final f = _frame;
    TracedLine? line(String id) =>
        _skipped.contains(id) || _traced[id]!.every((s) => s.length < 2) ? null : TracedLine(_traced[id]!);
    final life = line('life');
    final out = <String, int?>{
      'heart': line('heart') == null ? null : PalmMeasure.heart(f, line('heart')!).option,
      'head': line('head') == null ? null : PalmMeasure.head(f, line('head')!, life: life).option,
      'life': life == null ? null : PalmMeasure.life(f, life).option,
      'fate': PalmMeasure.fate(f, line('fate'), life: life).option,
    };
    Navigator.of(context).pop(out);
  }

  void _next() {
    if (_line < _lines.length - 1) {
      setState(() => _line++);
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final texts = palmistryFor(Localizations.localeOf(context).languageCode);
    final title = {for (final q in texts.questions) q.id: q.title};
    final name = title[_current] ?? _current;
    final instruction = _detecting
        ? l.palmDetecting
        : _calibrating
        ? [l.palmTapIndex, l.palmTapLittle, l.palmTapWrist][_taps.length]
        : _auto.contains(_current)
        ? l.palmAutoLine(name)
        : (_handFound ? l.palmAutoMissing(name) : l.palmTraceLine(name));

    // Room for four lines of instructions in every step and language.
    final instructionStyle = theme.textTheme.titleMedium!;
    final instructionHeight =
        MediaQuery.textScalerOf(context).scale(instructionStyle.fontSize!) * (instructionStyle.height ?? 1.3) * 4 + 20;

    return Scaffold(
      appBar: AppBar(title: Text(l.palmTraceTitle)),
      body: _aspect == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Fixed heights above and below the photo, so it never moves
                // between steps: a tap or stroke lands where the user aimed.
                SizedBox(
                  height: instructionHeight,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(instruction, style: instructionStyle),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _aspect!,
                      child: LayoutBuilder(
                        builder: (context, box) {
                          final size = box.biggest;
                          return GestureDetector(
                            onTapUp: _calibrating && !_detecting
                                ? (d) => setState(() => _taps.add(_toImage(d.localPosition, size)))
                                : null,
                            // Drawing over a line found automatically replaces it.
                            onPanStart: _calibrating || _detecting
                                ? null
                                : (d) => setState(() {
                                    if (_auto.remove(_current)) _traced[_current]!.clear();
                                    _traced[_current]!.add([_toImage(d.localPosition, size)]);
                                  }),
                            onPanUpdate: _calibrating || _detecting
                                ? null
                                : (d) => setState(() => _traced[_current]!.last.add(_toImage(d.localPosition, size))),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(File(widget.photoPath), fit: BoxFit.fill),
                                CustomPaint(
                                  painter: _TracePainter(
                                    aspect: _aspect!,
                                    taps: _taps,
                                    frame: _calibrating ? null : _frame,
                                    current: _calibrating ? null : _current,
                                    traced: _traced,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SourceNote(l.palmTraceNote),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            IconButton.outlined(
                              tooltip: l.palmUndo,
                              icon: const Icon(Icons.undo),
                              onPressed: () => setState(() {
                                if (!_calibrating && _traced[_current]!.isNotEmpty) {
                                  _traced[_current]!.removeLast();
                                  _auto.remove(_current);
                                } else if (!_calibrating && _line > 0) {
                                  _line--;
                                } else if (_taps.isNotEmpty) {
                                  _taps.removeLast();
                                  _handFound = false;
                                }
                              }),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: TextButton(
                                onPressed: _calibrating
                                    ? null
                                    : () {
                                        _skipped.add(_current);
                                        _traced[_current]!.clear();
                                        _next();
                                      },
                                child: Text(l.palmCantSee, maxLines: 2, textAlign: TextAlign.center),
                              ),
                            ),
                            FilledButton(
                              onPressed: !_calibrating && _traced[_current]!.any((s) => s.length > 1)
                                  ? () {
                                      _skipped.remove(_current);
                                      _next();
                                    }
                                  : null,
                              child: Text(_line == _lines.length - 1 ? l.palmUseTracing : l.palmNext),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _TracePainter extends CustomPainter {
  _TracePainter({
    required this.aspect,
    required this.taps,
    required this.frame,
    required this.current,
    required this.traced,
    required this.color,
  });

  final double aspect;
  final List<Offset> taps;
  final PalmFrame? frame;
  final String? current;
  final Map<String, List<List<Offset>>> traced;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Offset px(Offset p) => Offset(p.dx / aspect * size.width, p.dy * size.height);
    final dot = Paint()..color = color;
    final ring = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final t in taps) {
      canvas.drawCircle(px(t), 7, dot);
      canvas.drawCircle(px(t), 7, ring);
    }
    final f = frame;
    if (f == null) return;

    // Dotted guide for the current line: where it usually runs.
    final guide = PalmFrame.guides[current]!;
    final guidePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i < guide.length; i++) {
      final a = px(f.toImage(guide[i - 1])), b = px(f.toImage(guide[i]));
      final steps = ((b - a).distance / 10).ceil();
      for (var k = 0; k < steps; k += 2) {
        canvas.drawLine(Offset.lerp(a, b, k / steps)!, Offset.lerp(a, b, (k + 1) / steps)!, guidePaint);
      }
    }

    // Lines traced so far; the current one is drawn brighter.
    for (final e in traced.entries) {
      final paint = Paint()
        ..color = e.key == current ? color : color.withValues(alpha: 0.45)
        ..strokeWidth = e.key == current ? 4 : 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      for (final s in e.value) {
        if (s.length < 2) continue;
        final path = Path()..moveTo(px(s.first).dx, px(s.first).dy);
        for (final p in s.skip(1)) {
          path.lineTo(px(p).dx, px(p).dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TracePainter old) => true;
}
