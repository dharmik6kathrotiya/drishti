import 'package:flutter/material.dart';

import '../../../core/i18n/astro_names.dart';

import 'journal_store.dart';

/// Mood (1–5) over time, with full and new moons marked as vertical lines.
class MoodChart extends StatelessWidget {
  const MoodChart({super.key, required this.entries});

  /// Oldest first.
  final List<JournalEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 160,
          width: double.infinity,
          child: CustomPaint(painter: _MoodPainter(entries, theme.colorScheme, theme.textTheme)),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _Legend(
              color: theme.colorScheme.primary,
              label: '○ ${AstroNames.of(Localizations.localeOf(context).languageCode).tithi(15)}',
            ),
            const SizedBox(width: 12),
            _Legend(
              color: theme.colorScheme.outline,
              label: '● ${AstroNames.of(Localizations.localeOf(context).languageCode).tithi(30)}',
            ),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(width: 12, height: 2, color: color),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _MoodPainter extends CustomPainter {
  _MoodPainter(this.entries, this.scheme, this.textTheme);
  final List<JournalEntry> entries;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 18.0, bottom = 8.0, top = 8.0;
    final w = size.width - left;
    final h = size.height - top - bottom;
    final grid = Paint()
      ..color = scheme.outline.withValues(alpha: 0.35)
      ..strokeWidth = 0.8;
    for (var m = 1; m <= 5; m++) {
      final y = top + h - (m - 1) / 4 * h;
      canvas.drawLine(Offset(left, y), Offset(size.width, y), grid);
      final tp = TextPainter(
        text: TextSpan(
          text: '$m',
          style: textTheme.labelSmall?.copyWith(color: scheme.outline),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }
    if (entries.isEmpty) return;

    final first = entries.first.date;
    final span = entries.last.date.difference(first).inDays.clamp(1, 100000);
    double x(JournalEntry e) => left + e.date.difference(first).inDays / span * w;
    double y(JournalEntry e) => top + h - (e.mood - 1) / 4 * h;

    for (final e in entries) {
      final t = e.sky?.tithi;
      if (t == 15 || t == 30) {
        canvas.drawLine(
          Offset(x(e), top),
          Offset(x(e), top + h),
          Paint()
            ..color = (t == 15 ? scheme.primary : scheme.outline).withValues(alpha: 0.6)
            ..strokeWidth = 1.2,
        );
      }
    }

    final line = Path();
    for (var i = 0; i < entries.length; i++) {
      final p = Offset(x(entries[i]), y(entries[i]));
      i == 0 ? line.moveTo(p.dx, p.dy) : line.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = scheme.secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
    final dot = Paint()..color = scheme.secondary;
    for (final e in entries) {
      canvas.drawCircle(Offset(x(e), y(e)), 3, dot);
    }
  }

  @override
  bool shouldRepaint(_MoodPainter old) => old.entries != entries || old.scheme != scheme;
}
