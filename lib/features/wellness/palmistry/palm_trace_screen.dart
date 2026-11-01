import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/content/palmistry/palm_trace.dart';
import '../../../core/content/palmistry/palmistry_content.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/common.dart';
import 'palm_auto.dart';

/// The lines on the user's own palm photo. When the hand is found, every
/// line found is shown at once for one check ("Looks right"), and any line
/// can be fixed by drawing it. Otherwise: three reference taps, then each
/// main line traced by finger over a dotted guide. Returns the suggested
/// option per question id ('heart', 'head', 'life', 'fate'), which the
/// reading then shows for the user to confirm or change.
class PalmTraceScreen extends StatefulWidget {
  const PalmTraceScreen({super.key, required this.photoPath, this.detect = PalmAuto.run});
  final String photoPath;

  /// Finds the hand and lines (replaceable in tests).
  final Future<PalmAutoResult?> Function(String path) detect;

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

  /// All lines are shown together for one check.
  bool _review = false;

  /// One line is being redrawn from the review.
  bool _fixing = false;

  /// The 21 hand points found, drawn as the hand's outline.
  List<Offset> _hand = const [];

  /// The photo with its creases made clearer, when switched on.
  bool _enhanced = false;
  Uint8List? _enhancedBytes;

  /// Two-finger zoom: the photo is scaled by [_zoom] and moved by [_pan]
  /// (in screen pixels); one finger draws.
  double _zoom = 1;
  Offset _pan = Offset.zero;
  double _zoomStart = 1;
  Offset _panStart = Offset.zero;
  Offset _focalStart = Offset.zero;

  /// The stroke being drawn; it becomes part of the line only after a few
  /// points, so starting a two-finger zoom never erases a line.
  List<Offset>? _stroke;
  bool _committed = false;

  /// Each line's colour, so they can be told apart in the review.
  static const lineColors = {
    'heart': Color(0xFFE53935),
    'head': Color(0xFF1E88E5),
    'life': Color(0xFF43A047),
    'fate': Color(0xFFFFB300),
  };

