import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../core/astro/constants.dart';

/// Snapshot of the sky for a journal day, stored with the entry so history
/// never needs recalculating.
class JournalSky {
  const JournalSky({required this.tithi, required this.nakshatra, required this.moonSign});

  /// 1..30 (1–15 Shukla, 16–30 Krishna).
  final int tithi;
  final int nakshatra;
  final Sign moonSign;

  bool get shukla => tithi <= 15;

  Map<String, dynamic> toJson() => {'t': tithi, 'n': nakshatra, 'm': moonSign.index};
  factory JournalSky.fromJson(Map j) =>
      JournalSky(tithi: j['t'] as int, nakshatra: j['n'] as int, moonSign: Sign.values[j['m'] as int]);
}

class JournalEntry {
  const JournalEntry({
    required this.date,
    required this.mood,
    required this.energy,
    this.tags = const [],
    this.note = '',
    this.sky,
  });

  /// Local calendar date (time ignored).
  final DateTime date;

  /// 1 (low) .. 5 (great).
  final int mood;
  final int energy;
  final List<String> tags;
  final String note;
  final JournalSky? sky;

  String get key => keyFor(date);

  static String keyFor(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
    'date': key,
    'mood': mood,
    'energy': energy,
    if (tags.isNotEmpty) 'tags': tags,
    if (note.isNotEmpty) 'note': note,
    if (sky != null) 'sky': sky!.toJson(),
  };

  factory JournalEntry.fromJson(Map j) {
    final p = (j['date'] as String).split('-').map(int.parse).toList();
    return JournalEntry(
      date: DateTime(p[0], p[1], p[2]),
      mood: j['mood'] as int,
      energy: (j['energy'] as int?) ?? 3,
      tags: ((j['tags'] as List?) ?? const []).cast<String>(),
      note: (j['note'] as String?) ?? '',
      sky: j['sky'] is Map ? JournalSky.fromJson(j['sky'] as Map) : null,
    );
  }
}

/// Simple averages for the insights view. Only meaningful with enough data.
class JournalInsights {
  JournalInsights(List<JournalEntry> entries)
    : shukla = _avg(entries.where((e) => e.sky?.shukla == true)),
      krishna = _avg(entries.where((e) => e.sky?.shukla == false)),
      byElement = {for (final el in Element.values) el: _avg(entries.where((e) => e.sky?.moonSign.element == el))},
      byWeekday = {for (var d = 1; d <= 7; d++) d: _avg(entries.where((e) => e.date.weekday == d))};

  static const minimumEntries = 30;

  final double? shukla;
  final double? krishna;
  final Map<Element, double?> byElement;

  /// DateTime.weekday (1 = Monday) -> average mood.
  final Map<int, double?> byWeekday;

  static double? _avg(Iterable<JournalEntry> list) {
    final l = list.toList();
    if (l.isEmpty) return null;
    return l.fold<int>(0, (s, e) => s + e.mood) / l.length;
  }
}

class JournalNotifier extends AsyncNotifier<List<JournalEntry>> {
  Box<String>? _box;

  Future<Box<String>> _open() async => _box ??= await Hive.openBox<String>('journal');

  List<JournalEntry> _all() =>
      _box!.values.map((s) => JournalEntry.fromJson(jsonDecode(s) as Map)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  @override
  Future<List<JournalEntry>> build() async {
    await _open();
    return _all();
  }

  Future<void> save(JournalEntry e) async {
    await (await _open()).put(e.key, jsonEncode(e.toJson()));
    state = AsyncData(_all());
  }

  Future<void> delete(DateTime date) async {
    await (await _open()).delete(JournalEntry.keyFor(date));
    state = AsyncData(_all());
  }

  Future<void> clear() async {
    await (await _open()).clear();
    state = const AsyncData([]);
  }

  String exportJson() =>
      const JsonEncoder.withIndent('  ')
          .convert({'app': 'Drishti', 'journal': (state.value ?? const []).map((e) => e.toJson()).toList()});
}

final journalProvider = AsyncNotifierProvider<JournalNotifier, List<JournalEntry>>(JournalNotifier.new);
