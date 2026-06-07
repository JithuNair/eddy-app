import 'package:flutter/material.dart';

@immutable
class ColorTokens extends ThemeExtension<ColorTokens> {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color darkOverlay;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  final Color regulate;
  final Color regulateSubtle;
  final Color focus;
  final Color focusSubtle;
  final Color momentum;
  final Color momentumSubtle;
  final Color mistBlue;

  const ColorTokens({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.darkOverlay,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.regulate,
    required this.regulateSubtle,
    required this.focus,
    required this.focusSubtle,
    required this.momentum,
    required this.momentumSubtle,
    required this.mistBlue,
  });

  static const dark = ColorTokens(
    background: Color(0xFF0B1220),
    surface: Color(0xFF121B2E),
    surfaceElevated: Color(0xFF162238),
    darkOverlay: Color(0xFF08101C),
    border: Color(0xFF263A63),
    textPrimary: Color(0xFFEAF2FF),
    textSecondary: Color(0xFF9AA8C2),
    textMuted: Color(0xFF6F7D96),
    regulate: Color(0xFF6FD3C0),
    regulateSubtle: Color(0xFF0D2830),
    focus: Color(0xFFA89BFF),
    focusSubtle: Color(0xFF1A1535),
    momentum: Color(0xFFFF8F7A),
    momentumSubtle: Color(0xFF2D1510),
    mistBlue: Color(0xFF7EB6FF),
  );

  static const light = ColorTokens(
    background: Color(0xFFF7FAFF),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFEEF4FF),
    darkOverlay: Color(0xFFDDE6F5),
    border: Color(0xFFDDE6F5),
    textPrimary: Color(0xFF162033),
    textSecondary: Color(0xFF4A5A78),
    textMuted: Color(0xFF6B778C),
    regulate: Color(0xFF3AAE9B),
    regulateSubtle: Color(0xFFE6F7F5),
    focus: Color(0xFF7D6DF2),
    focusSubtle: Color(0xFFEEE8FF),
    momentum: Color(0xFFF57D68),
    momentumSubtle: Color(0xFFFDECEA),
    mistBlue: Color(0xFF4F8DFF),
  );

  @override
  ColorTokens copyWith({
    Color? background, Color? surface, Color? surfaceElevated,
    Color? darkOverlay, Color? border, Color? textPrimary,
    Color? textSecondary, Color? textMuted, Color? regulate,
    Color? regulateSubtle, Color? focus, Color? focusSubtle,
    Color? momentum, Color? momentumSubtle, Color? mistBlue,
  }) {
    return ColorTokens(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      darkOverlay: darkOverlay ?? this.darkOverlay,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      regulate: regulate ?? this.regulate,
      regulateSubtle: regulateSubtle ?? this.regulateSubtle,
      focus: focus ?? this.focus,
      focusSubtle: focusSubtle ?? this.focusSubtle,
      momentum: momentum ?? this.momentum,
      momentumSubtle: momentumSubtle ?? this.momentumSubtle,
      mistBlue: mistBlue ?? this.mistBlue,
    );
  }

  @override
  ColorTokens lerp(ColorTokens? other, double t) {
    if (other == null) return this;
    return ColorTokens(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      darkOverlay: Color.lerp(darkOverlay, other.darkOverlay, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      regulate: Color.lerp(regulate, other.regulate, t)!,
      regulateSubtle: Color.lerp(regulateSubtle, other.regulateSubtle, t)!,
      focus: Color.lerp(focus, other.focus, t)!,
      focusSubtle: Color.lerp(focusSubtle, other.focusSubtle, t)!,
      momentum: Color.lerp(momentum, other.momentum, t)!,
      momentumSubtle: Color.lerp(momentumSubtle, other.momentumSubtle, t)!,
      mistBlue: Color.lerp(mistBlue, other.mistBlue, t)!,
    );
  }
}

extension ColorTokensX on BuildContext {
  ColorTokens get colors => Theme.of(this).extension<ColorTokens>()!;
}
