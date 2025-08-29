import 'package:flutter/foundation.dart';
import 'game_manual_save_system.dart';

/// ゲームイベント時の保存トリガー管理のベースクラス
abstract class GameEventTriggersBase {
  final ProgressAwareDataManager _dataManager;
  bool _isEnabled = true;

  GameEventTriggersBase(this._dataManager);

  /// データマネージャーへのアクセス
  ProgressAwareDataManager get dataManager => _dataManager;

  /// システムの有効・無効切り替え
  bool get isEnabled => _isEnabled;

  void enable() {
    _isEnabled = true;
    if (kDebugMode) {
      debugPrint('Game event triggers enabled');
    }
  }

  void disable() {
    _isEnabled = false;
    if (kDebugMode) {
      debugPrint('Game event triggers disabled');
    }
  }

  /// デバッグ情報
  Map<String, dynamic> getDebugInfo() {
    return {
      'enabled': _isEnabled,
      'data_manager_info': _dataManager.getDebugInfo(),
    };
  }
}