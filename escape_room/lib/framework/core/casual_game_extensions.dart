import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../ui/flame_ui_builder.dart';

/// カジュアルゲーム開発用の便利な拡張メソッド集
/// ConfigurableGame/FlameGame用の汎用的な機能を提供

/// PositionComponent用拡張メソッド
extension CasualGameComponentExtensions on PositionComponent {
  /// 画面中央配置
  void centerInScreen(Vector2 screenSize) {
    position = Vector2(
      (screenSize.x - size.x) / 2,
      (screenSize.y - size.y) / 2,
    );
  }
  
  /// 境界チェック
  bool isWithinBounds(Vector2 screenSize) {
    return position.x >= 0 && 
           position.y >= 0 && 
           position.x + size.x <= screenSize.x && 
           position.y + size.y <= screenSize.y;
  }
  
  /// 距離計算
  double distanceTo(PositionComponent other) {
    return position.distanceTo(other.position);
  }
  
  /// 衝突判定（円形）
  bool circularCollidesWith(PositionComponent other) {
    final distance = distanceTo(other);
    final minDistance = (size.length + other.size.length) / 4;
    return distance <= minDistance;
  }
}

/// FlameGame用拡張メソッド  
extension CasualGameExtensions on FlameGame {
  /// 画面フラッシュエフェクト
  void flashScreen({Color color = Colors.white, double duration = 0.2}) {
    final flash = RectangleComponent(
      size: size,
      paint: Paint()..color = color.withValues(alpha: 0.5),
    );
    add(flash);
    
    Future.delayed(Duration(milliseconds: (duration * 1000).round()), () {
      flash.removeFromParent();
    });
  }
  
  /// 基本UI生成
  List<Component> createStandardGameUI() {
    return [
      FlameUIBuilder.scoreText(
        text: 'Score: 0',
        screenSize: size,
      ),
      FlameUIBuilder.timerText(
        text: 'Time: 00:00',
        screenSize: size,
      ),
    ];
  }
}