import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/color_tokens.dart';
import '../models/journal_entry.dart';
import '../providers/journal_provider.dart';

class JournalEntryScreen extends ConsumerStatefulWidget {
  /// Full entry ID ('YYYY-MM-DD_<ms>' for existing, 'new_YYYY-MM-DD' for new).
  final String entryId;
  const JournalEntryScreen({super.key, required this.entryId});

  @override
  ConsumerState<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen> {
  late final TextEditingController _headingCtrl;
  late final TextEditingController _subheadingCtrl;
  late final TextEditingController _bodyCtrl;
  late final TextEditingController _musicUrlCtrl;
  late final TextEditingController _musicTitleCtrl;
  late final FocusNode _bodyFocus;

  late List<String> _photoPaths;
  late List<String> _voiceNotePaths;
  String? _musicUrl;
  String? _musicTitle;

  bool _isRecording = false;
  String? _currentRecordingPath;
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  String? _playingPath;

  bool _dirty = false;
  bool _saving = false;

  late final DateTime _date;
  late final String? _existingId; // null → brand-new entry

  @override
  void initState() {
    super.initState();
    final isNew = widget.entryId.startsWith('new_');
    final dateStr = isNew
        ? widget.entryId.substring(4)
        : JournalEntry.datePrefix(widget.entryId);
    _date = DateTime.parse(dateStr);
    final existing = isNew
        ? null
        : ref.read(journalProvider.notifier).entryById(widget.entryId);
    _existingId = existing?.id;

    _headingCtrl = TextEditingController(text: existing?.heading ?? '');
    _subheadingCtrl = TextEditingController(text: existing?.subheading ?? '');
    _bodyCtrl = TextEditingController(text: existing?.body ?? '');
    _musicUrlCtrl = TextEditingController(text: existing?.musicUrl ?? '');
    _musicTitleCtrl = TextEditingController(text: existing?.musicTitle ?? '');
    _photoPaths = List.from(existing?.photoPaths ?? []);
    _voiceNotePaths = List.from(existing?.voiceNotePaths ?? []);
    _musicUrl = existing?.musicUrl;
    _musicTitle = existing?.musicTitle;
    _bodyFocus = FocusNode();

    for (final ctrl in [_headingCtrl, _subheadingCtrl, _bodyCtrl]) {
      ctrl.addListener(() => setState(() => _dirty = true));
    }

    // Auto-focus body for quick capture
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bodyFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _headingCtrl.dispose();
    _subheadingCtrl.dispose();
    _bodyCtrl.dispose();
    _musicUrlCtrl.dispose();
    _musicTitleCtrl.dispose();
    _bodyFocus.dispose();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  // ── Save ────────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    setState(() => _saving = true);
    final base = (_existingId != null
            ? ref.read(journalProvider.notifier).entryById(_existingId!)
            : null) ??
        JournalEntry.newEntry(_date);

    final updated = base.copyWith(
      heading: _headingCtrl.text.trim().isEmpty ? null : _headingCtrl.text.trim(),
      subheading: _subheadingCtrl.text.trim().isEmpty ? null : _subheadingCtrl.text.trim(),
      body: _bodyCtrl.text.trim().isEmpty ? null : _bodyCtrl.text.trim(),
      photoPaths: _photoPaths,
      voiceNotePaths: _voiceNotePaths,
      musicUrl: _musicUrl,
      musicTitle: _musicTitle,
      clearMusicUrl: _musicUrl == null,
      clearMusicTitle: _musicTitle == null,
    );

    await ref.read(journalProvider.notifier).save(updated);
    setState(() {
      _dirty = false;
      _saving = false;
    });
    if (mounted) context.pop();
  }

  // ── Photos ──────────────────────────────────────────────────────────────────

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final files = source == ImageSource.gallery
        ? await picker.pickMultiImage()
        : [if (await picker.pickImage(source: source) case final f?) f];

    if (files.isEmpty) return;

    final dir = await _journalDir('photos');
    final dateStr = JournalEntry.dateKey(_date);
    for (final xf in files) {
      final ext = xf.path.split('.').last;
      final dest = '${dir.path}/${dateStr}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      await File(xf.path).copy(dest);
      setState(() {
        _photoPaths.add(dest);
        _dirty = true;
      });
    }
  }

