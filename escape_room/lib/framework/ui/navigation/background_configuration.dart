import '../../../gen/assets.gen.dart';
import '../../escape_room/core/room_types.dart';
import '../../../game/components/game_background.dart';

/// 部屋背景設定を管理するクラス
class BackgroundConfiguration {
  /// 現在の部屋に対応した背景画像設定を取得
  static GameBackgroundConfig getRoomBackground(RoomType room, bool isLightOn) {
    final baseConfig = _getRoomBackgroundConfig(room);

    // 照明がオフの場合は夜モードを使用（中央の部屋のみ）
    if (!isLightOn && room == RoomType.center) {
      return baseConfig.copyWith(asset: _getNightImageAsset(room));
    }

    return baseConfig;
  }
  
  /// 部屋の背景設定を取得
  static GameBackgroundConfig _getRoomBackgroundConfig(RoomType room) {
    switch (room) {
      // 1階の部屋
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
        
      // 地下の部屋
      case RoomType.undergroundLeftmost:
        return GameBackgroundConfig(
          asset: Assets.images.undergroundLeftmost,
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
      case RoomType.undergroundLeft:
        return GameBackgroundConfig(
          asset: Assets.images.undergroundLeft,
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
      case RoomType.undergroundCenter:
        return GameBackgroundConfig(
          asset: Assets.images.undergroundCenter,
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
      case RoomType.undergroundRight:
        return GameBackgroundConfig(
          asset: Assets.images.undergroundRight,
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
      case RoomType.undergroundRightmost:
        return GameBackgroundConfig(
          asset: Assets.images.undergroundRightmost,
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
        
      // 隠し部屋（専用背景画像使用）
      case RoomType.hiddenA:
        return GameBackgroundConfig(
          asset: Assets.images.hiddenRoomA,
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
      case RoomType.hiddenB:
        return GameBackgroundConfig(
          asset: Assets.images.hiddenRoomB,
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
      case RoomType.hiddenC:
        return GameBackgroundConfig(
          asset: Assets.images.hiddenRoomC,
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
      case RoomType.hiddenD:
        return GameBackgroundConfig(
          asset: Assets.images.hiddenRoomD,
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
      // 最終謎部屋（プレースホルダー画像使用）
      case RoomType.finalPuzzle:
        return GameBackgroundConfig(
          asset: Assets.images.escapeRoomBg, // プレースホルダー
          aspectRatio: 5 / 8,
          topReservedHeight: 84.0,
        );
    }
  }
  
  /// 夜モード画像アセットを取得（型安全）
  static AssetGenImage _getNightImageAsset(RoomType room) {
    switch (room) {
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
      // 地下・隠し部屋・最終謎部屋には夜モードなし（必要に応じて追加）
      case RoomType.undergroundLeftmost:
      case RoomType.undergroundLeft:
      case RoomType.undergroundCenter:
      case RoomType.undergroundRight:
      case RoomType.undergroundRightmost:
      case RoomType.hiddenA:
      case RoomType.hiddenB:
      case RoomType.hiddenC:
      case RoomType.hiddenD:
      case RoomType.finalPuzzle:
        return Assets.images.escapeRoomBgNight;
    }
  }
}