import 'package:flame/components.dart';
import '../flame_ui_builder.dart';
import '../screen_factory.dart';

/// スタート画面の生成クラス
class StartScreenBuilder {
  /// スタート画面を生成
  static PositionComponent create(Vector2 screenSize, ScreenConfig config) {
    final screen = PositionComponent();

    // 背景
    screen.add(_createBackground(screenSize, config));

    // タイトル
    screen.add(
      FlameUIBuilder.titleText(
        text: config.title ?? 'Game Title',
        screenSize: screenSize,
        yOffset: -100,
      ),
    );

    // サブタイトル（オプション）
    if (config.subtitle != null) {
      screen.add(
        FlameUIBuilder.subtitleText(
          text: config.subtitle!,
          screenSize: screenSize,
          yOffset: -60,
        ),
      );
    }

    // START GAME ボタン
    screen.add(
      FlameUIBuilder.primaryButton(
        text: 'START GAME',
        onPressed: config.customActions?['start'] ?? () {},
        screenSize: screenSize,
      ),
    );

    // Settings ボタン
    if (config.showSettings) {
      screen.add(
        FlameUIBuilder.settingsButton(
          screenSize,
          customOnPressed: config.customActions?['settings'],
        ),
      );
    }

    return screen;
  }

  /// 背景コンポーネントを作成
  static PositionComponent _createBackground(
    Vector2 screenSize,
    ScreenConfig config,
  ) {
    if (config.gradientColors != null && config.gradientColors!.length >= 2) {
      return FlameUIBuilder.gradientBackground(
        screenSize: screenSize,
        colors: config.gradientColors!,
      );
    } else if (config.backgroundColor != null) {
      return FlameUIBuilder.solidColorBackground(
        screenSize: screenSize,
        color: config.backgroundColor!,
      );
    } else {
      return FlameUIBuilder.defaultGameBackground(screenSize: screenSize);
    }
  }
}
