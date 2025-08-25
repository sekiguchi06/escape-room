import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:escape_room/framework/ui/japanese_message_system.dart';

void main() {
  group('Flame日本語テキスト描画デバッグ', () {
    test('基本的なTextComponent作成テスト', () {
      // 最もシンプルなTextComponent
      final simpleText = TextComponent(text: '鍵', position: Vector2(10, 10));

      expect(simpleText.text, equals('鍵'));
      expect(simpleText.position, equals(Vector2(10, 10)));
      debugPrint('✅ Simple TextComponent created: "${simpleText.text}"');
    });

    test('TextPaintなしでの日本語表示テスト', () {
      // TextPaintを指定しない場合
      final defaultText = TextComponent(
        text: 'インベントリ',
        position: Vector2(10, 10),
      );

      expect(defaultText.text, equals('インベントリ'));
      debugPrint('✅ Default TextComponent: "${defaultText.text}"');
      debugPrint('✅ Default textRenderer: ${defaultText.textRenderer}');
    });

    test('最小限のTextStyleでのテスト', () {
      // 最小限のTextStyle
      final minimalStyle = TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 16),
      );

      final textWithMinimalStyle = TextComponent(
        text: 'ドライバー',
        textRenderer: minimalStyle,
        position: Vector2(10, 10),
      );

      expect(textWithMinimalStyle.text, equals('ドライバー'));
      debugPrint(
        '✅ Minimal style TextComponent: "${textWithMinimalStyle.text}"',
      );
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
      debugPrint('✅ No font TextComponent: "${textWithNoFont.text}"');
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
      debugPrint('✅ System font TextComponent: "${textWithSystemFont.text}"');
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
        style: const TextStyle(color: Colors.white, fontSize: 16),
      );
      final textWithSimple = TextComponent(
        text: '箱',
        textRenderer: simpleImpl,
        position: Vector2(10, 10),
      );

      debugPrint('✅ Current implementation style: ${currentImpl.style}');
      debugPrint('✅ Simple implementation style: ${simpleImpl.style}');

      expect(textWithCurrent.text, equals(textWithSimple.text));
    });

    test('文字エンコーディング検証', () {
      final testStrings = ['鍵', 'ドライバー', 'メモ', 'インベントリ', '本', '箱'];

      for (final str in testStrings) {
        final component = TextComponent(text: str);

        debugPrint('Text: "$str"');
        debugPrint('  Length: ${str.length}');
        debugPrint('  Runes: ${str.runes.toList()}');
        debugPrint(
          '  UTF-16: ${str.codeUnits.map((c) => '0x${c.toRadixString(16)}').join(' ')}',
        );
        debugPrint('  Component text: "${component.text}"');
        debugPrint('  Matches: ${str == component.text}');
        debugPrint('---');

        expect(component.text, equals(str));
      }
    });
  });
}
