import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/regulate/screens/regulate_screen.dart';
import '../features/regulate/screens/physiological_sigh_screen.dart';
import '../features/regulate/screens/box_breathing_screen.dart';
import '../features/regulate/screens/grounding_screen.dart';
import '../features/focus/screens/focus_screen.dart';
import '../features/focus/screens/focus_timer_screen.dart';
import '../features/momentum/screens/momentum_screen.dart';
import '../features/momentum/screens/momentum_tracker_screen.dart';
import 'widgets/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/regulate',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/regulate',
          pageBuilder: (context, state) => _fade(const RegulateScreen()),
          routes: [
            GoRoute(
              path: 'sigh',
              pageBuilder: (context, state) =>
                  _slide(const PhysiologicalSighScreen()),
            ),
            GoRoute(
              path: 'box',
              pageBuilder: (context, state) =>
                  _slide(const BoxBreathingScreen()),
            ),
            GoRoute(
              path: 'grounding',
              pageBuilder: (context, state) =>
                  _slide(const GroundingScreen()),
            ),
          ],
        ),
        GoRoute(
          path: '/focus',
          pageBuilder: (context, state) => _fade(const FocusScreen()),
          routes: [
            GoRoute(
              path: 'session',
              pageBuilder: (context, state) =>
                  _slide(const FocusTimerScreen()),
            ),
          ],
        ),
        GoRoute(
          path: '/momentum',
          pageBuilder: (context, state) => _fade(const MomentumScreen()),
          routes: [
            GoRoute(
              path: 'tracker',
              pageBuilder: (context, state) =>
                  _slide(const MomentumTrackerScreen()),
            ),
          ],
        ),
      ],
    ),
  ],
);

CustomTransitionPage<void> _fade(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 180),
  );
}

CustomTransitionPage<void> _slide(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, _, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: FadeTransition(opacity: animation, child: child),
    ),
    transitionDuration: const Duration(milliseconds: 280),
  );
}
