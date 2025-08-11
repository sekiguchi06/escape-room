# AI開発マスターファイル
最終更新: 2025-08-11

## 読み込み順序
1. **[CLAUDE.md](CLAUDE.md)** - AI開発ルール・品質基準・禁止事項（厳格に厳守）
2. **このファイル** - プロジェクト情報・技術仕様・実装ガイド

## 現在の実装状況（2025年8月時点）
### ✅ 完了済み（高優先度）
1. **ConfigurableGame基盤** - Flame統合完了・安定稼働中
2. **全9システム統合** - Audio、Animation、UI、Timer、State等完成
3. **ScoreSystem完成** - スコア管理・ランキング・コンボシステム実装完了
4. **TapFireGame実装** - CasualGameTemplateの完全使用例・量産テンプレート完成
5. **テスト環境完成** - 92.2%成功率（364/395）・ブラウザシミュレーション対応
6. **🆕 QuickTemplateシステム** - 4種類のゲームテンプレート（5分で作成可能）
7. **🆕 App Store公開システム** - 脱出ゲーム"Escape Master"設定完了・テンプレート量産対応

## 次期優先タスク
1. **App Storeリリース完了** - 脱出ゲーム "Escape Master" 公開完了
2. **量産フロー実行** - テンプレートシステム活用による2本目ゲーム開発
3. **LevelSystem実装** - 難易度進行・ステージ管理システム

## プロジェクト概要
- **目的**: AI支援カジュアルゲーム開発フレームワーク
- **目標**: 月4本リリース、月収30-65万円
- **技術**: Flutter + Flame 1.30.1 + MCP
- **完成度**: 90%（主要フレームワーク完成・量産体制構築済み）
- **テスト**: 364/395成功（92.2%）

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

### 🆕 QuickTemplateシステム（5分でゲーム作成可能）
| テンプレート | ファイル | 実装例 | 主な機能 |
|-------------|---------|--------|----------|
| TapShooterTemplate | lib/framework/game_types/quick_templates/tap_shooter_template.dart | simple_tap_shooter.dart | 敵生成・タップ処理・スコア管理 |
| Match3Template | lib/framework/game_types/quick_templates/match3_template.dart | simple_match3.dart | グリッド管理・マッチ判定・連鎖処理 |
| EndlessRunnerTemplate | lib/framework/game_types/quick_templates/endless_runner_template.dart | simple_runner.dart | 自動スクロール・障害物・ジャンプ |
| EscapeRoomTemplate | lib/framework/game_types/quick_templates/escape_room_template.dart | simple_escape_room.dart | インベントリ・パズル・ホットスポット |

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

### 🆕 QuickTemplateを使った5分ゲーム作成
```dart
// 1. テンプレートを継承
class MyShooterGame extends QuickTapShooterTemplate {
  // 2. 設定のみ実装（これだけで動作！）
  @override
  TapShooterConfig get gameConfig => const TapShooterConfig(
    gameDuration: Duration(seconds: 60),
    enemySpeed: 150.0,
    maxEnemies: 6,
    targetScore: 1500,
  );
  
  // 3. オプション：イベントカスタマイズ
  @override
  void onScoreUpdated(int newScore) {
    // カスタム処理
  }
}

// 利用可能なテンプレート:
// - QuickTapShooterTemplate: タップシューティング
// - QuickMatch3Template: マッチ3パズル  
// - QuickEndlessRunnerTemplate: エンドレスランナー
// - QuickEscapeRoomTemplate: 脱出ゲーム
```

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
│   │   ├── configurable_game.dart      # 設定駆動ゲーム基底クラス
│   │   └── casual_game_extensions.dart # 拡張機能
│   ├── game_types/           # 🆕 ゲームタイプ別テンプレート
│   │   └── quick_templates/  # 5分で作成可能なクイックテンプレート
│   │       ├── tap_shooter_template.dart   # タップシューティング
│   │       ├── match3_template.dart        # マッチ3パズル
│   │       ├── endless_runner_template.dart # エンドレスランナー
│   │       └── escape_room_template.dart   # 脱出ゲーム
│   ├── animation/            # ✅ AnimationSystem（Flame Effects統合）
│   ├── audio/                # ✅ AudioSystem（BGM/SFX）
│   │   └── providers/        # FlameAudioProvider実装
│   ├── effects/              # ✅ ParticleSystem（統合完了）
│   ├── input/                # ✅ InputSystem（Flame events）
│   ├── state/                # ✅ StateSystem（状態管理）
│   ├── timer/                # ✅ TimerSystem（タイマー）
│   ├── ui/                   # ✅ UISystem（ボタン等）
│   ├── score/                # ✅ ScoreSystem（スコア・ランキング）
│   ├── persistence/          # ✅ PersistenceSystem（データ保存）
│   ├── monetization/         # ✅ AdProvider（広告）
│   │   └── providers/        # GoogleAdProvider、MockAdProvider
│   ├── analytics/            # ✅ AnalyticsProvider（分析）
│   │   └── providers/        # FirebaseAnalyticsProvider
│   ├── game_services/        # ✅ GameServices（統合サービス）
│   ├── templates/            # テンプレート例
│   │   └── platform_configs/ # 🆕 App Store公開設定テンプレート
│   ├── test_utils/           # テストユーティリティ
│   └── framework.dart        # フレームワークエクスポート
│
├── game/                      # ゲーム実装
│   ├── simple_game.dart      # メインゲームクラス（統合ポイント）
│   ├── tap_fire_game.dart    # TapFireゲーム実装例
│   ├── example_games/        # 🆕 QuickTemplate使用例
│   │   ├── simple_tap_shooter.dart  # タップシューター実装例
│   │   ├── simple_runner.dart       # ランナー実装例
│   │   ├── simple_match3.dart       # マッチ3実装例
│   │   └── simple_escape_room.dart  # 脱出ゲーム実装例
│   ├── config/               # 設定
│   │   └── game_config.dart  # 難易度設定等
│   ├── screens/              # 画面コンポーネント
│   │   └── playing_screen_component.dart   # プレイ画面
│   ├── widgets/              # UIウィジェット
│   │   ├── custom_game_ui.dart     # ゲームUI
│   │   ├── custom_start_ui.dart    # スタート画面UI
│   │   └── custom_settings_ui.dart # 設定画面UI
│   └── framework_integration/  # フレームワーク統合
│       ├── simple_game_states.dart         # 状態定義
│       └── simple_game_configuration.dart  # 設定管理
│
└── main.dart                  # エントリーポイント

