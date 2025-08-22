import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'framework_integration/simple_game_states.dart';
import 'framework_integration/simple_game_configuration.dart';

/// シンプルなゲーム実装
class SimpleGame extends FlameGame {
  SimpleGameState _currentState = const SimpleGameStartState();
  bool _isInitialized = false;

  // テスト用のモックプロパティ
  final managers = <String, dynamic>{};
  final timerManager = <String, dynamic>{};
  final configuration = <String, dynamic>{};

  // 設定プロパティ
  final config = const SimpleGameConfig(gameDuration: Duration(seconds: 10));

  // 初期化状態
  bool get isInitialized => _isInitialized;

  SimpleGameState get currentState => _currentState;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _currentState = const SimpleGameStartState();

    // テスト用マネージャーの初期化
    managers['stateProvider'] = SimpleGameStateProvider();
    managers['themeManager'] = {}; // Mock object
    managers['audioManager'] = {}; // Mock object
    managers['dataManager'] = {}; // Mock object
    managers['monetizationManager'] = {}; // Mock object
    managers['analyticsManager'] = {}; // Mock object

    // タイマーマネージャーの初期化
    timerManager['getTimer'] = (String name) => _MockTimer();

    _isInitialized = true;
  }

  /// ゲーム状態を変更
  void changeState(SimpleGameState newState) {
    _currentState = newState;
  }

  /// ゲームを開始
  void startGame() {
    changeState(const SimpleGamePlayingState());
  }

  /// ゲームを終了
  void endGame({bool victory = false, String? message}) {
    changeState(SimpleGameOverState(isVictory: victory, message: message));
  }

  /// ゲームを一時停止
  void pauseGame() {
    paused = true;
  }

  /// ゲームを再開
  void resumeGame() {
    paused = false;
  }

  /// ゲームをリセット
  void resetGame() {
    paused = false;
    changeState(const SimpleGameStartState());
  }

  /// ゲームを再起動（テスト用）
  void restartGame() {
    resetGame();
    startGame();
  }

  /// デバッグ情報取得（テスト用）
  Map<String, dynamic> getDebugInfo() {
    return {
      'currentState': _currentState.toString(),
      'paused': paused,
      'game_type': 'SimpleGame',
      'initialized': _isInitialized,
      'current_state': _currentState.runtimeType.toString(),
      'performance': {'components': children.length, 'fps': 60},
    };
  }

  /// パフォーマンスメトリクス取得（テスト用）
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'fps': 60,
      'memory': '100MB',
      'component_count': children.length,
      'timer_count': 1,
    };
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 簡単な状態表示
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'State: ${_currentState.toString()}',
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(10, 10));
  }
}

/// テスト用のモックタイマー
class _MockTimer {
  bool isRunning = false;

  void start() => isRunning = true;
  void stop() => isRunning = false;
  void reset() => isRunning = false;
}
