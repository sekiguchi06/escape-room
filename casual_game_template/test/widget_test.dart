
import 'package:flutter_test/flutter_test.dart';
import 'package:casual_game_template/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('CasualGameApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CasualGameApp());

    // Verify that our app loads without errors - using current UI text
    expect(find.text('🔓 Play Escape Room'), findsOneWidget);
    
    // Verify that basic UI elements are present
    expect(find.text('Casual Game Template'), findsOneWidget);
  });
  
  testWidgets('Basic app navigation test', (WidgetTester tester) async {
    await tester.pumpWidget(const CasualGameApp());
    
    // Wait for initial frame to load
    await tester.pump(const Duration(milliseconds: 100));
    
    // Verify that the basic UI is working - using current UI
    expect(find.text('🔓 Play Escape Room'), findsOneWidget);
    expect(find.text('Casual Game Template'), findsOneWidget);
    
    // Allow one more frame for game initialization
    await tester.pump(const Duration(milliseconds: 100));
  });
}