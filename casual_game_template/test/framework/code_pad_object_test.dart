import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import '../../lib/framework/escape_room/gameobjects/code_pad_object.dart';
import '../../lib/framework/escape_room/core/interaction_result.dart';

void main() {
  group('CodePadObject Tests', () {
    late CodePadObject codePad;
    
    setUp(() {
      codePad = CodePadObject(
        position: Vector2(100, 100),
        size: Vector2(50, 50),
        correctCode: '1234',
        rewardItemId: 'test_key',
      );
    });
    
    test('should initialize with correct properties', () {
      expect(codePad.objectId, equals('code_pad'));
      expect(codePad.correctCode, equals('1234'));
      expect(codePad.rewardItemId, equals('test_key'));
      expect(codePad.position, equals(Vector2(100, 100)));
      expect(codePad.size, equals(Vector2(50, 50)));
    });
    
    test('should initialize strategy after calling initialize', () async {
      await codePad.initialize();
      expect(codePad.canInteract(), isTrue);
    });
    
    test('should allow interaction initially', () async {
      await codePad.initialize();
      expect(codePad.canInteract(), isTrue);
    });
    
    test('should return interaction result', () async {
      await codePad.initialize();
      
      final result = codePad.performInteraction();
      expect(result.success, isTrue);
      expect(result.message, contains('コードパッドにアクセスしています'));
      expect(result.shouldActivate, isFalse);
    });
    
    test('should use default values when not specified', () {
      final defaultCodePad = CodePadObject(
        position: Vector2.zero(),
        size: Vector2(50, 50),
      );
      
      expect(defaultCodePad.correctCode, equals('2859'));
      expect(defaultCodePad.rewardItemId, equals('puzzle_key'));
    });
    
    test('should load assets without errors', () async {
      await codePad.loadAssets();
      expect(codePad.dualSpriteComponent, isNotNull);
    });
    
    test('should execute onActivated callback', () {
      // onActivated メソッドが呼び出されても例外が発生しないことを確認
      expect(() => codePad.onActivated(), returnsNormally);
    });
  });
  
  group('CodePadPuzzleStrategy Tests', () {
    late CodePadPuzzleStrategy strategy;
    
    setUp(() {
      strategy = CodePadPuzzleStrategy(
        correctCode: '5678',
        successMessage: 'Success!',
        failureMessage: 'Failed!',
        rewardItemId: 'reward',
      );
    });
    
    test('should have correct strategy name', () {
      expect(strategy.strategyName, equals('CodePadPuzzle'));
    });
    
    test('should return correct expected code', () {
      expect(strategy.expectedCode, equals('5678'));
    });
    
    test('should execute initial interaction', () {
      final result = strategy.execute();
      expect(result.success, isTrue);
      expect(result.message, contains('コードパッドにアクセスしています'));
      expect(result.shouldActivate, isFalse);
    });
    
    test('should handle correct code validation', () {
      final result = strategy.validateCode('5678');
      expect(result.success, isTrue);
      expect(result.message, equals('Success!'));
      expect(result.itemsToAdd, contains('reward'));
      expect(result.shouldActivate, isTrue);
    });
    
    test('should handle incorrect code validation', () {
      final result = strategy.validateCode('9999');
      expect(result.success, isFalse);
      expect(result.message, equals('Failed!'));
      expect(result.itemsToAdd, isEmpty);
      expect(result.shouldActivate, isFalse);
    });
    
    test('should not allow interaction after solving', () {
      // 正解を入力して解決状態にする
      strategy.validateCode('5678');
      
      // 再度やり取りを試行
      expect(strategy.canInteract(), isFalse);
      final result = strategy.validateCode('5678');
      expect(result.success, isFalse);
      expect(result.message, contains('既に解決済みです'));
    });
    
    test('should reset state correctly', () {
      // 解決状態にする
      strategy.validateCode('5678');
      expect(strategy.canInteract(), isFalse);
      
      // リセット
      strategy.reset();
      expect(strategy.canInteract(), isTrue);
    });
    
    test('should handle edge cases in code validation', () {
      // 空文字列
      var result = strategy.validateCode('');
      expect(result.success, isFalse);
      
      // スペース付き（現在の実装では完全一致）
      result = strategy.validateCode(' 5678 ');
      expect(result.success, isFalse);
      
      // 文字数不一致
      result = strategy.validateCode('56');
      expect(result.success, isFalse);
      
      result = strategy.validateCode('567890');
      expect(result.success, isFalse);
    });
  });
}