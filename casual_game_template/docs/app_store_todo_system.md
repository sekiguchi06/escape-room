# App Store公開 - 実行可能TODOシステム

## 🎯 AI実行可能タスク（即座実行）

### Phase A: コンプライアンス対応
```bash
# ✅ AI実行可能 - プライバシーマニフェスト作成
TASK_ID: privacy-manifest-creation
PRIORITY: 🚨 緊急（2024年5月以降必須）
EXECUTION: 即座実行可能
DEPENDENCIES: なし
LOCATION: ios/Runner/PrivacyInfo.xcprivacy
STATUS: ⏳ 待機中
```

```bash
# ✅ AI実行可能 - プライバシーラベル準備
TASK_ID: privacy-labels-preparation  
PRIORITY: 🔥 高（App Store Connect設定前必須）
EXECUTION: 即座実行可能
DEPENDENCIES: なし
DELIVERABLE: データ収集項目一覧ドキュメント
STATUS: ⏳ 待機中
```

### Phase B: アセット作成
```bash
# ✅ AI実行可能 - アプリアイコン作成
TASK_ID: app-icon-generation
PRIORITY: 🔥 高（App Store Connect設定必須）
EXECUTION: 即座実行可能  
DEPENDENCIES: なし
SIZES: 1024x1024 + 全iOS要求サイズ
LOCATION: ios/Runner/Assets.xcassets/AppIcon.appiconset/
STATUS: ⏳ 待機中
```

```bash
# ✅ AI実行可能 - スクリーンショット作成
TASK_ID: screenshot-generation
PRIORITY: 🔥 高（App Store Connect設定必須）
EXECUTION: ゲーム実行後実行可能
DEPENDENCIES: ゲーム動作確認
SIZES: iPhone 6.5"/5.5", iPad 12.9" (各3枚)
STATUS: ⏳ 待機中
```

## 🚫 人間介入必須タスク（AI実行不可）

### Phase C: アカウント・支払い
```bash
# ❌ 人間のみ - Apple Developer Program
TASK_ID: apple-developer-enrollment
PRIORITY: 🚨 最優先（全作業の前提）
HUMAN_ACTION: https://developer.apple.com/programs/ で$99支払い
TIME_REQUIRED: 24-48時間（審査含む）
BLOCKER: アカウント・支払い情報
STATUS: 🔴 未実行
```

```bash
# ❌ 人間のみ - Firebase本番プロジェクト
TASK_ID: firebase-production-setup
PRIORITY: 🔥 高（プロダクション必須）
HUMAN_ACTION: Firebase Console でプロジェクト作成
DEPENDENCIES: Googleアカウント
CURRENT: テスト用設定
STATUS: 🔴 未実行
```

```bash
# ❌ 人間のみ - AdMob本番設定
TASK_ID: admob-production-setup  
PRIORITY: 🔥 高（収益化必須）
HUMAN_ACTION: AdMob アカウント作成・広告ユニット作成
DEPENDENCIES: Googleアカウント・税務情報
CURRENT: テスト用ID ca-app-pub-3940256099942544~1458002511
STATUS: 🔴 未実行
```

### Phase D: App Store操作
```bash
# ❌ 人間のみ - App Store Connect設定
TASK_ID: app-store-connect-setup
PRIORITY: 🔥 高（公開直前必須）
HUMAN_ACTION: appstoreconnect.apple.com でアプリ作成・設定
DEPENDENCIES: Apple Developer Program完了
PREPARED: docs/app_store_metadata.md で設定内容準備済み
STATUS: 🔴 未実行
```

## 📊 実行状況トラッキング

### 現在の実行可能状況
| Phase | タスク | AI実行 | 人間介入 | ステータス | 依存関係 |
|-------|--------|---------|----------|------------|----------|
| A | プライバシーマニフェスト | ✅ | - | ⏳待機 | なし |
| A | プライバシーラベル | ✅ | - | ⏳待機 | なし |
| B | アプリアイコン | ✅ | - | ⏳待機 | なし |
| B | スクリーンショット | ✅ | - | ⏳待機 | ゲーム実行 |
| C | Apple Developer | - | ❌ | 🔴未実行 | 支払い |
| C | Firebase本番 | - | ❌ | 🔴未実行 | アカウント |
| C | AdMob本番 | - | ❌ | 🔴未実行 | アカウント |
| D | App Store Connect | - | ❌ | 🔴未実行 | Developer完了 |

### 推奨実行順序
```bash
# 🚀 今すぐ実行可能（AI）
1. プライバシーマニフェスト作成 → 即座実行
2. アプリアイコン作成 → 即座実行  
3. スクリーンショット作成 → ゲーム動作確認後実行

# ⏳ 人間介入待ち
4. Apple Developer Program登録 → 人間が実行
5. Firebase・AdMob設定 → 人間が実行
6. App Store Connect設定 → 人間が実行
```

## 🔄 ステータス更新システム

### ステータス定義
- ⏳ **待機中**: 実行可能、未着手
- 🟡 **実行中**: 作業進行中
- ✅ **完了**: 作業完了・確認済み
- 🔴 **未実行**: 人間介入必須・未着手
- ⚠️ **ブロック**: 依存関係により実行不可

### 更新ルール
1. **AI実行タスク**: 着手時に🟡、完了時に✅
2. **人間介入タスク**: 完了まで🔴維持
3. **依存関係**: 前提未完了時は⚠️ブロック
4. **毎日更新**: 進捗状況を日次で更新

## 🎯 完了判定基準

### Phase A完了条件
- [x] プライバシーマニフェスト: PrivacyInfo.xcprivacy ファイル存在
- [x] プライバシーラベル: App Store Connect設定用データ完成

### Phase B完了条件  
- [x] アプリアイコン: 1024x1024サイズ + 全要求サイズ生成
- [x] スクリーンショット: 3機種 × 3枚 = 9枚作成

### 最終完了条件
- [x] App Store Connect でアプリ公開申請完了
- [x] 審査ステータス "In Review" 確認
- [x] プライバシー・コンプライアンス要件100%クリア