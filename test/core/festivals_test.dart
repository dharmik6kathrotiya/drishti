import 'package:drishti/core/astro/vedic/festivals.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/ephemeris_setup.dart';

/// Reference dates are those published by mainstream North Indian panchangs
/// for New Delhi. A ±1 day tolerance is allowed only where traditions
/// genuinely differ (documented per case).
void main() {
  setUpAll(setUpEphemeris);

  late List<FestivalEvent> y2025;
  late List<FestivalEvent> y2026;

  setUpAll(() {
    final calc = FestivalCalculator(latitude: 28.6139, longitude: 77.2090, timezoneId: 'Asia/Kolkata');
    y2025 = calc.year(2025);
    y2026 = calc.year(2026);
  });

  DateTime dateOf(List<FestivalEvent> events, String id) =>
      events.firstWhere((e) => e.id == id, orElse: () => throw StateError('$id not found')).date;

  void expectDate(List<FestivalEvent> events, String id, DateTime expected, {int tolerance = 0}) {
    final d = dateOf(events, id);
    expect(
      d.difference(expected).inDays.abs(),
      lessThanOrEqualTo(tolerance),
      reason: '$id: got $d, expected $expected',
    );
  }

  group('2025, New Delhi', () {
    test('Makar Sankranti', () => expectDate(y2025, 'sankranti_capricorn', DateTime(2025, 1, 14)));
    test('Vasant Panchami (kshaya Panchami)', () => expectDate(y2025, 'vasant_panchami', DateTime(2025, 2, 2)));
    test('Maha Shivaratri', () => expectDate(y2025, 'maha_shivaratri', DateTime(2025, 2, 26)));
    test('Holika Dahan and Holi', () {
      expectDate(y2025, 'holika_dahan', DateTime(2025, 3, 13));
      expectDate(y2025, 'holi', DateTime(2025, 3, 14));
    });
    test('Ugadi / Gudi Padwa', () => expectDate(y2025, 'ugadi', DateTime(2025, 3, 30)));
    test('Hanuman Jayanti', () => expectDate(y2025, 'hanuman_jayanti', DateTime(2025, 4, 12)));
    test('Akshaya Tritiya', () => expectDate(y2025, 'akshaya_tritiya', DateTime(2025, 4, 30)));
    test('Guru Purnima', () => expectDate(y2025, 'guru_purnima', DateTime(2025, 7, 10)));
    test(
      'Raksha Bandhan (Bhadra on the previous afternoon)',
      () => expectDate(y2025, 'raksha_bandhan', DateTime(2025, 8, 9)),
    );
    // Smarta (Ashtami at nishita) vs Vaishnava/Rohini traditions can differ by a day.
    test('Janmashtami', () => expectDate(y2025, 'janmashtami', DateTime(2025, 8, 16), tolerance: 1));
    test('Ganesh Chaturthi', () => expectDate(y2025, 'ganesh_chaturthi', DateTime(2025, 8, 27)));
    test('Onam', () => expectDate(y2025, 'onam', DateTime(2025, 9, 5)));
    test('Sharad Navratri begins', () => expectDate(y2025, 'sharad_navratri', DateTime(2025, 9, 22)));
    test('Dussehra', () => expectDate(y2025, 'dussehra', DateTime(2025, 10, 2)));
    test('Karva Chauth', () => expectDate(y2025, 'karva_chauth', DateTime(2025, 10, 10)));
    test('Dhanteras', () => expectDate(y2025, 'dhanteras', DateTime(2025, 10, 18)));
    test(
      'Diwali (Amavasya barely touches the second pradosh)',
      () => expectDate(y2025, 'diwali', DateTime(2025, 10, 20)),
    );
    test('Govardhan Puja', () => expectDate(y2025, 'govardhan_puja', DateTime(2025, 10, 22)));
    test('Bhai Dooj', () => expectDate(y2025, 'bhai_dooj', DateTime(2025, 10, 23)));
    test('Chhath', () => expectDate(y2025, 'chhath', DateTime(2025, 10, 27)));
    // Smarta and Vaishnava Ekadashi can fall on consecutive days.
    test('Nirjala Ekadashi', () => expectDate(y2025, 'ekadashi_nirjala', DateTime(2025, 6, 6), tolerance: 1));
  });

  group('2026, New Delhi', () {
    test('Makar Sankranti', () => expectDate(y2026, 'sankranti_capricorn', DateTime(2026, 1, 14)));
    test('Maha Shivaratri', () => expectDate(y2026, 'maha_shivaratri', DateTime(2026, 2, 15)));
    test('Holika Dahan moves past an all-night Bhadra; Holi on 4 March', () {
      expectDate(y2026, 'holika_dahan', DateTime(2026, 3, 3));
      expectDate(y2026, 'holi', DateTime(2026, 3, 4));
    });
    // Navami spans two madhyahnas in some years; almanacs differ.
    test('Ram Navami', () => expectDate(y2026, 'ram_navami', DateTime(2026, 3, 26), tolerance: 1));
    test('Lunar eclipse of 3 March 2026 is listed', () {
      expect(y2026.any((e) => e.id == 'lunar_eclipse' && e.date == DateTime(2026, 3, 3)), isTrue);
    });
  });

  test('every month has two Ekadashis, all 12 sankrantis are present', () {
    expect(y2025.where((e) => e.id.startsWith('ekadashi_')).length, inInclusiveRange(23, 26));
    expect(y2025.where((e) => e.type == FestivalType.sankranti).length, 12);
    expect(y2025.where((e) => e.id == 'purnima').length, inInclusiveRange(12, 13));
  });

  test('events are sorted and inside the year', () {
    for (var i = 1; i < y2025.length; i++) {
      expect(y2025[i].date.isBefore(y2025[i - 1].date), isFalse);
    }
    expect(y2025.every((e) => e.date.year == 2025), isTrue);
  });
}
