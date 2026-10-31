import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drishti/core/astro/ephemeris.dart';
import 'package:sweph/sweph.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

/// Initialises Swiss Ephemeris for host-side unit tests using the native
/// library and ephemeris files shipped inside the sweph package.
Future<void> setUpEphemeris() async {
  tzdata.initializeTimeZones();
  if (Ephemeris.isReady) return;
  final root = _swephPackageRoot();
  final lib = Platform.isWindows ? '$root/example.dart/sweph.dll' : '$root/example.dart/libsweph.so';
  final tmp = await Directory.systemTemp.createTemp('drishti_ephe');
  await Ephemeris.init(modulePath: lib, assetLoader: _FileAssetLoader(root), epheFilesPath: tmp.path);
}

String _swephPackageRoot() {
  final config = jsonDecode(File('.dart_tool/package_config.json').readAsStringSync()) as Map;
  final pkg = (config['packages'] as List).cast<Map>().firstWhere((p) => p['name'] == 'sweph');
  return Uri.parse(pkg['rootUri'] as String).toFilePath(windows: Platform.isWindows);
}

class _FileAssetLoader implements AssetLoader {
  _FileAssetLoader(this.root);
  final String root;

  @override
  Future<Uint8List> load(String assetPath) async {
    final rel = assetPath.replaceFirst('packages/sweph/', '');
    return File('$root/$rel').readAsBytes();
  }
}
