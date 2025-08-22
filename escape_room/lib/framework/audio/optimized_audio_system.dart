import 'package:flutter/foundation.dart';
import 'package:flame_audio/flame_audio.dart';
import 'web_audio_system.dart'
    if (dart.library.io) 'web_audio_system_stub.dart';

/// ゲームアクション音響タイプ（audioplayers非依存）
enum GameActionType {
  generalTap, // 一般的なタップ
  uiButtonPress, // UIボタン押下
  hotspotInteraction, // ホットスポット相互作用
  itemAcquisition, // アイテム取得
  puzzleSuccess, // パズル成功
  gimmickActivation, // ギミック作動
  errorAction, // エラーアクション
  gameCleared, // ゲームクリア
}

/// 最適化音響システム専用BGMコンテキスト
enum OptimizedBgmContext {
  menu('menu', null), // Assets.sounds.menuを使用
  exploration('exploration', null), // Assets.sounds.explorationAmbientを使用
  puzzle('puzzle', null), // パズル用BGMは未実装
  victory('victory', null), // Assets.sounds.victoryFanfareを使用
  silent('silent', null);

  const OptimizedBgmContext(this.id, this.fileName);
  final String id;
  final String? fileName;

  /// BGMアセットパスを取得（FlameAudioは自動的にassets/audioプレフィックスを追加）
  String? get assetPath {
    switch (this) {
      case OptimizedBgmContext.menu:
        return 'menu.mp3';
      case OptimizedBgmContext.exploration:
        return 'exploration_ambient.mp3';
      case OptimizedBgmContext.victory:
        return 'victory_fanfare.mp3';
      case OptimizedBgmContext.puzzle:
      case OptimizedBgmContext.silent:
        return null;
    }
  }
}

/// AudioPool ベース最適化音響システム
///
/// - 低レイテンシサウンドエフェクト
/// - プラットフォーム条件分岐対応
/// - Web/iOS/Android 互換性
class OptimizedAudioSystem {
  static final OptimizedAudioSystem _instance =
      OptimizedAudioSystem._internal();
  factory OptimizedAudioSystem() => _instance;
  OptimizedAudioSystem._internal();

  // AudioPool インスタンス管理
  final Map<GameActionType, AudioPool?> _audioPools = {};
  final Map<String, String> _soundAssets = {
    GameActionType.generalTap.name: 'menu.mp3',
    GameActionType.uiButtonPress.name: 'menu.mp3',
    GameActionType.hotspotInteraction.name: 'menu.mp3',
    GameActionType.itemAcquisition.name: 'menu.mp3',
    GameActionType.puzzleSuccess.name: 'menu.mp3',
    GameActionType.gimmickActivation.name: 'menu.mp3',
    GameActionType.errorAction.name: 'menu.mp3',
    GameActionType.gameCleared.name: 'victory_fanfare.mp3',
  };

  bool _isInitialized = false;
  OptimizedBgmContext _currentBgmContext = OptimizedBgmContext.silent;

