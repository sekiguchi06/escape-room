import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';
import 'game/simple_game.dart';
import 'game/providers/game_state_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameStateProvider(),
      child: MaterialApp(
        title: 'Tap Rush',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const GameScreen(),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SimpleGame _game;

  @override
  void initState() {
    super.initState();
    _game = SimpleGame();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ProviderをGameに設定
    final gameStateProvider = context.read<GameStateProvider>();
    _game.setProvider(gameStateProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),
          SafeArea(
            child: BackButton(
              color: Colors.white,
              onPressed: () {
                // 将来的にメニュー画面に戻る
              },
            ),
          ),
          // デバッグ情報表示
          if (true) // デバッグモード
            Positioned(
              top: 60,
              right: 10,
              child: Consumer<GameStateProvider>(
                builder: (context, gameState, child) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'State: ${gameState.currentState.name}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        Text(
                          'Timer: ${gameState.gameTimer.toStringAsFixed(1)}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        Text(
                          'Games: ${gameState.gameSessionCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}