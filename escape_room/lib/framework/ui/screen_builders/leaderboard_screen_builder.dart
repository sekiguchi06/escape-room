import 'package:flame/components.dart';
import '../flame_ui_builder.dart';
import '../ui_system.dart';
import '../screen_factory.dart';

/// リーダーボード画面の生成クラス
class LeaderboardScreenBuilder {
  /// リーダーボード画面を生成
  static PositionComponent create(Vector2 screenSize, ScreenConfig config) {
    final screen = PositionComponent();

    // 背景
    screen.add(_createBackground(screenSize, config));

    // タイトル
    screen.add(
      FlameUIBuilder.titleText(
        text: 'LEADERBOARD',
        screenSize: screenSize,
        yOffset: -150,
      ),
    );

    // スコアリスト（簡易実装）
    final scores =
        config.leaderboardData ??
        [
          {'name': 'Player 1', 'score': 1000},
          {'name': 'Player 2', 'score': 800},
          {'name': 'Player 3', 'score': 600},
        ];

    for (int i = 0; i < scores.length && i < 5; i++) {
      final data = scores[i];
      final yPos = -80.0 + (i * 40.0);
      screen.add(
        TextUIComponent(
          text: '${i + 1}. ${data['name']} - ${data['score']}',
          styleId: 'medium',
          position: Vector2(screenSize.x / 2, screenSize.y / 2 + yPos),
        )..anchor = Anchor.center,
      );
    }

    // 戻るボタン
    screen.add(
      FlameUIBuilder.backButton(
        screenSize,
        customOnPressed: config.customActions?['back'],
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
