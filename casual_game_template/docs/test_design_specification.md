# テスト設計仕様書

## 概要

本ドキュメントは、カジュアルゲーム開発フレームワークにおけるテスト設計の仕様と、**単体テストとシミュレーションテストの乖離を防止する**ための必須ルールを定義します。

## 🚨 根本問題の分析

### 発生した問題
1. **単体テスト成功 → ブラウザ実行でエラー多発**
2. **Flameエンジン統合部分が未テスト**
3. **実際のゲームループやイベント処理の検証不足**
4. **依存関係やバージョン互換性の未確認**

### 根本原因
- **統合テストの不足**: 各システムを独立してテストし、Flameとの統合をテストしていない
- **実環境との差異**: テスト環境と実行環境の差異を想定していない
- **段階的検証の欠如**: 単体 → 統合 → システム → 受入れテストの段階的検証なし

## 必須テスト階層（4層テスト戦略）

### 1. 単体テスト（Unit Test）
**目的**: 個別クラス・メソッドの基本動作確認

**対象**:
- 各プロバイダー実装（AudioProvider, InputProcessor等）
- 設定クラス（Configuration）
- 状態管理クラス（StateProvider）

**制約**:
- **外部依存は全てモック化**
- **Flameエンジンとの統合は含まない**
- **実行時間: 各テスト100ms以内**

### 2. 統合テスト（Integration Test）
**目的**: システム間の連携動作確認

**対象**:
- ConfigurableGame + 各システムの統合
- **Flameエンジンとの実際の統合**
- プロバイダー間の相互作用

**必須項目**:
```dart
// 統合テストの必須パターン
test('ConfigurableGame + Flame統合テスト', () async {
  // 1. 実際のFlameGameインスタンス作成
  final game = TestGame();
  
  // 2. Flameエンジンでの初期化
  await game.onLoad();
  
  // 3. 実際のイベント処理確認
  game.onTapDown(TapDownEvent(...));
  
  // 4. フレームワークシステム連携確認
  expect(game.audioManager.isInitialized, isTrue);
  expect(game.inputManager.isInitialized, isTrue);
});
```

### 3. システムテスト（System Test）
**目的**: 完全なゲームライフサイクルの動作確認

**対象**:
- 実際のゲーム開始から終了までの全フロー
- 状態遷移の完全性
- タイマーとイベントの同期

**必須シナリオ**:
```dart
test('完全ゲームライフサイクル', () async {
  // ゲーム開始 → プレイ → ゲームオーバー → リスタート
  // 設定変更時の動作確認
  // エラー時の回復処理確認
});
```

### 4. ブラウザ自動テスト（E2E Test）
**目的**: 実ブラウザでの動作確認

**対象**:
- Chrome/Safari/Firefoxでの動作
- 実際のUI操作（flutter_driver使用）
- パフォーマンス確認

**自動化された完了条件**:
```yaml
フレームワーク初期化テスト:
  - アプリタイトル「Casual Game Template」表示: 10秒以内
  - 初期状態「TAP TO START」表示: 5秒以内
  - ゲーム開始操作後のプレイ状態移行: 1秒以内
  - タイマー動作確認: 3秒間の動作観察
  - ゲームオーバー状態検出: 10秒以内

マルチセッション実行テスト:
  - 3セッション連続実行: 各セッション15秒以内完了
  - セッション番号正確表示確認
  - 状態遷移エラー0件

設定変更サイクルテスト:
  - 4設定サイクル実行: Default→easy→hard→Default
  - 各設定表示確認: 3秒以内
  - 設定変更時のゲーム動作確認

長時間安定性テスト:
  - 2分間または8セッション実行
  - 最低3セッション完了必須
  - エラー・クラッシュ0件
  - 平均セッション時間測定

エラー発生確認テスト:
  - 連続タップストレステスト: 10回/秒
  - 高速状態変化テスト: 5サイクル
  - 最終状態正常性確認
```

## 🔒 テスト設計の必須ルール

### Rule 1: 統合テスト必須化
```yaml
単体テスト実装時の必須事項:
  - 対応する統合テストを同時作成
  - 統合テスト成功なくして単体テスト完了とみなさない
  - ConfigurableGameを継承する全クラスで統合テスト実施
```

### Rule 2: 実環境依存の明示化
```dart
// NG: 環境依存を隠蔽
test('システム動作確認', () {
  // Flameエンジンとの統合が隠蔽されている
});

// OK: 環境依存を明示
test('Flame 1.30.1統合: システム動作確認', () {
  // Flameのバージョンと統合内容を明記
});
```

### Rule 3: 段階的検証の強制
```
開発フロー（変更不可）:
  1. 単体テスト実装・成功
  2. 統合テスト実装・成功  
  3. システムテスト実装・成功
  4. ブラウザ自動テスト成功
  5. 手動ブラウザ確認
  → 全て成功で初めて完了
```

### Rule 4: バージョン固定テスト
```yaml
テスト環境設定:
  flame: "1.30.1"  # 固定バージョン
  flutter: ">=3.8.1"
  
バージョン変更時:
  - 全統合テストの再実行必須
  - 互換性問題の事前検出
```

## テストファイル構成

