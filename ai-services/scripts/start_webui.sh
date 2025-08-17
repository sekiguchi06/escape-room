#!/bin/bash
cd ~/ai-services/StableDiffusion/stable-diffusion-webui

# ログファイルの設定
LOG_FILE="~/ai-services/Logs/webui-$(date +%Y%m%d).log"

echo "$(date): Starting Stable Diffusion WebUI API..." >> "$LOG_FILE"

./webui.sh \
  --api \
  --listen \
  --port 7860 \
  --enable-insecure-extension-access \
  --ckpt-dir /Users/sekiguchi/ai-services/Models/checkpoints \
  --vae-dir /Users/sekiguchi/ai-services/Models/vae \
  --lora-dir /Users/sekiguchi/ai-services/Models/loras \
  --embeddings-dir /Users/sekiguchi/ai-services/Models/embeddings \
  --skip-torch-cuda-test \
  --upcast-sampling \
  --no-half-vae \
  --use-cpu interrogate