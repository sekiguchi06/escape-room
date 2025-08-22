# ネイティブ評価機能セットアップガイド

## 1. パッケージ追加

`pubspec.yaml`に以下を追加：

```yaml
dependencies:
  in_app_review: ^2.0.9
```

## 2. コード修正

`lib/game/components/premium_clear_screen.dart`で：

```dart
// コメントアウトを解除
import 'package:in_app_review/in_app_review.dart';

// _showAppRatingDialog メソッド内のコメントアウトを解除
final InAppReview inAppReview = InAppReview.instance;
if (await inAppReview.isAvailable()) {
  inAppReview.requestReview();
}
```

## 3. プラットフォーム設定

### iOS
- `ios/Runner/Info.plist`に設定不要（StoreKit自動対応）

### Android  
- `android/app/src/main/AndroidManifest.xml`に設定不要（Play Core API自動対応）

## 4. テスト方法

### シミュレータ/エミュレータ
- テスト用ダイアログが表示される（現在の実装）

### 実機
- iOS: App Store評価ダイアログ
- Android: Play Store評価ダイアログ

## 5. 制限事項

- **年間制限**: ユーザーあたり年3回まで
- **ガイドライン準拠**: Apple/Google審査通過のため適切な頻度での表示
- **ユーザー体験**: ゲームクリア時など適切なタイミングでのみ表示