  void _removePhoto(String path) {
    setState(() {
      _photoPaths.remove(path);
      _dirty = true;
    });
    File(path).delete().catchError((_) {});
  }

  // ── Voice notes ─────────────────────────────────────────────────────────────

  Future<void> _startRecording() async {
    final dir = await _journalDir('voice');
    final path =
        '${dir.path}/${JournalEntry.dateKey(_date)}_${DateTime.now().millisecondsSinceEpoch}.m4a';

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      await _recorder.hasPermission(); // triggers system permission dialog
      return;
    }

    await _recorder.start(const RecordConfig(), path: path);
    setState(() {
      _isRecording = true;
      _currentRecordingPath = path;
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    if (path != null) {
      setState(() {
        _voiceNotePaths.add(path);
        _dirty = true;
      });
    }
    setState(() {
      _isRecording = false;
      _currentRecordingPath = null;
    });
  }

  Future<void> _togglePlayVoice(String path) async {
    if (_playingPath == path) {
      await _player.stop();
      setState(() => _playingPath = null);
    } else {
      await _player.stop();
      await _player.play(DeviceFileSource(path));
      setState(() => _playingPath = path);
      _player.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _playingPath = null);
      });
    }
  }

  void _removeVoiceNote(String path) {
    setState(() {
      _voiceNotePaths.remove(path);
      _dirty = true;
    });
    if (_playingPath == path) _player.stop();
    File(path).delete().catchError((_) {});
  }

  // ── Music ───────────────────────────────────────────────────────────────────

  void _showMusicDialog() {
    _musicUrlCtrl.text = _musicUrl ?? '';
    _musicTitleCtrl.text = _musicTitle ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add music',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ctx.colors.textPrimary)),
            const SizedBox(height: 16),
            _Field(
              controller: _musicTitleCtrl,
              label: 'Song name',
              hint: 'e.g. Midnight Rain',
              colors: ctx.colors,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _musicUrlCtrl,
              label: 'Link',
              hint: 'Paste Spotify, YouTube or Apple Music URL',
              colors: ctx.colors,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (_musicUrl != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _musicUrl = null;
                        _musicTitle = null;
                        _dirty = true;
                      });
                      Navigator.pop(ctx);
                    },
                    child: Text('Remove',
                        style: TextStyle(color: ctx.colors.textMuted)),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    final url = _musicUrlCtrl.text.trim();
                    final title = _musicTitleCtrl.text.trim();
                    setState(() {
                      _musicUrl = url.isEmpty ? null : url;
                      _musicTitle = title.isEmpty ? null : title;
                      _dirty = true;
                    });
                    Navigator.pop(ctx);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: ctx.colors.journal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Future<Directory> _journalDir(String sub) async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/journal/$sub');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  void _showPhotoSourceSheet() {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: c.journal),
                title:
                    Text('Choose from gallery', style: TextStyle(color: c.textPrimary)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickPhoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: c.journal),
                title: Text('Take a photo', style: TextStyle(color: c.textPrimary)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickPhoto(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.textSecondary),
          onPressed: () {
            if (_dirty) {
              _showDiscardDialog();
            } else {
              context.pop();
            }
          },
        ),
        title: Text(_formatDate(_date),
            style: TextStyle(
                fontSize: 15, color: c.textSecondary, fontWeight: FontWeight.w500)),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                  child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))),
            )
          else
            TextButton(
              onPressed: _save,
              child: Text('Save',
                  style: TextStyle(
                      color: c.journal,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading
              _Field(
                controller: _headingCtrl,
                label: null,
                hint: 'Heading (optional)',
                colors: c,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary),
                borderless: true,
              ),
              const SizedBox(height: 4),
              // Subheading
              _Field(
                controller: _subheadingCtrl,
                label: null,
                hint: 'Subheading (optional)',
                colors: c,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: c.textSecondary),
                borderless: true,
              ),
              Divider(color: c.border, height: 28),

              // Body
              _Field(
                controller: _bodyCtrl,
                focusNode: _bodyFocus,
                label: null,
                hint: 'Write anything... no limits, no judgement.',
                colors: c,
                minLines: 6,
                maxLines: null,
                style: TextStyle(
                    fontSize: 15, color: c.textPrimary, height: 1.6),
                borderless: true,
              ),

              const SizedBox(height: 24),

              // Media section
              Text('Media',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: c.textMuted,
                      letterSpacing: 0.8)),
              const SizedBox(height: 14),

              // Photos
              _PhotoStrip(
                paths: _photoPaths,
                onAdd: _showPhotoSourceSheet,
                onRemove: _removePhoto,
                accentColor: c.journal,
                colors: c,
              ),
              const SizedBox(height: 16),

              // Voice notes
              _VoiceSection(
                paths: _voiceNotePaths,
                isRecording: _isRecording,
                playingPath: _playingPath,
                onStartRecord: _startRecording,
                onStopRecord: _stopRecording,
                onTogglePlay: _togglePlayVoice,
                onRemove: _removeVoiceNote,
                accentColor: c.journal,
                colors: c,
              ),
              const SizedBox(height: 16),

              // Music link
              _MusicTile(
                musicTitle: _musicTitle,
                musicUrl: _musicUrl,
                onTap: _showMusicDialog,
                colors: c,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDiscardDialog() {
    final c = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Discard changes?',
            style: TextStyle(color: c.textPrimary)),
        content: Text('Your unsaved changes will be lost.',
            style: TextStyle(color: c.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Keep editing',
                style: TextStyle(color: c.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: Text('Discard',
                style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const days = [
      '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday',
      'Saturday', 'Sunday'
    ];
    return '${days[d.weekday]}, ${months[d.month]} ${d.day}';
  }
}

// ── Reusable text field ────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? label;
  final String hint;
  final ColorTokens colors;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final int? minLines;
  final int? maxLines;
  final bool borderless;

  const _Field({
    required this.controller,
    this.focusNode,
    required this.label,
    required this.hint,
    required this.colors,
    this.style,
    this.keyboardType,
    this.minLines,
    this.maxLines = 1,
    this.borderless = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!,
              style: TextStyle(
                  fontSize: 12,
                  color: c.textMuted,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          focusNode: focusNode,
          style: style ?? TextStyle(fontSize: 15, color: c.textPrimary),
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: c.textMuted),
            border: borderless ? InputBorder.none : OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: c.border),
            ),
            enabledBorder: borderless ? InputBorder.none : OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: c.border),
            ),
            focusedBorder: borderless ? InputBorder.none : OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: c.journal),
            ),
            filled: !borderless,
            fillColor: borderless ? null : c.surfaceElevated,
            contentPadding: borderless
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// ── Photo strip ────────────────────────────────────────────────────────────────

