import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:casual_game_template/framework/ui/flutter_theme_system.dart';

/// Flutter公式ThemeData準拠テーマシステムの単体テスト
/// 既存インターフェース互換性とFlutter公式準拠実装の確認
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('🎨 Flutter公式ThemeData準拠テーマシステム テスト', () {
    
    group('FlutterUITheme テスト', () {
      test('Material Design Light テーマ作成確認', () {
        final lightTheme = FlutterUITheme.light();
        
        expect(lightTheme, isNotNull);
        expect(lightTheme.getColor('primary'), isNotNull);
        expect(lightTheme.getColor('secondary'), isNotNull);
        expect(lightTheme.getColor('text'), isNotNull);
        expect(lightTheme.getColor('background'), isNotNull);
        expect(lightTheme.getFontSize('medium'), equals(16.0));
        expect(lightTheme.getSpacing('medium'), equals(16.0));
        
        // Flutter公式ThemeDataへの変換確認
        final themeData = lightTheme.toThemeData();
        expect(themeData, isA<ThemeData>());
        expect(themeData.useMaterial3, isTrue);
        expect(themeData.colorScheme.brightness, equals(Brightness.light));
        // Material Design 3準拠確認
      });
      
      test('Material Design Dark テーマ作成確認', () {
        final darkTheme = FlutterUITheme.dark();
        
        expect(darkTheme, isNotNull);
        expect(darkTheme.getColor('primary'), isNotNull);
        expect(darkTheme.getColor('secondary'), isNotNull);
        expect(darkTheme.getColor('text'), isNotNull);
        expect(darkTheme.getColor('background'), isNotNull);
        
        // Flutter公式ThemeDataへの変換確認
        final themeData = darkTheme.toThemeData();
        expect(themeData.colorScheme.brightness, equals(Brightness.dark));
        expect(themeData.useMaterial3, isTrue);
        // Material Design 3準拠確認
      });
      
      test('ゲーム用カスタムテーマ作成確認', () {
        final gameTheme = FlutterUITheme.game();
        
        expect(gameTheme, isNotNull);
        expect(gameTheme.getColor('primary'), equals(Colors.orange));
        expect(gameTheme.getColor('secondary'), equals(Colors.purple));
        expect(gameTheme.getColor('text'), equals(Colors.white));
        expect(gameTheme.getColor('background'), equals(Colors.indigo));
        
        // Flutter公式ThemeDataへの変換確認
        final themeData = gameTheme.toThemeData();
        expect(themeData, isA<ThemeData>());
        expect(themeData.useMaterial3, isTrue);
        // ゲーム用カスタムテーマのMaterial Design準拠
      });
      
      test('カスタムパラメータ付きテーマ作成確認', () {
        final customTheme = FlutterUITheme.light(
          customColors: {
            'custom_color': Colors.pink,
          },
          customFontSizes: {
            'custom_size': 20.0,
          },
          customSpacings: {
            'custom_spacing': 12.0,
          },
        );
        
        expect(customTheme.getColor('custom_color'), equals(Colors.pink));
        expect(customTheme.getFontSize('custom_size'), equals(20.0));
        expect(customTheme.getSpacing('custom_spacing'), equals(12.0));
        
        // デフォルト値も正常に設定されていることを確認
        expect(customTheme.getFontSize('medium'), equals(16.0));
        expect(customTheme.getSpacing('medium'), equals(16.0));
      });
      
      test('存在しないキーでのデフォルト値取得確認', () {
        final theme = FlutterUITheme.light();
        
        // 存在しないキーの場合、ThemeDataからのデフォルト値が返される
        expect(theme.getColor('nonexistent'), isA<Color>());
        expect(theme.getFontSize('nonexistent'), equals(16.0));
        expect(theme.getSpacing('nonexistent'), equals(16.0));
      });
    });
    
    group('FlutterThemeManager テスト', () {
      late FlutterThemeManager manager;
      
      setUp(() {
        manager = FlutterThemeManager();
        manager.initializeDefaultThemes();
      });
      
      test('初期化確認', () {
        expect(manager, isNotNull);
        expect(manager.getAvailableThemes(), isNotEmpty);
        expect(manager.getAvailableThemes(), contains('light'));
        expect(manager.getAvailableThemes(), contains('dark'));
        expect(manager.getAvailableThemes(), contains('game'));
        expect(manager.currentThemeId, equals('light'));
      });
      
      test('Material Design 3準拠デフォルトテーマ確認', () {
        final availableThemes = manager.getAvailableThemes();
        
        expect(availableThemes.length, greaterThanOrEqualTo(3));
        expect(availableThemes, contains('light'));
        expect(availableThemes, contains('dark'));
        expect(availableThemes, contains('game'));
        
        // 各テーマがMaterial Design 3準拠であることを確認
        manager.setTheme('light');
        expect(manager.currentThemeData.useMaterial3, isTrue);
        
        manager.setTheme('dark');
        expect(manager.currentThemeData.useMaterial3, isTrue);
        
        manager.setTheme('game');
        expect(manager.currentThemeData.useMaterial3, isTrue);
      });
      
      test('テーマ変更確認', () {
        // 初期状態を明確に設定
        manager.setTheme('light');
        expect(manager.currentThemeId, equals('light'));
        
        manager.setTheme('dark');
        expect(manager.currentThemeId, equals('dark'));
        expect(manager.currentTheme, isA<UITheme>());
        
        manager.setTheme('game');
        expect(manager.currentThemeId, equals('game'));
        expect(manager.currentTheme, isA<UITheme>());
        
        // Flutter公式ThemeDataが正しく取得できることを確認
        final themeData = manager.currentThemeData;
        expect(themeData, isA<ThemeData>());
        expect(themeData.useMaterial3, isTrue);
      });
      
      test('存在しないテーマ設定時の処理確認', () {
        final originalTheme = manager.currentThemeId;
        
        manager.setTheme('nonexistent_theme');
        
        // 元のテーマが維持されることを確認
        expect(manager.currentThemeId, equals(originalTheme));
      });
      
      test('カスタムテーマ登録・使用確認', () {
        final customTheme = FlutterUITheme.light(
          customColors: {
            'primary': Colors.purple,
            'secondary': Colors.amber,
          },
        );
        
        manager.registerTheme('custom', customTheme);
        
        expect(manager.getAvailableThemes(), contains('custom'));
        
        manager.setTheme('custom');
        expect(manager.currentThemeId, equals('custom'));
        expect(manager.currentTheme.getColor('primary'), equals(Colors.purple));
        expect(manager.currentTheme.getColor('secondary'), equals(Colors.amber));
      });
      
      test('テーマ変更リスナー確認', () {
        var changeCount = 0;
        String? lastChangedTheme;
        
        void listener(String themeId) {
          changeCount++;
          lastChangedTheme = themeId;
        }
        
        manager.addThemeChangeListener(listener);
        
        // テーマ変更
        manager.setTheme('dark');
        expect(changeCount, equals(1));
        expect(lastChangedTheme, equals('dark'));
        
        manager.setTheme('game');
        expect(changeCount, equals(2));
        expect(lastChangedTheme, equals('game'));
        
        // 同じテーマに設定した場合、リスナーは呼ばれない
        manager.setTheme('game');
        expect(changeCount, equals(2));
        
        // リスナー削除
        manager.removeThemeChangeListener(listener);
        
        manager.setTheme('light');
        expect(changeCount, equals(2)); // 変更されない
      });
      
      test('システムテーマモード取得確認', () {
        manager.setTheme('light');
        expect(manager.getSystemThemeMode(), equals(ThemeMode.light));
        
        manager.setTheme('dark');
        expect(manager.getSystemThemeMode(), equals(ThemeMode.dark));
        
        manager.setTheme('game');
        expect(manager.getSystemThemeMode(), equals(ThemeMode.system));
      });
      
      test('デバッグ情報取得確認', () {
        final debugInfo = manager.getDebugInfo();
        
        expect(debugInfo, isA<Map<String, dynamic>>());
        expect(debugInfo.keys, contains('current_theme'));
        expect(debugInfo.keys, contains('available_themes'));
        expect(debugInfo.keys, contains('flutter_official_compliant'));
        expect(debugInfo.keys, contains('material_design_3'));
        expect(debugInfo.keys, contains('theme_data_available'));
        
        expect(debugInfo['flutter_official_compliant'], isTrue);
        expect(debugInfo['material_design_3'], isTrue);
        expect(debugInfo['theme_data_available'], isTrue);
        // Flutter公式準拠であることが明示されることを確認
      });
    });
    
    group('後方互換性テスト', () {
      test('ThemeManagerエイリアス確認', () {
        final manager = ThemeManager();
        expect(manager, isA<FlutterThemeManager>());
        // 既存コードとの互換性が保たれることを確認
      });
      
      test('DefaultUIThemeエイリアス確認', () {
        final theme = DefaultUITheme.light();
        expect(theme, isA<FlutterUITheme>());
        // 既存コードとの互換性が保たれることを確認
      });
    });
    
    group('Flutter公式準拠性テスト', () {
      test('ThemeData準拠確認', () {
        final manager = FlutterThemeManager();
        manager.initializeDefaultThemes();
        
        // 各テーマがFlutter公式ThemeDataを生成できることを確認
        final themes = ['light', 'dark', 'game'];
        for (final themeId in themes) {
          manager.setTheme(themeId);
          final themeData = manager.currentThemeData;
          
          expect(themeData, isA<ThemeData>());
          expect(themeData.colorScheme, isA<ColorScheme>());
          expect(themeData.useMaterial3, isTrue);
          // Flutter公式ThemeData準拠確認
        }
      });
      
      test('ColorScheme準拠確認', () {
        final lightTheme = FlutterUITheme.light();
        final darkTheme = FlutterUITheme.dark();
        
        final lightThemeData = lightTheme.toThemeData();
        final darkThemeData = darkTheme.toThemeData();
        
        // ColorSchemeがFlutter公式仕様に準拠していることを確認
        expect(lightThemeData.colorScheme.brightness, equals(Brightness.light));
        expect(darkThemeData.colorScheme.brightness, equals(Brightness.dark));
        
        expect(lightThemeData.colorScheme.primary, isA<Color>());
        expect(lightThemeData.colorScheme.secondary, isA<Color>());
        expect(lightThemeData.colorScheme.surface, isA<Color>());
        expect(lightThemeData.colorScheme.onSurface, isA<Color>());
        // Flutter公式ColorScheme準拠確認
      });
      
      test('Material Design 3準拠確認', () {
        final manager = FlutterThemeManager();
        manager.initializeDefaultThemes();
        
        final themes = ['light', 'dark', 'game'];
        for (final themeId in themes) {
          manager.setTheme(themeId);
          final themeData = manager.currentThemeData;
          
          // Material Design 3の特徴確認
          expect(themeData.useMaterial3, isTrue);
          expect(themeData.colorScheme, isA<ColorScheme>());
          
          // Material Design 3のColorScheme必須プロパティ確認
          expect(themeData.colorScheme.primary, isA<Color>());
          expect(themeData.colorScheme.onPrimary, isA<Color>());
          expect(themeData.colorScheme.secondary, isA<Color>());
          expect(themeData.colorScheme.onSecondary, isA<Color>());
          expect(themeData.colorScheme.surface, isA<Color>());
          expect(themeData.colorScheme.onSurface, isA<Color>());
          // Material Design 3準拠確認
        }
      });
    });
    
    group('FlutterThemedUIComponent テスト', () {
      test('Theme.of(context)準拠テーマ取得確認', () {
        // BuildContextが必要なため、実際のWidgetテストで確認が望ましいが
        // 単体テストレベルではクラス定義の存在確認のみ
        expect(FlutterThemedUIComponent, isNotNull);
        // 実際の動作確認はウィジェットテストで実施
      });
    });
    
    group('エラーハンドリング確認', () {
      test('テーマ変更リスナーエラー処理確認', () {
        final manager = FlutterThemeManager();
        manager.initializeDefaultThemes();
        
        // エラーを投げるリスナーを追加
        void errorListener(String themeId) {
          throw Exception('Test error');
        }
        
        manager.addThemeChangeListener(errorListener);
        
        // エラーが発生してもテーマ変更が正常に動作することを確認
        expect(() => manager.setTheme('dark'), returnsNormally);
        expect(manager.currentThemeId, equals('dark'));
        // エラーハンドリングが正常に動作することを確認
      });
    });
  });
}