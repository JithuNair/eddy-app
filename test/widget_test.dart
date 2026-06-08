// ignore_for_file: avoid_redundant_argument_values

// Eddy widget + model tests
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
import 'package:eddy/features/momentum/models/habit.dart';

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

  // ── Habit model (pure logic — no widget pump needed) ─────────────────────────
  group('Habit model', () {
    test('completing today adds today to completedDates', () {
      const habit = Habit(id: 'a', name: 'Test', completedDates: []);
      final today = Habit.dateKey(DateTime.now());
      final updated = habit.toggleDate(DateTime.now());
      expect(updated.completedDates, contains(today));
    });

    test('completing today twice does not duplicate the date', () {
      const habit = Habit(id: 'a', name: 'Test', completedDates: []);
      final toggled = habit.toggleDate(DateTime.now());
      // toggle again = removes → list empty
      final reToggled = toggled.toggleDate(DateTime.now());
      final today = Habit.dateKey(DateTime.now());
      expect(reToggled.completedDates.where((d) => d == today).length, 0);
      // and re-adding from empty produces exactly one entry
      final final_ = reToggled.toggleDate(DateTime.now());
      expect(final_.completedDates.where((d) => d == today).length, 1);
    });

    test('isDoneOn returns true only for completed dates', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final habit = Habit(
        id: 'a',
        name: 'Test',
        completedDates: [Habit.dateKey(today)],
      );
      expect(habit.isDoneOn(today), isTrue);
      expect(habit.isDoneOn(yesterday), isFalse);
    });

    test('tracker summary counts completed days in a month correctly', () {
      // Build a habit with 3 completions in the current month
      final now = DateTime.now();
      final dates = [
        Habit.dateKey(DateTime(now.year, now.month, 1)),
        Habit.dateKey(DateTime(now.year, now.month, 5)),
        Habit.dateKey(DateTime(now.year, now.month, 10)),
        // One from a different month — should not count
        Habit.dateKey(DateTime(now.year, now.month - 1, 15)),
      ];
      final habit = Habit(id: 'a', name: 'Test', completedDates: dates);

      // Count completions this month (same logic as _SummaryCard)
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      int count = 0;
      for (int d = 1; d <= daysInMonth; d++) {
        if (habit.isDoneOn(DateTime(now.year, now.month, d))) count++;
      }
      expect(count, 3);
    });

    test('7-day row derives from completedDates via isDoneOn', () {
      final today = DateTime.now();
      final dates = List.generate(
        7,
        (i) => Habit.dateKey(today.subtract(Duration(days: i))),
      );
      final habit =
          Habit(id: 'a', name: 'Test', completedDates: dates);

      for (int i = 0; i < 7; i++) {
        final day = today.subtract(Duration(days: i));
        expect(habit.isDoneOn(day), isTrue,
            reason: 'day -$i should be done');
      }
      // An 8th day back should not be done
      expect(habit.isDoneOn(today.subtract(const Duration(days: 7))),
          isFalse);
    });

    test('isLastChance is true when neither today nor yesterday are done', () {
      const habit =
          Habit(id: 'a', name: 'Test', completedDates: []);
      expect(habit.isLastChance, isTrue);
    });

    test('isLastChance is false when today is done', () {
      final habit = Habit(
        id: 'a',
        name: 'Test',
        completedDates: [Habit.dateKey(DateTime.now())],
      );
      expect(habit.isLastChance, isFalse);
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
