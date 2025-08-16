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
import 'components/flutter_particle_system.dart';
import 'components/global_tap_detector.dart';

/// 新アーキテクチャ Escape Room デモ
/// 🎯 目的: 縦画面固定設定付きブラウザ動作確認
class EscapeRoomDemo extends ConsumerStatefulWidget {
  const EscapeRoomDemo({super.key});

  @override
  ConsumerState<EscapeRoomDemo> createState() => _EscapeRoomDemoState();
}

class _EscapeRoomDemoState extends ConsumerState<EscapeRoomDemo> {
  late EscapeRoomGame _game;
  
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
  }

  @override
  void dispose() {
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
                          final currentConfig = RoomNavigationSystem().getCurrentRoomBackground(isLightOn);
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
                      child: const Center(
                        child: RoomIndicator(),
                      ),
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
}