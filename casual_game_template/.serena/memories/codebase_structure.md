# コードベース構造

## ディレクトリ構成
```
lib/
├── framework/                 # フレームワーク本体（完成済み）
│   ├── core/                 # ConfigurableGame基盤
│   ├── animation/            # AnimationSystem（Flame Effects統合）
│   ├── audio/                # AudioSystem（BGM/SFX）
│   │   └── providers/        # FlameAudioProvider, AudioPlayersProvider
│   ├── effects/              # ParticleSystem（エフェクト管理）
│   ├── input/                # InputSystem（Flame events）
│   ├── state/                # StateSystem（状態管理）
│   ├── timer/                # TimerSystem（タイマー）
│   ├── ui/                   # UISystem（ボタン等）
│   ├── persistence/          # PersistenceSystem（データ保存）
│   ├── monetization/         # AdProvider（広告）
│   │   └── providers/        # GoogleAdProvider, MockAdProvider
│   ├── analytics/            # AnalyticsProvider（分析）
│   │   └── providers/        # FirebaseAnalyticsProvider
│   ├── score/                # ScoreSystem（スコア・ランキング・コンボ）
│   └── templates/            # テンプレート・使用例
│
├── game/                      # ゲーム実装（カスタマイズ領域）
│   ├── simple_game.dart      # メインゲームクラス
│   ├── tap_fire_game.dart    # TapFireGame完全実装例
│   ├── config/               # 設定
│   │   ├── game_config.dart  # 汎用ゲーム設定
│   │   └── tap_fire_config.dart  # TapFireGame固有設定
│   ├── screens/              # 画面コンポーネント
│   │   ├── start_screen_component.dart     # スタート画面
│   │   ├── playing_screen_component.dart   # プレイ画面  
│   │   └── game_over_screen_component.dart # ゲームオーバー画面
│   ├── framework_integration/  # フレームワーク統合
│   │   ├── simple_game_states.dart         # 状態定義
│   │   └── simple_game_configuration.dart  # 設定管理
│   └── templates/            # ゲーム別テンプレート
│       └── game_template.dart  # 新規ゲーム作成テンプレート
│
└── main.dart                  # エントリーポイント

test/                          # テスト（96.2%成功率）
├── effects/                   # パーティクルテスト
├── providers/                 # プロバイダーテスト
└── framework/                 # フレームワーク各種テスト
```

## 主要クラス関係
- **ConfigurableGame**: ゲーム基盤クラス（Flame Game継承）
- **CasualGameTemplate**: 量産用テンプレート（ConfigurableGame継承）
- **GameStateProvider**: 状態管理プロバイダー
- **GameConfiguration**: 設定管理基盤
- **ScreenFactory**: UI画面生成ファクトリ
- **ParticleEffectManager**: エフェクト管理

## 拡張パターン
1. **新ゲーム作成**: templates/template_example.dart をベースにコピー・編集
2. **設定追加**: GameConfig継承クラスでパラメータ追加
3. **UI拡張**: ScreenFactory活用で画面追加
4. **エフェクト追加**: ParticleEffectManager で新エフェクト定義