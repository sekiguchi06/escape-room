import 'package:flutter/material.dart';
import '../../escape_room/core/room_types.dart';
import '../../escape_room/core/floor_transition_service.dart';
import '../../../game/components/game_background.dart';
import '../../../gen/assets.gen.dart';
import '../../audio/audio_service.dart';
import 'background_configuration.dart';

/// 多階層対応ナビゲーションシステム
class MultiFloorNavigationSystem extends ChangeNotifier {
  static final MultiFloorNavigationSystem _instance = MultiFloorNavigationSystem._internal();
  factory MultiFloorNavigationSystem() => _instance;
  MultiFloorNavigationSystem._internal();
  
  final FloorTransitionService _floorService = FloorTransitionService();
  
  /// 現在の階層を取得
  FloorType get currentFloor => _floorService.currentFloor;
  
  /// 現在の部屋を取得
  RoomType get currentRoom => _floorService.currentRoom;
  
  /// 地下アクセス状態を取得
  bool get isUndergroundUnlocked => _floorService.isUndergroundUnlocked;
  
  /// 階段解放状態を取得
  bool get areStairsUnlocked => _floorService.areStairsUnlocked;
  
  /// 左に移動可能かチェック
  bool get canMoveLeft => _floorService.canMoveLeft();
  
  /// 右に移動可能かチェック
  bool get canMoveRight => _floorService.canMoveRight();
  
  /// 地下に移動可能かチェック
  bool get canMoveToUnderground => _floorService.canTransitionToUnderground();
  
  /// 1階に移動可能かチェック
  bool get canMoveToFloor1 => _floorService.canTransitionToFloor1();
  
  /// 隠し部屋かどうかをチェック
  bool isCurrentRoomHidden() {
    return currentRoom == RoomType.hiddenA ||
           currentRoom == RoomType.hiddenB ||
           currentRoom == RoomType.hiddenC ||
           currentRoom == RoomType.hiddenD;
  }
  
  /// 隠し部屋から元の部屋に戻れるかチェック
  bool canReturnFromHiddenRoom() {
    return isCurrentRoomHidden();
  }
  
  /// 左の部屋に移動
  void moveLeft() {
    debugPrint('⬅️ 左移動ボタン押下（現在: $currentRoomName）');
    if (canMoveLeft) {
      // 歩く音を再生（重複防止付き）
      AudioService().playUI(AudioAssets.walk, cooldown: const Duration(milliseconds: 500));
      
      _floorService.moveLeft();
      notifyListeners();
    } else {
      debugPrint('❌ 左移動不可（最左端または地下）');
    }
  }
  
  /// 右の部屋に移動
  void moveRight() {
    debugPrint('➡️ 右移動ボタン押下（現在: $currentRoomName）');
    if (canMoveRight) {
      // 歩く音を再生（重複防止付き）
      AudioService().playUI(AudioAssets.walk, cooldown: const Duration(milliseconds: 500));
      
      _floorService.moveRight();
      notifyListeners();
    } else {
      debugPrint('❌ 右移動不可（最右端または地下）');
    }
  }
  
  /// 地下に移動
  Future<void> moveToUnderground() async {
    if (canMoveToUnderground) {
      await _floorService.transitionToFloor(FloorType.underground);
      notifyListeners();
    }
  }

  /// 1階右奥から地下右奥に移動（同一位置での階層移動）
  Future<void> moveToUndergroundFromRightmost() async {
    if (currentRoom == RoomType.rightmost && canMoveToUnderground) {
      // 地下右奥に移動
      await _floorService.transitionToFloor(FloorType.underground);
      _floorService.moveToRoom(RoomType.undergroundRightmost);
      notifyListeners();
    }
  }

  /// 地下右奥から1階右奥に移動（同一位置での階層移動）
  Future<void> moveToFloor1FromUndergroundRightmost() async {
    if (currentRoom == RoomType.undergroundRightmost && canMoveToFloor1) {
      // 1階右奥に移動
      await _floorService.transitionToFloor(FloorType.floor1);
      _floorService.moveToRoom(RoomType.rightmost);
      notifyListeners();
    }
  }
  
