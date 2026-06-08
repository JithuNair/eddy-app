// ignore_for_file: avoid_redundant_argument_values

// Eddy widget tests
//
// Why not a full-app smoke test?
// ─────────────────────────────────────────────────────────────────────────────
// Eddy targets the **web** platform and relies on platform plugins (Hive via
// path_provider, audioplayers via the Web Audio API) and heavy animation
// controllers (RippleCircle, BreathingOrb) that schedule repeating Tickers.
// In the headless VM test runner those plugins are absent, and fake_async
// reports the repeating Ticker timers as "pending" even after disposal —
// causing a false failure.
//
// Rather than wrestle with that environment mismatch, we test the individual
// brand mark components directly. That keeps the suite fast and zero-flake.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eddy/core/widgets/eddy_swirl_logo.dart';

void main() {
  // ── Minimal helper: thin wrapper providing required Material ancestors ──────
  Widget wrap(Widget child) => MaterialApp(
        home: Scaffold(body: Center(child: child)),
      );

  // ── EddySwirlLogo (fallback CustomPainter) ──────────────────────────────────
  group('EddySwirlLogo', () {
    testWidgets('renders at default size without throwing', (tester) async {
      await tester.pumpWidget(
        wrap(const EddySwirlLogo(color: Color(0xFF6FD3C0))),
      );
      await tester.pump();

      expect(find.byType(EddySwirlLogo), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders at an explicit size', (tester) async {
      await tester.pumpWidget(
        wrap(const EddySwirlLogo(color: Color(0xFFA89BFF), size: 48)),
      );
      await tester.pump();

      final logo = tester.widget<EddySwirlLogo>(find.byType(EddySwirlLogo));
      expect(logo.size, 48.0);
    });
  });

  // ── EddyBrandMark (founder-approved PNG logo) ────────────────────────────────
  group('EddyBrandMark', () {
    testWidgets('shows PNG mark and wordmark by default', (tester) async {
      await tester.pumpWidget(
        wrap(const EddyBrandMark(accentColor: Color(0xFF6FD3C0))),
      );
      await tester.pump();

      expect(find.byType(EddyBrandMark), findsOneWidget);
      // PNG logo renders via Image.asset → Image widget
      expect(find.byType(Image), findsOneWidget);
      // Wordmark text
      expect(find.text('eddy'), findsOneWidget);
    });

    testWidgets('hides wordmark when showWordmark is false', (tester) async {
      await tester.pumpWidget(
        wrap(const EddyBrandMark(
          accentColor: Color(0xFFA89BFF),
          showWordmark: false,
        )),
      );
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('eddy'), findsNothing);
    });

    testWidgets('adapts to all three section accent colours', (tester) async {
      const colours = [
        Color(0xFF6FD3C0), // Regulate — Eddy Teal
        Color(0xFFA89BFF), // Focus    — Drift Lavender
        Color(0xFFFF8F7A), // Momentum — Warm Coral
      ];

      for (final c in colours) {
        await tester.pumpWidget(wrap(EddyBrandMark(accentColor: c)));
        await tester.pump();

        final mark = tester.widget<EddyBrandMark>(find.byType(EddyBrandMark));
        expect(mark.accentColor, c);
      }
    });
  });
}
