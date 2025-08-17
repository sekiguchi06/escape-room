# App Store リリーステンプレートシステム

## システム概要
カジュアルゲーム量産に向けたApp Store公開設定の標準化・効率化システム

## テンプレートファイル構成

### 1. 汎用設定テンプレート
**ファイル**: `templates/platform_configs/app_release_template.json`

**特徴**:
- 変数テンプレート方式: {{APP_NAME}}, {{BUNDLE_IDENTIFIER}}, {{GAME_GENRE}}等
- App Store公開に必要な全設定項目を網羅
- 段階的リリースフロー（Phase1-3）定義
- 多言語対応（日本語・英語標準）

**主要セクション**:
```json
{
  "app_metadata": { "app_name": "{{APP_NAME}}" },
  "app_store_metadata": { "category": "{{APP_STORE_CATEGORY}}" },
  "game_specific": { "genre": "{{GAME_GENRE}}" },
  "technical_requirements": {},
  "monetization": {},
  "assets": {},
  "build_configuration": {},
  "release_workflow": { "phases": [...] }
}
```

### 2. 脱出ゲーム専用設定
**ファイル**: `templates/platform_configs/escape_room_release_config.json`

**実装済み設定値**:
- アプリ名: "Escape Master" / "脱出マスター"
- Bundle ID: com.casualgames.escapemaster
- カテゴリ: Games > Puzzle
- 年齢制限: 4+ (全年齢対象)
- 価格: 無料 (広告収益モデル)

## 使用方法・量産フロー

### 新規ゲーム対応手順
1. **設定ファイル作成**: `app_release_template.json`をコピー
2. **変数置換**: ゲーム固有の値に{{変数}}を一括置換
3. **iOS設定適用**: Bundle ID・アプリ名をproject.pbxproj、Info.plistに反映
4. **ドキュメント生成**: メタデータ・プライバシーポリシー自動生成

### Phase別実行フロー
```
Phase 1: Asset Creation (アセット作成)
├── アプリアイコン作成 (1024x1024)
├── 全サイズアイコン自動生成  
├── ローンチスクリーン作成
└── スクリーンショット撮影

Phase 2: App Store Configuration (App Store設定)
├── App Store Connect アプリ作成
├── メタデータ設定 (日本語・英語)
├── アセットアップロード
└── コンプライアンス設定

Phase 3: Build and Submit (ビルド・提出)
├── iOS Release ビルド作成
├── コード署名・証明書設定
├── App Store Connect アップロード
└── 審査申請
```

## 標準化されたドキュメント

### App Store メタデータテンプレート
**ファイル**: `docs/app_store_metadata.md`

**内容**:
- 基本情報 (アプリ名・Bundle ID・バージョン)
- カテゴリ・分類設定
- 日本語版メタデータ (説明文・キーワード・プロモーションテキスト)
- 英語版メタデータ (同上)
- スクリーンショット説明文
- App Store Connect設定チェックリスト

### プライバシーポリシーテンプレート
**ファイル**: `docs/privacy_policy.md`

**特徴**:
- Google Mobile Ads データ収集対応
- Firebase Analytics データ収集対応
- COPPA対応 (13歳未満ユーザー対応)
- 日本語・英語完全対応
- App Store審査基準準拠

## 技術仕様・依存関係

### Flutter/iOS設定連携
```
pubspec.yaml (version: 1.0.0+1)
    ↓
ios/Runner/Info.plist (CFBundleShortVersionString: $(FLUTTER_BUILD_NAME))
    ↓  
ios/Runner.xcodeproj/project.pbxproj (PRODUCT_BUNDLE_IDENTIFIER)
```

### 必須SDK・サービス
- Flutter 3.8.1+
- Flame 1.30.1 (ゲームエンジン)
- Google Mobile Ads 6.0.0 (収益化)
- Firebase Analytics 10.7.4 (分析)
- Firebase Core 2.24.2 (基盤)

## 品質保証・テスト要件

### 必須テスト項目
1. **単体テスト**: 100%成功率必須
2. **統合テスト**: フレームワーク連携確認
3. **ブラウザシミュレーション**: 実動作確認
4. **iOS Simulator**: デバイス互換性確認

### パフォーマンス基準
- アプリ起動時間: < 3秒
- メモリ使用量: < 100MB
- バッテリー使用量: 低
- ネットワーク使用量: 最小限

## 量産効果・ROI

### 開発効率化
- **初回**: 設定・ドキュメント作成 4-6時間 → **2回目以降**: 設定値変更のみ 20-30分
- **エラー削減**: 標準化により設定ミス・審査差し戻しリスク大幅削減
- **品質保証**: テンプレート適用により一定品質保証

### 月間量産目標
- **目標**: 月4本リリース
- **1本あたり工数**: App Store公開準備 30分以内
- **年間効果**: 48本 × 4時間短縮 = 192時間削減

## 改善・拡張予定

### 次期バージョン機能
1. **自動化スクリプト**: 設定値一括置換・ファイル更新
2. **アイコン生成**: 1024x1024から全サイズ自動生成
3. **スクリーンショット**: ゲームプレイ自動撮影
4. **CI/CD統合**: GitHub Actions連携での自動App Store準備