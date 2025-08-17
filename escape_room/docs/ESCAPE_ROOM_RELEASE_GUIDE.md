# 脱出ゲーム App Store リリース作業ガイド

**作成日**: 2025-08-11  
**目的**: QuickEscapeRoomTemplateを使用した脱出ゲームのApp Store公開作業管理

## 📋 作業概要（修正版）

### プロジェクト基本情報
- **ベーステンプレート**: QuickEscapeRoomTemplate（実装済み・公式準拠）
- **フレームワーク完成度**: 96.2%
- **AI作業時間**: 43分（大幅短縮・テンプレート活用）
- **人間作業時間**: 署名設定・ストア申請（時間不定）
- **必要リソース**: Apple Developer（$99/年）・Google Play Console（$25初回のみ）

### 完成済み基盤
✅ 脱出ゲームロジック完全実装  
✅ インベントリ・ホットスポット・パズルシステム  
✅ Firebase Analytics・Google Mobile Ads統合  
✅ iOS/Androidビルド環境  
✅ テストスイート（96.2%成功率）

---

## 🎯 Phase 1: ゲーム実装・カスタマイズ

### 🔧 P1-1: 脱出ゲーム具体実装
- **作業時間**: 10分
- **作業内容**: QuickEscapeRoomTemplateを使用した脱出ゲーム実装
- **成果物**: 動作する脱出ゲーム（テンプレート活用）
- **受け入れ条件**: 
  - テンプレートのサンプルゲームが正常動作
  - テスト実行で成功率96%以上維持
  - ブラウザシミュレーション正常動作確認

**実行コマンド**:
```bash
# 既存テンプレートテスト実行
flutter test test/framework/game_types/
# ブラウザ動作確認
flutter run -d chrome --web-port=8080
```

### 🎨 P1-2: ゲーム設定カスタマイズ  
- **作業時間**: 3分
- **作業内容**: EscapeRoomConfig設定値変更（テーマ・制限時間等）
- **成果物**: カスタマイズされたゲーム設定
- **受け入れ条件**:
  - 設定値が適切に反映されている
  - ゲームバランスが適正（制限時間・難易度）

### 🖼️ P1-3: アセット最適化（既存流用）
- **作業時間**: 2分
- **作業内容**: 既存アセットの確認・最適化（新規作成不要）
- **成果物**: 最適化済みアセット
- **受け入れ条件**:
  - assets/audio/配下のアセットが正常読み込み
  - アセットサイズが適切（<100KB）

---

## 🏪 Phase 2: App Store準備・メタデータ

### 📱 P2-1: アプリ基本情報設定（AI実行）
- **作業時間**: 5分
- **作業内容**: pubspec.yaml・Info.plist・build.gradle.kts自動更新
- **成果物**: 公開準備完了アプリ設定
- **受け入れ条件**:
  - Bundle IDが一意（com.yourcompany.escaperoomgame等）
  - アプリ名設定（"Escape Room Adventure"等）
  - バージョン1.0.0+1設定

**AIが自動実行する設定変更**:
- `pubspec.yaml`: name、version更新
- `ios/Runner/Info.plist`: CFBundleDisplayName更新
- `android/app/build.gradle.kts`: applicationId更新

### 🎯 P2-2: アイコン・スクリーンショット自動生成
- **作業時間**: 8分
- **作業内容**: 既存アイコン流用・flutter_driver自動スクリーンショット
- **成果物**: App Store要求アセット
- **受け入れ条件**:
  - 既存アイコンセット確認済み（ios/Runner/Assets.xcassets/）
  - 自動スクリーンショット3枚以上生成
  - 解像度要件満足

**AI実行コマンド**:
```bash
# 既存アイコン確認
ls ios/Runner/Assets.xcassets/AppIcon.appiconset/
# 自動スクリーンショット生成
flutter drive --target=test_driver/app.dart --driver=test_driver/browser_simulation_test.dart --web-port=8080
```

