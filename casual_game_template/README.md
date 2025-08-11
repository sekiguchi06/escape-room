# カジュアルゲーム開発フレームワーク

Flutter + Flameベースの汎用カジュアルゲーム開発フレームワーク

## 📚 ドキュメント

- **[AI_MASTER.md](docs/AI_MASTER.md)** - プロジェクト情報・技術仕様・実装ガイド
- **[CLAUDE.md](docs/CLAUDE.md)** - AI開発ルール・品質基準・禁止事項
- **[GAME_DEVELOPMENT_GUIDE.md](docs/GAME_DEVELOPMENT_GUIDE.md)** - ゲーム開発ガイド
- **[GAME_TEMPLATE_GUIDE.md](docs/GAME_TEMPLATE_GUIDE.md)** - テンプレートガイド

## テスト実行

### 自動テスト（人間の操作不要）
```bash
# 単体テスト
flutter test test/framework_extended_test.dart

# システムテスト  
flutter test test/system/simplified_system_test.dart

# 自動ブラウザテスト
./test/scripts/run_automated_browser_test.sh
```

### 手動テスト（人間の操作が必要）
```bash
# ブラウザで手動確認
./test/scripts/run_manual_browser_test.sh
```

## 自動テストの完了条件

- フレームワーク初期化: 10秒以内
- マルチセッション実行: 3セッション完了
- 設定変更サイクル: 4サイクル完了
- 長時間安定性: 2分間エラー0件
- 連続タップストレス: クラッシュ0件

全て自動判定されるため、人間の確認は不要です。