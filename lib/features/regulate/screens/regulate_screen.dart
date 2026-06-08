import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/eddy_theme.dart';
import '../../../core/widgets/eddy_scaffold.dart';
import '../../../core/widgets/eddy_header.dart';
import '../../../core/widgets/ripple_circle.dart';

class RegulateScreen extends StatelessWidget {
  const RegulateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return EddyScaffold(
      accentColor: c.regulate,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: EddyHeader(
                title: 'Regulate',
                subtitle: 'Ground yourself first. Everything else follows.',
                accentColor: c.regulate,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.04, end: 0),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _RegulateCard(
                    title: 'Physiological Sigh',
                    subtitle: 'Fastest relief for acute spikes',
                    description:
                        'Double inhale through nose, long exhale. Offloads CO₂ faster than any other breath pattern.',
                    iconAsset: 'assets/icons/regulate/physiological_sigh.png',
                    tag: 'FASTEST ACTING',
                    color: c.regulate,
                    subtle: c.regulateSubtle,
                    onTap: () => context.go('/regulate/sigh'),
                  ).animate().fadeIn(delay: 80.ms, duration: 400.ms).slideY(begin: 0.04, end: 0),
                  const SizedBox(height: 14),
                  _RegulateCard(
                    title: 'Box Breathing',
                    subtitle: 'Steady, rhythmic reset',
                    description:
                        'Inhale 4 · hold 4 · exhale 4 · hold 4. Used by special forces to stay calm under pressure.',
                    iconAsset: 'assets/icons/regulate/box_breathing.png',
                    tag: 'STRUCTURED',
                    color: c.regulate,
                    subtle: c.regulateSubtle,
                    onTap: () => context.go('/regulate/box'),
                  ).animate().fadeIn(delay: 160.ms, duration: 400.ms).slideY(begin: 0.04, end: 0),
                  const SizedBox(height: 14),
                  _RegulateCard(
                    title: '5-4-3-2-1 Grounding',
                    subtitle: 'Anchor to the present moment',
                    description:
                        '5 things you see · 4 hear · 3 touch · 2 smell · 1 taste. Breaks dissociation fast.',
                    iconAsset: 'assets/icons/regulate/grounding.png',
                    tag: 'SENSORY',
                    color: c.regulate,
                    subtle: c.regulateSubtle,
                    onTap: () => context.go('/regulate/grounding'),
                  ).animate().fadeIn(delay: 240.ms, duration: 400.ms).slideY(begin: 0.04, end: 0),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegulateCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String description;
  final String iconAsset;
  final String tag;
  final Color color;
  final Color subtle;
  final VoidCallback onTap;

  const _RegulateCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.iconAsset,
    required this.tag,
    required this.color,
    required this.subtle,
    required this.onTap,
  });

  @override
  State<_RegulateCard> createState() => _RegulateCardState();
}

class _RegulateCardState extends State<_RegulateCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _pressed ? c.surfaceElevated : c.surface,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.color.withValues(alpha: _pressed ? 0.10 : 0.07),
                c.surface,
              ],
            ),
            borderRadius: EddyRadius.card,
            border: Border.all(
              color: _pressed
                  ? widget.color.withValues(alpha: 0.3)
                  : c.border.withValues(alpha: 0.6),
              width: 0.5,
            ),
            boxShadow: EddyGlow.card(c),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon box with ripple
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    RippleCircle(
                      color: widget.color,
                      size: 52,
                      ringCount: 2,
                      period: const Duration(seconds: 4),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: widget.subtle,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(
                          widget.iconAsset,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: widget.color.withValues(alpha: 0.2),
                                width: 0.5),
                          ),
                          child: Text(widget.tag,
                              style: EddyText.tag(widget.color)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: widget.color.withValues(alpha: 0.8),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(widget.description,
                        style: Theme.of(context).textTheme.bodyMedium),
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
