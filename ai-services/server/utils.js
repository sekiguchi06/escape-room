#!/usr/bin/env node

import fs from 'fs-extra';
import path from 'path';
import { promisify } from 'util';
import { exec } from 'child_process';
import { OUTPUT_DIR } from './config.js';

const execAsync = promisify(exec);

export class Utils {
  // 出力ディレクトリの設定
  static ensureOutputDirectory() {
    fs.ensureDirSync(OUTPUT_DIR);
  }

  // 利用可能なモデル一覧取得（ComfyUI）
  static async listComfyUIModels() {
    try {
      const modelsDir = path.join(process.env.COMFYUI_PATH || '~/ai-services/ComfyUI/ComfyUI', 'models', 'checkpoints');
      const files = await fs.readdir(modelsDir);
      return files.filter(file => file.endsWith('.safetensors') || file.endsWith('.ckpt'));
    } catch (error) {
      return ['Counterfeit-V3.0_fp16.safetensors']; // フォールバック
    }
  }

  // 生成された画像一覧取得
  static async listOutputImages(limit = 10) {
    try {
      const files = await fs.readdir(OUTPUT_DIR);
      const imageFiles = files
        .filter(file => /\.(png|jpg|jpeg|webp)$/i.test(file))
        .map(file => ({
          filename: file,
          path: path.join(OUTPUT_DIR, file),
          created: fs.statSync(path.join(OUTPUT_DIR, file)).birthtime
        }))
        .sort((a, b) => b.created - a.created)
        .slice(0, limit);

      return imageFiles;
    } catch (error) {
      console.error('Error listing output images:', error);
      return [];
    }
  }

  // サービス状態確認
  static async checkServicesStatus() {
    const results = {
      comfyui: false,
      webui: false,
      timestamp: new Date().toISOString()
    };

    // ComfyUI状態確認
    try {
      const { stdout: comfyResponse } = await execAsync('curl -s http://127.0.0.1:8188/system_stats', { timeout: 3000 });
      results.comfyui = comfyResponse.includes('system');
    } catch (error) {
      results.comfyui = false;
    }

    // WebUI状態確認  
    try {
      const { stdout: webuiResponse } = await execAsync('curl -s http://127.0.0.1:7860/sdapi/v1/options', { timeout: 3000 });
      results.webui = webuiResponse.includes('samples_save');
    } catch (error) {
      results.webui = false;
    }

    return results;
  }

  // 品質プリセット設定
  static getQualityPreset(preset = 'standard') {
    const presets = {
      'draft': {
        steps: 15,
        cfg_scale: 6,
        width: 512,
        height: 512
      },
      'standard': {
        steps: 25,
        cfg_scale: 7.5,
        width: 768,
        height: 768
      },
      'high': {
        steps: 35,
        cfg_scale: 8,
        width: 1024,
        height: 1024
      },
      'ultra': {
        steps: 50,
        cfg_scale: 9,
        width: 1536,
        height: 1536
      }
    };

    return presets[preset] || presets.standard;
  }

  // ファイル存在確認
  static async fileExists(filePath) {
    try {
      await fs.access(filePath);
      return true;
    } catch (error) {
      return false;
    }
  }

  // 安全なファイル名生成
  static generateSafeFilename(baseName, extension = 'png') {
    const timestamp = Date.now();
    const randomSuffix = Math.random().toString(36).substring(2, 8);
    const safeName = baseName.replace(/[^a-zA-Z0-9_-]/g, '_');
    return `${safeName}_${timestamp}_${randomSuffix}.${extension}`;
  }

  // エラー詳細ログ出力
  static logError(context, error, additionalInfo = {}) {
    const errorLog = {
      timestamp: new Date().toISOString(),
      context: context,
      error: {
        message: error.message,
        stack: error.stack,
        name: error.name
      },
      additionalInfo: additionalInfo
    };

    console.error('ERROR:', JSON.stringify(errorLog, null, 2));
    return errorLog;
  }
}