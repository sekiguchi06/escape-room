import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../../gen/assets.gen.dart';
import 'japanese_message_system.dart';

/// アイテム取得通知コンポーネント
/// 画面下部からスライド表示される横長の通知枠
class ItemAcquisitionNotification extends PositionComponent {
  final String itemName;
  final String description;
  final AssetGenImage itemAsset;
  final double screenWidth;
  final double screenHeight;
  
  late RectangleComponent _backgroundPanel;
  late SpriteComponent _itemIcon;
  late TextComponent _titleText;
  late TextComponent _descriptionText;
  
  bool _isVisible = false;
  
  ItemAcquisitionNotification({
    required this.itemName,
    required this.description,
    required this.itemAsset,
    required this.screenWidth,
    required this.screenHeight,
  });
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _setupNotificationUI();
  }
  
  /// 通知UIの設定
  Future<void> _setupNotificationUI() async {
    // 通知パネルのサイズと位置
    final panelWidth = screenWidth * 0.9;
    final panelHeight = 80.0;
    final panelX = (screenWidth - panelWidth) / 2;
    final panelY = screenHeight; // 画面外から開始
    
    // 背景パネル
    _backgroundPanel = RectangleComponent(
      position: Vector2(panelX, panelY),
      size: Vector2(panelWidth, panelHeight),
      paint: Paint()
        ..color = Colors.black.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill,
    );
    
    // 枠線
    final borderPanel = RectangleComponent(
      position: Vector2(panelX, panelY),
      size: Vector2(panelWidth, panelHeight),
      paint: Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    
    // アイテムアイコン
    _itemIcon = SpriteComponent(
      position: Vector2(panelX + 10, panelY + 10),
      size: Vector2(60, 60),
    );
    
    // アイテム画像を読み込み
    try {
      _itemIcon.sprite = await Sprite.load(itemAsset.path.replaceFirst('assets/', ''));
    } catch (e) {
      debugPrint('❌ Failed to load item icon: ${itemAsset.path} -> $e');
      // 読み込み失敗時は黄色い四角を表示
      _itemIcon.paint = Paint()..color = Colors.yellow;
    }
    
    // タイトルテキスト
    _titleText = TextComponent(
      text: '✨ $itemName を手に入れました！',
      textRenderer: JapaneseFontSystem.getTextPaint(18, Colors.yellow, FontWeight.bold),
      position: Vector2(panelX + 85, panelY + 15),
      anchor: Anchor.topLeft,
    );
    
    // 説明テキスト
    _descriptionText = TextComponent(
      text: description,
      textRenderer: JapaneseFontSystem.getTextPaint(14, Colors.white),
      position: Vector2(panelX + 85, panelY + 40),
      anchor: Anchor.topLeft,
    );
    
    // コンポーネント追加
    add(_backgroundPanel);
    add(borderPanel);
    add(_itemIcon);
    add(_titleText);
    add(_descriptionText);
  }
  
  /// 通知を表示
  void show() {
    if (_isVisible) return;
    
    _isVisible = true;
    
    // 最終位置（インベントリ領域の少し上）
    final targetY = screenHeight - 200.0; // インベントリ領域の上
    
    // スライドアップアニメーション
    final slideEffect = MoveToEffect(
      Vector2(_backgroundPanel.position.x, targetY),
      EffectController(
        duration: 0.5,
        curve: Curves.easeOutBack,
      ),
    );
    
    _backgroundPanel.add(slideEffect);
    
    // アイコンも同時に移動
    _itemIcon.add(MoveToEffect(
      Vector2(_itemIcon.position.x, targetY + 10),
      EffectController(duration: 0.5, curve: Curves.easeOutBack),
    ));
    
    // テキストも同時に移動
    _titleText.add(MoveToEffect(
      Vector2(_titleText.position.x, targetY + 15),
      EffectController(duration: 0.5, curve: Curves.easeOutBack),
    ));
    
    _descriptionText.add(MoveToEffect(
      Vector2(_descriptionText.position.x, targetY + 40),
      EffectController(duration: 0.5, curve: Curves.easeOutBack),
    ));
    
    debugPrint('🎊 Item acquisition notification shown: $itemName');
    
    // 3秒後に自動的に非表示
    Future.delayed(const Duration(seconds: 3), () {
      hide();
    });
  }
  
  /// 通知を非表示
  void hide() {
    if (!_isVisible) return;
    
    _isVisible = false;
    
    // 画面外へスライドアウト
    final slideOutEffect = MoveToEffect(
      Vector2(_backgroundPanel.position.x, screenHeight + 100),
      EffectController(
        duration: 0.3,
        curve: Curves.easeInBack,
      ),
      onComplete: () {
        removeFromParent();
      },
    );
    
    _backgroundPanel.add(slideOutEffect);
    
    // 他の要素も同時に移動
    _itemIcon.add(MoveToEffect(
      Vector2(_itemIcon.position.x, screenHeight + 110),
      EffectController(duration: 0.3, curve: Curves.easeInBack),
    ));
    
    _titleText.add(MoveToEffect(
      Vector2(_titleText.position.x, screenHeight + 115),
      EffectController(duration: 0.3, curve: Curves.easeInBack),
    ));
    
    _descriptionText.add(MoveToEffect(
      Vector2(_descriptionText.position.x, screenHeight + 140),
      EffectController(duration: 0.3, curve: Curves.easeInBack),
    ));
    
    debugPrint('🎊 Item acquisition notification hidden: $itemName');
  }
  
  /// 通知が表示中かチェック
  bool get isVisible => _isVisible;
}

/// アイテム取得通知マネージャー
/// 複数の通知を管理し、重複を防ぐ
class ItemAcquisitionNotificationManager extends Component {
  ItemAcquisitionNotification? _currentNotification;
  
  /// アイテム取得通知を表示
  void showNotification({
    required String itemName,
    required String description,
    required AssetGenImage itemAsset,
    required Vector2 screenSize,
  }) {
    // 既存の通知があれば先に非表示
    if (_currentNotification != null && _currentNotification!.isVisible) {
      _currentNotification!.hide();
    }
    
    // 新しい通知を作成
    _currentNotification = ItemAcquisitionNotification(
      itemName: itemName,
      description: description,
      itemAsset: itemAsset,
      screenWidth: screenSize.x,
      screenHeight: screenSize.y,
    );
    
    add(_currentNotification!);
    _currentNotification!.show();
    
    debugPrint('🎊 Notification manager: Showing $itemName');
  }
  
  /// 現在の通知を非表示
  void hideCurrentNotification() {
    _currentNotification?.hide();
  }
  
  /// 通知が表示中かチェック
  bool get hasActiveNotification => _currentNotification?.isVisible ?? false;
}