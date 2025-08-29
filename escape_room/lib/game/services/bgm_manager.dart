import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flame_audio/flame_audio.dart';
import '../../framework/escape_room/core/room_types.dart';
import '../../framework/audio/audio_service.dart';
import '../../framework/audio/bgm_switcher.dart';

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

  /// BGM停止（統一AudioService使用）
  Future<void> _forceStopCurrentBgm() async {
    try {
      debugPrint('🔇 BGM停止開始');
      await AudioService().stopBGM();
      _isBgmPlaying = false;
      debugPrint('✅ BGM停止完了');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ BGM停止エラー: $e');
      _isBgmPlaying = false;
      notifyListeners();
    }
  }


  /// 現在の階層に応じてBGMを更新（統一システム使用）
  Future<void> _updateBgmForCurrentFloor() async {
    debugPrint('🎵 BGM更新開始: 階層=${_floorName(_currentFloor)}');
    
    try {
      String bgmFile;
      switch (_currentFloor) {
        case FloorType.floor1:
          bgmFile = AudioAssets.moonlight;        // スタート・1階BGM
          break;
        case FloorType.underground:
          bgmFile = AudioAssets.swimmingFishDream;  // 地下BGM
          break;
        case null:
        default:
          bgmFile = AudioAssets.mistyDream;        // デフォルト・メインゲームBGM
          break;
      }
      
      debugPrint('🎵 統一BGMサービスで再生開始: $bgmFile');
      await AudioService().playBGM(bgmFile, volume: 0.5);
      _isBgmPlaying = true;
      debugPrint('✅ 統一BGM再生成功: $bgmFile');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ 統一BGM再生失敗: $e');
      _isBgmPlaying = false;
      notifyListeners();
    }
  }

  /// フェードアウト付きBGM切り替え（統一システム使用）
  Future<void> switchBgmWithFadeOut(FloorType newFloor) async {
    if (_currentFloor == newFloor) {
      debugPrint('🎵 同じ階層のためBGM切り替えスキップ');
      return;
    }

    debugPrint('🎵 統一BGM切り替えサービスでフェード開始');
    
    try {
      // BGMタイプを決定
      RoomBGMType roomType;
      switch (newFloor) {
        case FloorType.floor1:
          roomType = RoomBGMType.mainFloor;
          break;
        case FloorType.underground:
          roomType = RoomBGMType.underground;
          break;
        default:
          roomType = RoomBGMType.mainFloor;
          break;
      }
      
      // 統一BGM切り替え関数を使用（1.0秒フェードアウト）
      await BGMSwitcher.switchToRoomBGM(
        roomType,
        fadeOutDuration: const Duration(milliseconds: 1000),
      );
      
      _currentFloor = newFloor;
      _isBgmPlaying = true;
      debugPrint('✅ 統一BGM切り替え完了: ${_floorName(newFloor)}');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ 統一BGM切り替え失敗: $e');
      _isBgmPlaying = false;
      notifyListeners();
    }
  }

  /// 安全なBGM停止（統一システム使用）
  Future<void> stopCurrentBgmSafely() async {
    if (!_isBgmPlaying) {
      debugPrint('🔇 BGM停止済みのためスキップ');
      return;
    }
    
    try {
      debugPrint('🔇 統一BGMサービスで安全停止開始');
      await AudioService().stopBGM();
      _isBgmPlaying = false;
      debugPrint('✅ 統一BGM安全停止完了');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ 統一BGM安全停止エラー: $e');
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