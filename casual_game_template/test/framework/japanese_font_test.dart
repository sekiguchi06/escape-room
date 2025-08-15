import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../lib/framework/ui/japanese_message_system.dart';

void main() {
  group('日本語文字化け問題テスト', () {
    
    test('Unicode明示文字列の正確性テスト', () {
      // Unicode配列から文字列生成テスト
      final keyUnicode = String.fromCharCodes([37749]); // '鍵'
      final toolUnicode = String.fromCharCodes([12489, 12521, 12452, 12496, 12540]); // 'ドライバー'
      final memoUnicode = String.fromCharCodes([12513, 12514]); // 'メモ'
      
      // 期待値との比較
      expect(keyUnicode, equals('鍵'));
      expect(toolUnicode, equals('ドライバー')); 
      expect(memoUnicode, equals('メモ'));
      
      print('✅ Unicode生成文字列: $keyUnicode, $toolUnicode, $memoUnicode');
    });
    
    test('JapaneseMessageSystemメッセージ取得テスト', () {
      // メッセージ取得テスト
      final gameStart = JapaneseMessageSystem.getMessage('game_start');
      final inventoryTitle = JapaneseMessageSystem.getMessage('inventory_title');
      final itemKey = JapaneseMessageSystem.getMessage('item_key');
      
      // 文字化けしていないかチェック
      expect(gameStart, isNotEmpty);
      expect(inventoryTitle, isNotEmpty);
      expect(itemKey, isNotEmpty);
      
      print('✅ メッセージ取得結果:');
      print('  game_start: $gameStart');
      print('  inventory_title: $inventoryTitle'); 
      print('  item_key: $itemKey');
      
      // 文字化け確認（期待値比較）
      expect(gameStart, equals('ゲーム開始'));
      expect(inventoryTitle, equals('インベントリ'));
      expect(itemKey, equals('鍵'));
    });
    
    test('Flutter TextStyleとFlame TextPaint比較テスト', () {
      // Flutter TextStyle
      final flutterStyle = TextStyle(
        fontFamily: 'Noto Sans JP',
        fontSize: 16,
        color: Colors.black,
      );
      
      // Flame TextPaint
      final flameTextPaint = JapaneseFontSystem.getTextPaint(16, Colors.black);
      
      // フォント設定確認
      expect(flutterStyle.fontFamily, equals('Noto Sans JP'));
      expect(flameTextPaint.style.fontFamily, equals('Noto Sans JP'));
      expect(flameTextPaint.style.fontFamilyFallback, isNotNull);
      expect(flameTextPaint.style.fontFamilyFallback!.length, greaterThan(0));
      
      print('✅ フォント設定比較:');
      print('  Flutter: ${flutterStyle.fontFamily}');
      print('  Flame: ${flameTextPaint.style.fontFamily}');
      print('  Fallback: ${flameTextPaint.style.fontFamilyFallback}');
    });
    
    test('文字エンコーディング直接テスト', () {
      // 異なる文字指定方法での比較
      final directString = '鍵'; // 直接文字列
      final unicodeString = String.fromCharCodes([37749]); // Unicode
      final escapeString = '\u9375'; // エスケープシーケンス
      
      print('✅ 文字エンコーディング比較:');
      print('  直接文字列: "$directString" (${directString.codeUnits})');
      print('  Unicode配列: "$unicodeString" (${unicodeString.codeUnits})');
      print('  エスケープ: "$escapeString" (${escapeString.codeUnits})');
      
      // 全て同じ文字であることを確認
      expect(directString, equals(unicodeString));
      expect(unicodeString, equals(escapeString));
      expect(directString.codeUnits, equals(unicodeString.codeUnits));
    });
    
    test('Flame TextComponent生成テスト', () {
      // TextComponent生成テスト
      final testText = '鍵';
      final textPaint = JapaneseFontSystem.getTextPaint(16, Colors.white);
      
      final textComponent = TextComponent(
        text: testText,
        textRenderer: textPaint,
        position: Vector2(10, 10),
      );
      
      // コンポーネント生成確認
      expect(textComponent.text, equals(testText));
      expect(textComponent.textRenderer, equals(textPaint));
      expect(textComponent.position, equals(Vector2(10, 10)));
      
      print('✅ TextComponent生成成功:');
      print('  text: "${textComponent.text}"');
      print('  position: ${textComponent.position}');
    });
    
    test('WebFont読み込み状態シミュレーション', () {
      // フォント読み込み失敗時のフォールバック動作テスト
      final textPaint = TextPaint(
        style: TextStyle(
          fontFamily: 'NonExistentFont', // 存在しないフォント
          fontFamilyFallback: ['Noto Sans JP', 'sans-serif'],
          fontSize: 16,
          color: Colors.black,
        ),
      );
      
      expect(textPaint.style.fontFamily, equals('NonExistentFont'));
      expect(textPaint.style.fontFamilyFallback, contains('Noto Sans JP'));
      expect(textPaint.style.fontFamilyFallback, contains('sans-serif'));
      
      print('✅ フォールバック設定確認:');
      print('  Primary: ${textPaint.style.fontFamily}');
      print('  Fallback: ${textPaint.style.fontFamilyFallback}');
    });
    
    test('文字列長・バイト数確認テスト', () {
      final testStrings = [
        '鍵',
        'ドライバー', 
        'メモ',
        'インベントリ',
        'ゲーム開始',
      ];
      
      print('✅ 文字列詳細情報:');
      for (final str in testStrings) {
        final codeUnits = str.codeUnits;
        final runes = str.runes.toList();
        
        print('  "$str":');
        print('    文字数: ${str.length}');
        print('    CodeUnits: $codeUnits');
        print('    Runes: $runes');
        print('    UTF-16: ${codeUnits.map((u) => '0x${u.toRadixString(16)}').join(', ')}');
        
        expect(str.length, greaterThan(0));
        expect(codeUnits.length, greaterThan(0));
      }
    });
  });
}