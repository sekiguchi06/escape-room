import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../components/inventory_manager.dart';
import 'ui_system.dart';
import 'japanese_message_system.dart';

/// インベントリアイテムレンダリング専用クラス
/// 画像・色アイコン・テキストの描画処理を担当
class InventoryItemRenderer {
  final PositionComponent parent;
  final String itemId;
  final GameItem item;
  final Vector2 size;
  
  late final RectangleComponent _backgroundComponent;
  late final RectangleComponent? _iconComponent;
  late final TextComponent _nameComponent;
  
  InventoryItemRenderer({
    required this.parent,
    required this.itemId,
    required this.item,
    required this.size,
  });
  
  /// レンダリング実行
  Future<void> render() async {
    await _renderBackground();
    await _renderIcon();
    _renderText();
  }
  
  /// 背景を描画
  Future<void> _renderBackground() async {
    _backgroundComponent = RectangleComponent(
      size: size,
      position: Vector2.zero(),
      paint: Paint()..color = Colors.grey.shade800,
    );
    _backgroundComponent.priority = InventoryUILayerPriority.inventoryItems;
    parent.add(_backgroundComponent);
  }
  
  /// アイコンを描画（画像優先、フォールバック色アイコン）
  Future<void> _renderIcon() async {
    await _renderItemImage();
  }
  
  /// 画像アイコンを描画（モーダル表示と同じ画像パスを使用）
  Future<void> _renderItemImage() async {
    try {
      final iconSize = Vector2(size.x * 0.8, size.y * 0.8);
      final iconPosition = Vector2(
        (size.x - iconSize.x) / 2,
        (size.y - iconSize.y) / 2,
      );
      
      // モーダルと同じ画像パスを使用: assets/images/items/{itemId}.png  
      final modalImagePath = 'items/$itemId.png';
      final sprite = await Sprite.load(modalImagePath);
      final spriteComponent = SpriteComponent(
        sprite: sprite,
        size: iconSize,
        position: iconPosition,
      );
      spriteComponent.priority = InventoryUILayerPriority.inventoryItems + 1;
      parent.add(spriteComponent);
      
    } catch (e) {
      // 画像読み込み失敗時は色アイコンで代替（テスト環境含む）
      _renderColorIcon();
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
    _iconComponent!.priority = InventoryUILayerPriority.inventoryItems + 1;
    parent.add(_iconComponent!);
  }
  
  /// テキストを描画
  void _renderText() {
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
    parent.add(_nameComponent);
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
    _nameComponent.text = newItem.name;
    
    // アイコン色更新
    if (_iconComponent != null) {
      _iconComponent!.paint.color = _getItemColor();
    }
  }
  
  /// 背景色を更新
  void updateBackgroundColor(Color color) {
    _backgroundComponent.paint.color = color;
  }
}