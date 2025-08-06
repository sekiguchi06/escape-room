import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:casual_game_template/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('CasualGameApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(CasualGameApp());

    // Verify that our app loads without errors.
    expect(find.text('Casual Game Template'), findsOneWidget);
    
    // Verify that the game widget is present.
    expect(find.byKey(const ValueKey('game_canvas')), findsOneWidget);
    
    // Verify that the audio test button is present.
    expect(find.byIcon(Icons.volume_up), findsOneWidget);
  });
  
  testWidgets('Navigation to AudioTestPage', (WidgetTester tester) async {
    await tester.pumpWidget(CasualGameApp());
    
    // Tap the audio test button.
    await tester.tap(find.byIcon(Icons.volume_up));
    
    // Manual pumps instead of pumpAndSettle to avoid timeout
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (tester.any(find.text('Audio Test'))) {
        break;
      }
    }
    
    // Verify that we navigated to the audio test page.
    expect(find.text('Audio Test'), findsOneWidget);
  });
}