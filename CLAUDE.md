# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains a complete Flutter + Flame casual game development framework with 90% implementation completion and 96.2% test success rate. The main project is located in the `casual_game_template/` directory.

## MCP Configuration

The repository has the following MCP servers configured:

1. **Atlassian MCP Server**: Provides access to Jira and Confluence APIs
   - Configuration in `.mcp.json` and `.claude/claude_project_config.json`
   - Enables operations like searching Jira issues, creating/updating issues, and working with Confluence pages

## Available MCP Tools

When working in this repository, you have access to Atlassian tools:
- `mcp__atlassian__getAccessibleAtlassianResources`: Get available Atlassian cloud instances
- `mcp__atlassian__searchJiraIssuesUsingJql`: Search Jira issues using JQL
- Other Atlassian tools for creating/updating issues and working with Confluence

## Development Guidelines

Since this is a new repository, when setting up a project:

1. **Project Initialization**: Document the project type and setup commands in this file
2. **Build Commands**: Add common build, test, and lint commands as they are established
3. **Architecture**: Document high-level architecture decisions as the codebase grows

## Current Permissions

The `.claude/settings.local.json` file allows various operations including:
- File system operations (ls, mkdir, find, cat, rm)
- Claude CLI operations
- Brew package management
- Web fetching from docs.anthropic.com
- Atlassian MCP operations

## Jira操作効率化
- 単純なJiraステータス更新はTodoWriteツールを使用せず即座に実行する
- 作業完了時は「完了」ではなく「レビュー中」ステータスに変更する

## 🚨 Jiraツール実行時停止問題の対策 (緊急対応)

### 根本原因
1. **MCPサーバー応答遅延**: Atlassian APIの不安定な応答時間
2. **大容量レスポンス**: Jiraコメント/履歴データの処理負荷
3. **ネットワークタイムアウト**: 接続タイムアウトによる無応答状態
4. **JSON解析負荷**: 複雑なJiraデータ構造の解析時間

### 必須実行ルール（停止防止）
1. **事前状況報告**: Jiraツール実行前に「実行中...」と報告
2. **段階的実行**: 大きな操作を小分けして実行
3. **タイムアウト設定**: 長時間応答がない場合の早期終了
4. **フォールバック**: エラー時の代替手段を準備
5. **定期報告**: 実行中の進捗を定期的に報告

### Jiraツール実行時の必須パターン
```
1. 「Jiraツール実行開始: [操作内容]」と報告
2. ツール実行
3. 結果に関わらず「実行完了」または「エラー発生」を報告
4. エラー時は即座にフォールバックアクション実行
```

### 禁止事項
- **絶対に無言でツール実行禁止**
- **応答なしでの長時間待機禁止**
- **エラー時の放置禁止**

### 具体的実装パターン
#### コメント追加時
```
1. 「Jiraコメント追加実行中: CYIM-XXX」
2. mcp__atlassian__addCommentToJiraIssue実行
3. 成功: 「コメント追加完了」/ 失敗: 「エラー発生、手動確認要」
```

#### 大容量データ取得時
```
1. 「Issue詳細取得中（大容量データ警告）: CYIM-XXX」
2. 制限付きフィールド指定でmcp__atlassian__getJiraIssue実行
3. 必要に応じて追加データを段階的取得
```

### エラー時フォールバック戦略
1. **一次対応**: エラーメッセージの即座報告
2. **二次対応**: 手動操作の代替手順提示
3. **三次対応**: Jira Web UIでの直接操作指示

### 実行前チェックリスト
- [ ] 事前状況報告済み
- [ ] 必要最小限のデータ要求
- [ ] フォールバック手順準備済み
- [ ] タイムアウト対策設定済み

## 必須思考プロセス

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

### ステータスID一覧
- **To Do**: ID = 10003（英語名: "To Do"）
- **進行中**: ID = 10004（英語名: "In Progress"）
- **レビュー中**: ID = 10042（英語名: 表示なし、カテゴリは"進行中"）
- **完了**: ID = 10005（英語名: "Done"）

### ステータス遷移ID
- To Do → 進行中: transition id "3"
- 進行中 → レビュー中: transition id "4"  
- レビュー中 → 完了: transition id "5"
- レビュー中 → 進行中（差し戻し）: transition id "2"

### JQL検索の必須ルール
- **ステータスID直接指定を推奨**
  - ✅ status = 10004（進行中）
  - ✅ status IN (10003, 10004, 10005)
  - ✅ status = 10042（レビュー中）
- **英語名使用時の注意**
  - ✅ status = "In Progress"
  - ✅ status IN ("To Do", "In Progress", "Done")
  - ❌ status = "進行中"（APIタイムアウトの原因）
  - ❌ status IN ("To Do", "進行中")（複合時に不安定）
- **タイムアウト対策**
  - ID指定が最も高速・安定
  - 複雑なJQLは段階的に実行
  - OR/IN句は英語名またはIDで構成

### 厳密なステータス遷移条件

