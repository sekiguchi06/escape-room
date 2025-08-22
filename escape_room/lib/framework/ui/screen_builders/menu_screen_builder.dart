import 'package:flame/components.dart';
import '../flame_ui_builder.dart';
import '../screen_factory.dart';

/// メニュー画面の生成クラス
class MenuScreenBuilder {
  /// メニュー画面を生成
  static PositionComponent create(Vector2 screenSize, ScreenConfig config) {
    final screen = PositionComponent();

    // 背景
    screen.add(_createBackground(screenSize, config));

    // タイトル
    screen.add(
      FlameUIBuilder.titleText(
        text: config.title ?? 'Main Menu',
        screenSize: screenSize,
        yOffset: -150,
      ),
    );

    // メニュー項目
    final menuItems = config.menuItems ?? ['PLAY', 'SETTINGS', 'QUIT'];

    for (int i = 0; i < menuItems.length; i++) {
      final item = menuItems[i];
      screen.add(
        FlameUIBuilder.primaryButton(
          text: item,
          onPressed: config.customActions?[item.toLowerCase()] ?? () {},
          screenSize: screenSize,
          customPosition: Vector2(
            screenSize.x / 2 - 100,
            screenSize.y / 2 + (i * 60).toDouble(),
          ),
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
