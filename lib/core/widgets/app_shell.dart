import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/color_tokens.dart';
import '../providers/theme_provider.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _tabs = [
    _Tab(
      label: 'Regulate',
      assetPath: 'assets/icons/nav/regulate.png',
      path: '/regulate',
    ),
    _Tab(
      label: 'Focus',
      assetPath: 'assets/icons/nav/focus.png',
      path: '/focus',
    ),
    _Tab(
      label: 'Momentum',
      assetPath: 'assets/icons/nav/momentum.png',
      path: '/momentum',
    ),
  ];

  static const _subRoutes = [
    '/regulate/sigh',
    '/regulate/box',
    '/regulate/grounding',
    '/focus/session',
  ];

  int _indexFor(String loc) {
    if (loc.startsWith('/focus')) return 1;
    if (loc.startsWith('/momentum')) return 2;
    return 0;
  }

  bool _showNav(String loc) =>
      !_subRoutes.any((r) => loc.startsWith(r));

  Color _activeColor(int index, ColorTokens c) {
    return [c.regulate, c.focus, c.momentum][index];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = GoRouterState.of(context).uri.toString();
    final index = _indexFor(loc);
    final showNav = _showNav(loc);
    final c = context.colors;
    final activeColor = _activeColor(index, c);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Stack(
      children: [
        Column(
          children: [
            Expanded(child: child),
            if (showNav)
              _NavBar(
                tabs: _tabs,
                activeIndex: index,
                activeColor: activeColor,
                colors: c,
                onTap: (path) => context.go(path),
              ),
          ],
        ),
        if (showNav)
          Positioned(
            top: 20,
            right: 20,
            child: _ThemeToggle(isDark: isDark, onToggle: () {
              ref.read(themeModeProvider.notifier).toggle();
            }),
          ),
      ],
    );
  }
}

// ── Theme toggle ─────────────────────────────────────────────────────────────
//
// Dark mode  → shows the owl   (assets/icons/theme/dark_mode_owl.png)
// Light mode → shows the eagle (assets/icons/theme/light_mode_eagle.png)
//
// Tapping switches to the other mode.
class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const _ThemeToggle({required this.isDark, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final asset = isDark
        ? 'assets/icons/theme/dark_mode_owl.png'
        : 'assets/icons/theme/light_mode_eagle.png';

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: c.surface,
          shape: BoxShape.circle,
          border: Border.all(color: c.border),
        ),
        child: ClipOval(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Image.asset(
              asset,
              fit: BoxFit.contain,
              // Semantic label handled by parent GestureDetector tooltip
            ),
          ),
        ),
      ),
    );
  }
}

// ── Navigation bar ────────────────────────────────────────────────────────────
//
// Each tab uses a PNG icon from assets/icons/nav/.
// Selected tab: full opacity + tinted background pill.
// Unselected tab: 35% opacity so the icon colour doesn't compete.
class _NavBar extends StatelessWidget {
  final List<_Tab> tabs;
  final int activeIndex;
  final Color activeColor;
  final ColorTokens colors;
  final void Function(String) onTap;

  const _NavBar({
    required this.tabs,
    required this.activeIndex,
    required this.activeColor,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Material(
      color: c.surface,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: c.border, width: 0.5)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(tabs.length, (i) {
                final tab = tabs[i];
                final selected = i == activeIndex;
                final labelColor =
                    selected ? activeColor : c.textMuted;

                return Expanded(
                  child: InkWell(
                    onTap: () => onTap(tab.path),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: selected
                                ? activeColor.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Opacity(
                            opacity: selected ? 1.0 : 0.35,
                            child: Image.asset(
                              tab.assetPath,
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            color: labelColor,
                            fontSize: 10,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            letterSpacing: 0.2,
                          ),
                          child: Text(tab.label),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab {
  final String label;

  /// Path to the nav icon PNG under assets/icons/nav/.
  final String assetPath;
  final String path;

  const _Tab({
    required this.label,
    required this.assetPath,
    required this.path,
  });
}
