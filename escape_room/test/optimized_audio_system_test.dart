import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:escape_room/framework/audio/optimized_audio_system.dart';
import 'package:escape_room/framework/audio/enhanced_sfx_system.dart';
import 'package:escape_room/framework/audio/integrated_audio_manager.dart';

void main() {
  // テスト環境で必須の初期化
  TestWidgetsFlutterBinding.ensureInitialized();
  group('OptimizedAudioSystem Tests', () {
    late OptimizedAudioSystem audioSystem;

    setUp(() {
      audioSystem = OptimizedAudioSystem();
    });

    tearDown(() {
      audioSystem.dispose();
    });

    test('システム初期化テスト', () async {
      // arrange
      expect(audioSystem.getSystemStatus()['initialized'], false);

      // act
      final success = await audioSystem.initialize();

      // assert
      expect(success, true);
      expect(audioSystem.getSystemStatus()['initialized'], true);
      expect(audioSystem.getSystemStatus()['supportsAudioPool'], !kIsWeb);
    });

    test('GameActionType列挙値テスト', () {
      // arrange & act
      final actionTypes = GameActionType.values;

      // assert
      expect(actionTypes.length, 8);
      expect(actionTypes.contains(GameActionType.generalTap), true);
      expect(actionTypes.contains(GameActionType.itemAcquisition), true);
      expect(actionTypes.contains(GameActionType.gameCleared), true);
    });

    test('OptimizedBgmContext列挙値テスト', () {
      // arrange & act
      final bgmContexts = OptimizedBgmContext.values;

      // assert
      expect(bgmContexts.length, 5);
      expect(OptimizedBgmContext.menu.fileName, 'menu_theme.mp3');
      expect(
        OptimizedBgmContext.exploration.fileName,
        'ambient_exploration.mp3',
      );
      expect(OptimizedBgmContext.victory.fileName, 'victory_fanfare.mp3');
      expect(OptimizedBgmContext.silent.fileName, null);
    });

    test('音響アセットマッピングテスト', () async {
      // arrange
      await audioSystem.initialize();
      final status = audioSystem.getSystemStatus();

      // assert
      expect(status['audioPoolsLoaded'], greaterThan(0));
      if (!kIsWeb) {
        expect(status['supportsAudioPool'], true);
      }
    });
  });

  group('UserActionType互換性テスト', () {
    test('UserActionType → GameActionType 変換テスト', () {
      // arrange & act & assert
      expect(
        UserActionType.generalTap.toGameActionType(),
        GameActionType.generalTap,
      );
      expect(
        UserActionType.uiButtonPress.toGameActionType(),
        GameActionType.uiButtonPress,
      );
      expect(
        UserActionType.hotspotInteraction.toGameActionType(),
        GameActionType.hotspotInteraction,
      );
      expect(
        UserActionType.itemAcquisition.toGameActionType(),
        GameActionType.itemAcquisition,
      );
      expect(
        UserActionType.puzzleSuccess.toGameActionType(),
        GameActionType.puzzleSuccess,
      );
      expect(
        UserActionType.gimmickActivation.toGameActionType(),
        GameActionType.gimmickActivation,
      );
      expect(
        UserActionType.errorAction.toGameActionType(),
        GameActionType.errorAction,
      );
      expect(
        UserActionType.gameCleared.toGameActionType(),
        GameActionType.gameCleared,
      );
    });

    test('全UserActionTypeのマッピング確認', () {
      // arrange
      final userActionTypes = UserActionType.values;

      // act & assert
      for (final userAction in userActionTypes) {
        expect(() => userAction.toGameActionType(), returnsNormally);
      }
    });
  });

  group('統合音響システムテスト', () {
    late IntegratedAudioManager integratedManager;

    setUp(() {
      integratedManager = IntegratedAudioManager();
    });

    test('IntegratedAudioManager singleton テスト', () {
      // arrange
      final instance1 = IntegratedAudioManager();
      final instance2 = IntegratedAudioManager();

      // assert
      expect(instance1, same(instance2));
      expect(instance1, same(integratedManager));
    });

    test('OptimizedAudioSystem singleton テスト', () {
      // arrange
      final instance1 = OptimizedAudioSystem();
      final instance2 = OptimizedAudioSystem();

      // assert
      expect(instance1, same(instance2));
    });
  });

  group('エラーハンドリングテスト', () {
    late OptimizedAudioSystem audioSystem;

    setUp(() {
      audioSystem = OptimizedAudioSystem();
    });

    tearDown(() {
      audioSystem.dispose();
    });

    test('未初期化状態での音響再生テスト', () async {
      // arrange
      expect(audioSystem.getSystemStatus()['initialized'], false);

      // act & assert - エラーが投げられずに正常に処理される
      expect(
        () async =>
            await audioSystem.playActionSound(GameActionType.generalTap),
        returnsNormally,
      );
    });

    test('不正な音量値テスト', () async {
      // arrange
      await audioSystem.initialize();

      // act & assert - 異常な音量値でも正常に処理される
      try {
        await audioSystem.playActionSound(
          GameActionType.generalTap,
          volume: -1.0, // 負の値
        );
        // エラーが発生しないことを確認
      } catch (e) {
        fail('異常な音量値でエラーが発生: $e');
      }

      try {
        await audioSystem.playActionSound(
          GameActionType.generalTap,
          volume: 2.0, // 1.0を超える値
        );
        // エラーが発生しないことを確認
      } catch (e) {
        fail('異常な音量値でエラーが発生: $e');
      }
    }, timeout: const Timeout(Duration(seconds: 5)));

    test('リソース解放テスト', () {
      // act
      audioSystem.dispose();
      final disposedStatus = audioSystem.getSystemStatus();

      // assert
      expect(disposedStatus['initialized'], false);
      expect(disposedStatus['audioPoolsLoaded'], 0);
    });
  });
}