class _PhotoStrip extends StatelessWidget {
  final List<String> paths;
  final VoidCallback onAdd;
  final void Function(String) onRemove;
  final Color accentColor;
  final ColorTokens colors;

  const _PhotoStrip({
    required this.paths,
    required this.onAdd,
    required this.onRemove,
    required this.accentColor,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Add button
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: c.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: accentColor.withValues(alpha: 0.4),
                    style: BorderStyle.solid),
              ),
              child: Icon(Icons.add_photo_alternate_outlined,
                  color: accentColor, size: 28),
            ),
          ),
          // Photos
          ...paths.map((path) => _PhotoThumb(
                path: path,
                onRemove: () => onRemove(path),
                onTap: () => _openPhoto(context, path),
              )),
        ],
      ),
    );
  }

  void _openPhoto(BuildContext context, String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenPhoto(path: path),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  final String path;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _PhotoThumb(
      {required this.path, required this.onRemove, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: FileImage(File(path)),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          top: 2,
          right: 12,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                  color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _FullScreenPhoto extends StatelessWidget {
  final String path;
  const _FullScreenPhoto({required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(File(path)),
        ),
      ),
    );
  }
}

// ── Voice section ─────────────────────────────────────────────────────────────

class _VoiceSection extends StatelessWidget {
  final List<String> paths;
  final bool isRecording;
  final String? playingPath;
  final Future<void> Function() onStartRecord;
  final Future<void> Function() onStopRecord;
  final Future<void> Function(String) onTogglePlay;
  final void Function(String) onRemove;
  final Color accentColor;
  final ColorTokens colors;

  const _VoiceSection({
    required this.paths,
    required this.isRecording,
    required this.playingPath,
    required this.onStartRecord,
    required this.onStopRecord,
    required this.onTogglePlay,
    required this.onRemove,
    required this.accentColor,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Record button
        GestureDetector(
          onTap: isRecording ? onStopRecord : onStartRecord,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isRecording
                  ? Colors.redAccent.withValues(alpha: 0.12)
                  : c.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isRecording
                      ? Colors.redAccent.withValues(alpha: 0.5)
                      : accentColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  color: isRecording ? Colors.redAccent : accentColor,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  isRecording ? 'Tap to stop recording' : 'Record voice note',
                  style: TextStyle(
                      color: isRecording ? Colors.redAccent : accentColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14),
                ),
                if (isRecording) ...[
                  const SizedBox(width: 8),
                  _RecordingDot(),
                ],
              ],
            ),
          ),
        ),
        // Recorded notes list
        if (paths.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...paths.asMap().entries.map((entry) {
            final i = entry.key;
            final path = entry.value;
            final isPlaying = playingPath == path;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: c.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.border),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => onTogglePlay(path),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: accentColor,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Voice note ${i + 1}',
                          style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ),
                    GestureDetector(
                      onTap: () => onRemove(path),
                      child: Icon(Icons.delete_outline_rounded,
                          size: 18, color: c.textMuted),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _RecordingDot extends StatefulWidget {
  @override
  State<_RecordingDot> createState() => _RecordingDotState();
}

class _RecordingDotState extends State<_RecordingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
            color: Colors.redAccent, shape: BoxShape.circle),
      ),
    );
  }
}

