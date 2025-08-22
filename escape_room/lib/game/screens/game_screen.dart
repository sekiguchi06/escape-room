import 'package:flutter/material.dart';
import 'package:flame/game.dart';

class GameScreen<T extends Game> extends StatelessWidget {
  final String gameTitle;
  final T Function() gameFactory;

  const GameScreen({
    super.key,
    required this.gameTitle,
    required this.gameFactory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(gameTitle),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: GameWidget<T>.controlled(
        gameFactory: gameFactory,
        key: ValueKey('${gameTitle}_canvas'),
        overlayBuilderMap: _buildOverlayMap(),
      ),
    );
  }

  Map<String, Widget Function(BuildContext, T)> _buildOverlayMap() {
    return {
      'startUI': (context, game) {
        return const SizedBox.shrink();
      },
      'settingsUI': (context, game) {
        return const SizedBox.shrink();
      },
      'gameUI': (context, game) {
        return const SizedBox.shrink();
      },
      'gameOverUI': (context, game) {
        return const SizedBox.shrink();
      },
    };
  }
}
