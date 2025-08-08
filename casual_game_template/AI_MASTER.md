# AI開発マスターファイル
最終更新: 2024-12-10

## 読み込み順序
1. **CLAUDE.md** - AI開発ルール・品質基準・禁止事項（厳格に厳守）
2. **このファイル** - プロジェクト情報・技術仕様・実装ガイド

## 現在の最優先タスク
1. ✅ **ParticleSystem統合** - 完了済み（既に統合済みでした）
2. ✅ **ScoreSystem実装** - 完了済み（スコア管理・ランキング・コンボシステム）
3. ✅ **タップファイヤーゲーム実装** - 完了済み（CasualGameTemplateの完全な使用例）

## 次期優先タスク
1. **LevelSystem実装** - 難易度進行・ステージ管理システム
2. **PowerUpSystem実装** - アイテム・パワーアップシステム  
3. **量産フロー最適化** - 月4本リリース体制の構築

## プロジェクト概要
- **目的**: AI支援カジュアルゲーム開発フレームワーク
- **目標**: 月4本リリース、月収30-65万円
- **技術**: Flutter + Flame 1.30.1 + MCP
- **完成度**: 90%
- **テスト**: 351/365成功（96.2%）

## テスト定義・品質基準

### シミュレーションテスト（実動作確認）
- **実機シミュレーター**: iOS Simulator, Android Emulator での動作確認
- **ブラウザテスト**: Chrome, Safari等での実際の動作確認
- **実UI操作**: タップ、スワイプ、画面表示の確認
- **実時間進行**: 実際のタイマー動作、フレームレート測定

### 自動テスト種別
- **単体テスト**: 個別クラス・メソッドの動作確認（`flutter test`）
- **統合テスト**: 複数コンポーネント間の連携確認
- **パフォーマンステスト**: 処理速度・メモリ使用量の測定

### 品質基準（数値目標）
- 単体テスト成功率: 100%
- 統合テスト成功率: 100%
- ブラウザ動作確認: 必須
- 実機動作確認: 必須
- 既存機能との非干渉: 必須

### 必須作業手順
1. **AI_MASTER.md読み込み**（このファイル・プロジェクト情報把握）
2. **CLAUDE.md厳守確認**（開発ルール・禁止事項の再確認）
3. **プロバイダーパターン準拠実装**
4. **CLAUDE.md記載の3ステップ完了判定実行**

## システム実装状況

