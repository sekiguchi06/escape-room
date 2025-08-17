#!/bin/bash
export PYTORCH_ENABLE_MPS_FALLBACK=1
export PYTORCH_MPS_HIGH_WATERMARK_RATIO=0.0

# ComfyUIが既に起動しているかチェック
check_comfyui() {
    curl -s "http://127.0.0.1:8188/system_stats" > /dev/null 2>&1
    return $?
}

echo "ComfyUIの起動状況を確認中..."
if check_comfyui; then
    echo "✅ ComfyUIは既に起動中です (http://127.0.0.1:8188)"
    exit 0
fi

echo "ComfyUIが停止中です。起動します..."

cd ~/ai-services/ComfyUI/ComfyUI
source ../venv-system/bin/activate

# ログファイルの設定
LOG_FILE="$HOME/ai-services/Logs/comfyui-$(date +%Y%m%d).log"

echo "$(date): Starting ComfyUI API..." >> "$LOG_FILE"

python main.py \
  --listen 0.0.0.0 \
  --port 8188 \
  --enable-cors-header