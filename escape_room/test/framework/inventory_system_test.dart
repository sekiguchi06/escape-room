import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:escape_room/framework/components/inventory_manager.dart';
import 'package:escape_room/framework/ui/inventory_ui_component.dart';
import 'package:escape_room/framework/ui/inventory_state_notifier.dart';
import 'package:escape_room/framework/ui/responsive_layout_calculator.dart';
import 'package:escape_room/framework/ui/japanese_message_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InventorySystem Tests', () {
    group('InventoryManager Tests', () {
      late InventoryManager manager;

      setUp(() {
        manager = InventoryManager(maxItems: 4, onItemSelected: (_) {});
      });

      test('should add item correctly', () {
        final result = manager.addItem('key');
        expect(result, isTrue);
        expect(manager.hasItem('key'), isTrue);
        expect(manager.items.length, equals(1));
      });

      test('should not add duplicate items', () {
        manager.addItem('key');
        final result = manager.addItem('key');
        expect(result, isFalse);
        expect(manager.items.length, equals(1));
      });

      test('should respect max items limit', () {
        manager.addItem('key');
        manager.addItem('tool');
        manager.addItem('code');
        manager.addItem('extra1');
        final result = manager.addItem('extra2');
        expect(result, isFalse);
        expect(manager.items.length, equals(4));
        expect(manager.isFull, isTrue);
      });

      test('should remove item correctly', () {
        manager.addItem('key');
        final result = manager.removeItem('key');
        expect(result, isTrue);
        expect(manager.hasItem('key'), isFalse);
        expect(manager.isEmpty, isTrue);
      });

      test('should clear all items', () {
        manager.addItem('key');
        manager.addItem('tool');
        manager.clear();
        expect(manager.isEmpty, isTrue);
        expect(manager.items.length, equals(0));
      });

      test('should calculate usage rate correctly', () {
        manager.addItem('key');
        manager.addItem('tool');
        expect(manager.usageRate, equals(0.5));
      });
    });

    group('InventoryStateNotifier Tests', () {
      late InventoryManager manager;
      late InventoryStateNotifier notifier;
      bool notified = false;

      setUp(() {
        manager = InventoryManager(maxItems: 4, onItemSelected: (_) {});
        notifier = InventoryStateNotifier(manager: manager);
        notifier.addListener(() => notified = true);
        notified = false;
      });

      test('should notify on item selection', () {
        manager.addItem('key');
        notifier.selectItem('key');
        expect(notified, isTrue);
        expect(notifier.selectedItemId, equals('key'));
      });

      test('should notify on item addition', () {
        notifier.addItem('key');
        expect(notified, isTrue);
        expect(notifier.items.contains('key'), isTrue);
      });

      test('should notify on item removal', () {
        notifier.addItem('key');
        notified = false;
        notifier.removeItem('key');
        expect(notified, isTrue);
        expect(notifier.items.contains('key'), isFalse);
      });

      test('should clear selection when item is removed', () {
        notifier.addItem('key');
        notifier.selectItem('key');
        notifier.removeItem('key');
        expect(notifier.selectedItemId, isNull);
      });
    });

    group('ResponsiveLayoutCalculator Tests', () {
      late ResponsiveLayoutCalculator calculator;

      setUp(() {
        calculator = ResponsiveLayoutCalculator(
          screenSize: Vector2(400, 800),
          maxItems: 8,
        );
      });

      test('should calculate inventory area correctly', () {
        final area = calculator.calculateInventoryArea();
        expect(area.x, equals(400));
        expect(area.y, equals(160)); // 800 * 0.2
      });

      test('should calculate inventory position correctly', () {
        final position = calculator.calculateInventoryPosition();
        expect(position.x, equals(0));
        expect(position.y, equals(560)); // topMenu(80) + gameArea(480)
      });

      test('should calculate item positions for different counts', () {
        final positions1 = calculator.calculateItemPositions(1);
        final positions4 = calculator.calculateItemPositions(4);
        final positions8 = calculator.calculateItemPositions(8);

        expect(positions1.length, equals(1));
        expect(positions4.length, equals(4));
        expect(positions8.length, equals(8));

        // アイテムが画面内に配置されているかチェック
        for (final position in positions4) {
          expect(position.x, greaterThanOrEqualTo(0));
          expect(position.x, lessThan(400));
          expect(position.y, greaterThanOrEqualTo(560));
          expect(position.y, lessThan(800));
        }
      });

      test('should determine scroll indicator need', () {
        expect(
          calculator.shouldShowScrollIndicator(),
          isFalse,
        ); // 8 == maxItemsPerRow * 2 (4 * 2 = 8)
      });

      test('should calculate arrow positions', () {
        final leftArrow = calculator.calculateLeftArrowPosition();
        final rightArrow = calculator.calculateRightArrowPosition();
        final arrowSize = calculator.calculateArrowSize();

        expect(leftArrow.x, equals(8)); // screenSize.x * 0.02
        expect(
          rightArrow.x,
          equals(332),
        ); // screenSize.x - buttonWidth - margin
        expect(arrowSize.x, equals(60)); // screenSize.x * 0.15
      });
    });

    group('JapaneseMessageSystem Tests', () {
      test('should get correct messages', () {
        expect(
          JapaneseMessageSystem.getMessage('inventory_title'),
          equals('インベントリ'),
        );
        expect(
          JapaneseMessageSystem.getMessage('inventory_empty'),
          equals('アイテムがありません'),
        );
        expect(JapaneseMessageSystem.getMessage('item_key'), equals('鍵'));
      });

      test('should handle parameter substitution', () {
        final message = JapaneseMessageSystem.getMessage(
          'item_obtained',
          params: {'item': '鍵'},
        );
        expect(message, contains('鍵'));
      });

      test('should return key if message not found', () {
        final message = JapaneseMessageSystem.getMessage('unknown_key');
        expect(message, equals('unknown_key'));
      });

      test('should create message component correctly', () {
        final component = JapaneseMessageSystem.createMessageComponent(
          'inventory_title',
          position: Vector2(100, 100),
          fontSize: 24,
        );

        expect(component, isA<TextComponent>());
        expect(component.position, equals(Vector2(100, 100)));
        expect(component.text, equals('インベントリ'));
      });
    });

    group('InventoryUIComponent Integration Tests', () {
      late InventoryManager manager;
      late InventoryUIComponent uiComponent;

      setUp(() {
        manager = InventoryManager(maxItems: 4, onItemSelected: (_) {});
        uiComponent = InventoryUIComponent(
          manager: manager,
          screenSize: Vector2(400, 800),
        );
      });

      testWithFlameGame('should load inventory UI correctly', (game) async {
        await game.add(uiComponent);
        await game.ready();

        // UIが正常にロードされたかチェック
        expect(uiComponent.isLoaded, isTrue);
        expect(uiComponent.children.isNotEmpty, isTrue);
      });

      testWithFlameGame('should display items correctly', (game) async {
        await game.add(uiComponent);
        await game.ready();

        // アイテムを追加
        final added1 = uiComponent.addItem('key');
        final added2 = uiComponent.addItem('tool');

        // アイテム追加が成功したかチェック
        expect(added1, isTrue);
        expect(added2, isTrue);

        // マネージャーレベルでアイテムが追加されたかチェック
        expect(uiComponent.manager.items.length, equals(2));
        expect(uiComponent.manager.items, contains('key'));
        expect(uiComponent.manager.items, contains('tool'));
      });

      testWithFlameGame('should handle empty inventory', (game) async {
        await game.add(uiComponent);
        await game.ready();

        // 空メッセージが表示されるかチェック
        final textComponents = uiComponent.children
            .whereType<TextComponent>()
            .where((c) => c.text.contains('アイテムがありません'))
            .toList();
        expect(textComponents.isNotEmpty, isTrue);
      });

      testWithFlameGame('should update selection state', (game) async {
        await game.add(uiComponent);
        await game.ready();

        uiComponent.addItem('key');
        uiComponent.addItem('tool');

        // アイテムを選択
        uiComponent.selectItem('key');

        // 選択状態が正しく設定されたかチェック
        expect(uiComponent.selectedItemId, equals('key'));
      });
    });

    group('Performance Tests', () {
      testWithFlameGame(
        'should handle maximum items without performance issues',
        (game) async {
          final manager = InventoryManager(maxItems: 8, onItemSelected: (_) {});
          final uiComponent = InventoryUIComponent(
            manager: manager,
            screenSize: Vector2(400, 800),
          );

          await game.add(uiComponent);
          await game.ready();

          // 最大数のアイテムを追加
          for (int i = 0; i < 8; i++) {
            uiComponent.addItem('item$i');
          }

          // パフォーマンステスト：大量アイテム時の処理時間
          final stopwatch = Stopwatch()..start();
          uiComponent.refreshUI();
          stopwatch.stop();

          // 100ms以内で完了することを確認
          expect(stopwatch.elapsedMilliseconds, lessThan(100));
        },
      );
    });
  });
}