  /// 1階に移動
  Future<void> moveToFloor1() async {
    if (canMoveToFloor1) {
      await _floorService.transitionToFloor(FloorType.floor1);
      notifyListeners();
    }
  }
  
  
  /// 隠し部屋から元の部屋に戻る（同一階層内移動）
  void returnFromHiddenRoom() {
    if (!canReturnFromHiddenRoom()) return;
    
    RoomType targetRoom;
    
    // 隠し部屋から対応する通常部屋に戻る
    switch (currentRoom) {
      case RoomType.hiddenA:
        targetRoom = RoomType.left; // 1階左の部屋に戻る
        break;
      case RoomType.hiddenB:
        targetRoom = RoomType.right; // 1階右の部屋に戻る
        break;
      case RoomType.hiddenC:
        targetRoom = RoomType.undergroundLeft; // 地下左の部屋に戻る
        break;
      case RoomType.hiddenD:
        targetRoom = RoomType.undergroundRight; // 地下右の部屋に戻る
        break;
      default:
        return;
    }
    
    // 歩く音を再生（隠し部屋からの下移動、重複防止付き）
    AudioService().playUI(AudioAssets.walk, cooldown: const Duration(milliseconds: 500));
    
    // 同一階層内での部屋移動
    moveToRoom(targetRoom);
  }
  
  /// 地下アクセスを解放
  void unlockUnderground() {
    _floorService.unlockUnderground();
    notifyListeners();
  }
  
  /// main_escape_keyを使用して階段を解放
  void unlockStairsWithKey() {
    _floorService.unlockStairsWithKey();
    notifyListeners();
  }
  
  /// 地下解放条件をチェックして自動解放
  void checkAndUnlockUnderground(List<String> inventoryItems) {
    if (!isUndergroundUnlocked && 
        _floorService.checkUndergroundUnlockCondition(inventoryItems)) {
      unlockUnderground();
    }
  }
  
  /// 特定の部屋に直接移動（同一階層内）
  void moveToRoom(RoomType targetRoom) {
    if (RoomUtils.getFloorFromRoom(targetRoom) == currentFloor) {
      _floorService.moveToRoom(targetRoom);
      notifyListeners();
    }
  }
  
  /// ゲームリセット
  void resetToInitialState() {
    _floorService.resetToInitialState();
    notifyListeners();
  }
  
  /// 現在の部屋のインデックス（-2から+2）
  int get currentRoomIndex => RoomUtils.getRoomIndex(currentRoom);
  
  /// 現在の部屋名
  String get currentRoomName => RoomUtils.getRoomName(currentRoom);
  
  /// 現在の階層名
  String get currentFloorName {
    switch (currentFloor) {
      case FloorType.floor1:
        return '1階';
      case FloorType.underground:
        return '地下';
      case FloorType.hiddenRoomA:
        return '隠し部屋A';
      case FloorType.hiddenRoomB:
        return '隠し部屋B';
      case FloorType.hiddenRoomC:
        return '隠し部屋C';
      case FloorType.hiddenRoomD:
        return '隠し部屋D';
      case FloorType.finalPuzzleRoom:
        return '最終謎部屋';
    }
  }
  
  /// 現在の部屋に対応した背景画像設定を取得
  GameBackgroundConfig getCurrentRoomBackground(bool isLightOn) {
    return BackgroundConfiguration.getRoomBackground(currentRoom, isLightOn);
  }

  /// デバッグ情報を出力
  void debugPrintNavigationState() {
    debugPrint('🧭 ナビゲーション状態:');
    debugPrint('  階層: $currentFloorName');
    debugPrint('  部屋: $currentRoomName');
    debugPrint('  インデックス: $currentRoomIndex');
    debugPrint('  左移動可能: $canMoveLeft');
    debugPrint('  右移動可能: $canMoveRight');
    debugPrint('  地下移動可能: $canMoveToUnderground');
    debugPrint('  1階移動可能: $canMoveToFloor1');
    debugPrint('  地下解放状態: $isUndergroundUnlocked');
  }
}