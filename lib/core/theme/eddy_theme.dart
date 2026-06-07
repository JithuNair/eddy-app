import 'package:flutter/material.dart';
import 'color_tokens.dart';

// ── Radius ────────────────────────────────────────────────────────────────────
class EddyRadius {
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 22.0;
  static const xl = 28.0;
  static const pill = 100.0;

  static const card = BorderRadius.all(Radius.circular(lg));
  static const cardLarge = BorderRadius.all(Radius.circular(xl));
  static const button = BorderRadius.all(Radius.circular(md));
  static const pillButton = BorderRadius.all(Radius.circular(pill));
  static const chip = BorderRadius.all(Radius.circular(pill));
  static const input = BorderRadius.all(Radius.circular(md));
  static const sheet = BorderRadius.vertical(top: Radius.circular(xl));
}

// ── Spacing ───────────────────────────────────────────────────────────────────
class EddySpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
  static const screenH = EdgeInsets.fromLTRB(24, 48, 24, 32);
  static const screenHSlim = EdgeInsets.fromLTRB(24, 24, 24, 24);
  static const card = EdgeInsets.all(20.0);
  static const cardV = EdgeInsets.symmetric(horizontal: 20, vertical: 16);
}

// ── Glows / Shadows ───────────────────────────────────────────────────────────
class EddyGlow {
  static List<BoxShadow> accent(Color color, {double intensity = 0.25}) => [
        BoxShadow(
          color: color.withOpacity(intensity),
          blurRadius: 24,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> orb(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.35),
          blurRadius: 40,
          spreadRadius: 4,
        ),
        BoxShadow(
          color: color.withOpacity(0.15),
          blurRadius: 80,
          spreadRadius: 8,
        ),
      ];

  static List<BoxShadow> card(ColorTokens c) => [
        BoxShadow(
          color: c.darkOverlay.withOpacity(0.6),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}

// ── Gradients ─────────────────────────────────────────────────────────────────
class EddyGradients {
  static LinearGradient regulate(ColorTokens c) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          c.regulate.withOpacity(0.12),
          c.surface,
        ],
      );

  static LinearGradient focus(ColorTokens c) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          c.focus.withOpacity(0.10),
          c.surface,
        ],
      );

  static LinearGradient momentum(ColorTokens c) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          c.momentum.withOpacity(0.10),
          c.surface,
        ],
      );

  static RadialGradient orbGlow(Color color) => RadialGradient(
        colors: [
          color.withOpacity(0.18),
          color.withOpacity(0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      );
}

// ── Card decorations ──────────────────────────────────────────────────────────
class EddyCardStyle {
  static BoxDecoration base(ColorTokens c, {Color? gradient}) => BoxDecoration(
        color: gradient == null ? c.surface : null,
        gradient: gradient != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [gradient.withOpacity(0.12), c.surface],
              )
            : null,
        borderRadius: EddyRadius.card,
        border: Border.all(color: c.border.withOpacity(0.6), width: 0.5),
        boxShadow: EddyGlow.card(c),
      );

  static BoxDecoration elevated(ColorTokens c) => BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: EddyRadius.card,
        border: Border.all(color: c.border.withOpacity(0.4), width: 0.5),
      );
}

// ── Text Styles ───────────────────────────────────────────────────────────────
// Complementary helpers on top of ThemeData's textTheme
class EddyText {
  static TextStyle sectionLabel(ColorTokens c) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: c.textMuted,
        letterSpacing: 1.5,
      );

  static TextStyle accentLabel(Color accent) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: accent,
        letterSpacing: 1.5,
      );

  static TextStyle tag(Color color) => TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.8,
      );

  static TextStyle timerDisplay(ColorTokens c) => TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.w200,
        color: c.textPrimary,
        letterSpacing: 4,
        fontFamily: 'Plus Jakarta Sans',
      );
}
