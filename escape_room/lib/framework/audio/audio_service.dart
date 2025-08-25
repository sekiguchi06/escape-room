import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// オーディオファイル定数
class AudioAssets {
  static const String decisionButton = 'decision_button.mp3';
  static const String close = 'close.mp3';                         // 閉じる音（新規追加）
  static const String ambientExploration = 'decision_button.mp3';  // 暫定的にdecision_button.mp3を使用
  static const String buttonPress = 'decision_button.mp3';         // 暫定的にdecision_button.mp3を使用
  static const String itemGet = 'decision_button.mp3';             // 暫定的にdecision_button.mp3を使用
  static const String success = 'decision_button.mp3';             // 暫定的にdecision_button.mp3を使用
  static const String error = 'decision_button.mp3';               // 暫定的にdecision_button.mp3を使用
  static const String doorOpen = 'decision_button.mp3';            // 暫定的にdecision_button.mp3を使用
  static const String victoryFanfare = 'decision_button.mp3';      // 暫定的にdecision_button.mp3を使用
}

/// 音響効果カテゴリ
enum AudioCategory {
  ui,      // UI効果音（ボタン、タップ等）
  bgm,     // BGM・環境音
  sfx,     // ゲーム効果音
  voice,   // 音声・ナレーション
}

/// 音響管理サービス（シングルトン）
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _isInitialized = false;
  double _masterVolume = 0.8;
  double _bgmVolume = 0.6;
  double _sfxVolume = 0.8;
  double _uiVolume = 1.0;
  bool _isMuted = false;

  /// 初期化
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // 重要な音響ファイルをプリロード
      await _preloadCriticalAudio();
      _isInitialized = true;
      debugPrint('🎵 AudioService initialized successfully');
    } catch (e) {
      debugPrint('⚠️ AudioService initialization failed: $e');
    }
  }

  /// 重要な音響ファイルのプリロード
  Future<void> _preloadCriticalAudio() async {
    final criticalFiles = [
      AudioAssets.decisionButton,
      AudioAssets.buttonPress,
      AudioAssets.success,
      AudioAssets.error,
    ];

    for (final file in criticalFiles) {
      try {
        await FlameAudio.audioCache.load(file);
        debugPrint('🎵 Preloaded: $file');
      } catch (e) {
        debugPrint('⚠️ Failed to preload: $file - $e');
      }
    }
  }

  /// UI効果音を再生
  Future<void> playUI(String fileName, {double? volume}) async {
    if (!_isInitialized || _isMuted) return;
    
    try {
      final effectiveVolume = (volume ?? _uiVolume) * _masterVolume;
      await FlameAudio.play(fileName, volume: effectiveVolume);
      debugPrint('🎵 UI Audio played: $fileName (volume: ${effectiveVolume.toStringAsFixed(2)})');
    } catch (e) {
      debugPrint('❌ UI Audio failed: $fileName - $e');
    }
  }

  /// BGMを再生
  Future<void> playBGM(String fileName, {double? volume, bool loop = true}) async {
    if (!_isInitialized || _isMuted) return;
    
    try {
      final effectiveVolume = (volume ?? _bgmVolume) * _masterVolume;
      if (loop) {
        await FlameAudio.loopLongAudio(fileName, volume: effectiveVolume);
      } else {
        await FlameAudio.play(fileName, volume: effectiveVolume);
      }
      debugPrint('🎵 BGM played: $fileName (volume: ${effectiveVolume.toStringAsFixed(2)}, loop: $loop)');
    } catch (e) {
      debugPrint('❌ BGM failed: $fileName - $e');
    }
  }

  /// BGMを停止
  Future<void> stopBGM() async {
    try {
      FlameAudio.bgm.stop();
      debugPrint('🎵 BGM stopped');
    } catch (e) {
      debugPrint('❌ BGM stop failed: $e');
    }
  }

  /// 効果音を再生
  Future<void> playSFX(String fileName, {double? volume}) async {
    if (!_isInitialized || _isMuted) return;
    
    try {
      final effectiveVolume = (volume ?? _sfxVolume) * _masterVolume;
      await FlameAudio.play(fileName, volume: effectiveVolume);
      debugPrint('🎵 SFX played: $fileName (volume: ${effectiveVolume.toStringAsFixed(2)})');
    } catch (e) {
      debugPrint('❌ SFX failed: $fileName - $e');
    }
  }

  /// カテゴリ別再生（便利メソッド）
  Future<void> play(String fileName, AudioCategory category, {double? volume}) async {
    switch (category) {
      case AudioCategory.ui:
        await playUI(fileName, volume: volume);
        break;
      case AudioCategory.bgm:
        await playBGM(fileName, volume: volume);
        break;
      case AudioCategory.sfx:
        await playSFX(fileName, volume: volume);
        break;
      case AudioCategory.voice:
        await playSFX(fileName, volume: volume);
        break;
    }
  }

  // ボリューム制御
  void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
    debugPrint('🎵 Master volume set to: ${_masterVolume.toStringAsFixed(2)}');
  }

  void setBGMVolume(double volume) {
    _bgmVolume = volume.clamp(0.0, 1.0);
    debugPrint('🎵 BGM volume set to: ${_bgmVolume.toStringAsFixed(2)}');
  }

  void setSFXVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    debugPrint('🎵 SFX volume set to: ${_sfxVolume.toStringAsFixed(2)}');
  }

  void setUIVolume(double volume) {
    _uiVolume = volume.clamp(0.0, 1.0);
    debugPrint('🎵 UI volume set to: ${_uiVolume.toStringAsFixed(2)}');
  }

  void setMuted(bool muted) {
    _isMuted = muted;
    debugPrint('🎵 Audio ${muted ? 'muted' : 'unmuted'}');
  }

  // ゲッター
  double get masterVolume => _masterVolume;
  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;
  double get uiVolume => _uiVolume;
  bool get isMuted => _isMuted;
  bool get isInitialized => _isInitialized;
}

/// Riverpod プロバイダー
final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});