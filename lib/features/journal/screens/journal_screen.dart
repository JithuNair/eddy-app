import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/providers/theme_provider.dart';
import '../models/journal_entry.dart';
import '../providers/journal_provider.dart';
import '../providers/journal_lock_provider.dart';
import '../providers/drive_backup_provider.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockEnabled = ref.watch(journalLockEnabledProvider);
    final unlocked = ref.watch(journalUnlockedProvider);

    if (lockEnabled && !unlocked) {
      return _LockGate(
        onUnlock: () => ref.read(journalUnlockedProvider.notifier).authenticate(),
      );
    }

    return const _JournalContent();
  }
}

// ── Lock gate ──────────────────────────────────────────────────────────────────

class _LockGate extends StatelessWidget {
  final Future<bool> Function() onUnlock;
  const _LockGate({required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline_rounded, size: 56, color: c.journal),
              const SizedBox(height: 20),
              Text('Journal is locked',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary)),
              const SizedBox(height: 8),
              Text('Use biometrics or PIN to open',
                  style: TextStyle(fontSize: 14, color: c.textMuted)),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onUnlock,
                icon: const Icon(Icons.fingerprint_rounded),
                label: const Text('Unlock'),
                style: FilledButton.styleFrom(
                  backgroundColor: c.journal,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Main journal content ───────────────────────────────────────────────────────

class _JournalContent extends ConsumerStatefulWidget {
  const _JournalContent();

  @override
  ConsumerState<_JournalContent> createState() => _JournalContentState();
}

class _JournalContentState extends ConsumerState<_JournalContent> {
  @override
  void initState() {
    super.initState();
    // Kick off a silent restore check on first open.
    // If the box is non-empty (normal use), this is a no-op.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(restoreProvider.notifier).checkAndRestore();
    });
  }

