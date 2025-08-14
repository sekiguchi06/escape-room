import 'package:flame/game.dart';
import 'package:flame/components.dart' as flame;
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../framework/state/game_state_system.dart';
import '../framework/timer/flame_timer_system.dart';
import '../framework/ui/ui_system.dart';
import '../framework/input/flame_input_system.dart';
import '../framework/core/configurable_game.dart';
import '../framework/animation/animation_system.dart';
import '../framework/audio/audio_system.dart';
import '../framework/audio/game_audio_helper.dart';
import '../framework/monetization/monetization_system.dart';
import '../framework/analytics/analytics_system.dart';
import '../framework/audio/providers/flame_audio_provider.dart';
import '../framework/monetization/providers/google_ad_provider.dart';
import '../framework/analytics/providers/firebase_analytics_provider.dart';
import 'package:flutter/foundation.dart';
import '../framework/effects/particle_system.dart';
import 'framework_integration/simple_game_states.dart';
import 'framework_integration/simple_game_configuration.dart';

class SimpleGame extends ConfigurableGame<GameState, SimpleGameConfig> {
  // 既存フィールド（必要最小限）
  late GameComponent _testCircle;
  late ParticleEffectManager _particleEffectManager;
  
  // カスタムUI用の状態プロパティ
  int _score = 0;
  double _gameTime = 60.0;
  bool _gameActive = false;

  // 公開プロパティ（main.dartのオーバーレイから参照）
  int get score => _score;
  double get gameTimeRemaining => _gameTime;
  bool get gameActive => _gameActive;

