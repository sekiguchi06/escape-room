import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../audio_system.dart';

/// AudioPlayersパッケージを使用したAudioProviderの実装
class AudioPlayersProvider implements AudioProvider {
  AudioConfiguration? _config;

  // BGM用プレイヤー（1つのBGMのみ同時再生）
  AudioPlayer? _bgmPlayer;
  String? _currentBgmAssetId;
  bool _bgmEnabled = true;
  bool _sfxEnabled = true;

  // 効果音用プレイヤープール
  final List<AudioPlayer> _sfxPlayerPool = [];
  final Map<String, AudioPlayer> _activeSfxPlayers = {};

  // 音量設定
  double _masterVolume = 1.0;
  double _bgmVolume = 0.7;
  double _sfxVolume = 0.8;

  @override
  Future<void> initialize(AudioConfiguration config) async {
    _config = config;
    _masterVolume = config.masterVolume;
    _bgmVolume = config.bgmVolume;
    _sfxVolume = config.sfxVolume;
    _bgmEnabled = config.bgmEnabled;
    _sfxEnabled = config.sfxEnabled;

    // BGM用プレイヤー作成
    _bgmPlayer = AudioPlayer();

    // 効果音用プレイヤープール作成（5個）
    for (int i = 0; i < 5; i++) {
      _sfxPlayerPool.add(AudioPlayer());
    }

    // プリロード処理
    await _preloadAssets();

    if (config.debugMode) {
      debugPrint('AudioPlayersProvider initialized');
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
      for (final assetId in _config!.preloadAssets) {
        // プリロード処理（実際のプリロードはaudioplayersでは制限的）
        if (_config!.debugMode) {
          debugPrint('Preloading audio asset: $assetId');
        }
      }
    } catch (e) {
      debugPrint('Audio preload failed: $e');
    }
  }

