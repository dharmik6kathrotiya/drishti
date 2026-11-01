import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// The optional daily feed: a static JSON file published for free (GitHub
/// Pages). The app works fully without it; the feed only adds editorial
/// announcements and ready-made content. Set FEED_URL at build time
/// (`--dart-define=FEED_URL=https://USER.github.io/REPO/feed/latest.json`).
class FeedService {
  FeedService._();

  static const url = String.fromEnvironment(
    'FEED_URL',
    defaultValue: 'https://dharmik6kathrotiya.github.io/drishti/feed/latest.json',
  );
  static const _maxAge = Duration(hours: 6);

  static Future<File> _cacheFile() async => File('${(await getApplicationSupportDirectory()).path}/feed_latest.json');

  /// Cached feed, refreshed in the background when older than [_maxAge].
  static Future<DailyFeed?> load() async {
    final file = await _cacheFile();
    DailyFeed? cached;
    if (file.existsSync()) {
      try {
        cached = DailyFeed.fromJson(jsonDecode(await file.readAsString()) as Map<String, dynamic>);
      } catch (_) {
        cached = null;
      }
    }
    final stale = !file.existsSync() || DateTime.now().difference(file.lastModifiedSync()) > _maxAge;
    if (url.isEmpty || !stale) return cached;
    try {
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final feed = DailyFeed.fromJson(jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
        await file.writeAsString(utf8.decode(res.bodyBytes));
        return feed;
      }
    } catch (_) {
      // Offline or unreachable: keep using the cache.
    }
    return cached;
  }
}

class Announcement {
  const Announcement({required this.id, required this.title, required this.body, this.until});
  final String id;
  final String title;
  final String body;
  final DateTime? until;

  bool get active => until == null || DateTime.now().isBefore(until!);
}

class DailyFeed {
  const DailyFeed({required this.date, required this.announcements, required this.raw});
  final String date;
  final List<Announcement> announcements;

  /// Full feed for features that want ready-made content.
  final Map<String, dynamic> raw;

  static const supportedVersion = 1;

  factory DailyFeed.fromJson(Map<String, dynamic> json) {
    if ((json['version'] as int? ?? 0) > supportedVersion) {
      // A newer feed format: only read the parts we understand.
    }
    return DailyFeed(
      date: json['date'] as String? ?? '',
      announcements: [
        for (final a in (json['announcements'] as List? ?? const []))
          Announcement(
            id: a['id'] as String? ?? '',
            title: a['title'] as String? ?? '',
            body: a['body'] as String? ?? '',
            until: a['until'] == null ? null : DateTime.tryParse(a['until'] as String),
          ),
      ],
      raw: json,
    );
  }
}

final dailyFeedProvider = FutureProvider<DailyFeed?>((ref) => FeedService.load());
