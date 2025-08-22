import 'package:flutter/foundation.dart';

/// 音響設定の基底クラス
abstract class AudioConfiguration {
  /// BGM設定
  Map<String, String> get bgmAssets;

  /// 効果音設定
  Map<String, String> get sfxAssets;

  /// マスター音量 (0.0 - 1.0)
  double get masterVolume;

  /// BGM音量 (0.0 - 1.0)
  double get bgmVolume;

  /// 効果音音量 (0.0 - 1.0)
  double get sfxVolume;

  /// BGM有効フラグ
  bool get bgmEnabled;

  /// 効果音有効フラグ
  bool get sfxEnabled;

  /// プリロード対象アセット
  List<String> get preloadAssets;

  /// ループ設定
  Map<String, bool> get loopSettings;

  /// デバッグモード
  bool get debugMode;
}

/// デフォルト音響設定
class DefaultAudioConfiguration implements AudioConfiguration {
  @override
  final Map<String, String> bgmAssets;

  @override
  final Map<String, String> sfxAssets;

  @override
  final double masterVolume;

  @override
  final double bgmVolume;

  @override
  final double sfxVolume;

  @override
  final bool bgmEnabled;

  @override
  final bool sfxEnabled;

  @override
  final List<String> preloadAssets;

  @override
  final Map<String, bool> loopSettings;

  @override
  final bool debugMode;

  const DefaultAudioConfiguration({
    this.bgmAssets = const {},
    this.sfxAssets = const {},
    this.masterVolume = 1.0,
    this.bgmVolume = 0.7,
    this.sfxVolume = 0.8,
    this.bgmEnabled = true,
    this.sfxEnabled = true,
    this.preloadAssets = const [],
    this.loopSettings = const {},
    this.debugMode = false,
  });

  DefaultAudioConfiguration copyWith({
    Map<String, String>? bgmAssets,
    Map<String, String>? sfxAssets,
    double? masterVolume,
    double? bgmVolume,
    double? sfxVolume,
    bool? bgmEnabled,
    bool? sfxEnabled,
    List<String>? preloadAssets,
    Map<String, bool>? loopSettings,
    bool? debugMode,
  }) {
    return DefaultAudioConfiguration(
      bgmAssets: bgmAssets ?? this.bgmAssets,
      sfxAssets: sfxAssets ?? this.sfxAssets,
      masterVolume: masterVolume ?? this.masterVolume,
      bgmVolume: bgmVolume ?? this.bgmVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      bgmEnabled: bgmEnabled ?? this.bgmEnabled,
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
      preloadAssets: preloadAssets ?? this.preloadAssets,
      loopSettings: loopSettings ?? this.loopSettings,
      debugMode: debugMode ?? this.debugMode,
    );
  }
}

/// 音響プロバイダーの抽象インターフェース
abstract class AudioProvider {
  /// 初期化
  Future<void> initialize(AudioConfiguration config);

  /// BGM再生
  Future<void> playBgm(String assetId, {bool loop = true});

  /// BGM停止
  Future<void> stopBgm();

  /// BGM一時停止
  Future<void> pauseBgm();

  /// BGM再開
  Future<void> resumeBgm();

  /// BGM音量設定
  Future<void> setBgmVolume(double volume);

  /// 効果音再生
  Future<void> playSfx(String assetId, {double volume = 1.0});

  /// 効果音停止
  Future<void> stopSfx(String assetId);

  /// 全効果音停止
  Future<void> stopAllSfx();

  /// 効果音音量設定
  Future<void> setSfxVolume(double volume);

  /// マスター音量設定
  Future<void> setMasterVolume(double volume);

  /// BGM有効/無効切り替え
  void setBgmEnabled(bool enabled);

  /// 効果音有効/無効切り替え
  void setSfxEnabled(bool enabled);

  /// 現在のBGM再生状態
  bool get isBgmPlaying;

  /// 現在のBGM一時停止状態
  bool get isBgmPaused;

  /// リソース解放
  Future<void> dispose();
}

/// サイレント音響プロバイダー（テスト・デバッグ用）
class SilentAudioProvider implements AudioProvider {
  bool _bgmPlaying = false;
  bool _bgmPaused = false;
  String? _currentBgm;

  /// 現在再生中のBGMを取得
  String? get currentBgm => _currentBgm;

  @override
  Future<void> initialize(AudioConfiguration config) async {
    debugPrint('SilentAudioProvider initialized');
  }

  @override
  Future<void> playBgm(String assetId, {bool loop = true}) async {
    _currentBgm = assetId;
    _bgmPlaying = true;
    _bgmPaused = false;
    debugPrint('Silent BGM play: $assetId (loop: $loop)');
  }

  @override
  Future<void> stopBgm() async {
    _bgmPlaying = false;
    _bgmPaused = false;
    _currentBgm = null;
    debugPrint('Silent BGM stop');
  }

  @override
  Future<void> pauseBgm() async {
    _bgmPaused = true;
    debugPrint('Silent BGM pause');
  }

  @override
  Future<void> resumeBgm() async {
    _bgmPaused = false;
    debugPrint('Silent BGM resume');
  }

  @override
  Future<void> setBgmVolume(double volume) async {
    debugPrint('Silent BGM volume: $volume');
  }

  @override
  Future<void> playSfx(String assetId, {double volume = 1.0}) async {
    debugPrint('Silent SFX play: $assetId (volume: $volume)');
  }

  @override
  Future<void> stopSfx(String assetId) async {
    debugPrint('Silent SFX stop: $assetId');
  }

  @override
  Future<void> stopAllSfx() async {
    debugPrint('Silent SFX stop all');
  }

