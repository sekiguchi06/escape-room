import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

/// 状態を持つインタラクティブ要素の基底クラス
/// Unity MonoBehaviourとFlame Componentのベストプラクティスを統合
/// 
/// この抽象クラスは以下の責任を持つ：
/// - 状態管理（activated/interactable）
/// - 画像表示とスプライト管理
/// - タップインタラクション処理
/// - エラーハンドリング（画像読み込み失敗時）
abstract class StatefulInteractiveElement extends PositionComponent 
    with TapCallbacks, HasVisibility, HasGameReference {
  
  // Core Properties
  final String id;
  final Function(String) onInteract;
  
  // State Management
  bool _isActivated = false;
  bool _isInteractable = true;
  
  // Image Management
  @protected
  SpriteComponent? _spriteComponent;
  @protected
  RectangleComponent? _backgroundComponent;
  
  StatefulInteractiveElement({
    required this.id,
    required this.onInteract,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);
  
  /// 抽象メソッド: サブクラスで状態別画像パスを定義
  /// 
  /// Example:
  /// ```dart
  /// @override
  /// String getImagePath(bool isActivated) {
  ///   return isActivated 
  ///     ? 'assets/images/hotspots/safe_opened.png'
  ///     : 'assets/images/hotspots/safe_closed.png';
  /// }
  /// ```
  String getImagePath(bool isActivated);
  
  /// 抽象メソッド: 特定の相互作用ロジック
  /// インタラクション完了時にサブクラスで実行される処理
  void onInteractionCompleted();
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _initializeVisuals();
  }
  
  /// 初期ビジュアル設定
  /// フォールバック用の背景矩形と初期画像を設定
  Future<void> _initializeVisuals() async {
    // デフォルト背景（画像読み込み失敗時のフォールバック）
    _backgroundComponent = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.grey.withValues(alpha: 0.3),
      position: Vector2.zero(),
    );
    add(_backgroundComponent!);
    
    // 枠線追加（デバッグ・開発時の視認性向上）
    final border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.grey.shade600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
      position: Vector2.zero(),
    );
    add(border);
    
    // 初期画像読み込み
    await updateVisuals();
  }
  
  /// 状態切り替え（Unity-style state management）
  /// 
  /// 状態を切り替え、ビジュアルを更新し、完了処理を実行
  void toggleState() {
    if (!_isInteractable) return;
    
    _isActivated = !_isActivated;
    updateVisuals();
    onInteractionCompleted();
    
    debugPrint('🔄 $id state toggled to: activated=$_isActivated');
  }
  
  /// ビジュアル更新（Flame-style image handling）
  /// 
  /// 現在の状態に応じた画像を読み込み、表示を更新
  Future<void> updateVisuals() async {
    final imagePath = getImagePath(_isActivated);
    await _loadSprite(imagePath);
  }
  
  /// 外部から状態を設定（アニメーションや条件付き変更用）
  void setState(bool activated) {
    if (_isActivated != activated) {
      _isActivated = activated;
      updateVisuals();
    }
  }
  
  /// スプライト読み込み（エラーハンドリング付き）
  /// 
  /// 画像読み込みに失敗した場合はフォールバック背景を表示
  @protected
  Future<void> _loadSprite(String imagePath) async {
    try {
      // assets/プレフィックスを除去
      final cleanPath = imagePath.replaceFirst('assets/', '');
      debugPrint('🖼️ Loading sprite for $id: $imagePath -> $cleanPath');
      
      // 既存スプライトを削除
      _spriteComponent?.removeFromParent();
      
      // 新しいスプライトを作成
      final sprite = await Sprite.load(cleanPath);
      _spriteComponent = SpriteComponent(
        sprite: sprite,
        size: size,
        position: Vector2.zero(),
      );
      
      add(_spriteComponent!);
      
      // 成功時は背景を透明に
      _backgroundComponent?.paint.color = Colors.transparent;
      
      debugPrint('✅ Successfully loaded sprite for $id: $cleanPath');
      
    } catch (e) {
      debugPrint('❌ Failed to load sprite for $id: $imagePath -> $e');
      
      // エラー時は背景矩形を表示
      _backgroundComponent?.paint.color = Colors.grey.withValues(alpha: 0.3);
      
      // エラー表示用のテキストを追加（デバッグ用）
      final errorText = TextComponent(
        text: '❌',
        textRenderer: TextPaint(
          style: TextStyle(
            color: Colors.red,
            fontSize: size.y * 0.3,
          ),
        ),
        position: size / 2,
        anchor: Anchor.center,
      );
      add(errorText);
    }
  }
  
  /// インタラクション制御
  /// 
  /// 要素のインタラクション可能性を制御し、視覚的フィードバックを提供
  void setInteractable(bool interactable) {
    _isInteractable = interactable;
    scale = Vector2.all(interactable ? 1.0 : 0.8); // 視覚的フィードバック（サイズ変更）
    
    debugPrint('🎮 $id interactable set to: $interactable');
  }
  
  /// Flame TapCallbacks実装
  /// 
  /// タップイベントを処理し、コールバックを実行
  @override
  void onTapUp(TapUpEvent event) {
    if (!_isInteractable) {
      debugPrint('🚫 $id tap ignored (not interactable)');
      return;
    }
    
    debugPrint('👆 $id tapped');
    onInteract(id);
    
    // 自動状態切り替えはオプション（サブクラスで制御）
    // 一部の要素は手動制御が必要（パズル等）
  }
  
  /// タップダウン時の視覚的フィードバック
  @override
  void onTapDown(TapDownEvent event) {
    if (_isInteractable) {
      scale = Vector2.all(0.95); // 軽い縮小エフェクト
    }
  }
  
  /// タップキャンセル時の復帰
  @override
  void onTapCancel(TapCancelEvent event) {
    scale = Vector2.all(1.0); // 元のサイズに復帰
  }
  
  // Getters
  bool get isActivated => _isActivated;
  bool get isInteractable => _isInteractable;
  
  /// デバッグ情報取得
  Map<String, dynamic> getDebugInfo() {
    return {
      'id': id,
      'isActivated': _isActivated,
      'isInteractable': _isInteractable,
      'hasSprite': _spriteComponent != null,
      'position': position.toString(),
      'size': size.toString(),
      'currentImagePath': getImagePath(_isActivated),
    };
  }
}