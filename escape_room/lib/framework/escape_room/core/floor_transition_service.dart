import 'package:flutter/material.dart';
import 'room_types.dart';
import 'escape_room_game.dart';

/// 階層移動管理サービス
class FloorTransitionService extends ChangeNotifier {
  static final FloorTransitionService _instance = FloorTransitionService._internal();
  factory FloorTransitionService() => _instance;
  FloorTransitionService._internal();
  
  // 現在の階層
  FloorType _currentFloor = FloorType.floor1;
  
  // 地下へのアクセス許可状態
  bool _isUndergroundUnlocked = false;
  
  // 階段解放状態（main_escape_key使用後に解放）
  bool _areStairsUnlocked = false;
  
  // 各階層での現在の部屋
  final Map<FloorType, RoomType> _floorCurrentRoom = {
    FloorType.floor1: RoomType.center,
    FloorType.underground: RoomType.underground_center,
    FloorType.hiddenRoomA: RoomType.hiddenA,
    FloorType.hiddenRoomB: RoomType.hiddenB,
    FloorType.hiddenRoomC: RoomType.hiddenC,
    FloorType.hiddenRoomD: RoomType.hiddenD,
    FloorType.finalPuzzleRoom: RoomType.finalPuzzle,
  };
  
  /// 現在の階層を取得
  FloorType get currentFloor => _currentFloor;
  
  /// 地下へのアクセス許可状態を取得
  bool get isUndergroundUnlocked => _isUndergroundUnlocked;
  
  /// 階段解放状態を取得
  bool get areStairsUnlocked => _areStairsUnlocked;
  
  /// 現在の階層での現在の部屋を取得
  RoomType get currentRoom => _floorCurrentRoom[_currentFloor]!;
  
  /// 指定階層での現在の部屋を取得
  RoomType getCurrentRoomForFloor(FloorType floor) {
    return _floorCurrentRoom[floor]!;
  }
  
  /// 1階から地下への移動が可能かチェック
  bool canTransitionToUnderground() {
    final canMove = _currentFloor == FloorType.floor1 &&
                   currentRoom == RoomType.rightmost;
    
    // デバッグ用：地下解放条件を一時的に無効化
    debugPrint('🔍 地下移動チェック:');
    debugPrint('  現在階層: ${_getFloorName(_currentFloor)}');
    debugPrint('  現在部屋: ${RoomUtils.getRoomName(currentRoom)}');
    debugPrint('  rightmost部屋にいる: ${currentRoom == RoomType.rightmost}');
    debugPrint('  地下解放状態: ${_isUndergroundUnlocked ? "解放済み" : "未解放"}');
    debugPrint('  移動可能: $canMove (アイテム条件無視)');
    
    return canMove; // 一時的にアイテム条件を無視
  }
  
  /// 地下から1階への移動が可能かチェック
  bool canTransitionToFloor1() {
    return _currentFloor == FloorType.underground &&
           currentRoom == RoomType.underground_center;
  }
  
  /// 地下アクセスを解放
  void unlockUnderground() {
    if (!_isUndergroundUnlocked) {
      _isUndergroundUnlocked = true;
      debugPrint('🔓 地下へのアクセスが解放されました');
      notifyListeners();
    }
  }
  
  /// 地下アクセスの解放条件をチェック
  bool checkUndergroundUnlockCondition(List<String> inventoryItems) {
    // 1階クリア条件: main_escape_keyを持っている
    return inventoryItems.contains('main_escape_key');
  }
  
  /// 階層移動を実行
  Future<void> transitionToFloor(FloorType targetFloor) async {
    if (targetFloor == _currentFloor) return;
    
    switch (targetFloor) {
      case FloorType.underground:
        if (!canTransitionToUnderground()) {
          debugPrint('❌ 地下への移動条件が満たされていません');
          return;
        }
        break;
        
      case FloorType.floor1:
        if (!canTransitionToFloor1()) {
          debugPrint('❌ 1階への移動条件が満たされていません');
          return;
        }
        break;
        
      // 隠し部屋への移動は常に許可（呼び出し側で制御）
      case FloorType.hiddenRoomA:
      case FloorType.hiddenRoomB:
      case FloorType.hiddenRoomC:
      case FloorType.hiddenRoomD:
      case FloorType.finalPuzzleRoom:
        break;
    }
    
    final previousFloor = _currentFloor;
    _currentFloor = targetFloor;
    
    debugPrint('🔄 階層移動: ${_getFloorName(previousFloor)} → ${_getFloorName(targetFloor)}');
    debugPrint('📍 移動先部屋: ${RoomUtils.getRoomName(currentRoom)}');
    
    notifyListeners();
  }
  
