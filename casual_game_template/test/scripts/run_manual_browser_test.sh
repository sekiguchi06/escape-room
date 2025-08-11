#!/bin/bash

echo "🎮 手動ブラウザシミュレーションテスト開始..."

# 依存関係の更新
echo "📦 依存関係の更新..."
flutter pub get

# Chrome/Web環境でアプリ起動
echo "🌐 Chromeブラウザでアプリ起動..."
echo ""
echo "🔍 手動テスト項目:"
echo "  1. アプリが正常に起動することを確認"
echo "  2. 「TAP TO START」が表示されることを確認"
echo "  3. タップしてゲームが開始することを確認"
echo "  4. タイマーが正常に動作することを確認"
echo "  5. ゲームオーバー後にリスタートできることを確認"
echo "  6. 設定が循環的に変更されることを確認 (Default → easy → hard → Default)"
echo "  7. 複数セッション実行が正常に動作することを確認"
echo ""
echo "⚠️  手動テスト完了後、ターミナルで 'q' を押してアプリを終了してください"
echo ""

flutter run -d chrome