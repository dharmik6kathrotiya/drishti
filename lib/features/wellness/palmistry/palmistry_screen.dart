import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/content/palmistry/palmistry_content.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/common.dart';
import 'palm_diagram.dart';
import 'palm_trace_screen.dart';
import '../../../ui/widgets/tool_info_button.dart';

/// Step-by-step guided palm reading. Step 0 is the introduction, steps
/// 1..n are questions, and the final step is the reading.
class PalmistryScreen extends StatefulWidget {
  const PalmistryScreen({super.key});

  @override
  State<PalmistryScreen> createState() => _PalmistryScreenState();
}

class _PalmistryScreenState extends State<PalmistryScreen> {
  int _step = 0;
  final Map<String, int> _answers = {};
  String? _photoPath;

  /// Questions whose answer was suggested from the user's tracing.
  final Set<String> _suggested = {};

  Future<void> _trace() async {
    final result = await Navigator.of(context)
        .push<Map<String, int?>>(MaterialPageRoute(builder: (_) => PalmTraceScreen(photoPath: _photoPath!)));
    if (result == null || !mounted) return;
    setState(() {
      for (final e in result.entries) {
        if (e.value == null) continue;
        _answers[e.key] = e.value!;
        _suggested.add(e.key);
      }
      _step = 1;
    });
  }

  Future<void> _pick(ImageSource source) async {
    // The app declares CAMERA (for QR scanning), so Android requires the
    // runtime permission before handing off to the camera app.
    if (source == ImageSource.camera && !(await Permission.camera.request()).isGranted) return;
    try {
      final x = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 85);
      if (x != null) setState(() => _photoPath = x.path);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final texts = palmistryFor(Localizations.localeOf(context).languageCode);
    final qs = texts.questions;
    final total = qs.length;
    final theme = Theme.of(context);

    Widget body;
    if (_step == 0) {
      body = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(texts.intro, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 12),
          SectionCard(
            icon: Icons.info_outline,
            title: l.palmTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(texts.noScanNote, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(texts.whichHand),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(l.palmAddPhoto, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(l.palmTakePhoto),
                onPressed: () => _pick(ImageSource.camera),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(l.palmChoosePhoto),
                onPressed: () => _pick(ImageSource.gallery),
              ),
            ],
          ),
          if (_photoPath != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(File(_photoPath!), height: 220, fit: BoxFit.cover),
            ),
            const SizedBox(height: 10),
            FilledButton.tonalIcon(icon: const Icon(Icons.gesture), label: Text(l.palmTraceButton), onPressed: _trace),
          ],
          const SizedBox(height: 20),
          FilledButton(onPressed: () => setState(() => _step = 1), child: Text(l.palmNext)),
        ],
      );
    } else if (_step <= total) {
      final q = qs[_step - 1];
      final selected = _answers[q.id];
      body = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.palmStepOf(_step, total), style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(q.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PalmDiagram(area: q.area, size: 130),
              if (_photoPath != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: InteractiveViewer(
                      maxScale: 5,
                      child: Image.file(File(_photoPath!), height: 162, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(q.help, style: theme.textTheme.bodyMedium),
          if (_suggested.contains(q.id)) ...[const SizedBox(height: 8), SourceNote(l.palmSuggested)],
          const SizedBox(height: 12),
          RadioGroup<int>(
            groupValue: selected,
            onChanged: (v) => setState(() {
              _answers[q.id] = v!;
              _suggested.remove(q.id);
            }),
            child: Column(
              children: [
                for (var i = 0; i < q.options.length; i++)
                  RadioListTile<int>(contentPadding: EdgeInsets.zero, value: i, title: Text(q.options[i].label)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton(onPressed: () => setState(() => _step--), child: Text(l.palmBack)),
              const Spacer(),
              FilledButton(
                onPressed: () => setState(() => _step++),
                child: Text(_step == total ? l.palmSeeReading : l.palmNext),
              ),
            ],
          ),
        ],
      );
    } else {
      body = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.palmReadingTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          for (final q in qs)
            if (_answers[q.id] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SectionCard(
                  title: q.title,
                  icon: Icons.back_hand_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(q.options[_answers[q.id]!].label, style: theme.textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(q.options[_answers[q.id]!].meaning),
                    ],
                  ),
                ),
              ),
          SourceNote(texts.closing),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: Text(l.palmStartOver),
            onPressed: () => setState(() {
              _answers.clear();
              _suggested.clear();
              _step = 0;
            }),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.palmTitle),
        actions: const [ToolInfoButton(toolId: 'palmistry')],
      ),
      body: body,
    );
  }
}
