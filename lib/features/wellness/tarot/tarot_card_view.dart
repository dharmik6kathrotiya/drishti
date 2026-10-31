import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/content/tarot/tarot_deck.dart';

/// Procedurally drawn tarot card (no bundled artwork): suit emblem, numeral
/// and name, coloured from the current theme.
class TarotCardView extends StatelessWidget {
  const TarotCardView({
    super.key,
    required this.card,
    required this.name,
    this.reversed = false,
    this.faceDown = false,
    this.width = 120,
  });

  final TarotCard card;
  final String name;
  final bool reversed;
  final bool faceDown;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final painter = faceDown
        ? _CardBackPainter(scheme)
        : _CardFacePainter(card: card, name: name, scheme: scheme, textTheme: Theme.of(context).textTheme);
    final view = SizedBox(
      width: width,
      height: width * 1.65,
      child: CustomPaint(painter: painter),
    );
    return Semantics(
      label: faceDown ? 'Tarot card, face down' : '$name${reversed ? ', reversed' : ''}',
      child: reversed && !faceDown ? Transform.rotate(angle: pi, child: view) : view,
    );
  }
}

Color _suitColor(TarotSuit suit, ColorScheme s) => switch (suit) {
  TarotSuit.major => s.primary,
  TarotSuit.wands => Color.lerp(s.primary, Colors.deepOrange, 0.55)!,
  TarotSuit.cups => Color.lerp(s.secondary, Colors.blue, 0.45)!,
  TarotSuit.swords => Color.lerp(s.onSurface, Colors.blueGrey, 0.4)!,
  TarotSuit.pentacles => Color.lerp(s.primary, Colors.green, 0.5)!,
};

class _CardFacePainter extends CustomPainter {
  _CardFacePainter({required this.card, required this.name, required this.scheme, required this.textTheme});
  final TarotCard card;
  final String name;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(size.width * 0.08));
    final accent = _suitColor(card.suit, scheme);
    canvas.drawRRect(r, Paint()..color = scheme.surfaceContainerHigh);
    canvas.drawRRect(
      r.deflate(size.width * 0.04),
      Paint()
        ..color = accent.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.2, size.width * 0.015),
    );

    _text(canvas, card.numeral, Offset(size.width / 2, size.height * 0.11), size.width * 0.14, accent, bold: true);

    final center = Offset(size.width / 2, size.height * 0.48);
    final emblem = size.width * 0.28;
    final paint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.5, size.width * 0.025)
      ..strokeCap = StrokeCap.round;
    _emblem(canvas, center, emblem, paint);

    _text(
      canvas,
      name,
      Offset(size.width / 2, size.height * 0.85),
      size.width * 0.095,
      scheme.onSurface,
      maxWidth: size.width * 0.86,
    );
  }

  void _emblem(Canvas canvas, Offset c, double s, Paint p) {
    switch (card.suit) {
      case TarotSuit.wands:
        canvas.drawLine(c + Offset(-s * 0.3, s * 0.8), c + Offset(s * 0.3, -s * 0.8), p);
        canvas.drawCircle(c + Offset(s * 0.3, -s * 0.8), s * 0.12, p);
        canvas.drawLine(c + Offset(-s * 0.05, 0), c + Offset(s * 0.25, -s * 0.15), p);
      case TarotSuit.cups:
        final path = Path()
          ..moveTo(c.dx - s * 0.55, c.dy - s * 0.6)
          ..quadraticBezierTo(c.dx - s * 0.55, c.dy + s * 0.15, c.dx, c.dy + s * 0.15)
          ..quadraticBezierTo(c.dx + s * 0.55, c.dy + s * 0.15, c.dx + s * 0.55, c.dy - s * 0.6)
          ..close();
        canvas.drawPath(path, p);
        canvas.drawLine(c + Offset(0, s * 0.15), c + Offset(0, s * 0.65), p);
        canvas.drawLine(c + Offset(-s * 0.3, s * 0.7), c + Offset(s * 0.3, s * 0.7), p);
      case TarotSuit.swords:
        canvas.drawLine(c + Offset(0, -s * 0.9), c + Offset(0, s * 0.6), p);
        canvas.drawLine(c + Offset(-s * 0.35, s * 0.35), c + Offset(s * 0.35, s * 0.35), p);
        canvas.drawLine(c + Offset(0, s * 0.6), c + Offset(0, s * 0.85), p);
      case TarotSuit.pentacles:
        canvas.drawCircle(c, s * 0.7, p);
        final star = Path();
        for (var i = 0; i < 5; i++) {
          final a = -pi / 2 + i * 4 * pi / 5;
          final pt = c + Offset(cos(a), sin(a)) * s * 0.6;
          i == 0 ? star.moveTo(pt.dx, pt.dy) : star.lineTo(pt.dx, pt.dy);
        }
        star.close();
        canvas.drawPath(star, p);
      case TarotSuit.major:
        // An eight-pointed star for the trumps.
        for (var i = 0; i < 8; i++) {
          final a = i * pi / 4;
          final len = i.isEven ? s * 0.85 : s * 0.5;
          canvas.drawLine(c, c + Offset(cos(a), sin(a)) * len, p);
        }
        canvas.drawCircle(c, s * 0.18, p);
    }
  }

  void _text(
    Canvas canvas,
    String text,
    Offset center,
    double fontSize,
    Color color, {
    bool bold = false,
    double? maxWidth,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
          fontSize: fontSize,
          color: color,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          height: 1.15,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth ?? double.infinity);
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_CardFacePainter old) => old.card != card || old.name != name || old.scheme != scheme;
}

class _CardBackPainter extends CustomPainter {
  _CardBackPainter(this.scheme);
  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(size.width * 0.08));
    canvas.drawRRect(r, Paint()..color = scheme.primary.withValues(alpha: 0.22));
    final p = Paint()
      ..color = scheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(r.deflate(size.width * 0.05), p);
    final c = size.center(Offset.zero);
    for (var ring = 1; ring <= 3; ring++) {
      canvas.drawCircle(c, size.width * 0.1 * ring, p..color = scheme.primary.withValues(alpha: 0.9 - ring * 0.2));
    }
    for (var i = 0; i < 12; i++) {
      final a = i * pi / 6;
      canvas.drawLine(
        c + Offset(cos(a), sin(a)) * size.width * 0.32,
        c + Offset(cos(a), sin(a)) * size.width * 0.38,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_CardBackPainter old) => old.scheme != scheme;
}
