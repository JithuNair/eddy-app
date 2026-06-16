import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/widgets/eddy_scaffold.dart';
import '../../../core/widgets/eddy_header.dart';
import '../../../core/widgets/eddy_section_label.dart';
import '../providers/focus_timer_provider.dart';
import '../providers/sound_provider.dart';
import '../models/sound_option.dart';
import '../widgets/sound_picker.dart';

const List<int> _durations = [20, 25, 30, 45, 60];

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final timer = ref.watch(focusTimerProvider);
    final timerNotifier = ref.read(focusTimerProvider.notifier);
    final soundNotifier = ref.read(soundProvider.notifier);
    final sound = ref.watch(soundProvider);

    return EddyScaffold(
      accentColor: c.focus,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EddyHeader(
                title: 'Focus',
                subtitle: 'Set your intention. Start. The rest follows.',
                accentColor: c.focus,
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EddySectionLabel('DURATION'),
                    const SizedBox(height: 12),
                    Row(
                      children: _durations
                          .map((m) => Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: _DurationChip(
                                  minutes: m,
                                  selected: timer.durationMinutes == m,
                                  colors: c,
                                  onTap: () => timerNotifier.setDuration(m),
                                ),
                              ))
                          .toList(),
                    ),

                    const SizedBox(height: 32),

                    const SoundPicker(),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          timerNotifier.start();
                          if (sound.selected.source != SoundSource.none) {
                            soundNotifier.play();
                          }
                          context.go('/focus/session');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.focus,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('Start Session',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                )),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  final int minutes;
  final bool selected;
  final ColorTokens colors;
  final VoidCallback onTap;

  const _DurationChip({
    required this.minutes,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 52,
        height: 44,
        decoration: BoxDecoration(
          color: selected ? c.focusSubtle : c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? c.focus : c.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text('$minutes',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: selected ? c.focus : c.textSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                  )),
        ),
      ),
    );
  }
}
