import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../components/inventory_manager.dart';
import 'ui_system.dart';
import 'japanese_message_system.dart';

/// クリック可能アイテムコンポーネント
/// 移植ガイド準拠実装
class ClickableInventoryItem extends RectangleComponent with TapCallbacks {
  final String itemId;
  final GameItem item;
  final Function(String) onItemTapped;
  bool _isSelected = false;
  
  ClickableInventoryItem({
    required this.itemId,
    required this.item,
    required this.onItemTapped,
    required Vector2 position,
    required Vector2 size,
  }) : super(
    position: position,
    size: size,
    paint: Paint()..color = Colors.grey.shade700,
  );
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    priority = InventoryUILayerPriority.inventoryItems;
    _setupItemUI();
  }
  
  /// アイテムUI設定
  void _setupItemUI() {
    // アイテム背景
    paint = Paint()..color = Colors.grey.shade700;
    
    // アイテム名表示
    final nameComponent = JapaneseMessageSystem.createMessageComponent(
      itemId,
      position: Vector2(size.x / 2, size.y / 2),
      fontSize: size.y * 0.2,
      color: Colors.white,
      anchor: Anchor.center,
    );
    add(nameComponent);
    
    // 選択状態の枠線
    final borderComponent = RectangleComponent(
      size: size,
      position: Vector2.zero(),
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );
    borderComponent.priority = InventoryUILayerPriority.inventoryItems + 1;
    add(borderComponent);
  }
  
  /// タップ処理
  @override
  bool onTapUp(TapUpEvent event) {
    onItemTapped(itemId);
    return true;
  }
  
  /// 選択状態更新
  void updateSelectionState(bool isSelected) {
    _isSelected = isSelected;
    
    // 背景色変更
    paint = Paint()..color = _isSelected 
        ? Colors.yellow.shade700 
        : Colors.grey.shade700;
    
    // 枠線色変更
    final childList = children.toList();
    if (childList.length > 1 && childList[1] is RectangleComponent) {
      final borderComponent = childList[1] as RectangleComponent;
      borderComponent.paint = Paint()
        ..color = _isSelected ? Colors.yellow : Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
    }
  }
}