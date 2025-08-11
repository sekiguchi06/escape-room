#!/bin/bash

echo "🚀 自動ブラウザシミュレーションテスト開始..."

# 依存関係の更新
echo "📦 依存関係の更新..."
flutter pub get

# Chrome/Web環境でのテスト実行
echo "🌐 Chromeブラウザテスト実行..."
flutter drive \
  --driver=test_driver/browser_simulation_test.dart \
  --target=test_driver/app.dart \
  -d chrome

# テスト結果の確認
if [ $? -eq 0 ]; then
    echo "✅ 自動ブラウザテスト成功！"
    echo ""
    echo "📊 テスト概要:"
    echo "  - フレームワーク初期化テスト"
    echo "  - マルチセッション実行テスト" 
    echo "  - 設定変更サイクルテスト"
    echo "  - 長時間安定性テスト"
    echo "  - エラー発生確認テスト"
    echo ""
    echo "🎉 全ての自動テストが正常に完了しました！"
else
    echo "❌ 自動ブラウザテストが失敗しました"
    exit 1
fi