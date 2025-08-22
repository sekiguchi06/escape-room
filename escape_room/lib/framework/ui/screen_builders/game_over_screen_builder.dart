import 'package:flame/components.dart';
import '../flame_ui_builder.dart';
import '../screen_factory.dart';

/// ゲームオーバー画面の生成クラス
class GameOverScreenBuilder {
  /// ゲームオーバー画面を生成
  static PositionComponent create(Vector2 screenSize, ScreenConfig config) {
    final screen = PositionComponent();

    // 背景
    screen.add(_createBackground(screenSize, config));

    // GAME OVER タイトル
    screen.add(
      FlameUIBuilder.titleText(
        text: 'GAME OVER',
        screenSize: screenSize,
        yOffset: -150,
      ),
    );

    // 最終スコア
    if (config.finalScore != null) {
      screen.add(
        FlameUIBuilder.scoreText(
          text: 'Score: ${config.finalScore}',
          screenSize: screenSize,
        ),
      );
    }

    // ハイスコア
    if (config.highScore != null) {
      screen.add(
        FlameUIBuilder.scoreText(
          text: 'Best: ${config.highScore}',
          screenSize: screenSize,
        ),
      );
    }

    // PLAY AGAIN ボタン
    screen.add(
      FlameUIBuilder.primaryButton(
        text: 'PLAY AGAIN',
        onPressed: config.customActions?['restart'] ?? () {},
        screenSize: screenSize,
      ),
    );

    // MENU ボタン
    screen.add(
      FlameUIBuilder.secondaryButton(
        text: 'MENU',
        onPressed: config.customActions?['menu'] ?? () {},
        screenSize: screenSize,
      ),
    );

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
