# App Store Connect プライバシー設定手順

## 🎯 設定概要
- **アプリ**: Escape Master (com.casualgames.escapemaster)
- **データ収集**: 有り（広告・分析目的）
- **トラッキング**: 有り（App Tracking Transparency必要）

## 📋 Step-by-Step 設定手順

### Phase 1: 基本プライバシー設定

#### 1.1 App Store Connect にログイン
1. https://appstoreconnect.apple.com/ にアクセス
2. Apple Developer アカウントでサインイン
3. 対象アプリ「Escape Master」を選択

#### 1.2 プライバシー設定画面へ移動
1. 左メニュー「App Privacy」をクリック
2. 「Get Started」または「Edit」をクリック

### Phase 2: データ収集設定

#### 2.1 基本質問への回答
```
Q: Does this app collect data?
A: ✅ Yes

Q: Do you or your third-party partners collect data from this app?  
A: ✅ Yes, we and our partners collect data from this app
```

#### 2.2 収集データタイプ選択
収集するデータタイプを選択:
```
✅ Identifiers
✅ Usage Data  
✅ Diagnostics
❌ Contact Info
❌ Health & Fitness
❌ Financial Info
❌ Location
❌ Sensitive Info
❌ Contacts
❌ User Content
❌ Browsing History
❌ Search History
❌ Audio Data
```

### Phase 3: 詳細データ設定

#### 3.1 Identifiers > Device ID
```
Data Use Purpose:
✅ Third-Party Advertising
✅ Analytics

Linked to User: ❌ No
Used for Tracking: ✅ Yes
```

#### 3.2 Usage Data > Product Interaction
```
Data Use Purpose:
✅ Analytics
✅ App Functionality

Linked to User: ❌ No
Used for Tracking: ✅ Yes
```

#### 3.3 Diagnostics > Crash Data
```
Data Use Purpose:
✅ App Functionality

Linked to User: ❌ No
Used for Tracking: ❌ No
```

#### 3.4 Diagnostics > Performance Data
```
Data Use Purpose:
✅ App Functionality

Linked to User: ❌ No
Used for Tracking: ❌ No
```

#### 3.5 Diagnostics > Other Diagnostic Data
```
Data Use Purpose:
✅ Third-Party Advertising

Linked to User: ❌ No
Used for Tracking: ❌ No
```

### Phase 4: トラッキング設定

#### 4.1 App Tracking設定
```
Q: Does this app use data for tracking?
A: ✅ Yes

Q: Do you or your third-party partners use data for tracking?
A: ✅ Yes, we and our partners use data for tracking
```

#### 4.2 トラッキング目的
```
✅ Third-Party Advertising
✅ Developer's Advertising or Marketing
```

### Phase 5: 追加設定

#### 5.1 プライバシーポリシー
```
Privacy Policy URL: https://[あなたのドメイン]/privacy-policy
※ docs/privacy_policy.md を Web公開する必要あり
```

#### 5.2 年齢適合性
```
Age Rating: 4+ (全年齢対象)
Made for Kids: ❌ No (一般向けアプリとして設定)
```

## 🔍 設定確認チェックリスト

### ✅ 必須設定項目
- [ ] データ収集: Yes
- [ ] Identifiers > Device ID: 設定完了
- [ ] Usage Data > Product Interaction: 設定完了  
- [ ] Diagnostics > 3項目: 設定完了
- [ ] トラッキング: Yes
- [ ] プライバシーポリシーURL: 設定完了

### ✅ 技術実装確認
- [x] PrivacyInfo.xcprivacy: 作成済み
- [x] NSUserTrackingUsageDescription: Info.plist追加済み
- [ ] プライバシーポリシー Web公開: 未実施

### ✅ 審査対応
- [ ] 設定保存・提出
- [ ] Apple審査待ち
- [ ] 承認後App Store公開

## ⚠️ 重要な注意点

### 設定時の注意
1. **過少申告禁止**: 実際より少なく申告すると審査リジェクト
2. **SDK依存**: 使用SDKのデータ収集内容に依存
3. **継続更新**: SDK更新時は設定見直し必要

### トラッキング許可
- iOS 14.5以降でトラッキング実行時、ユーザーに許可ダイアログ表示
- 拒否された場合も広告表示は可能（ターゲティング精度低下）
- 許可率向上のため、許可理由を明確に説明

### プライバシーポリシー
- App Store審査で必ずチェックされる
- 実装と完全一致している必要
- 日本語・英語両方対応推奨

## 🚨 よくある審査リジェクト理由

### 設定ミス
- プライバシーラベルと実装の不一致
- プライバシーポリシーURLアクセス不可
- トラッキング設定の不備

### 対策
- 実装前にSDK公式ドキュメント確認
- 保守的な設定（疑わしい場合は「収集する」）
- 定期的な設定見直し（3ヶ月毎）

## 📞 問題発生時の対応

### 審査リジェクト時
1. Apple からのフィードバック詳細確認
2. 該当する設定項目の修正
3. 再提出

### 設定変更時
1. App Store Connect で設定更新
2. 必要に応じてアプリ更新
3. ユーザーへの変更通知（重要な場合）