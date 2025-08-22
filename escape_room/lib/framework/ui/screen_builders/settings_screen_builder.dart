import 'package:flame/components.dart';
import '../flame_ui_builder.dart';
import '../screen_factory.dart';

/// 設定画面の生成クラス
class SettingsScreenBuilder {
  /// 設定画面を生成
  static PositionComponent create(Vector2 screenSize, ScreenConfig config) {
    final screen = PositionComponent();

    // 背景
    screen.add(_createBackground(screenSize, config));

    // Settings タイトル
    screen.add(
      FlameUIBuilder.titleText(
        text: 'SETTINGS',
        screenSize: screenSize,
        yOffset: -150,
      ),
    );

    // 設定項目
    final settingsItems =
        config.settingsItems ?? ['Sound', 'Music', 'Vibration'];

    for (int i = 0; i < settingsItems.length; i++) {
      final item = settingsItems[i];
      screen.add(
        FlameUIBuilder.settingsItem(
          text: item,
          onPressed: config.customActions?[item.toLowerCase()] ?? () {},
          position: Vector2(
            screenSize.x / 2 - 100,
            screenSize.y / 2 + (i * 60).toDouble(),
          ),
        ),
      );
    }

    // BACK ボタン
    screen.add(
      FlameUIBuilder.secondaryButton(
        text: 'BACK',
        onPressed: config.customActions?['back'] ?? () {},
        screenSize: screenSize,
        customPosition: Vector2(screenSize.x / 2 - 75, screenSize.y / 2 + 150),
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
