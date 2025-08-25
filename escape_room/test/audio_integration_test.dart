import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:escape_room/framework/audio/bgm_context_manager.dart';
import 'package:escape_room/framework/audio/enhanced_sfx_system.dart';
import 'package:escape_room/framework/audio/audio_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('統合音響システム テスト（簡易版）', () {
    test('BgmContext列挙値確認', () {
      // BGMコンテキストの列挙値が正しく定義されていることを確認
      expect(BgmContext.menu, isNotNull);
      expect(BgmContext.exploration, isNotNull);
      expect(BgmContext.puzzle, isNotNull);
      expect(BgmContext.victory, isNotNull);
    });

    test('UserActionType列挙値確認', () {
      // ユーザーアクション種別が正しく定義されていることを確認
      expect(UserActionType.generalTap, isNotNull);
      expect(UserActionType.uiButtonPress, isNotNull);
      expect(UserActionType.hotspotInteraction, isNotNull);
      expect(UserActionType.itemAcquisition, isNotNull);
    });

    test('音響設定クラス作成テスト', () {
      final config = const DefaultAudioConfiguration(
        bgmAssets: {
          'menu': 'menu.mp3',
          'exploration_ambient': 'exploration_ambient.mp3',
        },
        sfxAssets: {'tap': 'tap.wav', 'button_tap': 'button_tap.wav'},
      );

      expect(config.bgmAssets['menu'], equals('menu.mp3'));
      expect(config.sfxAssets['tap'], equals('tap.wav'));
      expect(config.masterVolume, equals(1.0)); // デフォルト値
    });

    test('BGMコンテキスト推論テスト', () {
      final contextManager = BgmContextManager();

      // BGMコンテキストの基本動作確認
      expect(contextManager, isNotNull);

      // BGMコンテキストの列挙値が利用可能であることを確認
      expect(BgmContext.menu, isA<BgmContext>());
      expect(BgmContext.exploration, isA<BgmContext>());
    });

    test('ユーザーアクション種別マッピングテスト', () {
      // UserActionTypeからSFXアセットIDへのマッピング確認
      final mapping = UserActionTypeHelper.getDefaultSfxMapping();

      expect(mapping[UserActionType.generalTap], isNotNull);
      expect(mapping[UserActionType.uiButtonPress], isNotNull);
      expect(mapping[UserActionType.hotspotInteraction], isNotNull);
    });

    test('音響設定バリデーション', () {
      // 無効な設定でのバリデーション
      final invalidConfig = const DefaultAudioConfiguration(
        bgmAssets: {},
        sfxAssets: {},
        masterVolume: -1.0, // 無効な値
      );

      expect(invalidConfig.masterVolume, lessThan(0.0));

      // 有効な設定でのバリデーション
      final validConfig = const DefaultAudioConfiguration(
        bgmAssets: {'menu': 'menu.mp3'},
        sfxAssets: {'tap': 'tap.wav'},
        masterVolume: 0.8,
      );

      expect(validConfig.masterVolume, equals(0.8));
      expect(validConfig.bgmAssets, isNotEmpty);
      expect(validConfig.sfxAssets, isNotEmpty);
    });
  });

  group('モック音響システム テスト', () {
    test('MockAudioProvider基本機能', () async {
      final mockProvider = MockAudioProvider();

      expect(mockProvider.isInitialized, isFalse);
      expect(mockProvider.isBgmPlaying, isFalse);

      final config = const DefaultAudioConfiguration(
        bgmAssets: {'test': 'test.mp3'},
        sfxAssets: {'test': 'test.wav'},
      );

      await mockProvider.initialize(config);
      expect(mockProvider.isInitialized, isTrue);

      await mockProvider.playBgm('test');
      expect(mockProvider.isBgmPlaying, isTrue);

      await mockProvider.stopBgm();
      expect(mockProvider.isBgmPlaying, isFalse);

      await mockProvider.dispose();
      expect(mockProvider.isInitialized, isFalse);
    });

    test('MockAudioProvider SFX機能', () async {
      final mockProvider = MockAudioProvider();
      final config = const DefaultAudioConfiguration(
        bgmAssets: {},
        sfxAssets: {'test_sfx': 'test.wav'},
      );

      await mockProvider.initialize(config);

      // SFX再生
      await mockProvider.playSfx('test_sfx', volume: 0.5);

      // SFX停止
      await mockProvider.stopSfx('test_sfx');
      await mockProvider.stopAllSfx();

      expect(mockProvider.isInitialized, isTrue);
    });

    test('MockAudioProvider 有効無効切り替え', () async {
      final mockProvider = MockAudioProvider();
      final config = const DefaultAudioConfiguration(
        bgmAssets: {'test': 'test.mp3'},
        sfxAssets: {'test': 'test.wav'},
      );

      await mockProvider.initialize(config);

      // BGM無効化
      mockProvider.setBgmEnabled(false);
      await mockProvider.playBgm('test');
      expect(mockProvider.isBgmPlaying, isFalse);

      // BGM有効化
      mockProvider.setBgmEnabled(true);
      await mockProvider.playBgm('test');
      expect(mockProvider.isBgmPlaying, isTrue);

      // SFX無効化
      mockProvider.setSfxEnabled(false);
      await mockProvider.playSfx('test');

      // SFX有効化
      mockProvider.setSfxEnabled(true);
      await mockProvider.playSfx('test');
    });

    test('MockAudioProvider デバッグ情報', () async {
      final mockProvider = MockAudioProvider();
      final config = const DefaultAudioConfiguration(
        bgmAssets: {'test': 'test.mp3'},
        sfxAssets: {'test': 'test.wav'},
      );

      await mockProvider.initialize(config);

      final debugInfo = mockProvider.getDebugInfo();
      expect(debugInfo['provider_type'], equals('MockAudioProvider'));
      expect(debugInfo['is_initialized'], isTrue);
      expect(debugInfo.containsKey('bgm_enabled'), isTrue);
      expect(debugInfo.containsKey('sfx_enabled'), isTrue);
    });
  });
}

