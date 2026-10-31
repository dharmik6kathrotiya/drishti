import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'sha256.dart';

/// A downloadable on-device model.
class ModelInfo {
  const ModelInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.fileName,
    required this.url,
    required this.sizeBytes,
    required this.sha256,
    required this.license,
    required this.baseModel,
    this.minRamGb = 4,
    this.languages = const ['en'],
  });

  final String id;
  final String name;
  final String description;
  final String fileName;
  final String url;
  final int sizeBytes;

  /// Empty until the model is published; such models cannot be downloaded.
  final String sha256;
  final String license;
  final String baseModel;
  final int minRamGb;

  /// App languages this model passed the release gate (tool/ai/eval.py) in.
  /// In other languages the rule-based answerer is used instead.
  final List<String> languages;

  bool supports(String languageCode) => languages.contains(languageCode);

  /// Whether to use this model for [question] with the app in [languageCode].
  /// Indian-language app users often type English, which the model was
  /// trained on; but an English-only model never sees Indian scripts.
  bool handles(String languageCode, String question) {
    if (!supports(languageCode)) return false;
    if (languageCode != 'en') return true;
    var latin = 0, indic = 0;
    for (final r in question.runes) {
      if ((r >= 0x41 && r <= 0x5A) || (r >= 0x61 && r <= 0x7A)) latin++;
      if (r >= 0x0900 && r <= 0x0DFF) indic++; // Devanagari … Malayalam
    }
    return indic <= latin;
  }

  bool get isPublished => sha256.isNotEmpty && !url.contains('OWNER');

  factory ModelInfo.fromJson(Map json) => ModelInfo(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    fileName: json['fileName'] as String,
    url: json['url'] as String,
    sizeBytes: json['sizeBytes'] as int,
    sha256: (json['sha256'] as String?) ?? '',
    license: json['license'] as String,
    baseModel: json['baseModel'] as String,
    minRamGb: (json['minRamGb'] as int?) ?? 4,
    languages: [
      for (final l in (json['languages'] as List?) ?? const ['en']) l as String,
    ],
  );
}

/// Model catalogue. URLs point at the project's future GitHub Releases; an
/// entry becomes downloadable once its sha256 is filled in at release time.
const modelCatalogueJson = '''
[
  {
    "id": "drishti-guide-1.5b-q4",
    "name": "Drishti Guide (standard)",
    "description": "Best answers. About 1 GB; needs a phone with 6 GB RAM or more.",
    "fileName": "drishti-guide-1.5b-q4_k_m.gguf",
    "url": "https://github.com/dharmik6kathrotiya/drishti/releases/download/model-v1/drishti-guide-1.5b-q4_k_m.gguf",
    "sizeBytes": 1100000000,
    "sha256": "",
    "license": "Apache-2.0 (based on Qwen2.5-1.5B-Instruct)",
    "baseModel": "Qwen/Qwen2.5-1.5B-Instruct",
    "minRamGb": 6,
    "languages": ["en"]
  },
  {
    "id": "drishti-guide-0.5b-q4",
    "name": "Drishti Guide (lite)",
    "description": "Smaller and faster for older phones. About 400 MB; simpler answers.",
    "fileName": "drishti-guide-0.5b-q4_k_m.gguf",
    "url": "https://github.com/dharmik6kathrotiya/drishti/releases/download/model-v1/drishti-guide-0.5b-q4_k_m.gguf",
    "sizeBytes": 397807584,
    "sha256": "f7acfde2caaca457a8863f6d34f564edf97eb5f69a38d9d77de279a7bab4f30b",
    "license": "Apache-2.0 (based on Qwen2.5-0.5B-Instruct)",
    "baseModel": "Qwen/Qwen2.5-0.5B-Instruct",
    "minRamGb": 3,
    "languages": ["en"]
  }
]
''';

List<ModelInfo> loadCatalogue([String json = modelCatalogueJson]) => [
  for (final m in jsonDecode(json) as List) ModelInfo.fromJson(m as Map),
];

class DownloadProgress {
  const DownloadProgress(this.received, this.total);
  final int received;
  final int? total;
  double? get fraction => total == null || total == 0 ? null : received / total!;
}

class ModelDownloadException implements Exception {
  ModelDownloadException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Downloads, verifies and deletes model files in the app's support folder.
/// Makes no network calls unless the user starts a download.
class ModelManager {
  ModelManager(this.directory, {http.Client? client}) : _client = client ?? http.Client();

  /// Folder where models live (e.g. `<app support>/models`).
  final Directory directory;
  final http.Client _client;
  bool _cancelled = false;

  File fileFor(ModelInfo m) => File(p.join(directory.path, m.fileName));
  File _partFor(ModelInfo m) => File('${fileFor(m).path}.part');

  bool isInstalled(ModelInfo m) => fileFor(m).existsSync();

  int partialBytes(ModelInfo m) {
    final f = _partFor(m);
    return f.existsSync() ? f.lengthSync() : 0;
  }

  void cancel() => _cancelled = true;

  /// Streams progress. Resumes a previous partial download when possible and
  /// verifies the SHA-256 before installing.
  Stream<DownloadProgress> download(ModelInfo m) async* {
    if (!m.isPublished) {
      throw ModelDownloadException('This model has not been released yet.');
    }
    _cancelled = false;
    await directory.create(recursive: true);
    final part = _partFor(m);
    var offset = part.existsSync() ? part.lengthSync() : 0;

    final req = http.Request('GET', Uri.parse(m.url));
    if (offset > 0) req.headers['Range'] = 'bytes=$offset-';
    final res = await _client.send(req);
    if (res.statusCode == 200) {
      offset = 0; // server ignored the range; start over
    } else if (res.statusCode != 206) {
      throw ModelDownloadException('Download failed (HTTP ${res.statusCode}).');
    }
    final total = res.contentLength == null ? null : res.contentLength! + offset;
    final sink = part.openWrite(mode: offset == 0 ? FileMode.write : FileMode.append);
    var received = offset;
    try {
      await for (final chunk in res.stream) {
        if (_cancelled) throw ModelDownloadException('Download paused.');
        sink.add(chunk);
        received += chunk.length;
        yield DownloadProgress(received, total);
      }
    } finally {
      await sink.flush();
      await sink.close();
    }

    final hash = await sha256OfFile(part);
    if (hash != m.sha256.toLowerCase()) {
      await part.delete();
      throw ModelDownloadException('The downloaded file failed verification and was removed.');
    }
    await part.rename(fileFor(m).path);
    yield DownloadProgress(received, total);
  }

  Future<void> delete(ModelInfo m) async {
    for (final f in [fileFor(m), _partFor(m)]) {
      if (f.existsSync()) await f.delete();
    }
  }

  static Future<String> sha256OfFile(File f) async {
    final h = Sha256();
    await for (final chunk in f.openRead()) {
      h.add(chunk);
    }
    return h.hex();
  }
}