  // 時間フォーマット用公開メソッド
  String formatTime(double timeInSeconds) {
    final minutes = timeInSeconds ~/ 60;
    final seconds = (timeInSeconds % 60).round();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // 公開メソッド（main.dartのオーバーレイから呼び出し）
  @override
  void resetGame() {
    _score = 0;
    // 現在の設定から実際のゲーム時間を取得（60秒固定ではなく）
    final config = configuration.config;
    _gameTime = config.gameDuration.inMilliseconds / 1000.0;
    _gameActive = false;  // ゲーム未開始状態に設定
    
    // タイマーは作成するが開始しない
    timerManager.addTimer('main', TimerConfiguration(
      duration: config.gameDuration,
      type: TimerType.countdown,
      onComplete: () => _endGame(),
    ));
    // タイマーの開始はstartGame()で実行
    
    _showStartUI();  // スタートUIを表示
  }

  void restartFromGameOver() {
    // リスタートはゲーム開始状態にする（スタートUIではなく）
    _startGame();
  }

  // ポーズ機能（Flame公式パターン）
  @override
  void pauseGame() {
    if (_gameActive) {
      pauseEngine();
      timerManager.getTimer('main')?.pause();
      _gameActive = false;
      debugPrint('🎮 Game paused');
    }
  }

  @override
  void resumeGame() {
    if (!_gameActive) {
      resumeEngine();
      timerManager.getTimer('main')?.resume();
      _gameActive = true;
      debugPrint('🎮 Game resumed');
    }
  }

  // オーバーレイ管理メソッド
  void _showStartUI() {
    overlays.remove('gameUI');
    overlays.remove('gameOverUI');
    overlays.remove('settingsUI');
    overlays.add('startUI');
  }

  void _showGameUI() {
    try {
      overlays.remove('gameOverUI');
      overlays.remove('startUI');
      overlays.remove('settingsUI');
      overlays.add('gameUI');
    } catch (e) {
      debugPrint('🔥 GameUI overlay not available in test environment: $e');
    }
  }

  void _showGameOverUI() {
    try {
      overlays.remove('gameUI');
      overlays.remove('startUI');
      overlays.remove('settingsUI');
      overlays.add('gameOverUI');
    } catch (e) {
      debugPrint('🔥 GameOverUI overlay not available in test environment: $e');
    }
  }

  void showSettingsUI() {
    try {
      overlays.add('settingsUI');
    } catch (e) {
      debugPrint('🔥 SettingsUI overlay not available in test environment: $e');
    }
  }

  void hideSettingsUI() {
    try {
      overlays.remove('settingsUI');
    } catch (e) {
      debugPrint('🔥 SettingsUI overlay not available in test environment: $e');
    }
  }

  void _updateUI() {
    try {
      if (overlays.isActive('gameUI')) {
        overlays.remove('gameUI');
        overlays.add('gameUI');
      }
    } catch (e) {
      debugPrint('🔥 UI update not available in test environment: $e');
    }
  }
  
  SimpleGame() : super(
    configuration: SimpleGameConfiguration.defaultConfig,
    debugMode: false,
  ) {
    // プリセットの初期化
    SimpleGameConfigPresets.initialize();
  }
  
  @override
  GameStateProvider<GameState> createStateProvider() {
    return SimpleGameStateProvider();
  }

  AudioProvider createAudioProvider() {
    return FlameAudioProvider();
  }

  AdProvider createAdProvider() {
    // Web環境ではMockプロバイダーを使用
    if (kIsWeb) {
      return MockAdProvider();
    }
    return GoogleAdProvider();
  }

  AnalyticsProvider createAnalyticsProvider() {
    // Web環境ではConsoleプロバイダーを使用
    if (kIsWeb) {
      return ConsoleAnalyticsProvider();
    }
    return FirebaseAnalyticsProvider();
  }

  @override
  Future<void> initializeGame() async {
    debugPrint('🔥 SimpleGame.initializeGame() called');
    
    // 音声システムの初期化
    debugPrint('🔥 About to call _initializeAudio()');
    await _initializeAudio();
    debugPrint('🔥 _initializeAudio() completed');
    
    // UIテーマ初期化
    themeManager.initializeDefaultThemes();
    themeManager.setTheme('game');
    
    debugPrint('🔥 SimpleGame.initializeGame() completed');
    
    // スタートUIオーバーレイを表示（テスト環境では無効化）
    try {
      _showStartUI();
    } catch (e) {
      debugPrint('🔥 Overlay not available in test environment: $e');
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // パーティクルエフェクトマネージャーの初期化と追加
    _particleEffectManager = ParticleEffectManager();
    _particleEffectManager.priority = UILayerPriority.gameContent;
    add(_particleEffectManager);
    
    // テスト用ゲームオブジェクト作成（統合テスト用）
    _testCircle = GameComponent(
      position: Vector2.zero(),
      size: Vector2(80, 80),
      anchor: flame.Anchor.center,
    );
    _testCircle.paint.color = Colors.blue;
    _testCircle.paint.style = PaintingStyle.fill;
    add(_testCircle);
  }

  @override
  void onMount() {
    super.onMount();
    
    // テスト用ゲームオブジェクトの位置をsizeが利用可能になってから設定
    if (hasLayout) {
      _testCircle.position = Vector2(size.x / 2, size.y / 2 + 100);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    // ゲーム中のみタップ処理を有効化
    if (_gameActive && stateProvider.currentState is SimpleGamePlayingState) {
      final tapPosition = event.canvasPosition;
      
      // 青いサークル（_testCircle）のタップ判定
      if (_testCircle.containsPoint(tapPosition)) {
        _score += 10;
        audioManager.playSfx('tap', volumeMultiplier: 0.8);
        debugPrint('🎮 Circle tapped! Score: $_score');
        _updateUI();
      }
    }
  }

  @override
  void update(double dt) {
    final mainTimer = timerManager.getTimer('main');
    if (mainTimer != null && mainTimer.isRunning) {
      mainTimer.update(dt);
      
      if (stateProvider.currentState is SimpleGamePlayingState) {
        final remaining = mainTimer.current.inMilliseconds / 1000.0;
        (stateProvider as SimpleGameStateProvider).updateTimer(remaining);
        
        // カスタムUI用の時間更新
        _gameTime = remaining;
        
        // UI更新
        _updateUI();
        
        // タイマーが終了した場合、ゲームオーバー処理を実行
        if (remaining <= 0) {
          _endGame();
        }
      }
    }
    
    super.update(dt);
  }


  // 手動難易度変更メソッド（CustomSettingsUIから呼び出し）
  void applyDifficultyConfiguration(String configKey) {
    final newConfig = SimpleGameConfigPresets.getPreset(configKey);
    if (newConfig != null) {
      configuration.updateConfig(newConfig);
      audioManager.playSfx('tap', volumeMultiplier: 0.5);
      debugPrint('🎮 Manual configuration applied: $configKey');
      hideSettingsUI(); // 設定画面を閉じる
    }
  }

  /// 入力イベント処理を無効化
  /// ゲーム制御は専用ボタンからのみ実行（背景タップでのゲーム開始を防止）
  @override
  void onInputEvent(InputEventData event) {
    super.onInputEvent(event);
    // 背景タップによるゲーム開始を無効化
    // START GAMEボタンとSettingsボタンからのみ制御
  }

  void _startGame() {
    // セッション数に基づいて設定を自動切り替え（手動設定がない場合のみ）
    // 注: 手動設定が行われた場合は自動切り替えをスキップ
    // _applySessionBasedConfiguration(); // 無効化 - 手動設定を優先
    
    // ゲーム開始音を再生
    audioManager.playSfx('success', volumeMultiplier: 1.0);
    
    // カスタムUI用のゲーム状態設定
    _gameActive = true;
    _score = 0;
    
    // 現在の設定から実際のゲーム時間を取得
    final config = configuration.config;
    _gameTime = config.gameDuration.inMilliseconds / 1000.0;
    
    (stateProvider as SimpleGameStateProvider).startGame(config.gameDuration.inMilliseconds / 1000.0);
    
    timerManager.addTimer('main', TimerConfiguration(
      duration: config.gameDuration,
      type: TimerType.countdown,
      onComplete: () => _endGame(),
    ));
    
    timerManager.getTimer('main')?.start();
    
    // ゲームUIに切り替え
    _showGameUI();
  }

  /// publicメソッドとしてstartGameを公開（StartScreenComponentから呼び出し用）
  @override
  void startGame() {
    _startGame();
  }

  void _restartGame() {
    // セッション数に基づいて設定を自動切り替え（手動設定がない場合のみ）
    // 注: 手動設定が行われた場合は自動切り替えをスキップ
    // _applySessionBasedConfiguration(); // 無効化 - 手動設定を優先
    
    // リスタート音を再生
    audioManager.playSfx('success', volumeMultiplier: 0.8);
    
    // カスタムUI用のゲーム状態リセット
    _gameActive = true;
    _score = 0;
    
    // 現在の設定から実際のゲーム時間を取得
    final config = configuration.config;
    _gameTime = config.gameDuration.inMilliseconds / 1000.0;
    
    (stateProvider as SimpleGameStateProvider).restart(config.gameDuration.inMilliseconds / 1000.0);
    
    // タイマーを再作成
    timerManager.addTimer('main', TimerConfiguration(
      duration: config.gameDuration,
      type: TimerType.countdown,
      onComplete: () => _endGame(),
    ));
    
    timerManager.getTimer('main')?.start();
    
    // ゲームUIに切り替え
    _showGameUI();
  }

  void _endGame() {
    timerManager.getTimer('main')?.current.inMilliseconds ?? 0;
    
    // ゲームオーバー音を再生
    audioManager.playSfx('error', volumeMultiplier: 0.9);
    
    // カスタムUI用のゲーム状態更新
    _gameActive = false;
    _gameTime = 0.0;
    
    // タイマー終了時は残り時間を0にしてゲームオーバー状態にする
    (stateProvider as SimpleGameStateProvider).updateTimer(0.0);
    
    // ゲームオーバーUIを表示
    _showGameOverUI();
  }
  
  /// publicメソッドとしてrestartGameを公開（GameOverScreenComponentから呼び出し用）
  void restartGame() {
    _restartGame();
  }

  // 音声システムの初期化（GameAudioHelperを使用）
  Future<void> _initializeAudio() async {
    try {
      debugPrint('🎵 Starting audio initialization...');
      debugPrint('🎵 AudioManager available');
      
      await GameAudioIntegration.setupAudio(
        audioManager: audioManager,
        bgmFiles: {
          'menu_bgm': 'menu.mp3',
        },
        sfxFiles: {
          'tap': 'tap.wav',
          'success': 'success.wav',
          'error': 'error.wav',
        },
        masterVolume: 1.0,
        bgmVolume: 0.6,
        sfxVolume: 0.8,
        debugMode: true,
      );
      
      debugPrint('🎵 Audio system initialized with GameAudioHelper');
      debugPrint('🎵 SFX assets configured: tap.wav, success.wav, error.wav');
      debugPrint('🎵 Audio provider type: ${audioManager.provider.runtimeType}');
      debugPrint('🎵 BGM will start on first user interaction');
    } catch (e) {
      debugPrint('❌ Audio initialization failed: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
    }
  }
}