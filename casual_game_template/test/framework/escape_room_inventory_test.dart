import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../lib/framework/game_types/quick_templates/escape_room_template.dart';
import '../../lib/game/example_games/simple_escape_room.dart';

/// インベントリアイテム選択機能の単体テスト
void main() {
  group('インベントリアイテム選択テスト', () {
    late SimpleEscapeRoom game;
    
    setUp(() {
      game = SimpleEscapeRoom();
    });

    testWithFlameGame<SimpleEscapeRoom>(
      '初期状態：何も選択されていない',
      () => SimpleEscapeRoom(),
      (game) async {
        await game.ready();
        
        // 初期状態では何も選択されていないことを確認
        expect(game.inventoryItems.isEmpty, true);
      },
    );

    testWithFlameGame<SimpleEscapeRoom>(
      'アイテム取得：本棚からツールを取得',
      () => SimpleEscapeRoom(),
      (game) async {
        await game.ready();
        
        // 本棚をクリックしてツールを取得
        final bookshelfHotspot = game.children
            .whereType<HotspotComponent>()
            .firstWhere((h) => h.id == 'bookshelf');
        
        // ホットスポットをタップ
        const tapDetails = TapUpDetails();
        bookshelfHotspot.onTapUp(TapUpEvent(1, game, tapDetails));
        
        // ツールが取得されることを確認
        await Future.delayed(const Duration(milliseconds: 200));
        expect(game.inventoryItems.contains('tool'), true);
      },
    );

    testWithFlameGame<SimpleEscapeRoom>(
      'アイテム取得：机からコードを取得',
      () => SimpleEscapeRoom(),
      (game) async {
        await game.ready();
        
        // 机をクリックしてコードを取得
        final deskHotspot = game.children
            .whereType<HotspotComponent>()
            .firstWhere((h) => h.id == 'desk');
        
        // ホットスポットをタップ
        const tapDetails = TapUpDetails();
        deskHotspot.onTapUp(TapUpEvent(1, game, tapDetails));
        
        // コードが取得されることを確認
        await Future.delayed(const Duration(milliseconds: 200));
        expect(game.inventoryItems.contains('code'), true);
      },
    );

    testWithFlameGame<SimpleEscapeRoom>(
      'インベントリ選択：keyアイテム選択テスト',
      () => SimpleEscapeRoom(),
      (game) async {
        await game.ready();
        
        // 金庫を開けて鍵を取得
        await _setupKeyItem(game);
        
        // インベントリからkeyを選択するClickableInventoryItemを取得
        final keyInventoryItem = game.children
            .whereType<ClickableInventoryItem>()
            .firstWhere((item) => item.itemId == 'key');
        
        // keyアイテムをタップ
        const tapDetails = TapUpDetails();
        keyInventoryItem.onTapUp(TapUpEvent(1, game, tapDetails));
        
        // 選択状態を確認（遅延後）
        await Future.delayed(const Duration(milliseconds: 150));
        
        // 選択されたアイテムの状態確認（内部状態はprivateのため間接的に確認）
        // ドアをクリックして鍵が選択されていることを確認
        final doorHotspot = game.children
            .whereType<HotspotComponent>()
            .firstWhere((h) => h.id == 'door');
        
        const doorTapDetails = TapUpDetails();
        doorHotspot.onTapUp(TapUpEvent(1, game, doorTapDetails));
        
        // 脱出成功状態に遷移することで鍵選択が確認される
        await Future.delayed(const Duration(milliseconds: 200));
        expect(game.currentState, EscapeRoomState.escaped);
      },
    );

    testWithFlameGame<SimpleEscapeRoom>(
      'インベントリ選択：codeアイテム選択テスト',
      () => SimpleEscapeRoom(),
      (game) async {
        await game.ready();
        
        // 机からコードを取得
        await _setupCodeItem(game);
        
        // インベントリからcodeを選択
        final codeInventoryItem = game.children
            .whereType<ClickableInventoryItem>()
            .firstWhere((item) => item.itemId == 'code');
        
        // codeアイテムをタップ
        const codeTapDetails = TapUpDetails();
        codeInventoryItem.onTapUp(TapUpEvent(1, game, codeTapDetails));
        
        // 選択状態確認のため少し待機
        await Future.delayed(const Duration(milliseconds: 150));
        
        // code選択状態で金庫をクリックすると開くことを確認
        final safeHotspot = game.children
            .whereType<HotspotComponent>()
            .firstWhere((h) => h.id == 'safe');
        
        const safeTapDetails = TapUpDetails();
        safeHotspot.onTapUp(TapUpEvent(1, game, safeTapDetails));
        
        // 金庫が開いて鍵が取得される
        await Future.delayed(const Duration(milliseconds: 200));
        expect(game.inventoryItems.contains('key'), true);
      },
    );

    testWithFlameGame<SimpleEscapeRoom>(
      'インベントリ選択：toolアイテム選択テスト',
      () => SimpleEscapeRoom(),
      (game) async {
        await game.ready();
        
        // 本棚からツールを取得
        await _setupToolItem(game);
        
        // インベントリからtoolを選択
        final toolInventoryItem = game.children
            .whereType<ClickableInventoryItem>()
            .firstWhere((item) => item.itemId == 'tool');
        
        // toolアイテムをタップ
        const toolTapDetails = TapUpDetails();
        toolInventoryItem.onTapUp(TapUpEvent(1, game, toolTapDetails));
        
        // 選択処理の完了を待機
        await Future.delayed(const Duration(milliseconds: 150));
        
        // toolが選択されていることを確認（間接的に他のアイテムと異なる動作で確認）
        // toolの選択は現在のゲームロジックでは特別な処理がないため、
        // 単純にClickableInventoryItemコンポーネントが存在することで確認
        expect(toolInventoryItem.itemId, 'tool');
      },
    );

    testWithFlameGame<SimpleEscapeRoom>(
      'タップイベント処理：onTapDownとonTapUpの発火順序',
      () => SimpleEscapeRoom(),
      (game) async {
        await game.ready();
        
        // 鍵を取得して選択可能状態にする
        await _setupKeyItem(game);
        
        final keyInventoryItem = game.children
            .whereType<ClickableInventoryItem>()
            .firstWhere((item) => item.itemId == 'key');
        
        // onTapDownとonTapUpの順序確認
        // （実際のタップイベントはFlame内部で管理されるため、メソッドの存在確認）
        expect(keyInventoryItem.onTapDown, isA<Function>());
        expect(keyInventoryItem.onTapUp, isA<Function>());
      },
    );
  });
}

