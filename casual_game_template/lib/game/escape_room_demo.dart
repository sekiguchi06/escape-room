import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../framework/escape_room/core/escape_room_game.dart';

/// 新アーキテクチャ Escape Room デモ
/// 🎯 目的: ブラウザでの動作確認
class EscapeRoomDemo extends StatelessWidget {
  const EscapeRoomDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escape Room - 新アーキテクチャ'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: GameWidget<EscapeRoomGame>.controlled(
        gameFactory: EscapeRoomGame.new,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('新アーキテクチャ Escape Room 動作中')),
          );
        },
        child: const Icon(Icons.info),
      ),
    );
  }
}