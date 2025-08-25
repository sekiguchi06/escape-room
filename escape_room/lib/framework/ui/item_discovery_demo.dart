import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'modal_config.dart';
import 'modal_manager.dart';
import 'modal_display_strategy.dart';
import 'concentration_lines_component.dart';
import '../effects/particle_system.dart';

/// アイテム発見モーダルのデモンストレーション
/// 実際の動作確認用のコンポーネント
class ItemDiscoveryDemo extends FlameGame {
  late ModalManager _modalManager;
  late ConcentrationLinesManager _concentrationLinesManager;
  late ParticleEffectManager _particleEffectManager;
  late ItemDiscoveryDisplayStrategy _itemDiscoveryStrategy;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // エフェクトマネージャーの初期化
    _concentrationLinesManager = ConcentrationLinesManager();
    _particleEffectManager = ParticleEffectManager();
    _modalManager = ModalManager();

    // ItemDiscoveryDisplayStrategyの初期化とエフェクトマネージャーの設定
    _itemDiscoveryStrategy = ItemDiscoveryDisplayStrategy();
    _itemDiscoveryStrategy.setEffectManagers(
      concentrationLinesManager: _concentrationLinesManager,
      particleEffectManager: _particleEffectManager,
    );

    // エフェクトマネージャーをモーダルマネージャーに設定
    _modalManager.setEffectManagers(
      concentrationLinesManager: _concentrationLinesManager,
      particleEffectManager: _particleEffectManager,
    );

    // コンポーネント追加
    add(_concentrationLinesManager);
    add(_particleEffectManager);
    add(_modalManager);

    // タップハンドリング用のコンポーネント追加
    add(TapHandler(onTapCallback: _showItemDiscoveryModal));
  }

  /// アイテム発見モーダルを表示
  void _showItemDiscoveryModal() {
    final config = ModalConfig.itemDiscovery(
      title: '新しいアイテムを発見！',
      content: '貴重なアイテムを手に入れました',
      imagePath: 'items/coin.png',
      itemId: 'demo_item_001',
      onConfirm: () {
        _modalManager.hideTopModal();
      },
    );

    _modalManager.showModal(config, size);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 背景を白に設定
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = Colors.white,
    );

    // 説明テキストを描画
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Tap to show Item Discovery Modal',
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.x - textPainter.width) / 2,
        (size.y - textPainter.height) / 2,
      ),
    );
  }
}

/// タップハンドリング用のコンポーネント
class TapHandler extends PositionComponent with HasGameReference {
  final VoidCallback onTapCallback;

  TapHandler({required this.onTapCallback});

  bool onTapDown(TapDownEvent event) {
    onTapCallback();
    return true;
  }
}

/// デモ用のFlutterWidgetラッパー
class ItemDiscoveryDemoWidget extends StatelessWidget {
  const ItemDiscoveryDemoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Discovery Modal Demo'),
        backgroundColor: Colors.blue,
      ),
      body: const GameWidget<ItemDiscoveryDemo>.controlled(
        gameFactory: ItemDiscoveryDemo.new,
      ),
    );
  }
}
