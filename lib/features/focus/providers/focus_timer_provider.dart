import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FocusPhase { idle, running, done }

class FocusTimerState {
  final int durationMinutes;
  final int elapsedSeconds;
  final String intention;
  final FocusPhase phase;

  const FocusTimerState({
    required this.durationMinutes,
    required this.elapsedSeconds,
    required this.intention,
    required this.phase,
  });

  int get totalSeconds => durationMinutes * 60;
  int get remainingSeconds => (totalSeconds - elapsedSeconds).clamp(0, totalSeconds);
  double get progress => elapsedSeconds / totalSeconds;

  String get remainingLabel {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  FocusTimerState copyWith({
    int? durationMinutes,
    int? elapsedSeconds,
    String? intention,
    FocusPhase? phase,
  }) {
    return FocusTimerState(
      durationMinutes: durationMinutes ?? this.durationMinutes,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      intention: intention ?? this.intention,
      phase: phase ?? this.phase,
    );
  }
}

class FocusTimerNotifier extends StateNotifier<FocusTimerState> {
  Timer? _ticker;

  FocusTimerNotifier()
      : super(const FocusTimerState(
          durationMinutes: 25,
          elapsedSeconds: 0,
          intention: '',
          phase: FocusPhase.idle,
        ));

  void setDuration(int minutes) {
    state = state.copyWith(durationMinutes: minutes, elapsedSeconds: 0);
  }

  void setIntention(String text) {
    state = state.copyWith(intention: text);
  }

  void start() {
    if (state.phase == FocusPhase.running) return;
    state = state.copyWith(phase: FocusPhase.running, elapsedSeconds: 0);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = state.elapsedSeconds + 1;
      if (next >= state.totalSeconds) {
        _ticker?.cancel();
        state = state.copyWith(
          elapsedSeconds: state.totalSeconds,
          phase: FocusPhase.done,
        );
      } else {
        state = state.copyWith(elapsedSeconds: next);
      }
    });
  }

  void stop() {
    _ticker?.cancel();
    state = state.copyWith(phase: FocusPhase.idle, elapsedSeconds: 0);
  }

  void reset() {
    _ticker?.cancel();
    state = const FocusTimerState(
      durationMinutes: 25,
      elapsedSeconds: 0,
      intention: '',
      phase: FocusPhase.idle,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final focusTimerProvider =
    StateNotifierProvider<FocusTimerNotifier, FocusTimerState>(
        (ref) => FocusTimerNotifier());
