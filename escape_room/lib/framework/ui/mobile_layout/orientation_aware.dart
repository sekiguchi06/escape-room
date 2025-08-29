import 'package:flame/components.dart';
import '../ui_layout_manager.dart';
import 'layout_calculator.dart';
import 'layout_info.dart';

/// 画面向き対応（UILayoutManager統合）
enum ScreenOrientation { portrait, landscape }

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
        return MobileLayoutCalculator.calculateLayout(screenSize);
      case ScreenOrientation.landscape:
        return _calculateLandscapeLayout(screenSize);
    }
  }

  /// 横向きレイアウト（縦向きとは異なる比率）
  static MobileLayoutInfo _calculateLandscapeLayout(Vector2 screenSize) {
    // 横向き時は左右分割レイアウト
    const leftRatio = 0.7; // 70%: ゲーム領域
    const rightRatio = 0.3; // 30%: インベントリ+メニュー

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