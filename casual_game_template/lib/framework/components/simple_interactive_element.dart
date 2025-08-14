import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

/// シンプルな設定駆動のインタラクティブ要素
class SimpleInteractiveElement extends PositionComponent with TapCallbacks {
  final String id;
  final Function(String) onTap;
  final String inactiveImagePath;
  final String activeImagePath;
  final Function(String)? onActivated;
  
  bool _isActivated = false;
  SpriteComponent? _spriteComponent;
  
  SimpleInteractiveElement({
    required this.id,
    required this.onTap,
    required this.inactiveImagePath,
    required this.activeImagePath,
    required Vector2 position,
    required Vector2 size,
    this.onActivated,
  }) : super(position: position, size: size);
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadCurrentImage();
  }
  
  Future<void> _loadCurrentImage() async {
    final imagePath = _isActivated ? activeImagePath : inactiveImagePath;
    try {
      final cleanPath = imagePath.replaceFirst('assets/', '');
      final sprite = await Sprite.load(cleanPath);
      
      _spriteComponent?.removeFromParent();
      _spriteComponent = SpriteComponent(
        sprite: sprite,
        size: size,
        position: Vector2.zero(),
      );
      add(_spriteComponent!);
    } catch (e) {
      // フォールバック表示
      add(RectangleComponent(
        size: size,
        paint: Paint()..color = Colors.grey.withValues(alpha: 0.3),
        position: Vector2.zero(),
      ));
    }
  }
  
  void activate() {
    if (!_isActivated) {
      _isActivated = true;
      _loadCurrentImage();
      onActivated?.call(id);
    }
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    onTap(id);
  }
  
  bool get isActivated => _isActivated;
}