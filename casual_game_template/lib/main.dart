import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';

import 'game/tap_fire_game.dart';
import 'game/simple_game.dart';
import 'game/example_games/simple_tap_shooter.dart';
import 'game/example_games/simple_escape_room.dart';
import 'game/widgets/custom_game_ui.dart';
import 'game/widgets/custom_start_ui.dart';
import 'game/widgets/custom_settings_ui.dart';
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
        child: const GameSelectionScreen(),
      ),
    );
  }
}

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Casual Game Template'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // コメントアウト: 他のゲーム（App Store公開はEscape Gameのみ）
            /*
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GameScreen<TapFireGame>(
                      gameTitle: 'Tap Fire Game',
                      gameFactory: TapFireGame.new,
                    ),
                  ),
                );
              },
              child: const Text('Play Tap Fire Game'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GameScreen<SimpleGame>(
                      gameTitle: 'Simple Game',
                      gameFactory: SimpleGame.new,
                    ),
                  ),
                );
              },
              child: const Text('Play Simple Game'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GameScreen<SimpleTapShooter>(
                      gameTitle: 'Simple Tap Shooter',
                      gameFactory: SimpleTapShooter.new,
                    ),
                  ),
                );
              },
              child: const Text('Play Simple Tap Shooter'),
            ),
            */
            // App Store公開用: Escape Room Game
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GameScreen<SimpleEscapeRoom>(
                      gameTitle: 'Escape Room Adventure',
                      gameFactory: SimpleEscapeRoom.new,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('🔓 Play Escape Room'),
            ),
          ],
        ),
      ),
    );
  }
}

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(gameTitle),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
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
        if (game is SimpleGame) {
          return CustomStartUI(
            title: 'Simple Game',
            onStartPressed: () {
              game.startGame();
            },
            onSettingsPressed: () {
              game.showSettingsUI();
            },
          );
        } else if (game is TapFireGame) {
          return CustomStartUI(
            title: 'Tap Fire Game',
            onStartPressed: () {
              game.resetGame();
            },
            onSettingsPressed: () {
              game.showSettingsUI();
            },
          );
        } else if (game is SimpleTapShooter) {
          return CustomStartUI(
            title: 'Simple Tap Shooter',
            onStartPressed: () {
              game.startGame();
            },
            onSettingsPressed: () {
              // 設定は後で実装
            },
          );
        } else if (game is SimpleEscapeRoom) {
          return CustomStartUI(
            title: 'Escape Room Adventure',
            onStartPressed: () {
              game.startGame();
            },
            onSettingsPressed: () {
              // 脱出ゲーム設定（後で実装）
            },
          );
        }
        return const SizedBox.shrink();
      },
      'settingsUI': (context, game) {
        if (game is SimpleGame) {
          return CustomSettingsUI(
            onClosePressed: () {
              game.hideSettingsUI();
            },
            onDifficultyChanged: (difficulty) {
              // SimpleGameの難易度変更を実際に適用
              if (game is SimpleGame) {
                game.applyDifficultyConfiguration(difficulty);
              }
            },
          );
        } else if (game is TapFireGame) {
          return CustomSettingsUI(
            onClosePressed: () {
              game.hideSettingsUI();
            },
            onDifficultyChanged: (difficulty) {
              // TapFireGameの難易度変更処理
              debugPrint('🔥 Difficulty changed to: $difficulty');
            },
          );
        }
        return const SizedBox.shrink();
      },
      'gameUI': (context, game) {
        if (game is TapFireGame) {
          return CustomGameUI(
            score: game.score,
            timeRemaining: game.formatTime(game.gameTimeRemaining),
            isGameActive: game.gameActive,
            onPausePressed: () {
              if (game.gameActive) {
                game.pauseGame();
              } else {
                game.resumeGame();
              }
            },
            onRestartPressed: () {
              game.restartFromGameOver();
            },
          );
        } else if (game is SimpleGame) {
          return CustomGameUI(
            score: game.score,
            timeRemaining: game.formatTime(game.gameTimeRemaining),
            isGameActive: game.gameActive,
            onPausePressed: () {
              if (game.gameActive) {
                game.pauseGame();
              } else {
                game.resumeGame();
              }
            },
            onRestartPressed: () {
              game.restartFromGameOver();
            },
          );
        } else if (game is SimpleTapShooter) {
          return CustomGameUI(
            score: game.score,
            timeRemaining: game.formatTime(game.gameTimeRemaining),
            isGameActive: game.gameActive,
            onPausePressed: () {
              if (game.gameActive) {
                game.pauseGame();
              } else {
                game.resumeGame();
              }
            },
            onRestartPressed: () {
              game.resetGame();
            },
          );
        } else if (game is SimpleEscapeRoom) {
          return CustomGameUI(
            score: game.puzzlesSolved,
            timeRemaining: game.formatTime(game.timeRemaining),
            isGameActive: game.gameActive,
            onPausePressed: () {
              // 脱出ゲームのポーズ機能（後で実装）
            },
            onRestartPressed: () {
              game.resetGame();
            },
          );
        }
        return const SizedBox.shrink();
      },
      'gameOverUI': (context, game) {
        if (game is TapFireGame) {
          return CustomGameOverUI(
            finalScore: game.score,
            onRestartPressed: () {
              game.restartFromGameOver();
            },
            onMenuPressed: () {
              Navigator.of(context).pop();
            },
          );
        } else if (game is SimpleGame) {
          return CustomGameOverUI(
            finalScore: game.score,
            onRestartPressed: () {
              game.restartFromGameOver();
            },
            onMenuPressed: () {
              Navigator.of(context).pop();
            },
          );
        } else if (game is SimpleTapShooter) {
          return CustomGameOverUI(
            finalScore: game.score,
            onRestartPressed: () {
              game.resetGame();
            },
            onMenuPressed: () {
              Navigator.of(context).pop();
            },
          );
        } else if (game is SimpleEscapeRoom) {
          return CustomGameOverUI(
            finalScore: game.puzzlesSolved,
            onRestartPressed: () {
              game.resetGame();
            },
            onMenuPressed: () {
              Navigator.of(context).pop();
            },
          );
        }
        return const SizedBox.shrink();
      },
    };
  }
}