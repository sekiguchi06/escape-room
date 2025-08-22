import 'package:flame/components.dart';
import '../flame_ui_builder.dart';
import '../screen_factory.dart';

/// プレイング画面の生成クラス
class PlayingScreenBuilder {
  /// プレイング画面を生成
  static PositionComponent create(Vector2 screenSize, ScreenConfig config) {
    final screen = PositionComponent();

    // 背景（プレイング画面では通常透明またはゲーム背景）
    screen.add(_createBackground(screenSize, config));

    // スコア表示
    if (config.scoreText != null) {
      screen.add(
        FlameUIBuilder.scoreText(
          text: config.scoreText!,
          screenSize: screenSize,
        ),
      );
    }

    // タイマー表示
    if (config.timerText != null) {
      screen.add(
        FlameUIBuilder.timerText(
          text: config.timerText!,
          screenSize: screenSize,
        ),
      );
    }

    // プログレスバー
    if (config.showProgressBar && config.progressValue != null) {
      screen.add(
        FlameUIBuilder.progressBar(
          progress: config.progressValue!,
          screenSize: screenSize,
        ),
      );
    }

    // ポーズボタン
    if (config.showPauseButton) {
      screen.add(
        FlameUIBuilder.pauseButton(
          screenSize,
          customOnPressed: config.customActions?['pause'],
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
      // プレイング画面では透明背景がデフォルト
      return PositionComponent();
    }
  }
}
