import 'package:flutter/material.dart';

/// Expanding concentric ripple rings â€” the Eddy water-current signature.
/// Self-animated, no external controller needed.
class RippleCircle extends StatefulWidget {
  final Color color;
  final double size;
  final int ringCount;
  final Duration period;

  const RippleCircle({
    super.key,
    required this.color,
    this.size = 200,
    this.ringCount = 3,
    this.period = const Duration(seconds: 3),
  });

  @override
  State<RippleCircle> createState() => _RippleCircleState();
}

class _RippleCircleState extends State<RippleCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _RipplePainter(
              color: widget.color,
              progress: _ctrl.value,
              ringCount: widget.ringCount,
            ),
          ),
        );
      },
    );
  }
}

class _RipplePainter extends CustomPainter {
  final Color color;
  final double progress;
  final int ringCount;

  _RipplePainter({
    required this.color,
    required this.progress,
    required this.ringCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < ringCount; i++) {
      final offset = (progress + i / ringCount) % 1.0;
      final radius = maxRadius * offset;
      final opacity = (1.0 - offset) * 0.3;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_RipplePainter old) =>
      old.progress != progress || old.color != color;
}
