import 'package:flutter/foundation.dart';
import 'audio_system.dart';
import 'providers/flame_audio_provider.dart';

/// 簡単なゲーム音声設定ヘルパー
/// 流用時に間違いやすいパス設定を簡素化
class GameAudioHelper {
  /// 標準的なゲーム音声設定を作成（flame_audio公式準拠）
  /// 
  /// assets/audio/ フォルダ直下に音声ファイルを配置することを前提
  /// 
  /// 使用例:
  /// ```dart
  /// final audioConfig = GameAudioHelper.createStandardConfig(
  ///   bgmFiles: {
  ///     'menu_bgm': 'menu.mp3',
  ///     'game_bgm': 'game.mp3',
  ///   },
  ///   sfxFiles: {
  ///     'tap': 'tap.wav',
  ///     'success': 'success.wav',
  ///     'error': 'error.wav',
  ///   },
  /// );
  /// ```
  static DefaultAudioConfiguration createStandardConfig({
    required Map<String, String> bgmFiles,
    required Map<String, String> sfxFiles,
    double masterVolume = 1.0,
    double bgmVolume = 0.7,
    double sfxVolume = 0.8,
    bool bgmEnabled = true,
    bool sfxEnabled = true,
    List<String>? preloadAssets,
    Map<String, bool>? loopSettings,
    bool debugMode = false,
  }) {
    // BGMアセットマップを自動生成（flame_audio公式準拠：ファイル名のみ）
    final bgmAssets = <String, String>{};
    for (final entry in bgmFiles.entries) {
      bgmAssets[entry.key] = entry.value;
    }
    
    // SFXアセットマップを自動生成（flame_audio公式準拠：ファイル名のみ）
    final sfxAssets = <String, String>{};
    for (final entry in sfxFiles.entries) {
      sfxAssets[entry.key] = entry.value;
    }
    
    // デフォルトループ設定（BGMは全てループ、SFXはループなし）
    final defaultLoopSettings = <String, bool>{};
    for (final bgmId in bgmFiles.keys) {
      defaultLoopSettings[bgmId] = true; // BGMは自動的にループ
    }
    for (final sfxId in sfxFiles.keys) {
      defaultLoopSettings[sfxId] = false; // SFXは自動的にループなし
    }
    
    // カスタムループ設定をマージ
    if (loopSettings != null) {
      defaultLoopSettings.addAll(loopSettings);
    }
    
    return DefaultAudioConfiguration(
      bgmAssets: bgmAssets,
      sfxAssets: sfxAssets,
      masterVolume: masterVolume,
      bgmVolume: bgmVolume,
      sfxVolume: sfxVolume,
      bgmEnabled: bgmEnabled,
      sfxEnabled: sfxEnabled,
      preloadAssets: preloadAssets ?? [],
      loopSettings: defaultLoopSettings,
      debugMode: debugMode,
    );
  }
  
  /// 簡単なテスト用音声設定を作成
  /// 音声ファイルが存在しない場合でも動作する（SilentAudioProvider使用）
  static DefaultAudioConfiguration createTestConfig({
    bool debugMode = true,
  }) {
    return const DefaultAudioConfiguration(
      bgmAssets: {},
      sfxAssets: {},
      masterVolume: 1.0,
      bgmVolume: 0.7,
      sfxVolume: 0.8,
      bgmEnabled: true,
      sfxEnabled: true,
      preloadAssets: [],
      loopSettings: {},
      debugMode: true,
    );
  }
  
  /// ゲーム開発用の実プロバイダーを作成（flame_audio公式準拠）
  /// 本番環境での音声再生用
  static AudioProvider createRealProvider() {
    return FlameAudioProvider();
  }
  
  /// テスト・開発用のサイレントプロバイダーを作成
  /// 音声ファイルなしでの開発・テスト用
  static AudioProvider createSilentProvider() {
    return SilentAudioProvider();
  }
  
  /// pubspec.yamlに追加すべきアセット設定を生成
  /// 
  /// 使用例:
  /// ```dart
  /// final assetConfig = GameAudioHelper.generateAssetConfig();
  /// print(assetConfig); // pubspec.yamlにコピペ可能な形式で出力
  /// ```
  static String generateAssetConfig() {
    return '''
  assets:
    - assets/audio/bgm/
    - assets/audio/sfx/''';
  }
  
  /// 必要なディレクトリ構造のガイド
  static String getDirectoryStructureGuide() {
    return '''
プロジェクト推奨ディレクトリ構造:

your_project/
├── assets/
│   └── audio/
│       ├── bgm/          # BGMファイル(.mp3, .ogg等)
│       │   ├── menu.mp3
│       │   └── game.mp3
│       └── sfx/          # 効果音ファイル(.wav, .mp3等)
│           ├── tap.wav
│           ├── success.wav
│           └── error.wav
├── lib/
│   └── main.dart
└── pubspec.yaml

pubspec.yamlの設定:
${generateAssetConfig()}
''';
  }
}

/// ゲーム音声の簡単な統合ヘルパー
/// ConfigurableGameでの使用を簡素化
class GameAudioIntegration {
  /// 簡単な音声統合の設定例
  /// 
  /// ConfigurableGameの継承クラスで使用:
  /// ```dart
  /// class MyGame extends ConfigurableGame<GameState, MyConfig> {
  ///   @override
  ///   Future<void> initializeGame() async {
  ///     await GameAudioIntegration.setupAudio(
  ///       audioManager: audioManager,
  ///       bgmFiles: {'menu': 'menu.mp3'},
  ///       sfxFiles: {'tap': 'tap.wav'},
  ///     );
  ///   }
  /// }
  /// ```
  static Future<void> setupAudio({
    required AudioManager audioManager,
    required Map<String, String> bgmFiles,
    required Map<String, String> sfxFiles,
    double masterVolume = 1.0,
    double bgmVolume = 0.7,
    double sfxVolume = 0.8,
    bool debugMode = false,
  }) async {
    final config = GameAudioHelper.createStandardConfig(
      bgmFiles: bgmFiles,
      sfxFiles: sfxFiles,
      masterVolume: masterVolume,
      bgmVolume: bgmVolume,
      sfxVolume: sfxVolume,
      debugMode: debugMode,
    );
    
    await audioManager.updateConfiguration(config);
    
    if (debugMode) {
      debugPrint('🎵 GameAudioIntegration: Audio setup completed');
      debugPrint('  BGM files: ${bgmFiles.keys.join(', ')}');
      debugPrint('  SFX files: ${sfxFiles.keys.join(', ')}');
    }
  }
  
  /// よくあるゲーム音声パターンのプリセット
  static Map<String, String> getCommonBgmPreset() {
    return {
      'menu_bgm': 'menu.mp3',
      'game_bgm': 'game.mp3',
      'victory_bgm': 'victory.mp3',
    };
  }
  
  static Map<String, String> getCommonSfxPreset() {
    return {
      'tap': 'tap.wav',
      'success': 'success.wav',
      'error': 'error.wav',
      'button_click': 'button.wav',
      'coin': 'coin.wav',
      'powerup': 'powerup.wav',
    };
  }
}