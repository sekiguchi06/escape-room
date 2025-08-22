import 'package:flutter/foundation.dart';
import '../state/game_state_system.dart';

/// 汎用ゲーム設定の抽象基底クラス
/// 型パラメータでゲーム固有の状態と設定を定義可能
abstract class GameConfiguration<TState extends GameState, TConfig> {
  TConfig config;
  Map<TState, dynamic> stateConfigs;

  GameConfiguration({required this.config, this.stateConfigs = const {}});

  /// 設定の妥当性チェック
  bool isValid();

  /// 設定を更新
  void updateConfig(TConfig newConfig) {
    if (isValidConfig(newConfig)) {
      final oldConfig = config;
      config = newConfig;
      onConfigurationChanged(oldConfig, newConfig);
    }
  }

  /// 特定の値のみ上書き更新
  TConfig copyWith(Map<String, dynamic> overrides);

  /// 設定変更時のコールバック
  void onConfigurationChanged(TConfig oldConfig, TConfig newConfig) {
    debugPrint('Configuration changed: $oldConfig -> $newConfig');
  }

  /// JSON形式でのシリアライゼーション
  Map<String, dynamic> toJson();

  /// JSONからの復元（サブクラスで実装）
  static T fromJson<T extends GameConfiguration>(Map<String, dynamic> json) {
    throw UnimplementedError('Subclass must implement fromJson');
  }

  /// リモート設定との同期
  Future<void> syncWithRemoteConfig() async {
    // Firebase Remote Config等との統合
    // サブクラスでオーバーライド可能
  }

  /// A/Bテスト用の設定取得
  TConfig getConfigForVariant(String variantId) {
    // A/Bテスト対応
    return config;
  }

  /// 設定の妥当性チェック（サブクラスで実装）
  bool isValidConfig(TConfig config);

  /// デバッグ情報取得
  Map<String, dynamic> getDebugInfo() {
    return {
      'config': config.toString(),
      'stateConfigs': stateConfigs.toString(),
      'isValid': isValid(),
    };
  }
}

/// 設定変更通知を提供するミックスイン
mixin ConfigurationNotifier<TState extends GameState, TConfig>
    on GameConfiguration<TState, TConfig>, ChangeNotifier {
  @override
  void updateConfig(TConfig newConfig) {
    super.updateConfig(newConfig);
    notifyListeners();
  }

  @override
  void onConfigurationChanged(TConfig oldConfig, TConfig newConfig) {
    super.onConfigurationChanged(oldConfig, newConfig);
    notifyListeners();
  }
}

/// リモート設定管理
class RemoteConfigManager {
  static final RemoteConfigManager _instance = RemoteConfigManager._internal();
  factory RemoteConfigManager() => _instance;
  RemoteConfigManager._internal();

  final Map<String, dynamic> _remoteValues = {};
  final List<void Function(Map<String, dynamic>)> _listeners = [];

  /// リモート値を取得
  T? getValue<T>(String key) {
    final value = _remoteValues[key];
    return value is T ? value : null;
  }

  /// リモート値を設定（テスト用）
  void setValue(String key, dynamic value) {
    _remoteValues[key] = value;
    _notifyListeners();
  }

  /// 変更リスナーを追加
  void addListener(void Function(Map<String, dynamic>) listener) {
    _listeners.add(listener);
  }

  /// 変更リスナーを削除
  void removeListener(void Function(Map<String, dynamic>) listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener(_remoteValues);
    }
  }

  /// Firebase Remote Configと同期
  Future<void> fetchAndActivate() async {
    // Firebase Remote Config実装
    debugPrint('RemoteConfigManager: fetchAndActivate called');
  }
}

/// A/Bテスト管理
class ABTestManager {
  static final ABTestManager _instance = ABTestManager._internal();
  factory ABTestManager() => _instance;
  ABTestManager._internal();

  final Map<String, String> _userVariants = {};

  /// ユーザーのバリアントを取得
  String getUserVariant(String experimentId) {
    return _userVariants[experimentId] ?? 'control';
  }

  /// ユーザーのバリアントを設定
  void setUserVariant(String experimentId, String variantId) {
    _userVariants[experimentId] = variantId;
    debugPrint('ABTest: User assigned to $experimentId = $variantId');
  }

  /// 実験の定義
  void defineExperiment(
    String experimentId,
    List<String> variants,
    Map<String, int> trafficSplit,
  ) {
    // 実験定義とユーザー割り当てロジック
    final totalWeight = trafficSplit.values.fold(
      0,
      (sum, weight) => sum + weight,
    );
    final random = (DateTime.now().millisecondsSinceEpoch % totalWeight);

    int currentWeight = 0;
    for (final entry in trafficSplit.entries) {
      currentWeight += entry.value;
      if (random < currentWeight) {
        setUserVariant(experimentId, entry.key);
        break;
      }
    }
  }
}

/// 設定プリセット管理
class ConfigurationPresets<TConfig> {
  final Map<String, TConfig> _presets = {};

  /// プリセットを登録
  void registerPreset(String name, TConfig config) {
    _presets[name] = config;
  }

  /// プリセットを取得
  TConfig? getPreset(String name) {
    return _presets[name];
  }

