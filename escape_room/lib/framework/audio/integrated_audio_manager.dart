import 'package:flutter/foundation.dart';
import 'audio_system.dart';
import 'bgm_context_manager.dart';
import 'enhanced_sfx_system.dart';
import 'optimized_audio_system.dart';

/// 統合音響管理システム
/// BGM、効果音、コンテキスト管理を一元化
class IntegratedAudioManager {
  static final IntegratedAudioManager _instance =
      IntegratedAudioManager._internal();
  factory IntegratedAudioManager() => _instance;
  IntegratedAudioManager._internal();

  AudioManager? _coreAudioManager;
  BgmContextManager? _bgmContextManager;
  EnhancedSfxSystem? _enhancedSfxSystem;
  OptimizedAudioSystem? _optimizedAudioSystem;
  bool _isInitialized = false;

  /// システム初期化
  Future<void> initialize(AudioManager coreAudioManager) async {
    _coreAudioManager = coreAudioManager;

    // サブシステムを初期化
    _bgmContextManager = BgmContextManager();
    _bgmContextManager!.initialize(coreAudioManager);

    _enhancedSfxSystem = EnhancedSfxSystem();
    _enhancedSfxSystem!.initialize(coreAudioManager);

    // 最適化音響システムを初期化
    _optimizedAudioSystem = OptimizedAudioSystem();
    await _optimizedAudioSystem!.initialize();

    _isInitialized = true;

    debugPrint(
      '🔊 Integrated Audio Manager initialized with OptimizedAudioSystem',
    );
  }

  /// ゲーム状態に応じたBGM自動制御
  Future<void> updateGameAudio({
    required GameAudioContext context,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized) return;

    switch (context) {
      case GameAudioContext.gameStart:
        await _bgmContextManager!.switchContext(BgmContext.menu);
        break;

      case GameAudioContext.gameExploration:
        await _bgmContextManager!.switchContext(BgmContext.exploration);
        break;

      case GameAudioContext.puzzleActive:
        await _bgmContextManager!.switchContext(BgmContext.puzzle);
        break;

      case GameAudioContext.gameCleared:
        await _bgmContextManager!.switchContext(BgmContext.victory);
        await _enhancedSfxSystem!.playEscapeSuccess();
        break;

      case GameAudioContext.gamePaused:
        await _bgmContextManager!.pauseCurrentBgm();
        break;

      case GameAudioContext.gameResumed:
        await _bgmContextManager!.resumeCurrentBgm();
        break;
    }
  }

  /// ユーザー操作に応じた効果音再生（最適化システム優先）
  Future<void> playUserActionSound(
    UserActionType action, {
    double? volumeMultiplier,
  }) async {
    debugPrint(
      '🎵 IntegratedAudioManager.playUserActionSound called: ${action.name} (vol: ${volumeMultiplier ?? 1.0})',
    );

    // 初期化されていない場合、OptimizedAudioSystemを直接使用
    if (!_isInitialized) {
      debugPrint(
        '⚠️ IntegratedAudioManager not initialized, using OptimizedAudioSystem directly',
      );
      final optimizedSystem = OptimizedAudioSystem();
      await optimizedSystem.initialize();
      final gameAction = action.toGameActionType();
      await optimizedSystem.playActionSound(
        gameAction,
        volumeMultiplier: volumeMultiplier ?? 1.0,
      );
      return;
    }

    // 最適化音響システムを優先使用
    if (_optimizedAudioSystem != null) {
      debugPrint('🔊 Using OptimizedAudioSystem for ${action.name}');
      final gameAction = action.toGameActionType();
      await _optimizedAudioSystem!.playActionSound(
        gameAction,
        volumeMultiplier: volumeMultiplier ?? 1.0,
      );
    } else {
      debugPrint('🔄 Fallback to EnhancedSfxSystem for ${action.name}');
      // フォールバック: 既存システム使用
      await _enhancedSfxSystem?.playByUserAction(
        action,
        volumeMultiplier: volumeMultiplier,
      );
    }
  }

  /// GameActionType直接再生（推奨）
  Future<void> playGameActionSound(
    GameActionType action, {
    double? volumeMultiplier,
  }) async {
    if (!_isInitialized || _optimizedAudioSystem == null) return;
    await _optimizedAudioSystem!.playActionSound(
      action,
      volumeMultiplier: volumeMultiplier ?? 1.0,
    );
  }