// ── Music tile ─────────────────────────────────────────────────────────────────

class _MusicTile extends StatelessWidget {
  final String? musicTitle;
  final String? musicUrl;
  final VoidCallback onTap;
  final ColorTokens colors;

  const _MusicTile({
    required this.musicTitle,
    required this.musicUrl,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final hasMusic = musicUrl != null && musicUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: hasMusic ? c.journal.withValues(alpha: 0.08) : c.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: hasMusic
                  ? c.journal.withValues(alpha: 0.35)
                  : c.border),
        ),
        child: Row(
          children: [
            Icon(Icons.music_note_rounded,
                color: hasMusic ? c.journal : c.textMuted, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasMusic
                        ? (musicTitle ?? 'Music link')
                        : 'Add music',
                    style: TextStyle(
                        color: hasMusic ? c.textPrimary : c.textMuted,
                        fontWeight: FontWeight.w500,
                        fontSize: 14),
                  ),
                  if (hasMusic && musicUrl != null)
                    Text(musicUrl!,
                        style: TextStyle(
                            color: c.journal,
                            fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (hasMusic)
              GestureDetector(
                onTap: () async {
                  final uri = Uri.tryParse(musicUrl!);
                  const _allowedSchemes = {'https', 'http', 'spotify'};
                  if (uri != null &&
                      _allowedSchemes.contains(uri.scheme) &&
                      await canLaunchUrl(uri)) {
                    await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.open_in_new_rounded,
                      color: c.journal, size: 18),
                ),
              ),
            const SizedBox(width: 4),
            Icon(Icons.edit_outlined, color: c.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}