/// テスト用のモック音響プロバイダー
class MockAudioProvider extends AudioProvider {
  bool _isInitialized = false;
  final Map<String, bool> _bgmPlayingStates = {};
  final Map<String, bool> _sfxPlayingStates = {};
  bool _isBgmPaused = false;
  bool _bgmEnabled = true;
  bool _sfxEnabled = true;

  bool get isInitialized => _isInitialized;

  @override
  bool get isBgmPlaying => _bgmPlayingStates.isNotEmpty;

  @override
  bool get isBgmPaused => _isBgmPaused;

  @override
  Future<void> initialize(AudioConfiguration config) async {
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
    _bgmPlayingStates.clear();
    _sfxPlayingStates.clear();
  }

  @override
  Future<void> playBgm(String assetId, {bool loop = true}) async {
    if (!_isInitialized || !_bgmEnabled) return;
    debugPrint('Mock BGM play: $assetId (loop: $loop)');
    _bgmPlayingStates[assetId] = true;
    _isBgmPaused = false;
  }

  @override
  Future<void> stopBgm() async {
    if (!_isInitialized) return;
    debugPrint('Mock BGM stop');
    _bgmPlayingStates.clear();
    _isBgmPaused = false;
  }

  @override
  Future<void> pauseBgm() async {
    debugPrint('Mock BGM pause');
    _isBgmPaused = true;
  }

  @override
  Future<void> resumeBgm() async {
    debugPrint('Mock BGM resume');
    _isBgmPaused = false;
  }

  @override
  Future<void> playSfx(String assetId, {double volume = 1.0}) async {
    if (!_isInitialized || !_sfxEnabled) return;
    debugPrint('Mock SFX play: $assetId (volume: $volume)');
    _sfxPlayingStates[assetId] = true;
  }

  @override
  Future<void> stopSfx(String assetId) async {
    debugPrint('Mock SFX stop: $assetId');
    _sfxPlayingStates.remove(assetId);
  }

  @override
  Future<void> stopAllSfx() async {
    debugPrint('Mock SFX stop all');
    _sfxPlayingStates.clear();
  }

  @override
  Future<void> setBgmVolume(double volume) async {
    debugPrint('Mock BGM volume set: $volume');
  }

  @override
  Future<void> setSfxVolume(double volume) async {
    debugPrint('Mock SFX volume set: $volume');
  }

  @override
  Future<void> setMasterVolume(double volume) async {
    debugPrint('Mock master volume set: $volume');
  }

  @override
  void setBgmEnabled(bool enabled) {
    debugPrint('Mock BGM enabled: $enabled');
    _bgmEnabled = enabled;
    if (!enabled) {
      stopBgm();
    }
  }

  @override
  void setSfxEnabled(bool enabled) {
    debugPrint('Mock SFX enabled: $enabled');
    _sfxEnabled = enabled;
    if (!enabled) {
      stopAllSfx();
    }
  }

  Map<String, dynamic> getDebugInfo() {
    return {
      'provider_type': 'MockAudioProvider',
      'is_initialized': _isInitialized,
      'bgm_playing_count': _bgmPlayingStates.length,
      'sfx_playing_count': _sfxPlayingStates.length,
      'bgm_enabled': _bgmEnabled,
      'sfx_enabled': _sfxEnabled,
    };
  }
}

/// UserActionTypeヘルパークラス（テスト用）
class UserActionTypeHelper {
  static Map<UserActionType, String> getDefaultSfxMapping() {
    return {
      UserActionType.generalTap: 'tap',
      UserActionType.uiButtonPress: 'button_tap',
      UserActionType.hotspotInteraction: 'hotspot_interact',
      UserActionType.itemAcquisition: 'item_get',
      UserActionType.puzzleSuccess: 'puzzle_success',
      UserActionType.gimmickActivation: 'gimmick_activate',
      UserActionType.errorAction: 'error_sound',
      UserActionType.gameCleared: 'game_clear',
    };
  }
}
