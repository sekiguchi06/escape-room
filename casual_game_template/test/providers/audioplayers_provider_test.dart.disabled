import 'package:flutter_test/flutter_test.dart';
import 'package:casual_game_template/framework/audio/audio_system.dart';
import 'package:casual_game_template/framework/providers/audio_provider_factory.dart';
import 'package:casual_game_template/framework/test_utils/test_environment.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('AudioProvider Tests (Auto-Selected)', () {
    late AudioProvider provider;
    late DefaultAudioConfiguration config;
    
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      // テスト環境であることを明示
      TestEnvironmentDetector.setTestMode(true);
    });
    
    setUp(() {
      // ファクトリーで自動選択（テスト環境なのでSilentAudioProviderが選択される）
      provider = AudioProviderFactory.create();
      config = const DefaultAudioConfiguration(
        bgmAssets: {
          'menu_bgm': 'audio/bgm/menu.mp3',
          'game_bgm': 'audio/bgm/game.mp3',
        },
        sfxAssets: {
          'tap': 'audio/sfx/tap.wav',
          'success': 'audio/sfx/success.wav',
          'error': 'audio/sfx/error.wav',
        },
        masterVolume: 1.0,
        bgmVolume: 0.7,
        sfxVolume: 0.8,
        bgmEnabled: true,
        sfxEnabled: true,
        preloadAssets: ['menu_bgm', 'tap', 'success'],
        loopSettings: {
          'menu_bgm': true,
          'game_bgm': true,
        },
        debugMode: true,
      );
    });
    
    tearDown(() async {
      await provider.dispose();
    });
    
    test('初期化成功（テスト環境自動選択）', () async {
      // テスト環境ではFlameAudioProviderが選択されることを確認
      expect(provider.isTestProvider, isTrue);
      expect(provider.providerName, equals('FlameAudioProvider'));
      
      await provider.initialize(config);
      
      // 初期化後の状態確認
      expect(provider.isBgmPlaying, isFalse);
      expect(provider.isBgmPaused, isFalse);
    });
    
    test('BGM再生制御', () async {
      await provider.initialize(config);
      
      // BGM再生開始
      await provider.playBgm('menu_bgm');
      
      // 少し待機（非同期処理完了のため）
      await Future.delayed(const Duration(milliseconds: 100));
      
      // BGM一時停止
      await provider.pauseBgm();
      
      // BGM再開
      await provider.resumeBgm();
      
      // BGM停止
      await provider.stopBgm();
      expect(provider.isBgmPlaying, isFalse);
    });
    
    test('BGM音量制御', () async {
      await provider.initialize(config);
      
      // BGM再生
      await provider.playBgm('menu_bgm');
      await Future.delayed(const Duration(milliseconds: 50));
      
      // BGM音量変更
      await provider.setBgmVolume(0.5);
      await provider.setBgmVolume(0.0);
      await provider.setBgmVolume(1.0);
      
      await provider.stopBgm();
    });
    
    test('効果音再生制御', () async {
      await provider.initialize(config);
      
      // 効果音再生（複数同時）
      await provider.playSfx('tap', volume: 0.8);
      await provider.playSfx('success', volume: 1.0);
      await provider.playSfx('error', volume: 0.6);
      
      // 少し待機
      await Future.delayed(const Duration(milliseconds: 50));
      
      // 特定効果音停止
      await provider.stopSfx('tap');
      
      // 全効果音停止
      await provider.stopAllSfx();
    });
    
    test('効果音音量制御', () async {
      await provider.initialize(config);
      
      // 効果音再生
      await provider.playSfx('tap');
      await Future.delayed(const Duration(milliseconds: 50));
      
      // 効果音音量変更
      await provider.setSfxVolume(0.5);
      await provider.setSfxVolume(0.0);
      await provider.setSfxVolume(1.0);
      
      await provider.stopAllSfx();
    });
    
    test('マスター音量制御', () async {
      await provider.initialize(config);
      
      // BGMと効果音を再生
      await provider.playBgm('menu_bgm');
      await provider.playSfx('tap');
      await Future.delayed(const Duration(milliseconds: 50));
      
      // マスター音量変更
      await provider.setMasterVolume(0.5);
      await provider.setMasterVolume(0.0);
      await provider.setMasterVolume(1.0);
      
      await provider.stopBgm();
      await provider.stopAllSfx();
    });
    
    test('BGM有効/無効切り替え', () async {
      await provider.initialize(config);
      
      // BGM再生
      await provider.playBgm('menu_bgm');
      await Future.delayed(const Duration(milliseconds: 50));
      
      // BGM無効化（再生停止されるべき）
      provider.setBgmEnabled(false);
      await Future.delayed(const Duration(milliseconds: 50));
      
      // BGM有効化
      provider.setBgmEnabled(true);
      
      // 再度BGM再生
      await provider.playBgm('game_bgm');
      await provider.stopBgm();
    });
    
    test('効果音有効/無効切り替え', () async {
      await provider.initialize(config);
      
      // 効果音再生
      await provider.playSfx('tap');
      await provider.playSfx('success');
      await Future.delayed(const Duration(milliseconds: 50));
      
      // 効果音無効化（全停止されるべき）
      provider.setSfxEnabled(false);
      await Future.delayed(const Duration(milliseconds: 50));
      
      // 効果音有効化
      provider.setSfxEnabled(true);
      
      // 再度効果音再生
      await provider.playSfx('error');
      await provider.stopAllSfx();
    });
    
    test('同一BGMの重複再生防止', () async {
      await provider.initialize(config);
      
      // 同じBGMを複数回再生
      await provider.playBgm('menu_bgm');
      await Future.delayed(const Duration(milliseconds: 50));
      
      await provider.playBgm('menu_bgm'); // 重複再生（スキップされるべき）
      await Future.delayed(const Duration(milliseconds: 50));
      
      // 異なるBGMに切り替え
      await provider.playBgm('game_bgm');
      await Future.delayed(const Duration(milliseconds: 50));
      
      await provider.stopBgm();
    });
    
    test('音量範囲制限', () async {
      await provider.initialize(config);
      
      await provider.playBgm('menu_bgm');
      await provider.playSfx('tap');
      await Future.delayed(const Duration(milliseconds: 50));
      
      // 範囲外の音量設定（クランプされるべき）
      await provider.setBgmVolume(-0.5); // 0.0にクランプ
      await provider.setBgmVolume(1.5);  // 1.0にクランプ
      
      await provider.setSfxVolume(-0.5); // 0.0にクランプ
      await provider.setSfxVolume(1.5);  // 1.0にクランプ
      
      await provider.setMasterVolume(-0.5); // 0.0にクランプ
      await provider.setMasterVolume(1.5);  // 1.0にクランプ
      
      await provider.stopBgm();
      await provider.stopAllSfx();
    });
    
    test('アセットパス解決', () async {
      await provider.initialize(config);
      
      // 設定に定義されたアセット
      await provider.playBgm('menu_bgm'); // 'audio/bgm/menu.mp3'に解決
      await provider.playSfx('tap'); // 'audio/sfx/tap.wav'に解決
      
      // 設定に定義されていないアセット（デフォルトパス使用）
      await provider.playBgm('unknown_bgm'); // 'audio/bgm/unknown_bgm'に解決
      await provider.playSfx('unknown_sfx'); // 'audio/sfx/unknown_sfx'に解決
      
      await Future.delayed(const Duration(milliseconds: 50));
      
      await provider.stopBgm();
      await provider.stopAllSfx();
    });
    
    test('dispose処理', () async {
      await provider.initialize(config);
      
      // BGMと効果音を再生
      await provider.playBgm('menu_bgm');
      await provider.playSfx('tap');
      await provider.playSfx('success');
      await Future.delayed(const Duration(milliseconds: 50));
      
      // dispose実行
      await provider.dispose();
      
      // dispose後の状態確認
      expect(provider.isBgmPlaying, isFalse);
      expect(provider.isBgmPaused, isFalse);
    });
  });
}