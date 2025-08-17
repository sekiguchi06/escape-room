#!/bin/bash

LORA_DIR="/Users/sekiguchi/ai-services/Models/loras"
echo "Checking LoRA files in: $LORA_DIR"

for file in "$LORA_DIR"/*.safetensors; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        filesize=$(stat -f%z "$file")
        filetype=$(file "$file" | cut -d: -f2)
        
        # LoRAファイルは通常1MB以上
        if [ $filesize -lt 1000000 ]; then
            echo "❌ SMALL: $filename ($filesize bytes) - $filetype"
        elif [[ "$filetype" == *"Zip archive"* ]]; then
            echo "❌ CORRUPTED: $filename - Zip archive detected"
        else
            echo "✅ OK: $filename ($filesize bytes)"
        fi
    fi
done