import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../framework/framework.dart';

/// インベントリシステムデモゲーム
/// Webブラウザでの動作確認用
class InventoryDemoGame extends FlameGame {
  late InventoryManager _inventoryManager;
  late InventoryUIComponent _inventoryUI;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // インベントリマネージャーを初期化
    _inventoryManager = InventoryManager(
      maxItems: 4,
      onItemSelected: (itemId) {
        debugPrint('🎯 Item selected in demo: $itemId');
      },
    );

    // インベントリUIコンポーネントを作成
    _inventoryUI = InventoryUIComponent(
      manager: _inventoryManager,
      screenSize: size,
    );

    // UIコンポーネントを追加
    add(_inventoryUI);

    // デモ用アイテムを追加
    await _addDemoItems();
    
    // 背景色を設定
    camera.backdrop.add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.grey.shade900,
    ));
    
    // タイトル表示
    _addDemoTitle();
    
    // 操作説明を追加
    _addInstructions();
  }

  /// デモ用アイテムを追加
  Future<void> _addDemoItems() async {
    // 少し遅延してアイテムを順次追加（デモ効果）
    await Future.delayed(const Duration(milliseconds: 500));
    _inventoryUI.addItem('key');
    
    await Future.delayed(const Duration(milliseconds: 500));
    _inventoryUI.addItem('tool');
    
    await Future.delayed(const Duration(milliseconds: 500));
    _inventoryUI.addItem('code');
  }

  /// デモタイトルを追加
  void _addDemoTitle() {
    final titleComponent = TextComponent(
      text: 'インベントリシステムデモ',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: size.y * 0.04,
          fontWeight: FontWeight.bold,
          fontFamily: 'Noto Sans JP',
        ),
      ),
      position: Vector2(size.x / 2, size.y * 0.05),
      anchor: Anchor.center,
    );
    titleComponent.priority = 1000;
    add(titleComponent);
  }

  /// 操作説明を追加
  void _addInstructions() {
    final instructions = [
      '操作方法:',
      '• アイテムをタップして選択',
      '• 選択されたアイテムは黄色の枠で表示',
      '• 左右の矢印でエリア移動（未実装）',
      '',
      '実装済み機能:',
      '• スマートフォン縦型レイアウト対応',
      '• アイテム表示・選択・状態管理',
      '• 日本語フォント対応',
      '• レスポンシブデザイン',
    ];

    for (int i = 0; i < instructions.length; i++) {
      final instruction = TextComponent(
        text: instructions[i],
        textRenderer: TextPaint(
          style: TextStyle(
            color: instructions[i].isEmpty ? Colors.transparent : 
                   instructions[i].startsWith('•') ? Colors.lightBlue.shade200 :
                   instructions[i].endsWith(':') ? Colors.yellow.shade300 : Colors.white,
            fontSize: size.y * 0.025,
            fontWeight: instructions[i].endsWith(':') ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Noto Sans JP',
          ),
        ),
        position: Vector2(size.x * 0.05, size.y * 0.12 + i * size.y * 0.03),
        anchor: Anchor.topLeft,
      );
      instruction.priority = 1000;
      add(instruction);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    
    // 画面サイズ変更時にインベントリUIを更新
    if (isLoaded && children.contains(_inventoryUI)) {
      _inventoryUI.removeFromParent();
      _inventoryUI = InventoryUIComponent(
        manager: _inventoryManager,
        screenSize: size,
      );
      add(_inventoryUI);
    }
  }
}