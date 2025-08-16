import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flame/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';

import 'framework/ui/image_preloader.dart';
import 'game/tap_fire_game.dart';
import 'game/simple_game.dart';
import 'game/example_games/simple_tap_shooter.dart';
// import 'game/example_games/simple_escape_room.dart'; // 削除済み
import 'game/escape_room_demo.dart';
import 'game/widgets/custom_game_ui.dart';
import 'game/widgets/custom_start_ui.dart';
import 'game/widgets/custom_settings_ui.dart';
import 'game/framework_integration/simple_game_states_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: PreloadedApp(
        child: CasualGameApp(),
      ),
    ),
  );
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
        fontFamily: 'Noto Sans JP', // 日本語フォント設定（文字化け対策）
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja'), // 日本語
        Locale('en'), // 英語
      ],
      home: const GameSelectionScreen(),
    );
  }
}

class GameSelectionScreen extends ConsumerWidget {
  const GameSelectionScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final gameState = ref.watch(simpleGameStateProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(localizations?.appTitle ?? 'Casual Game Template'),
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
            // 新アーキテクチャ版
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EscapeRoomDemo(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: Text(localizations?.escapeGameTitle ?? '🔓 Play Escape Room'),
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
        }
        // SimpleEscapeRoom削除済み
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
              // SimpleGameの難易度変更処理
              {
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
        }
        // SimpleEscapeRoom削除済み
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
        }
        // SimpleEscapeRoom削除済み
        return const SizedBox.shrink();
      },
    };
  }
}