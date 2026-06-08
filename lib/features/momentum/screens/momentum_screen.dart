import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/eddy_theme.dart';
import '../../../core/widgets/eddy_scaffold.dart';
import '../../../core/widgets/eddy_header.dart';
import '../models/habit.dart';
import '../providers/momentum_provider.dart';

class MomentumScreen extends ConsumerWidget {
  const MomentumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(momentumProvider);
    final c = context.colors;

    return EddyScaffold(
      accentColor: c.momentum,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EddyHeader(
              title: 'Momentum',
              subtitle: 'Never miss two days in a row.',
              accentColor: c.momentum,
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.04, end: 0),
            const SizedBox(height: 8),
            Expanded(
              child: habits.isEmpty
                  ? _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      itemCount: habits.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _HabitCard(
                        habit: habits[i],
                        ref: ref,
                      ).animate().fadeIn(
                          delay: Duration(milliseconds: 60 * i),
                          duration: 350.ms),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _AddButton(ref: ref),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final Habit habit;
  final WidgetRef ref;

  const _HabitCard({required this.habit, required this.ref});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isLastChance = habit.isLastChance;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: EddyRadius.card,
        border: Border.all(
          color: isLastChance
              ? c.momentum.withValues(alpha: 0.4)
              : c.border.withValues(alpha: 0.6),
          width: 0.5,
        ),
        gradient: isLastChance
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [c.momentum.withValues(alpha: 0.06), c.surface],
              )
            : null,
        boxShadow: EddyGlow.card(c),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(habit.name,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              if (isLastChance) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: c.momentumSubtle,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: c.momentum.withValues(alpha: 0.2), width: 0.5),
                  ),
                  child: Text('do it today',
                      style: EddyText.tag(c.momentum)),
                ),
                const SizedBox(width: 8),
              ],
              GestureDetector(
                onTap: () => _showOptions(context),
                child: Icon(Icons.more_horiz, color: c.textMuted, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _WeekRow(habit: habit, ref: ref),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _HabitOptions(habit: habit, ref: ref),
    );
  }
}

class _WeekRow extends StatelessWidget {
  final Habit habit;
  final WidgetRef ref;

  const _WeekRow({required this.habit, required this.ref});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final today = DateTime.now();
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = days[i];
        final isToday = i == 6;
        final done = habit.isDoneOn(day);

        return GestureDetector(
          onTap: isToday
              ? () => ref.read(momentumProvider.notifier).toggleToday(habit.id)
              : null,
          child: Column(
            children: [
              Text(dayLabels[day.weekday - 1],
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isToday ? c.textSecondary : c.textMuted,
                        fontSize: 10,
                      )),
              const SizedBox(height: 6),
              _DayDot(done: done, isToday: isToday, colors: c),
            ],
          ),
        );
      }),
    );
  }
}

class _DayDot extends StatelessWidget {
  final bool done;
  final bool isToday;
  final ColorTokens colors;

  const _DayDot(
      {required this.done, required this.isToday, required this.colors});

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? c.momentum : Colors.transparent,
        border: Border.all(
          color: done
              ? c.momentum
              : isToday
                  ? c.textSecondary
                  : c.border,
          width: isToday && !done ? 1.5 : 1,
        ),
      ),
      child: done
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : null,
    );
  }
}

class _HabitOptions extends StatefulWidget {
  final Habit habit;
  final WidgetRef ref;

  const _HabitOptions({required this.habit, required this.ref});

  @override
  State<_HabitOptions> createState() => _HabitOptionsState();
}

class _HabitOptionsState extends State<_HabitOptions> {
  bool _renaming = false;
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.habit.name);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.habit.name,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 20),
          if (_renaming) ...[
            TextField(
              controller: _ctrl,
              autofocus: true,
              style: TextStyle(color: c.textPrimary),
              decoration: InputDecoration(
                hintText: 'Habit name',
                hintStyle: TextStyle(color: c.textMuted, fontSize: 14),
                filled: true,
                fillColor: c.surfaceElevated,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.momentum, width: 1.5)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              onSubmitted: (_) => _saveRename(context),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveRename(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.momentum,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: const Text('Save',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ] else ...[
            _OptionTile(
              icon: Icons.edit_outlined,
              label: 'Rename',
              color: c.textSecondary,
              onTap: () => setState(() => _renaming = true),
            ),
            const SizedBox(height: 4),
            _OptionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Delete habit',
              color: Colors.redAccent,
              onTap: () {
                Navigator.pop(context);
                widget.ref
                    .read(momentumProvider.notifier)
                    .deleteHabit(widget.habit.id);
              },
            ),
          ],
        ],
      ),
    );
  }

  void _saveRename(BuildContext context) {
    final name = _ctrl.text.trim();
    if (name.isNotEmpty) {
      widget.ref
          .read(momentumProvider.notifier)
          .renameHabit(widget.habit.id, name);
    }
    Navigator.pop(context);
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _OptionTile(
      {required this.icon,
      required this.label,
      required this.onTap,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Add your first habit below.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: context.colors.textMuted)),
    );
  }
}

class _AddButton extends StatelessWidget {
  final WidgetRef ref;

  const _AddButton({required this.ref});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: () => _showAddSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: c.momentum,
          borderRadius: BorderRadius.circular(32),
          boxShadow: EddyGlow.accent(c.momentum, intensity: 0.2),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Add habit',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddHabitSheet(ref: ref),
    );
  }
}

class _AddHabitSheet extends StatefulWidget {
  final WidgetRef ref;

  const _AddHabitSheet({required this.ref});

  @override
  State<_AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<_AddHabitSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New habit', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            autofocus: true,
            style: TextStyle(color: c.textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g. Read for 20 mins',
              hintStyle: TextStyle(color: c.textMuted, fontSize: 14),
              filled: true,
              fillColor: c.surfaceElevated,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: c.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: c.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: c.momentum, width: 1.5)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            onSubmitted: (_) => _add(context),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _add(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.momentum,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              child: const Text('Add',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _add(BuildContext context) {
    final name = _ctrl.text.trim();
    if (name.isNotEmpty) {
      widget.ref.read(momentumProvider.notifier).addHabit(name);
    }
    Navigator.pop(context);
  }
}
