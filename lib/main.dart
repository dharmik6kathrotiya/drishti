import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sweph/sweph.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

import 'app/app.dart';
import 'app/providers.dart';
import 'core/astro/ephemeris.dart';
import 'core/storage/local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Bundled model outside pub packages: shown on the licences page.
  LicenseRegistry.addLicense(
    () => Stream.value(
      const LicenseEntryWithLineBreaks(
        ['MediaPipe Hand Landmarker model'],
        'Copyright Google LLC. Licensed under the Apache License, Version 2.0 '
        '(https://www.apache.org/licenses/LICENSE-2.0). Used on the phone to find the hand in palm photos.',
      ),
    ),
  );
  tzdata.initializeTimeZones();

  final supportDir = await getApplicationSupportDirectory();
  final results = await Future.wait([
    Ephemeris.init(assetLoader: _BundleLoader(), epheFilesPath: '${supportDir.path}/ephe_files'),
    LocalStore.open(),
  ]);

  var deviceTz = 'Asia/Kolkata';
  try {
    deviceTz = (await FlutterTimezone.getLocalTimezone()).identifier;
  } catch (_) {}

  runApp(
    ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(results[1] as LocalStore),
        deviceTimezoneProvider.overrideWithValue(deviceTz),
      ],
      child: const DrishtiApp(),
    ),
  );
}

class _BundleLoader implements AssetLoader {
  @override
  Future<Uint8List> load(String assetPath) async => (await rootBundle.load(assetPath)).buffer.asUint8List();
}
