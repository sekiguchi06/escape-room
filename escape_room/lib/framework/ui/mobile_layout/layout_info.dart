import 'package:flame/components.dart';
import '../ui_layer_priority.dart';
import 'position_calculator.dart';

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
  UIPositionCalculator get adAreaCalculator =>
      UIPositionCalculator(containerSize: adArea, containerOffset: adOffset);

  /// UIレイヤー優先度を適用
  void applyLayerPriorities(Component component) {
    // ゲームコンテンツ優先度適用例
    component.priority = UILayerPriority.gameContent;
  }

  /// デバッグ情報を取得
  Map<String, dynamic> toDebugMap() {
    return {
      'screenSize': '${screenSize.x}x${screenSize.y}',
      'menuArea':
          '${menuArea.x}x${menuArea.y} at ${menuOffset.x},${menuOffset.y}',
      'gameArea':
          '${gameArea.x}x${gameArea.y} at ${gameOffset.x},${gameOffset.y}',
      'inventoryArea':
          '${inventoryArea.x}x${inventoryArea.y} at ${inventoryOffset.x},${inventoryOffset.y}',
      'adArea': '${adArea.x}x${adArea.y} at ${adOffset.x},${adOffset.y}',
    };
  }

  @override
  String toString() {
    return 'MobileLayoutInfo(screen: ${screenSize.x}x${screenSize.y})';
  }
}