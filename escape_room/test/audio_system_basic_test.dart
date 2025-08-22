import 'package:flutter_test/flutter_test.dart';
import 'package:escape_room/framework/audio/bgm_context_manager.dart';
import 'package:escape_room/framework/audio/enhanced_sfx_system.dart';
import 'package:escape_room/framework/audio/integrated_audio_manager.dart';

void main() {
  group('音響システム 基本テスト', () {
    test('BGMコンテキスト定数テスト', () {
      // BGMコンテキストの基本的な定数確認
      expect(BgmContext.menu.name, 'menu');
      expect(BgmContext.menu.bgmAssetId, 'menu');

      expect(BgmContext.exploration.name, 'exploration');
      expect(BgmContext.exploration.bgmAssetId, 'exploration_ambient');

      expect(BgmContext.victory.name, 'victory');
      expect(BgmContext.victory.bgmAssetId, 'victory_fanfare');

      expect(BgmContext.silent.name, 'silent');
      expect(BgmContext.silent.bgmAssetId, null);
    });

    test('ゲーム状態からBGMコンテキスト推定テスト', () {
      // メニュー状態
      final menuContext = BgmContext.fromGameState(
        isGameActive: false,
        isGameCleared: false,
        isPuzzleActive: false,
      );
      expect(menuContext, BgmContext.menu);

      // 探索状態
      final explorationContext = BgmContext.fromGameState(
        isGameActive: true,
        isGameCleared: false,
        isPuzzleActive: false,
      );
      expect(explorationContext, BgmContext.exploration);

      // パズル状態
      final puzzleContext = BgmContext.fromGameState(
        isGameActive: true,
        isGameCleared: false,
        isPuzzleActive: true,
      );
      expect(puzzleContext, BgmContext.puzzle);

      // クリア状態
      final victoryContext = BgmContext.fromGameState(
        isGameActive: true,
        isGameCleared: true,
        isPuzzleActive: false,
      );
      expect(victoryContext, BgmContext.victory);
    });

    test('ユーザーアクション種別定数テスト', () {
      // ユーザーアクション種別の確認
      final actions = UserActionType.values;

      expect(actions.contains(UserActionType.generalTap), true);
      expect(actions.contains(UserActionType.uiButtonPress), true);
      expect(actions.contains(UserActionType.hotspotInteraction), true);
      expect(actions.contains(UserActionType.itemAcquisition), true);
      expect(actions.contains(UserActionType.puzzleSuccess), true);
      expect(actions.contains(UserActionType.gimmickActivation), true);
      expect(actions.contains(UserActionType.errorAction), true);
      expect(actions.contains(UserActionType.gameCleared), true);

      // 全8種類のアクションが定義されている
      expect(actions.length, 8);
    });

    test('ゲーム音響コンテキスト定数テスト', () {
      // ゲーム音響コンテキストの確認
      final contexts = GameAudioContext.values;

      expect(contexts.contains(GameAudioContext.gameStart), true);
      expect(contexts.contains(GameAudioContext.gameExploration), true);
      expect(contexts.contains(GameAudioContext.puzzleActive), true);
      expect(contexts.contains(GameAudioContext.gameCleared), true);
      expect(contexts.contains(GameAudioContext.gamePaused), true);
      expect(contexts.contains(GameAudioContext.gameResumed), true);

      // 全6種類のコンテキストが定義されている
      expect(contexts.length, 6);
    });

    test('音響システムクラス初期化テスト', () {
      // シングルトンインスタンス確認
      final bgmManager1 = BgmContextManager();
      final bgmManager2 = BgmContextManager();
      expect(bgmManager1, same(bgmManager2));

      final sfxSystem1 = EnhancedSfxSystem();
      final sfxSystem2 = EnhancedSfxSystem();
      expect(sfxSystem1, same(sfxSystem2));

      final integratedManager1 = IntegratedAudioManager();
      final integratedManager2 = IntegratedAudioManager();
      expect(integratedManager1, same(integratedManager2));
    });
  });

  group('音響システム 統合クラステスト', () {
    test('統合音響管理システム デバッグ情報テスト', () {
      final manager = IntegratedAudioManager();
      final debugInfo = manager.getDebugInfo();

      // 初期化前はfalse
      expect(debugInfo['isInitialized'], false);
      expect(debugInfo['currentBgmContext'], 'silent');
      expect(debugInfo['isBgmPlaying'], false);
    });

    test('BGMコンテキスト管理システム 初期状態テスト', () {
      final manager = BgmContextManager();

      // 初期状態の確認
      expect(manager.currentContext, BgmContext.menu);
      expect(manager.isBgmPlaying, false);
    });
  });
}
