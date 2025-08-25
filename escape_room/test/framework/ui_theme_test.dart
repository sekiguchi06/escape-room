import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:escape_room/framework/ui/flutter_theme_system.dart';

void main() {
  group('汎用UIテーマシステムテスト', () {
    test('汎用UIテーマシステム - テーマ管理', () {
      debugPrint('🎨 汎用UIテーマシステムテスト開始...');

      final themeManager = FlutterThemeManager();
      themeManager.initializeDefaultThemes();

      // 利用可能なテーマ確認
      final availableThemes = themeManager.getAvailableThemes();
      expect(availableThemes.length, greaterThan(0));
      debugPrint('  📋 利用可能テーマ: ${availableThemes.join(', ')}');

      // デフォルトテーマ確認
      final defaultTheme = themeManager.currentTheme;
      final primaryColor = defaultTheme.getColor('primary');
      final textSize = defaultTheme.getFontSize('medium');

      expect(primaryColor, isNotNull);
      expect(textSize, greaterThan(0));
      debugPrint('  🎯 デフォルトテーマ - プライマリ色: $primaryColor, テキストサイズ: $textSize');

      // テーマ変更
      if (availableThemes.contains('dark')) {
        themeManager.setTheme('dark');
        expect(themeManager.currentThemeId, equals('dark'));
        debugPrint('  🌙 ダークテーマに変更成功');

        final darkPrimaryColor = themeManager.currentTheme.getColor('primary');
        debugPrint('  🎨 ダークテーマプライマリ色: $darkPrimaryColor');
      }

      // カスタムテーマ登録
      final customTheme = FlutterUITheme(
        themeData: ThemeData(primarySwatch: Colors.purple, fontFamily: 'Arial'),
        colors: const {
          'primary': Colors.purple,
          'secondary': Colors.orange,
          'accent': Colors.cyan,
        },
        fontSizes: const {'small': 10.0, 'medium': 14.0, 'large': 18.0},
      );

      themeManager.registerTheme('custom', customTheme);
      themeManager.setTheme('custom');

      expect(themeManager.currentThemeId, equals('custom'));
      expect(
        themeManager.currentTheme.getColor('primary'),
        equals(Colors.purple),
      );
      debugPrint('  🎭 カスタムテーマ登録・適用成功');

      debugPrint('🎉 汎用UIテーマシステムテスト完了！');
    });
  });
}
