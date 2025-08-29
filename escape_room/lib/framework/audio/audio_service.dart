import 'dart:async';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// オーディオファイル定数
/// 重要制約: FlameAudioは assets/audio/ プレフィックスを自動付加
/// 参照: AUDIO_SYSTEM_CONSTRAINTS.md
class AudioAssets {
  static const String decisionButton = 'decision_button.mp3';
  static const String close = 'close.mp3';                         // 閉じる音（新規追加）
  static const String walk = 'walk.mp3';                           // 歩く音（新規追加）
  
  // 新しいBGM音声ファイル（assets/audio/ に配置済み）
  static const String mistyDream = 'misty_dream.mp3';              // 1階BGM：霧の中の夢
  static const String moonlight = 'moonlight.mp3';                 // スタート画面BGM：月光
  static const String swimmingFishDream = 'swimming_fish_dream.mp3'; // 地下BGM：夢の中を泳ぐ魚
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
  
  // BGMフェード機能用
  Timer? _fadeTimer;
  bool _isFading = false;
  double _currentBGMVolume = 0.6;
  String? _currentBGMFile;
  String? _pendingBGMFile;

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

  /// BGMを再生（従来互換・即座に切り替え）
  /// 推奨：switchBGMWithFade() を使用してスムーズな切り替えを
  Future<void> playBGM(String fileName, {double? volume, bool loop = true}) async {
    if (!_isInitialized || _isMuted) return;
    
    try {
      // 既存のフェードタイマーをキャンセル
      _fadeTimer?.cancel();
      _fadeTimer = null;
      _isFading = false;
      
      final effectiveVolume = (volume ?? _bgmVolume) * _masterVolume;
      if (loop) {
        await FlameAudio.bgm.play(fileName, volume: effectiveVolume);
      } else {
        await FlameAudio.play(fileName, volume: effectiveVolume);
      }
      
      // 状態管理を更新
      _currentBGMFile = fileName;
      _currentBGMVolume = volume ?? _bgmVolume;
      
      debugPrint('🎵 BGM played: $fileName (volume: ${effectiveVolume.toStringAsFixed(2)}, loop: $loop)');
    } catch (e) {
      debugPrint('❌ BGM failed: $fileName - $e');
      _currentBGMFile = null;
    }
  }

  /// BGMを停止
  Future<void> stopBGM() async {
    try {
      // フェードタイマーをキャンセル
      _fadeTimer?.cancel();
      _fadeTimer = null;
      _isFading = false;
      
      FlameAudio.bgm.stop();
      _currentBGMFile = null;
      _currentBGMVolume = _bgmVolume;
      debugPrint('🎵 BGM stopped');
    } catch (e) {
      debugPrint('❌ BGM stop failed: $e');
    }
  }

  /// 【統一BGM切り替え関数】
  /// 現在のBGMを1.0秒でフェードアウト後、新しいBGMを元音量で再生
  /// 
  /// [newBGMFile] 新しいBGMファイル名（空文字列の場合は停止のみ）
  /// [fadeOutDuration] フェードアウト時間（デフォルト1.0秒）
  /// [targetVolume] 新BGMの目標音量（デフォルトは設定されたBGM音量）
  Future<void> switchBGMWithFade(
    String newBGMFile, {
    Duration fadeOutDuration = const Duration(milliseconds: 1000),
    double? targetVolume,
  }) async {
    if (!_isInitialized || _isMuted) {
      debugPrint('⚠️ AudioService not initialized or muted - BGM switch skipped');
      return;
    }

    // 空文字列の場合は停止のみ
    if (newBGMFile.isEmpty) {
      debugPrint('🎵 Empty BGM file - stopping current BGM');
      await stopBGM();
      return;
    }

    final effectiveTargetVolume = targetVolume ?? _bgmVolume;
    
    // 同じBGMが既に再生中の場合はスキップ
    if (_currentBGMFile == newBGMFile && !_isFading) {
      debugPrint('🎵 Same BGM already playing: $newBGMFile');
      return;
    }

    debugPrint('🎵 Starting BGM switch: ${_currentBGMFile ?? 'none'} → $newBGMFile');

    try {
      // フェード中の場合は既存タイマーをキャンセル
      if (_isFading) {
        _fadeTimer?.cancel();
        _isFading = false;
      }

      // BGMが再生中の場合はフェードアウトしてから切り替え
      if (_currentBGMFile != null) {
        _pendingBGMFile = newBGMFile;
        await _fadeOutCurrentBGM(fadeOutDuration, effectiveTargetVolume);
      } else {
        // BGMが再生されていない場合は直接新しいBGMを再生
        await _playNewBGM(newBGMFile, effectiveTargetVolume);
      }
    } catch (e) {
      debugPrint('❌ BGM switch failed: ${_currentBGMFile ?? 'none'} → $newBGMFile - $e');
      // エラー時は安全に新しいBGMを再生
      await _playNewBGM(newBGMFile, effectiveTargetVolume);
    }
  }

  /// フェードアウト処理（内部用）
  Future<void> _fadeOutCurrentBGM(Duration duration, double nextTargetVolume) async {
    if (_currentBGMFile == null) return;

    _isFading = true;
    const int fadeSteps = 50; // 50ステップでスムーズなフェード
    final int intervalMs = (duration.inMilliseconds / fadeSteps).round();
    final double volumeStep = _currentBGMVolume / fadeSteps;
    
    double currentVolume = _currentBGMVolume;
    int step = 0;

    _fadeTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) async {
      step++;
      currentVolume = (_currentBGMVolume - (volumeStep * step)).clamp(0.0, 1.0);
      
      try {
        // FlameAudioのBGM音量を直接制御（公式推奨方法）
        FlameAudio.bgm.audioPlayer.setVolume(currentVolume * _masterVolume);
        
        // フェードアウト完了
        if (step >= fadeSteps || currentVolume <= 0.0) {
          timer.cancel();
          _fadeTimer = null;
          _isFading = false;
          
          // 現在のBGMを停止
          FlameAudio.bgm.stop();
          debugPrint('🎵 BGM fadeout completed: $_currentBGMFile');
          
          // 新しいBGMを再生
          if (_pendingBGMFile != null) {
            await _playNewBGM(_pendingBGMFile!, nextTargetVolume);
            _pendingBGMFile = null;
          }
        }
      } catch (e) {
        timer.cancel();
        _fadeTimer = null;
        _isFading = false;
        debugPrint('❌ Fade out error at step $step: $e');
        
        // エラー時も新しいBGMを再生
        if (_pendingBGMFile != null) {
          await _playNewBGM(_pendingBGMFile!, nextTargetVolume);
          _pendingBGMFile = null;
        }
      }
    });
  }

  /// 新しいBGMを元音量で再生（内部用）
  Future<void> _playNewBGM(String fileName, double targetVolume) async {
    try {
      final effectiveVolume = targetVolume * _masterVolume;
      await FlameAudio.bgm.play(fileName, volume: effectiveVolume);
      
      _currentBGMFile = fileName;
      _currentBGMVolume = targetVolume;
      
      debugPrint('🎵 New BGM started: $fileName (volume: ${effectiveVolume.toStringAsFixed(2)})');
    } catch (e) {
      debugPrint('❌ New BGM playback failed: $fileName - $e');
      _currentBGMFile = null;
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
  
  // BGM状態ゲッター
  String? get currentBGMFile => _currentBGMFile;
  bool get isFading => _isFading;
  double get currentBGMVolume => _currentBGMVolume;
}

/// Riverpod プロバイダー
final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});