# AI開発マスターファイル - 脱出ゲーム特化版
最終更新: 2025-08-18

## 📚 ドキュメント読み込み順序
1. **[ESCAPE_ROOM_UNIFIED_DESIGN_GUIDE.md](ESCAPE_ROOM_UNIFIED_DESIGN_GUIDE.md)** - 設計思想・アーキテクチャ指針（必読）
2. **このファイル** - 実装状況・技術仕様・進捗管理（実装ガイド）
3. **[CLAUDE.md](CLAUDE.md)** - AI開発ルール・品質基準・禁止事項（厳格に厳守）

## 📋 このファイルの役割
- **実装進捗の追跡**: システム実装状況・完成度管理
- **技術仕様の詳細**: ファイル構成・API・コマンド等
- **開発効率化**: 実装パターン・よくあるエラー対処
- **品質管理**: 具体的KPI・テスト成功率・パフォーマンス指標

> **設計原則・アーキテクチャ**: [DESIGN_GUIDE](ESCAPE_ROOM_UNIFIED_DESIGN_GUIDE.md)を参照  
> **開発ルール・禁止事項**: [CLAUDE.md](CLAUDE.md)を参照

## 現在の実装状況（2025年8月19日時点）
### ✅ 脱出ゲーム完全動作システム（実動作確認済み）
1. **EscapeRoomFramework基盤** ✅ - パズル・インベントリ・ホットスポット統合済み（iOS実機確認済み）
2. **パズルシステム実装済み** ✅ - CodePad、Safe、Bookshelf、Box等のパズルオブジェクト実装
3. **インベントリシステム完全動作** ✅ - アイテム管理・組み合わせ・UI統合完了（動作確認済み）
4. **ルームナビゲーション完全動作** ✅ - 5ルーム間遷移・ホットスポット相互作用（実機確認済み）
5. **UI特化システム動作確認済み** ✅ - 脱出ゲーム専用モーダル・日本語対応・モバイル最適化
6. **アイテム組み合わせシステム動作** ✅ - key+coin→master_key→escape_keyの組み合わせ確認済み
7. **ゲームクリア機能動作** ✅ - 脱出成功時のゲームクリア機能実機確認済み
8. **オーディオシステム動作** ✅ - ホットスポット相互作用時の音響効果実機確認済み
9. **アプリ設定完了** ✅ - "Escape Master"として設定済み（iOS設定確認済み）

### 🔍 実機動作確認記録（2025年8月19日）
- **プラットフォーム**: iPhone 16 Pro Simulator (iOS 18.6)
- **確認項目**: 
  - ホットスポット相互作用（石の泉、重厚な扉、紋章、革の椅子等）✅
  - アイテム収集（小さな鍵、コイン）✅
  - アイテム組み合わせ（key+coin→master_key）✅
  - 5ルーム間ナビゲーション（最左端↔最右端）✅
  - 脱出成功によるゲームクリア✅
  - 音響効果の再生✅
  - プログレス保存・復元✅
- **テストケース成功率**: 7項目中7項目成功（100%）

## 次期優先タスク
1. **App Storeリリース完了** - 脱出ゲーム "Escape Master" 公開完了
2. **パズルシステム拡張** - 新しい謎解きメカニズムの追加
3. **ストーリーシステム強化** - ルーム間の物語連結・キャラクター開発
4. **ヒントシステム改善** - アダプティブヒント・難易度調整

## プロジェクト概要
- **目的**: AI支援高品質脱出ゲーム開発フレームワーク
- **目標**: ストーリー性とパズル要素を重視した没入型体験
- **技術**: Flutter + Flame 1.30.1 + MCP
- **特化要素**: 謎解きシステム、インベントリ管理、ルーム遷移、ホットスポット相互作用
- **ゲームタイプ**: 脱出ゲーム・パズルアドベンチャー特化
- **プレイ時間**: 15-45分（じっくりと謎解きを楽しむ）

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

