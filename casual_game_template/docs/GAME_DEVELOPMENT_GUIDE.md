# カジュアルゲーム開発ガイド

## 📝 設計テンプレート

### 1. 基本情報
- **名称**: [ゲーム名]
- **ジャンル**: [アクション/パズル/リズム等]
- **プレイ時間**: [30-90秒推奨]
- **操作**: [タップ/スワイプ等]
- **コアループ**: `[入力] → [処理] → [結果] → [報酬] → [繰り返し]`

### 2. ゲームルール
- **目的**: [1文で説明]
- **勝利条件**: [明確な条件]
- **終了条件**: [時間/回数/失敗]
- **スコア計算**: [基本点×係数]

### 3. 必要コンポーネント
```
主要オブジェクト: [名前]
- 動作: [移動パターン]
- サイズ: [大/中/小]
- 判定: [円形/矩形]
- 入力処理: [タップ時の処理内容]
```

### 4. 設定パラメータ
| パラメータ | Easy | Normal | Hard |
|------------|------|--------|------|
| 制限時間 | 60秒 | 45秒 | 30秒 |
| 速度係数 | 0.8x | 1.0x | 1.5x |
| サイズ係数 | 1.5x | 1.0x | 0.7x |
| 基本スコア | 10点 | 15点 | 25点 |

---

## 🚀 実装ガイド（20分）

### Step 1: ファイル作成（2分）
```bash
touch lib/game/your_game.dart
touch lib/game/config/your_game_config.dart
```

### Step 2: 基本実装（15分）

**設定クラス**
```dart
class YourGameConfig {
  final int gameDuration;
  final double speedMultiplier;
  final double sizeMultiplier;
  final int baseScore;
  
  const YourGameConfig({
    this.gameDuration = 45,
    this.speedMultiplier = 1.0,
    this.sizeMultiplier = 1.0,
    this.baseScore = 15,
  });
  
  static const easy = YourGameConfig(
    gameDuration: 60, speedMultiplier: 0.8, 
    sizeMultiplier: 1.5, baseScore: 10,
  );
  static const normal = YourGameConfig();
  static const hard = YourGameConfig(
    gameDuration: 30, speedMultiplier: 1.5,
    sizeMultiplier: 0.7, baseScore: 25,
  );
}
```

**メインゲーム**
```dart
class YourGame extends ConfigurableGame<GameState, YourGameConfig> with TapCallbacks {
  int score = 0;
  double timeRemaining = 0;
  
  YourGame({YourGameConfig? config}) : super(
    configuration: YourGameConfiguration(config ?? const YourGameConfig()),
  )
  
  @override
  GameStateProvider<GameState> createStateProvider() {
    return SimpleGameStateProvider();
  }
  
  @override
  Future<void> onLoad() async {
    timeRemaining = configuration.config.gameDuration.toDouble();
    // オブジェクト生成ロジック
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    timeRemaining -= dt;
    if (timeRemaining <= 0) {
      // ゲーム終了処理
    }
  }
  
  @override
  void onTapDown(TapDownEvent event) {
    score += configuration.config.baseScore;
  }
}
```

### Step 3: 起動確認（3分）
```bash
flutter run -d chrome
```

---

## ✅ 設計チェックリスト

### 必須確認項目
- [ ] ゲーム名が決定済み
- [ ] 30-90秒でプレイ完結
- [ ] 操作は1-2種類のみ
- [ ] ルールが1文で説明可能
- [ ] 主要オブジェクト定義済み
- [ ] 入力処理が明確
- [ ] スコア計算式が決定済み
- [ ] 終了条件が明確
- [ ] Easy/Normal/Hard の3段階
- [ ] 各パラメータに数値設定済み
- [ ] 20分以内で実装可能な規模
- [ ] テスト方法が明確

**80%以上チェック済みで実装開始可能**

---

## 💡 設計例（3ジャンル）

### アクション例：タップディフェンス
- **コアループ**: `敵出現 → タップ撃退 → スコア獲得 → 次の敵`
- **設定値**: 敵速度 60/80/120px/s、敵サイズ 50/40/30px

### パズル例：カラーマッチ  
- **コアループ**: `色提示 → 同色選択 → 消去 → 新規生成`
- **設定値**: 色数 3/4/5色、グリッド 4×4/5×5/6×6

### リズム例：ビートタップ
- **コアループ**: `ビート表示 → タイミングタップ → 判定 → スコア`
- **設定値**: BPM 60/120/180、判定幅 ±150/100/50ms

---

## ⚠️ よくあるエラーと対処法

| エラー | 原因 | 解決法 |
|--------|------|--------|
| TapDownInfo not found | Flame古いバージョン | TapDownEvent使用 |
| extends vs implements | 継承ミス | extends使用 |
| late initialization | 初期化順序 | onLoadで初期化 |

---

**このガイド1つで設計から実装まで完結。20分で新ゲーム作成可能。**