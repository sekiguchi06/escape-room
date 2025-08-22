import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:escape_room/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('基本テスト', () {
    testWidgets('EscapeRoomApp smoke test', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const ProviderScope(child: EscapeRoomApp()));

      await tester.pump();

      // Verify that our app loads without errors - check if any widget is present
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });

    testWidgets('Basic app loads successfully', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: EscapeRoomApp()));

      // Wait for initial frame to load
      await tester.pump();

      // Verify that the basic UI is working
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App has proper widget tree', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: EscapeRoomApp()));

      await tester.pump();

      // Check that basic widget tree is present
      expect(find.byType(MaterialApp), findsWidgets);
    });
  });
}
