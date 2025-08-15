import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import '../framework/escape_room/core/escape_room_game.dart';
import 'components/inventory_widget.dart';
import 'components/game_menu_bar.dart';
import 'components/ad_area.dart';
import 'components/game_background.dart';
import 'components/lighting_system.dart';
import 'components/room_navigation_system.dart';
import 'components/room_indicator.dart';
import 'components/hotspot_display.dart';

/// 新アーキテクチャ Escape Room デモ
/// 🎯 目的: 縦画面固定設定付きブラウザ動作確認
class EscapeRoomDemo extends StatefulWidget {
  const EscapeRoomDemo({super.key});

  @override
  State<EscapeRoomDemo> createState() => _EscapeRoomDemoState();
}

class _EscapeRoomDemoState extends State<EscapeRoomDemo> {
  
  @override
  void initState() {
    super.initState();
    // 縦画面固定設定（移植ガイド準拠）
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
                    // VTR風背景画像（部屋移動・照明状態に応じて変化）
                    ListenableBuilder(
                      listenable: Listenable.merge([
                        RoomNavigationSystem(),
                        LightingSystem(),
                      ]),
                      builder: (context, _) {
                        final isLightOn = LightingSystem().isLightOn;
                        final currentConfig = RoomNavigationSystem().getCurrentRoomBackground(isLightOn);
                        return ResponsiveGameBackground(
                          config: currentConfig.copyWith(
                            topReservedHeight: menuBarHeight,
                          ),
                          bottomReservedHeight: 12, // メニューバーと同じ余白（margin: 12px）
                        );
                      },
                    ),
                    
                    // ゲーム本体（透明背景でオーバーレイ）
                    Positioned(
                      top: menuBarHeight, // 動的メニューバー高さ
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: GameWidget<EscapeRoomGame>.controlled(
                        gameFactory: EscapeRoomGame.new,
                      ),
                    ),
                    
                    // ホットスポット表示（ゲーム上部、UI下部）
                    Positioned(
                      top: menuBarHeight, // メニューバー下から
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return HotspotDisplay(
                            gameSize: Size(constraints.maxWidth, constraints.maxHeight),
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