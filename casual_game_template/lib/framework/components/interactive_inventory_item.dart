import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'stateful_interactive_element.dart';

/// AI生成画像対応のインベントリアイテムコンポーネント
/// 
/// インベントリ内で表示される、選択可能なゲームアイテム
/// 状態に応じた画像表示（通常/選択中/使用済み等）をサポート
class InteractiveInventoryItem extends StatefulInteractiveElement {
  
  final String itemName;
  final String itemDescription;
  final String itemType;
  final Map<String, String> _imagePaths;
  final Function(String)? onSelectionChanged;
  
  bool _isSelected = false;
  bool _isUsed = false;
  
  /// インベントリアイテム作成
  /// 
  /// [imagePaths] は状態別の画像パスマップ
  /// 例: {'normal': 'path1', 'selected': 'path2', 'used': 'path3'}
  InteractiveInventoryItem({
    required super.id,
    required this.itemName,
    required this.itemDescription,
    required this.itemType,
    required Map<String, String> imagePaths,
    required super.onInteract,
    required super.position,
    required super.size,
    this.onSelectionChanged,
  }) : _imagePaths = Map.from(imagePaths);
  
  /// Factory constructors for common item types
  
  /// 鍵アイテム
  factory InteractiveInventoryItem.key({
    required Function(String) onInteract,
    required Vector2 position,
    required Vector2 size,
    Function(String)? onSelectionChanged,
  }) {
    return InteractiveInventoryItem(
      id: 'key',
      itemName: '鍵',
      itemDescription: 'ドアを開けるのに必要な鍵',
      itemType: 'tool',
      imagePaths: {
        'normal': 'assets/images/items/key_normal.png',
        'selected': 'assets/images/items/key_selected.png',
        'used': 'assets/images/items/key_used.png',
      },
      onInteract: onInteract,
      position: position,
      size: size,
      onSelectionChanged: onSelectionChanged,
    );
  }
  
  /// コードメモアイテム
  factory InteractiveInventoryItem.code({
    required Function(String) onInteract,
    required Vector2 position,
    required Vector2 size,
    Function(String)? onSelectionChanged,
  }) {
    return InteractiveInventoryItem(
      id: 'code',
      itemName: 'メモ',
      itemDescription: '4桁の数字が書かれている: 1234',
      itemType: 'information',
      imagePaths: {
        'normal': 'assets/images/items/code_normal.png',
        'selected': 'assets/images/items/code_selected.png',
        'used': 'assets/images/items/code_used.png',
      },
      onInteract: onInteract,
      position: position,
      size: size,
      onSelectionChanged: onSelectionChanged,
    );
  }
  
  /// ツールアイテム
  factory InteractiveInventoryItem.tool({
    required Function(String) onInteract,
    required Vector2 position,
    required Vector2 size,
    Function(String)? onSelectionChanged,
  }) {
    return InteractiveInventoryItem(
      id: 'tool',
      itemName: 'ドライバー',
      itemDescription: '何かを分解するのに使えそう',
      itemType: 'tool',
      imagePaths: {
        'normal': 'assets/images/items/tool_normal.png',
        'selected': 'assets/images/items/tool_selected.png',
        'used': 'assets/images/items/tool_used.png',
      },
      onInteract: onInteract,
      position: position,
      size: size,
      onSelectionChanged: onSelectionChanged,
    );
  }
  
  /// アイコンベースのアイテム（フォールバック用）
  factory InteractiveInventoryItem.iconBased({
    required String id,
    required String itemName,
    required String itemDescription,
    required String itemType,
    required String iconEmoji,
    required Function(String) onInteract,
    required Vector2 position,
    required Vector2 size,
    Function(String)? onSelectionChanged,
  }) {
    return InteractiveInventoryItem(
      id: id,
      itemName: itemName,
      itemDescription: itemDescription,
      itemType: itemType,
      imagePaths: {
        'icon': iconEmoji, // 特殊: 絵文字アイコン
      },
      onInteract: onInteract,
      position: position,
      size: size,
      onSelectionChanged: onSelectionChanged,
    );
  }
  
