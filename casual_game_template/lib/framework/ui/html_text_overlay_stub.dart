// iOS/Android用スタブファイル
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// HTML要素による日本語テキスト表示コンポーネント（スタブ版）
/// iOS/Android環境では何もしない
class HtmlTextOverlay extends Component {
  final String text;
  final Vector2 position;
  final double fontSize;
  final Color color;
  
  HtmlTextOverlay({
    required this.text,
    required this.position,
    required this.fontSize,
    required this.color,
  });
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    // iOS/Androidでは何もしない
  }
  
  @override
  void onRemove() {
    super.onRemove();
    // iOS/Androidでは何もしない
  }
  
  /// テキスト内容を更新（スタブ）
  void updateText(String newText) {
    // iOS/Androidでは何もしない
  }
  
  /// 位置を更新（スタブ）
  void updatePosition(Vector2 newPosition) {
    // iOS/Androidでは何もしない
  }
}

/// HtmlTextOverlay管理ヘルパー（スタブ版）
class HtmlTextManager {
  static final Map<String, HtmlTextOverlay> _overlays = {};
  
  /// HTMLテキストオーバーレイを作成（スタブ）
  static HtmlTextOverlay createText({
    required String id,
    required String text,
    required Vector2 position,
    required double fontSize,
    required Color color,
  }) {
    // 既存のオーバーレイを削除
    removeText(id);
    
    final overlay = HtmlTextOverlay(
      text: text,
      position: position,
      fontSize: fontSize,
      color: color,
    );
    
    _overlays[id] = overlay;
    return overlay;
  }
  
  /// HTMLテキストオーバーレイを削除（スタブ）
  static void removeText(String id) {
    final existing = _overlays[id];
    if (existing != null) {
      existing.onRemove();
      _overlays.remove(id);
    }
  }
  
  /// 全てのオーバーレイをクリア（スタブ）
  static void clearAll() {
    for (final overlay in _overlays.values) {
      overlay.onRemove();
    }
    _overlays.clear();
  }
}