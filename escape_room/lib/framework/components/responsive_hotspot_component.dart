import 'package:flame/components.dart';
import 'hotspot_component.dart';

/// レスポンシブ対応ホットスポットコンポーネント
/// 400x600統一背景画像に対する相対座標からデバイス座標に自動変換
class ResponsiveHotspotComponent extends HotspotComponent {
  /// 400x600背景に対する相対位置 (0.0-1.0)
  final Vector2 relativePosition;
  
  /// 400x600背景に対する相対サイズ (0.0-1.0)
  final Vector2 relativeSize;
  
  /// 統一背景サイズ（400x600固定）
  static final Vector2 unifiedBackgroundSize = Vector2(400, 600);

  ResponsiveHotspotComponent({
    required super.id,
    required super.onTap,
    required this.relativePosition,
    required this.relativeSize,
    super.invisible = true,    // デフォルトで透明
    super.debugMode,
  }) : super(
    position: Vector2.zero(), // 初期値、updateForScreenSizeで更新
    size: Vector2.zero(),
  );

  /// 画面サイズ変更時に座標・サイズを自動調整
  void updateForScreenSize(Vector2 screenSize, Vector2 backgroundDisplaySize) {
    // 400x600統一背景に対する絶対座標を計算
    final absolutePosition = Vector2(
      relativePosition.x * unifiedBackgroundSize.x,
      relativePosition.y * unifiedBackgroundSize.y,
    );
    
    final absoluteSize = Vector2(
      relativeSize.x * unifiedBackgroundSize.x,
      relativeSize.y * unifiedBackgroundSize.y,
    );
    
    // 画面表示サイズに合わせてスケール調整
    final scaleX = backgroundDisplaySize.x / unifiedBackgroundSize.x;
    final scaleY = backgroundDisplaySize.y / unifiedBackgroundSize.y;
    
    // 実際のホットスポット位置・サイズを設定
    position = Vector2(
      absolutePosition.x * scaleX,
      absolutePosition.y * scaleY,
    );
    
    size = Vector2(
      absoluteSize.x * scaleX,
      absoluteSize.y * scaleY,
    );
  }

  /// デバッグ情報表示用
  Map<String, dynamic> getDebugInfo() {
    return {
      'id': id,
      'relativePosition': '(${relativePosition.x.toStringAsFixed(2)}, ${relativePosition.y.toStringAsFixed(2)})',
      'relativeSize': '(${relativeSize.x.toStringAsFixed(2)}, ${relativeSize.y.toStringAsFixed(2)})',
      'actualPosition': '(${position.x.toStringAsFixed(1)}, ${position.y.toStringAsFixed(1)})',
      'actualSize': '(${size.x.toStringAsFixed(1)}, ${size.y.toStringAsFixed(1)})',
      'invisible': isInvisible,
      'debugMode': debugMode,
    };
  }
}