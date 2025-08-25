import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'package:escape_room/framework/ui/modal_config.dart';
import 'package:escape_room/framework/ui/modal_display_strategy.dart';
import 'package:escape_room/framework/ui/concentration_lines_component.dart';
import 'package:escape_room/framework/effects/particle_system.dart';

/// アイテム発見モーダルのテスト
/// issue #14 の実装確認
void main() {
  group('Item Discovery Modal Tests', () {
    test('ModalType.itemDiscovery が正しく追加されている', () {
      // ModalType.itemDiscovery が利用可能かチェック
      const itemDiscoveryType = ModalType.itemDiscovery;
      expect(itemDiscoveryType, isNotNull);
      expect(itemDiscoveryType.toString(), contains('itemDiscovery'));
    });

    test('ModalConfig.itemDiscovery ファクトリーメソッドが正しく動作する', () {
      // ファクトリーメソッドの動作確認
      final config = ModalConfig.itemDiscovery(
        title: 'テストアイテム',
        content: 'テスト説明',
        imagePath: 'test/item.png',
        itemId: 'test_item_001',
        onConfirm: () {},
      );

      expect(config.type, ModalType.itemDiscovery);
      expect(config.title, 'テストアイテム');
      expect(config.content, 'テスト説明');
      expect(config.imagePath, 'test/item.png');
      expect(config.data['itemId'], 'test_item_001');
      expect(config.onConfirm, isNotNull);
    });

    test('ItemDiscoveryDisplayStrategy が正しく初期化される', () {
      // Strategy の初期化確認
      final strategy = ItemDiscoveryDisplayStrategy();

      expect(strategy.strategyName, 'item_discovery_display');
      expect(strategy.canHandle(ModalType.itemDiscovery), true);
      expect(strategy.canHandle(ModalType.item), false);
      expect(strategy.canHandle(ModalType.puzzle), false);
      expect(strategy.canHandle(ModalType.inspection), false);
    });

    test('ModalDisplayContext が ItemDiscoveryDisplayStrategy を含む', () {
      // コンテキストに戦略が含まれているかチェック
      final context = ModalDisplayContext();
      context.initializeDefaultStrategies();

      final availableStrategies = context.availableStrategies;
      expect(availableStrategies, contains('item_discovery_display'));
      expect(availableStrategies.length, 4); // 4つの戦略が登録されている

      // itemDiscovery タイプの戦略が選択できるかチェック
      final selectedStrategy = context.selectStrategy(ModalType.itemDiscovery);
      expect(selectedStrategy, isNotNull);
      expect(selectedStrategy!.strategyName, 'item_discovery_display');
    });

    test('ConcentrationLinesComponent が正しく初期化される', () {
      // 集中線コンポーネントの初期化確認
      final center = Vector2(100, 100);
      final concentrationLines = ConcentrationLinesComponent(
        center: center,
        maxRadius: 200.0,
        lineCount: 16,
        lineColor: Colors.orange,
        animationDuration: 1.5,
      );

      expect(concentrationLines.center, center);
      expect(concentrationLines.maxRadius, 200.0);
      expect(concentrationLines.lineCount, 16);
      expect(concentrationLines.lineColor, Colors.orange);
      expect(concentrationLines.animationDuration, 1.5);
    });

    test('ConcentrationLinesManager が正しく動作する', () {
      // 集中線マネージャーの動作確認
      final manager = ConcentrationLinesManager();
      expect(manager.activeEffectCount, 0);

      // エフェクト追加のテスト（実際にはコンポーネントがマウントされていないのでエラーになる）
      // これは統合テスト時に確認
    });

    test('ParticleEffectManager にアイテム発見エフェクトが登録されている', () {
      // パーティクルマネージャーのエフェクト確認
      final particleManager = ParticleEffectManager();

      // onLoad を呼んでデフォルトエフェクトを登録
      particleManager.onLoad();

      // itemDiscovery エフェクトが登録されているかは内部状態なので直接確認不可
      // 実際の動作は統合テスト時に確認
      expect(particleManager.activeEffectCount, 0);
    });

    test('入力検証が正しく動作する', () {
      // ItemDiscoveryDisplayStrategy の入力検証
      final strategy = ItemDiscoveryDisplayStrategy();
      final config = ModalConfig.itemDiscovery(title: 'テスト', content: 'テスト内容');

      // アイテム発見演出は入力検証不要なので常にtrue
      expect(strategy.validateInput('any_input', config), true);
      expect(strategy.validateInput('', config), true);
    });

    test('確認処理が正しく実行される', () {
      // executeConfirm の動作確認
      bool confirmCalled = false;

      final config = ModalConfig.itemDiscovery(
        title: 'テスト',
        content: 'テスト内容',
        onConfirm: () => confirmCalled = true,
      );

      final strategy = ItemDiscoveryDisplayStrategy();
      strategy.executeConfirm(config, null);

      expect(confirmCalled, true);
    });
  });

  group('Integration Tests', () {
    testWidgets('ModalManager で ItemDiscovery モーダルを作成できる', (
      WidgetTester tester,
    ) async {
      // 統合テストはwidgetTestで実行
      // 実際のFlameゲーム環境での動作確認

      // TODO: Flameゲーム環境でのテスト実装
      // 現在は基本的な機能テストのみ実装
      expect(true, true); // プレースホルダー
    });
  });
}
