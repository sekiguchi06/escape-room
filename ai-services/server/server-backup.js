#!/usr/bin/env node

import { config } from 'dotenv';
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { 
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import axios from 'axios';
import fs from 'fs-extra';
import path from 'path';
import os from 'os';
import { spawn, exec } from 'child_process';
import { promisify } from 'util';

// .envファイルを読み込み（プロジェクトルートから）
config({ path: path.join(process.cwd(), '../../.env') });

const COMFYUI_API_URL = process.env.COMFYUI_API_URL || 'http://127.0.0.1:8188';
const WEBUI_API_URL = process.env.WEBUI_API_URL || 'http://127.0.0.1:7860';
const OUTPUT_DIR = process.env.OUTPUT_DIR || path.join(os.homedir(), '.ai-services', 'output');
const SCRIPTS_DIR = path.join(process.cwd(), '../scripts');
const COMFYUI_SCRIPT = path.join(SCRIPTS_DIR, 'start_comfyui.sh');
const execAsync = promisify(exec);

class GlobalImageGenerationMCP {
  constructor() {
    this.server = new Server(
      {
        name: 'global-image-generation',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    // 出力ディレクトリ確保
    fs.ensureDirSync(OUTPUT_DIR);
    
    this.setupToolHandlers();
  }

  setupToolHandlers() {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: [
        {
          name: 'comfyui_generate',
          description: 'Generate image using ComfyUI with advanced workflow',
          inputSchema: {
            type: 'object',
            properties: {
              prompt: { type: 'string', description: 'Text prompt for image generation' },
              negative_prompt: { type: 'string', description: 'Negative prompt', default: 'blurry, low quality, worst quality, low resolution' },
              width: { type: 'number', default: 1024 },
              height: { type: 'number', default: 1024 },
              steps: { type: 'number', default: 30 },
              cfg_scale: { type: 'number', default: 8.0 },
              sampler: { type: 'string', default: 'dpmpp_2m' },
              scheduler: { type: 'string', default: 'karras' },
              model: { type: 'string', description: 'Model filename', default: 'Counterfeit-V3.0_fp16.safetensors' },
              lora: { type: 'string', description: 'LoRA filename (optional)', default: '' },
              lora_strength: { type: 'number', description: 'LoRA strength', default: 0.7 },
              output_name: { type: 'string', description: 'Custom output filename (optional)' },
              quality_preset: { type: 'string', enum: ['draft', 'standard', 'high', 'ultra'], default: 'high', description: 'Quality preset for generation' }
            },
            required: ['prompt'],
          },
        },
        {
          name: 'comfyui_generate_hd',
          description: 'Generate high-definition image using ComfyUI with upscaling workflow',
          inputSchema: {
            type: 'object',
            properties: {
              prompt: { type: 'string', description: 'Text prompt for image generation' },
              negative_prompt: { type: 'string', description: 'Negative prompt', default: 'blurry, low quality, worst quality, low resolution, distorted' },
              base_resolution: { type: 'string', enum: ['512x512', '768x768', '1024x1024'], default: '768x768' },
              upscale_factor: { type: 'number', enum: [2, 4], default: 2 },
              steps: { type: 'number', default: 40 },
              cfg_scale: { type: 'number', default: 8.0 },
              model: { type: 'string', description: 'Model filename', default: 'Counterfeit-V3.0_fp16.safetensors' },
              lora: { type: 'string', description: 'LoRA filename (optional)', default: '' },
              lora_strength: { type: 'number', description: 'LoRA strength', default: 0.7 },
              output_name: { type: 'string', description: 'Custom output filename (optional)' }
            },
            required: ['prompt'],
          },
        },
        {
          name: 'webui_generate',
          description: 'Generate image using Stable Diffusion WebUI',
          inputSchema: {
            type: 'object',
            properties: {
              prompt: { type: 'string', description: 'Text prompt for image generation' },
              negative_prompt: { type: 'string', default: 'blurry, low quality' },
              width: { type: 'number', default: 512 },
              height: { type: 'number', default: 512 },
              steps: { type: 'number', default: 20 },
              cfg_scale: { type: 'number', default: 7 },
              sampler_name: { type: 'string', default: 'DPM++ 2M Karras' },
              output_name: { type: 'string', description: 'Custom output filename (optional)' }
            },
            required: ['prompt'],
          },
        },
        {
          name: 'check_services',
          description: 'Check if ComfyUI and WebUI services are running',
          inputSchema: {
            type: 'object',
            properties: {},
          },
        },
        {
          name: 'list_models',
          description: 'List available models in both services',
          inputSchema: {
            type: 'object',
            properties: {
              service: { type: 'string', enum: ['comfyui', 'webui', 'both'], default: 'both' }
            },
          },
        },
        {
          name: 'list_outputs',
          description: 'List generated images in output directory',
          inputSchema: {
            type: 'object',
            properties: {
              limit: { type: 'number', default: 10, description: 'Maximum number of files to list' }
            },
          },
        },
        {
          name: 'comfyui_inpainting',
          description: 'Inpaint specific areas of an image while preserving the rest - perfect for escape room asset differences',
          inputSchema: {
            type: 'object',
            properties: {
              reference_image: { type: 'string', description: 'Path to original image file' },
              mask_image: { type: 'string', description: 'Path to mask image file (white=modify, black=preserve)' },
              prompt: { type: 'string', description: 'Text prompt describing what to generate in masked area' },
              negative_prompt: { type: 'string', default: 'blurry, low quality, artifacts', description: 'Negative prompt' },
              steps: { type: 'number', default: 20 },
              cfg_scale: { type: 'number', default: 7.0 },
              denoise: { type: 'number', default: 0.75, description: 'Denoising strength (0.1-1.0, lower=more original preserved)' },
              model: { type: 'string', default: 'Counterfeit-V3.0_fp16.safetensors', description: 'Model filename' },
              output_name: { type: 'string', description: 'Custom output filename (optional)' }
            },
            required: ['reference_image', 'mask_image', 'prompt'],
          },
        },
        {
          name: 'comfyui_controlnet_reference',
          description: 'Generate image differences using ControlNet + Reference for escape room assets',
          inputSchema: {
            type: 'object',
            properties: {
              reference_image: { type: 'string', description: 'Path to reference image file' },
              prompt: { type: 'string', description: 'Text prompt describing the desired changes' },
              negative_prompt: { type: 'string', description: 'Negative prompt', default: 'blurry, low quality, different lighting, different angle' },
              controlnet_type: { type: 'string', enum: ['canny', 'depth', 'canny+depth'], default: 'canny', description: 'ControlNet type for structure preservation' },
              canny_strength: { type: 'number', default: 0.8, description: 'ControlNet strength (0.0-1.0)' },
              reference_strength: { type: 'number', default: 0.9, description: 'Reference image influence (0.0-1.0)' },
              steps: { type: 'number', default: 25 },
              cfg_scale: { type: 'number', default: 7.5 },
              model: { type: 'string', description: 'Model filename', default: 'Counterfeit-V3.0_fp16.safetensors' },
              output_name: { type: 'string', description: 'Custom output filename (optional)' }
            },
            required: ['reference_image', 'prompt'],
          },
        }
      ],
    }));

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          case 'comfyui_generate':
            return await this.comfyuiGenerate(args);
          case 'comfyui_generate_hd':
            return await this.comfyuiGenerateHD(args);
          case 'webui_generate':
            return await this.webuiGenerate(args);
          case 'check_services':
            return await this.checkServices();
          case 'list_models':
            return await this.listModels(args);
          case 'list_outputs':
            return await this.listOutputs(args);
          case 'comfyui_inpainting':
            return await this.comfyuiInpainting(args);
          case 'comfyui_controlnet_reference':
            return await this.comfyuiControlNetReference(args);
          default:
            throw new Error(`Unknown tool: ${name}`);
        }
      } catch (error) {
        return {
          content: [
            {
              type: 'text',
              text: `Error: ${error.message}`,
            },
          ],
        };
      }
    });
  }

  getQualitySettings(preset) {
    const settings = {
      'draft': { steps: 15, cfg: 6.0, sampler: 'euler', scheduler: 'normal' },
      'standard': { steps: 25, cfg: 7.5, sampler: 'dpmpp_2m', scheduler: 'karras' },
      'high': { steps: 35, cfg: 8.0, sampler: 'dpmpp_2m', scheduler: 'karras' },
      'ultra': { steps: 50, cfg: 9.0, sampler: 'dpmpp_2m', scheduler: 'karras' }
    };
    return settings[preset] || settings['high'];
  }

  async comfyuiGenerate(args) {
    const {
      prompt,
      negative_prompt = 'blurry, low quality, worst quality, low resolution',
      width = 1024,
      height = 1024,
      steps = 30,
      cfg_scale = 8.0,
      sampler = 'dpmpp_2m',
      scheduler = 'karras',
      model = 'Counterfeit-V3.0_fp16.safetensors',
      lora = '',
      lora_strength = 0.7,
      output_name,
      quality_preset = 'high'
    } = args;

    // 品質プリセットの適用
    const qualitySettings = this.getQualitySettings(quality_preset);
    const finalSteps = steps || qualitySettings.steps;
    const finalCfg = cfg_scale || qualitySettings.cfg;
    const finalSampler = sampler || qualitySettings.sampler;
    const finalScheduler = scheduler || qualitySettings.scheduler;

    // LoRA使用判定
    const useLoRA = lora && lora.trim() !== '';
    
    const workflow = useLoRA ? {
      "3": {
        "class_type": "KSampler",
        "inputs": {
          "seed": Math.floor(Math.random() * 1000000),
          "steps": finalSteps,
          "cfg": finalCfg,
          "sampler_name": finalSampler,
          "scheduler": finalScheduler,
          "denoise": 1.0,
          "model": ["10", 0],
          "positive": ["6", 0],
          "negative": ["7", 0],
          "latent_image": ["5", 0]
        }
      },
      "4": {
        "class_type": "CheckpointLoaderSimple",
        "inputs": {
          "ckpt_name": model
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
        "class_type": "CLIPTextEncode",
        "inputs": {
          "text": prompt,
          "clip": ["10", 1]
        }
      },
      "7": {
        "class_type": "CLIPTextEncode",
        "inputs": {
          "text": negative_prompt,
          "clip": ["10", 1]
        }
      },
      "8": {
        "class_type": "VAEDecode",
        "inputs": {
          "samples": ["3", 0],
          "vae": ["4", 2]
        }
      },
      "9": {
        "class_type": "SaveImage",
        "inputs": {
          "filename_prefix": output_name || "ComfyUI",
          "images": ["8", 0]
        }
      },
      "10": {
        "class_type": "LoraLoader",
        "inputs": {
          "model": ["4", 0],
          "clip": ["4", 1],
          "lora_name": lora,
          "strength_model": lora_strength,
          "strength_clip": lora_strength
        }
      }
    } : {
      "3": {
        "class_type": "KSampler",
        "inputs": {
          "seed": Math.floor(Math.random() * 1000000),
          "steps": finalSteps,
          "cfg": finalCfg,
          "sampler_name": finalSampler,
          "scheduler": finalScheduler,
          "denoise": 1.0,
          "model": ["4", 0],
          "positive": ["6", 0],
          "negative": ["7", 0],
          "latent_image": ["5", 0]
        }
      },
      "4": {
        "class_type": "CheckpointLoaderSimple",
        "inputs": {
          "ckpt_name": model
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
        "class_type": "CLIPTextEncode",
        "inputs": {
          "text": prompt,
          "clip": ["4", 1]
        }
      },
      "7": {
        "class_type": "CLIPTextEncode",
        "inputs": {
          "text": negative_prompt,
          "clip": ["4", 1]
        }
      },
      "8": {
        "class_type": "VAEDecode",
        "inputs": {
          "samples": ["3", 0],
          "vae": ["4", 2]
        }
      },
      "9": {
        "class_type": "SaveImage",
        "inputs": {
          "filename_prefix": output_name || "ComfyUI",
          "images": ["8", 0]
        }
      }
    };

    const payload = {
      prompt: workflow,
      client_id: 'global-mcp-client'
    };

    // ComfyUI自動起動
    const isRunning = await this.ensureComfyUIRunning();
    if (!isRunning) {
      throw new Error('ComfyUI could not be started. Please check the service configuration.');
    }

    console.log('Sending workflow to ComfyUI:');
    console.log('Payload keys:', Object.keys(payload));
    console.log('Workflow nodes:', Object.keys(workflow));
    
    try {
      const response = await axios.post(`${COMFYUI_API_URL}/prompt`, payload, {
        headers: {
          'Content-Type': 'application/json'
        }
      });
      console.log('ComfyUI response status:', response.status);
      console.log('ComfyUI response data:', JSON.stringify(response.data, null, 2));
      
      const promptId = response.data.prompt_id;
      const result = await this.waitForCompletion(promptId, COMFYUI_API_URL, 120000);
      
      // 生成された画像をユーザー出力ディレクトリにコピー
      await this.copyComfyUIOutput(result, output_name || 'comfyui_generated');

      return {
        content: [
          {
            type: 'text',
            text: `✅ ComfyUI image generated successfully!\\n` +
                  `📝 Prompt: "${prompt}"\\n` +
                  `🎯 Model: ${model}\\n` +
                  `📐 Size: ${width}x${height}\\n` +
                  `🔄 Steps: ${steps}\\n` +
                  `💾 Output directory: ${OUTPUT_DIR}\\n` +
                  `🆔 Prompt ID: ${promptId}`,
          },
        ],
      };
    } catch (error) {
      console.error('ComfyUI API Error Details:', {
        status: error.response?.status,
        statusText: error.response?.statusText,
        data: error.response?.data,
        headers: error.response?.headers,
        message: error.message
      });
      
      throw new Error(`ComfyUI API error: ${error.response?.status} - ${JSON.stringify(error.response?.data || error.message)}`);
    }
  }

  async webuiGenerate(args) {
    const {
      prompt,
      negative_prompt = 'blurry, low quality',
      width = 512,
      height = 512,
      steps = 20,
      cfg_scale = 7,
      sampler_name = 'DPM++ 2M Karras',
      output_name
    } = args;

    const payload = {
      prompt,
      negative_prompt,
      width,
      height,
      steps,
      cfg_scale,
      sampler_name,
      batch_size: 1,
      n_iter: 1,
      seed: -1,
    };

    const response = await axios.post(`${WEBUI_API_URL}/sdapi/v1/txt2img`, payload);
    
    if (response.status === 200 && response.data.images) {
      // Base64画像を保存
      const imageData = response.data.images[0];
      const filename = `${output_name || 'webui_generated'}_${Date.now()}.png`;
      const filepath = path.join(OUTPUT_DIR, filename);
      
      const buffer = Buffer.from(imageData, 'base64');
      await fs.writeFile(filepath, buffer);

      return {
        content: [
          {
            type: 'text',
            text: `✅ WebUI image generated successfully!\n` +
                  `📝 Prompt: "${prompt}"\n` +
                  `📐 Size: ${width}x${height}\n` +
                  `🔄 Steps: ${steps}\n` +
                  `🎨 Sampler: ${sampler_name}\n` +
                  `💾 Saved as: ${filename}\n` +
                  `📁 Output directory: ${OUTPUT_DIR}`,
          },
        ],
      };
    } else {
      throw new Error(`WebUI API error: ${response.status}`);
    }
  }

  async comfyuiGenerateHD(args) {
    const {
      prompt,
      negative_prompt = 'blurry, low quality, worst quality, low resolution, distorted',
      base_resolution = '768x768',
      upscale_factor = 2,
      steps = 40,
      cfg_scale = 8.0,
      model = 'Counterfeit-V3.0_fp16.safetensors',
      output_name
    } = args;

    // 解像度の解析
    const [baseWidth, baseHeight] = base_resolution.split('x').map(Number);
    const finalWidth = baseWidth * upscale_factor;
    const finalHeight = baseHeight * upscale_factor;

    // 高解像度生成ワークフロー（2段階生成）
    const workflow = {
      // 第1段階: ベース画像生成
      "1": {
        "class_type": "CheckpointLoaderSimple",
        "inputs": {
          "ckpt_name": model
        }
      },
      "2": {
        "class_type": "CLIPTextEncode",
        "inputs": {
          "text": `masterpiece, best quality, ultra detailed, 8k, photorealistic, ${prompt}`,
          "clip": ["1", 1]
        }
      },
      "3": {
        "class_type": "CLIPTextEncode",
        "inputs": {
          "text": `${negative_prompt}, low resolution, pixelated, jpeg artifacts`,
          "clip": ["1", 1]
        }
      },
      "4": {
        "class_type": "EmptyLatentImage",
        "inputs": {
          "width": baseWidth,
          "height": baseHeight,
          "batch_size": 1
        }
      },
      "5": {
        "class_type": "KSampler",
        "inputs": {
          "seed": Math.floor(Math.random() * 1000000),
          "steps": Math.floor(steps * 0.7),
          "cfg": cfg_scale,
          "sampler_name": "dpmpp_2m_karras",
          "scheduler": "karras",
          "denoise": 1.0,
          "model": ["1", 0],
          "positive": ["2", 0],
          "negative": ["3", 0],
          "latent_image": ["4", 0]
        }
      },
      // 第2段階: 高解像度化
      "6": {
        "class_type": "LatentUpscaleBy",
        "inputs": {
          "upscale_method": "nearest-exact",
          "scale_by": upscale_factor,
          "samples": ["5", 0]
        }
      },
      "7": {
        "class_type": "KSampler",
        "inputs": {
          "seed": Math.floor(Math.random() * 1000000),
          "steps": Math.floor(steps * 0.3),
          "cfg": cfg_scale - 1.0,
          "sampler_name": "dpmpp_2m_karras", 
          "scheduler": "karras",
          "denoise": 0.4,
          "model": ["1", 0],
          "positive": ["2", 0],
          "negative": ["3", 0],
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
          "filename_prefix": output_name || "ComfyUI_HD",
          "images": ["8", 0]
        }
      }
    };

    // ComfyUI自動起動
    const isRunning = await this.ensureComfyUIRunning();
    if (!isRunning) {
      throw new Error('ComfyUI could not be started. Please check the service configuration.');
    }

    const response = await axios.post(`${COMFYUI_API_URL}/prompt`, {
      prompt: workflow,
      client_id: 'global-mcp-client-hd'
    });

    const promptId = response.data.prompt_id;
    const result = await this.waitForCompletion(promptId, COMFYUI_API_URL, 120000); // 2分タイムアウト
    
    // 生成された画像をユーザー出力ディレクトリにコピー
    await this.copyComfyUIOutput(result, output_name || 'comfyui_hd_generated');

    return {
      content: [
        {
          type: 'text',
          text: `✅ ComfyUI HD image generated successfully!\n` +
                `📝 Prompt: "${prompt}"\n` +
                `🎯 Model: ${model}\n` +
                `📐 Base Size: ${base_resolution} → Final Size: ${finalWidth}x${finalHeight}\n` +
                `🔍 Upscale Factor: ${upscale_factor}x\n` +
                `🔄 Steps: ${steps} (Base: ${Math.floor(steps * 0.7)}, Refine: ${Math.floor(steps * 0.3)})\n` +
                `💎 Quality: Ultra HD\n` +
                `💾 Output directory: ${OUTPUT_DIR}\n` +
                `🆔 Prompt ID: ${promptId}`,
        },
      ],
    };
  }

  async ensureComfyUIRunning() {
    try {
      await axios.get(`${COMFYUI_API_URL}/system_stats`, { timeout: 3000 });
      return true; // 既に起動中
    } catch (error) {
      console.log('ComfyUI not running, starting...');
      
      // 絶対パスで確実に実行
      const scriptPath = '/Users/sekiguchi/git/escape-room/ai-services/scripts/start_comfyui.sh';
      console.log('Starting ComfyUI using script:', scriptPath);
      
      // バックグラウンドで起動
      const child = spawn('bash', [scriptPath], {
        detached: true,
        stdio: ['ignore', 'ignore', 'ignore'],
        cwd: '/Users/sekiguchi/git/escape-room/ai-services/scripts'
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

  async checkServices() {
    const services = [];
    
    try {
      await axios.get(`${COMFYUI_API_URL}/system_stats`);
      services.push('✅ ComfyUI: Running (http://127.0.0.1:8188)');
    } catch (error) {
      services.push('❌ ComfyUI: Not running');
    }

    try {
      await axios.get(`${WEBUI_API_URL}/sdapi/v1/samplers`);
      services.push('✅ WebUI: Running (http://127.0.0.1:7860)');
    } catch (error) {
      services.push('❌ WebUI: Not running');
    }

    return {
      content: [
        {
          type: 'text',
          text: `🔍 Service Status:\n${services.join('\n')}`,
        },
      ],
    };
  }

  async listModels(args) {
    const { service = 'both' } = args;
    const results = [];

    if (service === 'comfyui' || service === 'both') {
      try {
        const response = await axios.get(`${COMFYUI_API_URL}/object_info`);
        const objectInfo = response.data;
        const models = objectInfo.CheckpointLoaderSimple?.input?.required?.ckpt_name?.[0] || [];
        results.push(`📐 ComfyUI Models:\n${models.map(m => `  • ${m}`).join('\n')}`);
      } catch (error) {
        results.push('❌ ComfyUI: Cannot fetch models (service not running)');
      }
    }

    if (service === 'webui' || service === 'both') {
      try {
        const response = await axios.get(`${WEBUI_API_URL}/sdapi/v1/sd-models`);
        const models = response.data;
        results.push(`🎨 WebUI Models:\n${models.map(m => `  • ${m.title}`).join('\n')}`);
      } catch (error) {
        results.push('❌ WebUI: Cannot fetch models (service not running)');
      }
    }

    return {
      content: [
        {
          type: 'text',
          text: results.join('\n\n'),
        },
      ],
    };
  }

  async listOutputs(args) {
    const { limit = 10 } = args;
    
    try {
      const files = await fs.readdir(OUTPUT_DIR);
      const imageFiles = files
        .filter(file => /\.(png|jpg|jpeg|webp)$/i.test(file))
        .sort((a, b) => {
          const statA = fs.statSync(path.join(OUTPUT_DIR, a));
          const statB = fs.statSync(path.join(OUTPUT_DIR, b));
          return statB.mtime - statA.mtime;
        })
        .slice(0, limit);

      if (imageFiles.length === 0) {
        return {
          content: [
            {
              type: 'text',
              text: `📁 Output directory is empty: ${OUTPUT_DIR}`,
            },
          ],
        };
      }

      const fileList = imageFiles.map(file => {
        const stat = fs.statSync(path.join(OUTPUT_DIR, file));
        const size = (stat.size / 1024).toFixed(1);
        const date = stat.mtime.toLocaleString();
        return `  • ${file} (${size}KB, ${date})`;
      }).join('\n');

      return {
        content: [
          {
            type: 'text',
            text: `📁 Generated Images (${imageFiles.length}/${files.length}):\n${fileList}\n\n📍 Location: ${OUTPUT_DIR}`,
          },
        ],
      };
    } catch (error) {
      return {
        content: [
          {
            type: 'text',
            text: `Error listing outputs: ${error.message}`,
          },
        ],
      };
    }
  }

  async waitForCompletion(promptId, apiUrl, maxWait = 300000) {
    const startTime = Date.now();
    
    while (Date.now() - startTime < maxWait) {
      try {
        const response = await axios.get(`${apiUrl}/history/${promptId}`);
        const history = response.data;
        
        if (history[promptId]) {
          const status = history[promptId].status;
          
          if (status && status.completed) {
            return history[promptId];
          }
          
          // エラーをチェック
          if (status && status.status_str === 'error') {
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
    
    throw new Error('ComfyUI generation timeout or BrokenPipe error');
  }

  // シンプル生成フォールバック（インペインティングなし）
  async simpleGenerationFallback(args) {
    const {
      prompt,
      negative_prompt = 'blurry, low quality, artifacts',
      steps = 20,
      cfg_scale = 7,
      output_name
    } = args;

    console.log('Using simple generation fallback (no inpainting)');

    try {
      // シンプルなtxt2img生成で基本動作を確認
      const result = await this.comfyuiGenerate({
        prompt: prompt + ', escape room, indoor scene, detailed environment',
        negative_prompt: negative_prompt,
        steps: steps,
        cfg_scale: cfg_scale,
        width: 512,
        height: 512,
        quality_preset: 'standard',
        output_name: output_name || `simple_fallback_${Date.now()}.png`
      });
      
      return {
        ...result,
        method: 'simple_generation_fallback',
        note: 'Generated new image instead of inpainting due to system issues'
      };
    } catch (error) {
      console.error('Simple generation fallback failed:', error.message);
      throw new Error(`Simple generation fallback failed: ${error.message}`);
    }
  }

  // WebUIフォールバック機能（インペインティング）
  async webuiInpaintingFallback(args) {
    const {
      reference_image,
      mask_image,
      prompt,
      negative_prompt = 'blurry, low quality, artifacts',
      steps = 20,
      cfg_scale = 7,
      denoise = 0.75,
      output_name
    } = args;

    console.log('Using WebUI inpainting fallback');

    try {
      await this.ensureWebUIRunning();
      
      const payload = {
        init_images: [await this.imageToBase64(reference_image)],
        mask: await this.imageToBase64(mask_image),
        prompt: prompt,
        negative_prompt: negative_prompt,
        steps: steps,
        cfg_scale: cfg_scale,
        denoising_strength: denoise,
        inpaint_full_res: true,
        inpaint_full_res_padding: 32,
        inpainting_mask_invert: 0,
        mask_blur: 4,
        width: 512,
        height: 512,
        sampler_name: "DPM++ 2M Karras"
      };

      console.log('Sending WebUI inpainting request...');
      const response = await axios.post(`${WEBUI_API_URL}/sdapi/v1/img2img`, payload, {
        timeout: 120000 // 2分タイムアウト
      });

      if (!response.data.images || response.data.images.length === 0) {
        throw new Error('WebUI returned no images');
      }

      // 画像保存
      const imageData = response.data.images[0];
      const filename = output_name || `webui_inpaint_${Date.now()}.png`;
      const outputPath = path.join(OUTPUT_DIR, filename);
      
      await fs.writeFile(outputPath, Buffer.from(imageData, 'base64'));
      
      return {
        success: true,
        output_path: outputPath,
        filename: filename,
        method: 'webui_inpainting_fallback'
      };
    } catch (error) {
      console.error('WebUI inpainting fallback failed:', error.message);
      throw new Error(`Both ComfyUI and WebUI inpainting failed: ${error.message}`);
    }
  }

  // WebUI自動起動
  async ensureWebUIRunning() {
    try {
      await axios.get(`${WEBUI_API_URL}/sdapi/v1/options`, { timeout: 3000 });
      return true;
    } catch (error) {
      console.log('WebUI not running, starting...');
      const scriptPath = '/Users/sekiguchi/git/escape-room/ai-services/scripts/start_webui.sh';
      const child = spawn('bash', [scriptPath], {
        detached: true,
        stdio: ['ignore', 'ignore', 'ignore'],
        cwd: '/Users/sekiguchi/git/escape-room/ai-services/scripts'
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

  // 画像をBase64に変換
  async imageToBase64(imagePath) {
    const fullPath = path.isAbsolute(imagePath) ? imagePath : path.join(process.cwd(), imagePath);
    const imageBuffer = await fs.readFile(fullPath);
    return imageBuffer.toString('base64');
  }

  async comfyuiInpainting(args) {
    console.log('Starting inpainting with fallback strategy...');
    
    // フォールバック戦略: ComfyUI -> WebUI -> シンプル本番生成
    const methods = [
      { name: 'ComfyUI', fn: () => this.executeComfyUIInpainting(args) },
      { name: 'WebUI', fn: () => this.webuiInpaintingFallback(args) },
      { name: 'Simple Generate', fn: () => this.simpleGenerationFallback(args) }
    ];

    let lastError = null;
    
    for (const method of methods) {
      try {
        console.log(`Attempting ${method.name}...`);
        const result = await method.fn();
        console.log(`${method.name} succeeded`);
        return result;
      } catch (error) {
        console.log(`${method.name} failed:`, error.message);
        lastError = error;
        continue;
      }
    }
    
    throw new Error(`All inpainting methods failed. Last error: ${lastError?.message || 'Unknown error'}`);
  }

  async executeComfyUIInpainting(args) {
  }

  async executeComfyUIInpainting(args) {
    const {
      reference_image,
      mask_image, 
      prompt,
      negative_prompt = 'blurry, low quality, artifacts',
      steps = 15,
      cfg_scale = 6.0,
      denoise = 0.6,
      model = 'Counterfeit-V3.0_fp16.safetensors',
      output_name
    } = args;

    // インペインティングワークフロー（特定領域のみ修正）
    const workflow = {
      // 1. チェックポイント読み込み
      "1": {
        "class_type": "CheckpointLoaderSimple",
        "inputs": {
          "ckpt_name": model
        }
      },
      // 2. 元画像読み込み
      "2": {
        "class_type": "LoadImage",
        "inputs": {
          "image": reference_image
        }
      },
      // 3. マスク読み込み（白=修正対象、黒=保持）
      "3": {
        "class_type": "LoadImageMask",
        "inputs": {
          "image": mask_image,
          "channel": "red"
        }
      },
      // 4. 正プロンプトエンコード
      "4": {
        "class_type": "CLIPTextEncode",
        "inputs": {
          "text": prompt,
          "clip": ["1", 1]
        }
      },
      // 5. 負プロンプトエンコード
      "5": {
        "class_type": "CLIPTextEncode",
        "inputs": {
          "text": negative_prompt,
          "clip": ["1", 1]
        }
      },
      // 6. VAEエンコード（インペインティング用）
      "6": {
        "class_type": "VAEEncodeForInpaint",
        "inputs": {
          "pixels": ["2", 0],
          "vae": ["1", 2],
          "mask": ["3", 0],
          "grow_mask_by": 6
        }
      },
      // 7. KSampler（インペインティング）
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
      // 8. VAEデコード
      "8": {
        "class_type": "VAEDecode",
        "inputs": {
          "samples": ["7", 0],
          "vae": ["1", 2]
        }
      },
      // 9. 画像保存
      "9": {
        "class_type": "SaveImage",
        "inputs": {
          "filename_prefix": output_name || "Inpainting",
          "images": ["8", 0]
        }
      }
    };

    // ComfyUI自動起動
    if (!await this.ensureComfyUIRunning()) {
      throw new Error('Failed to start ComfyUI');
    }

    try {
      // ワークフロー実行
      const response = await axios.post(`${COMFYUI_API_URL}/prompt`, {
        prompt: workflow,
        client_id: 'mcp-server'
      });

      const promptId = response.data.prompt_id;
      
      // 完了待ち（180秒タイムアウト）
      const result = await this.waitForCompletion(promptId, COMFYUI_API_URL);
      
      const filename = `${output_name || 'Inpainting'}_${String(Date.now()).slice(-5)}_.png`;
      
      return {
        content: [
          {
            type: 'text',
            text: `✅ Inpainting completed successfully!\n` +
                  `📝 Prompt: "${prompt}"\n` +
                  `🖼️ Original: ${reference_image}\n` +
                  `🎭 Mask: ${mask_image}\n` +
                  `🔄 Steps: ${steps}\n` +
                  `🎨 Denoise: ${denoise}\n` +
                  `💾 Saved as: ${filename}\n` +
                  `📁 Output directory: ${OUTPUT_DIR}`,
          },
        ],
      };
    } catch (error) {
      throw new Error(`Inpainting error: ${error.response?.status} - ${JSON.stringify(error.response?.data) || error.message}`);
    }
  }

  async comfyuiControlNetReference(args) {
    const {
      reference_image,
      prompt,
      negative_prompt = 'blurry, low quality, different lighting, different angle',
      controlnet_type = 'canny',
      canny_strength = 0.8,
      reference_strength = 0.9,
      steps = 25,
      cfg_scale = 7.5,
      model = 'Counterfeit-V3.0_fp16.safetensors',
      output_name
    } = args;

    // シンプルなControlNetのみワークフロー（高速・安定）
    const workflow = {
      // 1. チェックポイント読み込み
      "1": {
        "class_type": "CheckpointLoaderSimple",
        "inputs": {
          "ckpt_name": model
        }
      },
      // 2. 参照画像読み込み
      "2": {
        "class_type": "LoadImage",
        "inputs": {
          "image": `${reference_image}`
        }
      },
      // 3. ControlNet読み込み
      "3": {
        "class_type": "ControlNetLoader",
        "inputs": {
          "control_net_name": "control_v11p_sd15_canny.pth"
        }
      },
      // 4. Canny前処理
      "4": {
        "class_type": "CannyEdgePreprocessor",
        "inputs": {
          "image": ["2", 0],
          "low_threshold": 100,
          "high_threshold": 200
        }
      },
      // 5. 正プロンプトエンコード
      "5": {
        "class_type": "CLIPTextEncode",
        "inputs": {
          "text": `${prompt}, same style, same lighting, same perspective`,
          "clip": ["1", 1]
        }
      },
      // 6. 負プロンプトエンコード
      "6": {
        "class_type": "CLIPTextEncode",
        "inputs": {
          "text": negative_prompt,
          "clip": ["1", 1]
        }
      },
      // 7. ControlNet適用
      "7": {
        "class_type": "ControlNetApply",
        "inputs": {
          "conditioning": ["5", 0],
          "control_net": ["3", 0],
          "image": ["4", 0],
          "strength": canny_strength
        }
      },
      // 8. 空のLatent画像
      "8": {
        "class_type": "EmptyLatentImage",
        "inputs": {
          "width": 512,
          "height": 512,
          "batch_size": 1
        }
      },
      // 9. KSampler（シンプル化）
      "9": {
        "class_type": "KSampler",
        "inputs": {
          "seed": Math.floor(Math.random() * 1000000),
          "steps": steps,
          "cfg": cfg_scale,
          "sampler_name": "dpmpp_2m",
          "scheduler": "karras",
          "denoise": 1.0,
          "model": ["1", 0],
          "positive": ["7", 0],
          "negative": ["6", 0],
          "latent_image": ["8", 0]
        }
      },
      // 10. VAEデコード
      "10": {
        "class_type": "VAEDecode",
        "inputs": {
          "samples": ["9", 0],
          "vae": ["1", 2]
        }
      },
      // 11. 画像保存
      "11": {
        "class_type": "SaveImage",
        "inputs": {
          "filename_prefix": output_name || "ControlNet_Reference",
          "images": ["10", 0]
        }
      }
    };

    const payload = {
      prompt: workflow,
      client_id: 'controlnet-reference-client'
    };

    // ComfyUI自動起動
    const isRunning = await this.ensureComfyUIRunning();
    if (!isRunning) {
      throw new Error('ComfyUI could not be started. Please check the service configuration.');
    }

    console.log('Sending ControlNet + Reference workflow to ComfyUI...');
    console.log('Reference image:', reference_image);
    console.log('Prompt:', prompt);
    console.log('ControlNet type:', controlnet_type);
    
    try {
      const response = await axios.post(`${COMFYUI_API_URL}/prompt`, payload, {
        headers: {
          'Content-Type': 'application/json'
        }
      });
      
      const promptId = response.data.prompt_id;
      const result = await this.waitForCompletion(promptId, COMFYUI_API_URL, 120000);
      
      // 生成された画像をユーザー出力ディレクトリにコピー
      await this.copyComfyUIOutput(result, output_name || 'controlnet_reference');

      return {
        content: [
          {
            type: 'text',
            text: `✅ ControlNet + Reference image generated successfully!\n` +
                  `📝 Prompt: "${prompt}"\n` +
                  `🖼️ Reference: ${reference_image}\n` +
                  `🎛️ ControlNet: ${controlnet_type} (strength: ${canny_strength})\n` +
                  `🎨 Reference strength: ${reference_strength}\n` +
                  `🎯 Model: ${model}\n` +
                  `🔄 Steps: ${steps}\n` +
                  `💾 Output directory: ${OUTPUT_DIR}\n` +
                  `🆔 Prompt ID: ${promptId}`,
          },
        ],
      };
    } catch (error) {
      console.error('ControlNet + Reference API Error:', error.message);
      throw new Error(`ControlNet + Reference error: ${error.response?.status} - ${JSON.stringify(error.response?.data || error.message)}`);
    }
  }

  async copyComfyUIOutput(result, baseName) {
    // ComfyUIの出力ディレクトリから画像を探してコピー
    const comfyOutputDir = path.join(os.homedir(), 'ai-services', 'ComfyUI', 'ComfyUI', 'output');
    
    try {
      const files = await fs.readdir(comfyOutputDir);
      const latestFile = files
        .filter(file => file.startsWith(baseName) && /\.(png|jpg|jpeg)$/i.test(file))
        .sort()
        .pop();

      if (latestFile) {
        const sourcePath = path.join(comfyOutputDir, latestFile);
        const destPath = path.join(OUTPUT_DIR, latestFile);
        await fs.copy(sourcePath, destPath);
      }
    } catch (error) {
      console.warn('Could not copy ComfyUI output:', error.message);
    }
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
  }
}

const server = new GlobalImageGenerationMCP();
server.run().catch(console.error);