import 'package:casual_game_template/framework/framework.dart';

/// 使用例: 5分で作成できるシンプルなタップシューティングゲーム
/// 
/// 作成手順:
/// 1. QuickTapShooterTemplateを継承
/// 2. gameConfigプロパティを実装
/// 3. 必要に応じてカスタムイベントをオーバーライド
class SimpleTapShooter extends QuickTapShooterTemplate {
  @override
  TapShooterConfig get gameConfig => const TapShooterConfig(
    gameDuration: Duration(seconds: 60),
    enemySpeed: 150.0,
    maxEnemies: 6,
    targetScore: 1500,
    difficultyLevel: 'normal',
  );
  
  @override
  void onScoreUpdated(int newScore) {
    // カスタムスコア処理（オプション）
    if (newScore > 500 && newScore % 500 == 0) {
      // 500点ごとに特別なエフェクト
      audioManager.playSfx('milestone');
    }
  }
  
  @override
  void onGameCompleted(int finalScore, int enemiesDestroyed) {
    // カスタムゲーム終了処理（オプション）
    if (finalScore >= gameConfig.targetScore) {
      audioManager.playSfx('victory');
    }
  }
}

/// 使用例: より難しいバージョン
class HardTapShooter extends QuickTapShooterTemplate {
  @override
  TapShooterConfig get gameConfig => const TapShooterConfig(
    gameDuration: Duration(seconds: 45),
    enemySpeed: 250.0,
    maxEnemies: 10,
    targetScore: 2000,
    difficultyLevel: 'hard',
  );
}