  /// システム初期化
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // プラットフォーム別初期化
      if (_supportsAudioPool) {
        await _initializeAudioPools();
        debugPrint('🔊 OptimizedAudioSystem: AudioPool初期化完了');
      } else {
        await _preloadSounds();
        debugPrint('🔊 OptimizedAudioSystem: Web向けプリロード完了');
      }

      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('❌ OptimizedAudioSystem初期化エラー: $e');
      return false;
    }
  }

  /// AudioPool対応プラットフォーム判定
  bool get _supportsAudioPool => !kIsWeb;

  /// AudioPool群の初期化（モバイル/デスクトップ）
  Future<void> _initializeAudioPools() async {
    debugPrint('🔧 AudioPool初期化開始 (${GameActionType.values.length}個)');

    for (final actionType in GameActionType.values) {
      try {
        final assetPath = _soundAssets[actionType.name];
        debugPrint('🎵 処理中: ${actionType.name} -> $assetPath');

        if (assetPath != null) {
          // 最大同時再生数をアクションタイプ別に最適化
          final maxPlayers = _getMaxPlayers(actionType);
          debugPrint('🎯 AudioPool作成試行: $assetPath (players: $maxPlayers)');

          _audioPools[actionType] = await FlameAudio.createPool(
            assetPath,
            maxPlayers: maxPlayers,
          );
          debugPrint('✅ AudioPool作成成功: ${actionType.name}');
        } else {
          debugPrint('⚠️ アセットパスが見つからない: ${actionType.name}');
        }
      } catch (e) {
        debugPrint('❌ AudioPool作成失敗: ${actionType.name} - $e');
        _audioPools[actionType] = null;
      }
    }

    final successCount = _audioPools.values
        .where((pool) => pool != null)
        .length;
    debugPrint(
      '🔧 AudioPool初期化完了: $successCount/${GameActionType.values.length}個成功',
    );
  }

  /// サウンドファイルのプリロード（Web）
  Future<void> _preloadSounds() async {
    final assetPaths = _soundAssets.values
        .where((path) => path.isNotEmpty)
        .toList();
    await FlameAudio.audioCache.loadAll(assetPaths);
  }

  /// アクションタイプ別最大同時再生数設定
  int _getMaxPlayers(GameActionType actionType) {
    switch (actionType) {
      case GameActionType.generalTap:
      case GameActionType.hotspotInteraction:
        return 4; // 高頻度タップ対応
      case GameActionType.uiButtonPress:
        return 2; // 通常のUI操作
      case GameActionType.itemAcquisition:
      case GameActionType.puzzleSuccess:
        return 1; // 一度に一つのイベント
      case GameActionType.gimmickActivation:
        return 2; // 複数ギミックの同時作動
      case GameActionType.errorAction:
        return 3; // エラー音の重複防止
      case GameActionType.gameCleared:
        return 1; // ゲームクリア時の単発音
    }
  }

  /// ゲームアクション音響再生
  Future<void> playActionSound(
    GameActionType actionType, {
    double volume = 1.0,
    double volumeMultiplier = 1.0,
  }) async {
    if (!_isInitialized) {
      debugPrint('⚠️ OptimizedAudioSystem: 未初期化状態での再生要求');
      return;
    }

    // Web版ではWeb Audio APIを使用
    if (kIsWeb) {
      WebAudioSystem().playActionSound(actionType.name);
      debugPrint('🔊 WebAudioSystem再生: ${actionType.name}');
      return;
    }

    // iOS/Android: FlameAudio直接再生を使用
    final finalVolume = (volume * volumeMultiplier).clamp(0.0, 1.0);

    try {
      // まず FlameAudio 直接再生を試行（AudioPool問題の回避）
      final assetPath = _soundAssets[actionType.name];
      if (assetPath != null) {
        await FlameAudio.play(assetPath, volume: finalVolume);
        debugPrint(
          '🔊 FlameAudio直接再生: ${actionType.name} ($assetPath) (vol: $finalVolume)',
        );
        return;
      }

      // フォールバック: AudioPool使用
      if (_supportsAudioPool) {
        final pool = _audioPools[actionType];
        if (pool != null) {
          await pool.start(volume: finalVolume);
          debugPrint('🔊 AudioPool再生: ${actionType.name} (vol: $finalVolume)');
        } else {
          debugPrint('⚠️ AudioPool未使用可能: ${actionType.name}');
        }
      }
    } catch (e) {
      debugPrint('❌ 音響再生エラー [${actionType.name}]: $e');
    }
  }

  /// BGM管理
  Future<void> playBgm(
    OptimizedBgmContext context, {
    double volume = 0.7,
  }) async {
    if (_currentBgmContext == context) return;

    try {
      // 現在のBGMを停止
      await FlameAudio.bgm.stop();

      final assetPath = context.assetPath;
      if (assetPath != null) {
        await FlameAudio.bgm.play(assetPath, volume: volume);
        debugPrint('🎵 BGM開始: ${context.id} ($assetPath)');
      }

      _currentBgmContext = context;
    } catch (e) {
      debugPrint('❌ BGM制御エラー: $e');
    }
  }

  /// BGM停止
  Future<void> stopBgm() async {
    try {
      await FlameAudio.bgm.stop();
      _currentBgmContext = OptimizedBgmContext.silent;
      debugPrint('🎵 BGM停止');
    } catch (e) {
      debugPrint('❌ BGM停止エラー: $e');
    }
  }

  /// リソース解放
  void dispose() {
    try {
      if (_supportsAudioPool) {
        // AudioPool の解放処理は自動管理される
        _audioPools.clear();
      }
      FlameAudio.audioCache.clearAll();
      _isInitialized = false;
      debugPrint('🗑️ OptimizedAudioSystem disposed');
    } catch (e) {
      debugPrint('⚠️ リソース解放エラー: $e');
    }
  }

  /// システム状態確認
  Map<String, dynamic> getSystemStatus() {
    return {
      'initialized': _isInitialized,
      'supportsAudioPool': _supportsAudioPool,
      'currentBgmContext': _currentBgmContext.id,
      'audioPoolsLoaded': _audioPools.length,
      'audioPoolsReady': _audioPools.values
          .where((pool) => pool != null)
          .length,
    };
  }
}
