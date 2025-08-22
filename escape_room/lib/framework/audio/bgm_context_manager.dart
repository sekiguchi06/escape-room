import 'package:flutter/foundation.dart';
import 'audio_system.dart';

/// BGMコンテキスト管理システム
/// ゲーム状態に応じて適切なBGMを自動切り替え
class BgmContextManager {
  static final BgmContextManager _instance = BgmContextManager._internal();
  factory BgmContextManager() => _instance;
  BgmContextManager._internal();

  AudioManager? _audioManager;
  BgmContext _currentContext = BgmContext.menu;
  String? _currentBgmId;
  bool _isInitialized = false;

  /// AudioManagerを設定して初期化
  void initialize(AudioManager audioManager) {
    _audioManager = audioManager;
    _isInitialized = true;
  }

  /// 現在のBGMコンテキストを取得
  BgmContext get currentContext => _currentContext;

  /// BGMコンテキストを変更
  Future<void> switchContext(
    BgmContext context, {
    bool forceRestart = false,
  }) async {
    if (!_isInitialized || _audioManager == null) return;

    final newBgmId = context.bgmAssetId;

    // 同じBGMが再生中で強制再開でない場合はスキップ
    if (_currentBgmId == newBgmId && !forceRestart) {
      _currentContext = context;
      return;
    }

    // BGM切り替え実行
    if (_currentBgmId != null) {
      await _audioManager!.stopBgm();
    }

    if (newBgmId != null) {
      await _audioManager!.playBgm(newBgmId);
      _currentBgmId = newBgmId;
    } else {
      _currentBgmId = null;
    }

    _currentContext = context;

    debugPrint(
      '🎵 BGM Context switched to: ${context.name} (${newBgmId ?? 'silent'})',
    );
  }

  /// 現在のBGMを停止
  Future<void> stopCurrentBgm() async {
    if (!_isInitialized || _audioManager == null) return;

    await _audioManager!.stopBgm();
    _currentBgmId = null;
    debugPrint('🔇 BGM stopped');
  }

  /// BGMを一時停止
  Future<void> pauseCurrentBgm() async {
    if (!_isInitialized || _audioManager == null) return;
    await _audioManager!.pauseBgm();
  }

  /// BGMを再開
  Future<void> resumeCurrentBgm() async {
    if (!_isInitialized || _audioManager == null) return;
    await _audioManager!.resumeBgm();
  }

  /// BGMが再生中かどうか
  bool get isBgmPlaying => _audioManager?.isBgmPlaying ?? false;

  /// リソースクリーンアップ
  void dispose() {
    _audioManager = null;
    _isInitialized = false;
    _currentBgmId = null;
  }
}

/// BGMコンテキスト定義
enum BgmContext {
  /// メニュー・スタート画面 (menu.mp3使用)
  menu('menu', 'menu'),

  /// ゲーム探索中 (新規: exploration_ambient.mp3)
  exploration('exploration', 'exploration_ambient'),

  /// パズル解決中 (exploration継続または専用BGM)
  puzzle('puzzle', 'exploration_ambient'),

  /// ゲームクリア (新規: victory_fanfare.mp3)
  victory('victory', 'victory_fanfare'),

  /// 無音・BGM停止
  silent('silent', null);

  const BgmContext(this.name, this.bgmAssetId);

  /// コンテキスト名
  final String name;

  /// 対応するBGMアセットID (nullの場合は無音)
  final String? bgmAssetId;

  /// ゲーム進行状況からコンテキストを推定
  static BgmContext fromGameState({
    required bool isGameActive,
    required bool isGameCleared,
    required bool isPuzzleActive,
  }) {
    if (isGameCleared) return BgmContext.victory;
    if (isPuzzleActive) return BgmContext.puzzle;
    if (isGameActive) return BgmContext.exploration;
    return BgmContext.menu;
  }
}
