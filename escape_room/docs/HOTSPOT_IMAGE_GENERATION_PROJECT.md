# 脱出ゲーム ホットスポット画像生成プロジェクト - 継続検討用まとめ

**作成日**: 2025-08-18  
**ステータス**: 進行中（MCP問題調査段階）  
**担当**: Claude Code → 次期AI継続予定

## 🎯 プロジェクト概要

### 目標
- 現在の可視化されているホットスポットを廃止
- 透明・不可視のホットスポットを背景画像に合わせて設定（1画面に3-5個）
- 背景画像と連動したホットスポット画像（正方形）を生成
- アイテム取得・組み合わせ・消費システム（最大5個制限）
- ゲームクリアまでの道筋作成と進行度管理システム連動

### 技術仕様
- **統一画像サイズ**: 400x600ピクセル（全背景画像）
- **ホットスポット画像**: 100x100正方形
- **座標配置**: 絶対座標（画像サイズ統一により実現）
- **対象デバイス**: iOS/Android縦向きのみ

## 📋 現在の実装状況

### ✅ 完了した調査

#### 1. MCPリソース確認
- **ComfyUI**: 稼働中（ポート8188）
- **Checkpointモデル**: `Counterfeit-V3.0_fp16.safetensors`（高品質アニメ風）
- **LoRAモデル**: 7種類利用可能
  - `isometric_dreams.safetensors` - ゲーム背景生成用
  - `game_icon_institute_2d.safetensors` - ゲームアイコン生成用
  - `ui_ux_design.safetensors` - UI要素生成用
  - `pixel_art_xl.safetensors` - レトロ風アセット生成用
  - その他3種類

#### 2. 既存背景画像分析
| ファイル | 内容 | 特徴的要素 | 推奨ホットスポット位置 |
|---------|------|-----------|---------------------|
| `room_left.png` | ゴシック石造回廊 | 石柱、アーチ天井、光と影 | 左柱(80,200)、中央床(200,450)、右壁(320,250) |
| `room_right.png` | 錬金術室・薬草貯蔵庫 | 木製棚、多数の瓶、ランタン | 左棚(50,300)、中央棚(200,200)、右棚(350,350) |
| `room_leftmost.png` | 地下通路・トンネル | アーチ型石壁、青い光の出口 | 左壁(60,250)、通路中央(200,400)、奥の光(200,150) |
| `room_rightmost.png` | 宝物庫・装飾品展示室 | 金色テーブル、装飾壺、宝箱 | テーブル左(150,350)、テーブル右(250,350)、背景装飾(200,200) |

#### 3. ホットスポットシステム確認
- **現在の実装**: `HotspotComponent`（固定座標、要修正）
- **UI対応状況**: `ResponsiveLayoutCalculator`でUI要素は相対座標対応済み
- **必要な改修**: 背景画像座標系との統合

## ⚠️ 発見された技術課題

### 🔥 緊急: MCP接続エラー & ComfyUI BrokenPipeError（2025-08-18解決済み）

#### **根本原因**
1. **MCP接続失敗**: `node`パス解決の問題
   - 症状: `No such tool available: mcp__global-image-generation__xxx`
   - 原因: `.mcp.json`でnodeコマンドのパスが相対指定
   - 解決: 絶対パス指定 → `/opt/homebrew/bin/node`

2. **ComfyUI BrokenPipeError**: モデルファイルアクセス不可
   - 症状: `[Errno 32] Broken pipe` 画像生成中にプロセス強制終了
   - 原因: ComfyUIがカスタムモデルパスを認識せず、存在しないモデルにアクセス
   - 解決: ComfyUI再起動で`extra_model_paths.yaml`を再読み込み

#### **修正内容**
```json
// .mcp.json（修正前）
"command": "node"
// .mcp.json（修正後）  
"command": "/opt/homebrew/bin/node"
```

```javascript
// server.js（追加）
import { config } from 'dotenv';
config({ path: path.join(process.cwd(), '../../.env') });
const OUTPUT_DIR = process.env.OUTPUT_DIR || path.join(os.homedir(), '.ai-services', 'output');
```

#### **確認手順（後続AI用）**
1. **MCP接続確認**: `mcp__global-image-generation__check_services` 実行
2. **モデルファイル確認**: `find ~/ai-services/ -name "*.safetensors"` でモデル存在確認
3. **ComfyUI設定確認**: `extra_model_paths.yaml`でカスタムパス設定確認
4. **ComfyUI再起動**: `bash ~/git/escape-room/ai-services/scripts/start_comfyui.sh`
5. **テスト生成**: 最小パラメータで画像生成テスト実行

