## 🔤 文字列一元管理・多言語化システム設計

現在の分析結果に基づく、包括的な文字列管理戦略を追加します。

### 📊 現状分析（自動スキャン結果）
- **総ハードコード文字列**: 2,227個
- **UIテキスト**: 156個（要優先対応）
- **日本語文字列**: 504個
- **既存ARB文字列**: 53個（英語）、44個（日本語）
- **移行進捗**: 30.7%

### 🎯 文字列管理戦略

#### 1. 段階的移行アプローチ
```
Phase 1（最優先・1-2週間）:
  - メインメニューボタン（はじめる、つづきから、あそびかた）
  - ダイアログボタン（閉じる、キャンセル、確認、戻る）
  - 設定項目（バイブレーション、プッシュ通知、自動セーブ）
  - エラーメッセージ（基本的なエラー表示）
  
Phase 2（1週間）:
  - アプリ情報（タイトル、バージョン、開発者）
  - ゲーム説明・ヘルプテキスト
  - ステータス表示（スコア、残り時間、アイテム数）

Phase 3（2-3週間）:
  - 詳細設定画面
  - 高度なエラーハンドリング
  - ゲーム内ストーリーテキスト
```

#### 2. 実装済み自動化ツール

作成した支援ツール：
- **文字列スキャンツール**: `tools/string_migration.py`
- **移行ガイド**: `docs/STRING_MIGRATION_GUIDE.md`
- **優先度管理**: `docs/PRIORITY_STRINGS.md`

使用方法：
```bash
# 現状分析
python3 tools/string_migration.py --scan

# ARB候補生成
python3 tools/string_migration.py --extract

# 移行状況確認
python3 tools/string_migration.py --validate
```

#### 3. ARBファイル構造（Flutter公式ベストプラクティス）

**app_en.arb（テンプレート）**:
```json
{
  "@@locale": "en",
  "@@author": "Escape Room Development Team",
  "@@last_modified": "2024-08-19",
  
  "buttonStart": "Start",
  "@buttonStart": {
    "description": "Start new game button"
  },
  
  "itemsCount": "{count, plural, =0{No items} =1{1 item} other{{count} items}}",
  "@itemsCount": {
    "description": "Item count with proper plural support",
    "placeholders": {
      "count": {"type": "int", "example": "3"}
    }
  }
}
```

**app_ja.arb（翻訳のみ）**:
```json
{
  "@@locale": "ja",
  "buttonStart": "はじめる",
  "itemsCount": "{count, plural, =0{アイテムなし} other{{count}個のアイテム}}"
}
```

#### 4. 実装パターン

**従来**:
```dart
Text('はじめる')
```

**新方式**:
```dart
final l10n = AppLocalizations.of(context);
Text(l10n?.buttonStart ?? 'はじめる')
```

#### 5. 品質管理・自動チェック

- **文字列キー命名規則**: `button*`、`error*`、`tooltip*`形式
- **メタデータ必須**: 英語ARBファイルに説明・例示必須
- **プレースホルダー型指定**: 引数の型と例を明記
- **複数形対応**: ICU MessageFormat使用

### 📁 作成済みドキュメント・ツール

1. **docs/STRING_MIGRATION_GUIDE.md**: 完全な移行手順書
2. **docs/PRIORITY_STRINGS.md**: 優先度別実装計画
3. **tools/string_migration.py**: 自動分析・候補生成ツール
4. **lib/config/app_config.dart**: 統一設定に国際化戦略含む

### ✅ 実装状況

#### 完了項目
- [x] ARBファイル構造設計（Flutter公式準拠）
- [x] 文字列移行自動化ツール作成
- [x] 段階的移行計画策定
- [x] main.dartの主要ボタンlocalization対応
- [x] l10n.yaml設定（英語テンプレート、日本語翻訳）

#### 次期対応予定
- [ ] Phase1文字列の完全移行（UI要素156個）
- [ ] ゲーム内ダイアログの多言語化
- [ ] エラーハンドリングメッセージ統一
- [ ] ビルド時文字列チェック自動化

### 🔄 継続的改善

1. **新規文字列追加ルール**:
   - 必ず英語ARBから追加
   - メタデータ（description、placeholders）記述必須
   - 命名規則遵守
   - 同時に日本語翻訳追加

2. **品質担保**:
   - 自動化ツールでの定期チェック
   - 未翻訳文字列の検出
   - 重複・不整合の検出
   - プレースホルダー検証

この文字列管理システムにより、保守性が高く国際化に対応したアプリ構成を実現できます。