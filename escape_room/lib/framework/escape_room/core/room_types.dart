/// 階層タイプの定義
enum FloorType {
  floor1,           // 1階
  underground,      // 地下
  hiddenRoomA,      // 隠し部屋A
  hiddenRoomB,      // 隠し部屋B
  hiddenRoomC,      // 隠し部屋C
  hiddenRoomD,      // 隠し部屋D
  finalPuzzleRoom,  // 最終謎部屋
}

/// 部屋タイプの定義（既存の1階 + 新規地下）
enum RoomType {
  // 1階（既存）
  leftmost,         // 最左端の部屋（-2）
  left,             // 左の部屋（-1）
  center,           // 中央の部屋（0）開始地点
  right,            // 右の部屋（+1）
  rightmost,        // 最右端の部屋（+2）
  testRoom,         // テスト用部屋
  
  // 地下（新規）
  undergroundLeftmost,   // 地下最左端
  undergroundLeft,       // 地下左
  undergroundCenter,     // 地下中央（エントランス）
  undergroundRight,      // 地下右
  undergroundRightmost,  // 地下最右端
  
  // 特殊部屋（隠し部屋・最終謎部屋）
  hiddenA,                // 隠し部屋A
  hiddenB,                // 隠し部屋B
  hiddenC,                // 隠し部屋C
  hiddenD,                // 隠し部屋D
  hiddenE,                // 隠し部屋E（1階左奥）
  hiddenF,                // 隠し部屋F（地下左）
  hiddenG,                // 隠し部屋G（地下左奥）
  finalPuzzle,            // 最終謎部屋
}

/// 部屋の状態管理クラス
class RoomState {
  final FloorType floor;
  final RoomType room;
  final bool isAccessible;
  
  const RoomState({
    required this.floor,
    required this.room,
    required this.isAccessible,
  });
  
  /// コピーを作成
  RoomState copyWith({
    FloorType? floor,
    RoomType? room,
    bool? isAccessible,
  }) {
    return RoomState(
      floor: floor ?? this.floor,
      room: room ?? this.room,
      isAccessible: isAccessible ?? this.isAccessible,
    );
  }
}

/// 階層・部屋管理のためのユーティリティクラス
class RoomUtils {
  /// RoomTypeから所属する階層を取得
  static FloorType getFloorFromRoom(RoomType room) {
    switch (room) {
      case RoomType.leftmost:
      case RoomType.left:
      case RoomType.center:
      case RoomType.right:
      case RoomType.rightmost:
      case RoomType.testRoom:
        return FloorType.floor1;
        
      case RoomType.undergroundLeftmost:
      case RoomType.undergroundLeft:
      case RoomType.undergroundCenter:
      case RoomType.undergroundRight:
      case RoomType.undergroundRightmost:
        return FloorType.underground;
        
      // 隠し部屋A/B/Eは1階の特別部屋
      case RoomType.hiddenA:
      case RoomType.hiddenB:
      case RoomType.hiddenE:
        return FloorType.floor1;
      
      // 隠し部屋C/D/F/Gは地下の特別部屋  
      case RoomType.hiddenC:
      case RoomType.hiddenD:
      case RoomType.hiddenF:
      case RoomType.hiddenG:
        return FloorType.underground;
      case RoomType.finalPuzzle:
        return FloorType.finalPuzzleRoom;
    }
  }
  
  /// 階層の1階部屋リストを取得（通常移動可能な部屋のみ）
  static List<RoomType> getFloor1Rooms() {
    return [
      RoomType.leftmost,
      RoomType.left,
      RoomType.center,
      RoomType.right,
      RoomType.rightmost,
    ];
  }
  
  /// 階層の地下部屋リストを取得
  static List<RoomType> getUndergroundRooms() {
    return [
      RoomType.undergroundLeftmost,
      RoomType.undergroundLeft,
      RoomType.undergroundCenter,
      RoomType.undergroundRight,
      RoomType.undergroundRightmost,
    ];
  }
  
