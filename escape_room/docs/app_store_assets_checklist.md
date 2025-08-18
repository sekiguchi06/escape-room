# Escape Master - App Store Assets Checklist

## Phase 2: App Store準備 - 進行状況

### 📱 アプリアイコン作成 ✅ 完了済み
- [x] 1024x1024 マスターアイコン作成 (脱出ゲームテーマ: 鍵・ドア・謎解きモチーフ)
- [x] 全サイズアイコン自動生成 (15サイズ完全実装: 20x20 〜 1024x1024)
- [x] iOS Assets.xcassets/AppIcon.appiconset/ へ配置完了
- [x] アイコン表示確認 完了 (Contents.json適切設定済み)

### 📸 スクリーンショット撮影
- [ ] iPhone 6.5" (1284×2778) - 3枚
  - [ ] ゲームプレイ画面 (部屋探索)
  - [ ] インベントリ画面 (アイテム管理)  
  - [ ] パズル画面 (謎解き)
- [ ] iPhone 5.5" (1242×2208) - 3枚 (同上)
- [ ] iPad 12.9" (2048×2732) - 3枚 (同上)

### 🎨 ローンチスクリーン
- [ ] ダークブルー基調 (#2C3E50) のローンチスクリーン作成
- [ ] Escape Master ロゴ配置
- [ ] iOS LaunchScreen.storyboard 更新

### 📝 App Store メタデータ ✅ 完了済み
#### 日本語版
- [x] アプリ名: "脱出マスター"
- [x] サブタイトル: "5分間で脱出せよ！究極のパズル体験"
- [x] 説明文: 完全作成済み (docs/app_store_metadata.md)
- [x] キーワード: "脱出ゲーム,パズル,謎解き,カジュアルゲーム,アドベンチャー"
- [x] プロモーションテキスト: "制限時間内に部屋から脱出せよ！"

#### 英語版 ✅ 完了済み
- [x] アプリ名: "Escape Master"
- [x] サブタイトル: "Ultimate 5-Minute Escape Challenge"
- [x] 説明文: 英語版完全作成済み (docs/app_store_metadata.md)
- [x] キーワード: "escape game,puzzle,mystery,casual game,adventure"

### 🏪 App Store Connect設定
- [ ] 新規アプリ作成 ("Escape Master")
- [ ] Bundle ID設定: com.casualgames.escapemaster
- [ ] カテゴリ: Games > Puzzle  
- [ ] 年齢制限: 4+ (全年齢対象)
- [ ] 価格設定: 無料 (広告収益モデル)
- [ ] 配信地域: 全世界

### 📋 コンプライアンス ✅ 完了済み
- [x] プライバシーポリシー作成・公開準備完了 (docs/privacy_policy.md)
- [x] データ収集に関する開示完了 (docs/privacy_labels_data.md)
- [x] プライバシーマニフェスト実装済み (ios/Runner/PrivacyInfo.xcprivacy)
- [x] Google Mobile Ads データ収集設定完了
  - [ ] Firebase Analytics データ収集
- [ ] COPPA対応 (13歳未満対応)

## 必要なアセット一覧

### アプリアイコン (PNG, sRGB色空間)
- 1024x1024 (App Store用)
- 180x180 (iPhone @3x)
- 120x120 (iPhone @2x)
- 167x167 (iPad Pro)
- 152x152 (iPad @2x)
- 76x76 (iPad @1x)
- その他各サイズ

### スクリーンショット仕様
- フォーマット: PNG
- 色空間: sRGB
- 透明度: なし
- 角の丸み: なし
- iPhone 6.5": 1284×2778
- iPhone 5.5": 1242×2208  
- iPad 12.9": 2048×2732

### 推奨撮影内容
1. **ゲームプレイ画面**: メインの部屋探索・タップ操作
2. **インベントリ画面**: アイテム管理・組み合わせ
3. **パズル画面**: 謎解き・コード入力・達成感

## 完了基準
- [ ] 全アセット作成完了・品質確認済み
- [ ] App Store Connect完全設定済み
- [ ] メタデータ最終確認・校正完了
- [ ] コンプライアンス要件満足
- [ ] 審査提出準備完了