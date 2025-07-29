import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/simple_game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tap Rush',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: SimpleGame()),
          SafeArea(
            child: BackButton(
              color: Colors.white,
              onPressed: () {
                // 将来的にメニュー画面に戻る
              },
            ),
          ),
        ],
      ),
    );
  }
}