  @override
  Future<void> playBgm(String assetId, {bool loop = true}) async {
    if (!_bgmEnabled || _bgmPlayer == null) return;

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

      // ループ設定
      await _bgmPlayer!.setReleaseMode(
        loop ? ReleaseMode.loop : ReleaseMode.stop,
      );

      // 音量設定
      await _bgmPlayer!.setVolume(_bgmVolume * _masterVolume);

      // 再生
      await _bgmPlayer!.play(AssetSource(assetPath));

      if (_config?.debugMode == true) {
        debugPrint(
          'BGM playing: $assetId (loop: $loop, volume: ${_bgmVolume * _masterVolume})',
        );
      }
    } catch (e) {
      debugPrint('BGM play failed: $e');
      _currentBgmAssetId = null;
    }
  }

  @override
  Future<void> stopBgm() async {
    if (_bgmPlayer == null) return;

    try {
      await _bgmPlayer!.stop();
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
    if (_bgmPlayer == null) return;

    try {
      await _bgmPlayer!.pause();

      if (_config?.debugMode == true) {
        debugPrint('BGM paused');
      }
    } catch (e) {
      debugPrint('BGM pause failed: $e');
    }
  }

  @override
  Future<void> resumeBgm() async {
    if (_bgmPlayer == null) return;

    try {
      await _bgmPlayer!.resume();

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

    if (_bgmPlayer != null && isBgmPlaying) {
      try {
        await _bgmPlayer!.setVolume(_bgmVolume * _masterVolume);

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
    if (!_sfxEnabled) return;

    try {
      // 利用可能なプレイヤーを取得
      final player = _getAvailableSfxPlayer();
      if (player == null) {
        if (_config?.debugMode == true) {
          debugPrint('No available SFX player for: $assetId');
        }
        return;
      }

      // アセットパス解決
      final assetPath = _resolveAssetPath(assetId, isBgm: false);

      // 音量設定（引数の音量、SFX音量、マスター音量を掛け合わせ）
      final effectiveVolume = (volume * _sfxVolume * _masterVolume).clamp(
        0.0,
        1.0,
      );
      await player.setVolume(effectiveVolume);

      // 単発再生設定
      await player.setReleaseMode(ReleaseMode.stop);

      // 再生完了時のコールバック設定
      player.onPlayerComplete.listen((_) {
        _releaseSfxPlayer(assetId, player);
      });

      // 再生
      await player.play(AssetSource(assetPath));

      // アクティブプレイヤーに追加
      _activeSfxPlayers[assetId] = player;

      if (_config?.debugMode == true) {
        debugPrint('SFX playing: $assetId (volume: $effectiveVolume)');
      }
    } catch (e) {
      debugPrint('SFX play failed: $e');
    }
  }

  @override
  Future<void> stopSfx(String assetId) async {
    final player = _activeSfxPlayers[assetId];
    if (player == null) return;

    try {
      await player.stop();
      _releaseSfxPlayer(assetId, player);

      if (_config?.debugMode == true) {
        debugPrint('SFX stopped: $assetId');
      }
    } catch (e) {
      debugPrint('SFX stop failed: $e');
    }
  }

  @override
  Future<void> stopAllSfx() async {
    final activePlayerEntries = List.from(_activeSfxPlayers.entries);

    for (final entry in activePlayerEntries) {
      try {
        await entry.value.stop();
        _releaseSfxPlayer(entry.key, entry.value);
      } catch (e) {
        debugPrint('SFX stop failed for ${entry.key}: $e');
      }
    }

    if (_config?.debugMode == true) {
      debugPrint('All SFX stopped');
    }
  }

  @override
  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);

    // 現在再生中の効果音の音量も更新
    for (final player in _activeSfxPlayers.values) {
      try {
        await player.setVolume(_sfxVolume * _masterVolume);
      } catch (e) {
        debugPrint('SFX volume update failed: $e');
      }
    }

    if (_config?.debugMode == true) {
      debugPrint(
        'SFX volume set: $volume (effective: ${_sfxVolume * _masterVolume})',
      );
    }
  }

  @override
  Future<void> setMasterVolume(double volume) async {
    _masterVolume = volume.clamp(0.0, 1.0);

    // BGM音量更新
    if (_bgmPlayer != null && isBgmPlaying) {
      try {
        await _bgmPlayer!.setVolume(_bgmVolume * _masterVolume);
      } catch (e) {
        debugPrint('BGM master volume update failed: $e');
      }
    }

    // SFX音量更新
    for (final player in _activeSfxPlayers.values) {
      try {
        await player.setVolume(_sfxVolume * _masterVolume);
      } catch (e) {
        debugPrint('SFX master volume update failed: $e');
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
    return _bgmPlayer?.state == PlayerState.playing;
  }

  @override
  bool get isBgmPaused {
    return _bgmPlayer?.state == PlayerState.paused;
  }

  /// 利用可能な効果音プレイヤーを取得
  AudioPlayer? _getAvailableSfxPlayer() {
    // プールから利用可能なプレイヤーを探す
    for (final player in _sfxPlayerPool) {
      if (player.state == PlayerState.stopped ||
          player.state == PlayerState.completed) {
        return player;
      }
    }

    // 利用可能なプレイヤーがない場合は新規作成
    if (_sfxPlayerPool.length < 10) {
      // 最大10個まで
      final newPlayer = AudioPlayer();
      _sfxPlayerPool.add(newPlayer);
      return newPlayer;
    }

    return null;
  }

  /// 効果音プレイヤーを解放
  void _releaseSfxPlayer(String assetId, AudioPlayer player) {
    _activeSfxPlayers.remove(assetId);
    // プレイヤーはプールに戻す（dispose不要）
  }

  /// アセットパスを解決
  String _resolveAssetPath(String assetId, {required bool isBgm}) {
    // 設定からパスを取得
    if (isBgm && _config?.bgmAssets.containsKey(assetId) == true) {
      return _config!.bgmAssets[assetId]!;
    }

    if (!isBgm && _config?.sfxAssets.containsKey(assetId) == true) {
      return _config!.sfxAssets[assetId]!;
    }

    // デフォルトパス生成
    if (isBgm) {
      return 'audio/bgm/$assetId';
    } else {
      return 'audio/sfx/$assetId';
    }
  }

  @override
  Future<void> dispose() async {
    // BGMプレイヤー停止・解放
    if (_bgmPlayer != null) {
      try {
        await _bgmPlayer!.stop();
        await _bgmPlayer!.dispose();
      } catch (e) {
        debugPrint('BGM player dispose failed: $e');
      }
      _bgmPlayer = null;
    }

    // 効果音プレイヤー停止・解放
    for (final player in _sfxPlayerPool) {
      try {
        await player.stop();
        await player.dispose();
      } catch (e) {
        debugPrint('SFX player dispose failed: $e');
      }
    }

    _sfxPlayerPool.clear();
    _activeSfxPlayers.clear();
    _currentBgmAssetId = null;

    if (_config?.debugMode == true) {
      debugPrint('AudioPlayersProvider disposed');
    }
  }
}
