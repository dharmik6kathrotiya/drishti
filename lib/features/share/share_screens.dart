import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../core/models/profile.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/format.dart';
import '../../ui/widgets/common.dart';
import '../../ui/widgets/tool_info_button.dart';

/// Profiles are shared phone-to-phone as a compact code (QR or text). Nothing
/// passes through a server. Notes and life events are never included.
class ProfileCodec {
  ProfileCodec._();
  static const prefix = 'DRISHTI1:';

  static String encode(Profile p) {
    final json = p.toJson()
      ..remove('id')
      ..remove('self')
      ..remove('notes')
      ..remove('events')
      ..remove('rel');
    return prefix + base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  }

  static Profile? decode(String code) {
    final c = code.trim();
    final i = c.indexOf(prefix);
    if (i < 0) return null;
    var body = c.substring(i + prefix.length).split(RegExp(r'\s')).first;
    body = body.padRight((body.length + 3) ~/ 4 * 4, '=');
    try {
      final map = jsonDecode(utf8.decode(base64Url.decode(body))) as Map;
      map['id'] = ProfilesNotifier.newId();
      return Profile.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}

class ShareProfileScreen extends ConsumerWidget {
  const ShareProfileScreen({super.key, required this.profileId});
  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final profile = profileById(ref.watch(profilesProvider), profileId);
    if (profile == null) return Scaffold(appBar: AppBar());
    final code = ProfileCodec.encode(profile);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.shareProfileTitle),
        actions: const [ToolInfoButton(toolId: 'share_qr')],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(l.shareProfileBody(profile.name), style: theme.textTheme.bodyMedium),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: QrImageView(data: code, size: 240, backgroundColor: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(profile.name, textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
          Text(Fmt.birthSummary(profile), textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.share),
            label: Text(l.shareAsText),
            onPressed: () => SharePlus.instance.share(ShareParams(text: l.shareText(profile.name, code))),
          ),
          const SizedBox(height: 12),
          SourceNote(l.sharePrivacyNote),
        ],
      ),
    );
  }
}

class ScanProfileScreen extends StatefulWidget {
  const ScanProfileScreen({super.key});

  @override
  State<ScanProfileScreen> createState() => _ScanProfileScreenState();
}

class _ScanProfileScreenState extends State<ScanProfileScreen> {
  bool _done = false;

  void _open(Profile p) {
    if (_done) return;
    _done = true;
    context.pushReplacement('/profile/new', extra: p);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.scanProfile),
        actions: [
          const ToolInfoButton(toolId: 'share_qr'),
          TextButton.icon(
            icon: const Icon(Icons.content_paste),
            label: Text(l.pasteCode),
            onPressed: () async {
              final controller = TextEditingController();
              final text = await showDialog<String>(
                context: context,
                builder: (c) => AlertDialog(
                  title: Text(l.pasteCode),
                  content: TextField(
                    controller: controller,
                    maxLines: 4,
                    decoration: InputDecoration(hintText: ProfileCodec.prefix),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c), child: Text(l.cancel)),
                    FilledButton(onPressed: () => Navigator.pop(c, controller.text), child: Text(l.continueLabel)),
                  ],
                ),
              );
              if (text == null || !context.mounted) return;
              final p = ProfileCodec.decode(text);
              if (p == null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.invalidCode)));
              } else {
                _open(p);
              }
            },
          ),
        ],
      ),
      body: MobileScanner(
        onDetect: (capture) {
          for (final b in capture.barcodes) {
            final p = b.rawValue == null ? null : ProfileCodec.decode(b.rawValue!);
            if (p != null) {
              _open(p);
              break;
            }
          }
        },
      ),
    );
  }
}
