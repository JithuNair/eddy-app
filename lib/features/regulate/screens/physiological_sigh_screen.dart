import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/eddy_theme.dart';
import '../../../core/widgets/eddy_scaffold.dart';
import '../../../core/widgets/eddy_buttons.dart';
import '../../../core/widgets/breathing_orb.dart';

enum _SighPhase { ready, inhale1, inhale2, exhale, done }

class PhysiologicalSighScreen extends StatefulWidget {
  const PhysiologicalSighScreen({super.key});

  @override
  State<PhysiologicalSighScreen> createState() =>
      _PhysiologicalSighScreenState();
}

class _PhysiologicalSighScreenState extends State<PhysiologicalSighScreen>
    with TickerProviderStateMixin {
  _SighPhase _phase = _SighPhase.ready;
  int _round = 0;
  static const int _totalRounds = 3;

  late AnimationController _orbController;
  late AnimationController _pulseController;
  Timer? _phaseTimer;

  static const _inhale1Duration = Duration(milliseconds: 1800);
  static const _inhale2Duration = Duration(milliseconds: 800);
  static const _exhaleDuration = Duration(milliseconds: 4000);
  static const _betweenDuration = Duration(milliseconds: 1200);

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(vsync: this);
    _pulseController = AnimationController(vsync: this, duration: 3.seconds)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _orbController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _start() {
    setState(() => _round = 1);
    _runInhale();
  }

  void _runInhale() {
    setState(() => _phase = _SighPhase.inhale1);
    // Run both inhale phases as ONE continuous animation so there is no
    // velocity discontinuity (choppiness) at the boundary.
    // The custom curve handles the 0→0.65 (1800ms) and 0.65→1.0 (800ms)
    // segments internally with matching velocities.
    const totalInhale = Duration(milliseconds: 2600); // 1800 + 800
    _orbController.animateTo(1.0,
        duration: totalInhale, curve: const _InhaleDoubleCurve());

    // Flip the label at the 1800ms mark (cosmetic only — animation continues)
    _phaseTimer = Timer(_inhale1Duration, () {
      if (mounted) setState(() => _phase = _SighPhase.inhale2);
      _phaseTimer = Timer(_inhale2Duration, _runExhale);
    });
  }

  void _runExhale() {
    setState(() => _phase = _SighPhase.exhale);
    _orbController.animateTo(0.0,
        duration: _exhaleDuration, curve: Curves.easeInOut);
    _phaseTimer = Timer(_exhaleDuration, () {
      if (_round < _totalRounds) {
        _phaseTimer = Timer(_betweenDuration, () {
          setState(() => _round++);
          _runInhale();
        });
      } else {
        _phaseTimer = Timer(_betweenDuration, () {
          setState(() => _phase = _SighPhase.done);
        });
      }
    });
  }

  void _reset() {
    _phaseTimer?.cancel();
    _orbController.animateTo(0.0,
        duration: const Duration(milliseconds: 700), curve: Curves.easeOut);
    setState(() {
      _phase = _SighPhase.ready;
      _round = 0;
    });
  }

  String get _phaseLabel => switch (_phase) {
        _SighPhase.ready => 'Ready when you are',
        _SighPhase.inhale1 => 'Inhale',
        _SighPhase.inhale2 => 'Inhale',
        _SighPhase.exhale => 'Exhale',
        _SighPhase.done => 'Well done',
      };

  String get _phaseSub => switch (_phase) {
        _SighPhase.ready => 'Tap the orb to begin',
        _SighPhase.inhale1 => '',
        _SighPhase.inhale2 => '',
        _SighPhase.exhale => '',
        _SighPhase.done => 'Your nervous system has been reset',
      };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return EddyScaffold(
      accentColor: c.regulate,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/regulate'),
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18, color: c.textSecondary),
                  ),
                  const Spacer(),
                  if (_round > 0 && _phase != _SighPhase.done)
                    Text('$_round / $_totalRounds',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: c.regulate)),
                  if (_phase != _SighPhase.ready)
                    TextButton(
                      onPressed: _reset,
                      child: Text('Reset',
                          style: TextStyle(color: c.textMuted, fontSize: 13)),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Physiological Sigh',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text('Fastest-acting technique for acute dysregulation',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: c.textMuted)),
                ],
              ),
            ),

            const Spacer(),

            // Breathing orb
            GestureDetector(
              onTap: _phase == _SighPhase.ready ? _start : null,
              child: _phase == _SighPhase.ready
                  ? BreathingOrb(
                      controller: _pulseController,
                      color: c.regulate,
                      minSize: 120,
                      maxSize: 180,
                      centerChild: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.air_rounded,
                              size: 26, color: Colors.white.withValues(alpha: 0.9)),
                          const SizedBox(height: 4),
                          Text('TAP',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.7),
                                letterSpacing: 2,
                              )),
                        ],
                      ),
                    )
                  : _phase == _SighPhase.done
                      ? Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.regulate.withValues(alpha: 0.15),
                            border:
                                Border.all(color: c.regulate.withValues(alpha: 0.4)),
                            boxShadow: EddyGlow.accent(c.regulate),
                          ),
                          child: Icon(Icons.check_rounded,
                                  size: 48, color: c.regulate)
                              .animate()
                              .scale(begin: const Offset(0.5, 0.5))
                              .fadeIn(),
                        )
                      : BreathingOrb(
                          controller: _orbController,
                          color: c.regulate,
                          minSize: 100,
                          maxSize: 200,
                        ),
            ),

            const Spacer(),

            // Phase labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 700),
                    reverseDuration: const Duration(milliseconds: 120),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Text(
                      _phaseLabel,
                      key: ValueKey(_phaseLabel),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 700),
                    reverseDuration: const Duration(milliseconds: 120),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Text(
                      _phaseSub,
                      key: ValueKey(_phaseSub),
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: c.textMuted),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            if (_phase == _SighPhase.done)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Column(
                  children: [
                    EddyPillButton(
                      label: 'Do it again',
                      color: c.regulate,
                      onPressed: _start,
                    ),
                    const SizedBox(height: 12),
                    EddyGhostButton(
                      label: 'Back to tools',
                      color: c.textSecondary,
                      onPressed: () => context.go('/regulate'),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Smooth double-inhale curve ─────────────────────────────────────────────────
//
// Maps [0,1] progress to orb size [0,1] across both inhale phases in one
// uninterrupted motion, eliminating the velocity discontinuity that caused
// choppiness when two separate animateTo() calls were chained.
//
//  t ∈ [0, split)    → first inhale  (0 → 0.65) with easeIn
//  t ∈ [split, 1]    → second inhale (0.65 → 1.0) with easeOut
//  split = 1800 / 2600 ≈ 0.692
class _InhaleDoubleCurve extends Curve {
  const _InhaleDoubleCurve();

  static const double _split = 1800 / 2600; // fraction of time for phase 1
  static const double _mid = 0.65;           // orb value at the boundary

  @override
  double transform(double t) {
    if (t <= _split) {
      final p = t / _split;
      return Curves.easeIn.transform(p) * _mid;
    } else {
      final p = (t - _split) / (1.0 - _split);
      return _mid + Curves.easeOut.transform(p) * (1.0 - _mid);
    }
  }
}
