import 'package:flutter/foundation.dart';
import '../config/game_configuration.dart';
import '../state/game_state_system.dart';
import 'game_managers.dart';

/// ゲームライフサイクル管理ミックスイン
/// ゲームの開始、停止、一時停止、リセット等を管理
mixin GameLifecycle<TState extends GameState, TConfig> {
  /// マネージャーコレクション
  GameManagers<TState> get managers;

  /// ゲーム設定
  GameConfiguration<TState, TConfig> get configuration;

  /// 初期化フラグ
  bool get isInitialized;

  /// 設定の適用
  Future<void> applyConfiguration(TConfig config) async {
    configuration.updateConfig(config);

    // 設定変更の通知
    onConfigurationChanged(configuration.config, config);

    // UI テーマの更新
    await updateTheme();

    // タイマーの更新
    await updateTimers();

    // 状態の更新
    await updateStates();
  }

  /// 設定変更時のコールバック（サブクラスで実装）
  void onConfigurationChanged(TConfig oldConfig, TConfig newConfig) {
    debugPrint('Configuration changed: $oldConfig -> $newConfig');
  }

  /// テーマの更新
  Future<void> updateTheme() async {
    // サブクラスでオーバーライド可能
  }

  /// タイマーの更新
  Future<void> updateTimers() async {
    // サブクラスでオーバーライド可能
  }

  /// 状態の更新
  Future<void> updateStates() async {
    // サブクラスでオーバーライド可能
  }

  /// ゲーム開始
  void startGame() {
    if (!isInitialized) {
      debugPrint('Warning: Game not initialized yet');
      return;
    }

    onGameStart();
  }

  /// ゲーム一時停止
  void pauseGame() {
    pauseEngine();
    managers.timerManager.pauseAllTimers();
    onGamePause();
  }

  /// ゲーム再開
  void resumeGame() {
    resumeEngine();
    managers.timerManager.resumeAllTimers();
    onGameResume();
  }

  /// ゲーム停止
  void stopGame() {
    managers.timerManager.stopAllTimers();
    onGameStop();
  }

  /// ゲーム リセット
  void resetGame() {
    managers.timerManager.stopAllTimers();
    managers.stateProvider = createStateProvider();
    onGameReset();
  }

  /// ゲーム開始時のコールバック（サブクラスで実装）
  void onGameStart() {}

  /// ゲーム一時停止時のコールバック（サブクラスで実装）
  void onGamePause() {}

  /// ゲーム再開時のコールバック（サブクラスで実装）
  void onGameResume() {}

  /// ゲーム停止時のコールバック（サブクラスで実装）
  void onGameStop() {}

  /// ゲームリセット時のコールバック（サブクラスで実装）
  void onGameReset() {}

  /// エンジンの一時停止（サブクラスで実装）
  void pauseEngine();

  /// エンジンの再開（サブクラスで実装）
  void resumeEngine();

  /// 状態プロバイダーの作成（サブクラスで実装）
  GameStateProvider<TState> createStateProvider();
}
