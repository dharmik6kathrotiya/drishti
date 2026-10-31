import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/astro/chart.dart';
import '../core/astro/settings.dart';
import '../core/geo/places.dart';
import '../core/models/app_settings.dart';
import '../core/models/profile.dart';
import '../core/storage/local_store.dart';

/// Overridden in main() once storage is open.
final localStoreProvider = Provider<LocalStore>((ref) => throw UnimplementedError());

/// IANA timezone of the phone (overridden in main()).
final deviceTimezoneProvider = Provider<String>((ref) => 'Asia/Kolkata');

final placeDatabaseProvider = FutureProvider<PlaceDatabase>((ref) => PlaceDatabase.load());

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(localStoreProvider).loadSettings();

  void update(AppSettings Function(AppSettings) change) {
    state = change(state);
    ref.read(localStoreProvider).saveSettings(state);
  }

  void updateCalc(CalcSettings Function(CalcSettings) change) => update((s) => s.copyWith(calc: change(s.calc)));
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class ProfilesNotifier extends Notifier<List<Profile>> {
  @override
  List<Profile> build() {
    final list = ref.read(localStoreProvider).loadProfiles();
    list.sort(_order);
    return list;
  }

  static int _order(Profile a, Profile b) {
    if (a.isSelf != b.isSelf) return a.isSelf ? -1 : 1;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  static String newId() => const Uuid().v4();

  Future<void> save(Profile p) async {
    await ref.read(localStoreProvider).saveProfile(p);
    final list = [...state.where((x) => x.id != p.id), p]..sort(_order);
    state = list;
    if (ref.read(settingsProvider).activeProfileId == null) {
      ref.read(settingsProvider.notifier).update((s) => s.copyWith(activeProfileId: () => p.id));
    }
  }

  Future<void> delete(String id) async {
    await ref.read(localStoreProvider).deleteProfile(id);
    state = state.where((p) => p.id != id).toList();
    if (ref.read(settingsProvider).activeProfileId == id) {
      ref
          .read(settingsProvider.notifier)
          .update((s) => s.copyWith(activeProfileId: () => state.isEmpty ? null : state.first.id));
    }
  }

  void reload() => state = build();
}

final profilesProvider = NotifierProvider<ProfilesNotifier, List<Profile>>(ProfilesNotifier.new);

final activeProfileProvider = Provider<Profile?>((ref) {
  final id = ref.watch(settingsProvider.select((s) => s.activeProfileId));
  final profiles = ref.watch(profilesProvider);
  return profiles.where((p) => p.id == id).firstOrNull ?? profiles.firstOrNull;
});

Profile? profileById(List<Profile> profiles, String id) => profiles.where((p) => p.id == id).firstOrNull;

/// Natal chart for a profile with the current calculation settings, or null
/// when the profile has no birth date.
final natalChartProvider = Provider.family<Chart?, String>((ref, profileId) {
  final profile = profileById(ref.watch(profilesProvider), profileId);
  final calc = ref.watch(settingsProvider.select((s) => s.calc));
  return chartForProfile(profile, calc);
});

Chart? chartForProfile(Profile? profile, CalcSettings calc) {
  if (profile == null || !profile.hasDate) return null;
  final utc = profile.birthUtc()!;
  return ChartCalculator.cast(
    utc: utc,
    settings: calc,
    latitude: profile.place?.latitude,
    longitude: profile.place?.longitude,
    withHouses: profile.canCastFullChart,
  );
}
