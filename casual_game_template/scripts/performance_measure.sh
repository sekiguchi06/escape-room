#!/bin/bash
# パフォーマンス測定スクリプト
# Flutter Guide第10章に基づくProfileモード性能測定

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RESULTS_DIR="$PROJECT_ROOT/performance_results"

# 結果保存ディレクトリの作成
mkdir -p "$RESULTS_DIR"

# タイムスタンプ
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
RESULT_FILE="$RESULTS_DIR/performance_$TIMESTAMP.json"

echo "🚀 パフォーマンス測定開始 - $TIMESTAMP"

# 現在のディレクトリをプロジェクトルートに変更
cd "$PROJECT_ROOT"

# Profileモードビルド時間測定
echo "📱 Profileモードビルド時間測定中..."
BUILD_START=$(date +%s.%N)

# Webプラットフォーム用Profileビルド
flutter build web --profile > "$RESULTS_DIR/build_output_$TIMESTAMP.log" 2>&1

BUILD_END=$(date +%s.%N)
BUILD_TIME=$(echo "$BUILD_END - $BUILD_START" | bc)

echo "✅ ビルド完了: ${BUILD_TIME}秒"

# Webアプリサイズ測定
WEB_SIZE=$(du -sh build/web | cut -f1)
echo "📦 Webアプリサイズ: $WEB_SIZE"

# パフォーマンス結果をJSONで保存
cat > "$RESULT_FILE" << EOF
{
  "timestamp": "$TIMESTAMP",
  "measurements": {
    "build_time_seconds": $BUILD_TIME,
    "web_app_size": "$WEB_SIZE",
    "flutter_version": "$(flutter --version | head -n1)",
    "dart_version": "$(dart --version | cut -d' ' -f4)",
    "platform": "$(uname -s)"
  },
  "performance_targets": {
    "build_time_target_seconds": 60,
    "web_app_size_target_mb": "10MB",
    "target_fps": 60,
    "startup_time_target_ms": 3000
  },
  "status": {
    "build_time_met": $(echo "$BUILD_TIME < 60" | bc),
    "measurement_completed": true
  }
}
EOF

echo "📊 パフォーマンス結果保存: $RESULT_FILE"

# 結果表示
echo "
=== パフォーマンス測定結果 ===
ビルド時間: ${BUILD_TIME}秒 (目標: 60秒以下)
Webアプリサイズ: $WEB_SIZE (目標: 10MB以下)
結果ファイル: $RESULT_FILE
"

# 基準値チェック
if (( $(echo "$BUILD_TIME > 60" | bc -l) )); then
    echo "⚠️  警告: ビルド時間が基準値(60秒)を超えています"
    exit 1
fi

echo "✅ パフォーマンス測定完了"