  @override
  String getImagePath(bool isActivated) {
    // 使用済みアイテムの場合
    if (_isUsed && _imagePaths.containsKey('used')) {
      return _imagePaths['used']!;
    }
    
    // 選択中の場合
    if (_isSelected && _imagePaths.containsKey('selected')) {
      return _imagePaths['selected']!;
    }
    
    // 通常状態
    if (_imagePaths.containsKey('normal')) {
      return _imagePaths['normal']!;
    }
    
    // アイコンベースの場合（特殊処理）
    if (_imagePaths.containsKey('icon')) {
      return _imagePaths['icon']!; // 絵文字等
    }
    
    // フォールバック
    return 'assets/images/items/default.png';
  }
  
  Future<void> _loadSpriteOverride(String imagePath) async {
    // アイコンベース（絵文字）の場合は特殊処理
    if (_imagePaths.containsKey('icon') && imagePath == _imagePaths['icon']) {
      await _renderIconText(imagePath);
      return;
    }
    
    // 通常の画像読み込み処理は基底クラスに委譲
    await updateVisuals();
  }
  
  /// アイコンテキスト（絵文字）のレンダリング
  Future<void> _renderIconText(String iconText) async {
    try {
      // 既存スプライトを削除
      _spriteComponent?.removeFromParent();
      
      // テキストコンポーネントとして描画
      final iconComponent = TextComponent(
        text: iconText,
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: size.y * 0.6,
          ),
        ),
        position: size / 2,
        anchor: Anchor.center,
      );
      
      add(iconComponent);
      
      // 成功時は背景を透明に
      _backgroundComponent?.paint.color = Colors.transparent;
      
      debugPrint('✅ Successfully rendered icon for $id: $iconText');
      
    } catch (e) {
      debugPrint('❌ Failed to render icon for $id: $iconText -> $e');
      // エラー時は背景矩形を表示
      _backgroundComponent?.paint.color = Colors.grey.withValues(alpha: 0.3);
    }
  }
  
  @override
  void onInteractionCompleted() {
    // 選択状態の切り替え
    _isSelected = !_isSelected;
    
    debugPrint('🎒 Item $id ($itemName) ${_isSelected ? "selected" : "deselected"}');
    
    // ビジュアル更新
    updateVisuals();
    
    // 外部コールバック実行
    onSelectionChanged?.call(id);
    
    // アイテムタイプ別ロジック
    _handleItemLogic();
  }
  
  /// アイテムタイプ別ロジック
  void _handleItemLogic() {
    switch (itemType) {
      case 'tool':
        if (_isSelected) {
          debugPrint('🔧 Tool selected: $itemName');
          // ツール選択時の処理
        }
        break;
        
      case 'information':
        if (_isSelected) {
          debugPrint('📄 Information item selected: $itemName');
          // 情報アイテム選択時の処理（モーダル表示等）
        }
        break;
        
      case 'key':
        if (_isSelected) {
          debugPrint('🔑 Key selected: $itemName');
          // キー選択時の処理
        }
        break;
        
      default:
        debugPrint('❓ Unknown item type: $itemType');
        break;
    }
  }
  
  /// アイテム使用（外部から呼び出し）
  void useItem() {
    if (_isUsed) {
      debugPrint('⚠️ Item $id already used');
      return;
    }
    
    _isUsed = true;
    _isSelected = false; // 使用時は選択解除
    setInteractable(false); // 使用済みアイテムは非インタラクティブ
    
    updateVisuals();
    
    debugPrint('✅ Item $id used');
  }
  
  /// 選択状態の設定
  void setSelected(bool selected) {
    if (_isUsed) return; // 使用済みアイテムは選択不可
    
    if (_isSelected != selected) {
      _isSelected = selected;
      updateVisuals();
      onSelectionChanged?.call(id);
    }
  }
  
  /// アイテム情報の取得
  Map<String, dynamic> getItemInfo() {
    return {
      ...getDebugInfo(),
      'itemName': itemName,
      'itemDescription': itemDescription,
      'itemType': itemType,
      'isSelected': _isSelected,
      'isUsed': _isUsed,
      'imagePaths': _imagePaths,
    };
  }
  
  // Getters
  bool get isSelected => _isSelected;
  bool get isUsed => _isUsed;
  String get name => itemName;
  String get description => itemDescription;
  String get type => itemType;
}