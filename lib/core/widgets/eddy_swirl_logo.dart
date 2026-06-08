import 'dart:math' as math;
import 'package:flutter/material.dart';

// ── Asset path constants ────────────────────────────────────────────────────

/// The founder-approved Eddy symbol mark (PNG, light background).
/// Registered in pubspec.yaml under assets/brand/.
const _kLogoAsset = 'assets/brand/eddy_logo.png';

// ── EddyBrandMark ────────────────────────────────────────────────────────────
//
// The composed brand identity shown in every section header.
//
// Mark:     founder-approved PNG logo (assets/brand/eddy_logo.png), clipped
//           to a soft rounded square so it sits crisply on dark surfaces.
// Wordmark: lowercase "eddy" text tinted by the section accent colour:
//             Regulate → Eddy Teal    #6FD3C0
//             Focus    → Drift Lav    #A89BFF
//             Momentum → Warm Coral   #FF8F7A
//
// [showWordmark] — set false to use the mark alone (e.g. compact spots).
// [size]         — height of the logo mark; wordmark scales proportionally.
class EddyBrandMark extends StatelessWidget {
  final Color accentColor;
  final bool showWordmark;

  /// Height of the logo mark container in logical pixels.
  final double size;

  const EddyBrandMark({
    super.key,
    required this.accentColor,
    this.showWordmark = true,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Logo mark ──────────────────────────────────────────────────────
        // Clip the PNG (which has a light background) to a rounded square.
        // The subtle rounding echoes the premium aquatic feel without
        // obscuring the drop shadow baked into the asset.
        ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.22),
          child: Image.asset(
            _kLogoAsset,
            width: size,
            height: size,
            fit: BoxFit.cover,
            // Decorative — the header title carries the accessible label.
            semanticLabel: '',
          ),
        ),

        // ── Wordmark ───────────────────────────────────────────────────────
        if (showWordmark) ...[
          SizedBox(width: size * 0.28),
          Text(
            'eddy',
            style: TextStyle(
              fontSize: size * 0.40,
              fontWeight: FontWeight.w600,
              color: accentColor,
              letterSpacing: size * 0.06,
              height: 1.0,
            ),
          ),
        ],
      ],
    );
  }
}

// ── EddySwirlLogo ────────────────────────────────────────────────────────────
//
// The original CustomPainter swirl mark — retained as a lightweight fallback
// for contexts where loading a PNG asset is not appropriate (e.g. unit-test
// environments, placeholder states, or future SVG export reference).
//
// NOT used as the default visual in production. EddyBrandMark now uses the
// founder-approved PNG logo above.
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

    final arcR = r * 0.70;
    final arcRect = Rect.fromCircle(center: center, radius: arcR);

    final arcPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          color.withValues(alpha: 0.18),
          color,
          color,
          color.withValues(alpha: 0.18),
        ],
        stops: const [0.0, 0.11, 0.89, 1.0],
      ).createShader(arcRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      arcRect,
      math.pi / 12,
      math.pi * 11 / 6,
      false,
      arcPaint,
    );

    canvas.drawLine(
      Offset(cx - arcR * 0.95, cy),
      Offset(cx + arcR * 0.38, cy),
      Paint()
        ..color = color.withValues(alpha: 0.78)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.165
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(
      center,
      r * 0.09,
      Paint()..color = color.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(_SwirlPainter old) => old.color != color;
}
