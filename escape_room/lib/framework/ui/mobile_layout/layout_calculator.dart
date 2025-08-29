import 'package:flame/components.dart';
import 'layout_info.dart';

/// スマートフォン縦型レイアウト計算システム
/// 移植ガイド準拠実装
class MobileLayoutCalculator {
  // 5分割レイアウト定義（既存UILayerPriority準拠）
  static const double topMenuRatio = 0.1; // 10%: メニューバー
  static const double gameAreaRatio = 0.6; // 60%: ゲーム領域
  static const double inventoryRatio = 0.2; // 20%: インベントリ
  static const double bannerAdRatio = 0.1; // 10%: 広告エリア

  /// ゲーム領域のサイズと位置を計算
  static Vector2 calculateGameArea(Vector2 screenSize) {
    return Vector2(screenSize.x, screenSize.y * gameAreaRatio);
  }

  /// ゲーム領域のオフセット位置を計算
  static Vector2 calculateGameAreaOffset(Vector2 screenSize) {
    return Vector2(0, screenSize.y * topMenuRatio);
  }

  /// インベントリ領域のサイズと位置を計算
  static Vector2 calculateInventoryArea(Vector2 screenSize) {
    return Vector2(screenSize.x, screenSize.y * inventoryRatio);
  }

  /// インベントリ領域のオフセット位置を計算
  static Vector2 calculateInventoryAreaOffset(Vector2 screenSize) {
    return Vector2(0, screenSize.y * (topMenuRatio + gameAreaRatio));
  }

  /// メニュー領域のサイズと位置を計算
  static Vector2 calculateMenuArea(Vector2 screenSize) {
    return Vector2(screenSize.x, screenSize.y * topMenuRatio);
  }

  /// メニュー領域のオフセット位置を計算
  static Vector2 calculateMenuAreaOffset(Vector2 screenSize) {
    return Vector2.zero();
  }

  /// 広告エリアのサイズと位置を計算
  static Vector2 calculateAdArea(Vector2 screenSize) {
    return Vector2(screenSize.x, screenSize.y * bannerAdRatio);
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