  /// 利用可能なプリセット一覧
  List<String> getAvailablePresets() {
    return _presets.keys.toList();
  }

  /// プリセットをJSONから一括読み込み
  void loadPresetsFromJson(
    Map<String, dynamic> json,
    TConfig Function(Map<String, dynamic>) fromJson,
  ) {
    for (final entry in json.entries) {
      if (entry.value is Map<String, dynamic>) {
        _presets[entry.key] = fromJson(entry.value);
      }
    }
  }
}

/// 設定検証ルール
abstract class ConfigurationValidator<TConfig> {
  /// 検証結果
  ConfigurationValidationResult validate(TConfig config);
}

class ConfigurationValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ConfigurationValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  factory ConfigurationValidationResult.valid() {
    return const ConfigurationValidationResult(isValid: true);
  }

  factory ConfigurationValidationResult.invalid(
    List<String> errors, [
    List<String> warnings = const [],
  ]) {
    return ConfigurationValidationResult(
      isValid: false,
      errors: errors,
      warnings: warnings,
    );
  }
}

/// 設定変更履歴管理
class ConfigurationHistory<TConfig> {
  final List<ConfigurationHistoryEntry<TConfig>> _history = [];
  final int maxHistorySize;

  ConfigurationHistory({this.maxHistorySize = 100});

  /// 設定変更を記録
  void recordChange(TConfig oldConfig, TConfig newConfig, String reason) {
    final entry = ConfigurationHistoryEntry(
      oldConfig: oldConfig,
      newConfig: newConfig,
      timestamp: DateTime.now(),
      reason: reason,
    );

    _history.add(entry);

    // 履歴サイズ制限
    if (_history.length > maxHistorySize) {
      _history.removeAt(0);
    }
  }

  /// 履歴を取得
  List<ConfigurationHistoryEntry<TConfig>> getHistory() {
    return List.unmodifiable(_history);
  }

  /// 特定の時間範囲の履歴を取得
  List<ConfigurationHistoryEntry<TConfig>> getHistoryInRange(
    DateTime start,
    DateTime end,
  ) {
    return _history
        .where(
          (entry) =>
              entry.timestamp.isAfter(start) && entry.timestamp.isBefore(end),
        )
        .toList();
  }
}

class ConfigurationHistoryEntry<TConfig> {
  final TConfig oldConfig;
  final TConfig newConfig;
  final DateTime timestamp;
  final String reason;

  const ConfigurationHistoryEntry({
    required this.oldConfig,
    required this.newConfig,
    required this.timestamp,
    required this.reason,
  });
}

/// 脱出ゲーム専用設定
/// 移植ガイド準拠実装
class EscapeRoomConfig {
  final Duration timeLimit;
  final int maxInventoryItems;
  final List<String> requiredItems;
  final String roomTheme;
  final int difficultyLevel;

  const EscapeRoomConfig({
    this.timeLimit = const Duration(minutes: 10),
    this.maxInventoryItems = 8,
    this.requiredItems = const ['key', 'code', 'tool'],
    this.roomTheme = 'office',
    this.difficultyLevel = 1,
  });

  /// 設定のコピー作成
  EscapeRoomConfig copyWith({
    Duration? timeLimit,
    int? maxInventoryItems,
    List<String>? requiredItems,
    String? roomTheme,
    int? difficultyLevel,
  }) {
    return EscapeRoomConfig(
      timeLimit: timeLimit ?? this.timeLimit,
      maxInventoryItems: maxInventoryItems ?? this.maxInventoryItems,
      requiredItems: requiredItems ?? this.requiredItems,
      roomTheme: roomTheme ?? this.roomTheme,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
    );
  }

  /// JSONシリアライゼーション
  Map<String, dynamic> toJson() {
    return {
      'timeLimit': timeLimit.inMinutes,
      'maxInventoryItems': maxInventoryItems,
      'requiredItems': requiredItems,
      'roomTheme': roomTheme,
      'difficultyLevel': difficultyLevel,
    };
  }

  /// JSONからの復元
  factory EscapeRoomConfig.fromJson(Map<String, dynamic> json) {
    return EscapeRoomConfig(
      timeLimit: Duration(minutes: json['timeLimit'] ?? 10),
      maxInventoryItems: json['maxInventoryItems'] ?? 8,
      requiredItems: List<String>.from(
        json['requiredItems'] ?? ['key', 'code', 'tool'],
      ),
      roomTheme: json['roomTheme'] ?? 'office',
      difficultyLevel: json['difficultyLevel'] ?? 1,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EscapeRoomConfig &&
        other.timeLimit == timeLimit &&
        other.maxInventoryItems == maxInventoryItems &&
        other.requiredItems.toString() == requiredItems.toString() &&
        other.roomTheme == roomTheme &&
        other.difficultyLevel == difficultyLevel;
  }

  @override
  int get hashCode {
    return Object.hash(
      timeLimit,
      maxInventoryItems,
      requiredItems,
      roomTheme,
      difficultyLevel,
    );
  }

  @override
  String toString() {
    return 'EscapeRoomConfig(timeLimit: $timeLimit, maxItems: $maxInventoryItems, items: $requiredItems, theme: $roomTheme, difficulty: $difficultyLevel)';
  }
}
