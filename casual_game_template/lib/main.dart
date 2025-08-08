import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';

import 'game/tap_fire_game.dart';
import 'game/framework_integration/simple_game_states.dart';

void main() {
  runApp(const CasualGameApp());
}

class CasualGameApp extends StatelessWidget {
  const CasualGameApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Casual Game Template',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChangeNotifierProvider<SimpleGameStateProvider>(
        create: (_) => SimpleGameStateProvider(),
        child: GameScreen(),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Tap Fire Game'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: GameWidget<TapFireGame>.controlled(
        gameFactory: TapFireGame.new,
        key: const ValueKey('game_canvas'),
      ),
    );
  }
}