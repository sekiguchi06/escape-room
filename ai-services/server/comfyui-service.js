#!/usr/bin/env node

import axios from 'axios';
import fs from 'fs-extra';
import path from 'path';
import os from 'os';
import { spawn } from 'child_process';
import { 
  COMFYUI_API_URL, 
  COMFYUI_SCRIPT, 
  OUTPUT_DIR, 
  DEFAULT_MODEL,
  GENERATION_TIMEOUT,
  SERVICE_STARTUP_TIMEOUT,
  API_REQUEST_TIMEOUT
} from './config.js';

export class ComfyUIService {
  // ComfyUIサービス起動確認・自動起動
  async ensureComfyUIRunning() {
    try {
      await axios.get(`${COMFYUI_API_URL}/system_stats`, { timeout: API_REQUEST_TIMEOUT });
      return true; // 既に起動中
    } catch (error) {
      console.log('ComfyUI not running, starting...');
      
      const child = spawn('bash', [COMFYUI_SCRIPT], {
        detached: true,
        stdio: ['ignore', 'ignore', 'ignore'],
        cwd: path.dirname(COMFYUI_SCRIPT)
      });
      child.unref();
      
      // 起動待機（最大45秒）
      for (let i = 0; i < 45; i++) {
        await new Promise(resolve => setTimeout(resolve, 1000));
        try {
          await axios.get(`${COMFYUI_API_URL}/system_stats`, { timeout: 2000 });
          console.log(`ComfyUI started successfully after ${i + 1} seconds`);
          return true;
        } catch (e) {
          if (i % 10 === 0) console.log(`Waiting for ComfyUI... ${i + 1}s`);
        }
      }
      
      console.error('ComfyUI failed to start within 45 seconds');
      return false;
    }
  }

  // ワークフロー実行
  async executeWorkflow(workflow) {
    await this.ensureComfyUIRunning();
    
    const promptResponse = await axios.post(`${COMFYUI_API_URL}/prompt`, {
      prompt: workflow
    });

    const promptId = promptResponse.data.prompt_id;
    console.log('Started generation with prompt_id:', promptId);

    return await this.waitForCompletion(promptId);
  }

  // 生成完了待機
  async waitForCompletion(promptId) {
    const startTime = Date.now();
    
    while (Date.now() - startTime < GENERATION_TIMEOUT) {
      try {
        const historyResponse = await axios.get(`${COMFYUI_API_URL}/history/${promptId}`);
        
        if (historyResponse.data[promptId]) {
          const status = historyResponse.data[promptId].status;
          
          if (status.status_str === 'success') {
            const outputs = historyResponse.data[promptId].outputs;
            
            // 生成された画像を探す
            for (const nodeId in outputs) {
              const nodeOutput = outputs[nodeId];
              if (nodeOutput.images && nodeOutput.images.length > 0) {
                const imageInfo = nodeOutput.images[0];
                return {
                  success: true,
                  output_path: path.join(OUTPUT_DIR, imageInfo.filename),
                  filename: imageInfo.filename,
                  prompt_id: promptId
                };
              }
            }
            
            throw new Error('No images generated');
          } else if (status.status_str === 'error') {
            // エラーメッセージを取得
            const errorMessage = status.messages.find(msg => msg[0] === 'execution_error');
            if (errorMessage) {
              throw new Error(`ComfyUI execution error: ${errorMessage[1].exception_message}`);
            }
            throw new Error('ComfyUI execution failed with unknown error');
          }
        }
        
        await new Promise(resolve => setTimeout(resolve, 2000));
      } catch (error) {
        await new Promise(resolve => setTimeout(resolve, 2000));
      }
    }
    
    throw new Error('ComfyUI generation timeout');
  }

