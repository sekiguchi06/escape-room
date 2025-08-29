import 'package:flame/components.dart';

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
    return Vector2(containerSize.x * width, containerSize.y * height);
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
  Vector2 getGridPosition(
    int row,
    int col,
    int maxCols,
    double itemSize,
    double spacing,
  ) {
    return Vector2(
      containerOffset.x + (col * (itemSize + spacing)) + spacing,
      containerOffset.y + (row * (itemSize + spacing)) + spacing,
    );
  }
}