# MCP画像生成サーバー トラブルシューティングガイド

**作成日**: 2025-08-18  
**対象**: 後続AI・開発者向け  
**前提**: Claude Code + MCP + ComfyUI構成

## 🚨 よくあるエラーと解決法

### 1. MCP接続エラー: "No such tool available"

#### **症状**
```
Error: No such tool available: mcp__global-image-generation__check_services
```

#### **根本原因**
- `.mcp.json`でnodeコマンドパスが相対指定
- Claude CodeがMCPサーバープロセスを起動できない

#### **診断手順**
```bash
# 1. nodeパス確認
which node
# → /opt/homebrew/bin/node (Homebrew環境)
# → /usr/local/bin/node (その他環境)

# 2. MCPサーバー手動起動テスト
cd /path/to/ai-services/server/
NODE_ENV=production node server.js
# エラーなしで待機状態になれば起動成功

# 3. 設定ファイル確認
cat .mcp.json | grep "command"
```

#### **解決法**
```json
// .mcp.json を修正
{
  "mcpServers": {
    "global-image-generation": {
      "command": "/opt/homebrew/bin/node",  // 絶対パスに変更
      "args": ["/Users/sekiguchi/git/escape-room/ai-services/server/server.js"]
    }
  }
}
```

#### **確認方法**
1. Claude Code再起動
2. `mcp__global-image-generation__check_services` 実行
3. 正常レスポンス確認

---

### 2. ComfyUI BrokenPipeError

#### **症状**
```
ComfyUI execution error: [Errno 32] Broken pipe
Request failed with status code 400
Generation timeout
```

#### **根本原因**
- ComfyUIがモデルファイルにアクセスできない
- カスタムモデルパス設定が認識されていない

#### **診断手順**
```bash
# 1. モデルファイル存在確認
find ~/ai-services/ -name "*.safetensors" -type f
# → /Users/sekiguchi/ai-services/Models/checkpoints/Counterfeit-V3.0_fp16.safetensors

# 2. ComfyUI設定確認
cat ~/ai-services/ComfyUI/ComfyUI/extra_model_paths.yaml

# 3. ComfyUI APIでモデル一覧確認
curl -s http://127.0.0.1:8188/object_info | jq '.CheckpointLoaderSimple.input.required.ckpt_name[0]'
```

#### **解決法**
```bash
# ComfyUI再起動でカスタムパス再読み込み
pkill -f "python.*main\.py.*8188"
bash ~/git/escape-room/ai-services/scripts/start_comfyui.sh
```

#### **確認方法**
1. 起動ログで「Adding extra search path checkpoints /Users/sekiguchi/ai-services/Models/checkpoints」確認
2. API経由でモデル一覧にCounterfeit-V3.0_fp16.safetensors存在確認
3. テスト画像生成実行

---

### 3. 環境変数読み込みエラー

#### **症状**
- OUTPUT_DIRが期待されるパスと異なる
- デフォルト値が適用されている

#### **解決法**
```javascript
// server.js にdotenv追加済み（2025-08-18対応済み）
import { config } from 'dotenv';
config({ path: path.join(process.cwd(), '../../.env') });
```

---

## 🔧 定期メンテナンス手順

### 毎セッション開始時
1. **MCP接続確認**: `mcp__global-image-generation__check_services`
2. **ComfyUI状態確認**: `curl -s http://127.0.0.1:8188/system_stats`
3. **モデル一覧確認**: `mcp__global-image-generation__list_models`

### エラー発生時
1. **ログ確認**: ComfyUIプロセス出力・Claude Codeログ
2. **設定ファイル確認**: `.mcp.json`, `extra_model_paths.yaml`, `.env`
3. **プロセス再起動**: ComfyUI → Claude Code の順

### 環境変更時
1. **MCP設定変更後**: Claude Code再起動必須
2. **ComfyUI設定変更後**: ComfyUIプロセス再起動必須
3. **モデル追加後**: ComfyUI再起動でスキャン更新

---

## 📋 チェックリスト（後続AI用）

### プロジェクト引き継ぎ時
- [ ] MCP接続テスト実行
- [ ] ComfyUI動作確認
- [ ] モデル・LoRAファイル存在確認
- [ ] 出力ディレクトリ書き込み権限確認
- [ ] テスト画像生成実行

### 新環境セットアップ時
- [ ] nodeパス確認・絶対パス設定
- [ ] ComfyUIカスタムパス設定
- [ ] 環境変数ファイル配置
- [ ] 必要ディレクトリ作成
- [ ] 権限設定確認

---

## ⚠️ 重要な注意事項

1. **MCP設定変更時は必ずClaude Code再起動**
2. **ComfyUI設定変更時は必ずComfyUI再起動**
3. **相対パスではなく絶対パスを使用**
4. **エラー発生時はログの詳細確認を最優先**
5. **モデルファイルの物理的存在を必ず確認**

このガイドにより、同様のMCP接続・ComfyUI画像生成エラーの再発を防止できます。