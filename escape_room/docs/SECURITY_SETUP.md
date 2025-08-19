# セキュリティ設定ガイド

## 🔒 機密情報の管理

### 環境設定ファイル
```bash
# .env.template をコピーして環境別設定を作成
cp .env.template .env.dev
cp .env.template .env.prod

# 実際の値を設定（絶対にgitにコミットしない）
vim .env.dev
vim .env.prod
```

### Google Services設定
```bash
# Firebase Console から GoogleService-Info.plist をダウンロード
# ios/Runner/GoogleService-Info.plist に配置（gitignore済み）

# Firebase Console から google-services.json をダウンロード
# android/app/google-services.json に配置（gitignore済み）
```

## ⚠️ 絶対にgitにコミットしてはいけないファイル

- `.env.dev`、`.env.prod`（環境設定）
- `GoogleService-Info.plist`（Firebase iOS設定）
- `google-services.json`（Firebase Android設定）
- `*.p12`、`*.p8`、`*.pem`（証明書類）
- `*.keystore`、`*.jks`（Android署名キー）

## ✅ gitに含めて良いファイル

- `.env.template`（テンプレート）
- `GoogleService-Info.plist.template`（テンプレート）
- `google-services.json.template`（テンプレート）

## 🛡️ セキュリティチェックリスト

- [ ] `.gitignore`に機密ファイルパターンが追加済み
- [ ] 既存の機密ファイルがgit追跡から除外済み
- [ ] テンプレートファイルが提供済み
- [ ] 実際のAPIキー・IDがダミー値または除外済み
- [ ] リモートリポジトリに機密情報が含まれていない

## 🔧 セットアップ手順

1. `.env.template`をコピーして環境設定作成
2. Firebase Consoleから設定ファイルダウンロード
3. Google AdMobから広告IDを取得
4. 各ファイルに実際の値を設定
5. アプリケーションビルド・テスト

## 📞 問題発生時

機密情報が誤ってコミットされた場合：
1. 即座にAPIキーを無効化・再生成
2. `git filter-branch`でコミット履歴から除去
3. リモートリポジトリに強制プッシュ
4. チーム全体に状況共有