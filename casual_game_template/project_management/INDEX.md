# カジュアルゲームフレームワーク開発 INDEX

## 🎯 このドキュメントの使い方
**必ず最初にこのINDEX.mdを読んでください**。プロジェクトの全体像を把握後、必要に応じて詳細ドキュメントを参照してください。

## ⚠️ 最初に確認すべきファイル
1. **../CLAUDE.md** - AI開発の基本ルール・禁止事項（プロジェクトルート）
2. **このINDEX.md** - プロジェクト全体の統合ガイド

## 📊 プロジェクト概要
- **目的**: AI支援による効率的なカジュアルゲーム開発ビジネス
- **目標**: 月4本リリース、月収30-65万円
- **技術スタック**: Flutter + Flame + Claude Code + MCP
- **現在の完成度**: 85%（実プロバイダー実装完了により大幅向上）
- **Gitブランチ**: master

## 🚨 最重要ルール（../CLAUDE.md より）
### 必須遵守事項
1. **完了判定の3ステップ必須厳守**
   - テスト実装 → テスト成功確認 → 実動作シミュレーション
   - 「テストが通ったから動く」という想定での進行は絶対禁止

2. **Jira操作時の必須ルール**
   - 事前状況報告 → ツール実行 → 結果報告（無言実行禁止）
   - ステータスID直接指定推奨（APIタイムアウト対策）

3. **品質基準**
   - 表面的解決ではなく根本原因分析必須
   - 手戻りより動かない方が良い（品質最優先）
   - 中途半端な成果物は禁止

### 禁止事項
- **曖昧表現禁止**: 「完全」「真の」「全て」「最適」等の使用禁止
- **ファイル作成原則禁止**: 既存ファイル編集を優先
- **テスト省略禁止**: 単体テスト・統合テストの省略禁止
- **推測実装禁止**: 公式ドキュメント確認せずの実装禁止

## 📁 ドキュメント構成

### 実装状況・計画
1. **current_status_checklist.md** - 現在の実装状況
   - 何が完成していて何が未完成か
   - 実装済みシステムの詳細記録
   - 完成度評価（総合85%）

2. **framework_completion_roadmap.md** - 完成への道筋
   - 残り作業の優先順位
   - 詳細なタスク分割
   - 推奨実行スケジュール

### 開発ガイド
3. **development_rules.md** - 開発ルール・禁止事項 
   - 完了判定3ステップ詳細
   - 禁止用語・表現一覧
   - 品質基準とテンプレート

4. **ai_work_instructions.md** - AI作業手順書
   - 具体的な実装手順
   - コード例とベストプラクティス
   - エラー対処法

5. **task_breakdown_details.md** - タスク詳細仕様
   - 各タスクの技術的詳細
   - 受け入れ条件
   - 実装ガイドライン

### 技術リファレンス
6. **technical_references.md** - 技術文書への参照
   - 技術仕様書一覧
   - 外部ドキュメントリンク
   - 実装時の参照順序

### プロジェクト概要
7. **README.md** - プロジェクト管理概要
   - フォルダ構成説明
   - ドキュメントの役割

### プラットフォーム設定
8. **../templates/platform_configs/** - プラットフォーム設定テンプレート
   - iOS/Android設定ファイルテンプレート
   - Firebase/Google Ads設定ガイド
   - フレームワーク統合ガイド

## 🎯 現在の最優先タスク
1. **パーティクルエフェクトシステム** - 視覚的魅力向上
2. **スコア・ランキングシステム** - ゲーム要素標準化
3. **レベル進行システム** - 難易度調整機能

## 💡 開発フロー
```
1. ../CLAUDE.md で基本ルール確認
2. このINDEX.md で全体像把握
3. current_status_checklist.md で現状確認
4. framework_completion_roadmap.md で次タスク選択
5. development_rules.md で開発ルール再確認
6. ai_work_instructions.md で実装手順確認
7. task_breakdown_details.md で詳細仕様確認
8. technical_references.md で技術情報確認（必要時）
9. ../templates/platform_configs/ でプラットフォーム設定確認（必要時）
```

## 📚 公式ドキュメント・ベストプラクティス参照

### 必須参照ドキュメント
1. **Flutter公式ドキュメント**: https://flutter.dev/docs
2. **Flame Engine公式**: https://docs.flame-engine.org/latest/
3. **Google Mobile Ads**: https://developers.google.com/admob/flutter/quick-start
4. **Firebase Analytics**: https://firebase.google.com/docs/analytics/get-started?platform=flutter
5. **audioplayers**: https://pub.dev/packages/audioplayers

### ベストプラクティス文書
- **docs/bestpractice_compliance_check.md** - Flame/Flutterベストプラクティス適合性チェック
- **docs/framework_specification.md** - フレームワーク技術仕様
- **docs/api_reference.md** - API仕様書

### コーディング規約
- **Dartコーディング規約**: https://dart.dev/guides/language/effective-dart
- **Flameゲーム開発**: https://docs.flame-engine.org/latest/flame/game.html
- **Providerパターン**: https://pub.dev/packages/provider

## 🔧 技術情報への素早いアクセス

### フレームワーク構成
- **基盤**: `lib/framework/` - ConfigurableGame、8システム統合
- **ゲーム実装**: `lib/game/` - SimpleGame実装例
- **テスト**: `test/` - 4層テスト戦略実装

### 実装済みシステム（100%完了）
- AnimationSystem（Extension Methods、Flame Effects統合）
- GoogleAdProvider（Google Mobile Ads SDK統合）
- FirebaseAnalyticsProvider（Firebase Analytics統合）
- AudioPlayersProvider（audioplayers統合）

### テスト実行コマンド
```bash
# アニメーション単体テスト
flutter test test/animation/animation_system_test.dart

# システム統合テスト
flutter test test/system/simplified_system_test.dart

# 自動ブラウザテスト
./scripts/run_automated_browser_test.sh
```

## 📝 ドキュメント更新ルール
1. 実装状況の変更 → `current_status_checklist.md` を更新
2. 新タスク追加 → `framework_completion_roadmap.md` を更新
3. 作業手順変更 → `ai_work_instructions.md` を更新
4. ルール変更 → `../CLAUDE.md` を更新後、このINDEX.mdにも反映

## 🚀 クイックスタート
AI開発者への指示例：
```
/project_management/INDEX.mdを確認して、現在の最優先タスクを実装してください。
必ず../CLAUDE.mdのルールに従ってください。
```

---
最終更新: 2025年7月31日