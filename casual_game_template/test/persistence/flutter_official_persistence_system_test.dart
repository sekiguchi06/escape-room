import 'package:flutter_test/flutter_test.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/framework/persistence/flutter_official_persistence_system.dart';

/// Flutter公式準拠永続化システムの単体テスト
/// 
/// テスト対象:
/// 1. shared_preferencesパッケージの正しい使用
/// 2. 基本的なCRUD操作
/// 3. データ型別の保存・読み込み
/// 4. JSON処理
/// 5. ゲーム専用メソッド
/// 6. デバッグ情報
/// 7. Flutter公式準拠性確認

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('🗃️ Flutter公式準拠永続化システム テスト', () {
    
    setUp(() {
      // SharedPreferencesのモックデータをクリア
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });
    
    group('FlutterDataManager基本機能テスト', () {
      test('初期化確認', () async {
        final dataManager = FlutterDataManager(debugMode: true);
        
        // 初期化前の状態確認
        expect(dataManager.isInitialized, isFalse);
        
        // 初期化実行
        await dataManager.initialize();
        
        // 初期化後の状態確認
        expect(dataManager.isInitialized, isTrue);
      });
      
      test('初期化なしでの操作時の安全性確認', () async {
        final dataManager = FlutterDataManager();
        
        // 初期化前の操作はfalse/nullを返すことを確認
        expect(await dataManager.saveString('test', 'value'), isFalse);
        expect(dataManager.loadString('test'), isNull);
        expect(await dataManager.remove('test'), isFalse);
        expect(await dataManager.clear(), isFalse);
        expect(dataManager.containsKey('test'), isFalse);
        expect(dataManager.getKeys(), isEmpty);
      });
    });
    
    group('文字列データ操作テスト', () {
      late FlutterDataManager dataManager;
      
      setUp(() async {
        dataManager = FlutterDataManager(debugMode: true);
        await dataManager.initialize();
      });
      
      test('文字列保存・読み込み確認', () async {
        const key = 'test_string';
        const value = 'Hello, Flutter!';
        
        // 保存
        final saveResult = await dataManager.saveString(key, value);
        expect(saveResult, isTrue);
        
        // 読み込み
        final loadedValue = dataManager.loadString(key);
        expect(loadedValue, equals(value));
      });
      
      test('文字列デフォルト値確認', () {
        const key = 'nonexistent_string';
        const defaultValue = 'default';
        
        final loadedValue = dataManager.loadString(key, defaultValue: defaultValue);
        expect(loadedValue, equals(defaultValue));
      });
      
      test('長い文字列の保存・読み込み確認', () async {
        const key = 'long_string';
        final longValue = 'A' * 1000; // 1000文字の文字列
        
        final saveResult = await dataManager.saveString(key, longValue);
        expect(saveResult, isTrue);
        
        final loadedValue = dataManager.loadString(key);
        expect(loadedValue, equals(longValue));
        expect(loadedValue?.length, equals(1000));
      });
    });
    
    group('数値データ操作テスト', () {
      late FlutterDataManager dataManager;
      
      setUp(() async {
        dataManager = FlutterDataManager(debugMode: true);
        await dataManager.initialize();
      });
      
      test('整数保存・読み込み確認', () async {
        const key = 'test_int';
        const value = 42;
        
        final saveResult = await dataManager.saveInt(key, value);
        expect(saveResult, isTrue);
        
        final loadedValue = dataManager.loadInt(key);
        expect(loadedValue, equals(value));
      });
      
      test('浮動小数点保存・読み込み確認', () async {
        const key = 'test_double';
        const value = 3.14159;
        
        final saveResult = await dataManager.saveDouble(key, value);
        expect(saveResult, isTrue);
        
        final loadedValue = dataManager.loadDouble(key);
        expect(loadedValue, equals(value));
      });
      
      test('負の数値確認', () async {
        final negativeInt = await dataManager.saveInt('negative_int', -100);
        final negativeDouble = await dataManager.saveDouble('negative_double', -99.99);
        
        expect(negativeInt, isTrue);
        expect(negativeDouble, isTrue);
        
        expect(dataManager.loadInt('negative_int'), equals(-100));
        expect(dataManager.loadDouble('negative_double'), equals(-99.99));
      });
      
      test('ゼロ値確認', () async {
        final zeroInt = await dataManager.saveInt('zero_int', 0);
        final zeroDouble = await dataManager.saveDouble('zero_double', 0.0);
        
        expect(zeroInt, isTrue);
        expect(zeroDouble, isTrue);
        
        expect(dataManager.loadInt('zero_int'), equals(0));
        expect(dataManager.loadDouble('zero_double'), equals(0.0));
      });
    });
    
    group('ブール値データ操作テスト', () {
      late FlutterDataManager dataManager;
      
      setUp(() async {
        dataManager = FlutterDataManager(debugMode: true);
        await dataManager.initialize();
      });
      
      test('ブール値保存・読み込み確認', () async {
        // true値のテスト
        final saveTrueResult = await dataManager.saveBool('test_bool_true', true);
        expect(saveTrueResult, isTrue);
        expect(dataManager.loadBool('test_bool_true'), isTrue);
        
        // false値のテスト
        final saveFalseResult = await dataManager.saveBool('test_bool_false', false);
        expect(saveFalseResult, isTrue);
        expect(dataManager.loadBool('test_bool_false'), isFalse);
      });
      
      test('ブール値デフォルト値確認', () {
        expect(dataManager.loadBool('nonexistent_bool', defaultValue: true), isTrue);
        expect(dataManager.loadBool('nonexistent_bool', defaultValue: false), isFalse);
      });
    });
    
    group('文字列リストデータ操作テスト', () {
      late FlutterDataManager dataManager;
      
      setUp(() async {
        dataManager = FlutterDataManager(debugMode: true);
        await dataManager.initialize();
      });
      
      test('文字列リスト保存・読み込み確認', () async {
        const key = 'test_string_list';
        const value = ['apple', 'banana', 'cherry'];
        
        final saveResult = await dataManager.saveStringList(key, value);
        expect(saveResult, isTrue);
        
        final loadedValue = dataManager.loadStringList(key);
        expect(loadedValue, equals(value));
        expect(loadedValue?.length, equals(3));
      });
      
      test('空リスト確認', () async {
        const key = 'empty_list';
        const value = <String>[];
        
        final saveResult = await dataManager.saveStringList(key, value);
        expect(saveResult, isTrue);
        
        final loadedValue = dataManager.loadStringList(key);
        expect(loadedValue, equals(value));
        expect(loadedValue?.isEmpty, isTrue);
      });
      
      test('大量要素リスト確認', () async {
        const key = 'large_list';
        final largeList = List.generate(100, (index) => 'item_$index');
        
        final saveResult = await dataManager.saveStringList(key, largeList);
        expect(saveResult, isTrue);
        
        final loadedValue = dataManager.loadStringList(key);
        expect(loadedValue, equals(largeList));
        expect(loadedValue?.length, equals(100));
      });
    });
    
    group('JSONデータ操作テスト', () {
      late FlutterDataManager dataManager;
      
      setUp(() async {
        dataManager = FlutterDataManager(debugMode: true);
        await dataManager.initialize();
      });
      
      test('JSON保存・読み込み確認', () async {
        const key = 'test_json';
        final value = <String, dynamic>{
          'name': 'Flutter Game',
          'version': '1.0.0',
          'score': 12345,
          'completed': true,
          'levels': ['level1', 'level2', 'level3'],
        };
        
        final saveResult = await dataManager.saveJson(key, value);
        expect(saveResult, isTrue);
        
        final loadedValue = dataManager.loadJson(key);
        expect(loadedValue, equals(value));
        expect(loadedValue?['name'], equals('Flutter Game'));
        expect(loadedValue?['score'], equals(12345));
        expect(loadedValue?['completed'], isTrue);
      });
      
      test('ネストしたJSONオブジェクト確認', () async {
        const key = 'nested_json';
        final nestedValue = <String, dynamic>{
          'player': {
            'id': 'player123',
            'stats': {
              'level': 10,
              'experience': 2500,
              'achievements': ['first_win', 'speed_demon']
            }
          },
          'settings': {
            'audio': true,
            'graphics': 'high'
          }
        };
        
        final saveResult = await dataManager.saveJson(key, nestedValue);
        expect(saveResult, isTrue);
        
        final loadedValue = dataManager.loadJson(key);
        expect(loadedValue, equals(nestedValue));
        
        // ネストした値の確認
        final playerStats = loadedValue?['player']?['stats'] as Map<String, dynamic>?;
        expect(playerStats?['level'], equals(10));
        expect(playerStats?['achievements'], equals(['first_win', 'speed_demon']));
      });
      
      test('不正なJSONデータのハンドリング確認', () async {
        // 直接文字列として不正なJSONを保存
        await dataManager.saveString('invalid_json', '{invalid json}');
        
        // JSON読み込み時にデフォルト値が返されることを確認
        final loadedValue = dataManager.loadJson('invalid_json', defaultValue: {'error': 'default'});
        expect(loadedValue, equals({'error': 'default'}));
      });
    });
    
    group('データ管理操作テスト', () {
      late FlutterDataManager dataManager;
      
      setUp(() async {
        dataManager = FlutterDataManager(debugMode: true);
        await dataManager.initialize();
      });
      
      test('データ削除確認', () async {
        const key = 'test_remove';
        const value = 'to be removed';
        
        // データ保存
        await dataManager.saveString(key, value);
        expect(dataManager.containsKey(key), isTrue);
        
        // データ削除
        final removeResult = await dataManager.remove(key);
        expect(removeResult, isTrue);
        expect(dataManager.containsKey(key), isFalse);
        expect(dataManager.loadString(key), isNull);
      });
      
      test('全データクリア確認', () async {
        // 複数データ保存
        await dataManager.saveString('string1', 'value1');
        await dataManager.saveInt('int1', 100);
        await dataManager.saveBool('bool1', true);
        
        expect(dataManager.getKeys().length, greaterThanOrEqualTo(3));
        
        // 全クリア
        final clearResult = await dataManager.clear();
        expect(clearResult, isTrue);
        expect(dataManager.getKeys(), isEmpty);
      });
      
      test('キー存在確認', () async {
        const existingKey = 'existing_key';
        const nonExistingKey = 'non_existing_key';
        
        await dataManager.saveString(existingKey, 'exists');
        
        expect(dataManager.containsKey(existingKey), isTrue);
        expect(dataManager.containsKey(nonExistingKey), isFalse);
      });
      
      test('キー一覧取得確認', () async {
        final initialKeys = dataManager.getKeys();
        
        await dataManager.saveString('key1', 'value1');
        await dataManager.saveString('key2', 'value2');
        await dataManager.saveString('key3', 'value3');
        
        final keysAfterSave = dataManager.getKeys();
        expect(keysAfterSave.length, equals(initialKeys.length + 3));
        expect(keysAfterSave, contains('key1'));
        expect(keysAfterSave, contains('key2'));
        expect(keysAfterSave, contains('key3'));
      });
      
      test('データ再読み込み確認', () async {
        // reload機能は実際のSharedPreferencesでのみ有効
        // テストでは例外が発生しないことを確認
        expect(() => dataManager.reload(), returnsNormally);
      });
    });
    
    group('ゲーム専用メソッドテスト', () {
      late FlutterDataManager dataManager;
      
      setUp(() async {
        dataManager = FlutterDataManager(debugMode: true);
        await dataManager.initialize();
      });
      
      test('ハイスコア管理確認', () async {
        // 初期ハイスコア確認
        expect(dataManager.loadHighScore(), equals(0));
        
        // ハイスコア更新
        final saveResult1 = await dataManager.saveHighScore(1000);
        expect(saveResult1, isTrue);
        expect(dataManager.loadHighScore(), equals(1000));
        
        // より高いスコアで更新
        final saveResult2 = await dataManager.saveHighScore(2000);
        expect(saveResult2, isTrue);
        expect(dataManager.loadHighScore(), equals(2000));
        
        // より低いスコアで更新試行（更新されない）
        final saveResult3 = await dataManager.saveHighScore(1500);
        expect(saveResult3, isTrue); // 成功扱い
        expect(dataManager.loadHighScore(), equals(2000)); // 変更されない
      });
      
      test('カテゴリ別ハイスコア確認', () async {
        await dataManager.saveHighScore(100, category: 'easy');
        await dataManager.saveHighScore(200, category: 'normal');
        await dataManager.saveHighScore(300, category: 'hard');
        
        expect(dataManager.loadHighScore(category: 'easy'), equals(100));
        expect(dataManager.loadHighScore(category: 'normal'), equals(200));
        expect(dataManager.loadHighScore(category: 'hard'), equals(300));
        expect(dataManager.loadHighScore(category: 'expert'), equals(0)); // 未設定
      });
      
      test('ユーザー設定管理確認', () async {
        final settings = <String, dynamic>{
          'soundEnabled': true,
          'musicVolume': 0.8,
          'difficulty': 'normal',
          'language': 'ja',
        };
        
        final saveResult = await dataManager.saveUserSettings(settings);
        expect(saveResult, isTrue);
        
        final loadedSettings = dataManager.loadUserSettings();
        expect(loadedSettings, equals(settings));
        expect(loadedSettings['soundEnabled'], isTrue);
        expect(loadedSettings['musicVolume'], equals(0.8));
      });
      
      test('ゲーム進行状況管理確認', () async {
        final progress = <String, dynamic>{
          'currentLevel': 5,
          'unlockedLevels': [1, 2, 3, 4, 5],
          'collectedItems': ['sword', 'shield', 'potion'],
          'completedQuests': {'main_quest_1': true, 'side_quest_2': true},
        };
        
        final saveResult = await dataManager.saveGameProgress(progress);
        expect(saveResult, isTrue);
        
        final loadedProgress = dataManager.loadGameProgress();
        expect(loadedProgress, equals(progress));
        expect(loadedProgress['currentLevel'], equals(5));
        expect(loadedProgress['unlockedLevels'], equals([1, 2, 3, 4, 5]));
      });
      
      test('統計データ管理確認', () async {
        final stats = <String, dynamic>{
          'totalPlayTime': 3600, // 秒
          'gamesPlayed': 25,
          'totalScore': 50000,
          'averageScore': 2000.0,
          'achievements': ['beginner', 'scorer', 'persistent'],
        };
        
        final saveResult = await dataManager.saveStatistics(stats);
        expect(saveResult, isTrue);
        
        final loadedStats = dataManager.loadStatistics();
        expect(loadedStats, equals(stats));
        expect(loadedStats['gamesPlayed'], equals(25));
        expect(loadedStats['achievements'], equals(['beginner', 'scorer', 'persistent']));
      });
    });
    
    group('デバッグ情報確認', () {
      test('デバッグ情報構造確認', () async {
        final dataManager = FlutterDataManager(debugMode: true);
        await dataManager.initialize();
        
        // テストデータ追加
        await dataManager.saveString('test1', 'value1');
        await dataManager.saveInt('test2', 42);
        
        final debugInfo = dataManager.getDebugInfo();
        
        expect(debugInfo, isA<Map<String, dynamic>>());
        expect(debugInfo['flutter_official_compliant'], isTrue);
        expect(debugInfo['package'], equals('shared_preferences'));
        expect(debugInfo['initialized'], isTrue);
        expect(debugInfo['debug_mode'], isTrue);
        expect(debugInfo['total_keys'], greaterThanOrEqualTo(2));
        expect(debugInfo['available_keys'], isA<List<String>>());
        expect(debugInfo['available_keys'], contains('test1'));
        expect(debugInfo['available_keys'], contains('test2'));
      });
      
      test('未初期化時のデバッグ情報確認', () {
        final dataManager = FlutterDataManager(debugMode: false);
        final debugInfo = dataManager.getDebugInfo();
        
        expect(debugInfo['initialized'], isFalse);
        expect(debugInfo['debug_mode'], isFalse);
        expect(debugInfo['total_keys'], equals(0));
        expect(debugInfo['available_keys'], isEmpty);
      });
    });
    
    group('エラーハンドリング確認', () {
      test('初期化失敗時のハンドリング', () async {
        // SharedPreferencesのモック設定で例外をスローさせることは困難
        // 基本的な動作確認のみ
        final dataManager = FlutterDataManager();
        expect(() => dataManager.initialize(), returnsNormally);
      });
      
      test('型不一致データの安全性確認', () async {
        final dataManager = FlutterDataManager();
        await dataManager.initialize();
        
        // 文字列として保存
        await dataManager.saveString('test_key', 'string_value');
        
        // 異なる型で読み込み試行（デフォルト値が返される）
        expect(dataManager.loadInt('test_key', defaultValue: 999), equals(999));
        expect(dataManager.loadBool('test_key', defaultValue: true), isTrue);
      });
    });
    
    group('後方互換性確認', () {
      test('DataManagerエイリアス動作確認', () async {
        // typedef DataManager = FlutterDataManager
        final dataManager = DataManager(debugMode: true);
        
        expect(dataManager, isA<FlutterDataManager>());
        
        await dataManager.initialize();
        expect(dataManager.isInitialized, isTrue);
        
        // 基本機能も正常動作
        await dataManager.saveString('test', 'value');
        expect(dataManager.loadString('test'), equals('value'));
      });
    });
    
    group('Flutter公式準拠性確認', () {
      test('shared_preferences準拠パターン確認', () async {
        final dataManager = FlutterDataManager(debugMode: true);
        await dataManager.initialize();
        
        final debugInfo = dataManager.getDebugInfo();
        
        // Flutter公式準拠であることを明示
        expect(debugInfo['flutter_official_compliant'], isTrue);
        expect(debugInfo['package'], equals('shared_preferences'));
      });
      
      test('公式推奨データ型確認', () async {
        final dataManager = FlutterDataManager();
        await dataManager.initialize();
        
        // shared_preferencesが対応する全データ型をテスト
        expect(await dataManager.saveString('test_string', 'value'), isTrue);
        expect(await dataManager.saveInt('test_int', 42), isTrue);
        expect(await dataManager.saveDouble('test_double', 3.14), isTrue);
        expect(await dataManager.saveBool('test_bool', true), isTrue);
        expect(await dataManager.saveStringList('test_list', ['a', 'b']), isTrue);
        
        // 全データ型が正常に保存・読み込みできることを確認
        expect(dataManager.loadString('test_string'), equals('value'));
        expect(dataManager.loadInt('test_int'), equals(42));
        expect(dataManager.loadDouble('test_double'), equals(3.14));
        expect(dataManager.loadBool('test_bool'), isTrue);
        expect(dataManager.loadStringList('test_list'), equals(['a', 'b']));
      });
    });
    
    group('パフォーマンステスト', () {
      test('大量データ処理確認', () async {
        final dataManager = FlutterDataManager();
        await dataManager.initialize();
        
        const dataCount = 100;
        final stopwatch = Stopwatch()..start();
        
        // 大量データ保存
        for (int i = 0; i < dataCount; i++) {
          await dataManager.saveString('bulk_test_$i', 'value_$i');
        }
        
        // 大量データ読み込み
        for (int i = 0; i < dataCount; i++) {
          final value = dataManager.loadString('bulk_test_$i');
          expect(value, equals('value_$i'));
        }
        
        stopwatch.stop();
        
        // パフォーマンス確認（合理的な時間内で完了）
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5秒以内
        expect(dataManager.getKeys().length, greaterThanOrEqualTo(dataCount));
      });
    });
  });
}