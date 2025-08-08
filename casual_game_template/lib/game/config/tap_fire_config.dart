import '../../framework/config/game_configuration.dart';
import '../../framework/state/game_state_system.dart';

/// TapFireGame設定クラス - シンプル設計
/// 
/// SimpleGameConfigをベースにした軽量実装
/// JSONファイルで難易度調整可能
class TapFireConfig {
  final int gameDuration; // seconds
  final double fireballSpawnInterval; // seconds
  final double fireballSpeed; // pixels per second
  final double fireballSize; // pixels
  final int baseScore;
  final String difficulty;

  const TapFireConfig({
    this.gameDuration = 30,
    this.fireballSpawnInterval = 1.5,
    this.fireballSpeed = 80.0,
    this.fireballSize = 40.0,
    this.baseScore = 10,
    this.difficulty = 'normal',
  });

  TapFireConfig copyWith({
    int? gameDuration,
    double? fireballSpawnInterval,
    double? fireballSpeed,
    double? fireballSize,
    int? baseScore,
    String? difficulty,
  }) {
    return TapFireConfig(
      gameDuration: gameDuration ?? this.gameDuration,
      fireballSpawnInterval: fireballSpawnInterval ?? this.fireballSpawnInterval,
      fireballSpeed: fireballSpeed ?? this.fireballSpeed,
      fireballSize: fireballSize ?? this.fireballSize,
      baseScore: baseScore ?? this.baseScore,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  Map<String, dynamic> toJson() => {
    'gameDuration': gameDuration,
    'fireballSpawnInterval': fireballSpawnInterval,
    'fireballSpeed': fireballSpeed,
    'fireballSize': fireballSize,
    'baseScore': baseScore,
    'difficulty': difficulty,
  };

  factory TapFireConfig.fromJson(Map<String, dynamic> json) => TapFireConfig(
    gameDuration: json['gameDuration'] ?? 30,
    fireballSpawnInterval: json['fireballSpawnInterval']?.toDouble() ?? 1.5,
    fireballSpeed: json['fireballSpeed']?.toDouble() ?? 80.0,
    fireballSize: json['fireballSize']?.toDouble() ?? 40.0,
    baseScore: json['baseScore'] ?? 10,
    difficulty: json['difficulty'] ?? 'normal',
  );

  @override
  String toString() => 'TapFireConfig(duration: ${gameDuration}s, speed: $fireballSpeed)';
}

/// 設定プリセット - 3難易度
class TapFireConfigPresets {
  static const TapFireConfig easy = TapFireConfig(
    gameDuration: 45,
    fireballSpawnInterval: 2.0,
    fireballSpeed: 60.0,
    fireballSize: 50.0,
    baseScore: 10,
    difficulty: 'easy',
  );

  static const TapFireConfig normal = TapFireConfig(
    gameDuration: 30,
    fireballSpawnInterval: 1.5,
    fireballSpeed: 80.0,
    fireballSize: 40.0,
    baseScore: 15,
    difficulty: 'normal',
  );

  static const TapFireConfig hard = TapFireConfig(
    gameDuration: 20,
    fireballSpawnInterval: 1.0,
    fireballSpeed: 120.0,
    fireballSize: 30.0,
    baseScore: 25,
    difficulty: 'hard',
  );

  static TapFireConfig getPreset(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy': return easy;
      case 'hard': return hard;
      default: return normal;
    }
  }

  static List<TapFireConfig> get all => [easy, normal, hard];
}

/// GameConfiguration実装
class TapFireGameConfiguration extends GameConfiguration<GameState, TapFireConfig> {
  TapFireGameConfiguration(TapFireConfig config) : super(config: config);

  static final TapFireGameConfiguration defaultConfig = 
    TapFireGameConfiguration(TapFireConfigPresets.normal);

  @override
  bool isValid() => 
    config.gameDuration > 0 && 
    config.fireballSpeed > 0 && 
    config.baseScore > 0;

  @override
  bool isValidConfig(TapFireConfig config) => 
    config.gameDuration > 0 && 
    config.fireballSpeed > 0 && 
    config.baseScore > 0;

  @override
  TapFireConfig copyWith(Map<String, dynamic> overrides) {
    return config.copyWith(
      gameDuration: overrides['gameDuration'] as int?,
      fireballSpawnInterval: overrides['fireballSpawnInterval'] as double?,
      fireballSpeed: overrides['fireballSpeed'] as double?,
      fireballSize: overrides['fireballSize'] as double?,
      baseScore: overrides['baseScore'] as int?,
      difficulty: overrides['difficulty'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => config.toJson();

  @override
  String toString() => 'TapFireGameConfiguration($config)';
}