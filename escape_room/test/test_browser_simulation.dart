import 'package:flutter/material.dart';
import 'package:escape_room/game/simple_game.dart';

/// 最小限のブラウザ実動作テスト
void main() {
  runApp(const CasualGameTestApp());
}

class CasualGameTestApp extends StatelessWidget {
  const CasualGameTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Casual Game Framework Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GameTestScreen(),
    );
  }
}

class GameTestScreen extends StatefulWidget {
  const GameTestScreen({super.key});

  @override
  State<GameTestScreen> createState() => _GameTestScreenState();
}

class _GameTestScreenState extends State<GameTestScreen> {
  late SimpleGame game;

  @override
  void initState() {
    super.initState();
    // テスト用ゲーム
    game = SimpleGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Casual Game Framework Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ゲーム表示
            const Text('Simple Game Test'),
            const SizedBox(height: 20),
            // 基本的な操作ボタン
            ElevatedButton(
              onPressed: () => game.startGame(),
              child: const Text('Start Game'),
            ),
            ElevatedButton(
              onPressed: () => game.pauseGame(),
              child: const Text('Pause Game'),
            ),
            ElevatedButton(
              onPressed: () => game.resumeGame(),
              child: const Text('Resume Game'),
            ),
            ElevatedButton(
              onPressed: () => game.resetGame(),
              child: const Text('Reset Game'),
            ),
            const SizedBox(height: 20),
            // フレームワーク情報
            const Text('Framework Test - Basic Functionality Check'),
          ],
        ),
      ),
    );
  }
}
