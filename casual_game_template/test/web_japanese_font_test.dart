import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Web環境での日本語フォント表示テスト
/// 様々な設定パターンをテストして最適解を特定する
void main() {
  group('Web日本語フォント表示パターンテスト', () {
    
    test('パターン1: fontFamily指定なし（Flutterデフォルト）', () {
      final textPaint = TextPaint(
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      );
      
      final component = TextComponent(
        text: '鍵',
        textRenderer: textPaint,
      );
      
      expect(component.text, equals('鍵'));
      print('✅ パターン1 - フォント指定なし: "${component.text}"');
      print('   スタイル: ${textPaint.style}');
    });
    
    test('パターン2: fontFamilyFallbackのみ指定', () {
      final textPaint = TextPaint(
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontFamilyFallback: [
            'Noto Sans JP',
            'Hiragino Sans',
            'Yu Gothic',
            'Meiryo',
            'sans-serif',
          ],
        ),
      );
      
      final component = TextComponent(
        text: 'インベントリ',
        textRenderer: textPaint,
      );
      
      expect(component.text, equals('インベントリ'));
      print('✅ パターン2 - fontFamilyFallbackのみ: "${component.text}"');
      print('   フォールバック: ${textPaint.style.fontFamilyFallback}');
    });
    
    test('パターン3: fontFamily + fontFamilyFallback', () {
      final textPaint = TextPaint(
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontFamily: 'Noto Sans JP',
          fontFamilyFallback: [
            'Hiragino Sans',
            'Yu Gothic',
            'Meiryo',
            'sans-serif',
          ],
        ),
      );
      
      final component = TextComponent(
        text: 'ドライバー',
        textRenderer: textPaint,
      );
      
      expect(component.text, equals('ドライバー'));
      print('✅ パターン3 - fontFamily + fontFamilyFallback: "${component.text}"');
      print('   プライマリ: ${textPaint.style.fontFamily}');
      print('   フォールバック: ${textPaint.style.fontFamilyFallback}');
    });
    
    test('パターン4: システムフォント指定', () {
      final textPaint = TextPaint(
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontFamily: 'system-ui',
          fontFamilyFallback: [
            '-apple-system',
            'BlinkMacSystemFont',
            'Hiragino Sans',
            'Yu Gothic',
            'sans-serif',
          ],
        ),
      );
      
      final component = TextComponent(
        text: 'メモ',
        textRenderer: textPaint,
      );
      
      expect(component.text, equals('メモ'));
      print('✅ パターン4 - システムフォント: "${component.text}"');
      print('   システムフォント: ${textPaint.style.fontFamily}');
    });
    
    test('パターン5: Web専用フォント設定', () {
      final textPaint = TextPaint(
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontFamilyFallback: [
            'system-ui',
            '-apple-system',
            'BlinkMacSystemFont',
            'Segoe UI',
            'Roboto',
            'Helvetica Neue',
            'Arial',
            'Noto Sans',
            'sans-serif',
            'Hiragino Sans',
            'Hiragino Kaku Gothic ProN',
            'Yu Gothic',
            'Meiryo',
            'MS PGothic',
          ],
        ),
      );
      
      final component = TextComponent(
        text: '本',
        textRenderer: textPaint,
      );
      
      expect(component.text, equals('本'));
      print('✅ パターン5 - Web専用フォント設定: "${component.text}"');
      print('   全フォールバック: ${textPaint.style.fontFamilyFallback}');
    });
    
    test('パターン6: 最小設定（inherit: false）', () {
      final textPaint = TextPaint(
        style: const TextStyle(
          inherit: false,
          fontSize: 16,
          color: Colors.white,
        ),
      );
      
      final component = TextComponent(
        text: '箱',
        textRenderer: textPaint,
      );
      
      expect(component.text, equals('箱'));
      print('✅ パターン6 - 最小設定 inherit:false: "${component.text}"');
      print('   inherit: ${textPaint.style.inherit}');
    });
    
    test('パターン7: Unicode明示 + フォールバック', () {
      final unicodeText = String.fromCharCodes([37749, 12489, 12521, 12452, 12496, 12540, 12513, 12514]); // 鍵ドライバーメモ
      
      final textPaint = TextPaint(
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontFamilyFallback: [
            'Noto Sans CJK JP',
            'Hiragino Sans',
            'Yu Gothic',
            'Meiryo',
            'sans-serif',
          ],
        ),
      );
      
      final component = TextComponent(
        text: unicodeText,
        textRenderer: textPaint,
      );
      
      expect(component.text, equals(unicodeText));
      print('✅ パターン7 - Unicode明示 + フォールバック: "${component.text}"');
      print('   Unicode長: ${unicodeText.length}, Runes: ${unicodeText.runes.toList()}');
    });
  });
}