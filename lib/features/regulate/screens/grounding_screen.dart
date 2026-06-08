import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/widgets/eddy_scaffold.dart';
import '../../../core/widgets/eddy_buttons.dart';

class _GroundingStep {
  final int count;
  final String sense;
  final String verb;
  final String prompt;
  final IconData icon;

  const _GroundingStep({
    required this.count,
    required this.sense,
    required this.verb,
    required this.prompt,
    required this.icon,
  });
}

const _steps = [
  _GroundingStep(count: 5, sense: 'See', verb: 'you can see',
      prompt: 'Look around. Name 5 things in your field of vision.',
      icon: Icons.visibility_rounded),
  _GroundingStep(count: 4, sense: 'Hear', verb: 'you can hear',
      prompt: 'Close your eyes. What 4 sounds are present right now?',
      icon: Icons.hearing_rounded),
  _GroundingStep(count: 3, sense: 'Touch', verb: 'you can touch',
      prompt: 'Feel 3 textures â€” the floor, your clothes, the air.',
      icon: Icons.touch_app_rounded),
  _GroundingStep(count: 2, sense: 'Smell', verb: 'you can smell',
      prompt: 'Breathe in slowly. Notice 2 scents around you.',
      icon: Icons.air_rounded),
  _GroundingStep(count: 1, sense: 'Taste', verb: 'you can taste',
      prompt: '1 thing you can taste right now.',
      icon: Icons.restaurant_rounded),
];

class GroundingScreen extends StatefulWidget {
  const GroundingScreen({super.key});

  @override
  State<GroundingScreen> createState() => _GroundingScreenState();
}

class _GroundingScreenState extends State<GroundingScreen> {
  int _stepIndex = -1;

  bool get _isIntro => _stepIndex == -1;
  bool get _isDone => _stepIndex >= _steps.length;
  _GroundingStep? get _current =>
      _stepIndex >= 0 && _stepIndex < _steps.length ? _steps[_stepIndex] : null;

  void _advance() {
    HapticFeedback.selectionClick();
    setState(() => _stepIndex++);
  }

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
                  if (!_isIntro && !_isDone)
                    Text('${_stepIndex + 1} / ${_steps.length}',
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: c.regulate)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('5-4-3-2-1 Grounding',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text('Anchor to the present moment through your senses',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: c.textMuted)),
                ],
              ),
            ),
            const Spacer(),
            AnimatedSwitcher(
              duration: 350.ms,
              switchInCurve: Curves.easeOut,
              child: _isIntro
                  ? _buildIntro(c)
                  : _isDone
                      ? _buildDone(c)
                      : _buildStep(_current!, c),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: _isDone
                  ? EddyPillButton(
                      label: 'Back to tools',
                      color: c.regulate,
                      onPressed: () => context.go('/regulate'),
                    ).animate().fadeIn(duration: 400.ms)
                  : EddyPillButton(
                      label: _isIntro ? 'Begin' : 'Next',
                      color: c.regulate,
                      onPressed: _advance,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntro(ColorTokens c) {
    return Padding(
      key: const ValueKey('intro'),
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: c.regulateSubtle,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.anchor_rounded, size: 36, color: c.regulate),
          ),
          const SizedBox(height: 28),
          Text(
            'You\'re going to notice\n5 things you can sense.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w300, fontSize: 20),
          ),
          const SizedBox(height: 12),
          Text(
            'Take your time. There\'s no rush.\nEach step brings you more into your body.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: c.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(_GroundingStep step, ColorTokens c) {
    return Padding(
      key: ValueKey(step.count),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text('${step.count}',
              style: TextStyle(
                fontSize: 96,
                fontWeight: FontWeight.w100,
                color: c.regulate.withValues(alpha: 0.5),
                height: 1,
              )),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(step.icon, size: 16, color: c.regulate),
              const SizedBox(width: 8),
              Text('things ${step.verb}',
                  style: TextStyle(
                      color: c.regulate,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3)),
            ],
          ),
          const SizedBox(height: 32),
          Text(step.prompt,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(fontSize: 17, height: 1.7, color: c.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildDone(ColorTokens c) {
    return Padding(
      key: const ValueKey('done'),
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: c.regulateSubtle,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, size: 36, color: c.regulate)
                .animate().scale(begin: const Offset(0.5, 0.5)).fadeIn(),
          ),
          const SizedBox(height: 28),
          Text('You\'re here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w300)),
          const SizedBox(height: 12),
          Text(
            'That\'s all grounding is â€” returning to the present.\nYou can do this anytime.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: c.textMuted),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }
}
