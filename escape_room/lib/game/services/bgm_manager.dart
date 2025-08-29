import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flame_audio/flame_audio.dart';
import '../../framework/escape_room/core/room_types.dart';

/// BGM管理サービスクラス
/// Flutter公式ベストプラクティスに従った設計
class BgmManager extends ChangeNotifier {
  // シングルトンパターンの実装
  static final BgmManager _instance = BgmManager._internal();
  factory BgmManager() => _instance;
  BgmManager._internal();

  FloorType? _currentFloor;
  bool _isBgmPlaying = false;

  bool get isBgmPlaying => _isBgmPlaying;
  FloorType? get currentFloor => _currentFloor;

  /// BGMシステムの初期化
  Future<void> initialize() async {
    debugPrint('🎵 BGM管理システム初期化開始');
    
    try {
      // FlameAudio初期化テスト
      await _testFlameAudio();
      debugPrint('✅ BGM管理システム初期化完了');
    } catch (e) {
      debugPrint('❌ BGM管理システム初期化失敗: $e');
    }
  }

  /// FlameAudio動作テスト
  Future<void> _testFlameAudio() async {
    try {
      debugPrint('🔧 FlameAudio動作テスト開始');
      // 短い効果音で動作確認
      await FlameAudio.play('close.mp3', volume: 0.5);
      debugPrint('✅ FlameAudio動作テスト成功');
    } catch (e) {
      debugPrint('❌ FlameAudio動作テスト失敗: $e');
    }
  }

  /// 階層変化時の処理
  void onFloorChanged(FloorType newFloor) {
    if (_currentFloor != newFloor) {
      debugPrint('🎵 階層変化を検出: ${_floorName(_currentFloor)} → ${_floorName(newFloor)}');
      
      // 強制的に現在のBGMを停止
      _forceStopCurrentBgm();
      
      // 階層を更新
      _currentFloor = newFloor;
      
      // 少し待ってから新しいBGMを開始
      Future.delayed(const Duration(milliseconds: 300), () {
        _updateBgmForCurrentFloor();
      });
    }
  }

  /// BGM停止（公式推奨）
  Future<void> _forceStopCurrentBgm() async {
    try {
      debugPrint('🔇 BGM停止開始');
      await FlameAudio.bgm.stop();
      _isBgmPlaying = false;
      debugPrint('✅ BGM停止完了');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ BGM停止エラー: $e');
      _isBgmPlaying = false;
      notifyListeners();
    }
  }

  /// BGMフェードアウト（ベストプラクティス）
  Future<void> _fadeOutCurrentBgm() async {
    if (!_isBgmPlaying) {
      debugPrint('🔇 BGM再生中ではないためフェードアウトスキップ');
      return;
    }
    
    try {
      debugPrint('🔇 BGMフェードアウト開始（1秒間）');
      
      const Duration fadeDuration = Duration(milliseconds: 1000);
      const Duration updateInterval = Duration(milliseconds: 50);
      const double initialVolume = 0.5;
      
      int totalSteps = fadeDuration.inMilliseconds ~/ updateInterval.inMilliseconds;
      int currentStep = 0;
      
      final completer = Completer<void>();
      
      Timer.periodic(updateInterval, (timer) {
        currentStep++;
        double remainingPercent = 1.0 - (currentStep / totalSteps);
        double targetVolume = initialVolume * remainingPercent;
        
        if (targetVolume < 0) targetVolume = 0;
        
        try {
          FlameAudio.bgm.audioPlayer.setVolume(targetVolume);
        } catch (volumeError) {
          debugPrint('⚠️ 音量制御エラー (step $currentStep): $volumeError');
        }
        
        if (currentStep >= totalSteps) {
          timer.cancel();
          completer.complete();
        }
      });
      
      // フェードアウト完了を待機
      await completer.future;
      
      // 最後に停止
      await FlameAudio.bgm.stop();
      debugPrint('✅ フェードアウト停止完了');
    } catch (e) {
      debugPrint('❌ フェードアウト失敗、通常停止に切り替え: $e');
      await FlameAudio.bgm.stop();
    }
  }

  /// 現在の階層に応じてBGMを更新
  Future<void> _updateBgmForCurrentFloor() async {
    debugPrint('🎵 BGM更新開始: 階層=${_floorName(_currentFloor)}');
    
    try {
      String bgmFile;
      switch (_currentFloor) {
        case FloorType.floor1:
          bgmFile = 'moonlight.mp3';
          break;
        case FloorType.underground:
          bgmFile = 'swimming_fish_dream.mp3';
          break;
        case null:
        default:
          bgmFile = 'misty_dream.mp3';
          break;
      }
      
      debugPrint('🎵 BGM再生開始: $bgmFile');
      await FlameAudio.bgm.play(bgmFile, volume: 0.5);
      _isBgmPlaying = true;
      debugPrint('✅ BGM再生成功: $bgmFile');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ BGM再生失敗: $e');
      _isBgmPlaying = false;
      notifyListeners();
    }
  }

  /// フェードアウト付きBGM切り替え
  Future<void> switchBgmWithFadeOut(FloorType newFloor) async {
    if (_currentFloor == newFloor) {
      debugPrint('🎵 同じ階層のためBGM切り替えスキップ');
      return;
    }

    debugPrint('🎵 フェードアウト付きBGM切り替え開始');
    
    if (_isBgmPlaying) {
      await _fadeOutCurrentBgm();
    }
    
    _currentFloor = newFloor;
    await _updateBgmForCurrentFloor();
  }

  /// 安全なBGM停止
  Future<void> stopCurrentBgmSafely() async {
    if (!_isBgmPlaying) {
      debugPrint('🔇 BGM停止済みのためスキップ');
      return;
    }
    
    try {
      debugPrint('🔇 BGM安全停止開始');
      await FlameAudio.bgm.stop();
      _isBgmPlaying = false;
      debugPrint('✅ BGM安全停止完了');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ BGM安全停止エラー: $e');
      _isBgmPlaying = false;
      notifyListeners();
    }
  }

  /// 階層名の表示用文字列を取得
  String _floorName(FloorType? floor) {
    switch (floor) {
      case FloorType.floor1:
        return '1階';
      case FloorType.underground:
        return '地下';
      case null:
        return '未設定';
      default:
        return floor.toString();
    }
  }

  /// リソースの解放
  @override
  void dispose() {
    stopCurrentBgmSafely();
    super.dispose();
  }
}