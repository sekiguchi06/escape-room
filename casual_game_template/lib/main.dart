import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';

import 'game/simple_game.dart';
import 'game/framework_integration/simple_game_states.dart';

void main() {
  runApp(CasualGameApp());
}

class CasualGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Casual Game Framework Demo',
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GameWidget<SimpleGame>.controlled(
        gameFactory: SimpleGame.new,
      ),
    );
  }
}