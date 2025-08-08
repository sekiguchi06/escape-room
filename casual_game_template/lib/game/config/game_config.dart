import 'package:flutter/material.dart';
import '../framework_integration/simple_game_states.dart';

/// ゲーム設定を一元管理するクラス
/// 外部設定による動作制御を可能にし、A/Bテストやカスタマイズに対応
/// 
class GameConfig {
  /// ゲームの基本時間設定
  final Duration gameDuration;
  
  /// 各状態に対応するテキストメッセージ
  final Map<SimpleGameState, String> stateTexts;
  
  /// 各状態に対応する色設定
  final Map<SimpleGameState, Color> stateColors;
  
  /// タイマー表示の更新間隔（最適化用）
  final Duration timerUpdateInterval;
  
  /// UI設定
  final GameUIConfig uiConfig;
  
  /// デバッグ設定
  final GameDebugConfig debugConfig;

  const GameConfig({
    required this.gameDuration,
    required this.stateTexts,
    required this.stateColors,
    required this.timerUpdateInterval,
    required this.uiConfig,
    required this.debugConfig,
  });

  /// デフォルト設定
  static const GameConfig defaultConfig = GameConfig(
    gameDuration: Duration(seconds: 5),
    stateTexts: {
      SimpleGameState.start: 'TAP TO START',
      SimpleGameState.playing: 'TIME: {time}',
      SimpleGameState.gameOver: 'GAME OVER\nTAP TO RESTART',
    },
    stateColors: {
      SimpleGameState.start: Colors.white,
      SimpleGameState.playing: Colors.white,
      SimpleGameState.gameOver: Colors.red,
    },
    timerUpdateInterval: Duration(milliseconds: 100),
    uiConfig: GameUIConfig.defaultConfig,
    debugConfig: GameDebugConfig.defaultConfig,
  );

  /// Easy難易度設定
  static const GameConfig easyConfig = GameConfig(
    gameDuration: Duration(seconds: 10),
    stateTexts: {
      SimpleGameState.start: '🎮 EASY MODE\nTAP TO START',
      SimpleGameState.playing: '⏰ TIME: {time}',
      SimpleGameState.gameOver: '💀 GAME OVER\nTAP TO RESTART',
    },
    stateColors: {
      SimpleGameState.start: Colors.green,
      SimpleGameState.playing: Colors.blue,
      SimpleGameState.gameOver: Colors.orange,
    },
    timerUpdateInterval: Duration(milliseconds: 100),
    uiConfig: GameUIConfig.easyConfig,
    debugConfig: GameDebugConfig.defaultConfig,
  );

  /// Hard難易度設定
  static const GameConfig hardConfig = GameConfig(
    gameDuration: Duration(seconds: 3),
    stateTexts: {
      SimpleGameState.start: '🔥 HARD MODE\nTAP TO START',
      SimpleGameState.playing: '⚡ TIME: {time}',
      SimpleGameState.gameOver: '💥 GAME OVER\nTAP TO RESTART',
    },
    stateColors: {
      SimpleGameState.start: Colors.red,
      SimpleGameState.playing: Colors.yellow,
      SimpleGameState.gameOver: Colors.deepOrange,
    },
    timerUpdateInterval: Duration(milliseconds: 50),
    uiConfig: GameUIConfig.hardConfig,
    debugConfig: GameDebugConfig.defaultConfig,
  );

  /// JSONからGameConfigを作成（A/Bテスト・リモート設定用）
  factory GameConfig.fromJson(Map<String, dynamic> json) {
    return GameConfig(
      gameDuration: Duration(milliseconds: json['gameDurationMs'] ?? 5000),
      stateTexts: Map<SimpleGameState, String>.fromEntries(
        (json['stateTexts'] as Map<String, dynamic>? ?? {}).entries.map(
          (e) => MapEntry(_parseGameState(e.key), e.value as String),
        ),
      ),
      stateColors: Map<SimpleGameState, Color>.fromEntries(
        (json['stateColors'] as Map<String, dynamic>? ?? {}).entries.map(
          (e) => MapEntry(_parseGameState(e.key), Color(e.value as int)),
        ),
      ),
      timerUpdateInterval: Duration(milliseconds: json['timerUpdateIntervalMs'] ?? 100),
      uiConfig: GameUIConfig.fromJson(json['uiConfig'] ?? {}),
      debugConfig: GameDebugConfig.fromJson(json['debugConfig'] ?? {}),
    );
  }

