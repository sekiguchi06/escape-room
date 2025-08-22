# Flutter Analysis修正指示書 - A担当（UI専門）

## 担当範囲
**ディレクトリ**: `lib/framework/ui/` (49ファイル)  
**推定issue数**: 約140個  
**作業時間目安**: 3-4時間

## 作業手順

### 1. 担当範囲の問題確認
```bash
# 作業ディレクトリに移動
cd escape_room

# 担当範囲のissue確認
flutter analyze --no-fatal-infos | grep "lib/framework/ui/"

# エラーレベル別の確認
flutter analyze --no-fatal-infos | grep "lib/framework/ui/" | grep "error •"
flutter analyze --no-fatal-infos | grep "lib/framework/ui/" | grep "info •"
```

### 2. 修正優先順位
1. **error** レベル（最優先）
2. **warning** レベル（中優先）  
3. **info** レベル（低優先）

### 3. 主要エラーパターンと修正方法

#### A. undefined_class エラー
```dart
// エラー例
error • Undefined class 'CustomButton' • lib/framework/ui/components/button.dart:15:12

// 修正方法
1. import文を確認・追加
2. クラス名のタイポチェック
3. ファイルパスの確認
```

#### B. missing_required_argument エラー
```dart
// エラー例  
error • The named parameter 'onPressed' is required, but there's no corresponding argument

// 修正方法
Widget(
  onPressed: () {}, // 必須パラメータを追加
  // その他のプロパティ
)
```

#### C. undefined_function エラー
```dart
// エラー例
error • The function 'buildCustomWidget' isn't defined

// 修正方法
1. 関数名のタイポチェック
2. import文の確認
3. 関数の定義確認
```

#### D. unnecessary_import 情報
```dart
// 修正前
import 'package:flutter/foundation.dart';  // 不要なimport
import 'package:flutter/material.dart';

// 修正後
import 'package:flutter/material.dart';     // 必要なもののみ
```

### 4. よくある修正パターン

#### Widget関連
```dart
// 修正前（エラー）
return CustomButton(
  title: "OK",
  // onPressed パラメータなし
);

// 修正後
return CustomButton(
  title: "OK",
  onPressed: () => Navigator.pop(context),
);
```

#### BuildContext関連
```dart
// 修正前（エラー）
void showDialog() {
  // contextが未定義
}

// 修正後  
void showDialog(BuildContext context) {
  // contextを引数として追加
}
```

### 5. 修正確認手順
```bash
# 修正後の確認
flutter analyze lib/framework/ui/

# 特定ファイルのみ確認
flutter analyze lib/framework/ui/components/button.dart

# エラー数の確認
flutter analyze --no-fatal-infos | grep "lib/framework/ui/" | grep "error •" | wc -l
```

### 6. 作業完了基準
- [ ] lib/framework/ui/ 内のすべてのerrorレベルを0にする
- [ ] warningレベルを50%以上削減する  
- [ ] 修正したファイルのドキュメントコメントを適切に更新する
- [ ] `flutter analyze lib/framework/ui/` でクリーンな結果を得る

### 7. 報告フォーマット
作業完了時に以下を報告：
```
## A担当（UI）修正完了報告

### 修正前後の比較
- Error: XX個 → 0個
- Warning: XX個 → XX個  
- Info: XX個 → XX個

### 主要修正内容
- undefined_class: XX件修正
- missing_required_argument: XX件修正
- unnecessary_import: XX件削除

### 修正ファイル数: XX/49ファイル

### 残課題
- 特になし / [具体的な残課題があれば記載]
```

### 8. 注意事項
- **機能を変更しない**: UI の見た目や動作を変えずにエラーのみ修正
- **import最適化**: 不要なimportは削除、必要なimportは追加
- **型安全性**: 適切な型チェックを追加
- **null安全性**: null チェックを適切に行う

### 9. 困った時の対処法
1. **同様のエラー**: 他のファイルで同じエラーがどう修正されているか確認
2. **Flutter公式**: [Flutter API Documentation](https://api.flutter.dev/)を参照
3. **エラーメッセージ**: Dart/Flutterの公式エラー説明を検索

## 開始前チェックリスト
- [ ] Git の現在ブランチ確認（master）
- [ ] `flutter analyze` でベースライン確認
- [ ] 担当ディレクトリ `lib/framework/ui/` の存在確認
- [ ] 作業開始時刻記録

**頑張ってください！UIの品質向上をお願いします 🎨**