  // 基本txt2img生成
  async generateText2Image(args) {
    const {
      prompt,
      negative_prompt = 'blurry, low quality, worst quality, low resolution',
      steps = 30,
      cfg_scale = 8,
      width = 1024,
      height = 1024,
      sampler = 'dpmpp_2m',
      scheduler = 'karras',
      model = DEFAULT_MODEL,
      lora = '',
      lora_strength = 0.7,
      output_name
    } = args;

    // LoRA使用判定
    const useLoRA = lora && lora.trim() !== '';

    const workflow = useLoRA ? {
      "1": {
        "class_type": "CheckpointLoaderSimple",
        "inputs": {
          "ckpt_name": model
        }
      },
      "2": {
        "class_type": "LoraLoader",
        "inputs": {
          "model": ["1", 0],
          "clip": ["1", 1],
          "lora_name": lora,
          "strength_model": lora_strength,
          "strength_clip": lora_strength
        }
      },
      "3": {
        "class_type": "CLIPTextEncode",
        "inputs": {
          "text": prompt,
          "clip": ["2", 1]
        }
      },
      "4": {
        "class_type": "CLIPTextEncode",
        "inputs": {
          "text": negative_prompt,
          "clip": ["2", 1]
        }
      },
      "5": {
        "class_type": "EmptyLatentImage",
        "inputs": {
          "width": width,
          "height": height,
          "batch_size": 1
        }
      },
      "6": {
        "class_type": "KSampler",
        "inputs": {
          "seed": Math.floor(Math.random() * 1000000),
          "steps": steps,
          "cfg": cfg_scale,
          "sampler_name": sampler,
          "scheduler": scheduler,
          "denoise": 1.0,
          "model": ["2", 0],
          "positive": ["3", 0],
          "negative": ["4", 0],
          "latent_image": ["5", 0]
        }
      },
      "7": {
        "class_type": "VAEDecode",
        "inputs": {
          "samples": ["6", 0],
          "vae": ["1", 2]
        }
      },
      "8": {
        "class_type": "SaveImage",
        "inputs": {
          "images": ["7", 0],
          "filename_prefix": output_name || "comfyui_txt2img"
        }
      }
    } : {
      "1": {
        "class_type": "CheckpointLoaderSimple",
        "inputs": {
          "ckpt_name": model
        }
      },
      "2": {
        "class_type": "CLIPTextEncode",
        "inputs": {
          "text": prompt,
          "clip": ["1", 1]
        }
      },
      "3": {
        "class_type": "CLIPTextEncode",
        "inputs": {
          "text": negative_prompt,
          "clip": ["1", 1]
        }
      },
      "4": {
        "class_type": "EmptyLatentImage",
        "inputs": {
          "width": width,
          "height": height,
          "batch_size": 1
        }
      },
      "5": {
        "class_type": "KSampler",
        "inputs": {
          "seed": Math.floor(Math.random() * 1000000),
          "steps": steps,
          "cfg": cfg_scale,
          "sampler_name": sampler,
          "scheduler": scheduler,
          "denoise": 1.0,
          "model": ["1", 0],
          "positive": ["2", 0],
          "negative": ["3", 0],
          "latent_image": ["4", 0]
        }
      },
      "6": {
        "class_type": "VAEDecode",
        "inputs": {
          "samples": ["5", 0],
          "vae": ["1", 2]
        }
      },
      "7": {
        "class_type": "SaveImage",
        "inputs": {
          "images": ["6", 0],
          "filename_prefix": output_name || "comfyui_txt2img"
        }
      }
    };

    return await this.executeWorkflow(workflow);
  }

  // インペインティング（マスクを使った部分修正）
  async generateInpainting(args) {
    const {
      reference_image,
      mask_image, 
      prompt,
      negative_prompt = 'blurry, low quality, artifacts',
      steps = 20,
      cfg_scale = 7.0,
      denoise = 0.75,
      model = DEFAULT_MODEL,
      output_name
    } = args;

    // 画像を ComfyUI の input ディレクトリにコピー（400エラー対策）
    const refImageName = await this.uploadImageToComfyUI(reference_image, 'reference.png');
    const maskImageName = await this.uploadImageToComfyUI(mask_image, 'mask.png');

    const workflow = {
      "1": {
        "class_type": "CheckpointLoaderSimple",
        "inputs": {
          "ckpt_name": model
        }
      },
      "2": {
        "class_type": "LoadImage",
        "inputs": {
          "image": refImageName
        }
      },
      "3": {
        "class_type": "LoadImageMask",
        "inputs": {
          "image": maskImageName,
          "channel": "red"
        }
      },
      "4": {
        "class_type": "CLIPTextEncode",
        "inputs": {
          "text": prompt,
          "clip": ["1", 1]
        }
      },
      "5": {
        "class_type": "CLIPTextEncode",
        "inputs": {
          "text": negative_prompt,
          "clip": ["1", 1]
        }
      },
      "6": {
        "class_type": "VAEEncodeForInpaint",
        "inputs": {
          "pixels": ["2", 0],
          "vae": ["1", 2],
          "mask": ["3", 0],
          "grow_mask_by": 6
        }
      },
      "7": {
        "class_type": "KSampler",
        "inputs": {
          "seed": Math.floor(Math.random() * 1000000),
          "steps": steps,
          "cfg": cfg_scale,
          "sampler_name": "dpmpp_2m",
          "scheduler": "karras",
          "denoise": denoise,
          "model": ["1", 0],
          "positive": ["4", 0],
          "negative": ["5", 0],
          "latent_image": ["6", 0]
        }
      },
      "8": {
        "class_type": "VAEDecode",
        "inputs": {
          "samples": ["7", 0],
          "vae": ["1", 2]
        }
      },
      "9": {
        "class_type": "SaveImage",
        "inputs": {
          "images": ["8", 0],
          "filename_prefix": output_name || "comfyui_inpainting"
        }
      }
    };

    return await this.executeWorkflow(workflow);
  }

  // 画像をComfyUIのinputディレクトリにアップロード（400エラー対策）
  async uploadImageToComfyUI(imagePath, fileName) {
    const fs = await import('fs-extra');
    const path = await import('path');
    
    // ComfyUI inputディレクトリパス
    const comfyUIInputDir = path.join(os.homedir(), 'ai-services', 'ComfyUI', 'input');
    await fs.ensureDir(comfyUIInputDir);
    
    // ファイル名を安全に生成
    const timestamp = Date.now();
    const safeFileName = fileName.replace(/[^a-zA-Z0-9.-]/g, '_');
    const targetPath = path.join(comfyUIInputDir, `${timestamp}_${safeFileName}`);
    
    // 画像をコピー
    await fs.copy(imagePath, targetPath);
    
    // ComfyUIが参照するファイル名（相対パス）を返す
    return `${timestamp}_${safeFileName}`;
  }
}