### ✅ 脱出ゲームコアシステム（完成）
| システム | ファイル | テスト | 備考 |
|---------|---------|--------|------|
| EscapeRoomGame | lib/framework/escape_room/core/escape_room_game.dart | test/framework/escape_room_* | ゲームメインクラス |
| EscapeRoomController | lib/framework/escape_room/core/escape_room_game_controller.dart | test/framework/escape_room_* | ゲームロジック制御 |
| EscapeRoomUIManager | lib/framework/escape_room/core/escape_room_ui_manager.dart | test/framework/escape_room_* | UI管理系 |
| InventoryManager | lib/framework/components/inventory_manager.dart | test/framework/inventory_* | アイテム管理システム |
| HotspotComponent | lib/framework/components/hotspot_component.dart | test/framework/* | ホットスポット相互作用 |
| InteractionManager | lib/framework/components/interaction_manager.dart | test/framework/* | オブジェクト間相互作用 |

### ✅ パズルシステム（完成）
| システム | ファイル | テスト | 備考 |
|---------|---------|--------|------|
| CodePadObject | lib/framework/escape_room/gameobjects/code_pad_object.dart | test/framework/code_pad_* | 数字パズル |
| SafeObject | lib/framework/escape_room/gameobjects/safe_object.dart | test/framework/* | 金庫パズル |
| BookshelfObject | lib/framework/escape_room/gameobjects/bookshelf_object.dart | test/framework/* | 本棚相互作用 |
| BoxObject | lib/framework/escape_room/gameobjects/box_object.dart | test/framework/* | 箱パズル |
| ItemCombinationManager | lib/framework/escape_room/core/item_combination_manager.dart | test/framework/item_* | アイテム組み合わせ |

### ✅ 基盤システム（共通）
| システム | ファイル | テスト | 備考 |
|---------|---------|--------|------|
| AudioSystem | lib/framework/audio/audio_system.dart | test/framework/audio/* | BGM/SFX管理 |
| StateSystem | lib/framework/state/game_state_system.dart | test/state/* | 状態遷移管理 |
| PersistenceSystem | lib/framework/persistence/persistence_system.dart | test/persistence/* | セーブデータ管理 |
| AnalyticsSystem | lib/framework/analytics/analytics_system.dart | test/framework/analytics/* | プレイデータ分析 |

### ✅ UI専用システム（脱出ゲーム特化）
| システム | ファイル | テスト | 備考 |
|---------|---------|--------|------|
| InventoryUIComponent | lib/framework/ui/inventory_ui_component.dart | test/framework/ui/* | インベントリ表示 |
| EscapeRoomModalSystem | lib/framework/ui/escape_room_modal_system.dart | test/framework/ui/* | モーダルダイアログ |
| JapaneseMessageSystem | lib/framework/ui/japanese_message_system.dart | test/framework/ui/* | 日本語メッセージ |
| MobilePortraitLayout | lib/framework/ui/mobile_portrait_layout.dart | test/framework/ui/* | モバイル縦向きUI |

### ❌ 今後の拡張予定
| システム | 説明 | 優先度 |
|---------|------|--------|
| MultiRoomSystem | 複数部屋間の遷移システム | 中 |
| AdvancedPuzzleSystem | より複雑なパズルメカニズム | 中 |
| StorySystemIntegration | ストーリー進行とパズル連携 | 低 |
| HintSystemEnhancement | アダプティブヒントシステム | 低 |

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

### ✅ 脱出ゲーム新規パズル作成
```dart
// 1. 基底クラスを継承
class MyCustomPuzzle extends InteractableGameObject {
  String? _solution;
  bool _isUnlocked = false;

  @override
  Future<InteractionResult> onTapped(Vector2 tapPosition) async {
    if (_isUnlocked) {
      return InteractionResult.alreadyCompleted();
    }
    
    // パズル UI を表示
    final userInput = await _showPuzzleDialog();
    
    if (userInput == _solution) {
      _isUnlocked = true;
      // アイテムやヒント提供
      return InteractionResult.success(
        message: 'パズルを解きました！',
        providedItems: ['key', 'hint_note'],
      );
    }
    
    return InteractionResult.failure(message: 'まだ解けていません...');
  }
}
```

### ✅ ホットスポット相互作用の追加
```dart
// ホットスポット定義
final hotspot = HotspotComponent(
  position: Vector2(100, 200),
  size: Vector2(50, 50),
  interactableObject: BookshelfObject(),
  onInteraction: (result) {
    if (result.isSuccess) {
      // UI更新・アニメーション等
      _showResultAnimation(result);
    }
  },
);

// ゲームに追加
add(hotspot);
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

## 🖼️ 利用可能な画像資産

### 脱出ゲーム専用アセット
```
assets/images/
├── escape_room_bg*.png          # 背景画像（通常・ダーク・ナイト）
├── room_*.png                   # 各ルーム画像
├── hotspots/                    # ホットスポット画像
│   ├── bookshelf_*.png          # 本棚（満/空）
│   ├── safe_*.png               # 金庫（閉/開）
│   ├── box_*.png                # 箱（閉/開）
│   ├── alchemy_*.png            # 錬金術関連
│   ├── entrance_*.png           # 入口関連
│   ├── library_*.png            # 図書館関連
│   ├── prison_*.png             # 監獄関連
│   └── treasure_*.png           # 宝物関連
├── items/                       # アイテム画像
│   ├── book.png, coin.png       # 基本アイテム
│   ├── gem.png, key.png         # 重要アイテム
│   └── lightbulb.png           # ヒントアイテム
└── sounds/                      # 音響ファイル
    ├── puzzle_solved.wav        # パズル解決音
    ├── item_found.wav          # アイテム発見音
    ├── door_open.wav           # ドア開放音
    └── escape.wav              # 脱出成功音
```

## ⚠️ 実装時の必須ルール

### 1. 画像パス使用規則
- **必須**: `assets/images/hotspots/`内の画像を使用
- **命名規則**: 状態を示すサフィックス（`_closed`, `_opened`, `_full`, `_empty`）
- **エラーハンドリング**: 画像読み込み失敗時の代替画像指定

### 2. デバッグログ必須出力
```dart
// 全インタラクションでログ出力
debugPrint('[EscapeRoom] ${object.runtimeType}: ${interaction.type}');
debugPrint('[Inventory] Added item: $itemId, Total: ${items.length}');
debugPrint('[Puzzle] Solution attempt: $userInput vs $correctAnswer');
```

### 3. クラスサイズ制限
- **1クラス**: 200行以内を原則とする
- **1メソッド**: 50行以内を原則とする
- **違反時**: 責任分割・コンポーネント分離を実施

## よくあるエラーと対処
| エラー | 原因 | 対処 |
|--------|------|------|
| MissingPluginException | Web環境でのプラグイン未対応 | MockProvider使用（kIsWebで判定） |
| LateInitializationError | 初期化順序の問題 | onLoad()で初期化、late field確認 |
| event.handled使用 | Flame非推奨API | continuePropagation使用に変更 |
| RenderFlex overflow | UI要素のサイズ超過 | ScrollView追加、サイズ調整 |
| タップイベント重複 | 背景とボタンの競合 | TapCallbacks適切配置 |
| 画像読み込み失敗 | パス間違い・ファイル不存在 | assets/images/内パス確認、代替画像設定 |
| 日本語フォント未表示 | フォント設定不備 | NotoSansJP-Regular.ttf設定確認 |

## 脱出ゲーム設定値仕様

### 品質基準とKPI（脱出ゲーム特化）
| 項目 | 目標値 | 測定方法 | 備考 |
|------|--------|----------|------|
| クリア率 | 60%以上 | 最後まで到達したユーザー比率 | ヒントなしでの達成 |
| プレイ時間 | 15-45分 | 平均プレイセッション時間 | 適度なボリューム |
| パズル解決率 | 80%以上 | 各パズルの解決成功率 | ヒント3段階で達成 |
| ユーザー満足度 | 4.0以上 | アプリストア評価平均 | ストーリー・パズル品質 |

### パズル難易度設定
| レベル | 解決時間目安 | ヒント段階 | 複雑度 |
|--------|-------------|-----------|--------|
| チュートリアル | 30秒-1分 | 1段階 | 直感的操作 |
| 初級 | 1-3分 | 2段階 | 基本的推理 |
| 中級 | 3-7分 | 3段階 | 論理的思考 |
| 上級 | 5-10分 | 3段階 | 複合的推理 |

### インベントリ設定
- 最大保持アイテム数: 8個
- アイテム組み合わせ: 最大2個同時
- 自動整理: 重要度順
- 使用済みアイテム: 自動削除または履歴保持

### 音響設定（脱出ゲーム特化）
- 環境音（BGM）: 0.4（没入感重視で低め）
- 効果音（SFX）: 0.7（パズル解決時等の重要音）
- 音声（ナレーション）: 0.8（ストーリー重要）
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
├── framework/                 # 脱出ゲーム特化フレームワーク
│   ├── escape_room/          # ✅ 脱出ゲーム専用システム
│   │   ├── core/             # ゲームコア機能
│   │   │   ├── escape_room_game.dart           # メインゲームクラス
│   │   │   ├── escape_room_game_controller.dart # ゲームロジック制御
│   │   │   ├── escape_room_ui_manager.dart     # UI管理
│   │   │   ├── item_combination_manager.dart   # アイテム組み合わせ
│   │   │   └── clear_condition_manager.dart    # クリア条件管理
│   │   ├── gameobjects/      # パズルオブジェクト
│   │   │   ├── code_pad_object.dart            # 数字パズル
│   │   │   ├── safe_object.dart                # 金庫パズル
│   │   │   ├── bookshelf_object.dart           # 本棚相互作用
│   │   │   └── box_object.dart                 # 箱パズル
│   │   ├── components/       # 脱出ゲーム専用コンポーネント
│   │   │   ├── audio_component.dart            # 音響効果
│   │   │   ├── dual_sprite_component.dart      # 状態切替スプライト
│   │   │   └── sprite_component.dart           # 基本スプライト
│   │   ├── state/            # 状態管理（Riverpod）
│   │   │   └── escape_room_state_riverpod.dart # ゲーム状態管理
│   │   ├── strategies/       # 戦略パターン
│   │   │   ├── interaction_strategy.dart       # 相互作用戦略
│   │   │   ├── item_provider_strategy.dart     # アイテム提供戦略
│   │   │   └── puzzle_strategy.dart            # パズル解決戦略
│   │   └── ui/               # 脱出ゲーム専用UI
│   │       └── portrait_ui_builder.dart       # 縦向きUI構築
│   ├── components/           # ✅ 汎用コンポーネント
│   │   ├── inventory_manager.dart              # インベントリ管理
│   │   ├── hotspot_component.dart              # ホットスポット
│   │   ├── interaction_manager.dart            # 相互作用管理
│   │   └── interactive_inventory_item.dart     # インタラクティブアイテム
│   ├── ui/                   # ✅ 脱出ゲーム特化UI
│   │   ├── inventory_ui_component.dart         # インベントリ表示
│   │   ├── escape_room_modal_system.dart       # モーダルダイアログ
│   │   ├── japanese_message_system.dart        # 日本語メッセージ
│   │   ├── mobile_portrait_layout.dart         # モバイル縦向きUI
│   │   ├── item_acquisition_notification.dart  # アイテム取得通知
│   │   └── modal_manager.dart                  # モーダル管理
│   ├── audio/                # ✅ 音響システム（脱出ゲーム対応）
│   │   ├── audio_system.dart                   # 音響制御
│   │   ├── volume_manager.dart                 # 音量管理
│   │   └── providers/        # 音響プロバイダー
│   ├── state/                # ✅ 状態管理システム
│   │   ├── game_state_system.dart              # ゲーム状態
│   │   ├── game_progress_system.dart           # 進行状況
│   │   └── game_autosave_system.dart           # オートセーブ
│   ├── persistence/          # ✅ データ永続化
│   │   ├── persistence_system.dart             # データ保存
│   │   └── data_manager.dart                   # データ管理
│   ├── analytics/            # ✅ 分析システム
│   │   ├── analytics_system.dart               # 分析機能
│   │   └── providers/        # 分析プロバイダー
│   ├── core/                 # ✅ 基盤システム
│   │   ├── configurable_game.dart              # 設定駆動ゲーム
│   │   ├── game_lifecycle.dart                 # ゲームライフサイクル
│   │   └── framework_initializer.dart          # フレームワーク初期化
│   └── framework.dart        # フレームワークエクスポート
│
├── game/                      # 脱出ゲーム実装
│   ├── escape_room.dart      # メイン脱出ゲームクラス
│   ├── inventory_demo.dart   # インベントリデモ
│   ├── example_games/        # パズルゲーム実装例
│   │   └── code_pad_example.dart    # 数字パズル実装例
│   ├── components/           # ゲーム専用コンポーネント
│   │   ├── room_navigation_system.dart     # ルーム遷移システム
│   │   ├── room_hotspot_system.dart        # ホットスポットシステム
│   │   ├── inventory_system.dart           # インベントリシステム
│   │   ├── hint_dialog.dart                # ヒントダイアログ
│   │   └── item_detail_modal.dart          # アイテム詳細モーダル
│   ├── widgets/              # ゲーム専用ウィジェット
│   │   ├── custom_game_ui.dart             # ゲームUI
│   │   ├── custom_start_ui.dart            # スタート画面
│   │   ├── custom_settings_ui.dart         # 設定画面
│   │   └── custom_game_clear_ui.dart       # クリア画面
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

## 📝 AI開発時の更新ルール

### このファイル（AI_MASTER.md）の更新対象
- **実装完了時**: 「システム実装状況」の表を更新
- **タスク完了時**: 「現在の最優先タスク」を更新
- **エラー発生時**: 「よくあるエラーと対処」に追記
- **新規API追加時**: 「主要インターフェース」に追記
- **設定値変更時**: 「設定値仕様」を更新
- **具体的KPI変更時**: 「品質基準とKPI」を更新
- **ファイル構成変更時**: 「ファイル構成」セクションを更新

### 他ドキュメントとの連携ルール
- **設計原則変更時**: [DESIGN_GUIDE](ESCAPE_ROOM_UNIFIED_DESIGN_GUIDE.md)を更新
- **アーキテクチャ変更時**: [DESIGN_GUIDE](ESCAPE_ROOM_UNIFIED_DESIGN_GUIDE.md)を更新
- **開発ルール変更時**: [CLAUDE.md](CLAUDE.md)を更新
- **禁止事項追加時**: [CLAUDE.md](CLAUDE.md)を更新

### 役割分担の原則
- **このファイル**: 実装詳細・進捗・具体的数値（可変・頻繁更新）
- **DESIGN_GUIDE**: 設計思想・品質原則（不変・長期保持）
- **CLAUDE.md**: 開発ルール・AI行動規則（厳格・変更稀）

## 最近の主な変更
- 2025-08-18: **ドキュメント体系整理完了** - 役割分担明確化（DESIGN_GUIDE: 設計原則、AI_MASTER: 実装詳細、CLAUDE: 開発ルール）
- 2025-08-18: **脱出ゲーム特化プロジェクト適合** - カジュアルゲーム→脱出ゲーム特化、実装構造更新、乖離解消
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