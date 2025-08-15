import 'package:flame/components.dart';
import 'ui_system.dart';

/// スマートフォン縦型レイアウトシステム
/// 移植ガイド準拠実装
/// 既存UILayoutManagerを拡張
class MobileLayoutSystem extends UILayoutManager {
  // 5分割レイアウト定義（既存UILayerPriority準拠）
  static const double topMenuRatio = 0.1;      // 10%: メニューバー
  static const double gameAreaRatio = 0.6;     // 60%: ゲーム領域
  static const double inventoryRatio = 0.2;    // 20%: インベントリ
  static const double bannerAdRatio = 0.1;     // 10%: 広告エリア
  
  /// ゲーム領域のサイズと位置を計算
  static Vector2 calculateGameArea(Vector2 screenSize) {
    return Vector2(
      screenSize.x,
      screenSize.y * gameAreaRatio,
    );
  }
  
  /// ゲーム領域のオフセット位置を計算
  static Vector2 calculateGameAreaOffset(Vector2 screenSize) {
    return Vector2(
      0,
      screenSize.y * topMenuRatio,
    );
  }
  
  /// インベントリ領域のサイズと位置を計算
  static Vector2 calculateInventoryArea(Vector2 screenSize) {
    return Vector2(
      screenSize.x,
      screenSize.y * inventoryRatio,
    );
  }
  
  /// インベントリ領域のオフセット位置を計算
  static Vector2 calculateInventoryAreaOffset(Vector2 screenSize) {
    return Vector2(
      0,
      screenSize.y * (topMenuRatio + gameAreaRatio),
    );
  }
  
  /// メニュー領域のサイズと位置を計算
  static Vector2 calculateMenuArea(Vector2 screenSize) {
    return Vector2(
      screenSize.x,
      screenSize.y * topMenuRatio,
    );
  }
  
  /// メニュー領域のオフセット位置を計算
  static Vector2 calculateMenuAreaOffset(Vector2 screenSize) {
    return Vector2.zero();
  }
  
  /// 広告エリアのサイズと位置を計算
  static Vector2 calculateAdArea(Vector2 screenSize) {
    return Vector2(
      screenSize.x,
      screenSize.y * bannerAdRatio,
    );
  }
  
  /// 広告エリアのオフセット位置を計算
  static Vector2 calculateAdAreaOffset(Vector2 screenSize) {
    return Vector2(
      0,
      screenSize.y * (topMenuRatio + gameAreaRatio + inventoryRatio),
    );
  }
  
  /// レイアウト情報をまとめて取得
  static MobileLayoutInfo calculateLayout(Vector2 screenSize) {
    return MobileLayoutInfo(
      screenSize: screenSize,
      menuArea: calculateMenuArea(screenSize),
      menuOffset: calculateMenuAreaOffset(screenSize),
      gameArea: calculateGameArea(screenSize),
      gameOffset: calculateGameAreaOffset(screenSize),
      inventoryArea: calculateInventoryArea(screenSize),
      inventoryOffset: calculateInventoryAreaOffset(screenSize),
      adArea: calculateAdArea(screenSize),
      adOffset: calculateAdAreaOffset(screenSize),
    );
  }
  
  /// レスポンシブ対応: アイテムサイズ計算
  static double calculateItemSize(Vector2 inventoryArea, int maxItemsPerRow) {
    final itemSpacing = 10.0;
    final totalSpacing = (maxItemsPerRow - 1) * itemSpacing;
    final availableWidth = inventoryArea.x - totalSpacing - 20; // マージン考慮
    return availableWidth / maxItemsPerRow;
  }
  
  /// レスポンシブ対応: フォントサイズ計算
  static double calculateFontSize(Vector2 screenSize, double baseFontSize) {
    final scaleFactor = (screenSize.x / 375.0).clamp(0.8, 2.0); // iPhone 6ベース
    return baseFontSize * scaleFactor;
  }
}

/// UI座標計算ヘルパー
class UIPositionCalculator {
  final Vector2 containerSize;
  final Vector2 containerOffset;
  
  const UIPositionCalculator({
    required this.containerSize,
    required this.containerOffset,
  });
  
  /// 相対位置を絶対位置に変換 (0.0-1.0 → ピクセル座標)
  Vector2 getRelativePosition(double x, double y) {
    return Vector2(
      containerOffset.x + (containerSize.x * x),
      containerOffset.y + (containerSize.y * y),
    );
  }
  
  /// 相対サイズを絶対サイズに変換 (0.0-1.0 → ピクセルサイズ)
  Vector2 getRelativeSize(double width, double height) {
    return Vector2(
      containerSize.x * width,
      containerSize.y * height,
    );
  }
  
  /// 中央寄せ位置を計算
  Vector2 getCenterPosition(Vector2 objectSize) {
    return Vector2(
      containerOffset.x + (containerSize.x - objectSize.x) / 2,
      containerOffset.y + (containerSize.y - objectSize.y) / 2,
    );
  }
  
  /// 絶対位置をコンテナ相対位置に変換
  Vector2 toRelativePosition(Vector2 absolutePosition) {
    return Vector2(
      (absolutePosition.x - containerOffset.x) / containerSize.x,
      (absolutePosition.y - containerOffset.y) / containerSize.y,
    );
  }
  
