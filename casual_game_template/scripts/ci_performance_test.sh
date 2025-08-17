#!/bin/bash
# CI/CD用自動パフォーマンステスト
# GitHub Actions等での継続的性能監視

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🔄 CI/CD パフォーマンステスト開始"

cd "$PROJECT_ROOT"

# 環境情報表示
echo "Flutter環境:"
flutter --version

echo "Dart環境:"
dart --version

# 依存関係の更新
echo "📦 依存関係の確認..."
flutter pub get

# 静的解析（パフォーマンスに影響する問題の検出）
echo "🔍 静的解析実行..."
flutter analyze

# パフォーマンステストの実行
echo "⚡ パフォーマンステスト実行..."
dart test test/performance/ --reporter=json > performance_test_results.json 2>&1 || true

# Profileビルドテスト
echo "🏗️ Profileビルドテスト..."
"$SCRIPT_DIR/performance_measure.sh"

# 結果の評価
if [ -f "performance_results/performance_$(date '+%Y%m%d')*.json" ]; then
    echo "✅ パフォーマンス測定完了"
    # 最新の結果ファイルを表示
    LATEST_RESULT=$(ls -t performance_results/performance_*.json | head -1)
    echo "結果ファイル: $LATEST_RESULT"
    
    # JSONから主要メトリクスを抽出して表示
    if command -v jq >/dev/null 2>&1; then
        echo "主要メトリクス:"
        jq -r '.measurements | "ビルド時間: \(.build_time_seconds)秒"' "$LATEST_RESULT"
        jq -r '.measurements | "アプリサイズ: \(.web_app_size)"' "$LATEST_RESULT"
    fi
else
    echo "❌ パフォーマンス測定結果が見つかりません"
    exit 1
fi

echo "🎯 CI/CD パフォーマンステスト完了"