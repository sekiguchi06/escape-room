import 'package:flutter/services.dart';
import '../framework/ui/multi_floor_navigation_system.dart';
import 'components/lighting_system.dart';
import 'components/inventory_system.dart';
import 'services/bgm_manager.dart';
import '../framework/state/game_manual_save_system.dart';

/// ゲーム状態管理とシステム初期化の責任分離クラス
class EscapeRoomStateManager {
  ProgressAwareDataManager? _progressManager;
  late BgmManager _bgmManager;
  DateTime? _gameStartTime;
  
  // ゲッター
  DateTime? get gameStartTime => _gameStartTime;
  ProgressAwareDataManager? get progressManager => _progressManager;
  BgmManager get bgmManager => _bgmManager;

  /// システム初期化
  Future<void> initializeSystems() async {
    // 縦画面固定設定
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // 進行度管理システムを初期化
    await _initializeProgressSystem();

    // ゲーム開始時間を記録
    _gameStartTime = DateTime.now();
    
    // BGM管理システムの初期化
    _bgmManager = BgmManager();
    _bgmManager.initialize();
    
    // 階層変化監視の設定
    MultiFloorNavigationSystem().addListener(_onFloorChanged);
  }

  /// 進行度管理システムの初期化
  Future<void> _initializeProgressSystem() async {
    _progressManager = ProgressAwareDataManager.defaultInstance();
    await _progressManager!.initialize();
  }

  /// インベントリ変化時の処理
  Future<void> handleInventoryChanged() async {
    final inventory = InventorySystem().inventory;
    final nonNullItems = inventory
        .where((item) => item != null)
        .cast<String>()
        .toList();

    // 地下解放条件をチェック
    MultiFloorNavigationSystem().checkAndUnlockUnderground(nonNullItems);

    // アイテム取得時の進行度更新
    await _updateProgressFromInventory();
  }

  /// インベントリから進行度を更新
  Future<void> _updateProgressFromInventory() async {
    if (_progressManager != null) {
      final inventory = InventorySystem().inventory;
      final nonNullItems = inventory
          .where((item) => item != null)
          .cast<String>()
          .toList();

      await _progressManager!.progressManager.updateProgress(
        gameDataUpdate: {
          'inventory_items': nonNullItems
              .map(
                (itemId) => {
                  'id': itemId,
                  'name': itemId,
                  'category': 'general',
                },
              )
              .toList(),
          'total_items_collected': nonNullItems.length,
          'last_update': DateTime.now().toIso8601String(),
        },
        statisticsUpdate: {'items_collected': 1},
      );

      await _progressManager!.manualSave();
    }
  }

  /// ゲーム状態をリセット
  void resetGameState() {
    // システム状態をリセット
    MultiFloorNavigationSystem().resetToInitialState();
    LightingSystem().resetToInitialState();
    InventorySystem().initializeEmpty();

    // ゲーム開始時間をリセット
    _gameStartTime = DateTime.now();
    
    // BGMシステムもリセット
    _bgmManager.initialize();
    MultiFloorNavigationSystem().addListener(_onFloorChanged);
  }

  /// 階層変化時のコールバック
  void _onFloorChanged() {
    final navigationSystem = MultiFloorNavigationSystem();
    final newFloor = navigationSystem.currentFloor;
    _bgmManager.onFloorChanged(newFloor);
  }

  /// リソース解放
  void dispose() {
    _bgmManager.dispose();
    MultiFloorNavigationSystem().removeListener(_onFloorChanged);
    InventorySystem().removeListener(handleInventoryChanged);

    // 画面向き設定をリセット
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}
