import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import '../../lib/framework/escape_room/core/interaction_result.dart';
import '../../lib/framework/escape_room/strategies/item_provider_strategy.dart';
import '../../lib/framework/escape_room/strategies/puzzle_strategy.dart';
import '../../lib/framework/escape_room/gameobjects/bookshelf_object.dart';
import '../../lib/framework/escape_room/gameobjects/safe_object.dart';
import '../../lib/framework/escape_room/gameobjects/box_object.dart';
import '../../lib/framework/escape_room/core/escape_room_game.dart';

void main() {
  group('新アーキテクチャ Escape Room', () {
    
    group('InteractionResult', () {
      test('success factory', () {
        final result = InteractionResult.success(
          message: 'Test success',
          itemsToAdd: ['key'],
          shouldActivate: true,
        );
        
        expect(result.success, true);
        expect(result.message, 'Test success');
        expect(result.itemsToAdd, ['key']);
        expect(result.shouldActivate, true);
      });
      
      test('failure factory', () {
        final result = InteractionResult.failure('Test failure');
        
        expect(result.success, false);
        expect(result.message, 'Test failure');
        expect(result.itemsToAdd, isEmpty);
        expect(result.shouldActivate, false);
      });
    });
    
    group('ItemProviderStrategy', () {
      test('初回インタラクション成功', () {
        final strategy = ItemProviderStrategy(
          itemId: 'key',
          message: 'Found key!',
        );
        
        expect(strategy.canInteract(), true);
        
        final result = strategy.execute();
        expect(result.success, true);
        expect(result.message, 'Found key!');
        expect(result.itemsToAdd, ['key']);
        expect(result.shouldActivate, true);
        
        // 2回目は失敗
        expect(strategy.canInteract(), false);
        final result2 = strategy.execute();
        expect(result2.success, false);
      });
      
      test('リセット機能', () {
        final strategy = ItemProviderStrategy(
          itemId: 'tool',
          message: 'Found tool!',
        );
        
        strategy.execute();
        expect(strategy.canInteract(), false);
        
        strategy.reset();
        expect(strategy.canInteract(), true);
      });
    });
    
    group('PuzzleStrategy', () {
      test('パズル解決成功', () {
        final strategy = PuzzleStrategy(
          requiredItemId: 'key',
          successMessage: 'Puzzle solved!',
          failureMessage: 'Need key',
        );
        
        expect(strategy.canInteract(), true);
        
        final result = strategy.execute();
        expect(result.success, true);
        expect(result.message, 'Puzzle solved!');
        expect(result.shouldActivate, true);
        
        // 解決後は無効
        expect(strategy.canInteract(), false);
      });
    });
    
    group('GameObjects', () {
      test('BookshelfObject初期化', () {
        final bookshelf = BookshelfObject(
          position: Vector2(100, 200),
          size: Vector2(50, 75),
        );
        
        expect(bookshelf.objectId, 'bookshelf');
        expect(bookshelf.position, Vector2(100, 200));
        expect(bookshelf.size, Vector2(50, 75));
        expect(bookshelf.isActivated, false);
      });
      
      test('SafeObject初期化', () {
        final safe = SafeObject(
          position: Vector2(200, 150),
          size: Vector2(80, 100),
        );
        
        expect(safe.objectId, 'safe');
        expect(safe.position, Vector2(200, 150));
        expect(safe.size, Vector2(80, 100));
        expect(safe.isActivated, false);
      });
      
      test('BoxObject初期化', () {
        final box = BoxObject(
          position: Vector2(150, 300),
          size: Vector2(60, 40),
        );
        
        expect(box.objectId, 'box');
        expect(box.position, Vector2(150, 300));
        expect(box.size, Vector2(60, 40));
        expect(box.isActivated, false);
      });
    });
    
    group('EscapeRoomGame', () {
      test('ゲーム初期化', () {
        final game = EscapeRoomGame();
        
        expect(game.controller.gameObjects, isEmpty);
      });
      
      test('GameObject検索機能', () async {
        final game = EscapeRoomGame();
        await game.onLoad();
        
        // 型による検索
        final bookshelf = game.findGameObject<BookshelfObject>();
        expect(bookshelf, isNotNull);
        expect(bookshelf!.objectId, 'bookshelf');
        
        final safe = game.findGameObject<SafeObject>();
        expect(safe, isNotNull);
        expect(safe!.objectId, 'safe');
        
        final box = game.findGameObject<BoxObject>();
        expect(box, isNotNull);
        expect(box!.objectId, 'box');
        
        // 複数検索
        final allObjects = game.findGameObjects();
        expect(allObjects.length, 3);
      });
      
      test('全オブジェクト状態取得', () async {
        final game = EscapeRoomGame();
        await game.onLoad();
        
        // オブジェクトの初期化を待つ
        await Future.delayed(Duration(milliseconds: 100));
        
        final states = game.getAllObjectStates();
        expect(states.keys, containsAll(['bookshelf', 'safe', 'box']));
        
        for (final state in states.values) {
          expect(state['isActivated'], false);
        }
      });
    });
  });
}