# App Store 個人アカウント公開チェックリスト

## プロジェクト概要
- **アプリ名**: Escape Master / 脱出マスター
- **Bundle ID**: com.casualgames.escapemaster
- **バージョン**: 1.0.0+1
- **対象**: 個人開発者アカウントでの初回リリース

## 📋 実行状況トラッキング

### Phase 1: 基本設定（完了済み）
- [x] **Bundle ID設定**: com.casualgames.escapemaster（Xcode project.pbxproj設定済み）
- [x] **アプリ名設定**: "Escape Master" Info.plist CFBundleDisplayName設定済み
- [x] **バージョン設定**: pubspec.yaml version: 1.0.0+1
- [x] **メタデータ準備**: docs/app_store_metadata.md 完成済み
- [x] **プライバシーポリシー**: docs/privacy_policy.md 完成済み

### Phase 2: 開発者アカウント準備（人間介入必須）
- [ ] **Apple Developer Program**: 年額$99登録
  - **実行者**: 個人（アカウント・支払い情報必須）
  - **所要時間**: 24-48時間（審査含む）
  - **URL**: https://developer.apple.com/programs/

- [ ] **証明書・プロビジョニング**: iOS Distribution Certificate作成
  - **実行者**: 個人（開発者アカウント必須）
  - **場所**: Xcode Signing & Capabilities
  - **依存**: Apple Developer Program完了後

### Phase 3: プロダクション設定（人間介入必須）
- [ ] **Firebase本番プロジェクト**: テスト用から本番用へ切り替え
  - **実行者**: 個人（Googleアカウント必須）
  - **現在**: ✅ GoogleService-Info.plist 設定済み
  - **必要作業**: 本番Firebase プロジェクト作成・設定ファイル更新

- [ ] **Google AdMob設定**: テスト用IDから本番用IDへ切り替え
  - **実行者**: 個人（Googleアカウント・税務情報必須）
  - **現在**: ✅ ca-app-pub-3940256099942544~1458002511（テスト用Info.plist設定済み）
  - **必要作業**: AdMobアカウント作成・広告ユニット作成・Info.plist更新

### Phase 4: 必須コンプライアンス（完了済み）
- [x] **プライバシーマニフェスト作成**: ios/Runner/PrivacyInfo.xcprivacy
  - **実行者**: AI
  - **締切**: 2024年5月以降必須
  - **内容**: データ収集・第三者SDK情報開示
  - **状態**: ✅ 作成完了済み

- [x] **プライバシーラベル準備**: App Store Connect設定用データ整理
  - **実行者**: AI
  - **内容**: Google Mobile Ads・Firebase Analytics データ収集項目リスト
  - **状態**: ✅ docs/privacy_labels_data.md 準備完了済み

### Phase 5: アセット準備（AI実行可能）
- [ ] **アプリアイコン**: 1024x1024サイズ作成
  - **実行者**: AI（デザイン生成）
  - **必要サイズ**: 1024x1024, 180x180, 120x120, 87x87, 80x80, 76x76, 60x60, 58x58, 40x40, 29x29, 20x20
  - **状態**: 未作成

- [ ] **スクリーンショット**: 3機種対応
  - **実行者**: AI（ゲーム実行・キャプチャ）
  - **必要**: iPhone 6.5" (3枚), iPhone 5.5" (3枚), iPad 12.9" (3枚)
  - **状態**: 未作成

### Phase 6: App Store Connect設定（人間介入必須）
- [ ] **App Store Connect アプリ作成**: 新規アプリ登録
  - **実行者**: 個人（開発者アカウント必須）
  - **依存**: Apple Developer Program, Bundle ID確保
  - **URL**: https://appstoreconnect.apple.com

- [ ] **メタデータ設定**: 説明文・キーワード・カテゴリ設定
  - **実行者**: 個人
  - **準備済み**: docs/app_store_metadata.md の内容をコピー
  - **言語**: 日本語（Primary）, 英語（Additional）

- [ ] **アセットアップロード**: アイコン・スクリーンショット設定
  - **実行者**: 個人
  - **依存**: Phase 5完了後

### Phase 7: ビルド・提出（技術作業）
- [ ] **Release ビルド作成**: flutter build ios --release
  - **実行者**: AI + 個人（署名）
  - **要件**: 証明書・プロビジョニング設定完了
  - **コマンド**: `flutter build ios --release`

- [ ] **App Store Connect アップロード**: Archive & Upload
  - **実行者**: 個人（Xcode操作）
  - **ツール**: Xcode Organizer
  - **依存**: Release ビルド完了

- [ ] **審査申請**: Submit for Review
  - **実行者**: 個人
  - **場所**: App Store Connect
  - **所要時間**: 24-48時間

## 🚨 重要な制約・依存関係

### 人間介入必須項目（AI実行不可）
1. **アカウント・支払い関連**: Apple Developer, Firebase, AdMob
2. **証明書・署名**: iOS Distribution Certificate
3. **App Store Connect操作**: アプリ作成・設定・提出

### AI実行可能項目（完了済み）
1. ✅ **プライバシーマニフェスト作成** - PrivacyInfo.xcprivacy実装済み
2. ⏳ **アセット作成**（アイコン・スクリーンショット） - 状況確認中
3. ✅ **設定ファイル更新** - Bundle ID・アプリ名設定済み
4. ✅ **ドキュメント作成** - メタデータ・プライバシーポリシー完成済み

### 並行実行可能
- Phase 2 と Phase 4 は並行実行可能
- Phase 5 は Phase 1完了後いつでも実行可能

## 📅 推奨実行順序（更新版）

### 週1（人間主導） - 次のステップ
1. Apple Developer Program 登録申請
2. Firebase・AdMob アカウント準備

### ~~週2（AI主導）~~ ✅ 完了済み
1. ✅ プライバシーマニフェスト作成
2. ⏳ アイコン・スクリーンショット生成（状況確認中）

### 週3（人間主導） - 次のステップ
1. 証明書・プロビジョニング設定
2. App Store Connect アプリ作成
3. プロダクション設定切り替え

### 週4（協業） - 最終ステップ
1. Release ビルド作成
2. アップロード・審査申請

## 🎯 成功基準
- [ ] App Store Connect にアプリが表示される
- [ ] 審査申請が正常に完了する
- [ ] 審査ステータスが "In Review" になる
- [x] プライバシー・コンプライアンス要件をすべてクリア（PrivacyInfo.xcprivacy・プライバシーポリシー完成済み）

## 📊 現在の状況サマリー

### ✅ 完了済み項目
- **基本設定**: Bundle ID・アプリ名・バージョン設定
- **ドキュメント**: メタデータ・プライバシーポリシー
- **コンプライアンス**: プライバシーマニフェスト
- **SDK設定**: Firebase・AdMobテスト設定

### ⏳ 次のステップ（人間介入必須）
1. **Apple Developer Program 登録** ($99/年)
2. **証明書作成** (iOS Distribution Certificate)
3. **App Store Connect アプリ作成**
4. **本番環境設定** (Firebase・AdMob)