### 📄 P2-3: App Store説明文・メタデータ自動生成
- **作業時間**: 5分
- **作業内容**: AI自動生成によるアプリ説明・キーワード・プライバシーポリシー
- **成果物**: App Store準備完了文書
- **受け入れ条件**:
  - 説明文テンプレート自動生成（400文字程度）
  - キーワードリスト自動生成（脱出ゲーム関連）
  - プライバシーポリシーテンプレート生成

---

## 🚀 Phase 3: ビルド・公開申請

### 🔨 P3-1: リリースビルド作成・検証（AI実行）
- **作業時間**: 10分
- **作業内容**: Flutter公式推奨ビルド作成・自動検証
- **成果物**: App Bundle・IPAファイル
- **受け入れ条件**:
  - ビルドエラー0件
  - 自動テスト通過確認
  - ファイルサイズ妥当性確認

**AI実行コマンド**:
```bash
# Android App Bundle（推奨）
flutter build appbundle --release
# iOS IPA  
flutter build ipa --release
# ビルド検証
flutter test
```

### 🔐 P3-2: 署名設定（人間介入必須）
- **作業時間**: 人間作業
- **作業内容**: Apple Developer・Google Play Console署名設定
- **成果物**: 署名設定完了
- **受け入れ条件**:
  - iOS: Apple Developer証明書・プロファイル設定完了
  - Android: Play App Signingまたはupload keystore設定完了

**⚠️ 人間介入必須**:
- Apple Developer Portal操作
- Google Play Console操作
- Xcode署名設定
- Android keystore作成（初回のみ）

### 📤 P3-3: ストア申請（人間介入必須）
- **作業時間**: 人間作業
- **作業内容**: App Store Connect・Google Play Console申請
- **成果物**: 審査待ち状態
- **受け入れ条件**:
  - iOS: App Store Connect審査申請完了
  - Android: Google Play Console公開申請完了

**⚠️ 人間介入必須**:
- App Store Connect Web UI操作
- Google Play Console Web UI操作
- メタデータ入力・スクリーンショットアップロード
- 審査申請送信

---

## 📊 作業進捗管理

### ステータス定義
- **⏳ 待機**: 作業未開始
- **🔄 実行中**: 作業進行中  
- **✅ 完了**: 受け入れ条件達成
- **❌ ブロック**: 人間介入・外部依存待ち
- **🔧 修正**: 問題発生・修正対応中

### 品質チェックポイント
各フェーズ完了時に以下を確認：
1. **テスト実行結果**: 成功率95%以上
2. **ブラウザシミュレーション**: エラー0件
3. **実機動作確認**: iOS/Android各1端末
4. **パフォーマンス**: メモリ使用量・FPS監視

### 完了基準
- [ ] 全Phase完了（P1-1 〜 P3-3）
- [ ] App Store「審査待ち」ステータス達成  
- [ ] 品質基準全項目クリア
- [ ] ドキュメント・履歴更新完了

---

## 🆘 トラブルシューティング

### よくある問題・対処法
| 問題 | 原因 | 対処法 |
|------|------|--------|
| ビルドエラー | 証明書期限切れ | Apple Developer で証明書更新 |
| アップロード失敗 | Bundle ID重複 | 一意のBundle ID設定 |
| 審査リジェクト | メタデータ不備 | App Store ガイドライン確認・修正 |
| クラッシュ発生 | メモリリーク | メモリプロファイリング・最適化 |

### AI実行可能作業（43分）
- P1-1〜P1-3: ゲーム実装・設定（15分）
- P2-1〜P2-3: アプリ設定・メタデータ生成（18分）
- P3-1: ビルド作成・検証（10分）

### 人間介入必須作業（時間不定）
- P3-2: 署名設定（Apple Developer・Google Play Console）
- P3-3: ストア申請（Web UI操作・審査申請）

---

## 📈 成功指標・KPI

### 技術指標
- ビルド成功率: 100%
- テスト成功率: 95%以上  
- クラッシュ率: <1%
- 起動時間: <3秒

### ビジネス指標
- 審査通過率: 100%（初回目標）
- 公開完了時間: 3日以内
- 評価: 3.5星以上（初期目標）
- インストール: 100件以上（1週間以内）

---

**最終更新**: 2025-08-11  
**次回更新予定**: 作業開始時