#### **予防策**
- MCP設定変更後は必ずClaude Code再起動
- ComfyUI設定変更後は必ずComfyUI再起動
- モデルファイルの物理的存在確認を最初に実行
- 環境変数は.envファイルで統一管理

## ⚠️ その他の技術課題

### MCPサーバー統合問題
- **問題**: Claude CodeがMCPサーバーを認識しない
- **原因**: `.claude/claude_project_config.json`に`type: "stdio"`が欠けていた
- **対応**: 設定修正済み、但しClaude Code再起動が必要
- **検証結果**: MCPサーバー自体は正常動作（直接JSONRPC通信確認済み）

### ComfyUI API問題
- **エラー**: BrokenPipeError発生
- **影響**: 画像生成プロセスが中断
- **原因**: プロセス間通信の問題
- **回避策**: MCPサーバー経由での生成に切り替え

## 🛠️ 推奨する継続アプローチ

### Option A: MCP修復後の画像生成（推奨）
```javascript
// MCPサーバー経由での生成パラメータ
{
  "prompt": "medieval gothic stone corridor, ancient castle interior, detailed architecture, game background art",
  "negative_prompt": "blurry, low quality, modern elements, people, characters, text, watermark",
  "width": 400,
  "height": 600,
  "steps": 20,
  "cfg_scale": 7.0,
  "sampler": "euler",
  "model": "Counterfeit-V3.0_fp16.safetensors",
  "lora": "isometric_dreams.safetensors",
  "lora_strength": 0.7,
  "output_name": "escape_room_corridor_400x600"
}
```

### Option B: 既存画像リサイズ（即座に実行可能）
1. 既存4枚の背景画像を400x600にリサイズ
2. `ResponsiveHotspotComponent`の実装
3. 相対座標→絶対座標変換システム

### Option C: 外部画像生成サービス
- Midjourney、DALL-E等での背景画像生成
- 400x600仕様での一括生成
- プロンプト例：`"medieval stone corridor, 400x600 pixels, game background art"`

## 🎮 ホットスポット座標配置計画

### 座標システム設計
```dart
// 提案する新しいホットスポットコンポーネント
class ResponsiveHotspotComponent extends HotspotComponent {
  final Vector2 relativePosition;  // 0.0-1.0の相対座標
  final Vector2 relativeSize;      // 0.0-1.0の相対サイズ
  
  // 画面サイズ変更時に自動調整
  void updateForScreenSize(Vector2 screenSize, Vector2 backgroundSize) {
    // 統一された400x600背景に対する絶対座標計算
    position = Vector2(
      relativePosition.x * backgroundSize.x,
      relativePosition.y * backgroundSize.y,
    );
    size = Vector2(
      relativeSize.x * screenSize.x,
      relativeSize.y * screenSize.y,
    );
  }
}
```

### 各ルームの推奨ホットスポット配置

#### room_left.png（回廊）
- **左柱部分**: (80, 200, 60, 60) - 石柱のヒントオブジェクト
- **中央床**: (200, 450, 80, 80) - アイテム落下位置
- **右側壁**: (320, 250, 70, 70) - 壁面スイッチ
- **奥の光**: (200, 150, 50, 50) - 光源調査ポイント

#### room_right.png（錬金術室）
- **左棚**: (50, 300, 80, 80) - 薬草・瓶エリア
- **中央棚**: (200, 200, 100, 100) - メイン操作エリア
- **右棚**: (350, 350, 70, 70) - 器具・道具エリア

#### room_leftmost.png（地下通路）
- **左壁**: (60, 250, 70, 70) - 壁面の秘密
- **通路中央**: (200, 400, 80, 80) - 床の仕掛け
- **奥の光**: (200, 150, 60, 60) - 出口への手がかり

#### room_rightmost.png（宝物庫）
- **テーブル左**: (150, 350, 80, 80) - 装飾壺
- **テーブル右**: (250, 350, 80, 80) - 宝箱エリア
- **背景装飾**: (200, 200, 70, 70) - 壁面の紋章

## 🧪 テスト計画

### 対象デバイス
#### iOS シミュレーター
- **iPhone SE**: 375x667（小画面）
- **iPhone 14**: 390x844（標準）
- **iPhone 14 Pro Max**: 430x932（大画面）

