import 'package:flutter/material.dart';
import 'simple_game_states.dart';
import '../../framework/state/game_state_system.dart';
import '../../framework/config/game_configuration.dart';

/// シンプルゲームの設定クラス
class SimpleGameConfig {
  final Duration gameDuration;
  final Map<String, String> stateTexts;
  final Map<String, Color> stateColors;
  final Map<String, double> fontSizes;
  final Map<String, FontWeight> fontWeights;
  final bool enableDebugMode;
  final bool enableAnalytics;

  const SimpleGameConfig({
    this.gameDuration = const Duration(seconds: 10),
    this.stateTexts = const {
      'start': 'タップしてスタート',
      'playing': '残り時間: {time}秒',
      'gameOver': 'ゲーム終了\nもう一度？',
    },
    this.stateColors = const {
      'start': Colors.blue,
      'playing': Colors.green,
      'gameOver': Colors.red,
    },
    this.fontSizes = const {'start': 16.0, 'playing': 18.0, 'gameOver': 14.0},
    this.fontWeights = const {
      'start': FontWeight.normal,
      'playing': FontWeight.bold,
      'gameOver': FontWeight.normal,
    },
    this.enableDebugMode = false,
    this.enableAnalytics = false,
  });

  String getStateText(String state, {double? timeRemaining}) {
    final text = stateTexts[state] ?? '';
    if (timeRemaining != null) {
      return text.replaceAll('{time}', timeRemaining.toStringAsFixed(1));
    }
    return text;
  }

  Color getStateColor(String state) => stateColors[state] ?? Colors.black;

  /// JSON形式に変換
  Map<String, dynamic> toJson() {
    return {
      'gameDurationMs': gameDuration.inMilliseconds,
      'stateTexts': stateTexts,
      'stateColors': stateColors.map(
        (key, value) => MapEntry(key, value.value),
      ),
      'fontSizes': fontSizes,
      'fontWeights': fontWeights.map(
        (key, value) => MapEntry(key, value.index),
      ),
      'enableDebugMode': enableDebugMode,
      'enableAnalytics': enableAnalytics,
    };
  }

  /// JSONから復元
  static SimpleGameConfig fromJson(Map<String, dynamic> json) {
    return SimpleGameConfig(
      gameDuration: Duration(milliseconds: json['gameDurationMs'] ?? 10000),
      stateTexts: Map<String, String>.from(json['stateTexts'] ?? {}),
      stateColors: (json['stateColors'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, Color(value)),
      ),
      fontSizes: Map<String, double>.from(json['fontSizes'] ?? {}),
      fontWeights: (json['fontWeights'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, FontWeight.values[value]),
      ),
      enableDebugMode: json['enableDebugMode'] ?? false,
      enableAnalytics: json['enableAnalytics'] ?? false,
    );
  }

  Color getDynamicColor(String state, {double? timeRemaining}) {
    final baseColor = getStateColor(state);
    if (timeRemaining != null && timeRemaining < 5.0) {
      return Colors.red; // 緊急色
    }
    return baseColor;
  }

  double getFontSize(String state) => fontSizes[state] ?? 16.0;

  FontWeight getFontWeight(String state) =>
      fontWeights[state] ?? FontWeight.normal;
}

/// 設定バリデーション結果
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });
}

