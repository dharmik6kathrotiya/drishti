import 'package:drishti/core/astro/vedic/dasha.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final birth = DateTime.utc(1990, 5, 17, 6, 30);
  const moon = 123.4; // Ashlesha: Mercury mahadasha at birth
  final now = DateTime.utc(2026, 10, 29);

  for (final system in [Vimshottari(), YoginiDasha()]) {
    group(system.name, () {
      test('month by month: pratyantardashas cover the month without gaps', () {
        for (var i = 0; i < 12; i++) {
          final from = DateTime.utc(2026, 10 + i);
          final to = DateTime.utc(2026, 11 + i);
          final ps = system.between(birth, moon, from, to);
          expect(ps, isNotEmpty);
          expect(ps.every((p) => p.level == 3), isTrue);
          expect(ps.first.start.isAfter(from), isFalse);
          expect(ps.last.end.isBefore(to), isFalse);
          for (var j = 1; j < ps.length; j++) {
            expect(ps[j].start, ps[j - 1].end, reason: 'continuous');
          }
        }
      });

      test('coming next starts where the running period ends', () {
        final running = system.runningAt(birth, moon, now);
        for (final level in [1, 2, 3]) {
          final next = system.upcoming(birth, moon, now, level: level, count: 2);
          expect(next, hasLength(2), reason: 'level $level');
          expect(next.first.start, running[level - 1].end, reason: 'level $level');
          expect(next[1].start, next.first.end);
          expect(next.every((p) => p.level == level), isTrue);
        }
      });
    });
  }
}
