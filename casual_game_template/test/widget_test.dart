import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:casual_game_template/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('CasualGameApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CasualGameApp());

    // Verify that our app loads without errors.
    expect(find.text('Tap Fire Game'), findsOneWidget);
    
    // Verify that the game widget is present.
    expect(find.byKey(const ValueKey('game_canvas')), findsOneWidget);
  });
  
  testWidgets('Basic app navigation test', (WidgetTester tester) async {
    await tester.pumpWidget(const CasualGameApp());
    
    // Wait for initial frame to load
    await tester.pump(const Duration(milliseconds: 100));
    
    // Verify that the basic UI is working
    expect(find.text('Tap Fire Game'), findsOneWidget);
    expect(find.byKey(const ValueKey('game_canvas')), findsOneWidget);
    
    // Allow one more frame for game initialization
    await tester.pump(const Duration(milliseconds: 100));
  });
}