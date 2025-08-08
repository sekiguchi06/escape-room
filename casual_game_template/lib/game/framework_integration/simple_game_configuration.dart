import 'package:flutter/material.dart';
import '../../framework/config/game_configuration.dart';
import '../../framework/state/game_state_system.dart';

/// SimpleGame用の設定クラス（フレームワーク統合）
class SimpleGameConfig {
  final Duration gameDuration;
  final Map<String, String> stateTexts;
  final Map<String, Color> stateColors;
  final Map<String, double> fontSizes;
  final Map<String, FontWeight> fontWeights;
  final bool enableDebugMode;
  final bool enableAnalytics;
  
  const SimpleGameConfig({
    required this.gameDuration,
    required this.stateTexts,
    required this.stateColors,
    required this.fontSizes,
    required this.fontWeights,
    this.enableDebugMode = false,
    this.enableAnalytics = true,
  });
  
  /// JSON変換
  Map<String, dynamic> toJson() {
    return {
      'gameDurationMs': gameDuration.inMilliseconds,
      'stateTexts': stateTexts,
      'stateColors': stateColors.map((k, v) => MapEntry(k, v.toARGB32())),
      'fontSizes': fontSizes,
      'fontWeights': fontWeights.map((k, v) => MapEntry(k, v.index)),
      'enableDebugMode': enableDebugMode,
      'enableAnalytics': enableAnalytics,
    };
  }
  
  /// JSONから復元
  factory SimpleGameConfig.fromJson(Map<String, dynamic> json) {
    return SimpleGameConfig(
      gameDuration: Duration(milliseconds: json['gameDurationMs'] ?? 5000),
      stateTexts: Map<String, String>.from(json['stateTexts'] ?? {}),
      stateColors: (json['stateColors'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, Color(v as int))),
      fontSizes: (json['fontSizes'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, (v as num).toDouble())),
      fontWeights: (json['fontWeights'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, FontWeight.values[v as int])),
      enableDebugMode: json['enableDebugMode'] ?? false,
      enableAnalytics: json['enableAnalytics'] ?? true,
    );
  }
  
  /// コピー作成
  SimpleGameConfig copyWith({
    Duration? gameDuration,
    Map<String, String>? stateTexts,
    Map<String, Color>? stateColors,
    Map<String, double>? fontSizes,
    Map<String, FontWeight>? fontWeights,
    bool? enableDebugMode,
    bool? enableAnalytics,
  }) {
    return SimpleGameConfig(
      gameDuration: gameDuration ?? this.gameDuration,
      stateTexts: stateTexts ?? this.stateTexts,
      stateColors: stateColors ?? this.stateColors,
      fontSizes: fontSizes ?? this.fontSizes,
      fontWeights: fontWeights ?? this.fontWeights,
      enableDebugMode: enableDebugMode ?? this.enableDebugMode,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
    );
  }
  
  /// 状態に応じたテキスト取得
  String getStateText(String stateName, {double? timeRemaining}) {
    String text = stateTexts[stateName] ?? 'Unknown State';
    
    if (timeRemaining != null && text.contains('{time}')) {
      text = text.replaceAll('{time}', timeRemaining.toStringAsFixed(1));
    }
    
    return text;
  }
  
  /// 状態に応じた色取得
  Color getStateColor(String stateName) {
    return stateColors[stateName] ?? Colors.white;
  }
  
  /// 動的色計算（時間に応じた警告色）
  Color getDynamicColor(String stateName, {double? timeRemaining}) {
    if (timeRemaining == null) {
      return getStateColor(stateName);
    }
    
    final totalTime = gameDuration.inMilliseconds / 1000.0;
    final ratio = timeRemaining / totalTime;
    
    if (ratio <= 0.2) return Colors.red;
    if (ratio <= 0.4) return Colors.orange;
    return getStateColor(stateName);
  }
  
  /// フォントサイズ取得
  double getFontSize(String stateName) {
    return fontSizes[stateName] ?? 24.0;
  }
  
  /// フォント重み取得
  FontWeight getFontWeight(String stateName) {
    return fontWeights[stateName] ?? FontWeight.bold;
  }
}

