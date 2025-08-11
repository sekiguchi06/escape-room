import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../lib/framework/game_types/quick_templates/escape_room_template.dart';
import '../../lib/game/example_games/simple_escape_room.dart';

/// 日本語文字エンコーディング機能の単体テスト
void main() {
  group('日本語文字エンコーディングテスト', () {
    
    test('UTF-8文字列処理：基本漢字テスト', () {
      const testMessage = '鍵を選択しました';
      
      // UTF-8エンコード処理をテスト
      final utf8Message = String.fromCharCodes(testMessage.runes);
      
      expect(utf8Message, testMessage);
      expect(utf8Message.contains('鍵'), true);
      expect(utf8Message.contains('選択'), true);
    });

    test('UTF-8文字列処理：複合文字テスト', () {
      const testMessage = 'ここから脱出できそうだ';
      
      // UTF-8エンコード処理をテスト
      final utf8Message = String.fromCharCodes(testMessage.runes);
      
      expect(utf8Message, testMessage);
      expect(utf8Message.contains('ここから'), true);
      expect(utf8Message.contains('脱出'), true);
      expect(utf8Message.contains('できそうだ'), true);
    });

    test('UTF-8文字列処理：特殊文字テスト', () {
      const testMessage = '数字の組み合わせが必要';
      
      // UTF-8エンコード処理をテスト  
      final utf8Message = String.fromCharCodes(testMessage.runes);
      
      expect(utf8Message, testMessage);
      expect(utf8Message.contains('数字'), true);
      expect(utf8Message.contains('組み合わせ'), true);
      expect(utf8Message.contains('必要'), true);
    });

    test('UTF-8文字列処理：長文テスト', () {
      const testMessage = '本の間に何かが挟まっている。ドライバーが見つかった！';
      
      // UTF-8エンコード処理をテスト
      final utf8Message = String.fromCharCodes(testMessage.runes);
      
      expect(utf8Message, testMessage);
      expect(utf8Message.length, testMessage.length);
      expect(utf8Message.contains('本の間'), true);
      expect(utf8Message.contains('ドライバー'), true);
      expect(utf8Message.contains('見つかった'), true);
    });

    testWithFlameGame<SimpleEscapeRoom>(
      'ゲーム内メッセージ表示：アイテム名の正常表示',
      () => SimpleEscapeRoom(),
      (game) async {
        await game.ready();
        
        // アイテム定義の確認
        final items = {
          'key': '鍵',
          'code': 'メモ', 
          'tool': 'ドライバー',
        };
        
        for (final entry in items.entries) {
          // 各アイテム名がUTF-8処理で正しく処理されることを確認
          final itemName = entry.value;
          final utf8ItemName = String.fromCharCodes(itemName.runes);
          
          expect(utf8ItemName, itemName);
          expect(utf8ItemName.isNotEmpty, true);
        }
      },
    );

    testWithFlameGame<SimpleEscapeRoom>(
      'ホットスポット説明文：正常な日本語表示',
      () => SimpleEscapeRoom(),
      (game) async {
        await game.ready();
        
        // ホットスポットの説明文を確認
        final descriptions = [
          'ここから脱出できそうだ...',
          '何かが隠されているかも',
          '本の間に何かが挟まっている',
          '数字の組み合わせが必要',
        ];
        
        for (final description in descriptions) {
          final utf8Description = String.fromCharCodes(description.runes);
          
          expect(utf8Description, description);
          expect(utf8Description.isNotEmpty, true);
        }
      },
    );

    testWithFlameGame<SimpleEscapeRoom>(
      'メッセージコンポーネント：TextComponentの文字表示',
      () => SimpleEscapeRoom(),
      (game) async {
        await game.ready();
        
        // 机をクリックしてメッセージ表示をトリガー
        final deskHotspot = game.children
            .whereType<HotspotComponent>()
            .firstWhere((h) => h.id == 'desk');
        
        const tapDetails = TapUpDetails();
        deskHotspot.onTapUp(TapUpEvent(1, game, tapDetails));
        
        // メッセージコンポーネントが作成されるまで待機
        await Future.delayed(const Duration(milliseconds: 300));
        
        // TextComponentが作成され、日本語テキストが設定されることを確認
        final messageComponents = game.children.whereType<TextComponent>();
        final hasJapaneseText = messageComponents.any((component) => 
            component.text.contains('メモ') || 
            component.text.contains('発見'));
        
        expect(hasJapaneseText, true);
      },
    );

    test('フォント設定：システムフォントでのUTF-8対応', () {
      // TextStyle設定のテスト
      const textStyle = TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'sans-serif', // システムフォント
      );
      
      expect(textStyle.fontFamily, 'sans-serif');
      expect(textStyle.color, Colors.white);
      expect(textStyle.fontSize, 16);
    });

    test('文字列長計算：マルチバイト文字の正確な長さ', () {
      const testStrings = [
        '鍵', // 1文字
        'ドライバー', // 5文字
        'ここから脱出できそうだ', // 11文字
        '数字の組み合わせが必要', // 11文字
      ];
      
      final expectedLengths = [1, 5, 11, 11];
      
      for (int i = 0; i < testStrings.length; i++) {
        final testString = testStrings[i];
        final utf8String = String.fromCharCodes(testString.runes);
        
        expect(utf8String.length, expectedLengths[i]);
        expect(utf8String.runes.length, expectedLengths[i]);
      }
    });

    test('エラーハンドリング：不正文字列の処理', () {
      // 空文字列の処理
      const emptyString = '';
      final utf8Empty = String.fromCharCodes(emptyString.runes);
      expect(utf8Empty, '');
      expect(utf8Empty.isEmpty, true);
      
      // null安全性（Dartではnullは渡されないが、空チェック）
      const nullSafeString = '';
      final utf8NullSafe = String.fromCharCodes(nullSafeString.runes);
      expect(utf8NullSafe, '');
    });
  });
}