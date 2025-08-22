import 'package:flutter/material.dart';
import 'modal_config.dart';
import 'modal_strategy_interface.dart';
import 'item_display_strategy.dart';
import 'puzzle_input_strategy.dart';
import 'inspection_display_strategy.dart';
import 'item_discovery_display_strategy.dart';

/// モーダル表示コンテキスト
/// Strategy Pattern使用の制御クラス
class ModalDisplayContext {
  final List<ModalDisplayStrategy> _strategies = [];
  ModalDisplayStrategy? _currentStrategy;

  /// 戦略追加
  void addStrategy(ModalDisplayStrategy strategy) {
    _strategies.add(strategy);
    debugPrint('📋 Modal strategy added: ${strategy.strategyName}');
  }

  /// デフォルト戦略を初期化
  void initializeDefaultStrategies() {
    addStrategy(ItemDisplayStrategy());
    addStrategy(PuzzleInputStrategy());
    addStrategy(InspectionDisplayStrategy());
    addStrategy(ItemDiscoveryDisplayStrategy());
    debugPrint(
      '📋 Default modal strategies initialized: ${_strategies.length} strategies',
    );
  }

  /// 適切な戦略を選択
  ModalDisplayStrategy? selectStrategy(ModalType type) {
    for (final strategy in _strategies) {
      if (strategy.canHandle(type)) {
        _currentStrategy = strategy;
        debugPrint(
          '📋 Selected modal strategy: ${strategy.strategyName} for type: $type',
        );
        return strategy;
      }
    }

    debugPrint('❌ No modal strategy found for type: $type');
    return null;
  }

  /// 現在の戦略取得
  ModalDisplayStrategy? get currentStrategy => _currentStrategy;

  /// 利用可能な戦略一覧
  List<ModalDisplayStrategy> get availableStrategies =>
      List.unmodifiable(_strategies);
}
