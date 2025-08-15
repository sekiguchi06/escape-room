import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../components/inventory_manager.dart';
import 'ui_system.dart';
import 'japanese_message_system.dart';
import 'html_text_overlay.dart';

/// インベントリアイテムコンポーネント（個別アイテム）
/// 個別アイテムの表示・選択状態・タップ処理を担当
class InventoryItemComponent extends PositionComponent with TapCallbacks {
  final String itemId;
  final GameItem item;
  final Function(String) onItemTapped;
  bool isSelected = false;
  
  late final RectangleComponent _backgroundComponent;
  late final RectangleComponent _iconComponent;
  late final TextComponent _nameComponent;
  late final RectangleComponent _selectionIndicator;
  
  InventoryItemComponent({
    required this.itemId,
    required this.item,
    required this.onItemTapped,
    required Vector2 position,
    required Vector2 size,
  }) : super(
    position: position,
    size: size,
  );
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _renderItemIcon();
    _renderSelectionIndicator();
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    onItemTapped(itemId);
    // Flame推奨：継続非伝播
  }
  
  /// アイテムアイコンを描画（画像表示対応）
  void _renderItemIcon() {
    // アイテム背景
    _backgroundComponent = RectangleComponent(
      size: size,
      position: Vector2.zero(),
      paint: Paint()..color = Colors.grey.shade800,
    );
    _backgroundComponent.priority = InventoryUILayerPriority.inventoryItems;
    add(_backgroundComponent);
    
    // 画像表示（アイテムに画像パスがある場合）
    if (item.imagePath.isNotEmpty) {
      _renderItemImage();
    } else {
      _renderColorIcon();
    }
    
    // アイテム名表示（シンプルなTextComponent）
    _nameComponent = TextComponent(
      text: item.name,
      textRenderer: JapaneseFontSystem.getTextPaint(
        size.y * 0.15, 
        Colors.white, 
        FontWeight.bold
      ),
      position: Vector2(size.x / 2, size.y * 0.9),
      anchor: Anchor.center,
    );
    _nameComponent.priority = InventoryUILayerPriority.inventoryItems + 2;
    add(_nameComponent);
  }
  
  /// 画像アイコンを描画
  Future<void> _renderItemImage() async {
    try {
      final iconSize = Vector2(size.x * 0.8, size.y * 0.8);
      final iconPosition = Vector2(
        (size.x - iconSize.x) / 2,
        (size.y - iconSize.y) / 2,
      );
      
      final sprite = await Sprite.load(item.imagePath);
      final spriteComponent = SpriteComponent(
        sprite: sprite,
        size: iconSize,
        position: iconPosition,
      );
      spriteComponent.priority = InventoryUILayerPriority.inventoryItems + 1;
      add(spriteComponent);
      
    } catch (e) {
      debugPrint('❌ Failed to load item image ${item.imagePath}: $e');
      _renderColorIcon(); // フォールバック：色アイコン
    }
  }
  
  /// 色アイコンを描画（フォールバック）
  void _renderColorIcon() {
    final iconSize = Vector2(size.x * 0.8, size.y * 0.8);
    final iconPosition = Vector2(
      (size.x - iconSize.x) / 2,
      (size.y - iconSize.y) / 2,
    );
    
    _iconComponent = RectangleComponent(
      size: iconSize,
      position: iconPosition,
      paint: Paint()..color = _getItemColor(),
    );
    _iconComponent.priority = InventoryUILayerPriority.inventoryItems + 1;
    add(_iconComponent);
  }
  
  /// 選択インジケーターを描画
  void _renderSelectionIndicator() {
    // 選択状態の枠線
    _selectionIndicator = RectangleComponent(
      size: size,
      position: Vector2.zero(),
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _selectionIndicator.priority = InventoryUILayerPriority.selectedItem;
    add(_selectionIndicator);
    
    // 初期状態は非表示
    _updateSelectionVisual();
  }
  
  /// 選択状態を更新
  void updateSelectionState(bool selected) {
    if (isSelected != selected) {
      isSelected = selected;
      _updateSelectionVisual();
    }
  }
  
  /// 選択状態のビジュアルを更新
  void _updateSelectionVisual() {
    if (isSelected) {
      _selectionIndicator.paint
        ..color = Colors.yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      _backgroundComponent.paint.color = Colors.grey.shade600;
    } else {
      _selectionIndicator.paint
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      _backgroundComponent.paint.color = Colors.grey.shade800;
    }
  }
  
  /// アイテムタイプに基づく色を取得
  Color _getItemColor() {
    switch (itemId) {
      case 'key':
        return Colors.amber;
      case 'tool':
        return Colors.brown;
      case 'code':
        return Colors.blue.shade200;
      default:
        return Colors.grey.shade400;
    }
  }
  
  /// アイテム情報を更新
  void updateItem(GameItem newItem) {
    // アイテム名更新
    _nameComponent.text = newItem.name;
    
    // アイコン色更新
    _iconComponent.paint.color = _getItemColor();
  }
  
  /// ツールチップ表示
  void showTooltip() {
    final tooltipComponent = TextComponent(
      text: item.description,
      textRenderer: JapaneseFontSystem.getTextPaint(12, Colors.white),
      position: Vector2(size.x / 2, -20),
      anchor: Anchor.center,
    );
    tooltipComponent.priority = InventoryUILayerPriority.itemTooltip;
    add(tooltipComponent);
  }
  
  /// ツールチップ非表示
  void hideTooltip() {
    // ツールチップ用コンポーネントを削除
    final tooltipsToRemove = children.where((component) => 
      component.priority == InventoryUILayerPriority.itemTooltip).toList();
    
    for (final tooltip in tooltipsToRemove) {
      tooltip.removeFromParent();
    }
  }
}