import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/eddy_theme.dart';
import '../../../core/widgets/eddy_scaffold.dart';
import '../../../core/widgets/eddy_progress_ring.dart';
import '../providers/focus_timer_provider.dart';
import '../providers/sound_provider.dart';
import '../models/sound_option.dart';

class FocusTimerScreen extends ConsumerWidget {
  const FocusTimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(focusTimerProvider);
    final sound = ref.watch(soundProvider);
    final c = context.colors;

    if (timer.phase == FocusPhase.done) {
      return _DoneView(intention: timer.intention, ref: ref);
    }

    return EddyScaffold(
      accentColor: c.focus,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _easeOut(context, ref),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: c.border),
                      ),
                      child: Text('Ease out',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: c.textSecondary)),
                    ),
                  ),
                  const Spacer(),
                  if (timer.intention.isNotEmpty)
                    Flexible(
                      child: Text(timer.intention,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: c.textMuted,
                                fontStyle: FontStyle.italic,
                              ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right),
                    ),
                ],
              ),

              const Spacer(),

              EddyProgressRing(
                progress: timer.progress,
                color: c.focus,
                trackColor: c.surface,
                size: 260,
                strokeWidth: 3.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(timer.remainingLabel,
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(
                              fontSize: 52,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 2,
                              color: c.textPrimary,
                            )),
                    const SizedBox(height: 4),
                    Text('remaining',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: c.textMuted,
                              letterSpacing: 1,
                            )),
                  ],
                ),
              ),

              const Spacer(),

              _SoundControl(sound: sound, ref: ref),
            ],
          ),
        ),
      ),
    );
  }

  void _easeOut(BuildContext context, WidgetRef ref) {
    ref.read(focusTimerProvider.notifier).stop();
    ref.read(soundProvider.notifier).stop();
    context.go('/focus');
  }
}

class _SoundControl extends StatelessWidget {
  final SoundState sound;
  final WidgetRef ref;

  const _SoundControl({required this.sound, required this.ref});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final notifier = ref.read(soundProvider.notifier);
    final hasSound = sound.selected.source != SoundSource.none;

    if (!hasSound) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(sound.selected.emoji,
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  sound.isLoading
                      ? 'Loading...'
                      : sound.isPlaying
                          ? sound.selected.label
                          : 'Paused',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: sound.isPlaying ? c.textSecondary : c.textMuted,
                      ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (sound.isPlaying) {
                    notifier.stop();
                  } else {
                    notifier.play();
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c.focusSubtle,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    sound.isLoading
                        ? Icons.hourglass_empty_rounded
                        : sound.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                    color: c.focus,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.volume_down_rounded, size: 16, color: c.textMuted),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: c.focus,
                    inactiveTrackColor: c.border,
                    thumbColor: c.focus,
                    overlayColor: c.focus.withValues(alpha: 0.1),
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    trackHeight: 2,
                  ),
                  child: Slider(
                    value: sound.volume,
                    min: 0,
                    max: 1,
                    onChanged: notifier.setVolume,
                  ),
                ),
              ),
              Icon(Icons.volume_up_rounded, size: 16, color: c.textMuted),
            ],
          ),
          if (sound.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(sound.error!,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.redAccent)),
            ),
        ],
      ),
    );
  }
}

class _DoneView extends StatelessWidget {
  final String intention;
  final WidgetRef ref;

  const _DoneView({required this.intention, required this.ref});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return EddyScaffold(
      accentColor: c.focus,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: c.focusSubtle,
                  shape: BoxShape.circle,
                  boxShadow: EddyGlow.accent(c.focus, intensity: 0.1),
                ),
                child: Icon(Icons.check_rounded, color: c.focus, size: 44),
              ),
              const SizedBox(height: 32),
              Text('Session complete.',
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              if (intention.isNotEmpty)
                Text('"$intention"',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: c.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                    textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('That\'s real work. Take a breath.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: c.textMuted),
                  textAlign: TextAlign.center),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(soundProvider.notifier).stop();
                        ref.read(focusTimerProvider.notifier).reset();
                        context.go('/focus');
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: c.border),
                        foregroundColor: c.textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(focusTimerProvider.notifier).start();
                        final s = ref.read(soundProvider);
                        if (s.selected.source != SoundSource.none) {
                          ref.read(soundProvider.notifier).play();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.focus,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Go again',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
