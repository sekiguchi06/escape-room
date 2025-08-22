# 優先文字列移行リスト

## 移行戦略

現在のスキャン結果：
- **総ハードコード文字列**: 2,227個
- **UIテキスト**: 156個
- **日本語文字列**: 504個

この膨大な数を段階的に処理するため、以下の優先順位で移行を行います。

## Phase 1: 重要UI文字列（最優先）

### メインメニュー関連
```dart
// main.dart から抽出する重要文字列
'はじめる'                    → buttonStart
'つづきから'                  → buttonContinue  
'あそびかた'                  → buttonHowToPlay
'設定'                       → settings
'音量設定'                   → tooltipVolumeSettings
'ランキング'                  → tooltipRanking
'実績'                      → tooltipAchievements
'アプリ情報'                  → tooltipAppInfo
```

### ダイアログ・ボタン
```dart
'閉じる'                     → buttonClose
'キャンセル'                  → buttonCancel
'確認'                      → buttonConfirm
'戻る'                      → back
'リセット'                   → volumeReset
'テスト'                    → volumeTest
```

### ゲーム操作
```dart
'新しいゲームを開始'            → gameStartNewGame
'データを削除して開始'          → gameDeleteProgressConfirm
'ゲームオーバー'              → gameOver
'クリア！'                   → clear
'プレイ'                    → play
'リスタート'                 → restart
'一時停止'                   → pause
'再開'                     → resume
'メニュー'                   → menu
```

### 設定項目
```dart
'バイブレーション'             → settingsVibration
'タップ時の振動フィードバック'    → settingsVibrationDesc
'プッシュ通知'               → settingsPushNotification
'ゲーム更新やヒントの通知'      → settingsPushNotificationDesc
'自動セーブ'                → settingsAutoSave
'進行状況の自動保存'          → settingsAutoSaveDesc
```

### 音量設定
```dart
'音量設定'                   → volumeTitle
'BGM音量'                   → volumeBgm
'効果音音量'                 → volumeSfx
'ミュート中'                 → volumeMuted
```

### エラー・メッセージ
```dart
'セーブデータの読み込みに失敗しました'  → errorLoadSaveData
'エラーが発生しました: {error}'      → errorOccurred
'{feature}機能（実装予定）'          → messageNotImplemented
'新しいゲームを開始すると、現在の進行状況が削除されます。続けますか？' → gameOverwriteWarning
```

## Phase 2: 詳細UI文字列

### アプリ情報・説明文
```dart
'Escape Master'              → appTitle
'究極の脱出パズルゲーム'        → appSubtitle
'バージョン: 1.0.0'           → appVersion
'開発者: Claude Code'        → appDeveloper
```

### ゲーム説明・ヘルプ
```dart
'🎮 あそびかた'              → howToPlayTitle
'📱 基本操作'               → basicControlsTitle
'🔍 ゲームの進め方'          → gameProgressTitle
'💡 ヒント'                → hintsTitle
```

### ステータス・プログレス表示
```dart
'スコア'                    → score
'残り時間'                  → timeRemaining
'{count}個のアイテム'         → itemsCount (複数形対応)
```

## Phase 3: 低優先度

### デバッグ・開発用文字列
- ログメッセージ
- デバッグ出力
- テスト用文字列
- 開発者コメント

### 内部的な文字列
- ファイルパス
- 設定キー
- 定数値
- API関連

## 実装手順

### 1. ARBファイルに文字列を追加

**app_en.arb** に追加:
```json
{
  "@@locale": "en",
  "@@author": "Escape Room Development Team",
  "@@last_modified": "2024-08-19",

  "buttonStart": "Start",
  "@buttonStart": {
    "description": "Start new game button"
  },

  "buttonContinue": "Continue", 
  "@buttonContinue": {
    "description": "Continue saved game button"
  }
  // ... 他の文字列
}
```

**app_ja.arb** に対応する日本語を追加:
```json
{
  "@@locale": "ja",
  "buttonStart": "はじめる",
  "buttonContinue": "つづきから"
  // ... 他の文字列
}
```

### 2. Dartコードの修正

**Before:**
```dart
Text('はじめる')
```

**After:**
```dart
final l10n = AppLocalizations.of(context);
Text(l10n?.buttonStart ?? 'Start')
```

### 3. 動作確認

```bash
# localization ファイル生成
flutter gen-l10n

# アプリ実行・テスト
flutter run

# 言語切り替えテスト
# iOS Simulator: Device > Language & Region
# Android Emulator: Settings > System > Languages & input
```

## 注意点

### 既存のlocalizationとの整合性
- 現在の `app_en.arb` と `app_ja.arb` は既に正しい構造
- 新しい文字列は既存の命名規則に従う
- メタデータは英語ARBファイルのみに記述

### BuildContext の取得
- `AppLocalizations.of(context)` にはBuildContextが必要
- StatefulWidget や StatelessWidget 内で使用
- context が利用できない場合は設計を見直し

### null-safety 対応
```dart
// 推奨: null-safe pattern
final l10n = AppLocalizations.of(context);
if (l10n != null) {
  return Text(l10n.buttonStart);
}

// または fallback 付き
Text(AppLocalizations.of(context)?.buttonStart ?? 'Start')
```

### プレースホルダー対応
```dart
// ARB
"welcomeMessage": "Welcome, {userName}!",
"@welcomeMessage": {
  "placeholders": {
    "userName": {"type": "String", "example": "Alice"}
  }
}

// Dart
Text(l10n.welcomeMessage(userName))
```

## 進捗管理

チェックボックスで進捗を管理：

### Phase 1 (最優先)
- [ ] メインメニューボタン (5個)
- [ ] ダイアログボタン (4個)  
- [ ] ゲーム操作 (8個)
- [ ] 設定項目 (6個)
- [ ] 音量設定 (4個)
- [ ] エラーメッセージ (3個)

### Phase 2
- [ ] アプリ情報 (4個)
- [ ] ゲーム説明 (4個)
- [ ] ステータス表示 (3個)

### Phase 3
- [ ] その他UI文字列
- [ ] 低優先度文字列

## 完了基準

- [ ] Phase 1 の全文字列が ARB ファイルに登録済み
- [ ] 対応する Dart コードが `AppLocalizations` を使用
- [ ] 日本語・英語で正常に表示確認
- [ ] 動的な言語切り替えが動作
- [ ] ビルドエラーなし

この段階的アプローチにより、重要な文字列から確実に多言語化を進めることができます。