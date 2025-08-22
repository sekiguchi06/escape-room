import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// 縦画面固定レイアウトシステム
/// Strategy Pattern不使用、シンプル設計
/// Component-based Design + Single Responsibility Principle適用
class MobilePortraitLayout {
  // 5分割レイアウト定数（移植ガイド準拠）
  static const double menuRatio = 0.1; // 10%: メニューバー
  static const double gameRatio = 0.6; // 60%: ゲーム領域
  static const double inventoryRatio = 0.2; // 20%: インベントリ
  static const double adRatio = 0.1; // 10%: 広告エリア

  /// レイアウト計算実行
  static PortraitLayoutResult calculateLayout(Vector2 screenSize) {
    // 実行環境判定: Web環境の場合はiPhone15サイズに固定
    Vector2 targetSize;
    if (kIsWeb) {
      // iPhone15サイズ: 393x852 (CSS pixels)
      targetSize = Vector2(393, 852);
      debugPrint(
        '📱 Web environment detected: forcing iPhone15 size (393x852)',
      );
    } else {
      // 実機環境: デバイス画面サイズを使用
      targetSize = screenSize;
      debugPrint(
        '📱 Native environment: using device size (${screenSize.x}x${screenSize.y})',
      );
    }

    debugPrint(
      '📱 Portrait layout calculation: ${targetSize.x}x${targetSize.y}',
    );

    final menuArea = LayoutArea(
      position: Vector2.zero(),
      size: Vector2(targetSize.x, targetSize.y * menuRatio),
      areaName: 'menu',
    );

    final gameArea = LayoutArea(
      position: Vector2(0, targetSize.y * menuRatio),
      size: Vector2(targetSize.x, targetSize.y * gameRatio),
      areaName: 'game',
    );

    final inventoryArea = LayoutArea(
      position: Vector2(0, targetSize.y * (menuRatio + gameRatio)),
      size: Vector2(targetSize.x, targetSize.y * inventoryRatio),
      areaName: 'inventory',
    );

    final adArea = LayoutArea(
      position: Vector2(
        0,
        targetSize.y * (menuRatio + gameRatio + inventoryRatio),
      ),
      size: Vector2(targetSize.x, targetSize.y * adRatio),
      areaName: 'ad',
    );

    return PortraitLayoutResult(
      screenSize: targetSize,
      menuArea: menuArea,
      gameArea: gameArea,
      inventoryArea: inventoryArea,
      adArea: adArea,
    );
  }
}

/// 縦画面レイアウト結果
/// Single Responsibility Principle適用
class PortraitLayoutResult {
  final Vector2 screenSize;
  final LayoutArea menuArea;
  final LayoutArea gameArea;
  final LayoutArea inventoryArea;
  final LayoutArea adArea;

  const PortraitLayoutResult({
    required this.screenSize,
    required this.menuArea,
    required this.gameArea,
    required this.inventoryArea,
    required this.adArea,
  });

  /// デバッグ情報
  Map<String, dynamic> toDebugMap() {
    return {
      'screenSize': '${screenSize.x}x${screenSize.y}',
      'menuArea': menuArea.toDebugString(),
      'gameArea': gameArea.toDebugString(),
      'inventoryArea': inventoryArea.toDebugString(),
      'adArea': adArea.toDebugString(),
    };
  }

  @override
  String toString() {
    return 'PortraitLayoutResult(screen: ${screenSize.x}x${screenSize.y})';
  }
}

/// レイアウト領域定義
/// Component-based設計、再利用可能
class LayoutArea {
  final Vector2 position;
  final Vector2 size;
  final String areaName;

  const LayoutArea({
    required this.position,
    required this.size,
    required this.areaName,
  });

  /// 相対位置を絶対位置に変換
  Vector2 getRelativePosition(double x, double y) {
    return Vector2(position.x + (size.x * x), position.y + (size.y * y));
  }

  /// 相対サイズを絶対サイズに変換
  Vector2 getRelativeSize(double width, double height) {
    return Vector2(size.x * width, size.y * height);
  }

  /// 中央位置計算
  Vector2 get center =>
      Vector2(position.x + size.x / 2, position.y + size.y / 2);

  /// 領域内判定
  bool containsPoint(Vector2 point) {
    return point.x >= position.x &&
        point.x <= position.x + size.x &&
        point.y >= position.y &&
        point.y <= position.y + size.y;
  }

  String toDebugString() {
    return '$areaName: ${size.x}x${size.y} at ${position.x},${position.y}';
  }
}

/// 縦画面インベントリレイアウト計算機
/// Composition over Inheritance適用
class PortraitInventoryLayoutCalculator {
  final PortraitLayoutResult layoutResult;
  final int maxItems;

  // アイテムレイアウト設定
  static const int maxItemsPerRow = 4;
  static const double itemSpacingRatio = 0.05; // インベントリ幅の5%
  static const double marginRatio = 0.02; // インベントリ幅の2%

  const PortraitInventoryLayoutCalculator({
    required this.layoutResult,
    required this.maxItems,
  });

  /// アイテムサイズ計算
  Vector2 calculateItemSize(int itemCount) {
    final inventoryArea = layoutResult.inventoryArea;
    final itemsPerRow = (itemCount > maxItemsPerRow)
        ? maxItemsPerRow
        : itemCount;

    if (itemsPerRow <= 0) return Vector2.zero();

    final spacing = inventoryArea.size.x * itemSpacingRatio;
    final totalSpacing = spacing * (itemsPerRow + 1);
    final itemWidth = (inventoryArea.size.x - totalSpacing) / itemsPerRow;
    final itemHeight = inventoryArea.size.y * 0.6; // インベントリ高さの60%

    return Vector2(itemWidth, itemHeight);
  }

