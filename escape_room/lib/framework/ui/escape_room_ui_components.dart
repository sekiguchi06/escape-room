import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

/// モーダル表示タイプ
enum ModalType {
  item, // アイテム詳細表示
  puzzle, // パズル解答
  inspection, // オブジェクト詳細調査
}

/// モーダル設定
class ModalConfig {
  final ModalType type;
  final String title;
  final String content;
  final Map<String, dynamic> data;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const ModalConfig({
    required this.type,
    required this.title,
    required this.content,
    this.data = const {},
    this.onConfirm,
    this.onCancel,
  });
}

/// クリック可能なインベントリアイテム
class ClickableInventoryItem extends RectangleComponent with TapCallbacks {
  final String itemId;
  final Function(String) onTapped;

  ClickableInventoryItem({
    required this.itemId,
    required this.onTapped,
    super.size,
    super.position,
  }) : super(
         paint: Paint()..color = Colors.transparent, // 透明だがクリック可能
       );

  @override
  void onTapDown(TapDownEvent event) {
    // インベントリアイテムタップダウン
  }

  @override
  void onTapUp(TapUpEvent event) {
    // インベントリアイテムクリック
    onTapped(itemId);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    // インベントリアイテムタップキャンセル
  }
}

/// モーダルコンポーネント
class ModalComponent extends PositionComponent with TapCallbacks {
  final ModalConfig config;
  final Vector2 containerSize;
  final Paint backgroundPaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.8);
  final Paint modalPaint = Paint()..color = Colors.white;

  ModalComponent({required this.config, required this.containerSize})
    : super(size: containerSize);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _createModalElements();
  }

  void _createModalElements() {
    // モーダル背景
    final background = RectangleComponent(
      size: size,
      paint: backgroundPaint,
      position: Vector2.zero(),
    );
    add(background);

    // モーダルボックス
    final modalSize = Vector2(size.x * 0.8, size.y * 0.6);
    final modalPosition = Vector2(
      (size.x - modalSize.x) / 2,
      (size.y - modalSize.y) / 2,
    );

    final modalBox = RectangleComponent(
      size: modalSize,
      paint: modalPaint,
      position: modalPosition,
    );
    add(modalBox);

    // タイトル
    final titleText = TextComponent(
      text: config.title,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Noto Sans JP',
        ),
      ),
      position: Vector2(modalPosition.x + 20, modalPosition.y + 20),
    );
    add(titleText);

    // コンテンツ
    final contentText = TextComponent(
      text: config.content,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontFamily: 'Noto Sans JP',
        ),
      ),
      position: Vector2(modalPosition.x + 20, modalPosition.y + 60),
    );
    add(contentText);
  }

  @override
  bool onTapUp(TapUpEvent event) {
    // モーダル外をタップして閉じる
    config.onCancel?.call();
    removeFromParent();
    return true;
  }
}

/// エスケープルーム用HUDコンポーネント
class EscapeRoomHUD extends PositionComponent {
  final Function() onInventoryToggle;
  final Function() onMenuToggle;

  String _timeText = '00:00';
  int _score = 0;

  late TextComponent _timeComponent;
  late TextComponent _scoreComponent;

  EscapeRoomHUD({
    required this.onInventoryToggle,
    required this.onMenuToggle,
    required Vector2 screenSize,
  }) : super(size: screenSize);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _createHUDElements();
  }

  void _createHUDElements() {
    // タイマー表示
    _timeComponent = TextComponent(
      text: _timeText,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Noto Sans JP',
          shadows: [
            Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
          ],
        ),
      ),
      position: Vector2(20, 20),
    );
    add(_timeComponent);

    // スコア表示
    _scoreComponent = TextComponent(
      text: 'Score: $_score',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Noto Sans JP',
          shadows: [
            Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
          ],
        ),
      ),
      position: Vector2(20, 50),
    );
    add(_scoreComponent);
  }

  /// 時間更新
  void updateTime(String timeText) {
    _timeText = timeText;
    _timeComponent.text = timeText;
  }

  /// スコア更新
  void updateScore(int score) {
    _score = score;
    _scoreComponent.text = 'Score: $score';
  }
}