  @override
  void initState() {
    super.initState();
    File(widget.photoPath).readAsBytes().then(ui.instantiateImageCodec).then((c) => c.getNextFrame()).then((f) {
      if (mounted) setState(() => _aspect = f.image.width / f.image.height);
    });
    widget.detect(widget.photoPath).then((found) {
      if (!mounted) return;
      setState(() {
        _detecting = false;
        if (found == null) return;
        _handFound = true;
        _review = true;
        _hand = found.hand;
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
  /// ratio, so distances are the same in both directions. [local] is where
  /// the finger is on screen; the zoom is undone first.
  Offset _toImage(Offset local, Size box) {
    final p = (local - _pan) / _zoom;
    return Offset(p.dx / box.width * _aspect!, p.dy / box.height);
  }

  bool get _canDraw => !_calibrating && !_detecting && !_review;

  void _scaleStart(ScaleStartDetails d, Size box) {
    _zoomStart = _zoom;
    _panStart = _pan;
    _focalStart = d.localFocalPoint;
    _committed = false;
    _stroke = _canDraw && d.pointerCount == 1 ? [_toImage(d.localFocalPoint, box)] : null;
  }

  void _scaleUpdate(ScaleUpdateDetails d, Size box) {
    final stroke = _stroke;
    if (stroke != null && d.pointerCount == 1) {
      setState(() {
        stroke.add(_toImage(d.localFocalPoint, box));
        if (!_committed && stroke.length >= 4) {
          // A real stroke: drawing over a line found automatically replaces it.
          _committed = true;
          if (_auto.remove(_current)) _traced[_current]!.clear();
          _traced[_current]!.add(stroke);
        }
      });
      return;
    }
    if (stroke != null) {
      // A second finger: this is a zoom, not a stroke.
      setState(() {
        if (_committed) _traced[_current]!.remove(stroke);
        _stroke = null;
      });
    }
    final z = (_zoomStart * d.scale).clamp(1.0, 6.0);
    final pan = d.localFocalPoint - (_focalStart - _panStart) * (z / _zoomStart);
    setState(() {
      _zoom = z;
      // Keep the photo covering its box.
      _pan = Offset(pan.dx.clamp(box.width * (1 - z), 0.0), pan.dy.clamp(box.height * (1 - z), 0.0));
    });
  }

  Future<void> _toggleEnhanced() async {
    if (!_enhanced && _enhancedBytes == null) {
      final bytes = await enhancedPalmPhoto(widget.photoPath);
      if (!mounted || bytes == null) return;
      _enhancedBytes = bytes;
    }
    setState(() => _enhanced = !_enhanced);
  }

  void _finish() {
    final f = _frame;
    TracedLine? line(String id) =>
        _skipped.contains(id) || _traced[id]!.every((s) => s.length < 2) ? null : TracedLine(_traced[id]!);
    final life = line('life');
    final out = <String, int?>{
      'heart': line('heart') == null ? null : PalmMeasure.heart(f, line('heart')!).option,
      'head': line('head') == null ? null : PalmMeasure.head(f, line('head')!, life: life).option,
      'life': life == null ? null : PalmMeasure.life(f, life).option,
      // A fate line the detector simply missed is not reported as absent;
      // only the user's own "I can't see this line" says that.
      'fate': line('fate') == null && !_skipped.contains('fate')
          ? null
          : PalmMeasure.fate(f, line('fate'), life: life).option,
    };
    Navigator.of(context).pop(out);
  }

  void _next() {
    if (_fixing) {
      setState(() {
        _fixing = false;
        _review = true;
      });
    } else if (_line < _lines.length - 1) {
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
    final found = [
      for (final id in _lines)
        if (_traced[id]!.any((s) => s.length > 1)) id,
    ];
    final missing = [
      for (final id in _lines)
        if (!found.contains(id)) title[id] ?? id,
    ];
    final hint = _detecting ? '' : '\n${l.palmZoomHint}';
    final instruction = _detecting
        ? l.palmDetecting
        : _review
        ? [l.palmReviewFound, if (missing.isNotEmpty) l.palmReviewMissing(missing.join(', '))].join('\n')
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
      appBar: AppBar(
        title: Text(l.palmTraceTitle),
        actions: [
          IconButton(
            tooltip: l.palmEnhance,
            isSelected: _enhanced,
            icon: const Icon(Icons.contrast),
            onPressed: _toggleEnhanced,
          ),
        ],
      ),
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
                    child: Text.rich(
                      TextSpan(
                        text: instruction,
                        style: instructionStyle,
                        children: [TextSpan(text: hint, style: theme.textTheme.bodySmall)],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _aspect!,
                      child: LayoutBuilder(
                        builder: (context, box) {
                          final size = box.biggest;
                          return ClipRect(
                            child: GestureDetector(
                              onTapUp: _calibrating && !_detecting
                                  ? (d) => setState(() => _taps.add(_toImage(d.localPosition, size)))
                                  : null,
                              onScaleStart: _detecting ? null : (d) => _scaleStart(d, size),
                              onScaleUpdate: _detecting ? null : (d) => _scaleUpdate(d, size),
                              onScaleEnd: (_) => _stroke = null,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Transform.translate(
                                    offset: _pan,
                                    child: Transform.scale(
                                      scale: _zoom,
                                      alignment: Alignment.topLeft,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          if (_enhanced && _enhancedBytes != null)
                                            Image.memory(_enhancedBytes!, fit: BoxFit.fill, gaplessPlayback: true)
                                          else
                                            Image.file(File(widget.photoPath), fit: BoxFit.fill),
                                          CustomPaint(
                                            painter: _TracePainter(
                                              aspect: _aspect!,
                                              taps: _taps,
                                              frame: _calibrating ? null : _frame,
                                              current: _calibrating || _review ? null : _current,
                                              traced: _traced,
                                              hand: _review ? _hand : const [],
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (_zoom > 1)
                                    Positioned(
                                      right: 6,
                                      top: 6,
                                      child: IconButton.filledTonal(
                                        tooltip: l.palmResetZoom,
                                        icon: const Icon(Icons.zoom_out_map),
                                        onPressed: () => setState(() {
                                          _zoom = 1;
                                          _pan = Offset.zero;
                                        }),
                                      ),
                                    ),
                                ],
                              ),
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
                        if (_review) ...[
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              for (final id in _lines)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      found.contains(id) ? Icons.circle : Icons.circle_outlined,
                                      size: 14,
                                      color: lineColors[id],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(title[id] ?? id, style: theme.textTheme.bodySmall),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: PopupMenuButton<int>(
                                  tooltip: l.palmFixLine,
                                  onSelected: (i) => setState(() {
                                    _line = i;
                                    _review = false;
                                    _fixing = true;
                                  }),
                                  itemBuilder: (_) => [
                                    for (final (i, id) in _lines.indexed)
                                      PopupMenuItem(value: i, child: Text(title[id] ?? id)),
                                  ],
                                  child: IgnorePointer(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.edit_outlined),
                                      label: Text(l.palmFixLine),
                                      onPressed: () {},
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton.icon(
                                  icon: const Icon(Icons.check),
                                  label: Text(l.palmLooksRight),
                                  onPressed: _finish,
                                ),
                              ),
                            ],
                          ),
                        ] else
                          Row(
                            children: [
                              IconButton.outlined(
                                tooltip: l.palmUndo,
                                icon: const Icon(Icons.undo),
                                onPressed: () => setState(() {
                                  if (!_calibrating && _traced[_current]!.isNotEmpty) {
                                    _traced[_current]!.removeLast();
                                    _auto.remove(_current);
                                  } else if (!_calibrating && !_fixing && _line > 0) {
                                    _line--;
                                  } else if (_taps.isNotEmpty && !_fixing) {
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
                                child: Text(
                                  _fixing ? l.palmDone : (_line == _lines.length - 1 ? l.palmUseTracing : l.palmNext),
                                ),
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
    this.hand = const [],
  });

  final double aspect;
  final List<Offset> taps;
  final PalmFrame? frame;
  final String? current;
  final Map<String, List<List<Offset>>> traced;
  final Color color;

  /// The hand's 21 points, drawn as a faint outline (review only).
  final List<Offset> hand;

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
    if (hand.length == 21) {
      final bone = Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      for (final (a, b) in PalmAutoResult.bones) {
        canvas.drawLine(px(hand[a]), px(hand[b]), bone);
      }
      for (final h in hand) {
        canvas.drawCircle(px(h), 3, Paint()..color = Colors.white.withValues(alpha: 0.8));
      }
    }
    final f = frame;
    if (f == null) return;

    // Dotted guide for the current line: where it usually runs.
    final guide = current == null ? const <Offset>[] : PalmFrame.guides[current]!;
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
      // In the review (no current line) each line has its own colour.
      final paint = Paint()
        ..color = current == null
            ? _PalmTraceScreenState.lineColors[e.key]!
            : (e.key == current ? color : color.withValues(alpha: 0.45))
        ..strokeWidth = current == null || e.key == current ? 4 : 3
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
