import 'package:flutter/material.dart';
import '../theme/eddy_theme.dart';

/// A pulsing orb with a soft glow â€” the signature Eddy breathing visual.
/// Drives from an external [AnimationController] so the parent screen
/// controls the breath cycle timing.
class BreathingOrb extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  final double minSize;
  final double maxSize;
  final Widget? centerChild;

  const BreathingOrb({
    super.key,
    required this.controller,
    required this.color,
    this.minSize = 120,
    this.maxSize = 220,
    this.centerChild,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;
        final size = minSize + (maxSize - minSize) * t;
        return SizedBox(
          width: maxSize + 80,
          height: maxSize + 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ambient glow
              Container(
                width: size + 60,
                height: size + 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: 0.12 * t),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Mid glow ring
              Container(
                width: size + 24,
                height: size + 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.08 * t),
                ),
              ),
              // Core orb
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: 0.55 + 0.2 * t),
                      color.withValues(alpha: 0.20 + 0.10 * t),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                  boxShadow: EddyGlow.orb(color).map((s) => BoxShadow(
                        color: s.color.withValues(alpha: s.color.a * t),
                        blurRadius: s.blurRadius,
                        spreadRadius: s.spreadRadius,
                      )).toList(),
                ),
                child: centerChild != null
                    ? Center(child: centerChild)
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Static (non-animated) orb used as a decorative element.
class StaticOrb extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const StaticOrb({
    super.key,
    required this.color,
    this.size = 160,
    this.opacity = 0.15,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
