import 'package:flutter/material.dart';
import 'game_background.dart';
import 'room_navigation_system.dart';
import '../../framework/escape_room/core/room_types.dart';

/// 照明システムの状態管理
class LightingSystem extends ChangeNotifier {
  static final LightingSystem _instance = LightingSystem._internal();
  factory LightingSystem() => _instance;
  LightingSystem._internal();

  bool _isLightOn = true; // デフォルトは照明オン

  /// 照明がオンかどうか
  bool get isLightOn => _isLightOn;

  /// 照明をオンにする
  void turnOnLight() {
    if (!_isLightOn) {
      _isLightOn = true;
      notifyListeners();
      debugPrint('💡 照明オン: 部屋が明るくなりました');
    }
  }

  /// 照明をオフにする
  void turnOffLight() {
    if (_isLightOn) {
      _isLightOn = false;
      notifyListeners();
      debugPrint('🌙 照明オフ: 部屋が暗くなりました');
    }
  }

  /// 照明をトグル（切り替え）- 中央の部屋でのみ有効
  void toggleLight() {
    // 中央の部屋でのみ照明操作可能
    if (!_canToggleLightInCurrentRoom()) {
      debugPrint('💡 この部屋では照明を操作できません');
      return;
    }

    _isLightOn = !_isLightOn;
    notifyListeners();
    debugPrint(_isLightOn ? '💡 照明オン（図書館）' : '🌙 照明オフ（図書館）');
  }

  /// 現在の部屋で照明操作が可能かチェック
  bool _canToggleLightInCurrentRoom() {
    return RoomNavigationSystem().currentRoom == RoomType.center;
  }

  /// ゲームリスタート時：照明を初期状態（オン）に戻す
  void resetToInitialState() {
    _isLightOn = true;
    notifyListeners();
    debugPrint('🔄 ゲームリスタート: 照明システムをリセット（オン）');
  }

  /// 現在の照明状態に応じた背景設定を取得
  GameBackgroundConfig getCurrentBackgroundConfig() {
    return _isLightOn
        ? GameBackgroundConfig.escapeRoom
        : GameBackgroundConfig.escapeRoomNight;
  }
}
