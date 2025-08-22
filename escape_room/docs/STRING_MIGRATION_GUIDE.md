# 文字列多言語化移行ガイド

## 概要

本ガイドでは、Flutterプロジェクトの既存ハードコードされた文字列を、ARBファイルベースの多言語化システムに移行する手順を説明します。

## 移行手順

### 1. 前提条件確認

✅ `l10n.yaml`が設定済み  
✅ ARBファイル（`app_en.arb`, `app_ja.arb`）が存在  
✅ `flutter_localizations`依存関係が追加済み  
✅ `AppLocalizations`がインポート済み  

### 2. 文字列の識別と分類

#### 2.1 移行対象の文字列タイプ

- **UIテキスト**: ボタンラベル、メニュー項目、ダイアログメッセージ
- **ユーザーメッセージ**: エラーメッセージ、成功メッセージ、通知
- **ゲームコンテンツ**: ストーリーテキスト、説明文、ヒント
- **設定項目**: 設定画面の項目名、説明文

#### 2.2 移行除外項目

- **技術的文字列**: ログメッセージ、デバッグ出力、API キー
- **固定値**: バージョン番号、定数値
- **内部識別子**: ファイルパス、クラス名

### 3. ARBファイルへの文字列追加

#### 3.1 基本的な文字列

```json
// app_en.arb
"buttonStart": "Start",
"@buttonStart": {
  "description": "Start game button label"
}

// app_ja.arb  
"buttonStart": "はじめる"
```

#### 3.2 プレースホルダー付き文字列

```json
// app_en.arb
"welcomeMessage": "Welcome, {userName}!",
"@welcomeMessage": {
  "description": "Welcome message with user name",
  "placeholders": {
    "userName": {
      "type": "String",
      "example": "Alice"
    }
  }
}

// app_ja.arb
"welcomeMessage": "{userName}さん、ようこそ！"
```

#### 3.3 複数形対応文字列

```json
// app_en.arb
"itemsCount": "{count, plural, =0{No items} =1{1 item} other{{count} items}}",
"@itemsCount": {
  "description": "Item count with plural support",
  "placeholders": {
    "count": {
      "type": "int",
      "example": "3"
    }
  }
}

// app_ja.arb
"itemsCount": "{count, plural, =0{アイテムなし} other{{count}個のアイテム}}"
```

### 4. Dartコードの修正

#### 4.1 基本的な置換

**Before:**
```dart
Text('はじめる')
```

**After:**
```dart
Text(AppLocalizations.of(context)!.buttonStart)
```

#### 4.2 プレースホルダー付き文字列

**Before:**
```dart
Text('$userNameさん、ようこそ！')
```

**After:**
```dart
Text(AppLocalizations.of(context)!.welcomeMessage(userName))
```

#### 4.3 null-safe な取得

```dart
// 推奨パターン
final l10n = AppLocalizations.of(context);
if (l10n != null) {
  Text(l10n.buttonStart)
}

// または with fallback
Text(AppLocalizations.of(context)?.buttonStart ?? 'Start')
```

### 5. 自動検出・置換ツール

#### 5.1 文字列検出コマンド

```bash
# 日本語文字列を含むファイルを検索
grep -r "[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]" lib/ --include="*.dart"

# 文字列リテラルを検索（シングルクォート）
grep -r "'[^']*'" lib/ --include="*.dart"

# 文字列リテラルを検索（ダブルクォート）
grep -r '"[^"]*"' lib/ --include="*.dart"
```

#### 5.2 半自動置換スクリプト

```bash
#!/bin/bash
# tools/string_migration.sh

# 1. 文字列を抽出
echo "Extracting hardcoded strings..."
grep -rn "'[^']*'" lib/ --include="*.dart" > strings_to_migrate.txt

# 2. ARBファイルに未定義の文字列をチェック
echo "Checking missing strings in ARB files..."
# TODO: Python/Node.js script to cross-reference

# 3. バックアップ作成
echo "Creating backup..."
cp -r lib/ lib_backup/

echo "Manual migration required. Check strings_to_migrate.txt"
```

### 6. 移行チェックリスト

#### 6.1 コード修正後の確認

- [ ] すべてのText()ウィジェットでAppLocalizations使用
- [ ] AlertDialogのtitle, contentで多言語対応
- [ ] SnackBarメッセージの多言語化
- [ ] Tooltipテキストの多言語化
- [ ] AppBarのtitleで多言語対応
- [ ] エラーハンドリングでの多言語メッセージ

#### 6.2 ARBファイル品質チェック

- [ ] 英語ARBファイルにすべてのメタデータ記述
- [ ] 日本語ARBファイルに対応する翻訳
- [ ] プレースホルダーの型と例示値が適切
- [ ] 複数形ルールが正しく適用
- [ ] 文字列キーの命名規則に従っている

#### 6.3 動作テスト

- [ ] 日本語ロケールでの表示確認
- [ ] 英語ロケールでの表示確認
- [ ] デバイス言語切り替えでの動的変更
- [ ] 未翻訳文字列のfallback動作確認
- [ ] プレースホルダー値の正しい表示

### 7. よくある問題と解決法

#### 7.1 BuildContextが利用できない場合

**問題:**
```dart
class MyClass {
  String getMessage() {
    // BuildContext がない
    return AppLocalizations.of(context)!.message; // Error
  }
}
```

**解決法:**
```dart
class MyClass {
  String getMessage(BuildContext context) {
    return AppLocalizations.of(context)!.message;
  }
  
  // または初期化時にLocalizationsを渡す
  final AppLocalizations l10n;
  MyClass(this.l10n);
}
```

#### 7.2 動的文字列の処理

**問題:**
```dart
String message = isError ? 'エラーです' : '成功しました';
```

**解決法:**
```dart
// ARBに両方の文字列を定義
String message = isError 
  ? AppLocalizations.of(context)!.errorMessage
  : AppLocalizations.of(context)!.successMessage;
```

#### 7.3 文字列結合の処理

**問題:**
```dart
String fullMessage = 'ようこそ、' + userName + 'さん！';
```

**解決法:**
```dart
// プレースホルダーを使用
String fullMessage = AppLocalizations.of(context)!.welcomeMessage(userName);
```

### 8. 段階的移行戦略

#### Phase 1: 重要UI文字列（1-2週間）
- メインメニュー
- ゲーム操作ボタン
- 基本的なダイアログ

#### Phase 2: ユーザーメッセージ（1週間）
- エラーメッセージ
- 成功メッセージ
- プログレス表示

#### Phase 3: 詳細コンテンツ（2-3週間）
- 設定画面
- ヘルプ文書
- ゲーム内ストーリー

### 9. メンテナンス指針

#### 9.1 新規文字列追加時のルール

1. **必ず英語ARBファイルから追加**
2. **メタデータ（description, placeholders）を記述**
3. **対応する日本語翻訳を同時追加**
4. **文字列キー命名規則に従う**

#### 9.2 文字列キー命名規則

```
// 基本形式: [画面/機能][要素][種類]
buttonStart          // ボタン類
errorLoadData        // エラーメッセージ
tooltipSettings      // ツールチップ
titleMainMenu        // タイトル
messageSuccess       // メッセージ
```

#### 9.3 翻訳品質管理

- **文脈を考慮した翻訳**
- **UIスペースに適した文字数**
- **ユーザビリティを重視した表現**
- **アプリの世界観に合った文体**

## まとめ

この移行ガイドに従って段階的に文字列の多言語化を進めることで、保守性が高く、国際化に対応したアプリを構築できます。重要なのは一度にすべて移行するのではなく、優先度に応じて段階的に行うことです。