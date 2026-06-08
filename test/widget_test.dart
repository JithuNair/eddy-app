import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:eddy/main.dart';

void main() {
  setUpAll(() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen('habits')) {
      await Hive.openBox('habits');
    }
  });

  testWidgets('EddyApp smoke test — launches without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: EddyApp()),
    );
    await tester.pump();
    // App renders a MaterialApp — verify the widget tree is non-empty.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
