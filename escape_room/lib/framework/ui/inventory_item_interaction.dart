import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'ui_system.dart';
import 'japanese_message_system.dart';

/// インベントリアイテムインタラクション専用クラス
/// 選択状態・ツールチップ・タップ処理を担当
class InventoryItemInteraction {
  final PositionComponent parent;
  final String itemId;
  final Vector2 size;
  final Function(String) onItemTapped;

  bool isSelected = false;
  late final RectangleComponent _selectionIndicator;

  InventoryItemInteraction({
    required this.parent,
    required this.itemId,
    required this.size,
    required this.onItemTapped,
  });

  /// インタラクション初期化
  void initialize() {
    _setupSelectionIndicator();
  }

  /// 選択インジケーターを設定
  void _setupSelectionIndicator() {
    _selectionIndicator = RectangleComponent(
      size: size,
      position: Vector2.zero(),
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _selectionIndicator.priority = InventoryUILayerPriority.selectedItem;
    parent.add(_selectionIndicator);

    // 初期状態は非表示
    _updateSelectionVisual();
  }

  /// タップ処理実行
  void handleTap() {
    onItemTapped(itemId);
  }

  /// 選択状態を更新
  void updateSelectionState(bool selected) {
    if (isSelected != selected) {
      isSelected = selected;
      // onLoad完了後のみビジュアル更新
      if (parent.isMounted) {
        _updateSelectionVisual();
      }
    }
  }

  /// 選択状態のビジュアルを更新
  void _updateSelectionVisual() {
    if (isSelected) {
      _selectionIndicator.paint
        ..color = Colors.yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      // 背景色も更新
      _updateParentBackground(Colors.grey.shade600);
    } else {
      _selectionIndicator.paint
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      // 背景色をリセット
      _updateParentBackground(Colors.grey.shade800);
    }
  }

  /// 親コンポーネントの背景色を更新
  void _updateParentBackground(Color color) {
    final backgroundComponents = parent.children
        .whereType<RectangleComponent>()
        .where(
          (comp) => comp.priority == InventoryUILayerPriority.inventoryItems,
        );

    for (final bg in backgroundComponents) {
      bg.paint.color = color;
    }
  }

  /// ツールチップ表示
  void showTooltip(String description) {
    final tooltipComponent = TextComponent(
      text: description,
      textRenderer: JapaneseFontSystem.getTextPaint(12, Colors.white),
      position: Vector2(size.x / 2, -20),
      anchor: Anchor.center,
    );
    tooltipComponent.priority = InventoryUILayerPriority.itemTooltip;
    parent.add(tooltipComponent);
  }

  /// ツールチップ非表示
  void hideTooltip() {
    final tooltipsToRemove = parent.children
        .where(
          (component) =>
              component.priority == InventoryUILayerPriority.itemTooltip,
        )
        .toList();

    for (final tooltip in tooltipsToRemove) {
      tooltip.removeFromParent();
    }
  }
}
