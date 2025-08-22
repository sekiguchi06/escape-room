import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'responsive_layout_calculator.dart';
import 'ui_system.dart';
import 'japanese_message_system.dart';

/// インベントリレンダリング専用クラス
/// 表示ロジック専任での責任分離
class InventoryRenderer {
  final ResponsiveLayoutCalculator layoutCalculator;
  final Vector2 screenSize;

  InventoryRenderer({required this.layoutCalculator, required this.screenSize});

  /// インベントリ背景を作成
  RectangleComponent createInventoryBackground() {
    final inventoryArea = layoutCalculator.calculateInventoryArea();
    final inventoryPos = layoutCalculator.calculateInventoryPosition();

    return RectangleComponent(
      size: inventoryArea,
      position: inventoryPos,
      paint: Paint()..color = Colors.black.withValues(alpha: 0.9),
    )..priority = InventoryUILayerPriority.inventoryBackground;
  }

  /// インベントリタイトルを作成
  TextComponent createInventoryTitle() {
    final inventoryPos = layoutCalculator.calculateInventoryPosition();
    final inventoryArea = layoutCalculator.calculateInventoryArea();

    // 確実に中央配置するため、直接TextComponentを作成
    final titleComponent = TextComponent(
      text: JapaneseMessageSystem.getMessage('inventory_title'),
      textRenderer: JapaneseFontSystem.getTextPaint(
        screenSize.y * 0.025,
        Colors.yellow,
        FontWeight.bold,
      ),
      position: Vector2(
        inventoryPos.x + inventoryArea.x / 2,
        inventoryPos.y + inventoryArea.y * 0.15,
      ),
      anchor: Anchor.center,
    );
    titleComponent.priority = InventoryUILayerPriority.inventoryItems;
    return titleComponent;
  }

  /// 矢印ボタンを作成
  List<Component> createNavigationArrows(
    VoidCallback onLeftPressed,
    VoidCallback onRightPressed,
  ) {
    final components = <Component>[];

    // 左矢印ボタン
    components.addAll(
      _createArrowButton(
        '◀',
        layoutCalculator.calculateLeftArrowPosition(),
        layoutCalculator.calculateArrowSize(),
        Colors.grey.shade600,
        onLeftPressed,
      ),
    );

    // 右矢印ボタン
    components.addAll(
      _createArrowButton(
        '▶',
        layoutCalculator.calculateRightArrowPosition(),
        layoutCalculator.calculateArrowSize(),
        Colors.grey.shade600,
        onRightPressed,
      ),
    );

    return components;
  }

  /// 矢印ボタン作成ヘルパー
  List<Component> _createArrowButton(
    String text,
    Vector2 position,
    Vector2 size,
    Color color,
    VoidCallback onPressed,
  ) {
    // ボタン背景
    final buttonBg = RectangleComponent(
      size: size,
      position: position,
      paint: Paint()..color = color,
    );
    buttonBg.priority = InventoryUILayerPriority.inventoryItems;

    // ボタンテキスト（矢印）
    final buttonText = TextComponent(
      text: text,
      textRenderer: JapaneseFontSystem.getTextPaint(
        size.y * 0.4,
        Colors.white,
        FontWeight.bold,
      ),
      position: Vector2(position.x + size.x / 2, position.y + size.y / 2),
      anchor: Anchor.center,
    );
    buttonText.priority = InventoryUILayerPriority.inventoryItems + 1;

    return [buttonBg, buttonText];
  }

  /// 空インベントリメッセージを作成
  TextComponent createEmptyMessage() {
    final inventoryPos = layoutCalculator.calculateInventoryPosition();
    final inventoryArea = layoutCalculator.calculateInventoryArea();

    final emptyComponent = JapaneseMessageSystem.createMessageComponent(
      'inventory_empty',
      position: Vector2(
        inventoryPos.x + inventoryArea.x / 2,
        inventoryPos.y + inventoryArea.y / 2,
      ),
      fontSize: screenSize.y * 0.025,
      color: Colors.grey,
      anchor: Anchor.center,
    );
    emptyComponent.priority = InventoryUILayerPriority.inventoryItems;
    return emptyComponent;
  }
}
