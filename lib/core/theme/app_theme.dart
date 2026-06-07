import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_tokens.dart';

// Keep AppColors as a compat shim pointing at dark tokens
// New code should use context.colors instead
class AppColors {
  static const background = Color(0xFF0B1220);
  static const surface = Color(0xFF121B2E);
  static const surfaceElevated = Color(0xFF1A2540);
  static const border = Color(0xFF1F3052);
  static const textPrimary = Color(0xFFEAF2FF);
  static const textSecondary = Color(0xFF8899BB);
  static const textMuted = Color(0xFF6F7D96);
  static const regulate = Color(0xFF6FD3C0);
  static const regulateSubtle = Color(0xFF0D2830);
  static const focus = Color(0xFFA89BFF);
  static const focusSubtle = Color(0xFF1A1535);
  static const momentum = Color(0xFFFF8F7A);
  static const momentumSubtle = Color(0xFF2D1510);
}

class AppTheme {
  static ThemeData get dark => _build(Brightness.dark, ColorTokens.dark);
  static ThemeData get light => _build(Brightness.light, ColorTokens.light);

  static ThemeData _build(Brightness brightness, ColorTokens c) {
    final isDark = brightness == Brightness.dark;
    final base = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: c.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: c.regulate,
        onPrimary: isDark ? Colors.black : Colors.white,
        secondary: c.focus,
        onSecondary: isDark ? Colors.black : Colors.white,
        error: const Color(0xFFFF6B6B),
        onError: Colors.white,
        surface: c.surface,
        onSurface: c.textPrimary,
      ),
      extensions: [c],
      textTheme: TextTheme(
        displayLarge: base.displayLarge?.copyWith(
          fontSize: 34,
          fontWeight: FontWeight.w300,
          color: c.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: base.headlineMedium?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
          letterSpacing: -0.3,
        ),
        titleMedium: base.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
        bodyLarge: base.bodyLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: c.textSecondary,
          height: 1.55,
        ),
        bodyMedium: base.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: c.textSecondary,
          height: 1.5,
        ),
        bodySmall: base.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: c.textSecondary,
        ),
        labelSmall: base.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: c.textMuted,
          letterSpacing: 0.8,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceElevated,
        hintStyle: TextStyle(color: c.textMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.regulate, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: c.border),
          foregroundColor: c.textSecondary,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
