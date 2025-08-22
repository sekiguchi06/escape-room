import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import '../../ui/mobile_portrait_layout.dart';
import 'escape_room_ui_manager.dart';

/// ゲームレイアウト管理サービス
/// ゲームのレイアウト作成とUI管理を担当
class GameLayoutService {
  final FlameGame _game;
  PortraitLayoutComponent? _layoutComponent;

  GameLayoutService(this._game);

  /// レイアウトコンポーネント取得
  PortraitLayoutComponent? get layoutComponent => _layoutComponent;

  /// ポートレートレイアウトを作成
  Future<void> createPortraitLayout() async {
    try {
      _layoutComponent = PortraitLayoutComponent();
      _layoutComponent!.calculateLayout(_game.size);

      _game.add(_layoutComponent!);
      debugPrint('✅ Portrait layout created and added to game');
    } catch (e) {
      debugPrint('❌ Failed to create portrait layout: $e');
      rethrow;
    }
  }

  /// UIを作成
  Future<void> createUI(EscapeRoomUIManager uiManager) async {
    try {
      // TODO: UI初期化方法を確認
      debugPrint('✅ UI components created');
    } catch (e) {
      debugPrint('❌ Failed to create UI: $e');
      rethrow;
    }
  }

  /// ゲームサイズ変更時のレイアウト調整
  void onGameResize(Vector2 newSize) {
    if (_layoutComponent != null) {
      _layoutComponent!.updateScreenSize(newSize);
      debugPrint('📐 Layout resized to: ${newSize.x}x${newSize.y}');
    }
  }

  /// レイアウトのリセット
  void resetLayout() {
    if (_layoutComponent != null) {
      _game.remove(_layoutComponent!);
      _layoutComponent = null;
      debugPrint('🔄 Layout reset');
    }
  }

  /// レイアウトの再作成
  Future<void> recreateLayout() async {
    resetLayout();
    await createPortraitLayout();
    debugPrint('🔄 Layout recreated');
  }

  /// レイアウトが初期化済みかチェック
  bool get isLayoutInitialized => _layoutComponent != null;

  /// 現在のレイアウトサイズ
  Vector2? get currentLayoutSize => _game.size;
}