```
test/
├── unit/                     # 単体テスト
│   ├── audio_system_test.dart
│   ├── input_system_test.dart
│   └── ...
├── integration/              # 統合テスト  
│   ├── flame_integration_test.dart
│   ├── configurable_game_test.dart
│   └── system_integration_test.dart
├── system/                   # システムテスト
│   ├── game_lifecycle_test.dart
│   └── full_scenario_test.dart
└── e2e/                      # E2Eテスト
    ├── browser_chrome_test.dart
    └── browser_safari_test.dart
```

## 統合テスト実装テンプレート

### Flame統合テスト基本パターン
```dart
import 'package:flame_test/flame_test.dart';

void main() {
  group('Flame統合テスト', () {
    late TestGame game;
    
    setUp(() {
      game = TestGame();
    });
    
    testWithFlameGame<TestGame>('ConfigurableGame初期化', 
      (game) async {
        // 1. フレームワーク初期化確認
        expect(game.isInitialized, isTrue);
        
        // 2. 各システム初期化確認
        expect(game.audioManager, isNotNull);
        expect(game.inputManager, isNotNull);
        
        // 3. Flameコンポーネント確認
        expect(game.children.length, greaterThan(0));
      },
      setUp: (game, tester) async {
        await game.onLoad();
      }
    );
    
    testWithFlameGame<TestGame>('タップイベント統合', 
      (game) async {
        // 実際のFlameイベントでテスト
        final event = TapDownEvent(
          localPosition: Vector2(100, 100),
          // ... 実際のイベントパラメータ
        );
        
        game.onTapDown(event);
        
        // フレームワークでの処理確認
        // ゲーム固有の処理確認
      }
    );
  });
}
```

### システムテスト基本パターン
```dart
test('完全ゲームサイクル', () async {
  final game = TestGame();
  await game.onLoad();
  
  // 1. ゲーム開始
  game.startGame();
  expect(game.currentState, isA<PlayingState>());
  
  // 2. ゲームプレイ（複数フレーム実行）
  for (int i = 0; i < 60; i++) {
    game.update(1/60); // 1秒分実行
    await Future.delayed(Duration(milliseconds: 16));
  }
  
  // 3. ゲーム終了
  // 4. 設定変更
  // 5. リスタート
  
  // 各段階での状態確認
});
```

## テスト品質保証

### 必須カバレッジ
- **単体テスト**: 90%以上
- **統合テスト**: フレームワーク統合部100%
- **システムテスト**: 主要ユーザーシナリオ100%

### 実行時間制限
- **単体テスト全体**: 10秒以内
- **統合テスト全体**: 30秒以内  
- **システムテスト全体**: 60秒以内

### 成功基準
```yaml
テスト成功の定義:
  - 全階層テスト成功率: 100%
  - メモリリーク: 0件
  - 例外・エラー: 0件
  - パフォーマンス劣化: 5%以内
```

## テスト実行方法

### 自動ブラウザテスト実行
```bash
# 完全自動実行（推奨）
./scripts/run_automated_browser_test.sh

# または手動実行
flutter drive \
  --driver=test_driver/browser_simulation_test.dart \
  --target=test_driver/app.dart \
  -d chrome
```

### 手動ブラウザテスト実行
```bash
# 手動確認用（人間のテストが必要な場合）
./scripts/run_manual_browser_test.sh

# または直接実行
flutter run -d chrome
```

### 全テスト実行順序
```bash
# 推奨実行順序
flutter test test/framework_extended_test.dart          # 単体テスト
flutter test test/system/simplified_system_test.dart   # システムテスト
./scripts/run_automated_browser_test.sh                # 自動ブラウザテスト
./scripts/run_manual_browser_test.sh                   # 手動テスト（必要時）
```

## CI/CDパイプライン統合

### 自動実行フロー
```yaml
on_pull_request:
  1. 単体テスト実行
  2. 統合テスト実行
  3. システムテスト実行
  4. ブラウザ自動テスト実行
  → 全成功でマージ許可

on_main_branch:
  1. 全テスト再実行
  2. パフォーマンステスト
  3. セキュリティテスト
  → デプロイ実行
```

## 障害対応フロー

### テスト失敗時の対応
```
統合テスト失敗時:
  1. 単体テスト再確認
  2. 依存関係の確認（バージョン、インポート）
  3. Flameエンジンとの互換性確認
  4. 修正後は全階層テスト再実行
```

### 新機能追加時の必須作業
```
新システム追加時:
  1. 単体テスト作成（基本機能）
  2. 統合テスト作成（Flame統合）
  3. 既存システムとの統合テスト更新
  4. システムテストシナリオ更新
  5. ドキュメント更新
```

## 継続的改善

### 月次レビュー項目
- テスト実行時間の監視
- カバレッジ率の監視
- テスト失敗率の分析
- 新しいテストパターンの検討

### テスト技術の進化対応
- Flame新バージョン対応戦略
- Flutter新機能への対応
- テストツールの更新

---

**重要**: このテスト設計仕様書は、単体テストとシミュレーションテストの乖離を防ぐための最重要ドキュメントです。**すべての開発者が遵守**し、テスト品質の継続的向上を図ります。