  Future<void> _pickPastDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Choose a date to journal',
      builder: (context, child) {
        final c = context.colors;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: c.journal,
              onPrimary: Colors.white,
              surface: c.surface,
              onSurface: c.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && context.mounted) {
      context.push('/journal/day/${JournalEntry.dateKey(picked)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // When restore finishes, reload journalProvider from the newly-populated Hive box
    ref.listen<RestoreStatus>(restoreProvider, (prev, next) {
      if (next == RestoreStatus.done) {
        ref.invalidate(journalProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Journal restored from your Google Drive backup.',
              style: TextStyle(color: context.colors.textPrimary),
            ),
            backgroundColor: context.colors.surface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final entries = ref.watch(journalProvider);
    final restoreStatus = ref.watch(restoreProvider);
    final driveStatus = ref.watch(driveBackupProvider);
    final c = context.colors;
    final today = DateTime.now();
    final todayKey = JournalEntry.dateKey(today);
    final todayCount = entries
        .where((e) => JournalEntry.datePrefix(e.id) == todayKey)
        .length;
    final hasToday = todayCount > 0;

    // Group entries by day (YYYY-MM-DD) — each day is one card in the timeline
    final byDay = <String, List<JournalEntry>>{};
    for (final e in entries) {
      final dk = JournalEntry.datePrefix(e.id);
      byDay.putIfAbsent(dk, () => []).add(e);
    }
    // Sort entries within each day newest-first
    for (final list in byDay.values) {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    // Sort days newest-first
    final sortedDays = byDay.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Group days by "Month YYYY"
    final grouped = <String, List<String>>{};
    for (final dk in sortedDays) {
      final d = DateTime.parse(dk);
      final mk = _monthKey(d);
      grouped.putIfAbsent(mk, () => []).add(dk);
    }
    final groupKeys = grouped.keys.toList();

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    Image.asset('assets/icons/nav/journal.png',
                        width: 28, height: 28),
                    const SizedBox(width: 10),
                    Text('eddy',
                        style: TextStyle(
                            color: c.journal,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3)),
                    const Spacer(),
                    _LockToggle(),
                    const SizedBox(width: 8),
                    _JournalThemeToggle(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Journal',
                        style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            color: c.textPrimary,
                            height: 1.1)),
                    const SizedBox(height: 6),
                    Text('Your private space. No judgement.',
                        style: TextStyle(fontSize: 15, color: c.textSecondary)),
                  ],
                ),
              ),
            ),

            // Restore in-progress banner
            if (restoreStatus == RestoreStatus.checking ||
                restoreStatus == RestoreStatus.restoring)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: c.journal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: c.journal.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: c.journal)),
                        const SizedBox(width: 10),
                        Text(
                          restoreStatus == RestoreStatus.checking
                              ? 'Looking for your backup…'
                              : 'Restoring your journal…',
                          style:
                              TextStyle(color: c.journal, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Restore from backup button (shown when journal is empty but
            // Drive is connected — covers stale-token case after reinstall)
            if (entries.isEmpty &&
                restoreStatus != RestoreStatus.checking &&
                restoreStatus != RestoreStatus.restoring &&
                (restoreStatus == RestoreStatus.needsAuth ||
                 (driveStatus == DriveSignInStatus.signedIn &&
                  restoreStatus == RestoreStatus.idle)))
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: GestureDetector(
                    onTap: () => ref
                        .read(restoreProvider.notifier)
                        .restoreWithSignIn(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: c.journal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: c.journal.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.cloud_download_outlined,
                              size: 16, color: c.journal),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Restore from Drive backup',
                              style: TextStyle(
                                  color: c.journal,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              size: 16, color: c.journal),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Drive backup status chip (shown when not signed in)
            if (driveStatus == DriveSignInStatus.signedOut)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: GestureDetector(
                    onTap: () async {
                      final ok = await ref
                          .read(driveBackupProvider.notifier)
                          .signIn();
                      if (!ok || !mounted) return;
                      final currentEntries = ref.read(journalProvider);
                      if (currentEntries.isEmpty) {
                        // Journal is empty — check if there's a backup to restore
                        ref.read(restoreProvider.notifier).restoreWithSignIn();
                      } else {
                        // Journal has data — back it up
                        ref
                            .read(driveBackupServiceProvider)
                            .backupAll(currentEntries);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Drive backup active — your journal is safe.',
                                style: TextStyle(color: c.textPrimary),
                              ),
                              backgroundColor: c.surface,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: c.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: c.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.cloud_off_rounded,
                              size: 16, color: c.textMuted),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tap to enable Google Drive backup',
                              style: TextStyle(
                                  color: c.textSecondary, fontSize: 13),
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              size: 16, color: c.textMuted),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Today + Past date row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
                child: Row(
                  children: [
                    Expanded(child: _TodayCta(count: todayCount)),
                    const SizedBox(width: 10),
                    _PastDateButton(onTap: () => _pickPastDate(context)),
                  ],
                ),
              ),
            ),

            // Empty state
            if (entries.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_stories_outlined,
                            size: 48, color: c.journal.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        Text(
                          'Your timeline starts here.',
                          style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Write today — or log a memory\nfrom any date in the past.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: c.textMuted, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else ...[
              // Timeline grouped by month, one card per day
              for (final monthKey in groupKeys) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: c.journal,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(monthKey,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: c.journal,
                                letterSpacing: 0.6)),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList.separated(
                    itemCount: grouped[monthKey]!.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final dk = grouped[monthKey]![i];
                      return _DayCard(
                        dateKey: dk,
                        entries: byDay[dk]!,
                      );
                    },
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ],
        ),
      ),
    );
  }

  String _monthKey(DateTime d) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[d.month]} ${d.year}';
  }
}

// ── Theme toggle (Journal-hosted) ─────────────────────────────────────────────

