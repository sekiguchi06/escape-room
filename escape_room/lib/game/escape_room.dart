import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../framework/escape_room/core/escape_room_game.dart';
import 'components/inventory_widget.dart';
import 'components/game_menu_bar.dart';
import 'components/ad_area.dart';
import 'components/room_with_hotspots.dart';
import 'components/lighting_system.dart';
import 'components/room_navigation_system.dart';
import 'components/room_indicator.dart';
import 'widgets/custom_game_clear_ui.dart';
import '../framework/escape_room/state/escape_room_state_riverpod.dart';
import 'components/inventory_system.dart';
import '../framework/ui/item_notification_overlay.dart';
import '../framework/state/game_autosave_system.dart';

/// 新アーキテクチャ Escape Room ゲーム
/// 🎯 目的: 縦画面固定設定付きブラウザ動作確認
class EscapeRoom extends ConsumerStatefulWidget {
  const EscapeRoom({super.key});

  @override
  ConsumerState<EscapeRoom> createState() => _EscapeRoomState();
}

class _EscapeRoomState extends ConsumerState<EscapeRoom> {
  late EscapeRoomGame _game;
  ProgressAwareDataManager? _progressManager;

  @override
  void initState() {
    super.initState();
    // 縦画面固定設定（移植ガイド準拠）
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // ゲームインスタンスを初期化
    _game = EscapeRoomGame();

    // 進行度管理システムを初期化
    _initializeProgressSystem();

    // ゲーム開始時間を記録（クリア時間計算用）
    _gameStartTime = DateTime.now();
  }

  Future<void> _initializeProgressSystem() async {
    _progressManager = ProgressAwareDataManager.defaultInstance();
    await _progressManager!.initialize();

    // ゲーム内イベントのリスナーを設定
    _setupGameEventListeners();

    print('🎮 EscapeRoom: Progress system initialized');
  }

  void _setupGameEventListeners() {
    // インベントリシステムのリスナー設定
    InventorySystem().addListener(_onInventoryChanged);

    print('🎮 EscapeRoom: Event listeners set up');
  }

  void _onInventoryChanged() {
    print('📦 Inventory changed - updating progress...');
    final inventory = InventorySystem().inventory;
    final nonNullItems = inventory
        .where((item) => item != null)
        .cast<String>()
        .toList();
    print('📦 Current inventory: ${nonNullItems.join(', ')}');

    // アイテム取得時の進行度更新
    _updateProgressFromInventory();
  }

  Future<void> _updateProgressFromInventory() async {
    if (_progressManager != null) {
      final inventory = InventorySystem().inventory;
      final nonNullItems = inventory
          .where((item) => item != null)
          .cast<String>()
          .toList();

      // インベントリデータを進行度に記録
      await _progressManager!.progressManager.updateProgress(
        gameDataUpdate: {
          'inventory_items': nonNullItems
              .map(
                (itemId) => {
                  'id': itemId,
                  'name': itemId, // 簡易的にIDを名前として使用
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
      print('💾 Progress updated and saved from EscapeRoom');
      print('💾 Total items in progress: ${nonNullItems.length}');
    }
  }

  DateTime? _gameStartTime;

  @override
  void dispose() {
    // ゲームイベントリスナーを削除
    InventorySystem().removeListener(_onInventoryChanged);

    // 画面向き設定をリセット
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ProviderContainerをゲームに設定
    _game.setProviderContainer(ProviderScope.containerOf(context));

    // ゲーム状態を監視してクリア画面を表示
    _watchGameState();

    return Scaffold(
      body: Column(
        children: [
          // 1. ゲーム表示領域（動的高さ）
          Expanded(
            child: Builder(
              builder: (context) {
                final menuBarHeight = GameMenuBar.getHeight(context);

                return Stack(
                  children: [
                    // ゲーム本体（最下層・透明背景）
                    Positioned(
                      top: menuBarHeight, // 動的メニューバー高さ
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: GameWidget<EscapeRoomGame>(
                        game: _game,
                        overlayBuilderMap: _buildOverlayMap(),
                      ),
                    ),

                    // 背景とホットスポットを統合（中層・タップ可能）
                    Positioned(
                      top: menuBarHeight,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ListenableBuilder(
                        listenable: Listenable.merge([
                          RoomNavigationSystem(),
                          LightingSystem(),
                        ]),
                        builder: (context, _) {
                          final isLightOn = LightingSystem().isLightOn;
                          final currentConfig = RoomNavigationSystem()
                              .getCurrentRoomBackground(isLightOn);
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final gameSize = Size(
                                constraints.maxWidth,
                                constraints.maxHeight,
                              );
                              return OptimizedRoomWithHotspots(
                                config: currentConfig.copyWith(
                                  topReservedHeight: 0, // すでにPositionedで調整済み
                                ),
                                topReservedHeight: 0,
                                bottomReservedHeight: 12,
                                gameSize: gameSize,
                                game: _game, // ゲームインスタンスを渡す
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // 上部メニューバー（最前面オーバーレイ）
                    GameMenuBar(
                      onAddItem: () {
                        // TODO: アイテム追加ロジックを実装
                        debugPrint('Adding item from hint dialog');
                      },
                    ),

                    // 部屋インジケーター（メニューバー下部）
                    Positioned(
                      top: menuBarHeight + 8,
                      left: 0,
                      right: 0,
                      child: const Center(child: RoomIndicator()),
                    ),

                    // アイテム取得通知オーバーレイ（最前面）
                    Positioned(
                      bottom: 15.0, // ゲーム領域下端から15px上
                      left: MediaQuery.of(context).size.width * 0.025,
                      right: MediaQuery.of(context).size.width * 0.025,
                      child: const ItemNotificationOverlay(),
                    ),
                  ],
                );
              },
            ),
          ),

          // 2. インベントリ＋移動ボタン領域（動的高さ）
          const InventoryWidget(),

          // 3. 広告領域（固定50px）
          const AdArea(),
        ],
      ),
    );
  }

  /// overlayBuilderMapを構築
  Map<String, Widget Function(BuildContext, EscapeRoomGame)>
  _buildOverlayMap() {
    return {
      'gameClearUI': (context, game) {
        return CustomGameClearUI(
          clearTime: _gameStartTime != null
              ? DateTime.now().difference(_gameStartTime!)
              : null,
          onMenuPressed: () {
            // ゲームクリア画面を非表示にしてスタート画面に戻る
            game.overlays.remove('gameClearUI');
            Navigator.of(context).pop();
          },
          onRestartPressed: () {
            // ゲームクリア画面を非表示にしてゲームをリスタート
            game.overlays.remove('gameClearUI');
            _restartGame();
          },
        );
      },
    };
  }

  /// ゲームリスタート処理
  void _restartGame() {
    // ゲーム状態をリセット
    RoomNavigationSystem().resetToInitialRoom();
    LightingSystem().resetToInitialState();
    InventorySystem().initializeEmpty();

    // ゲーム開始時間をリセット
    _gameStartTime = DateTime.now();

    // ゲームの状態をリセット（EscapeRoomGameの初期状態に戻す）
    final stateNotifier = _game.stateNotifier;
    stateNotifier.resetToExploring();
  }

  /// ゲーム状態を監視してクリア画面を表示
  void _watchGameState() {
    // Riverpodの状態を監視
    ref.listen(escapeRoomStateProvider, (previous, current) {
      if (current.currentState == EscapeRoomState.escaped) {
        // 脱出成功時にクリア画面を表示
        _game.overlays.add('gameClearUI');
      }
    });
  }
}
