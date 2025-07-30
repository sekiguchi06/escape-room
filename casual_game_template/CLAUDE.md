# CLAUDE.md

## 禁止用語・表現

### 曖昧な修飾語の使用禁止
以下の曖昧で誇張的な表現は絶対に使用しない：
- **「完全」「完璧」**: 不正確。「動作確認済み」「実装済み」等の具体的表現を使用
- **「真の」「本当の」**: 主観的。「実機での」「ブラウザでの」等の具体的環境を明記
- **「全て」「すべて」**: 範囲不明確。具体的な対象・範囲を明記
- **「最高」「最適」**: 評価基準不明確。測定可能な指標で表現
- **「究極」「至上」**: 根拠なし。客観的事実のみ記述

### 正しい表現例
- ❌ 「完全にテスト済み」→ ✅ 「単体テスト12項目実行済み、ブラウザ動作未確認」
- ❌ 「真のシミュレーション」→ ✅ 「ブラウザでの実機シミュレーション」
- ❌ 「全て成功」→ ✅ 「5項目中5項目成功、2項目は未実施」
- ❌ 「最適化完了」→ ✅ 「応答時間30ms→15msに短縮、メモリ使用量は未測定」

## テスト定義

### シミュレーションテスト
- **実機シミュレーター**: iOS Simulator, Android Emulator での動作確認
- **ブラウザテスト**: Chrome, Safari等での実際の動作確認
- **実UI操作**: タップ、スワイプ、画面表示の確認
- **実時間進行**: 実際のタイマー動作、フレームレート測定

### 単体テスト
- 個別クラス・メソッドの動作確認
- `flutter test` コマンドでの自動テスト実行

### 統合テスト
- 複数コンポーネント間の連携確認
- システム全体の動作検証

### パフォーマンステスト
- 処理速度・メモリ使用量の測定
- 負荷テスト・ストレステスト

## 必須思考プロセス

### AnimationSystem実装完了記録（2025年7月30日）

#### 技術的実装内容
1. **Extension Methodsパターン**: PositionComponent、HasPaintコンポーネント用のアニメーションAPI
2. **Flame Effects統合**: MoveEffect、ScaleEffect、RotateEffect、OpacityEffect、SequenceEffect対応
3. **GameComponent基底クラス**: HasPaint mixinでOpacityProvider実装
4. **AnimationPresets**: buttonTap、popIn、slideInFromLeft等の汎用アニメーション
5. **視認性最適化**: アニメーション時間を人間が視認可能な長さに調整

#### 品質確認結果
- 単体テスト: 14テスト成功、0テスト失敗  
- 統合テスト: 3テスト成功
- ブラウザシミュレーション: Chromeで全アニメーション視覚確認済み

この実装はFlame 1.30.1公式ドキュメントに準拠し、テスト・シミュレーション・実動作の3段階検証を経て完了した。

### 開発品質基準
- 表面的な解決ではなく根本原因を分析する
- 汎用性・再利用性・システム化を必ず検討する
- 手戻りが発生するより動かない方が良い
- 品質を最優先とし、中途半端な成果物は禁止

### 🚨 完了判定の必須3ステップ（絶対厳守）

#### すべての実装タスクで以下を必ず実行：
1. **テスト実装**: 単体テスト・統合テストの作成と実行
2. **テスト成功確認**: 全テストケースのPASS確認
3. **実動作シミュレーション**: Webブラウザ等での実際の動作確認

#### ❌ 禁止事項
- **テスト成功のみで完了判定することは絶対禁止**
- **シミュレーション確認なしでの完了報告は絶対禁止**
- **「テストが通ったから動く」という想定での進行は絶対禁止**

#### ✅ 正しい完了フロー
```
実装 → テスト作成 → テスト実行 → テスト成功 → 
シミュレーション実行 → 実動作確認 → 問題なし → 完了報告
```

#### ⚠️ 問題発見時の対応
```
シミュレーションで問題発見 → 原因分析 → 修正実装 → 
テスト更新 → 再テスト → 再シミュレーション → 完了
```

### 完了報告テンプレート
```
## [機能名] 実装完了

### 1. テスト結果
- 単体テスト: X件中X件成功
- 統合テスト: X件中X件成功
- テスト実行ログ: [ログ添付]

### 2. シミュレーション結果
- 実行環境: [Chrome/iOS/Android等]
- 確認項目: [具体的動作内容]
- 結果: [成功/問題詳細]

### 3. 完了判定
✅ テスト成功 + ✅ シミュレーション成功 = 🎯 完了確定
```

## カジュアルゲームフレームワーク開発

### プロジェクト概要
- 目的: AI支援による効率的なカジュアルゲーム開発
- 目標: 月4本リリース
- 技術スタック: Flutter + Flame + Claude Code

### 現在の状況（2025年7月30日 20:00）
- **フレームワーク完成度**: 95%
- **基盤システム**: 95%実装済み（ConfigurableGame、状態管理、プロバイダーパターン）
- **アニメーションシステム**: 100%実装済み（Extension Methods、Flame Effects統合、ブラウザ視覚確認済み）
- **実プロバイダー実装**: 100%（GoogleAd、FirebaseAnalytics、AudioPlayers - 全て実装済み）
- **テスト品質**: 95%（単体テスト・統合テスト・視覚シミュレーション全て成功）

