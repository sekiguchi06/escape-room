import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../framework/ui/ui_system.dart';
import '../simple_game.dart';

class GameOverScreenComponent extends PositionComponent {
  final int sessionCount;
  
  GameOverScreenComponent({required this.sessionCount});
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    final game = findGame()! as SimpleGame;
    final config = game.configuration.config;
    
    // 背景
    final background = RectangleComponent(
      position: Vector2.zero(),
      size: game.size,
      paint: Paint()..color = Colors.red.withOpacity(0.8),
    );
    background.priority = UILayerPriority.background;
    add(background);
    
    // ゲームオーバーテキスト（メイン）
    final gameOverText = TextUIComponent(
      text: config.getStateText('gameOver'),
      styleId: 'large',
      position: Vector2(game.size.x / 2, game.size.y / 2 - 80),
    );
    gameOverText.anchor = Anchor.center;
    gameOverText.setTextColor(Colors.white);
    add(gameOverText);
    
    // セッション数テキスト（別コンポーネント）
    final sessionText = TextUIComponent(
      text: 'Session: $sessionCount',
      styleId: 'medium',
      position: Vector2(game.size.x / 2, game.size.y / 2 - 40),
    );
    sessionText.anchor = Anchor.center;
    sessionText.setTextColor(Colors.white);
    add(sessionText);
    
    // RESTARTボタン
    final restartButton = ButtonUIComponent(
      text: 'RESTART',
      colorId: 'primary',
      position: Vector2(game.size.x / 2 - 100, game.size.y / 2 + 20),
      size: Vector2(200, 50),
      onPressed: () {
        // ゲーム再開始処理とタイマー開始を実行
        game.restartGame();
      },
    );
    restartButton.anchor = Anchor.topLeft;
    add(restartButton);
    
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