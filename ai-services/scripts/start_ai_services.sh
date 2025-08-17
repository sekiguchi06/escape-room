#!/bin/bash

echo "🚀 AI Services Setup - Starting Image Generation Services"
echo "========================================================"

# 設定ファイルの読み込み
CONFIG_FILE="../configs/ai_services_config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# 環境変数の設定
export COMFYUI_API_URL="http://127.0.0.1:8188"
export WEBUI_API_URL="http://127.0.0.1:7860"
export OUTPUT_DIR="/Users/sekiguchi/.ai-services/output"

# ログディレクトリの作成
mkdir -p ~/ai-services/Logs

# LoRAファイルのチェック
echo "🔍 Checking LoRA files..."
../tools/check_lora_files.sh

echo ""
echo "🎨 Starting ComfyUI..."
./start_comfyui.sh &
COMFYUI_PID=$!

echo "⏳ Waiting for ComfyUI to start..."
for i in {1..30}; do
    if curl -s http://127.0.0.1:8188/ > /dev/null 2>&1; then
        echo "✅ ComfyUI started successfully!"
        break
    fi
    sleep 1
    if [ $i -eq 30 ]; then
        echo "❌ ComfyUI failed to start"
        exit 1
    fi
done

echo ""
echo "📊 Service Status:"
echo "ComfyUI: http://127.0.0.1:8188 ✅"
echo "WebUI: http://127.0.0.1:7860 (manual start if needed)"
echo ""
echo "🎯 Ready for LoRA image generation!"
echo "📁 Output directory: $OUTPUT_DIR"
echo "📁 ComfyUI output: /Users/sekiguchi/ai-services/ComfyUI/ComfyUI/output"