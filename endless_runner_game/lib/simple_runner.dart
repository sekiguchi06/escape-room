import 'package:casual_game_template/framework/framework.dart';

/// 使用例: 5分で作成できるシンプルなエンドレスランナー
class SimpleRunner extends QuickEndlessRunnerTemplate {
  @override
  RunnerConfig get gameConfig => const RunnerConfig(
    gameSpeed: 200.0,
    jumpHeight: 300.0,
    gravity: 980.0,
    obstacleSpawnRate: 2.5,
    maxObstacles: 8,
    difficultyLevel: 'normal',
  );
  
  @override
  void onScoreUpdated(int newScore) {
    // カスタムスコア処理（オプション）
    if (newScore > 0 && newScore % 100 == 0) {
      // 100点ごとに音効果
      audioManager.playSfx('score_milestone');
    }
  }
  
  @override
  void onObstaclePassed(int totalPassed) {
    // 障害物通過処理（オプション）
    if (totalPassed % 10 == 0) {
      // 10個通過ごとに特別な音
      audioManager.playSfx('milestone_passed');
    }
  }
}

/// 使用例: 高速バージョン
class FastRunner extends QuickEndlessRunnerTemplate {
  @override
  RunnerConfig get gameConfig => const RunnerConfig(
    gameSpeed: 350.0,
    jumpHeight: 350.0,
    gravity: 1200.0,
    obstacleSpawnRate: 1.5,
    maxObstacles: 12,
    difficultyLevel: 'hard',
  );
}

/// 使用例: ゆっくりバージョン
class CasualRunner extends QuickEndlessRunnerTemplate {
  @override
  RunnerConfig get gameConfig => const RunnerConfig(
    gameSpeed: 120.0,
    jumpHeight: 250.0,
    gravity: 800.0,
    obstacleSpawnRate: 3.0,
    maxObstacles: 5,
    difficultyLevel: 'easy',
  );
}