/// 設定バリデータ
class SimpleGameConfigValidator {
  ValidationResult validate(SimpleGameConfig config) {
    final errors = <String>[];
    final warnings = <String>[];

    if (config.gameDuration.inSeconds <= 0) {
      errors.add('Game duration must be positive');
    }

    if (config.stateTexts.isEmpty) {
      errors.add('State texts cannot be empty');
    }

    if (config.stateColors.isEmpty) {
      errors.add('State colors cannot be empty');
    }

    if (config.gameDuration.inSeconds > 300) {
      warnings.add(
        'Game duration is very long (${config.gameDuration.inSeconds}s)',
      );
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
}

/// 状態プロバイダー統計情報
class StateProviderStatistics {
  final int sessionCount;
  final int totalStateChanges;
  final Duration sessionDuration;
  final String mostVisitedState;
  final double averageStateTransitionsPerSession;

  const StateProviderStatistics({
    required this.sessionCount,
    required this.totalStateChanges,
    required this.sessionDuration,
    required this.mostVisitedState,
    required this.averageStateTransitionsPerSession,
  });
}

/// シンプルゲーム状態プロバイダー
class SimpleGameStateProvider extends GameStateProvider<SimpleGameState> {
  int _sessionCount = 0;
  int _totalStateChanges = 0;
  final DateTime _startTime = DateTime.now();
  final Map<String, int> _stateVisitCounts = {};

  SimpleGameStateProvider() : super(const SimpleGameStartState()) {
    // 状態遷移ルールを設定
    _setupStateTransitions();
  }

  void _setupStateTransitions() {
    // Start -> Playing の遷移を許可
    defineTransition(
      StateTransition<SimpleGameState>(
        fromState: SimpleGameStartState,
        toState: SimpleGamePlayingState,
      ),
    );

    // Playing -> GameOver の遷移を許可
    defineTransition(
      StateTransition<SimpleGameState>(
        fromState: SimpleGamePlayingState,
        toState: SimpleGameOverState,
      ),
    );

    // GameOver -> Playing の遷移を許可（リスタート）
    defineTransition(
      StateTransition<SimpleGameState>(
        fromState: SimpleGameOverState,
        toState: SimpleGamePlayingState,
      ),
    );

    // GameOver -> Start の遷移を許可（完全リセット）
    defineTransition(
      StateTransition<SimpleGameState>(
        fromState: SimpleGameOverState,
        toState: SimpleGameStartState,
      ),
    );

    // Playing -> Playing の遷移を許可（タイマー更新等）
    defineTransition(
      StateTransition<SimpleGameState>(
        fromState: SimpleGamePlayingState,
        toState: SimpleGamePlayingState,
      ),
    );
  }

  bool isInState<T extends SimpleGameState>() => currentState is T;

  T? getStateAs<T extends SimpleGameState>() {
    if (currentState is T) {
      return currentState as T;
    }
    return null;
  }

  bool startGame(double timeRemaining) {
    if (currentState is SimpleGameStartState) {
      _sessionCount++;
      transitionTo(
        SimpleGamePlayingState(
          sessionNumber: _sessionCount,
          timeRemaining: timeRemaining.abs(), // 負の値を正に調整
        ),
      );
      return true;
    }
    return false;
  }

  void updateTimer(double timeRemaining) {
    if (currentState is SimpleGamePlayingState) {
      final playingState = currentState as SimpleGamePlayingState;
      if (timeRemaining <= 0) {
        transitionTo(
          SimpleGameOverState(
            sessionNumber: playingState.sessionNumber,
            finalScore: playingState.score,
          ),
        );
      } else {
        transitionTo(
          SimpleGamePlayingState(
            sessionNumber: playingState.sessionNumber,
            score: playingState.score,
            timeRemaining: timeRemaining,
            level: playingState.level,
          ),
        );
      }
    }
  }

  bool restart(double timeRemaining) {
    if (currentState is SimpleGameOverState) {
      _sessionCount++;
      transitionTo(
        SimpleGamePlayingState(
          sessionNumber: _sessionCount,
          timeRemaining: timeRemaining,
        ),
      );
      return true;
    }
    return false; // start状態からのrestartは無効
  }

  void resetToState(SimpleGameState state) {
    transitionTo(state);
  }

  @override
  bool transitionTo(SimpleGameState newState) {
    _totalStateChanges++;
    final stateName = newState.runtimeType.toString();
    _stateVisitCounts[stateName] = (_stateVisitCounts[stateName] ?? 0) + 1;
    return super.transitionTo(newState);
  }

  @override
  StateStatistics getStatistics() {
    final stats = super.getStatistics();
    // Add our custom statistics to the base stats
    // The base stats already track visit counts from transition history
    return stats;
  }

  StateProviderStatistics getDetailedStatistics() {
    final mostVisitedEntry = _stateVisitCounts.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    return StateProviderStatistics(
      sessionCount: _sessionCount,
      totalStateChanges: _totalStateChanges,
      sessionDuration: DateTime.now().difference(_startTime),
      mostVisitedState: mostVisitedEntry.key,
      averageStateTransitionsPerSession: _sessionCount > 0
          ? _totalStateChanges / _sessionCount
          : 0.0,
    );
  }
}

/// 設定プリセット管理
class SimpleGameConfigPresets {
  static final Map<String, SimpleGameConfig> _presets = {};
  static final Map<String, SimpleGameConfiguration> _configurations = {};

  static void initialize() {
    _presets['default'] = const SimpleGameConfig();
    _presets['easy'] = const SimpleGameConfig(
      gameDuration: Duration(seconds: 15),
      stateTexts: {
        'start': '簡単モード\nタップしてスタート',
        'playing': 'のんびり行こう: {time}秒',
        'gameOver': '簡単だったね！\nもう一度？',
      },
    );
    _presets['hard'] = const SimpleGameConfig(
      gameDuration: Duration(seconds: 5),
      stateTexts: {
        'start': 'ハードモード\n準備はいい？',
        'playing': '急いで！: {time}秒',
        'gameOver': 'ハード！\nリベンジ？',
      },
      stateColors: {
        'start': Colors.orange,
        'playing': Colors.red,
        'gameOver': Colors.purple,
      },
    );

    _configurations['default'] = SimpleGameConfiguration.defaultConfig;
    _configurations['easy'] = SimpleGameConfiguration.easyConfig;
    _configurations['hard'] = SimpleGameConfiguration.hardConfig;
  }

  static SimpleGameConfig? getPreset(String name) => _presets[name];
  static SimpleGameConfiguration getConfigurationPreset(String name) =>
      _configurations[name] ?? SimpleGameConfiguration.defaultConfig;
}

/// 状態ファクトリ
class SimpleGameStateFactory {
  static SimpleGameState createStartState() => const SimpleGameStartState();
  static SimpleGameState createPlayingState({
    int sessionNumber = 1,
    double timeRemaining = 60.0,
  }) => SimpleGamePlayingState(
    sessionNumber: sessionNumber,
    timeRemaining: timeRemaining,
  );
  static SimpleGameState createGameOverState({
    bool isVictory = false,
    int sessionNumber = 1,
  }) => SimpleGameOverState(isVictory: isVictory, sessionNumber: sessionNumber);
}

/// ゲーム設定マネージャー
class SimpleGameConfiguration
    extends GameConfiguration<SimpleGameState, SimpleGameConfig> {
  final Map<String, SimpleGameConfig> variants;

  SimpleGameConfiguration({
    required SimpleGameConfig config,
    this.variants = const {},
  }) : super(config: config);

  static final defaultConfig = SimpleGameConfiguration(
    config: const SimpleGameConfig(),
    variants: const {
      'easy': SimpleGameConfig(gameDuration: Duration(seconds: 15)),
      'hard': SimpleGameConfig(gameDuration: Duration(seconds: 5)),
    },
  );

  static final easyConfig = SimpleGameConfiguration(
    config: const SimpleGameConfig(gameDuration: Duration(seconds: 15)),
  );

  static final hardConfig = SimpleGameConfiguration(
    config: const SimpleGameConfig(gameDuration: Duration(seconds: 5)),
  );

  @override
  bool isValid() => true; // 基本的な有効性チェック

  @override
  SimpleGameConfig copyWith(Map<String, dynamic> overrides) {
    return SimpleGameConfig(
      gameDuration: overrides['gameDuration'] ?? config.gameDuration,
      stateTexts: overrides['stateTexts'] ?? config.stateTexts,
      stateColors: overrides['stateColors'] ?? config.stateColors,
      fontSizes: overrides['fontSizes'] ?? config.fontSizes,
      fontWeights: overrides['fontWeights'] ?? config.fontWeights,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'gameDuration': config.gameDuration.inMilliseconds,
      'stateTexts': config.stateTexts,
      'variants': variants.map(
        (key, value) =>
            MapEntry(key, {'gameDuration': value.gameDuration.inMilliseconds}),
      ),
    };
  }

  @override
  bool isValidConfig(SimpleGameConfig config) => true;

  SimpleGameConfig getConfigForVariant(String variant) {
    return variants[variant] ?? config;
  }
}