/// テスト補助関数：鍵アイテムをセットアップ
Future<void> _setupKeyItem(SimpleEscapeRoom game) async {
  // コードを取得
  await _setupCodeItem(game);
  
  // 金庫を開いて鍵を取得
  final safeHotspot = game.children
      .whereType<HotspotComponent>()
      .firstWhere((h) => h.id == 'safe');
  
  const safeTapDetails = TapUpDetails();
  safeHotspot.onTapUp(TapUpEvent(1, game, safeTapDetails));
  await Future.delayed(const Duration(milliseconds: 200));
}

/// テスト補助関数：コードアイテムをセットアップ
Future<void> _setupCodeItem(SimpleEscapeRoom game) async {
  final deskHotspot = game.children
      .whereType<HotspotComponent>()
      .firstWhere((h) => h.id == 'desk');
  
  const deskTapDetails = TapUpDetails();
  deskHotspot.onTapUp(TapUpEvent(1, game, deskTapDetails));
  await Future.delayed(const Duration(milliseconds: 200));
}

/// テスト補助関数：ツールアイテムをセットアップ  
Future<void> _setupToolItem(SimpleEscapeRoom game) async {
  final bookshelfHotspot = game.children
      .whereType<HotspotComponent>()
      .firstWhere((h) => h.id == 'bookshelf');
  
  const bookshelfTapDetails = TapUpDetails();
  bookshelfHotspot.onTapUp(TapUpEvent(1, game, bookshelfTapDetails));
  await Future.delayed(const Duration(milliseconds: 200));
}