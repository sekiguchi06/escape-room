import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'components/timer_component.dart';
import 'components/ui_component.dart';
import 'components/input_component.dart';

enum SimpleGameState { start, playing, gameOver }

class SimpleGame extends FlameGame with TapDetector {
  SimpleGameState currentState = SimpleGameState.start;
  
  // Component指向設計に変更
  late GameTimerComponent gameTimer;
  late UIComponent gameUI;
  late InputComponent inputHandler;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // GameTimerComponentの初期化
    gameTimer = GameTimerComponent(
      initialTime: 5.0,
      onTimerEnd: _goToGameOver,
      onTimerUpdate: (time) => gameUI.updateTimer(time),
    );
    add(gameTimer);
    
    // UIComponentの初期化
    gameUI = UIComponent();
    add(gameUI);
    await gameUI.loaded; // UIComponentの初期化完了を待つ
    
    // InputComponentの初期化（状態管理用）
    inputHandler = InputComponent();
    
    // 初期状態のUI表示
    gameUI.showStartScreen();
    
    print('ゲーム初期化完了: ${currentState}');
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (!inputHandler.isEnabled) return;
    
    print('タップ検出: ${currentState}');
    
    switch (currentState) {
      case SimpleGameState.start:
        _startGame();
        break;
      case SimpleGameState.playing:
        print('ゲーム中（タップ無効）');
        break;
      case SimpleGameState.gameOver:
        _restart();
        break;
    }
  }

  void _startGame() {
    print('ゲーム開始');
    currentState = SimpleGameState.playing;
    gameTimer.start();
  }

  void _goToGameOver() {
    print('ゲームオーバー');
    currentState = SimpleGameState.gameOver;
    gameTimer.stop();
    gameUI.showGameOverScreen();
  }

  void _restart() {
    print('リスタート - ゲーム開始');
    currentState = SimpleGameState.start;
    gameTimer.reset();
    gameUI.showStartScreen();
    _startGame();
  }
}