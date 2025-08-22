import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../flame_ui_builder.dart';
import '../screen_factory.dart';

/// ポーズ画面の生成クラス
class PauseScreenBuilder {
  /// ポーズ画面を生成
  static PositionComponent create(Vector2 screenSize, ScreenConfig config) {
    final screen = PositionComponent();

    // 半透明背景（オーバーレイ）
    screen.add(
      FlameUIBuilder.background(screenSize: screenSize, color: Colors.black54),
    );

    // パネル
    final pausePanel = FlameUIBuilder.panel(
      screenSize: screenSize,
      children: [
        FlameUIBuilder.titleText(
          text: 'PAUSED',
          screenSize: Vector2(screenSize.x * 0.8, screenSize.y * 0.6),
          yOffset: -80,
        ),
        FlameUIBuilder.primaryButton(
          text: 'Resume',
          onPressed: config.customActions?['resume'] ?? () {},
          screenSize: Vector2(screenSize.x * 0.8, screenSize.y * 0.6),
          customPosition: Vector2(
            screenSize.x * 0.4 - 100,
            screenSize.y * 0.3 - 10,
          ),
        ),
        FlameUIBuilder.secondaryButton(
          text: 'Menu',
          onPressed: config.customActions?['menu'] ?? () {},
          screenSize: Vector2(screenSize.x * 0.8, screenSize.y * 0.6),
          customPosition: Vector2(
            screenSize.x * 0.4 - 75,
            screenSize.y * 0.3 + 50,
          ),
        ),
      ],
    );

    screen.add(pausePanel);

    return screen;
  }
}
