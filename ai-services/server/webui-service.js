#!/usr/bin/env node

import axios from 'axios';
import fs from 'fs-extra';
import path from 'path';
import { spawn } from 'child_process';
import { 
  WEBUI_API_URL, 
  WEBUI_SCRIPT, 
  OUTPUT_DIR,
  API_REQUEST_TIMEOUT
} from './config.js';

export class WebUIService {
  // WebUIサービス起動確認・自動起動
  async ensureWebUIRunning() {
    try {
      await axios.get(`${WEBUI_API_URL}/sdapi/v1/options`, { timeout: API_REQUEST_TIMEOUT });
      return true;
    } catch (error) {
      console.log('WebUI not running, starting...');
      
      const child = spawn('bash', [WEBUI_SCRIPT], {
        detached: true,
        stdio: ['ignore', 'ignore', 'ignore'],
        cwd: path.dirname(WEBUI_SCRIPT)
      });
      child.unref();
      
      // 起動待機（最大30秒）
      for (let i = 0; i < 30; i++) {
        await new Promise(resolve => setTimeout(resolve, 1000));
        try {
          await axios.get(`${WEBUI_API_URL}/sdapi/v1/options`, { timeout: 2000 });
          console.log(`WebUI started successfully after ${i + 1} seconds`);
          return true;
        } catch (e) {
          if (i % 10 === 0) console.log(`Waiting for WebUI... ${i + 1}s`);
        }
      }
      throw new Error('WebUI failed to start within 30 seconds');
    }
  }

  // 基本txt2img生成
  async generateText2Image(args) {
    const {
      prompt,
      negative_prompt = 'blurry, low quality',
      steps = 20,
      cfg_scale = 7,
      width = 512,
      height = 512,
      sampler_name = "DPM++ 2M Karras",
      output_name
    } = args;

    await this.ensureWebUIRunning();
    
    const payload = {
      prompt: prompt,
      negative_prompt: negative_prompt,
      steps: steps,
      cfg_scale: cfg_scale,
      width: width,
      height: height,
      sampler_name: sampler_name
    };

    const response = await axios.post(`${WEBUI_API_URL}/sdapi/v1/txt2img`, payload, {
      timeout: 120000 // 2分タイムアウト
    });

    if (!response.data.images || response.data.images.length === 0) {
      throw new Error('WebUI returned no images');
    }

    // 画像保存
    const imageData = response.data.images[0];
    const filename = output_name || `webui_txt2img_${Date.now()}.png`;
    const outputPath = path.join(OUTPUT_DIR, filename);
    
    await fs.writeFile(outputPath, Buffer.from(imageData, 'base64'));
    
    return {
      success: true,
      output_path: outputPath,
      filename: filename,
      method: 'webui_txt2img'
    };
  }

  // 画像をBase64に変換
  async imageToBase64(imagePath) {
    const fullPath = path.isAbsolute(imagePath) ? imagePath : path.join(process.cwd(), imagePath);
    const imageBuffer = await fs.readFile(fullPath);
    return imageBuffer.toString('base64');
  }
}