import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame_audio/flame_audio.dart';
import '../framework/escape_room/core/escape_room_game.dart';
import 'components/inventory_widget.dart';
import 'components/game_menu_bar.dart';
import 'components/ad_area.dart';
import 'components/room_with_hotspots.dart';
import 'components/lighting_system.dart';
import 'components/room_indicator.dart';
import 'components/floor_indicator.dart';
import '../framework/ui/multi_floor_navigation_system.dart';
import '../framework/escape_room/core/room_types.dart';
import 'widgets/custom_game_clear_ui.dart';
import '../framework/escape_room/state/escape_room_state_riverpod.dart';
import 'components/inventory_system.dart';
import '../framework/ui/item_notification_overlay.dart';
import '../framework/state/game_manual_save_system.dart';

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
  
  // BGM管理用変数
  FloorType? _currentFloor;
  bool _isBgmPlaying = false;
  String? _currentBgmFile;

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
    
    // FlameAudio BGM公式推奨初期化 + 階層変化監視
    _initializeBgmSystem();
    
    // デバッグ用案内メッセージ
    Future.delayed(const Duration(seconds: 2), () {
      debugPrint('🎮 脱出ゲーム開始！');
      debugPrint('📋 地下への道筋（デバッグモード）:');
      debugPrint('  1. 右矢印ボタンを連打してrightmost部屋に到達');
      debugPrint('  2. rightmost部屋の左下「地下への階段」ホットスポットをタップ');
      debugPrint('  3. 地下中央に移動');
      debugPrint('  4. 地下で左右矢印ボタンで探索可能');
      debugPrint('  5. 地下中央の「上への階段」で1階に戻れます');
    });
  }

  Future<void> _initializeProgressSystem() async {
    _progressManager = ProgressAwareDataManager.defaultInstance();
    await _progressManager!.initialize();

    // ゲーム内イベントのリスナーを設定
    _setupGameEventListeners();

    debugPrint('🎮 EscapeRoom: Progress system initialized');
  }

  void _setupGameEventListeners() {
    // インベントリシステムのリスナー設定
    InventorySystem().addListener(_onInventoryChanged);

    debugPrint('🎮 EscapeRoom: Event listeners set up');
  }

  void _onInventoryChanged() {
    debugPrint('📦 Inventory changed - updating progress...');
    final inventory = InventorySystem().inventory;
    final nonNullItems = inventory
        .where((item) => item != null)
        .cast<String>()
        .toList();
    debugPrint('📦 Current inventory: ${nonNullItems.join(', ')}');

    // 地下解放条件をチェック
    MultiFloorNavigationSystem().checkAndUnlockUnderground(nonNullItems);

    // アイテム取得時の進行度更新
    _updateProgressFromInventory();
    
    // UI更新
    if (mounted) {
      setState(() {});
    }
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
      debugPrint('💾 Progress updated and saved from EscapeRoom');
      debugPrint('💾 Total items in progress: ${nonNullItems.length}');
    }
  }

  DateTime? _gameStartTime;

  @override
  void dispose() {
    // BGMシステムを停止（公式推奨：dispose()は完全終了時のみ）
    _stopFloorBgmSystem();
    
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
                          MultiFloorNavigationSystem(),
                          LightingSystem(),
                        ]),
                        builder: (context, _) {
                          final isLightOn = LightingSystem().isLightOn;
                          final currentConfig = MultiFloorNavigationSystem()
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

                    // 階層表示（メニューバー下部）
                    Positioned(
                      top: menuBarHeight + 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ListenableBuilder(
                          listenable: MultiFloorNavigationSystem(),
                          builder: (context, _) {
                            return FloorIndicatorWidget(
                              currentFloor: MultiFloorNavigationSystem().currentFloor,
                              isUndergroundUnlocked: MultiFloorNavigationSystem().isUndergroundUnlocked,
                              onFloorTap: () {
                                // 階層変更時の処理
                                setState(() {});
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    // 部屋インジケーター（階層表示下部）
                    Positioned(
                      top: menuBarHeight + 50, // 階層表示の分だけ下げる
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
    MultiFloorNavigationSystem().resetToInitialState();
    LightingSystem().resetToInitialState();
    InventorySystem().initializeEmpty();

    // ゲーム開始時間をリセット
    _gameStartTime = DateTime.now();

    // ゲームの状態をリセット（EscapeRoomGameの初期状態に戻す）
    final stateNotifier = _game.stateNotifier;
    stateNotifier.resetToExploring();
    
    // BGMシステムもリセット
    _initializeFloorBgmSystem();
  }

  /// BGMシステム初期化（app.dartで初期化済みのため階層システムのみ）
  void _initializeBgmSystem() async {
    try {
      // FlameAudio.bgm.initialize() - app.dartで一元管理済み（重複削除）
      debugPrint('✅ FlameAudio BGM - app.dartで初期化済み');
      
      // 階層別BGMシステムの初期化
      _initializeFloorBgmSystem();
    } catch (e) {
      debugPrint('❌ BGM初期化エラー: $e');
    }
  }
  
  void _initializeFloorBgmSystem() {
    debugPrint('🎵 階層別BGMシステム初期化開始');
    final navigationSystem = MultiFloorNavigationSystem();
    _currentFloor = navigationSystem.currentFloor;
    
    // BGM状態をリセット（新しいゲームセッション）
    _isBgmPlaying = false;
    
    debugPrint('🎵 初期階層: ${_floorName(_currentFloor)}');
    
    // スタート画面からの遷移を考慮してBGMを開始
    Future.delayed(const Duration(milliseconds: 1200), () {
      _updateBgmForCurrentFloor();
    });
    
    // 階層変化を監視
    navigationSystem.addListener(_onFloorChanged);
    debugPrint('✅ 階層別BGMシステム初期化完了');
  }
  
  /// FlameAudioの動作テスト（iOS確認用）
  void _testFlameAudio() async {
    try {
      debugPrint('🔧 FlameAudio動作テスト開始');
      // 短い効果音で動作確認
      await FlameAudio.play('close.mp3', volume: 0.5);
      debugPrint('✅ FlameAudio動作テスト成功');
    } catch (e) {
      debugPrint('❌ FlameAudio動作テスト失敗: $e');
    }
  }
  
  /// 階層変化時のコールバック
  void _onFloorChanged() {
    final navigationSystem = MultiFloorNavigationSystem();
    final newFloor = navigationSystem.currentFloor;
    
    if (_currentFloor != newFloor) {
      debugPrint('🎵 階層変化を検出: ${_floorName(_currentFloor)} → ${_floorName(newFloor)}');
      
      // 強制的に現在のBGMを停止
      _forceStopCurrentBgm();
      
      // 階層を更新
      _currentFloor = newFloor;
      
      // 少し待ってから新しいBGMを開始
      Future.delayed(const Duration(milliseconds: 300), () {
        _updateBgmForCurrentFloor();
      });
    }
  }
  
  /// 公式推奨：BGM停止（無効化済み - ホームボタンBGM切り替えのため）
  void _forceStopCurrentBgm() async {
    try {
      debugPrint('🔇 BGM停止呼び出し - 無効化済みのためスキップ');
      // await FlameAudio.bgm.stop(); // 無効化：ホームボタンでの切り替えを妨害するため
      // _isBgmPlaying = false;
      debugPrint('✅ BGM停止スキップ完了');
    } catch (e) {
      debugPrint('❌ BGM停止エラー: $e');
      // _isBgmPlaying = false;
    }
  }
  
  // 複雑フェードシステム削除 - FlameAudio公式統一により不要
  
  /// 現在の階層に応じてBGMを更新（共通関数使用）
  void _updateBgmForCurrentFloor() async {
    debugPrint('🎵 BGM更新開始: 階層=${_floorName(_currentFloor)}');
    
    // 階層に応じたBGMファイルを決定
    String? bgmFile;
    switch (_currentFloor) {
      case FloorType.floor1:
        bgmFile = 'misty_dream.mp3';
        debugPrint('🎵 1階BGM選択: 霧の中の夢');
        break;
        
      case FloorType.underground:
        bgmFile = 'swimming_fish_dream.mp3';
        debugPrint('🎵 地下BGM選択: 夢の中を泳ぐ魚');
        break;
        
      default:
        bgmFile = null; // 無音
        debugPrint('🔇 BGM選択: 無音 (${_floorName(_currentFloor)})');
        break;
    }
    
    // 共通BGM切り替え関数を使用（非同期実行で画面遷移をブロックしない）
    _switchBgmSimple(bgmFile);
    debugPrint('✅ BGM切り替え開始（階層遷移）');
  }
  
  /// 階層名を取得（デバッグ用）
  String _floorName(FloorType? floor) {
    switch (floor) {
      case FloorType.floor1:
        return '1階';
      case FloorType.underground:
        return '地下';
      case null:
        return '不明';
      default:
        return floor.toString();
    }
  }
  
  /// BGMシステムを停止（dispose時）安全な停止方法
  void _stopFloorBgmSystem() async {
    try {
      MultiFloorNavigationSystem().removeListener(_onFloorChanged);
      
      // loopLongAudioの場合はbgm.stopではなく、より安全な方法を使用
      if (_isBgmPlaying) {
        await _stopCurrentBgmSafely();
      }
      
      _isBgmPlaying = false;
      debugPrint('🔇 階層BGMシステム停止完了');
    } catch (e) {
      debugPrint('❌ BGMシステム停止エラー: $e');
    }
  }
  
  /// FlameAudio公式統一：シンプルBGM切り替え
  Future<void> _switchBgmSimple(String? newBgmFile) async {
    try {
      // 公式推奨：stop() -> play() パターン
      debugPrint('🎵 BGM切り替え開始: $_currentBgmFile -> $newBgmFile');
      await FlameAudio.bgm.stop();
      
      if (newBgmFile != null) {
        await FlameAudio.bgm.play(newBgmFile, volume: 0.5);
        _currentBgmFile = newBgmFile;
        _isBgmPlaying = true;
        debugPrint('✅ 新BGM開始: $newBgmFile');
      } else {
        _isBgmPlaying = false;
        debugPrint('🔇 BGM停止状態');
      }
    } catch (e) {
      debugPrint('❌ BGM切り替えエラー: $e');
      _isBgmPlaying = false;
    }
  }
  
  /// 公式推奨：BGM停止（無効化済み - ホームボタンBGM切り替えのため）
  Future<void> _stopCurrentBgmSafely() async {
    try {
      debugPrint('🔇 BGM停止呼び出し - 無効化済みのためスキップ');
      // await FlameAudio.bgm.stop(); // 無効化：ホームボタンでの切り替えを妨害するため
      debugPrint('✅ BGM停止スキップ完了');
    } catch (e) {
      debugPrint('⚠️ BGM停止エラー: $e');
    }
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
