# カジュアルゲーム開発現状分析

## 現在の実装状況

### 動作中の実装: SimpleGame
- **ファイル**: `lib/game/simple_game.dart`
- **状態管理**: `enum SimpleGameState { start, playing, gameOver }`
- **フロー**: スタート画面 → ゲーム(5秒) → ゲームオーバー → リスタート
- **技術スタック**: Flutter + Flame 1.30.1 + TapDetector

```dart
class SimpleGame extends FlameGame with TapDetector {
  SimpleGameState currentState = SimpleGameState.start;
  double gameTimer = 5.0;
  late TextComponent stateText;
  
  // 状態遷移メソッド
  void _startGame() { currentState = SimpleGameState.playing; }
  void _goToGameOver() { currentState = SimpleGameState.gameOver; }
  void _restart() { _startGame(); }
}
```

## 技術選択の経緯と検証

### 成功した選択
1. **TapDetector使用継続**
   - **判断**: Flame 1.30.1で実際に動作確認済み
   - **根拠**: ソースコード(`~/.pub-cache/.../flame-1.30.1/lib/events.dart`)でexport確認
   - **結果**: 安定動作

2. **シンプルな状態管理**
   - **判断**: enum + switch文による直接制御
   - **根拠**: 3状態のみなので複雑なパターン不要
   - **結果**: 理解しやすく保守可能

### 失敗した試行
1. **RouterComponent導入失敗**
   - **問題**: タイマーリセット機能が動作不能
   - **原因**: 複雑なライフサイクル管理により状態同期困難
   - **教訓**: 要件に対して過剰なアーキテクチャは有害

2. **TapCallbacks移行失敗**
   - **問題**: `HasTapCallbacks`API不存在
   - **原因**: 推測による技術判断（実際の確認不足）
   - **教訓**: API変更主張時は必ずソースコード確認

## 現在の技術的問題

### 拡張性の課題
- **状態管理**: enum方式は状態数増加時に破綻
- **コンポーネント管理**: 単一TextComponent、複数要素追加困難
- **責務集中**: 全ロジックが単一クラスに集約
- **再利用性**: ゲーム固有実装、他ゲームへの流用困難

### 品質面の問題
- **テスト困難**: 状態とUIが密結合
- **デバッグ困難**: 状態遷移ロジックが散在
- **パフォーマンス**: 将来的なオブジェクト数増加への対応不明

## 提案された汎用設計

### 設計原則
1. **設定駆動**: ゲームルールを外部設定化
2. **責務分離**: 状態管理・表示・入力を独立クラス化  
3. **イベント駆動**: 疎結合なコンポーネント通信
4. **コンポーネント指向**: 機能を再利用可能な部品化
5. **テンプレート化**: 共通パターンの標準化

### 核となるアーキテクチャ
```dart
class UniversalCasualGame extends FlameGame {
  final GameConfig config;
  final EventBus eventBus;
  final GameStateMachine stateMachine;
  final List<GameComponent> components;
}

abstract class GameComponent {
  void initialize(GameContext context);
  void update(double dt, GameContext context);
  void handleEvent(GameEvent event);
}
```

### 期待効果
- **開発効率**: 新ゲーム作成時間 7日 → 2日
- **品質向上**: 共通コンポーネントの一元テスト
- **保守性**: 責務分離による変更影響限定
- **目標達成**: 月4本リリース体制の実現

## 次のステップ

### Phase 1: 現状検証
- Flame/Flutterベストプラクティスとの照合
- リファレンス文書との整合性確認
- 技術選択の妥当性検証

### Phase 2: 段階的改善
1. EventBus導入
2. Component分離  
3. 設定駆動化
4. テンプレート化

### Phase 3: 本格運用
- 新ゲーム開発フローの確立
- 品質指標の設定・測定
- 月4本リリース体制の構築

## 重要な教訓

### 技術判断プロセス
1. **実装前確認**: 公式ドキュメント・ソースコード確認必須
2. **推測の排除**: 「一般的に」「おそらく」等の表現禁止
3. **段階的検証**: 最小変更での動作確認優先
4. **根拠の明示**: 技術選択理由の文書化

### 失敗から学んだルール
- 動作するコード > 理論的に正しいコード > 非動作のベストプラクティス
- API存在確認なしに「非推奨」判断禁止
- 複雑なアーキテクチャ導入前に要件適合性検証必須

## 現在の開発環境

- **Flutter SDK**: 3.8.1+
- **Flame Engine**: 1.30.1
- **開発OS**: macOS (Darwin 24.5.0)
- **テスト環境**: iOS Simulator (iPhone 15)
- **エディタ**: Claude Code CLI環境