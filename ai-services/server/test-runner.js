#!/usr/bin/env node

import { ComfyUIService } from './comfyui-service.js';
import { WebUIService } from './webui-service.js';
import { Utils } from './utils.js';

class TestRunner {
  constructor() {
    this.comfyui = new ComfyUIService();
    this.webui = new WebUIService();
    this.results = [];
  }

  async runTest(testName, testFunction) {
    console.log(`\n🧪 Running test: ${testName}`);
    const startTime = Date.now();
    
    try {
      const result = await testFunction();
      const duration = Date.now() - startTime;
      
      this.results.push({
        test: testName,
        status: 'PASS',
        duration: duration,
        result: result
      });
      
      console.log(`✅ ${testName} - PASS (${duration}ms)`);
      return result;
    } catch (error) {
      const duration = Date.now() - startTime;
      
      this.results.push({
        test: testName,
        status: 'FAIL',
        duration: duration,
        error: error.message
      });
      
      console.log(`❌ ${testName} - FAIL (${duration}ms)`);
      console.log(`   Error: ${error.message}`);
      return null;
    }
  }

  async testComfyUIConnection() {
    return await this.runTest('ComfyUI Connection', async () => {
      const result = await this.comfyui.ensureComfyUIRunning();
      if (!result) throw new Error('ComfyUI failed to start');
      return 'ComfyUI is running';
    });
  }

  async testComfyUIBasicGeneration() {
    return await this.runTest('ComfyUI Basic Generation', async () => {
      const result = await this.comfyui.generateText2Image({
        prompt: 'simple test image, colorful shapes',
        steps: 10,
        width: 512,
        height: 512,
        output_name: 'test_basic'
      });
      return `Generated: ${result.filename}`;
    });
  }

  async testComfyUIInpainting() {
    return await this.runTest('ComfyUI Inpainting', async () => {
      // テスト用マスクと画像があるかチェック
      const refImage = '/Users/sekiguchi/git/escape-room/escape_room/assets/images/room_test_new.png';
      const maskImage = '/Users/sekiguchi/git/escape-room/escape_room/assets/images/candle_mask_simple.png';
      
      const refExists = await Utils.fileExists(refImage);
      const maskExists = await Utils.fileExists(maskImage);
      
      if (!refExists || !maskExists) {
        throw new Error('Test images not found');
      }
      
      const result = await this.comfyui.generateInpainting({
        reference_image: refImage,
        mask_image: maskImage,
        prompt: 'lit candle with bright flame',
        steps: 15,
        denoise: 0.6,
        output_name: 'test_inpainting'
      });
      
      return `Inpainting generated: ${result.filename}`;
    });
  }

  async testServicesStatus() {
    return await this.runTest('Services Status Check', async () => {
      const status = await Utils.checkServicesStatus();
      return `ComfyUI: ${status.comfyui}, WebUI: ${status.webui}`;
    });
  }

  async testListModels() {
    return await this.runTest('List Available Models', async () => {
      const models = await Utils.listComfyUIModels();
      return `Found ${models.length} models: ${models.slice(0, 3).join(', ')}...`;
    });
  }

  async testOutputListing() {
    return await this.runTest('List Output Images', async () => {
      const outputs = await Utils.listOutputImages(5);
      return `Found ${outputs.length} output images`;
    });
  }

  async runAllTests() {
    console.log('🚀 Starting comprehensive test suite...\n');
    
    // 基本接続テスト
    await this.testServicesStatus();
    await this.testComfyUIConnection();
    
    // 機能テスト
    await this.testListModels();
    await this.testOutputListing();
    await this.testComfyUIBasicGeneration();
    await this.testComfyUIInpainting();
    
    this.printSummary();
  }

  async runQuickTest() {
    console.log('⚡ Running quick connectivity tests...\n');
    
    await this.testServicesStatus();
    await this.testComfyUIConnection();
    await this.testListModels();
    
    this.printSummary();
  }

  printSummary() {
    console.log('\n📊 Test Results Summary:');
    console.log('========================');
    
    const passed = this.results.filter(r => r.status === 'PASS').length;
    const failed = this.results.filter(r => r.status === 'FAIL').length;
    const totalTime = this.results.reduce((sum, r) => sum + r.duration, 0);
    
    console.log(`Total Tests: ${this.results.length}`);
    console.log(`Passed: ${passed} ✅`);
    console.log(`Failed: ${failed} ❌`);
    console.log(`Total Time: ${totalTime}ms`);
    
    if (failed > 0) {
      console.log('\n❌ Failed Tests:');
      this.results
        .filter(r => r.status === 'FAIL')
        .forEach(r => {
          console.log(`   - ${r.test}: ${r.error}`);
        });
    }
    
    console.log('\n' + (failed === 0 ? '🎉 All tests passed!' : '⚠️  Some tests failed - check errors above'));
  }
}

// コマンドライン実行
if (import.meta.url === `file://${process.argv[1]}`) {
  const runner = new TestRunner();
  const testType = process.argv[2] || 'all';
  
  switch (testType) {
    case 'quick':
      await runner.runQuickTest();
      break;
    case 'all':
      await runner.runAllTests();
      break;
    default:
      console.log('Usage: node test-runner.js [quick|all]');
      break;
  }
}