### ✅ 完了（100%統合済み）
| システム | ファイル | テスト | 備考 |
|---------|---------|--------|------|
| ConfigurableGame | lib/framework/core/configurable_game.dart | test/framework_core_test.dart | Flame統合基盤 |
| AnimationSystem | lib/framework/animation/animation_system.dart | test/animation_disabled/* | Flame Effects統合 |
| AudioSystem | lib/framework/audio/audio_system.dart | test/providers/flame_audio_provider_test.dart | BGM/SFX対応 |
| TimerSystem | lib/framework/timer/flame_timer_system.dart | test/timer/* | カウントダウン/アップ |
| InputSystem | lib/framework/input/flame_input_system.dart | test/input/* | Flame公式events準拠 |
| StateSystem | lib/framework/state/game_state_system.dart | test/state/* | 状態遷移管理 |
| PersistenceSystem | lib/framework/persistence/persistence_system.dart | test/persistence/* | ハイスコア保存 |
| UISystem | lib/framework/ui/ui_system.dart | test/framework/ui/* | ButtonUIComponent等 |
| AdProvider | lib/framework/monetization/providers/google_ad_provider.dart | test/providers/google_ad_provider_test.dart | Google Mobile Ads |
| AnalyticsProvider | lib/framework/analytics/providers/firebase_analytics_provider.dart | test/providers/firebase_analytics_provider_test.dart | Firebase Analytics |

### ✅ 完了（100%統合済み）
| システム | ファイル | テスト | 備考 |
|---------|---------|--------|------|
| ScoreSystem | lib/framework/score/score_system.dart | 実装完了 | スコア計算・ランキング・コンボ対応 |

### ❌ 未実装
| システム | 説明 | 優先度 |
|---------|------|--------|
| LevelSystem | 難易度進行・ステージ管理 | 中 |
| PowerUpSystem | アイテム・パワーアップ | 低 |

## 公式ドキュメント参照（AIは必要時参照）
```
Flame公式: https://docs.flame-engine.org/latest/
- TapCallbacks: /flame/inputs/tap_events.html（continuePropagation使用、event.handled禁止）
- ParticleSystem: /flame/rendering/particles.html（ParticleSystemComponent）
- RouterComponent: /flame/router.html（画面遷移）
- Effects: /flame/effects.html（MoveEffect、ScaleEffect等）

Flutter: https://flutter.dev/docs
Firebase: https://firebase.google.com/docs/analytics/get-started?platform=flutter
Google Mobile Ads: https://developers.google.com/admob/flutter/quick-start
```

## 主要インターフェース
```dart
// AudioProvider契約
abstract class AudioProvider {
  Future<void> initialize();
  Future<void> playBgm(String key, {double volume = 1.0, bool loop = true});
  Future<void> playSfx(String key, {double volume = 1.0, double volumeMultiplier = 1.0});
  Future<void> stopBgm();
  void setBgmVolume(double volume);
  void setSfxVolume(double volume);
  void dispose();
}

// AdProvider契約
abstract class AdProvider {
  Future<void> initialize();
  Future<void> showInterstitial();
  Future<void> showRewarded(Function onRewarded);
  Future<void> showBanner();
  void dispose();
}

// AnalyticsProvider契約
abstract class AnalyticsProvider {
  Future<void> initialize();
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters});
  Future<void> setUserId(String userId);
  Future<void> setUserProperty(String name, String value);
  void dispose();
}

// StorageProvider契約
abstract class StorageProvider {
  Future<void> initialize();
  Future<void> save(String key, dynamic value);
  Future<T?> load<T>(String key);
  Future<void> delete(String key);
  Future<void> clear();
}
```

## 実装パターン

### 新規画面コンポーネント（Flame公式準拠）
```dart
class NewScreenComponent extends PositionComponent with TapCallbacks {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // 1. 背景追加（タップ不可）
    final background = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.blue.withOpacity(0.3),
    );
    add(background);
    
    // 2. UIコンポーネント追加
    final button = ButtonUIComponent(
      text: 'START',
      onPressed: () => game.startGame(),
      position: Vector2(size.x / 2, size.y / 2),
    );
    add(button);
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    // デフォルトでイベント停止（continuePropagation設定なし）
    // event.handled = true; // ❌ 使用禁止（Flame非推奨）
  }
}
```

### ParticleSystem統合方法
```dart
// simple_game.dart に追加
late ParticleEffectManager _particleEffectManager;

@override
Future<void> onLoad() async {
  await super.onLoad();
  
  // パーティクルマネージャー初期化（1行追加）
  _particleEffectManager = ParticleEffectManager();
  add(_particleEffectManager);
}

// 使用例
void onFireballTapped(Vector2 position) {
  _particleEffectManager.playEffect('explosion', position: position);
  // 利用可能エフェクト: explosion, sparkle, trail, collect, damage
}
```

## よくあるエラーと対処
| エラー | 原因 | 対処 |
|--------|------|------|
| MissingPluginException | Web環境でのプラグイン未対応 | MockProvider使用（kIsWebで判定） |
| LateInitializationError | 初期化順序の問題 | onLoad()で初期化、late field確認 |
| event.handled使用 | Flame非推奨API | continuePropagation使用に変更 |
| RenderFlex overflow | UI要素のサイズ超過 | ScrollView追加、サイズ調整 |
| タップイベント重複 | 背景とボタンの競合 | TapCallbacks適切配置 |

## 設定値仕様
### 難易度設定（SimpleGameConfig）
| 項目 | Easy | Default | Hard |
|------|------|---------|------|
| gameDuration | 10秒 | 5秒 | 3秒 |
| speed | 1.0 | 1.5 | 2.0 |
| targetScore | 100 | 500 | 1000 |
| particleCount | 20 | 30 | 50 |

### タイマー種別
- `TimerType.countdown`: 残り時間表示（ゲーム終了用）
- `TimerType.countup`: 経過時間表示（プレイ時間計測）

### 音声設定
- BGM音量: 0.6（デフォルト）
- SFX音量: 0.8（デフォルト）
- マスター音量: 1.0

## コマンド一覧
```bash
# テスト実行
flutter test                                    # 全テスト実行
flutter test test/effects/                      # 特定フォルダのテスト
flutter test test/effects/particle_system_test.dart  # 特定ファイルのテスト

# ブラウザ実行
flutter run -d chrome --web-port=8080          # デバッグモード
flutter run -d chrome --web-port=8080 --release # リリースモード

# ビルド
flutter build web                              # Webビルド
flutter build ios                              # iOSビルド
flutter build apk                              # Androidビルド

# Git操作
git status                                     # 変更確認
git add .                                      # 全変更をステージング
git commit -m "feat: ParticleSystem統合"       # コミット
git push origin master                         # プッシュ
```

## ファイル構成
```
lib/
├── framework/                 # フレームワーク本体
│   ├── core/                 # ✅ ConfigurableGame基盤
│   ├── animation/            # ✅ AnimationSystem（Flame Effects統合）
│   ├── audio/                # ✅ AudioSystem（BGM/SFX）
│   │   └── providers/        # FlameAudioProvider実装
│   ├── effects/              # ⚠️ ParticleSystem（未統合）
│   ├── input/                # ✅ InputSystem（Flame events）
│   ├── state/                # ✅ StateSystem（状態管理）
│   ├── timer/                # ✅ TimerSystem（タイマー）
│   ├── ui/                   # ✅ UISystem（ボタン等）
│   ├── persistence/          # ✅ PersistenceSystem（データ保存）
│   ├── monetization/         # ✅ AdProvider（広告）
│   │   └── providers/        # GoogleAdProvider、MockAdProvider
│   └── analytics/            # ✅ AnalyticsProvider（分析）
│       └── providers/        # FirebaseAnalyticsProvider
│
├── game/                      # ゲーム実装
│   ├── simple_game.dart      # メインゲームクラス（統合ポイント）
│   ├── config/               # 設定
│   │   └── game_config.dart  # 難易度設定等
│   ├── screens/              # 画面コンポーネント
│   │   ├── start_screen_component.dart     # スタート画面
│   │   ├── playing_screen_component.dart   # プレイ画面
│   │   └── game_over_screen_component.dart # ゲームオーバー画面
│   └── framework_integration/  # フレームワーク統合
│       ├── simple_game_states.dart         # 状態定義
│       └── simple_game_configuration.dart  # 設定管理
│
└── main.dart                  # エントリーポイント

test/                          # テスト（96.2%成功）
├── effects/                   # パーティクルテスト（9/9成功）
├── animation_disabled/        # アニメーションテスト（34/34成功）
├── providers/                 # プロバイダーテスト
└── ...                       # その他システムテスト
```

## AI開発時の更新ルール
- **実装完了時**: 「システム実装状況」の表を更新
- **タスク完了時**: 「現在の最優先タスク」を更新
- **エラー発生時**: 「よくあるエラーと対処」に追記
- **新規API追加時**: 「主要インターフェース」に追記
- **設定値変更時**: 「設定値仕様」を更新
- **品質基準変更時**: 「テスト定義・品質基準」を更新

## 最近の主な変更
- 2025-08-08: ScoreSystem完全実装（スコア管理・ランキング・コンボシステム・LocalStorageProvider）
- 2025-08-08: TapFireGame実装完了（CasualGameTemplateの完全使用例・量産テンプレート）
- 2025-08-08: CasualGameTemplateにScoreSystem統合（便利メソッド追加）
- 2024-12-10: ドキュメント構造整理（CLAUDE.md/AI_MASTER.md分離）
- 2024-12-10: UI操作正常化（ボタン専用制御、背景タップ無効化）
- 2024-08-06: テスト修正完了（96.2%成功率達成）
- 2024-07-30: AnimationSystem完全実装（Flame Effects統合）
- 2024-07-30: 実プロバイダー3種統合完了（Audio、Ad、Analytics）