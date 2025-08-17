import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../lib/framework/ui/japanese_message_system.dart';

void main() {
  group('Flame日本語テキスト描画デバッグ', () {
    
    test('基本的なTextComponent作成テスト', () {
      // 最もシンプルなTextComponent
      final simpleText = TextComponent(
        text: '鍵',
        position: Vector2(10, 10),
      );
      
      expect(simpleText.text, equals('鍵'));
      expect(simpleText.position, equals(Vector2(10, 10)));
      print('✅ Simple TextComponent created: "${simpleText.text}"');
    });
    
    test('TextPaintなしでの日本語表示テスト', () {
      // TextPaintを指定しない場合
      final defaultText = TextComponent(
        text: 'インベントリ',
        position: Vector2(10, 10),
      );
      
      expect(defaultText.text, equals('インベントリ'));
      print('✅ Default TextComponent: "${defaultText.text}"');
      print('✅ Default textRenderer: ${defaultText.textRenderer}');
    });
    
    test('最小限のTextStyleでのテスト', () {
      // 最小限のTextStyle
      final minimalStyle = TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      );
      
      final textWithMinimalStyle = TextComponent(
        text: 'ドライバー',
        textRenderer: minimalStyle,
        position: Vector2(10, 10),
      );
      
      expect(textWithMinimalStyle.text, equals('ドライバー'));
      print('✅ Minimal style TextComponent: "${textWithMinimalStyle.text}"');
    });
    
    test('フォント指定なしのTextStyleテスト', () {
      // フォントファミリー指定なし
      final noFontStyle = TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          // fontFamily指定なし
        ),
      );
      
      final textWithNoFont = TextComponent(
        text: 'メモ',
        textRenderer: noFontStyle,
        position: Vector2(10, 10),
      );
      
      expect(textWithNoFont.text, equals('メモ'));
      print('✅ No font TextComponent: "${textWithNoFont.text}"');
    });
    
    test('システムフォント指定テスト', () {
      // システムフォント明示指定
      final systemFontStyle = TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'Roboto', // Flutterデフォルト
        ),
      );
      
      final textWithSystemFont = TextComponent(
        text: '本',
        textRenderer: systemFontStyle,
        position: Vector2(10, 10),
      );
      
      expect(textWithSystemFont.text, equals('本'));
      print('✅ System font TextComponent: "${textWithSystemFont.text}"');
    });
    
    test('JapaneseMessageSystem比較テスト', () {
      // 現在の実装
      final currentImpl = JapaneseFontSystem.getTextPaint(16, Colors.white);
      final textWithCurrent = TextComponent(
        text: '箱',
        textRenderer: currentImpl,
        position: Vector2(10, 10),
      );
      
      // シンプルな実装
      final simpleImpl = TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      );
      final textWithSimple = TextComponent(
        text: '箱',
        textRenderer: simpleImpl,
        position: Vector2(10, 10),
      );
      
      print('✅ Current implementation style: ${currentImpl.style}');
      print('✅ Simple implementation style: ${simpleImpl.style}');
      
      expect(textWithCurrent.text, equals(textWithSimple.text));
    });
    
    test('文字エンコーディング検証', () {
      final testStrings = ['鍵', 'ドライバー', 'メモ', 'インベントリ', '本', '箱'];
      
      for (final str in testStrings) {
        final component = TextComponent(text: str);
        
        print('Text: "$str"');
        print('  Length: ${str.length}');
        print('  Runes: ${str.runes.toList()}');
        print('  UTF-16: ${str.codeUnits.map((c) => '0x${c.toRadixString(16)}').join(' ')}');
        print('  Component text: "${component.text}"');
        print('  Matches: ${str == component.text}');
        print('---');
        
        expect(component.text, equals(str));
      }
    });
  });
}