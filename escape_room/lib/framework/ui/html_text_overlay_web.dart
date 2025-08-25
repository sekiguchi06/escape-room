// Web専用ファイル
import 'package:web/web.dart' as web;
import 'package:flutter/foundation.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// HTML要素による日本語テキスト表示コンポーネント
/// Web環境でのCanvas文字化け問題の最終解決策
class HtmlTextOverlay extends Component {
  final String text;
  final Vector2 position;
  final double fontSize;
  final Color color;
  late web.HTMLDivElement _textElement;

  HtmlTextOverlay({
    required this.text,
    required this.position,
    required this.fontSize,
    required this.color,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();
    if (kIsWeb) {
      _createHtmlElement();
    }
  }

  @override
  void onRemove() {
    if (kIsWeb) {
      _textElement.remove();
    }
    super.onRemove();
  }

  /// HTML要素を作成してDOMに追加
  void _createHtmlElement() {
    _textElement = web.HTMLDivElement()..textContent = text;

    final style = _textElement.style;
    style.position = 'absolute';
    style.left = '${position.x}px';
    style.top = '${position.y}px';
    style.fontSize = '${fontSize}px';
    style.color =
        '#${color.r.toInt().toRadixString(16).padLeft(2, '0')}${color.g.toInt().toRadixString(16).padLeft(2, '0')}${color.b.toInt().toRadixString(16).padLeft(2, '0')}';
    style.fontFamily =
        'system-ui, -apple-system, "Hiragino Sans", "Yu Gothic Medium", "Meiryo", sans-serif';
    style.pointerEvents = 'none';
    style.zIndex = '1000';
    style.whiteSpace = 'nowrap';
    style.userSelect = 'none';

    // Flutter Web のゲームcanvasに重ねて表示
    web.document.body?.appendChild(_textElement);
  }

  /// テキスト内容を更新
  void updateText(String newText) {
    if (kIsWeb) {
      _textElement.textContent = newText;
    }
  }

  /// 位置を更新
  void updatePosition(Vector2 newPosition) {
    if (kIsWeb) {
      final style = _textElement.style;
      style.left = '${newPosition.x}px';
      style.top = '${newPosition.y}px';
    }
  }
}

/// HtmlTextOverlay管理ヘルパー
class HtmlTextManager {
  static final Map<String, HtmlTextOverlay> _overlays = {};

  /// HTMLテキストオーバーレイを作成
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

  /// HTMLテキストオーバーレイを削除
  static void removeText(String id) {
    final existing = _overlays[id];
    if (existing != null) {
      existing.onRemove();
      _overlays.remove(id);
    }
  }

  /// 全てのオーバーレイをクリア
  static void clearAll() {
    for (final overlay in _overlays.values) {
      overlay.onRemove();
    }
    _overlays.clear();
  }
}
