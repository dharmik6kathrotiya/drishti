import 'dart:convert';

import 'package:hive_ce/hive_ce.dart';

import 'answerer.dart';

class MemoryEntry {
  const MemoryEntry({required this.question, required this.answer, required this.at});
  final String question;
  final AiAnswer answer;
  final DateTime at;

  Map<String, dynamic> toJson() => {'q': question, 'a': answer.toJson(), 'at': at.toIso8601String()};

  factory MemoryEntry.fromJson(Map json) => MemoryEntry(
    question: json['q'] as String,
    answer: AiAnswer.fromJson(json['a'] as Map),
    at: DateTime.parse(json['at'] as String),
  );
}

/// Per-profile conversation history and life facts the user chose to share.
/// Stored only on this device in the `ai_memory` Hive box.
class AiMemory {
  AiMemory._(this._box);
  final Box<String> _box;

  static const boxName = 'ai_memory';
  static const maxEntries = 100;

  static Future<AiMemory> open() async {
    final box = Hive.isBoxOpen(boxName) ? Hive.box<String>(boxName) : await Hive.openBox<String>(boxName);
    return AiMemory._(box);
  }

  /// For tests.
  factory AiMemory.withBox(Box<String> box) => AiMemory._(box);

  List<MemoryEntry> history(String profileId) {
    final raw = _box.get('qa:$profileId');
    if (raw == null) return const [];
    return [for (final e in jsonDecode(raw) as List) MemoryEntry.fromJson(e as Map)];
  }

  Future<void> add(String profileId, MemoryEntry entry) {
    final list = [...history(profileId), entry];
    final trimmed = list.length > maxEntries ? list.sublist(list.length - maxEntries) : list;
    return _box.put('qa:$profileId', jsonEncode(trimmed.map((e) => e.toJson()).toList()));
  }

  List<String> lifeFacts(String profileId) {
    final raw = _box.get('facts:$profileId');
    return raw == null ? const [] : [for (final f in jsonDecode(raw) as List) f as String];
  }

  Future<void> setLifeFacts(String profileId, List<String> facts) => _box.put('facts:$profileId', jsonEncode(facts));

  Future<void> clearProfile(String profileId) async {
    await _box.delete('qa:$profileId');
    await _box.delete('facts:$profileId');
  }

  Future<void> clearAll() async {
    final keys = _box.keys.where((k) => k.toString().startsWith('qa:') || k.toString().startsWith('facts:')).toList();
    await _box.deleteAll(keys);
  }

  // Small settings used by the AI feature.
  Map<String, dynamic> get _settings {
    final raw = _box.get('settings');
    return raw == null ? <String, dynamic>{} : Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  bool get wifiOnly => (_settings['wifiOnly'] as bool?) ?? true;
  Future<void> setWifiOnly(bool v) => _box.put('settings', jsonEncode({..._settings, 'wifiOnly': v}));

  String? get activeModelId => _settings['model'] as String?;
  Future<void> setActiveModelId(String? id) => _box.put('settings', jsonEncode({..._settings, 'model': id}));
}
