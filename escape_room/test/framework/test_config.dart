import 'package:flutter/material.dart';
import 'package:escape_room/framework/config/game_configuration.dart';
import 'package:escape_room/framework/state/game_state_system.dart';

/// テスト用の汎用ゲーム設定
class TestGameConfig {
  final Duration maxTime;
  final int maxLevel;
  final Map<String, String> messages;
  final Map<String, Color> colors;
  final bool enablePowerUps;
  final double difficultyMultiplier;
  
  const TestGameConfig({
    required this.maxTime,
    required this.maxLevel,
    required this.messages,
    required this.colors,
    this.enablePowerUps = false,
    this.difficultyMultiplier = 1.0,
  });
  
  TestGameConfig copyWith({
    Duration? maxTime,
    int? maxLevel,
    Map<String, String>? messages,
    Map<String, Color>? colors,
    bool? enablePowerUps,
    double? difficultyMultiplier,
  }) {
    return TestGameConfig(
      maxTime: maxTime ?? this.maxTime,
      maxLevel: maxLevel ?? this.maxLevel,
      messages: messages ?? this.messages,
      colors: colors ?? this.colors,
      enablePowerUps: enablePowerUps ?? this.enablePowerUps,
      difficultyMultiplier: difficultyMultiplier ?? this.difficultyMultiplier,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'maxTimeMs': maxTime.inMilliseconds,
      'maxLevel': maxLevel,
      'messages': messages,
      'colors': colors.map((k, v) => MapEntry(k, v.toARGB32())),
      'enablePowerUps': enablePowerUps,
      'difficultyMultiplier': difficultyMultiplier,
    };
  }
  
  factory TestGameConfig.fromJson(Map<String, dynamic> json) {
    return TestGameConfig(
      maxTime: Duration(milliseconds: json['maxTimeMs'] ?? 60000),
      maxLevel: json['maxLevel'] ?? 5,
      messages: Map<String, String>.from(json['messages'] ?? {}),
      colors: (json['colors'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, Color(v as int))),
      enablePowerUps: json['enablePowerUps'] ?? false,
      difficultyMultiplier: (json['difficultyMultiplier'] ?? 1.0).toDouble(),
    );
  }
}

/// テスト用の汎用ゲーム設定クラス
class TestGameConfiguration extends GameConfiguration<GameState, TestGameConfig> 
    with ChangeNotifier, ConfigurationNotifier<GameState, TestGameConfig> {
  
  TestGameConfiguration({required super.config});
  
  @override
  bool isValid() {
    return config.maxTime.inMilliseconds > 0 &&
           config.maxLevel > 0 &&
           config.messages.isNotEmpty;
  }
  
  @override
  bool isValidConfig(TestGameConfig config) {
    return config.maxTime.inMilliseconds > 0 &&
           config.maxLevel > 0 &&
           config.messages.isNotEmpty;
  }
  
  @override
  TestGameConfig copyWith(Map<String, dynamic> overrides) {
    return config.copyWith(
      maxTime: overrides['maxTime'] as Duration?,
      maxLevel: overrides['maxLevel'] as int?,
      messages: overrides['messages'] as Map<String, String>?,
      colors: overrides['colors'] as Map<String, Color>?,
      enablePowerUps: overrides['enablePowerUps'] as bool?,
      difficultyMultiplier: overrides['difficultyMultiplier'] as double?,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return config.toJson();
  }
  
  static TestGameConfiguration fromJson(Map<String, dynamic> json) {
    return TestGameConfiguration(
      config: TestGameConfig.fromJson(json),
    );
  }
  
  @override
  TestGameConfig getConfigForVariant(String variantId) {
    switch (variantId) {
      case 'easy':
        return config.copyWith(
          maxTime: Duration(seconds: 120),
          maxLevel: 3,
          difficultyMultiplier: 0.5,
        );
      case 'hard':
        return config.copyWith(
          maxTime: Duration(seconds: 30),
          maxLevel: 10,
          difficultyMultiplier: 2.0,
        );
      default:
        return config;
    }
  }
}