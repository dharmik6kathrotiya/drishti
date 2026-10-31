import 'package:drishti/core/astro/numerology.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reduce keeps master numbers', () {
    expect(Numerology.reduce(29), 11);
    expect(Numerology.reduce(29, keepMasters: false), 2);
    expect(Numerology.reduce(1990), 1);
    expect(Numerology.reduce(22), 22);
  });

  test('life path of 1990-07-15 is 5', () {
    // 7 + (1+5=6) + (1+9+9+0=19 -> 10 -> 1) = 14 -> 5
    expect(Numerology.lifePath(DateTime(1990, 7, 15)), 5);
  });

  test('Mulank and Bhagyank', () {
    final d = DateTime(1990, 7, 29);
    expect(Numerology.mulank(d), 2); // 2+9 = 11 -> 2
    // 2+9 + 7 + 1+9+9+0 = 37 -> 10 -> 1
    expect(Numerology.bhagyank(d), 1);
  });

  test('Pythagorean name numbers', () {
    // JOHN: J1 O6 H8 N5 = 20 -> 2; vowels O6 -> 6; consonants 14 -> 5
    expect(Numerology.expression('John'), 2);
    expect(Numerology.soulUrge('John'), 6);
    expect(Numerology.personality('John'), 5);
  });

  test('Chaldean name number', () {
    // RAM: R2 A1 M4 = 7
    final (compound, reduced) = Numerology.chaldeanName('Ram');
    expect(compound, 7);
    expect(reduced, 7);
  });

  test('report uses available data only', () {
    expect(Numerology.report(name: 'Asha').numbers.map((n) => n.title), isNot(contains('Life Path')));
    final full = Numerology.report(name: 'Asha', birthDate: DateTime(2000, 1, 1));
    expect(full.byTitle('Life Path')!.value, 4); // 1 + 1 + 2
    expect(full.numbers.every((n) => n.meaning.isNotEmpty), isTrue);
  });
}