  /// グリッド位置を計算
  Vector2 getGridPosition(int row, int col, int maxCols, double itemSize, double spacing) {
    return Vector2(
      containerOffset.x + (col * (itemSize + spacing)) + spacing,
      containerOffset.y + (row * (itemSize + spacing)) + spacing,
    );
  }
}

/// モバイルレイアウト情報
/// UILayerPriority統合サポート
class MobileLayoutInfo {
  final Vector2 screenSize;
  
  final Vector2 menuArea;
  final Vector2 menuOffset;
  
  final Vector2 gameArea;
  final Vector2 gameOffset;
  
  final Vector2 inventoryArea;
  final Vector2 inventoryOffset;
  
  final Vector2 adArea;
  final Vector2 adOffset;
  
  const MobileLayoutInfo({
    required this.screenSize,
    required this.menuArea,
    required this.menuOffset,
    required this.gameArea,
    required this.gameOffset,
    required this.inventoryArea,
    required this.inventoryOffset,
    required this.adArea,
    required this.adOffset,
  });
  
  /// ゲーム領域のUIPositionCalculatorを取得（UILayerPriority.gameContent準拠）
  UIPositionCalculator get gameAreaCalculator => UIPositionCalculator(
    containerSize: gameArea,
    containerOffset: gameOffset,
  );
  
  /// インベントリ領域のUIPositionCalculatorを取得（InventoryUILayerPriority準拠）
  UIPositionCalculator get inventoryAreaCalculator => UIPositionCalculator(
    containerSize: inventoryArea,
    containerOffset: inventoryOffset,
  );
  
  /// メニュー領域のUIPositionCalculatorを取得（UILayerPriority.ui準拠）
  UIPositionCalculator get menuAreaCalculator => UIPositionCalculator(
    containerSize: menuArea,
    containerOffset: menuOffset,
  );
  
  /// 広告領域のUIPositionCalculatorを取得（UILayerPriority.background準拠）
  UIPositionCalculator get adAreaCalculator => UIPositionCalculator(
    containerSize: adArea,
    containerOffset: adOffset,
  );
  
  /// UIレイヤー優先度を適用
  void applyLayerPriorities(Component component) {
    // ゲームコンテンツ優先度適用例
    component.priority = UILayerPriority.gameContent;
  }
  
  /// デバッグ情報を取得
  Map<String, dynamic> toDebugMap() {
    return {
      'screenSize': '${screenSize.x}x${screenSize.y}',
      'menuArea': '${menuArea.x}x${menuArea.y} at ${menuOffset.x},${menuOffset.y}',
      'gameArea': '${gameArea.x}x${gameArea.y} at ${gameOffset.x},${gameOffset.y}',
      'inventoryArea': '${inventoryArea.x}x${inventoryArea.y} at ${inventoryOffset.x},${inventoryOffset.y}',
      'adArea': '${adArea.x}x${adArea.y} at ${adOffset.x},${adOffset.y}',
    };
  }
  
  @override
  String toString() {
    return 'MobileLayoutInfo(screen: ${screenSize.x}x${screenSize.y})';
  }
}

/// 画面向き対応（UILayoutManager統合）
enum ScreenOrientation {
  portrait,
  landscape,
}

/// 画面向き検出と対応レイアウト
/// UILayoutManagerの機能を継承
class OrientationAwareLayout extends UILayoutManager {
  /// 画面向きを判定
  static ScreenOrientation detectOrientation(Vector2 screenSize) {
    return screenSize.x > screenSize.y 
      ? ScreenOrientation.landscape 
      : ScreenOrientation.portrait;
  }
  
  /// 向きに応じたレイアウトを計算
  static MobileLayoutInfo calculateLayoutForOrientation(Vector2 screenSize) {
    final orientation = detectOrientation(screenSize);
    
    switch (orientation) {
      case ScreenOrientation.portrait:
        return MobileLayoutSystem.calculateLayout(screenSize);
      case ScreenOrientation.landscape:
        return _calculateLandscapeLayout(screenSize);
    }
  }
  
  /// 横向きレイアウト（縦向きとは異なる比率）
  static MobileLayoutInfo _calculateLandscapeLayout(Vector2 screenSize) {
    // 横向き時は左右分割レイアウト
    const leftRatio = 0.7;   // 70%: ゲーム領域
    const rightRatio = 0.3;  // 30%: インベントリ+メニュー
    
    return MobileLayoutInfo(
      screenSize: screenSize,
      menuArea: Vector2(screenSize.x * rightRatio, screenSize.y * 0.2),
      menuOffset: Vector2(screenSize.x * leftRatio, 0),
      gameArea: Vector2(screenSize.x * leftRatio, screenSize.y),
      gameOffset: Vector2.zero(),
      inventoryArea: Vector2(screenSize.x * rightRatio, screenSize.y * 0.6),
      inventoryOffset: Vector2(screenSize.x * leftRatio, screenSize.y * 0.2),
      adArea: Vector2(screenSize.x * rightRatio, screenSize.y * 0.2),
      adOffset: Vector2(screenSize.x * leftRatio, screenSize.y * 0.8),
    );
  }
}