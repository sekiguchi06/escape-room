import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/timer_component.dart';
import 'components/ui_component.dart';
import 'components/input_component.dart';
import 'providers/game_state_provider.dart';

class SimpleGame extends FlameGame with TapDetector {
  // Provider経由で状態管理
  GameStateProvider? _gameStateProvider;
  
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
      onTimerUpdate: (time) => _updateTimerInProvider(time),
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
    
    print('ゲーム初期化完了（Provider対応）');
  }

  /// BuildContextを通じてProviderにアクセス
  void setProvider(GameStateProvider provider) {
    _gameStateProvider = provider;
    // Providerからの状態変更をリッスン
    _gameStateProvider!.addListener(_onStateChanged);
  }

  /// Provider状態変更時のコールバック
  void _onStateChanged() {
    if (_gameStateProvider == null) return;
    
    final state = _gameStateProvider!.currentState;
    print('Provider状態変更: $state');
    
    // UI更新
    switch (state) {
      case SimpleGameState.start:
        gameUI.showStartScreen();
        break;
      case SimpleGameState.playing:
        gameUI.updateTimer(_gameStateProvider!.gameTimer);
        break;
      case SimpleGameState.gameOver:
        gameUI.showGameOverScreen();
        break;
    }
  }

  /// タイマー更新をProviderに反映
  void _updateTimerInProvider(double time) {
    _gameStateProvider?.updateTimer(time);
    gameUI.updateTimer(time);
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (!inputHandler.isEnabled || _gameStateProvider == null) return;
    
    final currentState = _gameStateProvider!.currentState;
    print('タップ検出: $currentState');
    
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
    print('ゲーム開始（Provider経由）');
    _gameStateProvider?.setPlayingState();
    gameTimer.start();
  }

  void _goToGameOver() {
    print('ゲームオーバー（Provider経由）');
    _gameStateProvider?.setGameOverState();
    gameTimer.stop();
  }

  void _restart() {
    print('リスタート（Provider経由）');
    _gameStateProvider?.resetGame();
    gameTimer.reset();
    _startGame();
  }

  @override
  void onRemove() {
    // Providerのリスナーを解除
    _gameStateProvider?.removeListener(_onStateChanged);
    super.onRemove();
  }
}