  @override
  Future<void> setSfxVolume(double volume) async {
    debugPrint('Silent SFX volume: $volume');
  }

  @override
  Future<void> setMasterVolume(double volume) async {
    debugPrint('Silent master volume: $volume');
  }

  @override
  void setBgmEnabled(bool enabled) {
    debugPrint('Silent BGM enabled: $enabled');
  }

  @override
  void setSfxEnabled(bool enabled) {
    debugPrint('Silent SFX enabled: $enabled');
  }

  @override
  bool get isBgmPlaying => _bgmPlaying;

  @override
  bool get isBgmPaused => _bgmPaused;

  @override
  Future<void> dispose() async {
    debugPrint('SilentAudioProvider disposed');
  }
}

/// 音響マネージャー
class AudioManager {
  AudioProvider _provider;
  AudioConfiguration _configuration;

  AudioManager({
    required AudioProvider provider,
    required AudioConfiguration configuration,
  }) : _provider = provider,
       _configuration = configuration;

  /// 現在のプロバイダー
  AudioProvider get provider => _provider;

  /// 現在の設定
  AudioConfiguration get configuration => _configuration;

  /// 初期化
  Future<void> initialize() async {
    await _provider.initialize(_configuration);
  }

  /// プロバイダー変更
  Future<void> setProvider(AudioProvider newProvider) async {
    await _provider.dispose();
    _provider = newProvider;
    await _provider.initialize(_configuration);
  }

  /// 設定更新
  Future<void> updateConfiguration(AudioConfiguration newConfiguration) async {
    debugPrint('🎵 AudioManager.updateConfiguration() called');
    debugPrint('🎵 New config SFX assets: ${newConfiguration.sfxAssets}');
    _configuration = newConfiguration;
    await _provider.initialize(_configuration);
    debugPrint('🎵 Provider initialized with new configuration');
  }

  /// BGM再生
  Future<void> playBgm(String bgmId) async {
    if (!_configuration.bgmEnabled) return;

    // BGMアセットの存在確認（AudioPlayersProviderが実際のパス解決を行う）
    if (!_configuration.bgmAssets.containsKey(bgmId)) {
      debugPrint('BGM asset not found: $bgmId');
      return;
    }

    final loop = _configuration.loopSettings[bgmId] ?? true;
    await _provider.playBgm(bgmId, loop: loop);
  }

  /// 効果音再生
  Future<void> playSfx(String sfxId, {double volumeMultiplier = 1.0}) async {
    debugPrint('🎵 AudioManager.playSfx() called for: $sfxId');
    debugPrint('🎵 SFX enabled: ${_configuration.sfxEnabled}');
    debugPrint(
      '🎵 Available SFX assets: ${_configuration.sfxAssets.keys.join(", ")}',
    );
    debugPrint('🎵 Looking for asset: $sfxId');

    if (!_configuration.sfxEnabled) {
      debugPrint('🎵 SFX disabled, skipping: $sfxId');
      return;
    }

    // SFXアセットの存在確認（AudioPlayersProviderが実際のパス解決を行う）
    if (!_configuration.sfxAssets.containsKey(sfxId)) {
      debugPrint('SFX asset not found: $sfxId');
      debugPrint('🎵 Available assets: ${_configuration.sfxAssets}');
      return;
    }

    debugPrint('🎵 SFX asset found, playing: $sfxId');
    final volume = _configuration.sfxVolume * volumeMultiplier;
    await _provider.playSfx(sfxId, volume: volume);
  }

  /// BGM停止
  Future<void> stopBgm() async {
    await _provider.stopBgm();
  }

  /// BGM一時停止
  Future<void> pauseBgm() async {
    await _provider.pauseBgm();
  }

  /// BGM再開
  Future<void> resumeBgm() async {
    await _provider.resumeBgm();
  }

  /// 全効果音停止
  Future<void> stopAllSfx() async {
    await _provider.stopAllSfx();
  }

  /// BGM有効/無効切り替え
  void setBgmEnabled(bool enabled) {
    _provider.setBgmEnabled(enabled);
    if (!enabled) {
      _provider.stopBgm();
    }
  }

  /// 効果音有効/無効切り替え
  void setSfxEnabled(bool enabled) {
    _provider.setSfxEnabled(enabled);
    if (!enabled) {
      _provider.stopAllSfx();
    }
  }

  /// 音量調整
  Future<void> setVolumes({
    double? masterVolume,
    double? bgmVolume,
    double? sfxVolume,
  }) async {
    if (masterVolume != null) {
      await _provider.setMasterVolume(masterVolume);
    }
    if (bgmVolume != null) {
      await _provider.setBgmVolume(bgmVolume);
    }
    if (sfxVolume != null) {
      await _provider.setSfxVolume(sfxVolume);
    }
  }

  /// BGM再生状態
  bool get isBgmPlaying => _provider.isBgmPlaying;

  /// BGM一時停止状態
  bool get isBgmPaused => _provider.isBgmPaused;

  /// デバッグ情報
  Map<String, dynamic> getDebugInfo() {
    return {
      'provider': _provider.runtimeType.toString(),
      'bgm_playing': _provider.isBgmPlaying,
      'bgm_paused': _provider.isBgmPaused,
      'bgm_enabled': _configuration.bgmEnabled,
      'sfx_enabled': _configuration.sfxEnabled,
      'master_volume': _configuration.masterVolume,
      'bgm_volume': _configuration.bgmVolume,
      'sfx_volume': _configuration.sfxVolume,
      'bgm_assets_count': _configuration.bgmAssets.length,
      'sfx_assets_count': _configuration.sfxAssets.length,
    };
  }

  /// リソース解放
  Future<void> dispose() async {
    await _provider.dispose();
  }
}