  /// レガシーAPIとの互換性保持
  Future<void> playSfx(String sfxId, {double volumeMultiplier = 1.0}) async {
    if (!_isInitialized || _coreAudioManager == null) return;
    await _coreAudioManager!.playSfx(sfxId, volumeMultiplier: volumeMultiplier);
  }

  /// BGM直接制御 (レガシー互換)
  Future<void> playBgm(String bgmId, {bool loop = true}) async {
    if (!_isInitialized || _coreAudioManager == null) return;
    await _coreAudioManager!.playBgm(bgmId);
  }

  /// BGM停止
  Future<void> stopBgm() async {
    if (!_isInitialized) return;
    await _bgmContextManager!.stopCurrentBgm();
  }

  /// 音量設定
  Future<void> setMasterVolume(double volume) async {
    if (!_isInitialized || _coreAudioManager == null) return;
    await _coreAudioManager!.setVolumes(
      masterVolume: volume,
      bgmVolume: _coreAudioManager!.configuration.bgmVolume,
      sfxVolume: _coreAudioManager!.configuration.sfxVolume,
    );
  }

  Future<void> setBgmVolume(double volume) async {
    if (!_isInitialized || _coreAudioManager == null) return;
    await _coreAudioManager!.setVolumes(
      masterVolume: _coreAudioManager!.configuration.masterVolume,
      bgmVolume: volume,
      sfxVolume: _coreAudioManager!.configuration.sfxVolume,
    );
  }

  Future<void> setSfxVolume(double volume) async {
    if (!_isInitialized || _coreAudioManager == null) return;
    await _coreAudioManager!.setVolumes(
      masterVolume: _coreAudioManager!.configuration.masterVolume,
      bgmVolume: _coreAudioManager!.configuration.bgmVolume,
      sfxVolume: volume,
    );
  }

  /// オーディオ有効/無効切り替え
  Future<void> setBgmEnabled(bool enabled) async {
    if (!_isInitialized || _coreAudioManager == null) return;
    _coreAudioManager!.setBgmEnabled(enabled);
  }

  Future<void> setSfxEnabled(bool enabled) async {
    if (!_isInitialized || _coreAudioManager == null) return;
    _coreAudioManager!.setSfxEnabled(enabled);
  }

  /// 状態取得
  bool get isBgmPlaying => _bgmContextManager?.isBgmPlaying ?? false;
  BgmContext get currentBgmContext =>
      _bgmContextManager?.currentContext ?? BgmContext.silent;

  /// デバッグ情報取得
  Map<String, dynamic> getDebugInfo() {
    return {
      'isInitialized': _isInitialized,
      'currentBgmContext': currentBgmContext.name,
      'isBgmPlaying': isBgmPlaying,
      'coreManager': _coreAudioManager?.getDebugInfo() ?? 'not initialized',
    };
  }

  /// リソースクリーンアップ
  Future<void> dispose() async {
    await _bgmContextManager?.stopCurrentBgm();
    _bgmContextManager?.dispose();
    _enhancedSfxSystem?.dispose();
    await _coreAudioManager?.dispose();

    _coreAudioManager = null;
    _bgmContextManager = null;
    _enhancedSfxSystem = null;
    _isInitialized = false;

    debugPrint('🔇 Integrated Audio Manager disposed');
  }
}

/// ゲーム音響コンテキスト
enum GameAudioContext {
  /// ゲーム開始・メニュー表示
  gameStart,

  /// ゲーム探索中
  gameExploration,

  /// パズル活動中
  puzzleActive,

  /// ゲームクリア
  gameCleared,

  /// ゲーム一時停止
  gamePaused,

  /// ゲーム再開
  gameResumed,
}

/// 統合音響システム初期化ヘルパー
class AudioSystemInitializer {
  /// フレームワーク統合初期化
  static Future<IntegratedAudioManager> initializeForEscapeRoom(
    AudioManager coreAudioManager,
  ) async {
    final integratedManager = IntegratedAudioManager();
    await integratedManager.initialize(coreAudioManager);

    // エスケープルーム用の初期BGM設定
    await integratedManager.updateGameAudio(
      context: GameAudioContext.gameStart,
    );

    return integratedManager;
  }
}
