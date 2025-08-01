# プラットフォーム設定テンプレート

このディレクトリには、カジュアルゲームテンプレートで使用するプラットフォーム固有の設定ファイルのテンプレートが含まれています。

## ディレクトリ構成

```
templates/platform_configs/
├── ios/
│   └── GoogleService-Info.plist.template  # iOS Firebase設定テンプレート
├── android/
│   └── google-services.json.template      # Android Firebase設定テンプレート
├── docs/
│   ├── platform_setup_guide.md           # プラットフォーム設定手順
│   └── framework_integration_guide.md    # フレームワーク統合ガイド
└── README.md                              # このファイル
```

## テンプレートの使用方法

### 1. Firebase/Google Ads 設定

新しいゲームプロジェクトを作成する際：

1. **iOS設定**:
   ```bash
   cp templates/platform_configs/ios/GoogleService-Info.plist.template ios/Runner/GoogleService-Info.plist
   ```

2. **Android設定**:
   ```bash
   cp templates/platform_configs/android/google-services.json.template android/app/google-services.json
   ```

3. テンプレート内の `YOUR_*` プレースホルダーを実際の値に置換

### 2. 詳細手順

- **初期設定**: `docs/platform_setup_guide.md` を参照
- **カスタム統合**: `docs/framework_integration_guide.md` を参照

## セキュリティ注意事項

- テンプレートファイルは安全（実際の認証情報は含まない）
- 実際の設定ファイルは `.gitignore` に追加することを推奨
- 本番用 API キーの管理には細心の注意を払う

## Mock モード

設定ファイルが存在しない場合、フレームワークは自動的に Mock モードで動作します：

- Firebase Analytics: ログ出力のみ（データ送信なし）
- Google Mobile Ads: テスト ID を使用

これにより設定完了前でも開発を進行できます。

## 更新履歴

- 2025-08-01: iOS/Android Firebase設定テンプレート、設定ガイド、統合ガイドを追加