#### Android エミュレーター
- **Pixel 4**: 411x869（標準）
- **Pixel 7 Pro**: 412x915（大画面）

### 検証項目
1. **画像サイズ統一性**: 全背景が400x600で表示されるか
2. **ホットスポット座標精度**: タップ判定が正確な位置で動作するか
3. **レスポンシブ対応**: 異なる画面サイズで適切にスケールするか
4. **パフォーマンス影響**: 画像読み込み・表示速度への影響
5. **既存機能との整合性**: インベントリ・進行管理システムとの連携

## 📝 次のステップ優先順位

### 高優先（即座に実行）
1. **MCP接続修復**: Claude Code再起動でMCPサーバー認識確認
2. **Option B実行**: MCPが利用できない場合の既存画像リサイズ
3. **ResponsiveHotspotComponent実装**: 新しい座標システム

### 中優先（実装後）
1. **ホットスポット画像生成**: 100x100正方形画像の作成
2. **座標配置テスト**: 各デバイスでの動作確認
3. **インタラクション統合**: アイテム取得・組み合わせシステム

### 低優先（最終段階）
1. **ゲーム進行システム統合**: 進行度管理との連携
2. **ゲームクリア条件**: エンディングまでの道筋作成
3. **パフォーマンス最適化**: 画像読み込み・メモリ使用量最適化

## 🔧 技術情報

### プロジェクト構造
```
escape_room/lib/framework/components/
├── hotspot_component.dart              # 修正対象
├── inventory_manager.dart              # 5個制限対応済み
└── interaction_manager.dart            # 相互作用管理

escape_room/assets/images/
├── room_*.png                          # 400x600統一予定
└── hotspots/                          # 100x100正方形画像予定
    ├── library_*.png                   # 図書館系
    ├── alchemy_*.png                   # 錬金術系
    ├── prison_*.png                    # 監獄系
    └── treasure_*.png                  # 宝物系

escape_room/lib/framework/ui/
├── responsive_layout_calculator.dart   # レスポンシブ計算（活用）
└── mobile_portrait_layout.dart         # モバイル縦向きUI
```

### 重要な制約・前提条件
- **インベントリ制限**: 最大5個（AI_MASTER.md記載の8個は古い情報）
- **対象プラットフォーム**: 縦向きモバイル専用（タブレット・横向き対象外）
- **互換性**: 既存セーブデータ互換性は考慮不要
- **画像形式**: PNG推奨（透明背景対応）

### MCP設定情報
```json
// .claude/claude_project_config.json
{
  "mcpServers": {
    "global-image-generation": {
      "command": "node",
      "args": ["/Users/sekiguchi/ai-services/MCPServers/global-image-generation/server.js"],
      "type": "stdio",
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
```

### 直接MCP呼び出し例
```bash
# MCPサーバーへの直接JSONRPC呼び出し
cd /Users/sekiguchi/ai-services/MCPServers/global-image-generation/
echo '{"jsonrpc": "2.0", "id": 1, "method": "tools/call", "params": {"name": "comfyui_generate", "arguments": {"prompt": "medieval stone corridor", "width": 400, "height": 600}}}' | node server.js
```

## 📊 進捗状況

### 完了済みタスク ✅
- [x] MCP画像生成サービスで利用可能なモデル・LoRAを確認
- [x] room_left（回廊）の400x600統一サイズ画像を生成（試行）
- [x] 生成画像の品質・サイズ・座標配置適性を確認

### 進行中タスク 🔄
- [ ] MCP画像生成サービスの問題調査・修復

### 未着手タスク 📋
- [ ] 既存のroom_left.pngと生成画像を比較評価
- [ ] 他3枚の背景画像生成
- [ ] ホットスポット画像（100x100）の生成
- [ ] ResponsiveHotspotComponent実装
- [ ] 各デバイスでの動作テスト

## 🤝 引き継ぎ事項

この文書をもとに、次のAIが以下の作業を継続できます：

1. **MCP問題解決**: Claude Code再起動またはOption B（既存画像リサイズ）の実行
2. **ホットスポット実装**: ResponsiveHotspotComponentの実装
3. **画像生成**: 背景画像4枚 + ホットスポット画像の生成
4. **統合テスト**: 実機での動作確認

**重要**: このプロジェクトは脱出ゲームの核心機能に関わるため、既存システムとの整合性を必ず確認しながら進めてください。