  /// アイテム位置リスト計算
  List<Vector2> calculateItemPositions(int itemCount) {
    final positions = <Vector2>[];
    final inventoryArea = layoutResult.inventoryArea;
    final itemSize = calculateItemSize(itemCount);
    final spacing = inventoryArea.size.x * itemSpacingRatio;

    for (int i = 0; i < itemCount; i++) {
      final row = i ~/ maxItemsPerRow;
      final col = i % maxItemsPerRow;

      final x =
          inventoryArea.position.x + spacing + col * (itemSize.x + spacing);
      final y =
          inventoryArea.position.y +
          (inventoryArea.size.y * 0.2) +
          row * (itemSize.y + spacing * 0.5);

      positions.add(Vector2(x, y));
    }

    return positions;
  }

  /// スクロール必要性判定
  bool shouldShowScrollIndicator() {
    final maxVisibleItems = maxItemsPerRow * 2; // 2行まで表示可能
    return maxItems > maxVisibleItems;
  }

  /// ナビゲーション矢印位置計算
  Map<String, Vector2> calculateNavigationPositions() {
    final inventoryArea = layoutResult.inventoryArea;

    return {
      'leftArrow': Vector2(
        inventoryArea.position.x + inventoryArea.size.x * marginRatio,
        inventoryArea.position.y + inventoryArea.size.y * 0.25,
      ),
      'rightArrow': Vector2(
        inventoryArea.position.x + inventoryArea.size.x * 0.85,
        inventoryArea.position.y + inventoryArea.size.y * 0.25,
      ),
    };
  }

  /// インベントリレイアウト情報をまとめて取得
  InventoryLayoutInfo calculateInventoryLayout(int itemCount) {
    return InventoryLayoutInfo(
      itemSize: calculateItemSize(itemCount),
      itemPositions: calculateItemPositions(itemCount),
      navigationPositions: calculateNavigationPositions(),
      shouldShowScroll: shouldShowScrollIndicator(),
      inventoryArea: layoutResult.inventoryArea,
    );
  }
}

/// インベントリレイアウト情報
/// Single Responsibility Principle適用
class InventoryLayoutInfo {
  final Vector2 itemSize;
  final List<Vector2> itemPositions;
  final Map<String, Vector2> navigationPositions;
  final bool shouldShowScroll;
  final LayoutArea inventoryArea;

  const InventoryLayoutInfo({
    required this.itemSize,
    required this.itemPositions,
    required this.navigationPositions,
    required this.shouldShowScroll,
    required this.inventoryArea,
  });

  /// アイテム総数
  int get itemCount => itemPositions.length;

  /// 表示可能行数
  int get visibleRows =>
      (itemCount / PortraitInventoryLayoutCalculator.maxItemsPerRow).ceil();

  /// 特定インデックスのアイテム位置取得
  Vector2? getItemPosition(int index) {
    if (index >= 0 && index < itemPositions.length) {
      return itemPositions[index];
    }
    return null;
  }

  /// 座標からアイテムインデックス取得（タップ判定用）
  int? getItemIndexFromPosition(Vector2 tapPosition) {
    for (int i = 0; i < itemPositions.length; i++) {
      final itemPos = itemPositions[i];
      final itemRect = ui.Rect.fromLTWH(
        itemPos.x,
        itemPos.y,
        itemSize.x,
        itemSize.y,
      );

      if (itemRect.contains(ui.Offset(tapPosition.x, tapPosition.y))) {
        return i;
      }
    }
    return null;
  }

  /// デバッグ情報
  Map<String, dynamic> toDebugMap() {
    return {
      'itemCount': itemCount,
      'itemSize': '${itemSize.x}x${itemSize.y}',
      'visibleRows': visibleRows,
      'shouldShowScroll': shouldShowScroll,
      'inventoryArea': inventoryArea.toDebugString(),
      'navigationCount': navigationPositions.length,
    };
  }
}

/// レイアウトコンポーネント（シンプル版）
/// Component-based Design適用、Strategy Pattern不使用
class PortraitLayoutComponent extends Component {
  PortraitLayoutResult? _currentLayout;
  Vector2 _currentScreenSize = Vector2.zero();

  /// レイアウト計算実行
  PortraitLayoutResult? calculateLayout(Vector2 screenSize) {
    try {
      _currentScreenSize = screenSize;
      _currentLayout = MobilePortraitLayout.calculateLayout(screenSize);
      debugPrint(
        '📐 Portrait layout calculated: ${screenSize.x}x${screenSize.y}',
      );
      return _currentLayout;
    } catch (e) {
      debugPrint('❌ Layout calculation error: $e');
      return null;
    }
  }

  /// 現在のレイアウト取得
  PortraitLayoutResult? get currentLayout => _currentLayout;

  /// 画面サイズ変更処理
  bool updateScreenSize(Vector2 newScreenSize) {
    if (_currentScreenSize != newScreenSize) {
      debugPrint(
        '📐 Screen size changed: ${_currentScreenSize.x}x${_currentScreenSize.y} → ${newScreenSize.x}x${newScreenSize.y}',
      );

      final newLayout = calculateLayout(newScreenSize);
      if (newLayout != null) {
        _currentScreenSize = newScreenSize;
        return true; // レイアウト変更あり
      }
    }
    return false; // レイアウト変更なし
  }

  /// デバッグ情報取得
  Map<String, dynamic> getDebugInfo() {
    return {
      'currentScreenSize': '${_currentScreenSize.x}x${_currentScreenSize.y}',
      'currentLayout': _currentLayout?.toDebugMap() ?? 'none',
    };
  }

  @override
  String toString() {
    return 'PortraitLayoutComponent(${_currentScreenSize.x}x${_currentScreenSize.y})';
  }
}
