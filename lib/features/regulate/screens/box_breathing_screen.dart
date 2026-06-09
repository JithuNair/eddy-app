import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/widgets/eddy_scaffold.dart';

enum _BoxPhase { ready, inhale, holdIn, exhale, holdOut }

class BoxBreathingScreen extends StatefulWidget {
  const BoxBreathingScreen({super.key});

  @override
  State<BoxBreathingScreen> createState() => _BoxBreathingScreenState();
}

class _BoxBreathingScreenState extends State<BoxBreathingScreen>
    with SingleTickerProviderStateMixin {
  _BoxPhase _phase = _BoxPhase.ready;
  int _secondsLeft = 4;
  int _completedRounds = 0;
  static const int _phaseDuration = 4;
  Timer? _timer;
  late AnimationController _squareController;

  @override
  void initState() {
    super.initState();
    _squareController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _squareController.dispose();
    super.dispose();
  }

  void _start() => _runPhase(_BoxPhase.inhale);

  void _runPhase(_BoxPhase phase) {
    setState(() {
      _phase = phase;
      _secondsLeft = _phaseDuration;
    });
    HapticFeedback.lightImpact();
    _animateForPhase(phase);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
      } else {
        t.cancel();
        _advancePhase();
      }
    });
  }

  void _animateForPhase(_BoxPhase phase) {
    switch (phase) {
      case _BoxPhase.inhale:
        _squareController.animateTo(1.0,
            duration: const Duration(seconds: _phaseDuration),
            curve: Curves.easeInOut);
      case _BoxPhase.exhale:
        _squareController.animateTo(0.0,
            duration: const Duration(seconds: _phaseDuration),
            curve: Curves.easeInOut);
      default:
        break;
    }
  }

  void _advancePhase() {
    final next = switch (_phase) {
      _BoxPhase.inhale => _BoxPhase.holdIn,
      _BoxPhase.holdIn => _BoxPhase.exhale,
      _BoxPhase.exhale => _BoxPhase.holdOut,
      _BoxPhase.holdOut => _BoxPhase.inhale,
      _BoxPhase.ready => _BoxPhase.inhale,
    };
    if (_phase == _BoxPhase.holdOut) setState(() => _completedRounds++);
    _runPhase(next);
  }

  void _stop() {
    _timer?.cancel();
    _squareController.animateTo(0.0, duration: 600.ms, curve: Curves.easeOut);
    setState(() {
      _phase = _BoxPhase.ready;
      _completedRounds = 0;
    });
  }

  String get _label => switch (_phase) {
        _BoxPhase.ready => 'Tap to begin',
        _BoxPhase.inhale => 'Inhale',
        _BoxPhase.holdIn => 'Hold',
        _BoxPhase.exhale => 'Exhale',
        _BoxPhase.holdOut => 'Hold',
      };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return EddyScaffold(
      accentColor: c.regulate,
      body: SafeArea(
        child: Column(
          children: [
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
                  if (_completedRounds > 0)
                    Text('$_completedRounds rounds',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: c.regulate)),
                  if (_phase != _BoxPhase.ready)
                    TextButton(
                      onPressed: _stop,
                      child: Text('Stop',
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
                  Text('Box Breathing',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text('4 · 4 · 4 · 4 — steady rhythm reset',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: c.textMuted)),
                ],
              ),
            ),
            const Spacer(),

            // Animated square — the box
            GestureDetector(
              onTap: _phase == _BoxPhase.ready ? _start : null,
              child: AnimatedBuilder(
                animation: _squareController,
                builder: (_, __) {
                  final t = _squareController.value;
                  final size = 130.0 + (t * 90);
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow
                      Container(
                        width: size + 40,
                        height: size + 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: RadialGradient(
                            colors: [
                              c.regulate.withValues(alpha: 0.06 + t * 0.06),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Box
                      Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              c.regulate.withValues(alpha: 0.12 + t * 0.10),
                              c.regulate.withValues(alpha: 0.04 + t * 0.06),
                            ],
                          ),
                          border: Border.all(
                            color: c.regulate.withValues(alpha: 0.2 + t * 0.4),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: c.regulate.withValues(alpha: 0.15 * t),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: _phase == _BoxPhase.ready
                            ? Center(
                                child: Text('TAP',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: c.regulate,
                                        letterSpacing: 2)))
                            : null,
                      ),
                    ],
                  );
                },
              ),
            ),

            const Spacer(),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Column(
                key: ValueKey(_phase),
                children: [
                  Text(_label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 22, fontWeight: FontWeight.w300)),
                  if (_phase != _BoxPhase.ready) ...[
                    const SizedBox(height: 12),
                    Text('$_secondsLeft',
                        style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w100,
                            color: c.regulate,
                            letterSpacing: 2)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 72),
          ],
        ),
      ),
    );
  }
}
