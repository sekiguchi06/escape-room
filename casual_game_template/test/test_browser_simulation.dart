import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'lib/framework/templates/template_example.dart';

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
  late SampleCasualGame game;

  @override
  void initState() {
    super.initState();
    // テスト用ゲーム設定
    game = SampleCasualGame(
      config: const SampleGameConfig(
        title: 'Framework Test Game',
        targetScore: 500,
        gameDuration: Duration(minutes: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // シンプルなFlameゲーム画面のみ
      body: GameWidget(game: game),
      
      // 最小限のテスト操作パネル
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                debugPrint('画面遷移テスト: Menu');
                game.stateProvider.transitionTo(SampleGameState.menu);
              },
              child: const Text('Menu'),
            ),
            ElevatedButton(
              onPressed: () {
                debugPrint('画面遷移テスト: Play');
                game.stateProvider.transitionTo(SampleGameState.playing);
              },
              child: const Text('Play'),
            ),
            ElevatedButton(
              onPressed: () {
                debugPrint('画面遷移テスト: Pause');
                game.stateProvider.transitionTo(SampleGameState.paused);
              },
              child: const Text('Pause'),
            ),
            ElevatedButton(
              onPressed: () {
                debugPrint('画面遷移テスト: Game Over');
                game.stateProvider.transitionTo(SampleGameState.gameOver);
              },
              child: const Text('Game Over'),
            ),
          ],
        ),
      ),
    );
  }
}