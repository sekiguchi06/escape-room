import 'package:flame/components.dart';
import '../flame_ui_builder.dart';
import '../screen_factory.dart';

/// ショップ画面の生成クラス
class ShopScreenBuilder {
  /// ショップ画面を生成
  static PositionComponent create(Vector2 screenSize, ScreenConfig config) {
    final screen = PositionComponent();

    // 背景
    screen.add(_createBackground(screenSize, config));

    // タイトル
    screen.add(
      FlameUIBuilder.titleText(
        text: 'SHOP',
        screenSize: screenSize,
        yOffset: -150,
      ),
    );

    // コイン表示（右上）
    screen.add(
      FlameUIBuilder.scoreText(
        text: config.coinText ?? 'Coins: 100',
        screenSize: screenSize,
      ),
    );

    // 商品リスト（グリッド配置・簡易実装）
    final shopItems =
        config.shopItems ?? ['Power Up', 'Extra Life', 'Coin Pack'];
    for (int i = 0; i < shopItems.length; i++) {
      final xPos = (i % 2) * 200.0 - 100.0;
      final yPos = (i ~/ 2) * 80.0 - 50.0;
      screen.add(
        FlameUIBuilder.secondaryButton(
          text: shopItems[i],
          onPressed:
              config
                  .customActions?['buy_${shopItems[i].toLowerCase().replaceAll(' ', '_')}'] ??
              () {},
          screenSize: screenSize,
          customSize: Vector2(180, 60),
          customPosition: Vector2(
            screenSize.x / 2 + xPos,
            screenSize.y / 2 + yPos,
          ),
        ),
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
