import 'package:flame/components.dart';

/// レスポンシブレイアウト計算機
/// スマートフォン縦型レイアウト専用の座標・サイズ計算
class ResponsiveLayoutCalculator {
  final Vector2 screenSize;
  final int maxItems;

  // スマートフォン縦型特化定数
  static const Map<String, double> _mobilePortraitRatios = {
    'inventoryArea': 0.2,
    'itemSpacing': 0.05,
    'marginRatio': 0.02,
  };

  static const int maxItemsPerRow = 4;

  ResponsiveLayoutCalculator({
    required this.screenSize,
    required this.maxItems,
  });

  /// インベントリエリアのサイズを計算
  Vector2 calculateInventoryArea() {
    final height = screenSize.y * _mobilePortraitRatios['inventoryArea']!;
    return Vector2(screenSize.x, height);
  }

  /// インベントリエリアの位置を計算（画面下部）
  Vector2 calculateInventoryPosition() {
    final topMenuHeight = screenSize.y * 0.1;
    final gameAreaHeight = screenSize.y * 0.6;

    return Vector2(0, topMenuHeight + gameAreaHeight);
  }

  /// 個別アイテムのサイズを計算
  Vector2 calculateItemSize(int itemCount) {
    final inventoryArea = calculateInventoryArea();
    final itemsPerRow = (itemCount > maxItemsPerRow)
        ? maxItemsPerRow
        : itemCount;
    final spacing = inventoryArea.x * _mobilePortraitRatios['itemSpacing']!;
    final totalSpacing = spacing * (itemsPerRow + 1);
    final itemWidth = (inventoryArea.x - totalSpacing) / itemsPerRow;
    final itemHeight = inventoryArea.y * 0.6; // インベントリ高さの60%

    return Vector2(itemWidth, itemHeight);
  }

  /// アイテムの位置リストを計算
  List<Vector2> calculateItemPositions(int itemCount) {
    final positions = <Vector2>[];
    final inventoryArea = calculateInventoryArea();
    final inventoryPos = calculateInventoryPosition();
    final itemSize = calculateItemSize(itemCount);
    final spacing = inventoryArea.x * _mobilePortraitRatios['itemSpacing']!;

    for (int i = 0; i < itemCount; i++) {
      final row = i ~/ maxItemsPerRow;
      final col = i % maxItemsPerRow;

      final x = inventoryPos.x + spacing + col * (itemSize.x + spacing);
      final y =
          inventoryPos.y +
          inventoryArea.y * 0.2 +
          row * (itemSize.y + spacing * 0.5);

      positions.add(Vector2(x, y));
    }

    return positions;
  }

  /// スクロールインジケーターが必要かチェック
  bool shouldShowScrollIndicator() {
    final maxVisibleItems = maxItemsPerRow * 2; // 2行まで表示
    return maxItems > maxVisibleItems;
  }

  /// ナビゲーション矢印の位置を計算
  Vector2 calculateLeftArrowPosition() {
    final inventoryPos = calculateInventoryPosition();
    final inventoryArea = calculateInventoryArea();

    return Vector2(
      inventoryPos.x + inventoryArea.x * 0.02,
      inventoryPos.y + inventoryArea.y * 0.25,
    );
  }

  /// ナビゲーション矢印のサイズを計算
  Vector2 calculateArrowSize() {
    final inventoryArea = calculateInventoryArea();
    return Vector2(inventoryArea.x * 0.15, inventoryArea.y * 0.5);
  }

  /// 右矢印の位置を計算
  Vector2 calculateRightArrowPosition() {
    final inventoryPos = calculateInventoryPosition();
    final inventoryArea = calculateInventoryArea();
    final buttonWidth = inventoryArea.x * 0.15;

    return Vector2(
      inventoryPos.x + inventoryArea.x - buttonWidth - inventoryArea.x * 0.02,
      inventoryPos.y + inventoryArea.y * 0.25,
    );
  }
}
