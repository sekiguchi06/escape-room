import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../framework/ui/ui_system.dart';
import '../simple_game.dart';

class StartScreenComponent extends PositionComponent {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    final game = findGame()! as SimpleGame;
    final config = game.configuration.config;
    
    // 背景（視覚確認用のみ、タップ不可）
    final background = RectangleComponent(
      position: Vector2.zero(),
      size: game.size,
      paint: Paint()..color = Colors.indigo.withOpacity(0.3),
    );
    background.priority = UILayerPriority.background;
    add(background);
    
    // タイトルテキスト
    final titleText = TextUIComponent(
      text: config.getStateText('start'),
      styleId: 'xlarge',
      position: Vector2(game.size.x / 2, game.size.y / 2 - 50),
    );
    titleText.anchor = Anchor.center;
    add(titleText);
    
    // START GAMEボタン
    final startButton = ButtonUIComponent(
      text: 'START GAME',
      colorId: 'primary',
      position: Vector2(game.size.x / 2 - 100, game.size.y / 2 + 20),
      size: Vector2(200, 50),
      onPressed: () {
        // ゲーム開始処理とタイマー開始を実行
        game.startGame();
      },
    );
    startButton.anchor = Anchor.topLeft;
    add(startButton);
    
    // Settingsボタン
    final settingsButton = ButtonUIComponent(
      text: 'Settings',
      colorId: 'secondary',
      position: UILayoutManager.topRight(game.size, Vector2(120, 40), 20),
      size: Vector2(120, 40),
      onPressed: () => game.router.pushNamed('settings'),
    );
    settingsButton.anchor = Anchor.topLeft;
    add(settingsButton);
  }
}

