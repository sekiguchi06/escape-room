import 'package:flutter/foundation.dart';
import 'package:flame_audio/flame_audio.dart';
import '../audio_system.dart';

/// flame_audioパッケージを使用したAudioProviderの公式実装
/// 公式ドキュメント: https://pub.dev/packages/flame_audio
class FlameAudioProvider implements AudioProvider {
  AudioConfiguration? _config;
  String? _currentBgmAssetId;
  bool _bgmEnabled = true;
  bool _sfxEnabled = true;

  // 音量設定
  double _masterVolume = 1.0;
  double _bgmVolume = 0.7;
  double _sfxVolume = 0.8;

  // AudioPoolマップ（高頻度SFX用）
  final Map<String, AudioPool> _audioPools = {};

  @override
  Future<void> initialize(AudioConfiguration config) async {
    debugPrint('🎵 FlameAudioProvider.initialize() called');
    _config = config;
    _masterVolume = config.masterVolume;
    _bgmVolume = config.bgmVolume;
    _sfxVolume = config.sfxVolume;
    _bgmEnabled = config.bgmEnabled;
    _sfxEnabled = config.sfxEnabled;

    debugPrint('🎵 Config loaded - SFX enabled: $_sfxEnabled');
    debugPrint('🎵 SFX assets: ${config.sfxAssets}');

    // FlameAudio.bgm.initialize() - app.dartで一元管理済み（重複削除）
    debugPrint('🎵 BGM initialization skipped - handled by app.dart');

    // プリロード処理（公式のaudioCache使用）
    await _preloadAssets();

    if (config.debugMode) {
      debugPrint('FlameAudioProvider initialized');
      debugPrint('  - BGM enabled: $_bgmEnabled');
      debugPrint('  - SFX enabled: $_sfxEnabled');
      debugPrint('  - Master volume: $_masterVolume');
      debugPrint('  - BGM volume: $_bgmVolume');
      debugPrint('  - SFX volume: $_sfxVolume');
    }
  }

  Future<void> _preloadAssets() async {
    if (_config?.preloadAssets.isEmpty ?? true) return;

    try {
      // 公式プリロード機能使用
      final assetsToLoad = <String>[];

      for (final assetId in _config!.preloadAssets) {
        // プリロード時も_resolveAssetPathを使用して一貫性を保つ
        final assetPath = _resolveAssetPath(assetId, isBgm: false);
        assetsToLoad.add(assetPath);

        if (_config!.debugMode) {
          debugPrint('Preloading audio asset: $assetId -> $assetPath');
        }
      }

      // 公式のloadAllメソッド使用
      await FlameAudio.audioCache.loadAll(assetsToLoad);
    } catch (e) {
      debugPrint('Audio preload failed: $e');
    }
  }

  @override
  Future<void> playBgm(String assetId, {bool loop = true}) async {
    if (!_bgmEnabled) return;

    try {
      // 現在のBGMが同じ場合はスキップ
      if (_currentBgmAssetId == assetId && isBgmPlaying) {
        return;
      }

      // 現在のBGMを停止
      await stopBgm();

      _currentBgmAssetId = assetId;

      // アセットパス解決
      final assetPath = _resolveAssetPath(assetId, isBgm: true);

      // 公式BGM API使用
      await FlameAudio.bgm.play(assetPath, volume: _bgmVolume * _masterVolume);

      if (_config?.debugMode == true) {
        debugPrint(
          'BGM playing: $assetId (volume: ${_bgmVolume * _masterVolume})',
        );
      }
    } catch (e) {
      debugPrint('BGM play failed: $e');
      _currentBgmAssetId = null;
    }
  }

  @override
  Future<void> stopBgm() async {
    try {
      await FlameAudio.bgm.stop();
      _currentBgmAssetId = null;

      if (_config?.debugMode == true) {
        debugPrint('BGM stopped');
      }
    } catch (e) {
      debugPrint('BGM stop failed: $e');
    }
  }

  @override
  Future<void> pauseBgm() async {
    try {
      await FlameAudio.bgm.pause();

      if (_config?.debugMode == true) {
        debugPrint('BGM paused');
      }
    } catch (e) {
      debugPrint('BGM pause failed: $e');
    }
  }

  @override
  Future<void> resumeBgm() async {
    try {
      await FlameAudio.bgm.resume();

      if (_config?.debugMode == true) {
        debugPrint('BGM resumed');
      }
    } catch (e) {
      debugPrint('BGM resume failed: $e');
    }
  }

  @override
  Future<void> setBgmVolume(double volume) async {
    _bgmVolume = volume.clamp(0.0, 1.0);

    if (isBgmPlaying) {
      try {
        // BGM再生中なら再度playで音量更新
        await FlameAudio.bgm.play(
          _resolveAssetPath(_currentBgmAssetId!, isBgm: true),
          volume: _bgmVolume * _masterVolume,
        );

        if (_config?.debugMode == true) {
          debugPrint(
            'BGM volume set: $volume (effective: ${_bgmVolume * _masterVolume})',
          );
        }
      } catch (e) {
        debugPrint('BGM volume setting failed: $e');
      }
    }
  }