test/                          # テスト（92.2%成功）
├── effects/                   # パーティクルテスト（9/9成功）
├── animation_disabled/        # アニメーションテスト（34/34成功）
├── providers/                 # プロバイダーテスト
└── ...                       # その他システムテスト

docs/                          # 🆕 App Store公開ドキュメント
├── app_store_metadata.md     # App Storeメタデータ完成版（日英対応）
├── privacy_policy.md         # プライバシーポリシー（COPPA対応）  
└── app_store_assets_checklist.md # App Store公開アセット仕様・チェックリスト

templates/                    # 🆕 App Store公開設定テンプレート
├── platform_configs/
│   ├── app_release_template.json      # 汎用設定テンプレート（量産対応）
│   ├── escape_room_release_config.json # 脱出ゲーム"Escape Master"専用設定
│   ├── ios/                          # iOS固有設定
│   ├── android/                      # Android固有設定
│   └── docs/                         # 設定ドキュメント
```

## AI開発時の更新ルール
- **実装完了時**: 「システム実装状況」の表を更新
- **タスク完了時**: 「現在の最優先タスク」を更新
- **エラー発生時**: 「よくあるエラーと対処」に追記
- **新規API追加時**: 「主要インターフェース」に追記
- **設定値変更時**: 「設定値仕様」を更新
- **品質基準変更時**: 「テスト定義・品質基準」を更新

## 最近の主な変更
- 2025-08-11: **ドキュメント修正完了** - 実装状況を実測値に更新（テスト成功率92.2%、364/395成功）・escape_room_responsive_test.dart修正完了
- 2025-08-11: **App Store公開システム完成** - 脱出ゲーム"Escape Master"設定完了・Bundle ID更新・メタデータ作成
- 2025-08-11: **量産テンプレートシステム構築** - app_release_template.json・脱出ゲーム専用設定完成
- 2025-08-11: **プライバシーポリシー・ドキュメント完備** - COPPA対応・多言語対応・App Store準拠版作成
- 2025-08-11: QuickTemplateシステム実装完了（4種類のゲームテンプレート・5分作成可能）
- 2025-08-11: プロジェクト構造整理（game_types/quick_templates追加）
- 2025-08-11: AI_MASTER.md更新（QuickTemplate詳細追加・ファイル構成更新）
- 2025-08-08: ScoreSystem完全実装（スコア管理・ランキング・コンボシステム・LocalStorageProvider）
- 2025-08-08: TapFireGame実装完了（CasualGameTemplateの完全使用例・量産テンプレート）
- 2025-08-08: CasualGameTemplateにScoreSystem統合（便利メソッド追加）
- 2024-12-10: ドキュメント構造整理（CLAUDE.md/AI_MASTER.md分離）
- 2024-12-10: UI操作正常化（ボタン専用制御、背景タップ無効化）
- 2024-08-06: テスト修正完了（92.2%成功率達成）
- 2024-07-30: AnimationSystem完全実装（Flame Effects統合）
- 2024-07-30: 実プロバイダー3種統合完了（Audio、Ad、Analytics）