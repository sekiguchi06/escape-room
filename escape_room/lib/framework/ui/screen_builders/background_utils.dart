import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../flame_ui_builder.dart';
import '../screen_factory.dart';

/// 画面背景作成のユーティリティクラス
class BackgroundUtils {
  /// 背景コンポーネントを作成
  static Component createBackground(Vector2 screenSize, ScreenConfig config) {
    if (config.gradientColors != null && config.gradientColors!.length > 1) {
      return FlameUIBuilder.gradientBackground(
        screenSize: screenSize,
        colors: config.gradientColors!,
      );
    } else {
      return FlameUIBuilder.background(
        screenSize: screenSize,
        color: config.backgroundColor ?? Colors.indigo.withValues(alpha: 0.3),
      );
    }
  }

  /// グラデーション背景を作成
  static Component createGradientBackground(
    Vector2 screenSize,
    List<Color> colors,
  ) {
    return FlameUIBuilder.gradientBackground(
      screenSize: screenSize,
      colors: colors,
    );
  }

  /// 単色背景を作成
  static Component createSolidBackground(Vector2 screenSize, Color color) {
    return FlameUIBuilder.background(screenSize: screenSize, color: color);
  }

  /// デフォルトゲーム背景を作成
  static Component createDefaultBackground(Vector2 screenSize) {
    return FlameUIBuilder.background(
      screenSize: screenSize,
      color: Colors.indigo.withValues(alpha: 0.3),
    );
  }
}
