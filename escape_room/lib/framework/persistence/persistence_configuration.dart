import 'package:flutter/foundation.dart';

/// データ永続化設定の基底クラス
abstract class PersistenceConfiguration {
  /// 自動保存間隔 (秒)
  int get autoSaveInterval;

  /// 暗号化有効フラグ
  bool get encryptionEnabled;

  /// 暗号化キー（暗号化有効時）
  String? get encryptionKey;

  /// クラウド同期有効フラグ
  bool get cloudSyncEnabled;

  /// データバージョン（マイグレーション用）
  int get dataVersion;

  /// デバッグモード
  bool get debugMode;

  /// 保存対象データキー一覧
  Set<String> get trackedKeys;
}

/// デフォルト永続化設定
class DefaultPersistenceConfiguration implements PersistenceConfiguration {
  @override
  final int autoSaveInterval;

  @override
  final bool encryptionEnabled;

  @override
  final String? encryptionKey;

  @override
  final bool cloudSyncEnabled;

  @override
  final int dataVersion;

  @override
  final bool debugMode;

  @override
  final Set<String> trackedKeys;

  const DefaultPersistenceConfiguration({
    this.autoSaveInterval = 30,
    this.encryptionEnabled = false,
    this.encryptionKey,
    this.cloudSyncEnabled = false,
    this.dataVersion = 1,
    this.debugMode = kDebugMode,
    this.trackedKeys = const {},
  });

  /// 設定のコピーを作成（一部パラメータの変更可能）
  DefaultPersistenceConfiguration copyWith({
    int? autoSaveInterval,
    bool? encryptionEnabled,
    String? encryptionKey,
    bool? cloudSyncEnabled,
    int? dataVersion,
    bool? debugMode,
    Set<String>? trackedKeys,
  }) {
    return DefaultPersistenceConfiguration(
      autoSaveInterval: autoSaveInterval ?? this.autoSaveInterval,
      encryptionEnabled: encryptionEnabled ?? this.encryptionEnabled,
      encryptionKey: encryptionKey ?? this.encryptionKey,
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      dataVersion: dataVersion ?? this.dataVersion,
      debugMode: debugMode ?? this.debugMode,
      trackedKeys: trackedKeys ?? this.trackedKeys,
    );
  }
}

/// 永続化結果
enum PersistenceResult {
  success,
  failure,
  networkError,
  encryptionError,
  storageFullError,
  permissionError,
}
