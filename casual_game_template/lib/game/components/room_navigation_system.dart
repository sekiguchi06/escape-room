import 'package:flutter/material.dart';
import 'game_background.dart';

/// 部屋の種類
enum RoomType {
  leftmost,  // 最左端の部屋（-2）
  left,      // 左の部屋（-1）
  center,    // 中央の部屋（0）開始地点
  right,     // 右の部屋（+1）
  rightmost, // 最右端の部屋（+2）
}

/// 部屋ナビゲーションシステム
class RoomNavigationSystem extends ChangeNotifier {
  static final RoomNavigationSystem _instance = RoomNavigationSystem._internal();
  factory RoomNavigationSystem() => _instance;
  RoomNavigationSystem._internal();

  RoomType _currentRoom = RoomType.center; // 開始は中央

  /// 現在の部屋
  RoomType get currentRoom => _currentRoom;

  /// 現在の部屋のインデックス（-2から+2）
  int get currentRoomIndex {
    switch (_currentRoom) {
      case RoomType.leftmost: return -2;
      case RoomType.left: return -1;
      case RoomType.center: return 0;
      case RoomType.right: return 1;
      case RoomType.rightmost: return 2;
    }
  }

  /// 左に移動可能かチェック
  bool get canMoveLeft => _currentRoom != RoomType.leftmost;

  /// 右に移動可能かチェック
  bool get canMoveRight => _currentRoom != RoomType.rightmost;

  /// 左の部屋に移動
  void moveLeft() {
    if (!canMoveLeft) return;

    switch (_currentRoom) {
      case RoomType.left:
        _currentRoom = RoomType.leftmost;
        break;
      case RoomType.center:
        _currentRoom = RoomType.left;
        break;
      case RoomType.right:
        _currentRoom = RoomType.center;
        break;
      case RoomType.rightmost:
        _currentRoom = RoomType.right;
        break;
      case RoomType.leftmost:
        return; // 既に最左端
    }

    notifyListeners();
    debugPrint('🔙 左に移動: ${_getRoomName()}');
  }

  /// 右の部屋に移動
  void moveRight() {
    if (!canMoveRight) return;

    switch (_currentRoom) {
      case RoomType.leftmost:
        _currentRoom = RoomType.left;
        break;
      case RoomType.left:
        _currentRoom = RoomType.center;
        break;
      case RoomType.center:
        _currentRoom = RoomType.right;
        break;
      case RoomType.right:
        _currentRoom = RoomType.rightmost;
        break;
      case RoomType.rightmost:
        return; // 既に最右端
    }

    notifyListeners();
    debugPrint('🔜 右に移動: ${_getRoomName()}');
  }

  /// 現在の部屋に対応した背景画像設定を取得
  GameBackgroundConfig getCurrentRoomBackground(bool isLightOn) {
    final baseConfig = _getRoomBackgroundConfig();
    
    // 照明がオフの場合は夜モードを使用（中央の部屋のみ）
    if (!isLightOn && _currentRoom == RoomType.center) {
      return baseConfig.copyWith(
        imagePath: _getNightImagePath(),
      );
    }
    
    return baseConfig;
  }

  /// 部屋の背景設定を取得
  GameBackgroundConfig _getRoomBackgroundConfig() {
    switch (_currentRoom) {
      case RoomType.leftmost:
        return GameBackgroundConfig(
          imagePath: 'assets/images/room_leftmost.png',
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
      case RoomType.left:
        return GameBackgroundConfig(
          imagePath: 'assets/images/room_left.png',
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
      case RoomType.center:
        return GameBackgroundConfig.escapeRoom; // 既存の中央部屋
      case RoomType.right:
        return GameBackgroundConfig(
          imagePath: 'assets/images/room_right.png',
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
      case RoomType.rightmost:
        return GameBackgroundConfig(
          imagePath: 'assets/images/room_rightmost.png',
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
    }
  }

  /// 夜モードの画像パスを取得
  String _getNightImagePath() {
    switch (_currentRoom) {
      case RoomType.leftmost:
        return 'assets/images/room_leftmost_night.png';
      case RoomType.left:
        return 'assets/images/room_left_night.png';
      case RoomType.center:
        return 'assets/images/escape_room_bg_night.png'; // 既存
      case RoomType.right:
        return 'assets/images/room_right_night.png';
      case RoomType.rightmost:
        return 'assets/images/room_rightmost_night.png';
    }
  }

  /// 部屋名を取得（デバッグ用）
  String _getRoomName() {
    switch (_currentRoom) {
      case RoomType.leftmost: return '最左端の部屋';
      case RoomType.left: return '左の部屋';
      case RoomType.center: return '中央の部屋（図書館）';
      case RoomType.right: return '右の部屋';
      case RoomType.rightmost: return '最右端の部屋';
    }
  }
}