  /// GameConfigをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'gameDurationMs': gameDuration.inMilliseconds,
      'stateTexts': Map<String, String>.fromEntries(
        stateTexts.entries.map((e) => MapEntry(e.key.name, e.value)),
      ),
      'stateColors': Map<String, int>.fromEntries(
        stateColors.entries.map((e) => MapEntry(e.key.name, e.value.toARGB32())),
      ),
      'timerUpdateIntervalMs': timerUpdateInterval.inMilliseconds,
      'uiConfig': uiConfig.toJson(),
      'debugConfig': debugConfig.toJson(),
    };
  }

  /// ゲーム時間を秒数で取得
  double get gameDurationInSeconds => gameDuration.inMilliseconds / 1000.0;

  /// 特定状態のテキストを取得（プレースホルダー対応）
  String getStateText(SimpleGameState state, {double? time}) {
    String text = stateTexts[state] ?? 'UNKNOWN STATE';
    
    if (time != null && text.contains('{time}')) {
      text = text.replaceAll('{time}', time.toStringAsFixed(1));
    }
    
    return text;
  }

  /// 特定状態の色を取得
  Color getStateColor(SimpleGameState state) {
    return stateColors[state] ?? Colors.white;
  }

  /// 時間に応じた動的色設定（警告色など）
  Color getDynamicTimerColor(double timeRemaining) {
    final ratio = timeRemaining / gameDurationInSeconds;
    
    if (ratio <= 0.2) return Colors.red;
    if (ratio <= 0.4) return Colors.orange;
    return getStateColor(SimpleGameState.playing);
  }

  /// 設定の複製（一部変更用）
  GameConfig copyWith({
    Duration? gameDuration,
    Map<SimpleGameState, String>? stateTexts,
    Map<SimpleGameState, Color>? stateColors,
    Duration? timerUpdateInterval,
    GameUIConfig? uiConfig,
    GameDebugConfig? debugConfig,
  }) {
    return GameConfig(
      gameDuration: gameDuration ?? this.gameDuration,
      stateTexts: stateTexts ?? this.stateTexts,
      stateColors: stateColors ?? this.stateColors,
      timerUpdateInterval: timerUpdateInterval ?? this.timerUpdateInterval,
      uiConfig: uiConfig ?? this.uiConfig,
      debugConfig: debugConfig ?? this.debugConfig,
    );
  }

  /// 設定の妥当性チェック
  bool isValid() {
    return gameDuration.inMilliseconds > 0 &&
           stateTexts.isNotEmpty &&
           stateColors.isNotEmpty &&
           timerUpdateInterval.inMilliseconds > 0;
  }

  /// 文字列からGameStateに変換
  static SimpleGameState _parseGameState(String name) {
    switch (name) {
      case 'start':
        return SimpleGameState.start;
      case 'playing':
        return SimpleGameState.playing;
      case 'gameOver':
        return SimpleGameState.gameOver;
      default:
        return SimpleGameState.start;
    }
  }
}

/// UI関連の設定
class GameUIConfig {
  final double fontSize;
  final FontWeight fontWeight;
  final double screenMargin;
  final bool showDebugInfo;

  const GameUIConfig({
    required this.fontSize,
    required this.fontWeight,
    required this.screenMargin,
    required this.showDebugInfo,
  });

  static const GameUIConfig defaultConfig = GameUIConfig(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    screenMargin: 20.0,
    showDebugInfo: false,
  );

  static const GameUIConfig easyConfig = GameUIConfig(
    fontSize: 28.0,
    fontWeight: FontWeight.w600,
    screenMargin: 20.0,
    showDebugInfo: false,
  );

  static const GameUIConfig hardConfig = GameUIConfig(
    fontSize: 22.0,
    fontWeight: FontWeight.w800,
    screenMargin: 15.0,
    showDebugInfo: false,
  );

  factory GameUIConfig.fromJson(Map<String, dynamic> json) {
    return GameUIConfig(
      fontSize: (json['fontSize'] ?? 24.0).toDouble(),
      fontWeight: FontWeight.values[json['fontWeightIndex'] ?? 5],
      screenMargin: (json['screenMargin'] ?? 20.0).toDouble(),
      showDebugInfo: json['showDebugInfo'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      'fontWeightIndex': fontWeight.index,
      'screenMargin': screenMargin,
      'showDebugInfo': showDebugInfo,
    };
  }
}

/// デバッグ関連の設定
class GameDebugConfig {
  final bool enableLogs;
  final bool showPerformanceMetrics;
  final bool showStateTransitions;

  const GameDebugConfig({
    required this.enableLogs,
    required this.showPerformanceMetrics,
    required this.showStateTransitions,
  });

  static const GameDebugConfig defaultConfig = GameDebugConfig(
    enableLogs: true,
    showPerformanceMetrics: false,
    showStateTransitions: true,
  );

  factory GameDebugConfig.fromJson(Map<String, dynamic> json) {
    return GameDebugConfig(
      enableLogs: json['enableLogs'] ?? true,
      showPerformanceMetrics: json['showPerformanceMetrics'] ?? false,
      showStateTransitions: json['showStateTransitions'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enableLogs': enableLogs,
      'showPerformanceMetrics': showPerformanceMetrics,
      'showStateTransitions': showStateTransitions,
    };
  }
}