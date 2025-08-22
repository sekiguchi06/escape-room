import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 2状態スプライト管理コンポーネント
/// 🎯 目的: inactive/active状態の画像管理を単一責任で担当
class DualSpriteComponent extends Component {
  final String inactiveAssetPath;
  final String activeAssetPath;
  final Color fallbackColor;
  final Vector2 componentSize;

  SpriteComponent? _currentSpriteComponent;
  Sprite? _inactiveSprite;
  Sprite? _activeSprite;
  bool _isActive = false;

  DualSpriteComponent({
    required this.inactiveAssetPath,
    required this.activeAssetPath,
    required this.fallbackColor,
    required this.componentSize,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadSprites();
    _createInitialSprite();
  }

  /// スプライト読み込み（Flame公式推奨方法）
  Future<void> _loadSprites() async {
    debugPrint(
      '🔍 DualSprite attempting to load: inactive=$inactiveAssetPath, active=$activeAssetPath',
    );
    try {
      _inactiveSprite = await Sprite.load(inactiveAssetPath);
      _activeSprite = await Sprite.load(activeAssetPath);
      debugPrint(
        '✅ DualSprite loaded successfully: $inactiveAssetPath, $activeAssetPath',
      );
    } catch (e) {
      debugPrint('❌ Failed to load sprites: $e');
      debugPrint(
        '❌ Attempted paths: inactive=$inactiveAssetPath, active=$activeAssetPath',
      );
      // スプライト読み込み失敗時はnullのまま（フォールバック使用）
    }
  }

  /// 初期スプライト作成
  void _createInitialSprite() {
    debugPrint(
      'DualSprite: _createInitialSprite called, _inactiveSprite: ${_inactiveSprite != null}',
    );
    if (_inactiveSprite != null) {
      _currentSpriteComponent = SpriteComponent(sprite: _inactiveSprite!)
        ..size = componentSize;
      add(_currentSpriteComponent!);
      debugPrint('DualSprite: Using sprite rendering');
    } else {
      // フォールバック: 色付き四角形
      final fallbackComponent = RectangleComponent(
        size: componentSize,
        paint: Paint()..color = fallbackColor,
      );
      add(fallbackComponent);
      debugPrint('DualSprite: Using fallback color rendering');
    }
  }

  /// アクティブ状態に切り替え
  void switchToActive() {
    if (_isActive) return;

    _isActive = true;

    if (_activeSprite != null && _currentSpriteComponent != null) {
      _currentSpriteComponent!.sprite = _activeSprite!;
      debugPrint('DualSprite: Switched to active state');
    } else {
      debugPrint('DualSprite: Active sprite not available');
    }
  }

  /// 非アクティブ状態に切り替え（テスト用）
  void switchToInactive() {
    if (!_isActive) return;

    _isActive = false;

    if (_inactiveSprite != null && _currentSpriteComponent != null) {
      _currentSpriteComponent!.sprite = _inactiveSprite!;
      debugPrint('DualSprite: Switched to inactive state');
    }
  }

  /// 現在の状態取得
  bool get isActive => _isActive;

  /// スプライト読み込み状態確認
  bool get hasSprites => _inactiveSprite != null && _activeSprite != null;
}
