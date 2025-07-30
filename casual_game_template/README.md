# カジュアルゲーム開発フレームワーク

Flutter + Flameベースの汎用カジュアルゲーム開発フレームワーク

## テスト実行

### 自動テスト（人間の操作不要）
```bash
# 単体テスト
flutter test test/framework_extended_test.dart

# システムテスト  
flutter test test/system/simplified_system_test.dart

# 自動ブラウザテスト
./scripts/run_automated_browser_test.sh
```

### 手動テスト（人間の操作が必要）
```bash
# ブラウザで手動確認
./scripts/run_manual_browser_test.sh
```

## 自動テストの完了条件

- フレームワーク初期化: 10秒以内
- マルチセッション実行: 3セッション完了
- 設定変更サイクル: 4サイクル完了
- 長時間安定性: 2分間エラー0件
- 連続タップストレス: クラッシュ0件

全て自動判定されるため、人間の確認は不要です。