  @override
  Future<void> playSfx(String assetId, {double volume = 1.0}) async {
    if (!_sfxEnabled) {
      debugPrint('SFX disabled, skipping: $assetId');
      return;
    }

    try {
      // アセットパス解決
      final assetPath = _resolveAssetPath(assetId, isBgm: false);

      if (_config?.debugMode == true) {
        debugPrint('SFX attempting to play: $assetId -> $assetPath');
        debugPrint(
          'SFX config available: ${_config?.sfxAssets.containsKey(assetId)}',
        );
        debugPrint(
          'SFX all configured assets: ${_config?.sfxAssets.keys.join(", ")}',
        );
      }

      // 音量計算
      final effectiveVolume = (volume * _sfxVolume * _masterVolume).clamp(
        0.0,
        1.0,
      );

      // 公式API使用
      await FlameAudio.play(assetPath, volume: effectiveVolume);

      if (_config?.debugMode == true) {
        debugPrint(
          'SFX successfully playing: $assetId at $assetPath (volume: $effectiveVolume)',
        );
      }
    } catch (e) {
      debugPrint('SFX play failed for $assetId: $e');
      if (_config?.debugMode == true) {
        debugPrint('SFX error details: ${e.runtimeType}');
      }
    }
  }

  @override
  Future<void> stopSfx(String assetId) async {
    // flame_audioはSFXの個別停止をサポートしていない
    if (_config?.debugMode == true) {
      debugPrint('stopSfx not supported in flame_audio');
    }
  }

  @override
  Future<void> stopAllSfx() async {
    try {
      // flame_audioはSFXの一括停止をサポートしていない
      // AudioPoolは個別のインスタンス停止もサポートしていない
      if (_config?.debugMode == true) {
        debugPrint('stopAllSfx not fully supported in flame_audio');
      }
    } catch (e) {
      debugPrint('Stop all SFX failed: $e');
    }
  }

  @override
  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);

    if (_config?.debugMode == true) {
      debugPrint('SFX volume set: $volume');
    }
  }

  @override
  Future<void> setMasterVolume(double volume) async {
    _masterVolume = volume.clamp(0.0, 1.0);

    // BGM音量更新
    if (isBgmPlaying && _currentBgmAssetId != null) {
      try {
        await FlameAudio.bgm.play(
          _resolveAssetPath(_currentBgmAssetId!, isBgm: true),
          volume: _bgmVolume * _masterVolume,
        );
      } catch (e) {
        debugPrint('BGM master volume update failed: $e');
      }
    }

    if (_config?.debugMode == true) {
      debugPrint('Master volume set: $volume');
    }
  }

  @override
  void setBgmEnabled(bool enabled) {
    _bgmEnabled = enabled;

    if (!enabled && isBgmPlaying) {
      stopBgm();
    }

    if (_config?.debugMode == true) {
      debugPrint('BGM enabled: $enabled');
    }
  }

  @override
  void setSfxEnabled(bool enabled) {
    _sfxEnabled = enabled;

    if (!enabled) {
      stopAllSfx();
    }

    if (_config?.debugMode == true) {
      debugPrint('SFX enabled: $enabled');
    }
  }

  @override
  bool get isBgmPlaying {
    return FlameAudio.bgm.isPlaying;
  }

  @override
  bool get isBgmPaused {
    // flame_audioは直接的なpause状態取得をサポートしていない
    return false;
  }

  /// アセットパスを解決（flame_audio公式準拠：assets/audio/直下に配置）
  String _resolveAssetPath(String assetId, {required bool isBgm}) {
    String fileName;

    // 設定からファイル名を取得
    if (isBgm && _config?.bgmAssets.containsKey(assetId) == true) {
      fileName = _config!.bgmAssets[assetId]!;
    } else if (!isBgm && _config?.sfxAssets.containsKey(assetId) == true) {
      fileName = _config!.sfxAssets[assetId]!;
    } else {
      // デフォルト: assetIdをファイル名として使用
      fileName = assetId;
    }

    if (_config?.debugMode == true) {
      debugPrint('FlameAudio path resolution: $assetId -> $fileName');
    }

    // flame_audio公式準拠の実験：audio/プレフィックスなしでテスト
    // FlameAudioが内部でassets/audio/を自動付加する可能性
    String resolvedPath;

    if (fileName.contains('/')) {
      resolvedPath = fileName;
    } else {
      // 単純なファイル名の場合、FlameAudioに直接渡してテスト
      resolvedPath = fileName;
    }

    if (_config?.debugMode == true) {
      debugPrint('FlameAudio resolved path: $resolvedPath');
    }

    return resolvedPath;
  }

  /// 高頻度効果音用のAudioPool作成
  Future<void> createAudioPool(String assetId, {int maxPlayers = 4}) async {
    if (_audioPools.containsKey(assetId)) return;

    try {
      final assetPath = _resolveAssetPath(assetId, isBgm: false);
      final pool = await FlameAudio.createPool(
        assetPath,
        maxPlayers: maxPlayers,
      );
      _audioPools[assetId] = pool;

      if (_config?.debugMode == true) {
        debugPrint('AudioPool created for: $assetId (maxPlayers: $maxPlayers)');
      }
    } catch (e) {
      debugPrint('AudioPool creation failed: $e');
    }
  }

  @override
  Future<void> dispose() async {
    try {
      // BGM停止
      await FlameAudio.bgm.stop();

      // AudioPool解放
      // flame_audioのAudioPoolにはdisposeメソッドがない
      _audioPools.clear();

      // キャッシュクリア
      FlameAudio.audioCache.clearAll();

      _currentBgmAssetId = null;

      if (_config?.debugMode == true) {
        debugPrint('FlameAudioProvider disposed');
      }
    } catch (e) {
      debugPrint('FlameAudioProvider dispose failed: $e');
    }
  }
}
