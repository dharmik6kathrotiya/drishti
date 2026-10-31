import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/profile.dart';

/// Offline place search over the bundled GeoNames database (CC BY 4.0).
class PlaceDatabase {
  PlaceDatabase._(this._rows, this._timezones, this._countries);

  final List<_PlaceRow> _rows;
  final List<String> _timezones;
  final Map<String, String> _countries;

  static PlaceDatabase? _instance;
  static Future<PlaceDatabase>? _loading;

  static Future<PlaceDatabase> load() {
    if (_instance != null) return Future.value(_instance);
    return _loading ??= () async {
      final bytes = await rootBundle.load('assets/geo/places.tsv.gz');
      final db = await compute(_parse, bytes.buffer.asUint8List());
      return _instance = db;
    }();
  }

  /// For tests: parse from raw gzip bytes.
  static PlaceDatabase fromBytes(Uint8List gz) => _parse(gz);

  static PlaceDatabase _parse(Uint8List gz) {
    final text = utf8.decode(GZipCodec().decode(gz));
    final lines = const LineSplitter().convert(text);
    final tz = lines[0].split('\t').sublist(1);
    final countries = <String, String>{
      for (final pair in lines[1].split('\t').sublist(1))
        pair.substring(0, pair.indexOf('=')): pair.substring(pair.indexOf('=') + 1),
    };
    final rows = <_PlaceRow>[];
    for (var i = 2; i < lines.length; i++) {
      final p = lines[i].split('\t');
      if (p.length < 8) continue;
      rows.add(
        _PlaceRow(
          name: p[0],
          search: _fold(p[1].isEmpty ? p[0] : p[1]),
          region: p[2],
          cc: p[3],
          lat: double.parse(p[4]),
          lon: double.parse(p[5]),
          tz: int.parse(p[6]),
        ),
      );
    }
    return PlaceDatabase._(rows, tz, countries);
  }

  int get length => _rows.length;
  String countryName(String code) => _countries[code] ?? code;

  /// Places whose name starts with [query] first (largest first), then places
  /// containing it. Accepts "Name, Region" to narrow the search.
  List<Place> search(String query, {int limit = 30}) {
    final parts = query.split(',');
    final q = _fold(parts.first.trim());
    final regionQ = parts.length > 1 ? _fold(parts.sublist(1).join(',').trim()) : '';
    if (q.length < 2) return const [];
    final prefix = <Place>[];
    final contains = <Place>[];
    for (final r in _rows) {
      if (regionQ.isNotEmpty &&
          !_fold(r.region).startsWith(regionQ) &&
          !_fold(countryName(r.cc)).startsWith(regionQ) &&
          _fold(r.cc) != regionQ) {
        continue;
      }
      if (r.search.startsWith(q)) {
        prefix.add(_toPlace(r));
        if (prefix.length >= limit) break;
      } else if (contains.length < limit && r.search.contains(q)) {
        contains.add(_toPlace(r));
      }
    }
    return [...prefix, ...contains].take(limit).toList();
  }

  /// Most populous place in a timezone (rows are sorted by population).
  Place? largestInTimezone(String timezoneId) {
    final i = _timezones.indexOf(timezoneId);
    if (i < 0) return null;
    for (final r in _rows) {
      if (r.tz == i) return _toPlace(r);
    }
    return null;
  }

  /// Nearest known place to coordinates (used for GPS / manual coordinates).
  Place nearest(double lat, double lon) {
    _PlaceRow? best;
    var bestD = double.infinity;
    for (final r in _rows) {
      final dLat = r.lat - lat;
      final dLon = (r.lon - lon) * _cosApprox(lat);
      final d = dLat * dLat + dLon * dLon;
      if (d < bestD) {
        bestD = d;
        best = r;
      }
    }
    return _toPlace(best!);
  }

  Place _toPlace(_PlaceRow r) => Place(
    name: r.name,
    region: r.region,
    countryCode: r.cc,
    latitude: r.lat,
    longitude: r.lon,
    timezoneId: _timezones[r.tz],
  );

  static double _cosApprox(double latDeg) {
    final x = latDeg * 3.141592653589793 / 180;
    return 1 - x * x / 2 + x * x * x * x / 24;
  }

  static const _accentGroups = {
    'a': 'àáâãäåāăą',
    'c': 'çćč',
    'd': 'ď',
    'e': 'èéêëēėęě',
    'i': 'ìíîïīį',
    'l': 'ł',
    'n': 'ñńň',
    'o': 'òóôõöøōő',
    'r': 'ř',
    's': 'śšş',
    't': 'țť',
    'u': 'ùúûüūůűų',
    'y': 'ýÿ',
    'z': 'žźż',
  };

  static final Map<String, String> _accentMap = {
    for (final e in _accentGroups.entries)
      for (final ch in e.value.split('')) ch: e.key,
  };

  static String _fold(String s) {
    final b = StringBuffer();
    for (final ch in s.toLowerCase().split('')) {
      b.write(_accentMap[ch] ?? ch);
    }
    return b.toString();
  }
}

class _PlaceRow {
  const _PlaceRow({
    required this.name,
    required this.search,
    required this.region,
    required this.cc,
    required this.lat,
    required this.lon,
    required this.tz,
  });

  final String name;
  final String search;
  final String region;
  final String cc;
  final double lat;
  final double lon;
  final int tz;
}
