import '../config/game_configuration.dart';
import '../state/game_state_system.dart';
import 'configurable_game_base.dart';

/// 設定可能なゲームのビルダー
/// Builderパターンを使用してゲームインスタンスを構築
class ConfigurableGameBuilder<TState extends GameState, TConfig> {
  GameConfiguration<TState, TConfig>? _configuration;
  bool _debugMode = false;
  
  /// 設定を指定
  ConfigurableGameBuilder<TState, TConfig> withConfiguration(
    GameConfiguration<TState, TConfig> configuration
  ) {
    _configuration = configuration;
    return this;
  }
  
  /// デバッグモードを有効化
  ConfigurableGameBuilder<TState, TConfig> withDebugMode(bool enabled) {
    _debugMode = enabled;
    return this;
  }
  
  /// ゲームを構築
  T build<T extends ConfigurableGameBase<TState, TConfig>>(
    T Function(GameConfiguration<TState, TConfig>?, bool) constructor
  ) {
    return constructor(_configuration, _debugMode);
  }
}

/// 高度なゲームビルダー
/// より詳細な設定オプションを提供
class AdvancedGameBuilder<TState extends GameState, TConfig> 
    extends ConfigurableGameBuilder<TState, TConfig> {
  String? _gameTitle;
  String? _gameVersion;
  Map<String, dynamic>? _customSettings;
  
  /// ゲームタイトルを設定
  AdvancedGameBuilder<TState, TConfig> withTitle(String title) {
    _gameTitle = title;
    return this;
  }
  
  /// ゲームバージョンを設定
  AdvancedGameBuilder<TState, TConfig> withVersion(String version) {
    _gameVersion = version;
    return this;
  }
  
  /// カスタム設定を追加
  AdvancedGameBuilder<TState, TConfig> withCustomSettings(
    Map<String, dynamic> settings
  ) {
    _customSettings = settings;
    return this;
  }
  
  /// 高度なゲームインスタンスを構築
  T buildAdvanced<T extends ConfigurableGameBase<TState, TConfig>>(
    T Function({
      GameConfiguration<TState, TConfig>? configuration,
      bool debugMode,
      String? title,
      String? version,
      Map<String, dynamic>? customSettings,
    }) constructor
  ) {
    return constructor(
      configuration: _configuration,
      debugMode: _debugMode,
      title: _gameTitle,
      version: _gameVersion,
      customSettings: _customSettings,
    );
  }
}