  /// 隠し部屋部屋リストを取得
  static List<RoomType> getHiddenRooms() {
    return [
      RoomType.hiddenA,
      RoomType.hiddenB,
      RoomType.hiddenC,
      RoomType.hiddenD,
    ];
  }
  
  /// 指定階層の部屋リストを取得
  static List<RoomType> getRoomsForFloor(FloorType floor) {
    switch (floor) {
      case FloorType.floor1:
        return getFloor1Rooms(); // 通常移動可能な部屋のみ
      case FloorType.underground:
        return getUndergroundRooms(); // 通常移動可能な部屋のみ
      case FloorType.hiddenRoomA:
        return [RoomType.hiddenA]; // 廃止予定（互換性のため残す）
      case FloorType.hiddenRoomB:
        return [RoomType.hiddenB]; // 廃止予定（互換性のため残す）
      case FloorType.hiddenRoomC:
        return [RoomType.hiddenC]; // 廃止予定（互換性のため残す）
      case FloorType.hiddenRoomD:
        return [RoomType.hiddenD]; // 廃止予定（互換性のため残す）
      case FloorType.finalPuzzleRoom:
        return [RoomType.finalPuzzle];
    }
  }
  
  /// 部屋のインデックスを取得（-2から+2）
  static int getRoomIndex(RoomType room) {
    switch (room) {
      // 1階
      case RoomType.leftmost:
        return -2;
      case RoomType.left:
        return -1;
      case RoomType.center:
        return 0;
      case RoomType.right:
        return 1;
      case RoomType.rightmost:
        return 2;
      case RoomType.testRoom:
        return 99; // テスト用特別値
        
      // 地下
      case RoomType.undergroundLeftmost:
        return -2;
      case RoomType.undergroundLeft:
        return -1;
      case RoomType.undergroundCenter:
        return 0;
      case RoomType.undergroundRight:
        return 1;
      case RoomType.undergroundRightmost:
        return 2;
        
      // 特殊部屋（隠し部屋・最終謎部屋）
      case RoomType.hiddenA:
        return 100; // 隠し部屋用特別値
      case RoomType.hiddenB:
        return 101;
      case RoomType.hiddenC:
        return 102;
      case RoomType.hiddenD:
        return 103;
      case RoomType.hiddenE:
        return 104; // 1階左奥隠し部屋
      case RoomType.hiddenF:
        return 105; // 地下左隠し部屋
      case RoomType.hiddenG:
        return 106; // 地下左奥隠し部屋
      case RoomType.finalPuzzle:
        return 200; // 最終謎部屋用特別値
    }
  }
  
  /// 部屋名を取得（デバッグ用）
  static String getRoomName(RoomType room) {
    switch (room) {
      // 1階
      case RoomType.leftmost:
        return '最左端の部屋';
      case RoomType.left:
        return '左の部屋';
      case RoomType.center:
        return '中央の部屋（図書館）';
      case RoomType.right:
        return '右の部屋';
      case RoomType.rightmost:
        return '最右端の部屋';
      case RoomType.testRoom:
        return 'テスト用部屋';
        
      // 地下
      case RoomType.undergroundLeftmost:
        return '地下最左端の部屋';
      case RoomType.undergroundLeft:
        return '地下左の部屋';
      case RoomType.undergroundCenter:
        return '地下中央の部屋';
      case RoomType.undergroundRight:
        return '地下右の部屋';
      case RoomType.undergroundRightmost:
        return '地下最右端の部屋';
        
      // 特殊部屋
      case RoomType.hiddenA:
        return '隠し部屋A';
      case RoomType.hiddenB:
        return '隠し部屋B';
      case RoomType.hiddenC:
        return '隠し部屋C';
      case RoomType.hiddenD:
        return '隠し部屋D';
      case RoomType.hiddenE:
        return '隠し部屋E（1階左奥）';
      case RoomType.hiddenF:
        return '隠し部屋F（地下左）';
      case RoomType.hiddenG:
        return '隠し部屋G（地下左奥）';
      case RoomType.finalPuzzle:
        return '最終謎部屋';
    }
  }
}