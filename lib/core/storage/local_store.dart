import 'dart:convert';

import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../models/app_settings.dart';
import '../models/profile.dart';

/// All user data lives on the device. Nothing is sent to any server.
class LocalStore {
  LocalStore._(this._profiles, this._settings);

  final Box<String> _profiles;
  final Box<String> _settings;

  static Future<LocalStore> open() async {
    await Hive.initFlutter('drishti');
    final profiles = await Hive.openBox<String>('profiles');
    final settings = await Hive.openBox<String>('settings');
    return LocalStore._(profiles, settings);
  }

  List<Profile> loadProfiles() => _profiles.values.map((s) => Profile.fromJson(jsonDecode(s) as Map)).toList();

  Future<void> saveProfile(Profile p) => _profiles.put(p.id, jsonEncode(p.toJson()));
  Future<void> deleteProfile(String id) => _profiles.delete(id);

  AppSettings loadSettings() {
    final raw = _settings.get('app');
    return raw == null ? const AppSettings() : AppSettings.fromJson(jsonDecode(raw) as Map);
  }

  Future<void> saveSettings(AppSettings s) => _settings.put('app', jsonEncode(s.toJson()));

  /// Export everything as JSON (for the user's own backup / data portability).
  String exportAll() => const JsonEncoder.withIndent('  ').convert({
    'app': 'Drishti',
    'version': 1,
    'settings': loadSettings().toJson(),
    'profiles': loadProfiles().map((p) => p.toJson()).toList(),
  });

  Future<int> importAll(String json) async {
    final data = jsonDecode(json) as Map;
    var count = 0;
    for (final p in (data['profiles'] as List? ?? const [])) {
      await saveProfile(Profile.fromJson(p as Map));
      count++;
    }
    return count;
  }

  /// Feature boxes (AI memory, tarot history, journal) owned by other modules.
  static const featureBoxes = ['ai_memory', 'tarot', 'journal'];

  /// Deletes all data stored by the app on this device.
  Future<void> wipe() async {
    await _profiles.clear();
    await _settings.clear();
    for (final name in featureBoxes) {
      final box = Hive.isBoxOpen(name) ? Hive.box<String>(name) : await Hive.openBox<String>(name);
      await box.clear();
    }
  }
}
