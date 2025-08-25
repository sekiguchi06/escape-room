import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flame_audio/flame_audio.dart';

/// ゲーム内音量管理システム
class VolumeManager extends ChangeNotifier {
  static final VolumeManager _instance = VolumeManager._internal();
  factory VolumeManager() => _instance;
  VolumeManager._internal();

  // 音量設定 (0.0 ~ 1.0)
  double _bgmVolume = 0.5; // デフォルト50%
  double _sfxVolume = 0.5; // デフォルト50%
  bool _isMuted = false;
  bool _isInitialized = false;

  // AudioPlayer instances
  AudioPlayer? _bgmPlayer;
  final List<AudioPlayer> _sfxPlayers = [];

  // Getters
  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;
  bool get isMuted => _isMuted;
  bool get isInitialized => _isInitialized;

  // 実際の音量計算（ミュート考慮）
  double get effectiveBgmVolume => _isMuted ? 0.0 : _bgmVolume;
  double get effectiveSfxVolume => _isMuted ? 0.0 : _sfxVolume;

  /// 初期化処理
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadSettings();
      _isInitialized = true;
      debugPrint(
        '🔊 VolumeManager initialized - BGM: ${(_bgmVolume * 100).round()}%, SFX: ${(_sfxVolume * 100).round()}%',
      );
    } catch (e) {
      debugPrint('❌ VolumeManager initialization failed: $e');
    }
  }

  /// 設定の読み込み
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _bgmVolume = prefs.getDouble('bgm_volume') ?? 0.5; // デフォルト50%
      _sfxVolume = prefs.getDouble('sfx_volume') ?? 0.5; // デフォルト50%
      _isMuted = prefs.getBool('is_muted') ?? false;

      // 範囲チェック
      _bgmVolume = _bgmVolume.clamp(0.0, 1.0);
      _sfxVolume = _sfxVolume.clamp(0.0, 1.0);

      debugPrint('📂 Volume settings loaded from storage');
    } catch (e) {
      debugPrint('⚠️ Failed to load volume settings: $e');
      // デフォルト値を使用
      _bgmVolume = 0.5; // デフォルト50%
      _sfxVolume = 0.5; // デフォルト50%
      _isMuted = false;
    }
  }

  /// 設定の保存
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('bgm_volume', _bgmVolume);
      await prefs.setDouble('sfx_volume', _sfxVolume);
      await prefs.setBool('is_muted', _isMuted);
      debugPrint('💾 Volume settings saved to storage');
    } catch (e) {
      debugPrint('❌ Failed to save volume settings: $e');
    }
  }

  /// BGM音量設定
  Future<void> setBgmVolume(double volume) async {
    _bgmVolume = volume.clamp(0.0, 1.0);
    await _updateBgmVolume();
    await _saveSettings();
    notifyListeners();
    debugPrint('🎵 BGM volume set to ${(_bgmVolume * 100).round()}%');
  }

  /// 効果音音量設定
  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    await _saveSettings();
    notifyListeners();
    debugPrint('🔔 SFX volume set to ${(_sfxVolume * 100).round()}%');
  }

  /// ミュート切り替え
  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    await _updateBgmVolume();
    await _saveSettings();
    notifyListeners();
    debugPrint('🔇 Audio ${_isMuted ? 'muted' : 'unmuted'}');
  }

  /// BGMの再生開始
  Future<void> playBgm(String audioPath, {bool loop = true}) async {
    try {
      await stopBgm(); // 既存のBGMを停止

      _bgmPlayer = AudioPlayer();
      await _bgmPlayer!.setVolume(effectiveBgmVolume);
      await _bgmPlayer!.setReleaseMode(
        loop ? ReleaseMode.loop : ReleaseMode.release,
      );
      await _bgmPlayer!.play(AssetSource(audioPath));

      debugPrint(
        '🎵 BGM started: $audioPath (volume: ${(effectiveBgmVolume * 100).round()}%)',
      );
    } catch (e) {
      debugPrint('❌ Failed to play BGM: $e');
    }
  }

  /// BGMの停止
  Future<void> stopBgm() async {
    try {
      if (_bgmPlayer != null) {
        await _bgmPlayer!.stop();
        await _bgmPlayer!.dispose();
        _bgmPlayer = null;
        debugPrint('⏹️ BGM stopped');
      }
    } catch (e) {
      debugPrint('❌ Failed to stop BGM: $e');
    }
  }

  /// BGMの一時停止
  Future<void> pauseBgm() async {
    try {
      if (_bgmPlayer != null) {
        await _bgmPlayer!.pause();
        debugPrint('⏸️ BGM paused');
      }
    } catch (e) {
      debugPrint('❌ Failed to pause BGM: $e');
    }
  }

  /// BGMの再開
  Future<void> resumeBgm() async {
    try {
      if (_bgmPlayer != null) {
        await _bgmPlayer!.resume();
        debugPrint('▶️ BGM resumed');
      }
    } catch (e) {
      debugPrint('❌ Failed to resume BGM: $e');
    }
  }

  /// 効果音の再生
  Future<void> playSfx(String audioPath) async {
    try {
      // Flame Audioを使用して効果音を再生
      await FlameAudio.play(audioPath, volume: effectiveSfxVolume);
      debugPrint(
        '🔔 SFX played: $audioPath (volume: ${(effectiveSfxVolume * 100).round()}%)',
      );
    } catch (e) {
      debugPrint('❌ Failed to play SFX: $e');
    }
  }

  /// 効果音の再生（AudioPlayerを使用、より詳細な制御が必要な場合）
  Future<void> playSfxWithPlayer(String audioPath) async {
    try {
      final player = AudioPlayer();
      await player.setVolume(effectiveSfxVolume);
      await player.play(AssetSource(audioPath));

      // 再生完了後にプレイヤーを破棄
      player.onPlayerComplete.listen((_) {
        player.dispose();
        _sfxPlayers.remove(player);
      });

      _sfxPlayers.add(player);
      debugPrint('🔔 SFX played with player: $audioPath');
    } catch (e) {
      debugPrint('❌ Failed to play SFX with player: $e');
    }
  }

  /// ゲーム固有の効果音
  Future<void> playGameSfx(GameSfxType type) async {
    String audioPath;

    switch (type) {
      case GameSfxType.buttonTap:
        audioPath = 'decision_button.mp3';  // 暫定的にdecision_button.mp3を使用
        break;
      case GameSfxType.itemFound:
        audioPath = 'decision_button.mp3';  // 暫定的にdecision_button.mp3を使用
        break;
      case GameSfxType.puzzleSolved:
        audioPath = 'decision_button.mp3';  // 暫定的にdecision_button.mp3を使用
        break;
      case GameSfxType.error:
        audioPath = 'decision_button.mp3';  // 暫定的にdecision_button.mp3を使用
        break;
      case GameSfxType.success:
        audioPath = 'decision_button.mp3';  // 暫定的にdecision_button.mp3を使用
        break;
      case GameSfxType.doorOpen:
        audioPath = 'decision_button.mp3';  // 暫定的にdecision_button.mp3を使用
        break;
      case GameSfxType.escape:
        audioPath = 'decision_button.mp3';  // 暫定的にdecision_button.mp3を使用
        break;
    }

    await playSfx(audioPath);
  }

  /// BGM音量の更新（内部使用）
  Future<void> _updateBgmVolume() async {
    if (_bgmPlayer != null) {
      try {
        await _bgmPlayer!.setVolume(effectiveBgmVolume);
      } catch (e) {
        debugPrint('❌ Failed to update BGM volume: $e');
      }
    }
  }

  /// 全ての音声を停止
  Future<void> stopAllAudio() async {
    await stopBgm();

    // 全ての効果音プレイヤーを停止
    for (final player in _sfxPlayers) {
      try {
        await player.stop();
        await player.dispose();
      } catch (e) {
        debugPrint('⚠️ Failed to stop SFX player: $e');
      }
    }
    _sfxPlayers.clear();

    debugPrint('🔇 All audio stopped');
  }

  /// リソースの解放
  @override
  Future<void> dispose() async {
    await stopAllAudio();
    _isInitialized = false;
    super.dispose();
  }

  /// 音量設定のリセット
  Future<void> resetToDefaults() async {
    _bgmVolume = 0.5; // デフォルト50%
    _sfxVolume = 0.5; // デフォルト50%
    _isMuted = false;

    await _updateBgmVolume();
    await _saveSettings();
    notifyListeners();

    debugPrint('🔄 Volume settings reset to defaults');
  }

  /// 現在の設定をログ出力
  void logCurrentSettings() {
    debugPrint('🔊 Current Volume Settings:');
    debugPrint('   BGM: ${(_bgmVolume * 100).round()}%');
    debugPrint('   SFX: ${(_sfxVolume * 100).round()}%');
    debugPrint('   Muted: $_isMuted');
    debugPrint('   Effective BGM: ${(effectiveBgmVolume * 100).round()}%');
    debugPrint('   Effective SFX: ${(effectiveSfxVolume * 100).round()}%');
  }
}

/// ゲーム効果音の種類
enum GameSfxType {
  buttonTap, // ボタンタップ音
  itemFound, // アイテム発見音
  puzzleSolved, // パズル解決音
  error, // エラー音
  success, // 成功音
  doorOpen, // ドア開放音
  escape, // 脱出成功音
}
