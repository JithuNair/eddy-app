import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/color_tokens.dart';
import '../models/journal_entry.dart';
import '../providers/journal_provider.dart';

class JournalViewScreen extends ConsumerStatefulWidget {
  final String entryId;
  const JournalViewScreen({super.key, required this.entryId});

  @override
  ConsumerState<JournalViewScreen> createState() => _JournalViewScreenState();
}

class _JournalViewScreenState extends ConsumerState<JournalViewScreen> {
  final _player = AudioPlayer();
  String? _playingPath;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay(String path) async {
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

  Future<void> _confirmDelete(JournalEntry entry) async {
    final c = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Delete this entry?',
            style: TextStyle(color: c.textPrimary)),
        content: Text(
            'This entry and all its photos and voice notes will be permanently deleted.',
            style: TextStyle(color: c.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                Text('Keep it', style: TextStyle(color: c.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(journalProvider.notifier).delete(entry);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(journalProvider);
    final entry = entries.where((e) => e.id == widget.entryId).firstOrNull;
    final c = context.colors;

    if (entry == null) {
      return Scaffold(
        backgroundColor: c.background,
        appBar: AppBar(backgroundColor: c.background, elevation: 0),
        body: Center(
            child: Text('Entry not found',
                style: TextStyle(color: c.textMuted))),
      );
    }

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.textSecondary),
          onPressed: () => context.pop(),
        ),
        title: Text(_formatDate(entry.date),
            style: TextStyle(
                fontSize: 15,
                color: c.textSecondary,
                fontWeight: FontWeight.w500)),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: c.journal),
            onPressed: () =>
                context.push('/journal/entry/${entry.id}'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: Colors.redAccent),
            onPressed: () => _confirmDelete(entry),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.heading != null && entry.heading!.isNotEmpty) ...[
              Text(entry.heading!,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                      height: 1.2)),
              const SizedBox(height: 6),
            ],
            if (entry.subheading != null &&
                entry.subheading!.isNotEmpty) ...[
              Text(entry.subheading!,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: c.textSecondary)),
              const SizedBox(height: 12),
            ],
            if (entry.heading != null || entry.subheading != null)
              Divider(color: c.border, height: 24),
            if (entry.body != null && entry.body!.isNotEmpty) ...[
              Text(entry.body!,
                  style: TextStyle(
                      fontSize: 15,
                      color: c.textPrimary,
                      height: 1.7)),
              const SizedBox(height: 28),
            ],

            // Photos
            if (entry.photoPaths.isNotEmpty) ...[
              _SectionLabel('Photos', c),
              const SizedBox(height: 10),
              _PhotoGrid(paths: entry.photoPaths),
              const SizedBox(height: 24),
            ],

            // Voice notes
            if (entry.voiceNotePaths.isNotEmpty) ...[
              _SectionLabel('Voice notes', c),
              const SizedBox(height: 10),
              ...entry.voiceNotePaths.asMap().entries.map((e) {
                final path = e.value;
                final i = e.key;
                final isPlaying = _playingPath == path;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => _togglePlay(path),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: c.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: c.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: c.journal.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: c.journal,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text('Voice note ${i + 1}',
                              style: TextStyle(
                                  color: c.textPrimary,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            // Music
            if (entry.musicUrl != null) ...[
              _SectionLabel('Music', c),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  final uri = Uri.tryParse(entry.musicUrl!);
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: c.journal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: c.journal.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.music_note_rounded,
                          color: c.journal, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.musicTitle ?? 'Music',
                                style: TextStyle(
                                    color: c.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                            Text(entry.musicUrl!,
                                style: TextStyle(
                                    color: c.journal, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Icon(Icons.open_in_new_rounded,
                          color: c.journal, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
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

class _SectionLabel extends StatelessWidget {
  final String text;
  final ColorTokens c;
  const _SectionLabel(this.text, this.c);

  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: c.textMuted,
          letterSpacing: 0.8));
}

class _PhotoGrid extends StatelessWidget {
  final List<String> paths;
  const _PhotoGrid({required this.paths});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: paths
          .map((path) => GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      backgroundColor: Colors.black,
                      appBar: AppBar(
                        backgroundColor: Colors.transparent,
                        iconTheme:
                            const IconThemeData(color: Colors.white),
                      ),
                      body: Center(
                        child: InteractiveViewer(
                          child: Image.file(File(path)),
                        ),
                      ),
                    ),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(File(path), fit: BoxFit.cover),
                ),
              ))
          .toList(),
    );
  }
}
