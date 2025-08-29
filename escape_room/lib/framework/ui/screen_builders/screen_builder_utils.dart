import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../flame_ui_builder.dart';
import '../screen_config.dart';

/// スクリーンビルダー共通処理
class ScreenBuilderUtils {
  /// 背景生成（共通処理）
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
}