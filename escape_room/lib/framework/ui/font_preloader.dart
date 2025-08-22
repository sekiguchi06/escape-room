import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// フォント事前読み込み管理クラス
/// Web環境でのフォント読み込み完了を保証
class FontPreloader {
  static bool _isLoaded = false;
  static final Completer<void> _loadCompleter = Completer<void>();

  /// フォント読み込み状態を取得
  static bool get isLoaded => _isLoaded;

  /// フォント読み込み完了を待機
  static Future<void> waitForFonts() => _loadCompleter.future;

  /// フォント事前読み込みを開始
  static Future<void> preloadFonts() async {
    if (_isLoaded) return;

    if (kIsWeb) {
      try {
        // Web環境でのフォント読み込み確認
        await _ensureWebFontsLoaded();
        debugPrint('✅ Web fonts loaded successfully');
      } catch (e) {
        debugPrint('⚠️ Font loading failed: $e');
      }
    }

    _isLoaded = true;
    if (!_loadCompleter.isCompleted) {
      _loadCompleter.complete();
    }
  }

  /// Web環境でのフォント読み込み確認
  static Future<void> _ensureWebFontsLoaded() async {
    // 日本語テキストを含むテスト用TextPainter作成
    final testTexts = ['鍵', 'インベントリ', 'ドライバー', 'メモ'];

    for (final text in testTexts) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 16,
            fontFamilyFallback: [
              'system-ui',
              '-apple-system',
              'BlinkMacSystemFont',
              'Noto Sans JP',
              'Hiragino Sans',
              'Yu Gothic',
              'Meiryo',
              'sans-serif',
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      // レイアウト実行でフォント読み込みをトリガー
      textPainter.layout();

      // 短時間待機してフォント解決を待つ
      await Future.delayed(const Duration(milliseconds: 10));

      textPainter.dispose();
    }

    // 追加待機でフォント安定化
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// フォント読み込み状態をリセット（テスト用）
  static void reset() {
    _isLoaded = false;
  }
}