class _JournalThemeToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider.notifier).isDark;
    final asset = isDark
        ? 'assets/icons/theme/dark_mode_owl.png'
        : 'assets/icons/theme/light_mode_eagle.png';
    final c = context.colors;
    return GestureDetector(
      onTap: () => ref.read(themeModeProvider.notifier).toggle(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: c.surface,
          shape: BoxShape.circle,
          border: Border.all(color: c.border),
        ),
        child: ClipOval(
          child: Image.asset(asset, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

// ── Lock toggle chip ───────────────────────────────────────────────────────────

class _LockToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(journalLockEnabledProvider);
    final c = context.colors;
    return GestureDetector(
      onTap: () async {
        if (!enabled) {
          // Verify biometrics before enabling lock
          final ok =
              await ref.read(journalUnlockedProvider.notifier).authenticate();
          if (ok) {
            ref.read(journalLockEnabledProvider.notifier).setEnabled(true);
          }
        } else {
          ref.read(journalLockEnabledProvider.notifier).setEnabled(false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: enabled
              ? c.journal.withValues(alpha: 0.15)
              : c.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: enabled ? c.journal.withValues(alpha: 0.4) : c.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
                enabled
                    ? Icons.lock_rounded
                    : Icons.lock_open_rounded,
                size: 14,
                color: enabled ? c.journal : c.textMuted),
            const SizedBox(width: 5),
            Text(enabled ? 'Locked' : 'Unlocked',
                style: TextStyle(
                    fontSize: 12,
                    color: enabled ? c.journal : c.textMuted,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Past date button ──────────────────────────────────────────────────────────

class _PastDateButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PastDateButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month_outlined, color: c.journal, size: 22),
            const SizedBox(height: 4),
            Text('Past date',
                style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Today CTA ─────────────────────────────────────────────────────────────────

class _TodayCta extends StatelessWidget {
  final int count;
  const _TodayCta({required this.count});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final today = DateTime.now();
    final hasEntry = count > 0;
    return GestureDetector(
      onTap: () => context.push('/journal/day/${JournalEntry.dateKey(today)}'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: c.journalSubtle,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: c.journal.withValues(alpha: hasEntry ? 0.35 : 0.6),
              width: hasEntry ? 1 : 1.5),
        ),
        child: Row(
          children: [
            Icon(
              hasEntry ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
              color: c.journal,
              size: 26,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasEntry
                        ? 'Today · $count note${count == 1 ? '' : 's'}'
                        : 'Write today\'s entry',
                    style: TextStyle(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatToday(today),
                    style: TextStyle(color: c.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: c.journal.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }

  String _formatToday(DateTime d) {
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

// ── Day card (timeline) ───────────────────────────────────────────────────────

class _DayCard extends StatelessWidget {
  final String dateKey;
  final List<JournalEntry> entries; // already sorted newest-first

  const _DayCard({required this.dateKey, required this.entries});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final date = DateTime.parse(dateKey);
    final count = entries.length;
    final top = entries.first;

    // Aggregate attachments across all notes for this day
    int totalPhotos = 0;
    int totalVoice = 0;
    bool hasMusic = false;
    for (final e in entries) {
      totalPhotos += e.photoPaths.length;
      totalVoice += e.voiceNotePaths.length;
      if (e.musicUrl != null) hasMusic = true;
    }

    return GestureDetector(
      onTap: () => context.push('/journal/day/$dateKey'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date + note count badge
            Row(
              children: [
                Text(_formatDate(date),
                    style: TextStyle(
                        fontSize: 12,
                        color: c.journal,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4)),
                const Spacer(),
                if (count > 1)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: c.journal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$count notes',
                        style: TextStyle(
                            fontSize: 11,
                            color: c.journal,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            // Top note preview
            if (top.heading != null && top.heading!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(top.heading!,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
            if (top.body != null && top.body!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(top.body!,
                  style: TextStyle(
                      fontSize: 14, color: c.textSecondary, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
            // Aggregated attachment chips
            if (totalPhotos > 0 || totalVoice > 0 || hasMusic) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  if (totalPhotos > 0)
                    _AttachChip(
                        icon: Icons.photo_library_outlined,
                        label:
                            '$totalPhotos photo${totalPhotos > 1 ? 's' : ''}',
                        color: c.journal),
                  if (totalVoice > 0)
                    _AttachChip(
                        icon: Icons.mic_none_rounded,
                        label:
                            '$totalVoice voice${totalVoice > 1 ? 's' : ''}',
                        color: c.journal),
                  if (hasMusic)
                    _AttachChip(
                        icon: Icons.music_note_rounded,
                        label: 'Music',
                        color: c.journal),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month]} ${d.day}, ${d.year}';
  }
}

class _AttachChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _AttachChip(
      {required this.icon, required this.label, required this.color});

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
          Icon(icon, size: 12, color: color),
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
