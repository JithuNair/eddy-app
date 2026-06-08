import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/eddy_theme.dart';
import '../../../core/widgets/eddy_scaffold.dart';
import '../models/habit.dart';
import '../providers/momentum_provider.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

int _daysInMonth(int year, int month) =>
    DateTime(year, month + 1, 0).day;

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

const _monthAbbr = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatLastCompleted(String dateKey) {
  final today    = Habit.dateKey(DateTime.now());
  final yesterday = Habit.dateKey(
      DateTime.now().subtract(const Duration(days: 1)));
  if (dateKey == today)     return 'Today';
  if (dateKey == yesterday) return 'Yesterday';
  final parts = dateKey.split('-');
  if (parts.length == 3) {
    final m = int.tryParse(parts[1]) ?? 1;
    final d = int.tryParse(parts[2]) ?? 1;
    return '${_monthAbbr[m - 1]} $d';
  }
  return dateKey;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class MomentumTrackerScreen extends ConsumerStatefulWidget {
  const MomentumTrackerScreen({super.key});

  @override
  ConsumerState<MomentumTrackerScreen> createState() =>
      _MomentumTrackerScreenState();
}

class _MomentumTrackerScreenState
    extends ConsumerState<MomentumTrackerScreen> {
  late DateTime _viewMonth;
  String? _selectedHabitId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _viewMonth = DateTime(now.year, now.month);
  }

  bool get _canGoNext {
    final now = DateTime.now();
    return _viewMonth.year < now.year ||
        (_viewMonth.year == now.year && _viewMonth.month < now.month);
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(momentumProvider);
    final c = context.colors;

    // Resolve selected habit
    if (habits.isNotEmpty &&
        (_selectedHabitId == null ||
            !habits.any((h) => h.id == _selectedHabitId))) {
      _selectedHabitId = habits.first.id;
    }
    final Habit? habit = habits.isEmpty
        ? null
        : habits.firstWhere(
            (h) => h.id == _selectedHabitId,
            orElse: () => habits.first,
          );

    return EddyScaffold(
      accentColor: c.momentum,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back row
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
              child: IconButton(
                onPressed: () => context.go('/momentum'),
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: c.textSecondary),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 2, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Momentum Tracker',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text('A gentle look back. No streaks, no shame.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: c.textMuted)),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.04, end: 0),
            const SizedBox(height: 20),
            // Scrollable body
            Expanded(
              child: habit == null
                  ? _buildNoHabits(c)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
                      children: [
                        // Habit selector (only when >1 habit)
                        if (habits.length > 1) ...[
                          _HabitChips(
                            habits: habits,
                            selectedId: _selectedHabitId!,
                            accentColor: c.momentum,
                            colors: c,
                            onSelect: (id) =>
                                setState(() => _selectedHabitId = id),
                          ),
                          const SizedBox(height: 20),
                        ],
                        // Month navigation
                        _MonthNav(
                          viewMonth: _viewMonth,
                          colors: c,
                          canGoNext: _canGoNext,
                          onPrev: () => setState(() {
                            _viewMonth = DateTime(
                                _viewMonth.year, _viewMonth.month - 1);
                          }),
                          onNext: _canGoNext
                              ? () => setState(() {
                                    _viewMonth = DateTime(
                                        _viewMonth.year, _viewMonth.month + 1);
                                  })
                              : null,
                        ),
                        const SizedBox(height: 12),
                        // Calendar
                        _CalendarGrid(
                          viewMonth: _viewMonth,
                          habit: habit,
                          accentColor: c.momentum,
                          colors: c,
                        )
                            .animate()
                            .fadeIn(delay: 60.ms, duration: 350.ms),
                        const SizedBox(height: 24),
                        // Summary card
                        _SummaryCard(
                          habit: habit,
                          viewMonth: _viewMonth,
                          accentColor: c.momentum,
                          colors: c,
                        )
                            .animate()
                            .fadeIn(delay: 120.ms, duration: 350.ms),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoHabits(ColorTokens c) {
    return Center(
      child: Text(
        'Add a habit on the Momentum screen\nto start tracking.',
        textAlign: TextAlign.center,
        style: TextStyle(color: c.textMuted, height: 1.6),
      ),
    );
  }
}

// ── Habit selector chips ──────────────────────────────────────────────────────

class _HabitChips extends StatelessWidget {
  final List<Habit> habits;
  final String selectedId;
  final Color accentColor;
  final ColorTokens colors;
  final ValueChanged<String> onSelect;

  const _HabitChips({
    required this.habits,
    required this.selectedId,
    required this.accentColor,
    required this.colors,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: habits.map((h) {
          final sel = h.id == selectedId;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(h.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: sel ? accentColor : c.surface,
                  borderRadius: EddyRadius.chip,
                  border: Border.all(
                      color: sel ? accentColor : c.border, width: 0.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  h.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: sel ? Colors.white : c.textSecondary,
                        fontWeight:
                            sel ? FontWeight.w600 : FontWeight.normal,
                      ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Month navigation row ──────────────────────────────────────────────────────

class _MonthNav extends StatelessWidget {
  final DateTime viewMonth;
  final ColorTokens colors;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback? onNext;

  const _MonthNav({
    required this.viewMonth,
    required this.colors,
    required this.canGoNext,
    required this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final label =
        '${_monthNames[viewMonth.month - 1]} ${viewMonth.year}';
    return Row(
      children: [
        _NavArrow(
          icon: Icons.chevron_left_rounded,
          color: c.textSecondary,
          onTap: onPrev,
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        _NavArrow(
          icon: Icons.chevron_right_rounded,
          color: canGoNext ? c.textSecondary : c.border,
          onTap: onNext,
        ),
      ],
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _NavArrow(
      {required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

// ── Calendar grid ─────────────────────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  final DateTime viewMonth;
  final Habit habit;
  final Color accentColor;
  final ColorTokens colors;

  const _CalendarGrid({
    required this.viewMonth,
    required this.habit,
    required this.accentColor,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final today = DateTime.now();
    final todayNorm =
        DateTime(today.year, today.month, today.day);
    final days = _daysInMonth(viewMonth.year, viewMonth.month);

    // Mon-based offset: Mon=0 … Sun=6
    final startOffset =
        (DateTime(viewMonth.year, viewMonth.month, 1).weekday - 1) % 7;

    // Build flat cell list: null = padding, int = day number
    final cells = <int?>[
      ...List<int?>.filled(startOffset, null),
      for (int d = 1; d <= days; d++) d,
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    const headers = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      children: [
        // Day-of-week headers
        Row(
          children: headers
              .map((l) => Expanded(
                    child: Text(
                      l,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: c.textMuted,
                            letterSpacing: 1,
                          ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        // Week rows
        for (int row = 0; row < cells.length ~/ 7; row++) ...[
          Row(
            children: List.generate(7, (col) {
              final dayNum = cells[row * 7 + col];
              if (dayNum == null) {
                return const Expanded(child: SizedBox(height: 38));
              }
              final date = DateTime(
                  viewMonth.year, viewMonth.month, dayNum);
              final isFuture = date.isAfter(todayNorm);
              final isToday = date == todayNorm;
              final isDone = habit.isDoneOn(date);

              return Expanded(
                child: _DayCell(
                  day: dayNum,
                  isDone: isDone,
                  isToday: isToday,
                  isFuture: isFuture,
                  accentColor: accentColor,
                  colors: c,
                ),
              );
            }),
          ),
          if (row < cells.length ~/ 7 - 1)
            const SizedBox(height: 4),
        ],
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isDone;
  final bool isToday;
  final bool isFuture;
  final Color accentColor;
  final ColorTokens colors;

  const _DayCell({
    required this.day,
    required this.isDone,
    required this.isToday,
    required this.isFuture,
    required this.accentColor,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;

    final Color bg;
    final Color text;
    final Border? border;

    if (isDone) {
      bg = accentColor;
      text = Colors.white;
      border = null;
    } else if (isToday) {
      bg = Colors.transparent;
      text = c.textSecondary;
      border =
          Border.all(color: accentColor.withValues(alpha: 0.55), width: 1.5);
    } else if (isFuture) {
      bg = Colors.transparent;
      text = c.textMuted.withValues(alpha: 0.25);
      border = null;
    } else {
      // Past, not completed — show softly, no shame mark
      bg = Colors.transparent;
      text = c.textMuted.withValues(alpha: 0.45);
      border = null;
    }

    return SizedBox(
      height: 38,
      child: Center(
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: border,
          ),
          alignment: Alignment.center,
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  isDone ? FontWeight.w600 : FontWeight.normal,
              color: text,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Summary card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final Habit habit;
  final DateTime viewMonth;
  final Color accentColor;
  final ColorTokens colors;

  const _SummaryCard({
    required this.habit,
    required this.viewMonth,
    required this.accentColor,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final now = DateTime.now();
    final isCurrentMonth =
        viewMonth.year == now.year && viewMonth.month == now.month;
    final days = _daysInMonth(viewMonth.year, viewMonth.month);

    // Count completions this month
    int completedCount = 0;
    for (int d = 1; d <= days; d++) {
      if (habit.isDoneOn(DateTime(viewMonth.year, viewMonth.month, d))) {
        completedCount++;
      }
    }

    // Last completed (across all history)
    final String lastLabel;
    if (habit.completedDates.isEmpty) {
      lastLabel = 'Never';
    } else {
      final sorted = List<String>.from(habit.completedDates)..sort();
      lastLabel = _formatLastCompleted(sorted.last);
    }

    // Gentle signal — only for current month
    final String? gentleSignal = isCurrentMonth
        ? _buildGentleSignal(habit, now)
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: EddyRadius.card,
        border: Border.all(
            color: c.border.withValues(alpha: 0.6), width: 0.5),
        boxShadow: EddyGlow.card(c),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          Row(
            children: [
              _Stat(
                label: isCurrentMonth ? 'This month' : 'That month',
                value:
                    '$completedCount day${completedCount == 1 ? '' : 's'}',
                accentColor: accentColor,
                colors: c,
              ),
              const SizedBox(width: 32),
              _Stat(
                label: 'Last completed',
                value: lastLabel,
                accentColor: accentColor,
                colors: c,
              ),
            ],
          ),
          // Gentle signal
          if (gentleSignal != null) ...[
            const SizedBox(height: 14),
            Divider(
                color: c.border.withValues(alpha: 0.4), height: 1),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    gentleSignal,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: c.textSecondary),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _buildGentleSignal(Habit habit, DateTime now) {
    final doneToday = habit.isDoneOn(now);
    final doneYesterday =
        habit.isDoneOn(now.subtract(const Duration(days: 1)));
    if (doneToday) return 'You showed up today.';
    if (!doneToday && !doneYesterday) {
      return 'Two days off — come back today.';
    }
    return 'No two missed days in a row.';
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;
  final ColorTokens colors;

  const _Stat({
    required this.label,
    required this.value,
    required this.accentColor,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: c.textMuted,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
