# App Store プライバシーラベル設定データ

## アプリ概要
- **アプリ名**: Escape Master / 脱出マスター
- **Bundle ID**: com.casualgames.escapemaster
- **対象年齢**: 4+ (全年齢対象)
- **カテゴリ**: ゲーム > パズル

## データ収集の有無

### ✅ 収集するデータ
このアプリは以下のデータを収集します：

#### 1. 識別子 (Identifiers)
- **デバイスID**: 
  - 収集SDK: Google Mobile Ads, Firebase Analytics
  - 用途: 広告配信、分析
  - ユーザーとのリンク: いいえ
  - トラッキング: はい

#### 2. 使用状況データ (Usage Data)
- **アプリインタラクション**:
  - 収集SDK: Firebase Analytics
  - 用途: アプリ分析、パフォーマンス監視
  - ユーザーとのリンク: いいえ
  - トラッキング: はい

#### 3. 診断 (Diagnostics)
- **クラッシュデータ**:
  - 収集SDK: Firebase Analytics
  - 用途: アプリ機能改善
  - ユーザーとのリンク: いいえ
  - トラッキング: いいえ

- **パフォーマンスデータ**:
  - 収集SDK: Firebase Analytics
  - 用途: アプリ最適化
  - ユーザーとのリンク: いいえ
  - トラッキング: いいえ

#### 4. その他の診断データ
- **その他の診断データ**:
  - 収集SDK: Google Mobile Ads
  - 用途: 広告配信最適化
  - ユーザーとのリンク: いいえ
  - トラッキング: いいえ

### ❌ 収集しないデータ

以下のデータは**収集していません**：
- 連絡先情報（名前、メールアドレス、電話番号等）
- 健康とフィットネス
- 財務情報
- 位置情報
- 機密情報（パスワード、セキュリティ情報等）
- 連絡先
- ユーザーコンテンツ（写真、動画、音声、文書等）
- 閲覧履歴
- 検索履歴
- 音声データ
- ユーザー指定のファイル

## SDK別データ収集詳細

### Google Mobile Ads (^6.0.0)
```json
{
  "purpose": "Third-Party Advertising",
  "data_types": [
    "Device ID",
    "Advertising Data",
    "Other Diagnostic Data"
  ],
  "linked_to_user": false,
  "used_for_tracking": true
}
```

### Firebase Analytics (^10.7.4)
```json
{
  "purpose": "Analytics",
  "data_types": [
    "Product Interaction",
    "Advertising Data",
    "Usage Data",
    "Crash Data",
    "Performance Data"
  ],
  "linked_to_user": false,
  "used_for_tracking": true
}
```

### Shared Preferences (^2.5.3)
```json
{
  "purpose": "App Functionality",
  "data_types": [
    "User Settings (Local Only)"
  ],
  "linked_to_user": false,
  "used_for_tracking": false,
  "note": "ローカルデバイス保存のみ、外部送信なし"
}
```

### Audio Players (^6.5.0)
```json
{
  "purpose": "App Functionality",
  "data_types": [],
  "linked_to_user": false,
  "used_for_tracking": false,
  "note": "データ収集なし、音声再生のみ"
}
```

## App Store Connect 設定用回答

### データ収集に関する質問への回答

#### Q: Does this app collect data?
**A: Yes**

#### Q: Do you or your third-party partners collect data from this app?
**A: Yes, we and our partners collect data from this app**

#### 収集データカテゴリ選択:
- [x] **Identifiers** → Device ID
- [x] **Usage Data** → Product Interaction
- [x] **Diagnostics** → Crash Data, Performance Data, Other Diagnostic Data
- [ ] Contact Info
- [ ] Health & Fitness
- [ ] Financial Info
- [ ] Location
- [ ] Sensitive Info
- [ ] Contacts
- [ ] User Content
- [ ] Browsing History
- [ ] Search History
- [ ] Audio Data

### 各データタイプの詳細設定

#### Identifiers > Device ID
- **Data Use**: Third-Party Advertising, Analytics
- **Linked to User**: No
- **Used for Tracking**: Yes

#### Usage Data > Product Interaction
- **Data Use**: Analytics, App Functionality
- **Linked to User**: No
- **Used for Tracking**: Yes

#### Diagnostics > Crash Data
- **Data Use**: App Functionality
- **Linked to User**: No
- **Used for Tracking**: No

#### Diagnostics > Performance Data
- **Data Use**: App Functionality
- **Linked to User**: No
- **Used for Tracking**: No

#### Diagnostics > Other Diagnostic Data
- **Data Use**: Third-Party Advertising
- **Linked to User**: No
- **Used for Tracking**: No

## トラッキングに関する設定

### App Tracking Transparency
- **Required**: Yes (iOS 14.5+)
- **Reason**: Google Mobile Ads および Firebase Analytics がクロスアプリ・ウェブサイトトラッキングを実行

### トラッキングドメイン
```
googleadservices.com
google-analytics.com
firebase.google.com
app-measurement.com
```

## プライバシーポリシーURL
- **URL**: https://[あなたのドメイン]/privacy-policy
- **状態**: 既存文書 `docs/privacy_policy.md` をWebサイトに公開必要

## 注意事項

### 重要な確認点
1. **第三者SDK更新**: SDK バージョンアップ時は収集データ変更の可能性
2. **iOS版限定**: この設定はiOS版のみ、Android版は別途Google Play対応
3. **継続監視**: Apple のプライバシー要件変更に対応

### リスク回避
- **過少申告禁止**: 実際より少なく申告すると審査リジェクト
- **正確性重視**: 不明な場合は「収集する」で安全側に設定
- **定期見直し**: 3ヶ月毎にSDK・データ収集状況を確認

## 設定完了チェックリスト

### App Store Connect 設定
- [ ] プライバシーラベル設定完了
- [ ] プライバシーポリシーURL設定
- [ ] トラッキング設定完了
- [ ] 年齢適合性確認

### 技術実装
- [x] プライバシーマニフェスト作成 (`PrivacyInfo.xcprivacy`)
- [ ] App Tracking Transparency実装確認
- [ ] プライバシーポリシー Web公開

### コンプライアンス
- [ ] COPPA対応確認 (13歳未満ユーザー)
- [ ] GDPR対応確認 (EU圏ユーザー)
- [ ] Apple審査ガイドライン準拠確認