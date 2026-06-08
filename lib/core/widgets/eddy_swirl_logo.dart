import 'dart:math' as math;
import 'package:flutter/material.dart';

/// ── EddySwirlLogo ────────────────────────────────────────────────────────────
///
/// An abstract swirl mark that implies a lowercase "e" through:
///   • a near-complete circular arc  (the body / bowl of the letter)
///   • a horizontal crossbar stroke  (the "e" counter)
///   • a tiny dot at centre          (the protected eye of the eddy)
///
/// The arc has a SweepGradient that fades at both ends (near the gap at
/// 3 o'clock), giving the stroke the sense of emerging from and dissolving
/// back into the current — premium, calm, not mascot-like.
///
/// Usage:
///   EddySwirlLogo(color: context.colors.regulate, size: 28)
class EddySwirlLogo extends StatelessWidget {
  final Color color;

  /// Outer diameter of the icon container in logical pixels.
  final double size;

  const EddySwirlLogo({
    super.key,
    required this.color,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Deep ocean surface — distinct from the app background
        color: const Color(0xFF0A1628),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.30),
            blurRadius: size * 0.55,
            spreadRadius: 0,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _SwirlPainter(color: color),
      ),
    );
  }
}

class _SwirlPainter extends CustomPainter {
  final Color color;

  const _SwirlPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    final r = size.width / 2;

    // ── Outer arc — body of the "e" ─────────────────────────────────────
    //
    // Sweep: 330° clockwise, starting just past 3 o'clock (pi/12 ≈ 15°).
    // The 30° gap is centred at 0 rad (3 o'clock) — the "e" opening.
    //
    // SweepGradient maps angle→colour: fade at 0° and 360° (the gap ends),
    // full opacity through the rest of the stroke.
    final arcR = r * 0.70;
    final arcRect = Rect.fromCircle(center: center, radius: arcR);

    final arcPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          color.withValues(alpha: 0.18), // fade at gap end   (≈ 345°)
          color,                          // full opacity body
          color,
          color.withValues(alpha: 0.18), // fade at gap start (≈ 15°)
        ],
        stops: const [0.0, 0.11, 0.89, 1.0],
      ).createShader(arcRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      arcRect,
      math.pi / 12,      // startAngle: 15°  (just clockwise of 3 o'clock)
      math.pi * 11 / 6,  // sweepAngle: 330° clockwise
      false,
      arcPaint,
    );

    // ── Crossbar — the "e" counter ──────────────────────────────────────
    //
    // Horizontal stroke through vertical centre, spanning from the left
    // tangent point to ~35% past centre-right (into the gap zone).
    // A slightly lower opacity ties it visually below the arc without
    // competing with it.
    canvas.drawLine(
      Offset(cx - arcR * 0.95, cy),
      Offset(cx + arcR * 0.38, cy),
      Paint()
        ..color = color.withValues(alpha: 0.78)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.165
        ..strokeCap = StrokeCap.round,
    );

    // ── Eye — the protected centre of the eddy ──────────────────────────
    canvas.drawCircle(
      center,
      r * 0.09,
      Paint()..color = color.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(_SwirlPainter old) => old.color != color;
}

/// ── EddyBrandMark ────────────────────────────────────────────────────────────
///
/// The composed brand identity: swirl logo + "eddy" wordmark side-by-side.
///
/// [accentColor] is the section-tint colour:
///   • Regulate → EddyTeal    #6FD3C0
///   • Focus    → DriftLav    #A89BFF
///   • Momentum → WarmCoral   #FF8F7A
///
/// [showWordmark] — set false to use the mark alone (e.g. compact spots).
/// [size]        — outer diameter of the swirl circle; wordmark scales with it.
class EddyBrandMark extends StatelessWidget {
  final Color accentColor;
  final bool showWordmark;
  final double size;

  const EddyBrandMark({
    super.key,
    required this.accentColor,
    this.showWordmark = true,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        EddySwirlLogo(color: accentColor, size: size),
        if (showWordmark) ...[
          SizedBox(width: size * 0.30),
          Text(
            'eddy',
            style: TextStyle(
              // Scale with the logo so mark + wordmark stay optically aligned
              fontSize: size * 0.42,
              fontWeight: FontWeight.w600,
              color: accentColor,
              letterSpacing: size * 0.075,
              height: 1.0,
            ),
          ),
        ],
      ],
    );
  }
}
