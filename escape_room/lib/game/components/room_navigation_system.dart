import 'package:flutter/material.dart';
import 'game_background.dart';
import '../../gen/assets.gen.dart';
import '../../framework/escape_room/core/room_types.dart';

/// 部屋ナビゲーションシステム
class RoomNavigationSystem extends ChangeNotifier {
  static final RoomNavigationSystem _instance =
      RoomNavigationSystem._internal();
  factory RoomNavigationSystem() => _instance;
  RoomNavigationSystem._internal();

  RoomType _currentRoom = RoomType.center; // 開始は中央

  /// 現在の部屋
  RoomType get currentRoom => _currentRoom;

  /// 現在の部屋のインデックス（-2から+2）
  int get currentRoomIndex {
    switch (_currentRoom) {
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
      // 地下は1階ナビゲーションシステムでは処理しない
      case RoomType.underground_leftmost:
      case RoomType.underground_left:
      case RoomType.underground_center:
      case RoomType.underground_right:
      case RoomType.underground_rightmost:
        return 0; // デフォルト値
      // 隠し部屋・最終謎部屋も処理しない
      case RoomType.hiddenA:
      case RoomType.hiddenB:
      case RoomType.hiddenC:
      case RoomType.hiddenD:
      case RoomType.finalPuzzle:
        return 0; // デフォルト値
    }
  }

  /// 左に移動可能かチェック
  bool get canMoveLeft => _currentRoom != RoomType.leftmost && 
      !_isUndergroundRoom(_currentRoom);

  /// 右に移動可能かチェック
  bool get canMoveRight => _currentRoom != RoomType.rightmost && 
      !_isUndergroundRoom(_currentRoom);
  
