import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

/// ホットスポットコンポーネント
/// 脱出ゲームでクリック可能なオブジェクトを表現
class HotspotComponent extends SpriteComponent with TapCallbacks {
  final String id;
  late final Function(String) onTap;
  bool _invisible = false;
  bool _debugMode = false;
  int? _hotspotNumber; // ホットスポット番号（左上に表示用）

  HotspotComponent({
    required this.id,
    required this.onTap,
    required Vector2 position,
    required Vector2 size,
    bool invisible = false,
    bool debugMode = false,
    int? hotspotNumber,
  }) : _invisible = invisible,
       _debugMode = debugMode,
       _hotspotNumber = hotspotNumber,
       super(position: position, size: size);

  /// 透明状態の取得
  bool get isInvisible => _invisible;

  /// デバッグモード状態の取得
  @override
  bool get debugMode => _debugMode;

  /// ホットスポット番号の取得
  int? get hotspotNumber => _hotspotNumber;

  /// 透明状態の設定
  void setInvisible(bool invisible) {
    _invisible = invisible;
    _updateVisibility();
  }

  /// デバッグモードの設定
  void setDebugMode(bool debugMode) {
    _debugMode = debugMode;
    _updateVisibility();
  }

  /// ホットスポット番号の設定
  void setHotspotNumber(int? number) {
    _hotspotNumber = number;
  }

  /// 表示状態の更新
  void _updateVisibility() {
    if (_debugMode) {
      // デバッグモード時は赤い半透明で表示
      opacity = 1.0;
    } else if (_invisible) {
      // 透明時は完全に非表示
      opacity = 0.0;
    } else {
      // 通常時は表示
      opacity = 1.0;
    }
  }

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
    // デバッグモードでない場合は親のレンダリング処理のみ実行
    if (!_debugMode) {
      super.render(canvas);
      return;
    }

    // 透明背景で赤い枠線のホットスポットを描画
    final borderPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 赤い枠線を描画
    canvas.drawRect(size.toRect(), borderPaint);

    // ホットスポット番号を左上に表示
    if (_hotspotNumber != null) {
      final numberTextPainter = TextPainter(
        text: TextSpan(
          text: _hotspotNumber.toString(),
          style: const TextStyle(
            color: Colors.red,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      numberTextPainter.layout();
      
      // 白い背景の小さな矩形を描画
      final backgroundRect = Rect.fromLTWH(
        2, 2, 
        numberTextPainter.width + 4, 
        numberTextPainter.height + 2,
      );
      final backgroundPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9);
      canvas.drawRect(backgroundRect, backgroundPaint);

      // 番号テキストを描画
      numberTextPainter.paint(canvas, const Offset(4, 2));
    }

    // デバッグ情報としてIDを右下に小さく表示
    if (_debugMode) {
      final idTextPainter = TextPainter(
        text: TextSpan(
          text: id,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 10,
            fontWeight: FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      idTextPainter.layout();
      idTextPainter.paint(
        canvas,
        Offset(
          size.x - idTextPainter.width - 2,
          size.y - idTextPainter.height - 2,
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
