#!/usr/bin/env node

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { 
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';

import { ComfyUIService } from './comfyui-service.js';
import { WebUIService } from './webui-service.js';
import { Utils } from './utils.js';

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

    this.comfyui = new ComfyUIService();
    this.webui = new WebUIService();
    
    // 出力ディレクトリ確保
    Utils.ensureOutputDirectory();
    
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
              prompt: {
                type: 'string',
                description: 'Text prompt for image generation'
              },
              negative_prompt: {
                type: 'string',
                description: 'Negative prompt',
                default: 'blurry, low quality, worst quality, low resolution'
              },
              steps: { type: 'number', default: 30 },
              cfg_scale: { type: 'number', default: 8 },
              width: { type: 'number', default: 1024 },
              height: { type: 'number', default: 1024 },
              sampler: { type: 'string', default: 'dpmpp_2m' },
              scheduler: { type: 'string', default: 'karras' },
              model: {
                type: 'string',
                description: 'Model filename',
                default: 'Counterfeit-V3.0_fp16.safetensors'
              },
              quality_preset: {
                type: 'string',
                description: 'Quality preset for generation',
                enum: ['draft', 'standard', 'high', 'ultra'],
                default: 'high'
              },
              output_name: {
                type: 'string',
                description: 'Custom output filename (optional)'
              }
            },
            required: ['prompt']
          }
        },
        {
          name: 'comfyui_inpainting',
          description: 'Inpaint specific areas of an image while preserving the rest - perfect for escape room asset differences',
          inputSchema: {
            type: 'object',
            properties: {
              reference_image: {
                type: 'string',
                description: 'Path to original image file'
              },
              mask_image: {
                type: 'string',
                description: 'Path to mask image file (white=modify, black=preserve)'
              },
              prompt: {
                type: 'string',
                description: 'Text prompt describing what to generate in masked area'
              },
              negative_prompt: {
                type: 'string',
                description: 'Negative prompt',
                default: 'blurry, low quality, artifacts'
              },
              steps: { type: 'number', default: 20 },
              cfg_scale: { type: 'number', default: 7 },
              denoise: {
                type: 'number',
                description: 'Denoising strength (0.1-1.0, lower=more original preserved)',
                default: 0.75
              },
              model: {
                type: 'string',
                description: 'Model filename',
                default: 'Counterfeit-V3.0_fp16.safetensors'
              },
              output_name: {
                type: 'string',
                description: 'Custom output filename (optional)'
              }
            },
            required: ['reference_image', 'mask_image', 'prompt']
          }
        },
        {
          name: 'check_services',
          description: 'Check if ComfyUI and WebUI services are running',
          inputSchema: {
            type: 'object',
            properties: {}
          }
        },
        {
          name: 'list_models',
          description: 'List available models in both services',
          inputSchema: {
            type: 'object',
            properties: {
              service: {
                type: 'string',
                enum: ['comfyui', 'webui', 'both'],
                default: 'both'
              }
            }
          }
        },
        {
          name: 'list_outputs',
          description: 'List generated images in output directory',
          inputSchema: {
            type: 'object',
            properties: {
              limit: {
                type: 'number',
                description: 'Maximum number of files to list',
                default: 10
              }
            }
          }
        }
      ]
    }));

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          case 'comfyui_generate':
            return await this.handleComfyUIGenerate(args);
            
          case 'comfyui_inpainting':
            return await this.handleComfyUIInpainting(args);
            
          case 'check_services':
            return await this.handleCheckServices();
            
          case 'list_models':
            return await this.handleListModels(args);
            
          case 'list_outputs':
            return await this.handleListOutputs(args);
            
          default:
            throw new Error(`Unknown tool: ${name}`);
        }
      } catch (error) {
        const errorLog = Utils.logError(`Tool: ${name}`, error, args);
        return {
          content: [
            {
              type: 'text',
              text: `Error: ${error.message}`
            }
          ],
          isError: true,
          _toolResult: error.message
        };
      }
    });
  }

  async handleComfyUIGenerate(args) {
    // 品質プリセットが指定されている場合は適用
    if (args.quality_preset && !args.steps && !args.cfg_scale && !args.width && !args.height) {
      const preset = Utils.getQualityPreset(args.quality_preset);
      args = { ...args, ...preset };
    }

    const result = await this.comfyui.generateText2Image(args);
    
    return {
      content: [
        {
          type: 'text',
          text: `Image generated successfully: ${result.filename}`
        }
      ],
      _toolResult: result
    };
  }

  async handleComfyUIInpainting(args) {
    const result = await this.comfyui.generateInpainting(args);
    
    return {
      content: [
        {
          type: 'text',
          text: `Inpainting completed successfully: ${result.filename}`
        }
      ],
      _toolResult: result
    };
  }

  async handleCheckServices() {
    const status = await Utils.checkServicesStatus();
    
    return {
      content: [
        {
          type: 'text',
          text: `Service Status:\nComfyUI: ${status.comfyui ? 'Running' : 'Not running'}\nWebUI: ${status.webui ? 'Running' : 'Not running'}\nChecked at: ${status.timestamp}`
        }
      ],
      _toolResult: status
    };
  }

  async handleListModels(args) {
    const models = await Utils.listComfyUIModels();
    
    return {
      content: [
        {
          type: 'text',
          text: `Available models: ${models.join(', ')}`
        }
      ],
      _toolResult: models
    };
  }

  async handleListOutputs(args) {
    const outputs = await Utils.listOutputImages(args.limit);
    
    return {
      content: [
        {
          type: 'text',
          text: `Generated images (${outputs.length}):\n${outputs.map(img => `- ${img.filename} (${img.created.toLocaleString()})`).join('\n')}`
        }
      ],
      _toolResult: outputs
    };
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
  }
}

const server = new GlobalImageGenerationMCP();
server.run().catch(console.error);