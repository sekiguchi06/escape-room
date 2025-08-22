import 'package:flutter/foundation.dart';
import 'audio_system.dart';
import 'bgm_context_manager.dart';
import 'optimized_audio_system.dart';

/// 強化効果音システム
/// 全ユーザー操作に対応した包括的な効果音管理
class EnhancedSfxSystem {
  static final EnhancedSfxSystem _instance = EnhancedSfxSystem._internal();
  factory EnhancedSfxSystem() => _instance;
  EnhancedSfxSystem._internal();

  AudioManager? _audioManager;
  bool _isInitialized = false;

  /// AudioManagerを設定して初期化
  void initialize(AudioManager audioManager) {
    _audioManager = audioManager;
    _isInitialized = true;
  }

  /// 基本的なタップ操作音
  Future<void> playTap({double volumeMultiplier = 1.0}) async {
    if (!_canPlaySfx()) return;
    await _audioManager!.playSfx('tap', volumeMultiplier: volumeMultiplier);
  }

  /// ボタンタップ音 (UIボタン用)
  Future<void> playButtonTap({double volumeMultiplier = 0.8}) async {
    if (!_canPlaySfx()) return;
    await _audioManager!.playSfx(
      'button_tap',
      volumeMultiplier: volumeMultiplier,
    );
  }

  /// ホットスポット発見音
  Future<void> playHotspotDiscovery({double volumeMultiplier = 0.9}) async {
    if (!_canPlaySfx()) return;
    await _audioManager!.playSfx(
      'item_found',
      volumeMultiplier: volumeMultiplier,
    );
  }

  /// アイテム取得音
  Future<void> playItemAcquired({double volumeMultiplier = 1.0}) async {
    if (!_canPlaySfx()) return;
    await _audioManager!.playSfx('success', volumeMultiplier: volumeMultiplier);
  }

  /// パズル解決音
  Future<void> playPuzzleSolved({double volumeMultiplier = 1.2}) async {
    if (!_canPlaySfx()) return;
    await _audioManager!.playSfx(
      'puzzle_solved',
      volumeMultiplier: volumeMultiplier,
    );
  }

  /// ドア開放音
  Future<void> playDoorOpen({double volumeMultiplier = 1.0}) async {
    if (!_canPlaySfx()) return;
    await _audioManager!.playSfx(
      'door_open',
      volumeMultiplier: volumeMultiplier,
    );
  }

  /// エラー・失敗音
  Future<void> playError({double volumeMultiplier = 0.7}) async {
    if (!_canPlaySfx()) return;
    await _audioManager!.playSfx('error', volumeMultiplier: volumeMultiplier);
  }

  /// 最終脱出成功音
  Future<void> playEscapeSuccess({double volumeMultiplier = 1.5}) async {
    if (!_canPlaySfx()) return;
    await _audioManager!.playSfx('escape', volumeMultiplier: volumeMultiplier);

    // 脱出成功時は自動的にBGMをビクトリーに切り替え
    await BgmContextManager().switchContext(BgmContext.victory);
  }

  /// ユーザー操作種別に応じた効果音再生
  Future<void> playByUserAction(
    UserActionType action, {
    double? volumeMultiplier,
  }) async {
    switch (action) {
      case UserActionType.generalTap:
        await playTap(volumeMultiplier: volumeMultiplier ?? 0.7);
        break;
      case UserActionType.uiButtonPress:
        await playButtonTap(volumeMultiplier: volumeMultiplier ?? 0.8);
        break;
      case UserActionType.hotspotInteraction:
        await playHotspotDiscovery(volumeMultiplier: volumeMultiplier ?? 0.9);
        break;
      case UserActionType.itemAcquisition:
        await playItemAcquired(volumeMultiplier: volumeMultiplier ?? 1.0);
        break;
      case UserActionType.puzzleSuccess:
        await playPuzzleSolved(volumeMultiplier: volumeMultiplier ?? 1.2);
        break;
      case UserActionType.gimmickActivation:
        await playDoorOpen(volumeMultiplier: volumeMultiplier ?? 1.0);
        break;
      case UserActionType.errorAction:
        await playError(volumeMultiplier: volumeMultiplier ?? 0.7);
        break;
      case UserActionType.gameCleared:
        await playEscapeSuccess(volumeMultiplier: volumeMultiplier ?? 1.5);
        break;
    }
  }

  /// 効果音再生可能かチェック
  bool _canPlaySfx() {
    return _isInitialized && _audioManager != null;
  }

  /// リソースクリーンアップ
  void dispose() {
    _audioManager = null;
    _isInitialized = false;
  }
}

/// ユーザーアクション種別（後方互換性のため残存）
/// 新システムではGameActionTypeを推奨
enum UserActionType {
  /// 一般的なタップ操作
  generalTap,

  /// UIボタン押下
  uiButtonPress,

  /// ホットスポット相互作用
  hotspotInteraction,

  /// アイテム取得
  itemAcquisition,

  /// パズル解決成功
  puzzleSuccess,

  /// ギミック発動 (ドア開放など)
  gimmickActivation,

  /// エラー操作
  errorAction,

  /// ゲームクリア
  gameCleared,
}

/// UserActionType から GameActionType への変換
extension UserActionTypeMapping on UserActionType {
  GameActionType toGameActionType() {
    switch (this) {
      case UserActionType.generalTap:
        return GameActionType.generalTap;
      case UserActionType.uiButtonPress:
        return GameActionType.uiButtonPress;
      case UserActionType.hotspotInteraction:
        return GameActionType.hotspotInteraction;
      case UserActionType.itemAcquisition:
        return GameActionType.itemAcquisition;
      case UserActionType.puzzleSuccess:
        return GameActionType.puzzleSuccess;
      case UserActionType.gimmickActivation:
        return GameActionType.gimmickActivation;
      case UserActionType.errorAction:
        return GameActionType.errorAction;
      case UserActionType.gameCleared:
        return GameActionType.gameCleared;
    }
  }
}

/// 効果音付きユーザー操作ヘルパー
class SfxUserActionHelper {
  /// タップ操作を効果音付きで実行
  static Future<void> executeWithTapSound(
    VoidCallback action, {
    double volumeMultiplier = 0.7,
  }) async {
    await EnhancedSfxSystem().playTap(volumeMultiplier: volumeMultiplier);
    action();
  }

  /// ボタン操作を効果音付きで実行
  static Future<void> executeWithButtonSound(
    VoidCallback action, {
    double volumeMultiplier = 0.8,
  }) async {
    await EnhancedSfxSystem().playButtonTap(volumeMultiplier: volumeMultiplier);
    action();
  }

  /// エラーハンドリング付き操作実行
  static Future<void> executeWithErrorHandling(
    Future<void> Function() action, {
    VoidCallback? onError,
  }) async {
    try {
      await action();
    } catch (e) {
      await EnhancedSfxSystem().playError();
      if (onError != null) onError();
      rethrow;
    }
  }
}