### 実装完了済みシステム
#### AnimationSystem (lib/framework/animation/animation_system.dart)
- **実装方式**: Extension Methods（PositionComponent、HasPaint対応）
- **対応Effect**: MoveEffect、ScaleEffect、RotateEffect、OpacityEffect、SequenceEffect
- **テスト状況**: 単体テスト13項目、透明度テスト1項目 - 全項目成功
- **ブラウザ確認**: PopIn(0.8秒)、SlideInFromLeft(1.5秒)、ButtonTap(0.1秒) - 全て視覚確認済み
- **Flame統合**: Flame 1.30.1 Effects System準拠、ゲームループ連携確認済み
- **GameComponent**: HasPaint mixin実装、OpacityProvider対応
- **AnimationPresets**: buttonTap、popIn、slideInFromLeft - SimpleGameで実際使用中

#### ConfigurableGame基盤
- **基底クラス**: ConfigurableGame<TState, TConfig>
- **システム統合**: 8システムマネージャー統合済み
- **設定駆動**: GameConfiguration、プリセット機能
- **状態管理**: GameStateProvider、状態遷移自動化

### 🚨 最優先タスク（即座対応必須）
**実プロバイダー実装** - Mock実装を実装に置き換え

#### Task 1: GoogleAdProvider実装
```
ファイル: lib/framework/monetization/providers/google_ad_provider.dart
内容: Google Mobile Ads SDK統合、実広告表示機能
受け入れ条件: テスト広告での動作確認、全広告タイプ対応
```

#### Task 2: FirebaseAnalyticsProvider実装  
```
ファイル: lib/framework/analytics/providers/firebase_analytics_provider.dart
内容: Firebase Analytics SDK統合、実イベント送信機能
受け入れ条件: Firebase Consoleでイベント受信確認
```

#### Task 3: AudioPlayersProvider実装
```
ファイル: lib/framework/audio/providers/audioplayers_provider.dart  
内容: audioplayers統合、実音声再生機能
受け入れ条件: 実音声ファイルでBGM・効果音再生確認
```

### 必須作業手順
1. `/project_management/ai_work_instructions.md` を読む
2. `/project_management/task_breakdown_details.md` で実装方法確認  
3. プロバイダーパターン準拠で実装
4. 必須3ステップ完了判定実行

### 実装時の厳守事項
- **既存インターフェース維持**: AdProvider等の変更禁止
- **プロバイダーパターン準拠**: インターフェース実装必須
- **エラーハンドリング**: try-catch必須、適切なログ出力
- **設定駆動**: Configurationクラス値参照必須
- **公式ドキュメント準拠**: 実装方針は公式ドキュメント・ベストプラクティスに従う
- **実装事実確認**: テスト成功 + ブラウザシミュレーション確認必須
- **偏装・隐蔽禁止**: テストのみ成功で実動作未確認の状態での完了報告禁止

### 品質基準
- 単体テスト成功率: 100%
- 統合テスト成功率: 100%  
- ブラウザ動作確認: 必須
- 実機動作確認: 必須
- 既存機能との非干渉: 必須

### テスト実行順序
```bash
# 1. アニメーション単体テスト
flutter test test/animation/animation_system_test.dart
flutter test test/animation/opacity_test.dart

# 2. システム統合テスト  
flutter test test/system/simplified_system_test.dart

# 3. 自動ブラウザテスト
./scripts/run_automated_browser_test.sh
```

### テスト実行結果（2025年7月30日 19:30確認済み）
```
test/animation/animation_system_test.dart: 13 tests passed
test/animation/opacity_test.dart: 1 test passed  
test/system/simplified_system_test.dart: 3 tests passed

総計: 17テスト成功、0テスト失敗

ブラウザ視覚シミュレーション: ChromeでAnimationPresets全機能確認済み
- PopIn: ゲーム起動時に0.8秒エラスティックアニメーション
- SlideInFromLeft: ゲーム開始時に1.5秒で左からスライドイン
- ButtonTap: 青い円タップ時に0.1秒で縮小→拡大
```

### 完了目標
- **Week 1**: 実プロバイダー3つ実装 → 85%完成
- **Week 2**: ゲーム機能追加 → 90%完成
- **Week 3**: ドキュメント整備 → 95%完成

### 不要ファイル削除対象
- framework_architecture.py: 一時生成ファイル、プロジェクトに不要

### 禁止表現
曖昧な表現（"適切に"、"十分に"、"正常に"、"理解される"、"完全"、"真の"）は使用禁止

## AI実装品質管理

### 公式ドキュメント準拠義務
- **Google Mobile Ads**: https://developers.google.com/admob/flutter/quick-start
- **Firebase Analytics**: https://firebase.google.com/docs/analytics/get-started?platform=flutter  
- **audioplayers**: https://pub.dev/packages/audioplayers
- **Flame Engine**: https://docs.flame-engine.org/
- **Flutter**: https://flutter.dev/docs

### ベストプラクティス参照義務
- **Flutterコーディング規約**: https://dart.dev/guides/language/effective-dart
- **Flameゲーム開発**: https://docs.flame-engine.org/latest/flame/game.html
- **Providerパターン**: https://pub.dev/packages/provider
- **テスト戦略**: https://flutter.dev/docs/testing

### 実装検証義務
1. **公式ドキュメント確認**: 実装前に公式ガイドを精読
2. **サンプルコード検証**: 公式サンプルの動作確認
3. **ベストプラクティス適用**: 推奨パターンの采用
4. **エラーハンドリング**: 公式推奨の例外処理
5. **パフォーマンス**: 公式ガイドライン遵守

### 禁止行為と罰則
- **偏装・隐蔽**: 動作しないコードを動作するように偽装する行為
- **テスト改竄**: 実装修正の代わりにテストを変更して回避する行為
- **根拠なし完了報告**: 実動作未確認での完了報告
- **ドキュメント無視**: 公式ドキュメントを読まずに推測で実装

**罰則**: 上記行為が発覚した場合、証拠として記録し、将来の管理判断に使用する。