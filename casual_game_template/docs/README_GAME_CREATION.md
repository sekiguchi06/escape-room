# 🎮 新しいゲームの作り方ガイド

## 🚀 5分でプロトタイプ作成

### Step 1: テンプレート選択

利用可能なゲームタイプ：

| ゲームタイプ | テンプレート | 特徴 |
|-------------|-------------|------|
| **タップシューティング** | `QuickTapShooterTemplate` | 敵をタップして破壊 |
| **マッチ3パズル** | `QuickMatch3Template` | 3つ揃えて消去 |
| **エンドレスランナー** | `QuickEndlessRunnerTemplate` | 障害物を避けて走行 |
| **脱出ゲーム** | `QuickEscapeRoomTemplate` | アイテムを使って脱出 |

### Step 2: 最速実装

```dart
import 'package:casual_game_template/framework/framework.dart';

class MyNewGame extends QuickTapShooterTemplate {
  @override
  TapShooterConfig get gameConfig => const TapShooterConfig(
    gameDuration: Duration(seconds: 60),
    enemySpeed: 150.0,
    targetScore: 1000,
  );
}
```

### Step 3: プロトタイプ完成！

- ゲームロジック ✅ 自動実装
- UI表示 ✅ 自動実装  
- スコアリング ✅ 自動実装
- タイマー ✅ 自動実装
- 効果音 ✅ 自動実装

## 📋 設定パラメータ一覧

### TapShooterConfig
```dart
TapShooterConfig(
  gameDuration: Duration(seconds: 60),  // ゲーム時間
  enemySpeed: 150.0,                   // 敵の速度
  maxEnemies: 5,                       // 最大敵数
  targetScore: 1000,                   // 目標スコア
  difficultyLevel: 'normal',           // 難易度
)
```

### Match3Config
```dart
Match3Config(
  gridSize: Size(8, 8),                // グリッドサイズ
  pieceTypes: ['red', 'blue', 'green'], // ピースの種類
  targetScore: 2000,                   // 目標スコア
  gameTime: Duration(minutes: 3),      // ゲーム時間
  minMatchCount: 3,                    // 最小マッチ数
)
```

### RunnerConfig
```dart
RunnerConfig(
  gameSpeed: 200.0,                    // ゲーム速度
  jumpHeight: 300.0,                   // ジャンプ高さ
  gravity: 980.0,                      // 重力
  obstacleSpawnRate: 2.0,              // 障害物生成間隔(秒)
  maxObstacles: 8,                     // 最大障害物数
)
```

### EscapeRoomConfig
```dart
EscapeRoomConfig(
  timeLimit: Duration(minutes: 10),    // 制限時間
  maxInventoryItems: 8,                // インベントリ上限
  requiredItems: ['key', 'code'],      // 必要アイテム
  roomTheme: 'office',                 // 部屋テーマ
  difficultyLevel: 1,                  // 難易度レベル
)
```

## 🎨 30分でカスタマイズ

### カスタムイベントのオーバーライド

```dart
class CustomTapShooter extends QuickTapShooterTemplate {
  @override
  TapShooterConfig get gameConfig => /* 設定 */;
  
  @override
  void onScoreUpdated(int newScore) {
    // スコア更新時のカスタム処理
    if (newScore % 500 == 0) {
      audioManager.playSfx('milestone');
    }
  }
  
  @override
  void onGameCompleted(int finalScore, int enemiesDestroyed) {
    // ゲーム完了時のカスタム処理
    if (finalScore >= gameConfig.targetScore) {
      audioManager.playSfx('victory');
    }
  }
}
```

## 🏗 2時間でフルカスタム

### 完全独自実装

```dart
class FullCustomGame extends ConfigurableGame<MyGameState, MyGameConfig> {
  // 完全な独自実装
  // 既存システムを組み合わせて使用
  
  @override
  Future<void> initializeGame() async {
    // 必要なシステムのみ追加
    add(audioManager);
    add(timerManager);
    add(scoreSystem);
    
    // 独自ゲームロジック
  }
}
```

## 📊 使用例参照

実装例は `lib/game/example_games/` に用意されています：

- `simple_tap_shooter.dart` - タップシューティング例
- `simple_match3.dart` - マッチ3パズル例
- `simple_runner.dart` - エンドレスランナー例
- `simple_escape_room.dart` - 脱出ゲーム例

## 🎯 月4本リリースのための戦略

### ゲームバリエーション作成

```dart
// 週1: 基本ゲーム
class BasicTapShooter extends QuickTapShooterTemplate { /* 基本設定 */ }

// 週2: 難易度違い  
class HardTapShooter extends QuickTapShooterTemplate { /* 高難易度設定 */ }

// 週3: テーマ違い
class SpaceTapShooter extends QuickTapShooterTemplate { /* 宇宙テーマ */ }

// 週4: ルール追加
class ComboTapShooter extends QuickTapShooterTemplate { /* コンボシステム */ }
```

## ⚡ 開発時間目安

| 段階 | 所要時間 | 成果物 |
|------|---------|--------|
| **プロトタイプ** | 5分 | 動作するゲーム |
| **カスタマイズ** | 30分 | 独自性追加 |
| **フルカスタム** | 2時間 | 完全独自ゲーム |

この構成により、**真の月4本リリース**が実現可能になります！