import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'stateful_interactive_element.dart';

/// AI生成画像対応のホットスポットコンポーネント
/// 
/// 脱出ゲーム等で使用される、状態変化するインタラクティブオブジェクト
/// 例：本棚（満杯→空）、金庫（閉→開）、箱（閉→開）
class InteractiveHotspot extends StatefulInteractiveElement {
  
  final String name;
  final String description;
  final Map<String, String> _imagePaths;
  final Function(String)? onStateChanged;
  
  /// ホットスポット作成
  /// 
  /// [imagePaths] は状態別の画像パスマップ
  /// 例: {'closed': 'assets/images/hotspots/safe_closed.png', 'opened': 'assets/images/hotspots/safe_opened.png'}
  InteractiveHotspot({
    required super.id,
    required this.name,
    required this.description,
    required Map<String, String> imagePaths,
    required super.onInteract,
    required super.position,
    required super.size,
    this.onStateChanged,
  }) : _imagePaths = Map.from(imagePaths);
  
  /// Factory constructors for common hotspot types with AI-generated images
  
  /// 本棚ホットスポット（AI生成画像使用）
  factory InteractiveHotspot.bookshelf({
    required Function(String) onInteract,
    required Vector2 position,
    required Vector2 size,
    Function(String)? onStateChanged,
  }) {
    return InteractiveHotspot(
      id: 'bookshelf',
      name: '本棚',
      description: '本の間に何かが挟まっている',
      imagePaths: {
        'full': 'assets/images/hotspots/bookshelf_full.png',
        'empty': 'assets/images/hotspots/bookshelf_empty.png',
      },
      onInteract: onInteract,
      position: position,
      size: size,
      onStateChanged: onStateChanged,
    );
  }
  
  /// 金庫ホットスポット（AI生成画像使用）
  factory InteractiveHotspot.safe({
    required Function(String) onInteract,
    required Vector2 position,
    required Vector2 size,
    Function(String)? onStateChanged,
  }) {
    return InteractiveHotspot(
      id: 'safe',
      name: '金庫',
      description: '数字の組み合わせが必要',
      imagePaths: {
        'closed': 'assets/images/hotspots/safe_closed.png',
        'opened': 'assets/images/hotspots/safe_opened.png',
      },
      onInteract: onInteract,
      position: position,
      size: size,
      onStateChanged: onStateChanged,
    );
  }
  
  /// 箱ホットスポット（AI生成画像使用）
  factory InteractiveHotspot.box({
    required Function(String) onInteract,
    required Vector2 position,
    required Vector2 size,
    Function(String)? onStateChanged,
  }) {
    return InteractiveHotspot(
      id: 'box',
      name: '箱',
      description: '古い箱がある',
      imagePaths: {
        'closed': 'assets/images/hotspots/box_closed.png',
        'opened': 'assets/images/hotspots/box_opened.png',
      },
      onInteract: onInteract,
      position: position,
      size: size,
      onStateChanged: onStateChanged,
    );
  }
  
  /// デフォルトホットスポット（画像なし、矩形表示）
  factory InteractiveHotspot.defaultHotspot({
    required String id,
    required String name,
    required String description,
    required Function(String) onInteract,
    required Vector2 position,
    required Vector2 size,
    Function(String)? onStateChanged,
  }) {
    return InteractiveHotspot(
      id: id,
      name: name,
      description: description,
      imagePaths: {
        'default': 'assets/images/hotspots/default.png', // 存在しないパス（フォールバック表示）
      },
      onInteract: onInteract,
      position: position,
      size: size,
      onStateChanged: onStateChanged,
    );
  }
  
  @override
  String getImagePath(bool isActivated) {
    // 画像パスマップから適切な画像を選択
    if (_imagePaths.isEmpty) {
      return 'assets/images/hotspots/default.png'; // フォールバック
    }
    
    // 具体的なホットスポットタイプに応じた画像選択
    switch (id) {
      case 'bookshelf':
        return isActivated ? _imagePaths['empty']! : _imagePaths['full']!;
      case 'safe':
      case 'box':
        return isActivated ? _imagePaths['opened']! : _imagePaths['closed']!;
      default:
        // その他のホットスポットの場合
        if (_imagePaths.containsKey('activated') && _imagePaths.containsKey('default')) {
          return isActivated ? _imagePaths['activated']! : _imagePaths['default']!;
        }
        // 単一画像の場合
        return _imagePaths.values.first;
    }
  }
  
  @override
  void onInteractionCompleted() {
    debugPrint('🏠 Hotspot $id ($name) interaction completed. State: ${isActivated ? "activated" : "inactive"}');
    
    // ゲーム状態に応じた処理
    _handleGameLogic();
    
    // 外部コールバック実行
    onStateChanged?.call(id);
  }
  
  /// ゲームロジック処理
  void _handleGameLogic() {
    switch (id) {
      case 'bookshelf':
        if (isActivated) {
          debugPrint('📚 Bookshelf emptied - item may be available');
          // アイテム出現ロジック等
        }
        break;
        
      case 'safe':
        if (isActivated) {
          debugPrint('🔓 Safe opened - contents revealed');
          // アイテム取得、スコア加算等
        }
        break;
        
      case 'box':
        if (isActivated) {
          debugPrint('📦 Box opened - checking contents');
          // アイテム発見ロジック等
        }
        break;
        
      default:
        debugPrint('❓ Unknown hotspot type: $id');
        break;
    }
  }
  
  /// ホットスポット情報の取得
  Map<String, dynamic> getHotspotInfo() {
    return {
      ...getDebugInfo(),
      'name': name,
      'description': description,
      'imagePaths': _imagePaths,
      'type': _getHotspotType(),
    };
  }
  
  String _getHotspotType() {
    switch (id) {
      case 'bookshelf':
        return 'furniture';
      case 'safe':
        return 'security';
      case 'box':
        return 'container';
      case 'door':
        return 'exit';
      default:
        return 'generic';
    }
  }
  
  /// 特定条件でのインタラクション制御
  void setConditionalInteraction({
    required bool requiresItem,
    String? requiredItemId,
    String? restrictionMessage,
  }) {
    if (requiresItem && requiredItemId != null) {
      setInteractable(false);
      debugPrint('🔒 Hotspot $id locked - requires item: $requiredItemId');
      
      if (restrictionMessage != null) {
        // 制限メッセージの表示（UI側で処理）
        debugPrint('💬 Restriction message: $restrictionMessage');
      }
    }
  }
}