import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../components/inventory_manager.dart';
import 'inventory_item_renderer.dart';
import 'inventory_item_interaction.dart';

/// インベントリアイテムコンポーネント（統合制御）
/// レンダリングとインタラクションを統合管理
class InventoryItemComponent extends PositionComponent with TapCallbacks {
  final String itemId;
  final GameItem item;
  final Function(String) onItemTapped;

  late final InventoryItemRenderer _renderer;
  late final InventoryItemInteraction _interaction;

  InventoryItemComponent({
    required this.itemId,
    required this.item,
    required this.onItemTapped,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _initializeComponents();
  }

  /// コンポーネント初期化
  Future<void> _initializeComponents() async {
    // レンダリング担当
    _renderer = InventoryItemRenderer(
      parent: this,
      itemId: itemId,
      item: item,
      size: size,
    );

    // インタラクション担当
    _interaction = InventoryItemInteraction(
      parent: this,
      itemId: itemId,
      size: size,
      onItemTapped: onItemTapped,
    );

    // 初期化実行
    await _renderer.render();
    _interaction.initialize();
  }

  @override
  void onTapUp(TapUpEvent event) {
    _interaction.handleTap();
    // Flame推奨：継続非伝播
  }

  /// 選択状態を更新（外部から呼び出し）
  void updateSelectionState(bool selected) {
    // 初期化完了後のみ更新
    if (isMounted) {
      try {
        _interaction.updateSelectionState(selected);
      } catch (e) {
        // 初期化前の場合は無視
      }
    }
  }

  /// 選択状態を取得
  bool get isSelected {
    try {
      return _interaction.isSelected;
    } catch (e) {
      return false; // 初期化前はfalse
    }
  }

  /// アイテム情報を更新（外部から呼び出し）
  void updateItem(GameItem newItem) {
    _renderer.updateItem(newItem);
  }

  /// ツールチップ表示（外部から呼び出し）
  void showTooltip() {
    _interaction.showTooltip(item.description);
  }

  /// ツールチップ非表示（外部から呼び出し）
  void hideTooltip() {
    _interaction.hideTooltip();
  }
}
