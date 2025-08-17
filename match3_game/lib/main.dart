import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/example_games/simple_match3.dart';

void main() {
  runApp(const Match3App());
}

class Match3App extends StatelessWidget {
  const Match3App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Match3 Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: GameWidget<SimpleMatch3>.controlled(
        gameFactory: () => SimpleMatch3(),
      ),
    );
  }
}