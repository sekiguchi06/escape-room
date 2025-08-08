import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:casual_game_template/framework/error/flutter_official_error_handling.dart';

/// Flutter公式準拠エラーハンドリングシステムの単体テスト
/// 
/// テスト対象:
/// 1. FlutterError.onError統合
/// 2. エラータイプ分類の正確性
/// 3. エラーリカバリー戦略
/// 4. エラー履歴管理
/// 5. エラー統計機能
/// 6. ユーザーフレンドリーメッセージ
/// 7. Flutter公式準拠性確認

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('🛡️ Flutter公式準拠エラーハンドリング テスト', () {
    
    group('GameError基本機能テスト', () {
      test('GameError構造確認', () {
        final error = GameError(
          type: GameErrorType.network,
          message: 'Connection timeout',
          details: 'Failed to connect to server',
          originalError: Exception('Network error'),
          stackTrace: StackTrace.current,
          timestamp: DateTime.now(),
        );
        
        expect(error.type, equals(GameErrorType.network));
        expect(error.message, equals('Connection timeout'));
        expect(error.details, equals('Failed to connect to server'));
        expect(error.originalError, isA<Exception>());
        expect(error.stackTrace, isNotNull);
        expect(error.timestamp, isA<DateTime>());
      });
      
      test('ユーザー向けメッセージ確認', () {
        final testCases = <GameErrorType, String>{
          GameErrorType.network: 'ネットワーク接続を確認してください',
          GameErrorType.adLoad: '広告の読み込みに失敗しました',
          GameErrorType.audioPlayback: '音声の再生に問題が発生しました',
          GameErrorType.gameLogic: 'ゲームでエラーが発生しました',
          GameErrorType.resourceLoad: 'データの読み込みに失敗しました',
          GameErrorType.configuration: '設定に問題があります',
          GameErrorType.permission: '必要な権限が不足しています',
          GameErrorType.unknown: '予期しないエラーが発生しました',
        };
        
        for (final entry in testCases.entries) {
          final error = GameError(
            type: entry.key,
            message: 'Test error',
            timestamp: DateTime.now(),
          );
          
          expect(error.userMessage, equals(entry.value));
        }
      });
      
      test('詳細情報Map変換確認', () {
        final now = DateTime.now();
        final error = GameError(
          type: GameErrorType.network,
          message: 'Test message',
          details: 'Test details',
          originalError: 'Original error',
          timestamp: now,
        );
        
        final detailMap = error.toDetailedMap();
        
        expect(detailMap['type'], equals('network'));
        expect(detailMap['message'], equals('Test message'));
        expect(detailMap['details'], equals('Test details'));
        expect(detailMap['userMessage'], equals('ネットワーク接続を確認してください'));
        expect(detailMap['timestamp'], equals(now.toIso8601String()));
        expect(detailMap['originalError'], equals('Original error'));
      });
    });
    
    group('NetworkErrorRecoveryStrategy テスト', () {
      test('基本動作確認', () async {
        final strategy = NetworkErrorRecoveryStrategy(
          maxRetries: 3,
          retryDelay: const Duration(milliseconds: 10),
        );
        
        final networkError = GameError(
          type: GameErrorType.network,
          message: 'Network error',
          timestamp: DateTime.now(),
        );
        
        final otherError = GameError(
          type: GameErrorType.audioPlayback,
          message: 'Audio error',
          timestamp: DateTime.now(),
        );
        
        // ネットワークエラーは処理可能
        expect(strategy.canHandle(networkError), isTrue);
        // 他のエラータイプは処理不可
        expect(strategy.canHandle(otherError), isFalse);
      });
      
      test('リトライ回数制限確認', () async {
        final strategy = NetworkErrorRecoveryStrategy(
          maxRetries: 2,
          retryDelay: const Duration(milliseconds: 1),
        );
        
        final error = GameError(
          type: GameErrorType.network,
          message: 'Network error',
          timestamp: DateTime.now(),
        );
        
        // 1回目: 処理可能
        expect(strategy.canHandle(error), isTrue);
        await strategy.attemptRecovery(error);
        
        // 2回目: まだ処理可能
        expect(strategy.canHandle(error), isTrue);
        await strategy.attemptRecovery(error);
        
        // 3回目: 制限超過
        expect(strategy.canHandle(error), isFalse);
      });
      
      test('リセット機能確認', () async {
        final strategy = NetworkErrorRecoveryStrategy(maxRetries: 1);
        
        final error = GameError(
          type: GameErrorType.network,
          message: 'Network error',
          timestamp: DateTime.now(),
        );
        
        // リトライ使い切る
        await strategy.attemptRecovery(error);
        expect(strategy.canHandle(error), isFalse);
        
        // リセット
        strategy.reset();
        expect(strategy.canHandle(error), isTrue);
      });
    });
    
    group('FlutterGameErrorHandler基本機能テスト', () {
      late FlutterGameErrorHandler handler;
      
      setUp(() {
        handler = FlutterGameErrorHandler(
          maxHistorySize: 10,
          debugMode: true,
        );
        handler.initialize();
      });
      
      tearDown(() {
        handler.dispose();
      });
      
      test('シングルトン動作確認', () {
        final handler1 = FlutterGameErrorHandler();
        final handler2 = FlutterGameErrorHandler();
        
        expect(identical(handler1, handler2), isTrue);
      });
      
      test('初期化確認', () {
        final debugInfo = handler.getDebugInfo();
        
        expect(debugInfo['flutter_official_compliant'], isTrue);
        expect(debugInfo['initialized'], isTrue);
        expect(debugInfo['debug_mode'], isTrue);
        expect(debugInfo['max_history_size'], equals(10));
      });
      
      test('エラー処理基本動作', () async {
        var listenerCalled = false;
        final receivedError = <GameError>[];
        
        handler.addErrorListener((error) {
          listenerCalled = true;
          receivedError.add(error);
        });
        
        final error = GameError(
          type: GameErrorType.network,
          message: 'Test error',
          timestamp: DateTime.now(),
        );
        
        await handler.handleError(error);
        
        expect(listenerCalled, isTrue);
        expect(receivedError.length, equals(1));
        expect(receivedError.first.message, equals('Test error'));
      });
      
      test('エラー履歴管理確認', () async {
        // 履歴サイズ制限テスト
        for (int i = 0; i < 15; i++) {
          await handler.handleError(GameError(
            type: GameErrorType.unknown,
            message: 'Error $i',
            timestamp: DateTime.now(),
          ));
        }
        
        final stats = handler.getErrorStatistics();
        expect(stats['totalErrors'], equals(10)); // maxHistorySize = 10
      });
      
      test('エラーカウント確認', () async {
        await handler.handleError(GameError(
          type: GameErrorType.network,
          message: 'Network error 1',
          timestamp: DateTime.now(),
        ));
        
        await handler.handleError(GameError(
          type: GameErrorType.network,
          message: 'Network error 2',
          timestamp: DateTime.now(),
        ));
        
        await handler.handleError(GameError(
          type: GameErrorType.adLoad,
          message: 'Ad error',
          timestamp: DateTime.now(),
        ));
        
        final stats = handler.getErrorStatistics();
        final counts = stats['errorCounts'] as Map<String, int>;
        
        expect(counts['network'], equals(2));
        expect(counts['adLoad'], equals(1));
      });
    });
    
    group('具体的エラー処理ヘルパーテスト', () {
      late FlutterGameErrorHandler handler;
      
      setUp(() {
        handler = FlutterGameErrorHandler(debugMode: true);
        handler.initialize();
      });
      
      tearDown(() {
        handler.dispose();
      });
      
      test('ネットワーク操作エラー処理', () async {
        // 成功ケース
        final successResult = await handler.handleNetworkOperation<String>(
          () async => 'Success',
          operationName: 'Test operation',
        );
        
        expect(successResult, equals('Success'));
        
        // 失敗ケース
        final failResult = await handler.handleNetworkOperation<String>(
          () async => throw Exception('Network failed'),
          operationName: 'Failed operation',
        );
        
        expect(failResult, isNull);
        
        // エラーが記録されているか確認
        final stats = handler.getErrorStatistics();
        expect(stats['totalErrors'], equals(1));
      });
      
      test('広告操作エラー処理', () async {
        // 成功ケース
        final successResult = await handler.handleAdOperation(
          () async {},
          adType: 'banner',
        );
        
        expect(successResult, isTrue);
        
        // 失敗ケース
        final failResult = await handler.handleAdOperation(
          () async => throw Exception('Ad load failed'),
          adType: 'interstitial',
        );
        
        expect(failResult, isFalse);
        
        // エラーが記録されているか確認
        final stats = handler.getErrorStatistics();
        final counts = stats['errorCounts'] as Map<String, int>;
        expect(counts['adLoad'], equals(1));
      });
      
      test('音声操作エラー処理', () async {
        // 成功ケース
        final successResult = await handler.handleAudioOperation(
          () async {},
          audioType: 'BGM',
        );
        
        expect(successResult, isTrue);
        
        // 失敗ケース
        final failResult = await handler.handleAudioOperation(
          () async => throw Exception('Audio playback failed'),
          audioType: 'SFX',
        );
        
        expect(failResult, isFalse);
        
        // エラーが記録されているか確認
        final stats = handler.getErrorStatistics();
        final counts = stats['errorCounts'] as Map<String, int>;
        expect(counts['audioPlayback'], equals(1));
      });
    });
    
    group('エラータイプ分類テスト', () {
      late FlutterGameErrorHandler handler;
      
      setUp(() {
        handler = FlutterGameErrorHandler(debugMode: true);
        handler.initialize();
      });
      
      tearDown(() {
        handler.dispose();
      });
      
      test('FlutterError分類確認', () {
        // ネットワークエラー判定
        final networkError = FlutterErrorDetails(
          exception: Exception('Network connection failed'),
        );
        
        // 権限エラー判定
        final permissionError = FlutterErrorDetails(
          exception: PlatformException(
            code: 'permission_denied',
            message: 'Permission denied',
          ),
        );
        
        // リソースエラー判定
        final assetError = FlutterErrorDetails(
          exception: Exception('Unable to load asset'),
        );
        
        // FlutterError.onErrorをトリガー
        FlutterError.onError!(networkError);
        FlutterError.onError!(permissionError);
        FlutterError.onError!(assetError);
        
        final stats = handler.getErrorStatistics();
        final counts = stats['errorCounts'] as Map<String, int>;
        
        expect(counts['network'], equals(1));
        expect(counts['permission'], equals(1));
        expect(counts['resourceLoad'], equals(1));
      });
    });
    
    group('リカバリー戦略テスト', () {
      test('カスタムリカバリー戦略追加', () async {
        final handler = FlutterGameErrorHandler();
        handler.initialize();
        
        var recoveryAttempted = false;
        
        // カスタムリカバリー戦略
        final customStrategy = _TestRecoveryStrategy(
          onRecover: () {
            recoveryAttempted = true;
          },
        );
        
        handler.addRecoveryStrategy(customStrategy);
        
        await handler.handleError(GameError(
          type: GameErrorType.adLoad,
          message: 'Test error',
          timestamp: DateTime.now(),
        ));
        
        expect(recoveryAttempted, isTrue);
        
        handler.dispose();
      });
    });
    
    group('エラー統計・管理テスト', () {
      late FlutterGameErrorHandler handler;
      
      setUp(() {
        handler = FlutterGameErrorHandler();
        handler.initialize();
      });
      
      tearDown(() {
        handler.dispose();
      });
      
      test('エラー履歴クリア確認', () async {
        // エラー追加
        await handler.handleError(GameError(
          type: GameErrorType.network,
          message: 'Error 1',
          timestamp: DateTime.now(),
        ));
        
        var stats = handler.getErrorStatistics();
        expect(stats['totalErrors'], equals(1));
        
        // クリア
        handler.clearErrorHistory();
        
        stats = handler.getErrorStatistics();
        expect(stats['totalErrors'], equals(0));
        expect((stats['errorCounts'] as Map).isEmpty, isTrue);
      });
      
      test('最近のエラー取得確認', () async {
        // 複数エラー追加
        for (int i = 0; i < 5; i++) {
          await handler.handleError(GameError(
            type: GameErrorType.unknown,
            message: 'Error $i',
            timestamp: DateTime.now(),
          ));
        }
        
        final stats = handler.getErrorStatistics();
        final recentErrors = stats['recentErrors'] as List;
        
        expect(recentErrors.length, equals(5));
        expect(recentErrors.first['message'], equals('Error 4')); // 最新が先頭
      });
    });
    
    group('後方互換性確認', () {
      test('ErrorHandlerエイリアス動作確認', () {
        // typedef ErrorHandler = FlutterGameErrorHandler
        final handler = ErrorHandler();
        
        expect(handler, isA<FlutterGameErrorHandler>());
        
        handler.initialize();
        final debugInfo = handler.getDebugInfo();
        expect(debugInfo['flutter_official_compliant'], isTrue);
        
        handler.dispose();
      });
    });
    
    group('Flutter公式準拠性確認', () {
      test('FlutterError統合確認', () {
        final handler = FlutterGameErrorHandler();
        handler.initialize();
        
        // FlutterError.onErrorが設定されているか確認
        expect(FlutterError.onError, isNotNull);
        
        // dispose後はデフォルトに戻る
        handler.dispose();
        expect(FlutterError.onError, equals(FlutterError.presentError));
      });
      
      test('公式準拠マーカー確認', () {
        final handler = FlutterGameErrorHandler();
        handler.initialize();
        
        final debugInfo = handler.getDebugInfo();
        expect(debugInfo['flutter_official_compliant'], isTrue);
        
        handler.dispose();
      });
    });
  });
}

/// テスト用リカバリー戦略
class _TestRecoveryStrategy implements ErrorRecoveryStrategy {
  final VoidCallback onRecover;
  
  _TestRecoveryStrategy({required this.onRecover});
  
  @override
  bool canHandle(GameError error) {
    return error.type == GameErrorType.adLoad;
  }
  
  @override
  Future<bool> attemptRecovery(GameError error) async {
    onRecover();
    return true;
  }
}