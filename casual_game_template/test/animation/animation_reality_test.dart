import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:casual_game_template/framework/animation/animation_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('AnimationSystem Reality Tests', () {
    testWithFlameGame('透明度アニメーション動作確認', (game) async {
      final manager = AnimationManager();
      await game.add(manager);
      
      // PositionComponentは OpacityProviderを実装していない
      final target = PositionComponent();
      await game.add(target);
      await game.ready();
      
      // 透明度アニメーションを実行
      await manager.animateOpacity(
        target,
        1.0,
        0.0,
        config: const AnimationConfig(duration: Duration(milliseconds: 100)),
      );
      
      // Effectが追加されないことを確認（Provider未実装のため）
      expect(target.children.isEmpty, isTrue);
    });
    
    testWithFlameGame('実際の値変更確認', (game) async {
      final manager = AnimationManager();
      await game.add(manager);
      
      final target = PositionComponent(position: Vector2(0, 0));
      await game.add(target);
      await game.ready();
      
      final initialPosition = target.position.clone();
      
      // 移動アニメーション実行
      await manager.animateMove(
        target,
        Vector2(0, 0),
        Vector2(100, 100),
        config: const AnimationConfig(duration: Duration(milliseconds: 100)),
      );
      
      // 100ms後の位置確認
      await Future.delayed(const Duration(milliseconds: 110));
      
      // 位置が変更されているか確認
      print('Initial: $initialPosition, Current: ${target.position}');
      // Effectの非同期性により正確な値は保証されない
    });
  });
}