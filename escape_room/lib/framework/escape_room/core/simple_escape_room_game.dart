import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 最小限の動作するEscape Room実装
/// 移植ガイド準拠・200行制限厳守
class SimpleEscapeRoomGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _createPortraitLayout();
  }

  /// 縦画面5分割レイアウト作成
  Future<void> _createPortraitLayout() async {
    // 背景
    add(RectangleComponent(size: size, paint: Paint()..color = Colors.black));

    // メニュー領域 (上部10%)
    add(
      RectangleComponent(
        position: Vector2(0, 0),
        size: Vector2(size.x, size.y * 0.1),
        paint: Paint()..color = Colors.brown.shade800,
      ),
    );

    add(
      TextComponent(
        text: '🔓 Escape Room',
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        position: Vector2(10, size.y * 0.03),
      ),
    );

    // ゲーム領域 (中央60%)
    add(
      RectangleComponent(
        position: Vector2(0, size.y * 0.1),
        size: Vector2(size.x, size.y * 0.6),
        paint: Paint()..color = Colors.brown.shade600,
      ),
    );

    add(
      TextComponent(
        text: 'ゲーム画面',
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        position: Vector2(size.x / 2 - 40, size.y * 0.4),
      ),
    );

    // インベントリ領域 (下部20%)
    add(
      RectangleComponent(
        position: Vector2(0, size.y * 0.7),
        size: Vector2(size.x, size.y * 0.2),
        paint: Paint()..color = Colors.grey.shade700,
      ),
    );

    add(
      TextComponent(
        text: 'インベントリ',
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        position: Vector2(size.x / 2 - 40, size.y * 0.75),
      ),
    );

    add(
      TextComponent(
        text: 'アイテムがありません',
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        position: Vector2(size.x / 2 - 60, size.y * 0.82),
      ),
    );

    // 広告領域 (最下部10%)
    add(
      RectangleComponent(
        position: Vector2(0, size.y * 0.9),
        size: Vector2(size.x, size.y * 0.1),
        paint: Paint()..color = Colors.grey.shade500,
      ),
    );

    add(
      TextComponent(
        text: '📺 広告',
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        position: Vector2(size.x / 2 - 30, size.y * 0.93),
      ),
    );
  }
}