  /// 現在の階層での部屋移動
  void moveToRoom(RoomType targetRoom) {
    if (RoomUtils.getFloorFromRoom(targetRoom) != _currentFloor) {
      debugPrint('❌ 現在の階層と異なる部屋への移動はできません');
      return;
    }
    
    _floorCurrentRoom[_currentFloor] = targetRoom;
    debugPrint('🚶 部屋移動: ${RoomUtils.getRoomName(targetRoom)}');
    notifyListeners();
  }
  
  /// 現在の階層で左に移動可能かチェック
  bool canMoveLeft() {
    // 隠し部屋・最終謎部屋では左右移動不可
    if (_isHiddenOrSpecialRoom(currentRoom)) {
      return false;
    }
    
    final roomIndex = RoomUtils.getRoomIndex(currentRoom);
    final rooms = RoomUtils.getRoomsForFloor(_currentFloor);
    return roomIndex > RoomUtils.getRoomIndex(rooms.first);
  }
  
  /// 現在の階層で右に移動可能かチェック
  bool canMoveRight() {
    // 隠し部屋・最終謎部屋では左右移動不可
    if (_isHiddenOrSpecialRoom(currentRoom)) {
      return false;
    }
    
    final roomIndex = RoomUtils.getRoomIndex(currentRoom);
    final rooms = RoomUtils.getRoomsForFloor(_currentFloor);
    return roomIndex < RoomUtils.getRoomIndex(rooms.last);
  }
  
  /// 左の部屋に移動
  void moveLeft() {
    if (!canMoveLeft()) return;
    
    final rooms = RoomUtils.getRoomsForFloor(_currentFloor);
    final currentIndex = rooms.indexOf(currentRoom);
    if (currentIndex > 0) {
      moveToRoom(rooms[currentIndex - 1]);
    }
  }
  
  /// 右の部屋に移動
  void moveRight() {
    if (!canMoveRight()) return;
    
    final rooms = RoomUtils.getRoomsForFloor(_currentFloor);
    final currentIndex = rooms.indexOf(currentRoom);
    if (currentIndex < rooms.length - 1) {
      moveToRoom(rooms[currentIndex + 1]);
    }
  }
  
  /// ゲームリセット時の初期化
  void resetToInitialState() {
    _currentFloor = FloorType.floor1;
    _isUndergroundUnlocked = false;
    _areStairsUnlocked = false;
    _floorCurrentRoom[FloorType.floor1] = RoomType.center;
    _floorCurrentRoom[FloorType.underground] = RoomType.underground_center;
    _floorCurrentRoom[FloorType.hiddenRoomA] = RoomType.hiddenA;
    _floorCurrentRoom[FloorType.hiddenRoomB] = RoomType.hiddenB;
    _floorCurrentRoom[FloorType.hiddenRoomC] = RoomType.hiddenC;
    _floorCurrentRoom[FloorType.hiddenRoomD] = RoomType.hiddenD;
    _floorCurrentRoom[FloorType.finalPuzzleRoom] = RoomType.finalPuzzle;
    debugPrint('🔄 階層システムをリセットしました');
    notifyListeners();
  }
  
  /// 階層移動アニメーション（プレースホルダー）
  Future<void> _playTransitionAnimation(FloorType targetFloor) async {
    // TODO: 実際のアニメーション実装
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  /// 隠し部屋・特殊部屋かどうかをチェック
  bool _isHiddenOrSpecialRoom(RoomType room) {
    return room == RoomType.hiddenA ||
           room == RoomType.hiddenB ||
           room == RoomType.hiddenC ||
           room == RoomType.hiddenD ||
           room == RoomType.finalPuzzle;
  }

  /// 階層名を取得（デバッグ用）
  String _getFloorName(FloorType floor) {
    switch (floor) {
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
  
  /// main_escape_keyを使って階段を解放
  void unlockStairsWithKey() {
    _areStairsUnlocked = true;
    _isUndergroundUnlocked = true;
    debugPrint('🗝️ 地下の鍵を使用して階段が解放されました！');
    debugPrint('🪜 今後は1階と地下を自由に行き来できます');
    notifyListeners();
  }

  /// 現在の状態をデバッグ出力
  void debugPrintCurrentState() {
    debugPrint('🏢 現在の階層: ${_getFloorName(_currentFloor)}');
    debugPrint('🚪 現在の部屋: ${RoomUtils.getRoomName(currentRoom)}');
    debugPrint('🔓 地下アクセス: ${_isUndergroundUnlocked ? "解放済み" : "未解放"}');
    debugPrint('🪜 階段解放: ${_areStairsUnlocked ? "解放済み" : "未解放"}');
    debugPrint('⬅️ 左移動可能: ${canMoveLeft()}');
    debugPrint('➡️ 右移動可能: ${canMoveRight()}');
    debugPrint('⬇️ 地下移動可能: ${canTransitionToUnderground()}');
    debugPrint('⬆️ 1階移動可能: ${canTransitionToFloor1()}');
  }
}