  /// 地下の部屋かどうかチェック
  bool _isUndergroundRoom(RoomType room) {
    return room == RoomType.underground_leftmost ||
           room == RoomType.underground_left ||
           room == RoomType.underground_center ||
           room == RoomType.underground_right ||
           room == RoomType.underground_rightmost;
  }

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
      case RoomType.testRoom:
        return; // テスト部屋は移動不可
      // 地下は1階ナビゲーションシステムでは移動処理しない
      case RoomType.underground_leftmost:
      case RoomType.underground_left:
      case RoomType.underground_center:
      case RoomType.underground_right:
      case RoomType.underground_rightmost:
        return; // 地下移動はMultiFloorNavigationSystemで処理
      // 隠し部屋・最終謎部屋も移動不可
      case RoomType.hiddenA:
      case RoomType.hiddenB:
      case RoomType.hiddenC:
      case RoomType.hiddenD:
      case RoomType.finalPuzzle:
        return; // 隠し部屋は左右移動不可
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
      case RoomType.testRoom:
        return; // テスト部屋は移動不可
      // 地下は1階ナビゲーションシステムでは移動処理しない
      case RoomType.underground_leftmost:
      case RoomType.underground_left:
      case RoomType.underground_center:
      case RoomType.underground_right:
      case RoomType.underground_rightmost:
        return; // 地下移動はMultiFloorNavigationSystemで処理
      // 隠し部屋・最終謎部屋も移動不可
      case RoomType.hiddenA:
      case RoomType.hiddenB:
      case RoomType.hiddenC:
      case RoomType.hiddenD:
      case RoomType.finalPuzzle:
        return; // 隠し部屋は左右移動不可
    }

    notifyListeners();
    debugPrint('🔜 右に移動: ${_getRoomName()}');
  }

  /// 現在の部屋に対応した背景画像設定を取得
  GameBackgroundConfig getCurrentRoomBackground(bool isLightOn) {
    final baseConfig = _getRoomBackgroundConfig();

    // 照明がオフの場合は夜モードを使用（中央の部屋のみ）
    if (!isLightOn && _currentRoom == RoomType.center) {
      return baseConfig.copyWith(asset: _getNightImageAsset());
    }

    return baseConfig;
  }

  /// 部屋の背景設定を取得
  GameBackgroundConfig _getRoomBackgroundConfig() {
    switch (_currentRoom) {
      case RoomType.leftmost:
        return GameBackgroundConfig(
          asset: Assets.images.roomLeftmost,
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
      case RoomType.left:
        return GameBackgroundConfig(
          asset: Assets.images.roomLeft,
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
      case RoomType.center:
        return GameBackgroundConfig.escapeRoom; // 既存の中央部屋
      case RoomType.right:
        return GameBackgroundConfig(
          asset: Assets.images.roomRight,
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
      case RoomType.rightmost:
        return GameBackgroundConfig(
          asset: Assets.images.roomRightmost,
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
      case RoomType.testRoom:
        return GameBackgroundConfig(
          asset: Assets.images.escapeRoomBg, // テスト用はデフォルト背景
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
      // 地下の部屋（1階ナビゲーションシステムでは処理しないが、背景は提供）
      case RoomType.underground_leftmost:
        return GameBackgroundConfig(
          asset: Assets.images.undergroundLeftmost,
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
      case RoomType.underground_left:
        return GameBackgroundConfig(
          asset: Assets.images.undergroundLeft,
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
      case RoomType.underground_center:
        return GameBackgroundConfig(
          asset: Assets.images.undergroundCenter,
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
      case RoomType.underground_right:
        return GameBackgroundConfig(
          asset: Assets.images.undergroundRight,
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
      case RoomType.underground_rightmost:
        return GameBackgroundConfig(
          asset: Assets.images.undergroundRightmost,
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
      // 隠し部屋・最終謎部屋もプレースホルダー
      case RoomType.hiddenA:
      case RoomType.hiddenB:
      case RoomType.hiddenC:
      case RoomType.hiddenD:
      case RoomType.finalPuzzle:
        return GameBackgroundConfig(
          asset: Assets.images.escapeRoomBg, // プレースホルダー
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
    }
  }

  /// 夜モードのアセットを取得（型安全）
  AssetGenImage _getNightImageAsset() {
    switch (_currentRoom) {
      case RoomType.leftmost:
        return Assets.images.roomLeftmostNight;
      case RoomType.left:
        return Assets.images.roomLeftNight;
      case RoomType.center:
        return Assets.images.escapeRoomBgNight; // 既存
      case RoomType.right:
        return Assets.images.roomRightNight;
      case RoomType.rightmost:
        return Assets.images.roomRightmostNight;
      case RoomType.testRoom:
        return Assets.images.escapeRoomBgNight; // テスト用
      // 地下は1階ナビゲーションシステムでは処理しない（プレースホルダー返却）
      case RoomType.underground_leftmost:
      case RoomType.underground_left:
      case RoomType.underground_center:
      case RoomType.underground_right:
      case RoomType.underground_rightmost:
        return Assets.images.escapeRoomBgNight; // プレースホルダー
      // 隠し部屋・最終謎部屋もプレースホルダー
      case RoomType.hiddenA:
      case RoomType.hiddenB:
      case RoomType.hiddenC:
      case RoomType.hiddenD:
      case RoomType.finalPuzzle:
        return Assets.images.escapeRoomBgNight; // プレースホルダー
    }
  }

  /// ゲームリスタート時：最初の部屋（中央）に戻す
  void resetToInitialRoom() {
    _currentRoom = RoomType.center;
    notifyListeners();
    debugPrint('🔄 ゲームリスタート: ${_getRoomName()}に戻りました');
  }

  /// 部屋名を取得（デバッグ用）
  String _getRoomName() {
    switch (_currentRoom) {
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
        return 'テスト部屋';
      // 地下は1階ナビゲーションシステムでは処理しない
      case RoomType.underground_leftmost:
        return '地下最左端の部屋';
      case RoomType.underground_left:
        return '地下左の部屋';
      case RoomType.underground_center:
        return '地下中央の部屋';
      case RoomType.underground_right:
        return '地下右の部屋';
      case RoomType.underground_rightmost:
        return '地下最右端の部屋';
      // 隠し部屋・最終謎部屋
      case RoomType.hiddenA:
        return '隠し部屋A';
      case RoomType.hiddenB:
        return '隠し部屋B';
      case RoomType.hiddenC:
        return '隠し部屋C';
      case RoomType.hiddenD:
        return '隠し部屋D';
      case RoomType.finalPuzzle:
        return '最終謎部屋';
    }
  }
}
