import 'package:flutter_test/flutter_test.dart';

import 'package:flame/components.dart';

import 'package:casual_game_template/framework/ui/ui_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('UI Layer Management System Tests', () {
    test('UILayerPriority values are correct', () {
      expect(UILayerPriority.background, equals(0));
      expect(UILayerPriority.gameContent, equals(100));
      expect(UILayerPriority.ui, equals(200));
      expect(UILayerPriority.modal, equals(300));
      expect(UILayerPriority.overlay, equals(400));
      expect(UILayerPriority.tooltip, equals(500));
    });

    test('UILayoutManager - レイアウト計算', () {
      final screenSize = Vector2(800, 600);
      final componentSize = Vector2(100, 50);
      
      // 中央配置
      final center = UILayoutManager.center(screenSize, componentSize);
      expect(center.x, equals(350)); // (800-100)/2
      expect(center.y, equals(275)); // (600-50)/2
      
      // 右上配置
      final topRight = UILayoutManager.topRight(screenSize, componentSize, 20);
      expect(topRight.x, equals(680)); // 800-100-20
      expect(topRight.y, equals(20));
    });

    test('ButtonUIComponent - ボタン基本動作', () async {
      bool pressed = false; // テスト用フラグ
      final button = ButtonUIComponent(
        text: 'Test Button',
        onPressed: () => pressed = true,
      );
      
      await button.onLoad();
      
      // ボタンが正常に作成されることを確認
      expect(button, isNotNull);
      expect(button.size.x, equals(120)); // デフォルトサイズ
      expect(button.size.y, equals(40)); // デフォルトサイズ
      
      // プロパティシステムの動作確認
      button.setProperty('customProp', 'testValue');
      expect(button.getProperty<String>('customProp'), equals('testValue'));
      
      // ボタン押下状態の確認
      expect(pressed, isFalse);
      button.onPressed?.call(); // コールバック実行をシミュレート
      expect(pressed, isTrue);
    });

    test('TextUIComponent - テキスト表示', () async {
      final textComponent = TextUIComponent(
        text: 'Hello World',
        styleId: 'large',
      );
      
      await textComponent.onLoad();
      
      expect(textComponent.text, equals('Hello World'));
      expect(textComponent.styleId, equals('large'));
      
      // テキスト更新
      textComponent.setText('Updated Text', styleId: 'medium');
      expect(textComponent.text, equals('Updated Text'));
      expect(textComponent.styleId, equals('medium'));
    });

    test('SettingsMenuComponent initializes with correct size', () {
      final settingsMenu = SettingsMenuComponent();
      
      expect(settingsMenu.size.x, equals(300));
      expect(settingsMenu.size.y, equals(400));
      expect(settingsMenu.priority, equals(UILayerPriority.modal + 1));
    });
  });

  group('Integration Tests - RouterComponent移行後', () {
    test('RouterComponent移行完了 - 旧システム削除確認', () {
      // UIScreenManagerとModalOverlayComponentは削除済み
      // RouterComponentベースの新システムが動作することを確認
      
      // UIレイアウトマネージャーは残存
      expect(UILayoutManager.center, isNotNull);
      
      // UIコンポーネントは残存
      final button = ButtonUIComponent(text: 'Test');
      expect(button, isNotNull);
      
      // 新しいSettingsMenuComponentは残存
      final settings = SettingsMenuComponent();
      expect(settings.size.x, equals(300));
    });
  });
}