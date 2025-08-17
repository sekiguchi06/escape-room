import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

/// ホットスポットコンポーネント
/// 脱出ゲームでクリック可能なオブジェクトを表現
class HotspotComponent extends SpriteComponent with TapCallbacks {
  final String id;
  late final Function(String) onTap;
  
  HotspotComponent({
    required this.id,
    required this.onTap,
    required Vector2 position,
    required Vector2 size,
  }) : super(
          position: position,
          size: size,
        );

  @override
  Future<void> onLoad() async {
    // 初期状態では背景矩形のみ表示
    final background = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.grey.withValues(alpha: 0.3),
      position: Vector2.zero(),
    );
    add(background);
  }

  /// 画像を更新する
  Future<void> updateImage(String imagePath) async {
    try {
      // assets/を除いたパスでロード
      final cleanPath = imagePath.replaceFirst('assets/', '');
      debugPrint('🖼️ Loading hotspot image: $imagePath -> $cleanPath');
      sprite = await Sprite.load(cleanPath);
      debugPrint('✅ Successfully loaded hotspot image: $cleanPath');
    } catch (e) {
      debugPrint('❌ Failed to load image: $imagePath -> $e');
      // 画像読み込み失敗時は代替画像または矩形を表示
      sprite = null;
    }
  }

  @override
  void render(Canvas canvas) {
    if (sprite != null) {
      super.render(canvas);
    } else {
      // スプライトがない場合は枠線付きの矩形を描画
      final paint = Paint()
        ..color = Colors.grey.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      
      final borderPaint = Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      canvas.drawRect(size.toRect(), paint);
      canvas.drawRect(size.toRect(), borderPaint);
      
      // IDテキストを表示
      final textPainter = TextPainter(
        text: TextSpan(
          text: id,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
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

  @override
  bool onTapDown(TapDownEvent event) {
    onTap(id);
    return true;
  }
}