import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:casual_game_template/game/framework_integration/simple_game_states.dart';
import 'package:casual_game_template/game/framework_integration/simple_game_configuration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('シンプルフレームワークテスト', () {
    test('SimpleGameState クラステスト', () {
      // SimpleGameStartState
      const startState = SimpleGameStartState();
      expect(startState.name, equals('start'));
      expect(startState.description, equals('ゲーム開始待ち状態'));
      
      // SimpleGamePlayingState
      const playingState = SimpleGamePlayingState(
        timeRemaining: 5.0,
        sessionNumber: 1,
      );
      expect(playingState.name, equals('playing'));
      expect(playingState.timeRemaining, equals(5.0));
      expect(playingState.sessionNumber, equals(1));
      
      // SimpleGameOverState
      const gameOverState = SimpleGameOverState(
        finalTime: 0.0,
        sessionNumber: 1,
      );
      expect(gameOverState.name, equals('gameOver'));
      expect(gameOverState.finalTime, equals(0.0));
      expect(gameOverState.sessionNumber, equals(1));
      
      debugPrint('✅ SimpleGameState クラステスト完了');
    });
    
    test('SimpleGameConfig クラステスト', () {
      const config = SimpleGameConfig(
        gameDuration: Duration(seconds: 10),
        stateTexts: {
          'start': 'START',
          'playing': 'TIME: {time}',
          'gameOver': 'GAME OVER',
        },
        stateColors: {
          'start': Color(0xFF00FF00),
          'playing': Color(0xFF0000FF),
          'gameOver': Color(0xFFFF0000),
        },
        fontSizes: {
          'start': 24.0,
          'playing': 28.0,
          'gameOver': 24.0,
        },
        fontWeights: {
          'start': FontWeight.bold,
          'playing': FontWeight.bold,
          'gameOver': FontWeight.bold,
        },
      );
      
      expect(config.gameDuration.inSeconds, equals(10));
      expect(config.getStateText('start'), equals('START'));
      expect(config.getStateText('playing', timeRemaining: 3.5), equals('TIME: 3.5'));
      expect(config.getStateColor('start'), equals(const Color(0xFF00FF00)));
      expect(config.getFontSize('playing'), equals(28.0));
      expect(config.getFontWeight('gameOver'), equals(FontWeight.bold));
      
      debugPrint('✅ SimpleGameConfig クラステスト完了');
    });
    
    test('SimpleGameConfiguration クラステスト', () {
      final configuration = SimpleGameConfiguration.defaultConfig;
      
      expect(configuration.isValid(), isTrue);
      expect(configuration.config.gameDuration.inSeconds, equals(5));
      
      // プリセットテスト
      final easyConfig = SimpleGameConfiguration.easyConfig;
      expect(easyConfig.config.gameDuration.inSeconds, equals(10));
      
      final hardConfig = SimpleGameConfiguration.hardConfig;
      expect(hardConfig.config.gameDuration.inSeconds, equals(3));
      
      debugPrint('✅ SimpleGameConfiguration クラステスト完了');
    });
    
    test('SimpleGameConfigPresets クラステスト', () {
      SimpleGameConfigPresets.initialize();
      
      final availablePresets = SimpleGameConfigPresets.getAvailablePresets();
      expect(availablePresets.contains('default'), isTrue);
      expect(availablePresets.contains('easy'), isTrue);
      expect(availablePresets.contains('hard'), isTrue);
      
      final defaultPreset = SimpleGameConfigPresets.getPreset('default');
      expect(defaultPreset, isNotNull);
      expect(defaultPreset!.gameDuration.inSeconds, equals(5));
      
      final easyPreset = SimpleGameConfigPresets.getPreset('easy');
      expect(easyPreset, isNotNull);
      expect(easyPreset!.gameDuration.inSeconds, equals(10));
      
      debugPrint('✅ SimpleGameConfigPresets クラステスト完了');
    });
    
    test('SimpleGameStateProvider 基本テスト', () {
      final stateProvider = SimpleGameStateProvider();
      
      // 初期状态確認
      expect(stateProvider.isInState<SimpleGameStartState>(), isTrue);
      
      // ゲーム開始
      final startSuccess = stateProvider.startGame(5.0);
      expect(startSuccess, isTrue);
      expect(stateProvider.isInState<SimpleGamePlayingState>(), isTrue);
      
      // 現在の状態情報を取得
      final gameInfo = stateProvider.getCurrentGameInfo();
      expect(gameInfo['stateName'], equals('playing'));
      expect(gameInfo['timeRemaining'], equals(5.0));
      expect(gameInfo['canStart'], isFalse);
      expect(gameInfo['canRestart'], isFalse);
      
      debugPrint('✅ SimpleGameStateProvider 基本テスト完了');
    });
    
    test('SimpleGameStateFactory テスト', () {
      final startState = SimpleGameStateFactory.createStartState();
      expect(startState.name, equals('start'));
      
      final playingState = SimpleGameStateFactory.createPlayingState(
        timeRemaining: 3.0,
        sessionNumber: 2,
      );
      expect(playingState.timeRemaining, equals(3.0));
      expect(playingState.sessionNumber, equals(2));
      
      final gameOverState = SimpleGameStateFactory.createGameOverState(
        finalTime: 0.0,
        sessionNumber: 2,
      );
      expect(gameOverState.finalTime, equals(0.0));
      expect(gameOverState.sessionNumber, equals(2));
      
      debugPrint('✅ SimpleGameStateFactory テスト完了');
    });
    
    test('JSON変換テスト', () {
      const config = SimpleGameConfig(
        gameDuration: Duration(seconds: 15),
        stateTexts: {
          'start': 'テスト開始',
          'playing': 'プレイ中: {time}',
          'gameOver': 'テスト終了',
        },
        stateColors: {
          'start': Color(0xFF123456),
          'playing': Color(0xFF654321),
          'gameOver': Color(0xFF999999),
        },
        fontSizes: {
          'start': 20.0,
          'playing': 24.0,
          'gameOver': 18.0,
        },
        fontWeights: {
          'start': FontWeight.w400,
          'playing': FontWeight.w600,
          'gameOver': FontWeight.w300,
        },
      );
      
      // JSON変換
      final json = config.toJson();
      expect(json['gameDurationMs'], equals(15000));
      expect(json['stateTexts']['start'], equals('テスト開始'));
      
      // JSON復元
      final restoredConfig = SimpleGameConfig.fromJson(json);
      expect(restoredConfig.gameDuration.inSeconds, equals(15));
      expect(restoredConfig.getStateText('start'), equals('テスト開始'));
      expect(restoredConfig.getStateColor('start'), equals(const Color(0xFF123456)));
      
      debugPrint('✅ JSON変換テスト完了');
    });
  });
}