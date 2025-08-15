import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import '../framework/escape_room/core/escape_room_game.dart';
import 'components/inventory_widget.dart';
import 'components/game_menu_bar.dart';
import 'components/ad_area.dart';

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
            child: Stack(
              children: [
                // 背景画像 + ゲーム本体
                Container(
                  color: Colors.black,
                  child: Stack(
                    children: [
                      // 5:8比率の背景画像を中央配置
                      Center(
                        child: AspectRatio(
                          aspectRatio: 5 / 8,
                          child: Image.asset(
                            'assets/images/escape_room_bg.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // ゲーム本体（透明背景でオーバーレイ）
                      GameWidget<EscapeRoomGame>.controlled(
                        gameFactory: EscapeRoomGame.new,
                      ),
                    ],
                  ),
                ),
                // 上部メニューバー（オーバーレイ）
                GameMenuBar(
                  onAddItem: () {
                    // TODO: アイテム追加ロジックを実装
                    debugPrint('Adding item from hint dialog');
                  },
                ),
              ],
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