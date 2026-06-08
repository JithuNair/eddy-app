import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  // Start with the OS preference; the toggle button lets the user override.
  ThemeModeNotifier() : super(ThemeMode.system);

  void toggle() {
    // Resolve current effective mode before toggling so the button always
    // flips to the opposite of what's actually on screen.
    final platformDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    final effectivelyDark = state == ThemeMode.dark ||
        (state == ThemeMode.system && platformDark);
    state = effectivelyDark ? ThemeMode.light : ThemeMode.dark;
  }

  bool get isDark {
    if (state == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return state == ThemeMode.dark;
  }
}
