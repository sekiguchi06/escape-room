#!/usr/bin/env node

import { config } from 'dotenv';
import path from 'path';
import os from 'os';
import { fileURLToPath } from 'url';

// ES moduleで__dirnameを取得
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// 環境設定ファイル
// .envファイルのパス問題を解決するため、複数の場所を試す
function loadEnvironment() {
  const possibleEnvPaths = [
    path.join(process.cwd(), '.env'),
    path.join(process.cwd(), '..', '.env'),  
    path.join(process.cwd(), '..', '..', '.env'),
    path.join(__dirname, '.env'),
    path.join(__dirname, '..', '.env'),
    path.join(__dirname, '..', '..', '.env')
  ];

  for (const envPath of possibleEnvPaths) {
    try {
      const result = config({ path: envPath });
      if (result.error) continue;
      console.log(`Environment loaded from: ${envPath}`);
      return true;
    } catch (error) {
      continue;
    }
  }
  
  console.log('Warning: No .env file found, using default values');
  return false;
}

// 環境変数読み込み実行
loadEnvironment();

// API URLs
export const COMFYUI_API_URL = process.env.COMFYUI_API_URL || 'http://127.0.0.1:8188';
export const WEBUI_API_URL = process.env.WEBUI_API_URL || 'http://127.0.0.1:7860';

// ディレクトリパス
export const OUTPUT_DIR = process.env.OUTPUT_DIR || path.join(os.homedir(), 'ai-services', 'ComfyUI', 'output');
export const SCRIPTS_DIR = path.resolve(path.join(__dirname, '..', 'scripts'));

// スクリプトパス
export const COMFYUI_SCRIPT = path.join(SCRIPTS_DIR, 'start_comfyui.sh');
export const WEBUI_SCRIPT = path.join(SCRIPTS_DIR, 'start_webui.sh');

// デフォルトモデル設定
export const DEFAULT_MODEL = 'Counterfeit-V3.0_fp16.safetensors';
export const DEFAULT_STEPS = 30;
export const DEFAULT_CFG = 8;
export const DEFAULT_WIDTH = 1024;
export const DEFAULT_HEIGHT = 1024;

// タイムアウト設定
export const GENERATION_TIMEOUT = 300000; // 5分
export const SERVICE_STARTUP_TIMEOUT = 45000; // 45秒
export const API_REQUEST_TIMEOUT = 3000; // 3秒