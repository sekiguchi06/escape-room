import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// デバッグ情報表示コンポーネント
class DebugInfoComponent extends TextComponent {
  final dynamic game;

  DebugInfoComponent({required this.game, super.position})
    : super(
        text: '',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
      );

  @override
  void update(double dt) {
    super.update(dt);

    // ゲーム情報の更新
    final buffer = StringBuffer();

    if (game.runtimeType.toString().isNotEmpty) {
      buffer.writeln('Game: ${game.runtimeType}');
    }

    // 初期化状態
    if (game.isInitialized != null) {
      buffer.writeln('Initialized: ${game.isInitialized}');
    }

    // 現在の状態
    if (game.currentState != null) {
      buffer.writeln('State: ${game.currentState}');
    }

    // タイマー情報
    if (game.timerManager != null) {
      final runningTimers = game.timerManager.getRunningTimerIds();
      buffer.writeln('Active Timers: ${runningTimers.length}');
    }

    text = buffer.toString();
  }
}

/// デバッグ設定とユーティリティ
class DebugUtils {
  /// デバッグコンポーネントを追加
  static void setupDebugging(Component game, bool debugMode) {
    if (!debugMode) return;

    // FPS表示
    game.add(FpsTextComponent(position: Vector2(10, 10)));

    // ゲーム情報表示
    game.add(DebugInfoComponent(game: game, position: Vector2(10, 40)));
  }

  /// デバッグ情報のログ出力
  static void logDebugInfo(dynamic game) {
    debugPrint('🔧 Debug Info:');
    debugPrint('  Game Type: ${game.runtimeType}');
    debugPrint('  Initialized: ${game.isInitialized ?? 'unknown'}');
    debugPrint('  Current State: ${game.currentState ?? 'unknown'}');

    if (game.timerManager != null) {
      final timers = game.timerManager.getTimerIds();
      debugPrint('  Timers: ${timers.length} (${timers.join(', ')})');
    }
  }
}
