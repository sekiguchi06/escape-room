import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../ui/japanese_message_system.dart';

/// 縦画面UI構築専用クラス
/// Single Responsibility Principle適用
class PortraitUIBuilder {
  static Future<List<Component>> buildPortraitUI(Vector2 screenSize) async {
    final components = <Component>[];
    
    // 背景
    components.add(RectangleComponent(
      size: screenSize,
      paint: Paint()..color = Colors.black,
    ));
    
    // メニュー領域 (上部10%)
    components.add(RectangleComponent(
      position: Vector2(0, 0),
      size: Vector2(screenSize.x, screenSize.y * 0.1),
      paint: Paint()..color = Colors.brown.shade800,
    ));
    
    // ゲーム領域 (中央60%)
    components.add(RectangleComponent(
      position: Vector2(0, screenSize.y * 0.1),
      size: Vector2(screenSize.x, screenSize.y * 0.6),
      paint: Paint()..color = Colors.brown.shade600,
    ));
    
    // インベントリ領域 (下部20%)
    components.add(RectangleComponent(
      position: Vector2(0, screenSize.y * 0.7),
      size: Vector2(screenSize.x, screenSize.y * 0.2),
      paint: Paint()..color = Colors.grey.shade700,
    ));
    
    // インベントリタイトル
    components.add(JapaneseMessageSystem.createMessageComponent(
      'inventory_title',
      position: Vector2(screenSize.x / 2 - 40, screenSize.y * 0.72),
      fontSize: 20,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ));
    
    // アイテムなしメッセージ
    components.add(JapaneseMessageSystem.createMessageComponent(
      'inventory_empty',
      position: Vector2(screenSize.x / 2 - 70, screenSize.y * 0.82),
      fontSize: 16,
      color: Colors.white,
    ));
    
    // 広告領域 (最下部10%)
    components.add(RectangleComponent(
      position: Vector2(0, screenSize.y * 0.9),
      size: Vector2(screenSize.x, screenSize.y * 0.1),
      paint: Paint()..color = Colors.grey.shade500,
    ));
    
    // 広告プレースホルダー
    components.add(TextComponent(
      text: '📺',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 30,
          color: Colors.black,
        ),
      ),
      position: Vector2(screenSize.x / 2 - 15, screenSize.y * 0.93),
    ));
    
    return components;
  }
}