/// SimpleGame用のフレームワーク統合設定クラス
class SimpleGameConfiguration extends GameConfiguration<GameState, SimpleGameConfig> 
    with ChangeNotifier, ConfigurationNotifier<GameState, SimpleGameConfig> {
  
  SimpleGameConfiguration({required super.config});
  
  @override
  bool isValid() {
    return config.gameDuration.inMilliseconds > 0 &&
           config.stateTexts.isNotEmpty &&
           config.stateColors.isNotEmpty;
  }
  
  @override
  bool isValidConfig(SimpleGameConfig config) {
    return config.gameDuration.inMilliseconds > 0 &&
           config.stateTexts.isNotEmpty &&
           config.stateColors.isNotEmpty;
  }
  
  @override
  SimpleGameConfig copyWith(Map<String, dynamic> overrides) {
    return config.copyWith(
      gameDuration: overrides['gameDuration'] as Duration?,
      stateTexts: overrides['stateTexts'] as Map<String, String>?,
      stateColors: overrides['stateColors'] as Map<String, Color>?,
      fontSizes: overrides['fontSizes'] as Map<String, double>?,
      fontWeights: overrides['fontWeights'] as Map<String, FontWeight>?,
      enableDebugMode: overrides['enableDebugMode'] as bool?,
      enableAnalytics: overrides['enableAnalytics'] as bool?,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return config.toJson();
  }
  
  static SimpleGameConfiguration fromJson(Map<String, dynamic> json) {
    return SimpleGameConfiguration(
      config: SimpleGameConfig.fromJson(json),
    );
  }
  
  /// プリセット設定
  static SimpleGameConfiguration get defaultConfig {
    return SimpleGameConfiguration(
      config: const SimpleGameConfig(
        gameDuration: Duration(seconds: 5),
        stateTexts: {
          'start': 'TAP TO START',
          'playing': 'TIME: {time}',
          'gameOver': 'GAME OVER\nTAP TO RESTART',
        },
        stateColors: {
          'start': Colors.white,
          'playing': Colors.white,
          'gameOver': Colors.red,
        },
        fontSizes: {
          'start': 24.0,
          'playing': 28.0,
          'gameOver': 24.0,
        },
        fontWeights: {
          'start': FontWeight.bold,
          'playing': FontWeight.bold,
          'gameOver': FontWeight.bold,
        },
      ),
    );
  }
  
  static SimpleGameConfiguration get easyConfig {
    return SimpleGameConfiguration(
      config: const SimpleGameConfig(
        gameDuration: Duration(seconds: 10),
        stateTexts: {
          'start': '🎮 EASY MODE\nTAP TO START',
          'playing': '⏰ TIME: {time}',
          'gameOver': '💀 GAME OVER\nTAP TO RESTART',
        },
        stateColors: {
          'start': Colors.green,
          'playing': Colors.blue,
          'gameOver': Colors.orange,
        },
        fontSizes: {
          'start': 28.0,
          'playing': 32.0,
          'gameOver': 28.0,
        },
        fontWeights: {
          'start': FontWeight.w600,
          'playing': FontWeight.w600,
          'gameOver': FontWeight.w600,
        },
      ),
    );
  }
  
  static SimpleGameConfiguration get hardConfig {
    return SimpleGameConfiguration(
      config: const SimpleGameConfig(
        gameDuration: Duration(seconds: 3),
        stateTexts: {
          'start': '🔥 HARD MODE\nTAP TO START',
          'playing': '⚡ TIME: {time}',
          'gameOver': '💥 GAME OVER\nTAP TO RESTART',
        },
        stateColors: {
          'start': Colors.red,
          'playing': Colors.yellow,
          'gameOver': Colors.deepOrange,
        },
        fontSizes: {
          'start': 22.0,
          'playing': 26.0,
          'gameOver': 22.0,
        },
        fontWeights: {
          'start': FontWeight.w800,
          'playing': FontWeight.w800,
          'gameOver': FontWeight.w800,
        },
      ),
    );
  }
  
  /// A/Bテスト用設定取得
  @override
  SimpleGameConfig getConfigForVariant(String variantId) {
    switch (variantId) {
      case 'easy':
        return easyConfig.config;
      case 'hard':
        return hardConfig.config;
      default:
        return config;
    }
  }
  
  /// リモート設定同期
  @override
  Future<void> syncWithRemoteConfig() async {
    // TODO: RemoteConfigManagerの実装待ち
    // 現在はスタブ実装
    await Future.delayed(const Duration(milliseconds: 100));
    debugPrint('Remote config sync completed (stub implementation)');
  }
}

/// 設定プリセット管理（フレームワーク統合）
class SimpleGameConfigPresets {
  static final ConfigurationPresets<SimpleGameConfig> _presets = ConfigurationPresets<SimpleGameConfig>();
  
  static void initialize() {
    _presets.registerPreset('default', SimpleGameConfiguration.defaultConfig.config);
    _presets.registerPreset('easy', SimpleGameConfiguration.easyConfig.config);
    _presets.registerPreset('hard', SimpleGameConfiguration.hardConfig.config);
  }
  
  static SimpleGameConfig? getPreset(String name) {
    return _presets.getPreset(name);
  }
  
  static List<String> getAvailablePresets() {
    return _presets.getAvailablePresets();
  }
  
  static SimpleGameConfiguration getConfigurationPreset(String name) {
    final config = getPreset(name);
    if (config == null) {
      throw ArgumentError('Unknown preset: $name');
    }
    return SimpleGameConfiguration(config: config);
  }
}

/// 設定検証ルール
class SimpleGameConfigValidator extends ConfigurationValidator<SimpleGameConfig> {
  @override
  ConfigurationValidationResult validate(SimpleGameConfig config) {
    final errors = <String>[];
    final warnings = <String>[];
    
    // 必須チェック
    if (config.gameDuration.inMilliseconds <= 0) {
      errors.add('Game duration must be positive');
    }
    
    if (config.stateTexts.isEmpty) {
      errors.add('State texts cannot be empty');
    }
    
    if (config.stateColors.isEmpty) {
      errors.add('State colors cannot be empty');
    }
    
    // 警告チェック
    if (config.gameDuration.inSeconds < 2) {
      warnings.add('Game duration is very short (less than 2 seconds)');
    }
    
    if (config.gameDuration.inSeconds > 30) {
      warnings.add('Game duration is very long (more than 30 seconds)');
    }
    
    // 必須状態のチェック
    final requiredStates = ['start', 'playing', 'gameOver'];
    for (final state in requiredStates) {
      if (!config.stateTexts.containsKey(state)) {
        errors.add('Missing text for required state: $state');
      }
      if (!config.stateColors.containsKey(state)) {
        errors.add('Missing color for required state: $state');
      }
    }
    
    if (errors.isNotEmpty) {
      return ConfigurationValidationResult.invalid(errors, warnings);
    }
    
    return ConfigurationValidationResult.valid();
  }
}