// Merges per-feature string fragments into the ARB files.
//
// lib/l10n/fragments/<feature>.json        -> lib/l10n/app_en.arb (template)
// lib/l10n/fragments/<feature>.<lang>.json -> lib/l10n/app_<lang>.arb
//
// Fragments use the ARB format (including "@key" metadata in English ones).
// Running this tool is idempotent: run it any number of times, in any order.
//
// Usage: dart run tool/merge_arb.dart [lang ...]   (default: all languages)
//        then: flutter gen-l10n
import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final fragments = Directory('lib/l10n/fragments')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  // Group fragments by language: "ai.json" -> en, "ai.hi.json" -> hi.
  final byLang = <String, List<File>>{};
  for (final f in fragments) {
    final name = f.uri.pathSegments.last;
    final parts = name.split('.');
    final lang = parts.length == 3 ? parts[1] : 'en';
    byLang.putIfAbsent(lang, () => []).add(f);
  }

  final only = args.toSet();
  for (final entry in byLang.entries) {
    if (only.isNotEmpty && !only.contains(entry.key)) continue;
    _merge(entry.key, entry.value);
  }
}

void _merge(String lang, List<File> files) {
  final target = File('lib/l10n/app_$lang.arb');
  final arb = target.existsSync()
      ? jsonDecode(target.readAsStringSync()) as Map<String, dynamic>
      : <String, dynamic>{'@@locale': lang};

  var added = 0;
  for (final f in files) {
    final map = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    for (final e in map.entries) {
      if (e.key.startsWith('@@')) continue;
      final existing = arb[e.key];
      if (lang == 'en' && existing != null && !e.key.startsWith('@') && existing != e.value) {
        stderr.writeln('Conflict for "${e.key}" in ${f.path}; keeping the template value.');
        continue;
      }
      if (existing == null) added++;
      arb[e.key] = e.value;
    }
  }

  target.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(arb)}\n');
  stdout.writeln('[$lang] merged ${files.length} fragments, $added new entries.');
}