#### 進行中 → レビュー中の条件
- **status-validator agentによる判定必須**
- **受け入れ条件100%達成必須**（human-intervention-requiredラベルなしの場合）
- **human-intervention-requiredラベルありの場合**:
  - AI実行可能部分が100%完了
  - 人間介入箇所が明確に文書化
  - 進行中維持（レビュー移行禁止）
- 部分達成でのレビュー移行は禁止
- 制約により完了不可能な場合はタスク分解が必要
- 定量的達成率を計算し80%未満は自動差し戻し

#### レビュー中 → 完了の条件  
- **status-validator agentによる最終確認必須**
- 品質基準の全項目クリア
- 実際の動作確認完了
- ドキュメント更新完了
- 副作用・影響範囲の確認完了

### 共通タスク受け入れ条件定義

#### 全タスク共通基準
1. **完了定義**: タスクが100%完了したかを数値・ファイル存在・動作確認で判定可能
2. **品質基準**: エラー0件、必須項目100%実装、基準値達成
3. **検証方法**: 自動確認コマンドまたは3ステップ以内の手動手順
4. **成果物**: 具体的ファイル・データ・状態変更が存在
5. **整合性**: 既存システム・文書との矛盾なし

#### タスクタイプ別基準

**ドキュメント作成**
- ファイル存在確認: `ls ファイルパス`
- 最小サイズ: 文字数または行数指定
- 必須セクション: セクション名を明記
- 検索確認: `grep キーワード ファイル`

**コード実装**  
- ファイル存在確認: 実装ファイルとテストファイル
- コンパイル: `ビルドコマンド` でエラー0件
- テスト: `テストコマンド` で成功率100%
- 動作確認: 3ステップ以内の手動テスト手順

**設定変更**
- 設定値確認: `設定確認コマンド` で変更値表示
- 動作確認: 設定適用後の動作テスト手順
- 副作用確認: 他機能への影響チェック項目

**調査・分析**
- 調査結果: データファイルまたはレポートファイル存在
- 必須情報: 収集すべき情報項目を明記
- 根拠: 情報源URLまたはファイル参照

#### 禁止表現
曖昧な表現（"適切に"、"十分に"、"正常に"、"理解される"）は使用禁止

## Jiraラベルシステム

### 使用ラベル：1つのみ
- **human-intervention-required**: 人間の介入が必須のタスク

### ラベル判定基準
以下のいずれかに該当する場合、ラベルを付与：
- 外部アカウント・認証情報が必要（Google、Apple、Firebase等）
- 2時間以上のインストール・ダウンロードが必要
- 物理デバイスでの動作確認が必要
- 証明書・署名が必要
- 有料サービスの契約・支払いが必要

### 自動実行ルール
```
# AI自動実行対象の選択
JQL: status = 10003 AND labels NOT IN ("human-intervention-required")

# 実行フロー
ラベルなし → 20分で100%完了 → レビュー中へ遷移
ラベルあり → 実行可能部分のみ完了 → 進行中維持 → 人間介入待ち
```

### タスク作成時のルール
1. デフォルトはラベルなし（AI実行可能想定）
2. 受け入れ条件に上記判定基準が含まれる場合のみラベル付与
3. 不明な場合は実行時に判断・追加

### 人間介入後の処理
1. 介入完了後、ラベルを除去
2. 残作業をAIが継続実行
3. または新規サブタスクとして分割

## カジュアルゲーム開発プロジェクト設定

### プロジェクト概要
- 目的: AI支援による効率的なカジュアルゲーム開発ビジネス
- 目標: 月4本リリース、月収30-65万円
- 技術スタック: Flutter + Flame + Claude Code + MCP

### 📌 AI開発指示の統一エントリーポイント
**必ず `casual_game_template/AI_MASTER.md` から開始してください。**
AI_MASTER.mdが唯一の統合ガイドです。

### 20分サイクル開発フロー
1. Jiraタスク確認・選択 (2分)
2. task-decomposer agentによるタスク分解 (3分)
3. task-executor agentでの実装 (12分)
4. quality-checker agentによる品質確認 (3分)

### Sub-agents活用方法
- task-selector: 実行可能なJiraタスクの自動選択と優先順位判定
- task-decomposer: 大きなタスクを20分以内の実装タスクに分解
- task-executor: auto-acceptモードでの高速開発実行（20分制約厳守）
- quality-checker: パフォーマンス・リテンション・収益性の観点で品質確認
- status-validator: 受け入れ条件達成率の定量評価とステータス遷移判定
- jql-validator: JQLクエリの事前検証とタイムアウト防止

### 品質基準とKPI
- D1リテンション: 40%以上
- D7リテンション: 15%以上  
- 目標ARPU: $0.13以上
- 開発サイクル: 7日/ゲーム以下
- Claude Code活用率: 80%以上

### ゲーム設計指針
- セッション時間: 30-90秒
- 操作: シンプルなタップ/スワイプ
- 難易度: 3秒で成功体験、60秒で挫折
- 広告頻度: 1分あたり2-3個