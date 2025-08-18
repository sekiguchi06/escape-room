#!/usr/bin/env node

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

const COMFYUI_API_URL = 'http://127.0.0.1:8188';
const WEBUI_API_URL = 'http://127.0.0.1:7860';
const OUTPUT_DIR = path.join(os.homedir(), '.ai-services', 'output');

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
              sampler: { type: 'string', default: 'dpmpp_2m_karras' },
              scheduler: { type: 'string', default: 'karras' },
              model: { type: 'string', description: 'Model filename', default: 'Counterfeit-V3.0_fp16.safetensors' },
              lora: { type: 'string', description: 'LoRA filename (optional)', default: 'isometric_dreams.safetensors' },
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
              lora: { type: 'string', description: 'LoRA filename (optional)', default: 'isometric_dreams.safetensors' },
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
      'high': { steps: 35, cfg: 8.0, sampler: 'dpmpp_2m_karras', scheduler: 'karras' },
      'ultra': { steps: 50, cfg: 9.0, sampler: 'dpmpp_2m_karras', scheduler: 'karras' }
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
      sampler = 'dpmpp_2m_karras',
      scheduler = 'karras',
      model = 'Counterfeit-V3.0_fp16.safetensors',
      lora = 'isometric_dreams.safetensors',
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

    const response = await axios.post(`${COMFYUI_API_URL}/prompt`, {
      prompt: workflow,
      client_id: 'global-mcp-client'
    });

    const promptId = response.data.prompt_id;
    const result = await this.waitForCompletion(promptId, COMFYUI_API_URL);
    
    // 生成された画像をユーザー出力ディレクトリにコピー
    await this.copyComfyUIOutput(result, output_name || 'comfyui_generated');

    return {
      content: [
        {
          type: 'text',
          text: `✅ ComfyUI image generated successfully!\n` +
                `📝 Prompt: "${prompt}"\n` +
                `🎯 Model: ${model}\n` +
                `📐 Size: ${width}x${height}\n` +
                `🔄 Steps: ${steps}\n` +
                `💾 Output directory: ${OUTPUT_DIR}\n` +
                `🆔 Prompt ID: ${promptId}`,
        },
      ],
    };
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

  async waitForCompletion(promptId, apiUrl, maxWait = 60000) {
    const startTime = Date.now();
    
    while (Date.now() - startTime < maxWait) {
      try {
        const response = await axios.get(`${apiUrl}/history/${promptId}`);
        const history = response.data;
        
        if (history[promptId] && history[promptId].status && history[promptId].status.completed) {
          return history[promptId];
        }
        
        await new Promise(resolve => setTimeout(resolve, 2000));
      } catch (error) {
        await new Promise(resolve => setTimeout(resolve, 2000));
      }
    }
    
    throw new Error('Generation timeout');
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