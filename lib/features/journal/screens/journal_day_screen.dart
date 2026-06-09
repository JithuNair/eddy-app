import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/color_tokens.dart';
import '../models/journal_entry.dart';
import '../providers/journal_provider.dart';

class JournalDayScreen extends ConsumerWidget {
  final String dateKey; // 'YYYY-MM-DD'
  const JournalDayScreen({super.key, required this.dateKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateTime.parse(dateKey);
    final allEntries = ref.watch(journalProvider);
    final updatedEntries = allEntries
        .where((e) => JournalEntry.datePrefix(e.id) == dateKey)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.textSecondary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _formatDate(date),
          style: TextStyle(
              fontSize: 16,
              color: c.textPrimary,
              fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              updatedEntries.isEmpty
                  ? ''
                  : '${updatedEntries.length} note${updatedEntries.length == 1 ? '' : 's'}',
              style: TextStyle(fontSize: 13, color: c.textMuted),
            ),
          ),
        ],
      ),
      body: updatedEntries.isEmpty
          ? _emptyState(c)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: updatedEntries.length,
              itemBuilder: (context, i) =>
                  _NoteCard(entry: updatedEntries[i]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/journal/entry/new_$dateKey'),
        backgroundColor: c.journal,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _emptyState(ColorTokens c) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notes_rounded, size: 52, color: c.journal.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'Nothing here yet.',
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w600, color: c.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first note.',
            style: TextStyle(fontSize: 14, color: c.textMuted),
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

// ── Note card ─────────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  final JournalEntry entry;
  const _NoteCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasPhotos = entry.photoPaths.isNotEmpty;
    final hasVoice = entry.voiceNotePaths.isNotEmpty;
    final hasMusic = entry.musicUrl != null;
    final time = _formatTime(entry.createdAt);

    return GestureDetector(
      onTap: () => context.push('/journal/view/${entry.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time stamp
            Text(time,
                style: TextStyle(
                    fontSize: 11,
                    color: c.journal,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4)),
            if (entry.heading != null && entry.heading!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(entry.heading!,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
            if (entry.body != null && entry.body!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(entry.body!,
                  style: TextStyle(
                      fontSize: 14, color: c.textSecondary, height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
            ],
            if (entry.isEmpty) ...[
              const SizedBox(height: 4),
              Text('Empty note',
                  style: TextStyle(
                      fontSize: 13,
                      color: c.textMuted,
                      fontStyle: FontStyle.italic)),
            ],
            if (hasPhotos || hasVoice || hasMusic) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  if (hasPhotos)
                    _Chip(
                        icon: Icons.photo_library_outlined,
                        label:
                            '${entry.photoPaths.length} photo${entry.photoPaths.length > 1 ? 's' : ''}',
                        color: c.journal),
                  if (hasVoice)
                    _Chip(
                        icon: Icons.mic_none_rounded,
                        label:
                            '${entry.voiceNotePaths.length} voice${entry.voiceNotePaths.length > 1 ? 's' : ''}',
                        color: c.journal),
                  if (hasMusic)
                    _Chip(
                        icon: Icons.music_note_rounded,
                        label: entry.musicTitle ?? 'Music',
                        color: c.journal),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime d) {
    final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final m = d.minute.toString().padLeft(2, '0');
    final period = d.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
