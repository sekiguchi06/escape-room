# プラットフォーム設定ガイド

このドキュメントでは、カジュアルゲームテンプレートで必要なプラットフォーム設定の手順を説明します。

## 概要

カジュアルゲームテンプレートでは以下のサービスを使用します：
- **Firebase Analytics**: ゲーム内分析とユーザー行動追跡
- **Google Mobile Ads**: 収益化のための広告表示

## Firebase 設定手順

### 1. Firebase プロジェクト作成

1. [Firebase Console](https://console.firebase.google.com/) にアクセス
2. 「プロジェクトを追加」をクリック
3. プロジェクト名を入力（例: `my-casual-game`）
4. Googleアナリティクスを有効にする（推奨）

### 2. iOS アプリの追加

1. Firebase Console で「iOS アプリを追加」をクリック
2. iOS バンドル ID を入力（例: `com.yourcompany.casualgame`）
3. アプリのニックネームを入力（オプション）
4. `GoogleService-Info.plist` をダウンロード

### 3. Android アプリの追加

1. Firebase Console で「Android アプリを追加」をクリック
2. Android パッケージ名を入力（iOS と同じ形式推奨）
3. アプリのニックネーム、SHA-1 証明書を入力（オプション）
4. `google-services.json` をダウンロード

## Google Mobile Ads 設定手順

### 1. AdMob アカウント作成

1. [AdMob](https://admob.google.com/) にアクセス
2. Googleアカウントでログイン
3. アプリを登録し、広告ユニット ID を取得

### 2. 広告ユニット ID の種類

- **バナー広告**: `ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY`
- **インタースティシャル広告**: `ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ`
- **リワード広告**: `ca-app-pub-XXXXXXXXXXXXXXXX/WWWWWWWWWW`

### 3. テスト用 ID

開発・テスト時は以下のテスト ID を使用してください：

```dart
// iOS テスト ID
static const String testBannerId = 'ca-app-pub-3940256099942544/2934735716';
static const String testInterstitialId = 'ca-app-pub-3940256099942544/4411468910';
static const String testRewardedId = 'ca-app-pub-3940256099942544/1712485313';

// Android テスト ID
static const String testBannerId = 'ca-app-pub-3940256099942544/6300978111';
static const String testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
static const String testRewardedId = 'ca-app-pub-3940256099942544/5224354917';
```

## ファイル配置手順

### iOS 設定ファイル

1. `templates/platform_configs/ios/GoogleService-Info.plist.template` をコピー
2. `ios/Runner/GoogleService-Info.plist` として保存
3. テンプレート内の `YOUR_*` 値を実際の値に置換：
   - `YOUR_CLIENT_ID`: Firebase から取得した Client ID
   - `YOUR_API_KEY`: Firebase から取得した API Key
   - `YOUR_BUNDLE_ID`: アプリのバンドル ID
   - `YOUR_PROJECT_ID`: Firebase プロジェクト ID
   - `YOUR_GOOGLE_APP_ID`: Firebase から取得した Google App ID

4. `ios/Runner/Info.plist` に Google Mobile Ads Application ID を追加：
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-YOUR_ADMOB_APP_ID~YOUR_APP_SUFFIX</string>
```

### Android 設定ファイル

1. `templates/platform_configs/android/google-services.json.template` をコピー
2. `android/app/google-services.json` として保存
3. テンプレート内の `YOUR_*` 値を実際の値に置換：
   - `YOUR_PROJECT_NUMBER`: Firebase プロジェクト番号
   - `YOUR_PROJECT_ID`: Firebase プロジェクト ID
   - `YOUR_ANDROID_APP_ID`: Firebase から取得した Android App ID
   - `YOUR_PACKAGE_NAME`: Android パッケージ名
   - `YOUR_CLIENT_ID`: Firebase から取得した Client ID
   - `YOUR_API_KEY`: Firebase から取得した API Key

4. `android/app/build.gradle` に Google Mobile Ads の App ID を追加：
```gradle
android {
    defaultConfig {
        // Google Mobile Ads App ID
        resValue "string", "admob_app_id", "ca-app-pub-YOUR_ADMOB_APP_ID~YOUR_APP_SUFFIX"
    }
}
```

## 設定値の確認方法

### Firebase 設定の確認

以下のコマンドでアプリが正常に起動し、Firebase Analytics が初期化されることを確認：

```bash
# iOS
flutter run -d 'iPhone 15 Pro'

# Android
flutter run -d android

# Web（開発用）
flutter run -d chrome
```

ログに以下が表示されれば成功：
```
FirebaseAnalyticsProvider initialized (may be in mock mode)
```

### Google Mobile Ads 設定の確認

広告読み込みテストを実行：

```bash
flutter test test/framework/monetization/google_ad_provider_test.dart
```

## トラブルシューティング

### よくある問題

1. **iOS アプリがクラッシュする**
   - `GoogleService-Info.plist` が正しく配置されているか確認
   - Info.plist に `GADApplicationIdentifier` が設定されているか確認

2. **Android ビルドが失敗する**
   - `google-services.json` が `android/app/` 直下にあるか確認
   - `android/app/build.gradle` に Google Services プラグインが適用されているか確認

3. **Firebase Analytics が動作しない**
   - 設定ファイル内の PROJECT_ID が正しいか確認
   - Firebase Console でアプリが正しく登録されているか確認

4. **広告が表示されない**
   - AdMob で広告ユニットが作成されているか確認
   - テスト ID を使用しているか確認（本番 ID は審査後に使用）

### ログの確認方法

```bash
# 詳細ログを有効にして実行
flutter run --verbose

# Firebase Analytics ログを確認
flutter logs
```

## Mock モードでの開発

設定ファイルが未配置の場合、フレームワークは自動的に Mock モードで動作します：

- Firebase Analytics: イベントはログ出力のみ（送信されない）
- Google Mobile Ads: テスト ID を使用した広告表示

これにより、設定完了前でも開発を進められます。

## セキュリティ注意事項

- 設定ファイルには API キーが含まれるため、公開リポジトリにコミットしない
- `.gitignore` に以下を追加することを推奨：
```
ios/Runner/GoogleService-Info.plist
android/app/google-services.json
```

- テンプレートファイルは公開して問題ありません（実際の値は含まれていないため）