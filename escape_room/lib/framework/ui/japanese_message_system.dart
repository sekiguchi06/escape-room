import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

/// 日本語メッセージ管理システム
/// インベントリシステム用の統一メッセージ管理
class JapaneseMessageSystem {
  static final Map<String, String> messages = {
    'game_start': 'ゲーム開始',
    'inventory_full': 'インベントリが満杯です',
    'item_obtained': '{item}を入手しました',
    'puzzle_solved': 'パズルを解きました！',
    'escape_success': '脱出成功！',
    'time_up': '時間切れです',
    'inventory_title': 'インベントリ',
    'inventory_empty': 'アイテムがありません',
    'item_selected': 'アイテムを選択しました',
    'item_removed': 'アイテムを削除しました',
    'item_key': '鍵',
    'item_tool': 'ドライバー',
    'item_code': 'メモ',
    'key_description': 'ドアを開ける鍵',
    'tool_description': 'ネジを外すためのドライバー',
    'code_description': '数字が書かれたメモ',
    'item_book': '本',
    'book_description': '重要な本',
    'item_box': '箱',
    'box_description': '小さな箱',
    'item_empty_shelf': '棚',
    'empty_shelf_description': '空の棚',
    // UI表示メッセージ
    'app_title': 'Escape Room - 新アーキテクチャ',
    'item_discovery_modal_title': 'アイテム発見',
    'already_examined_prefix': 'すでに調べた',
    'interaction_strategy_not_set': 'インタラクション戦略が設定されていません',
    // 具体的なアイテム発見メッセージ
    'bookshelf_discovery_message': '本の間から古い鍵を発見した！',
    'box_discovery_message': '箱の中から古い工具を発見した！',
  };

  /// メッセージを取得
  static String getMessage(String messageKey, {Map<String, String>? params}) {
    var message = messages[messageKey] ?? messageKey;

    // パラメータ置換
    if (params != null) {
      params.forEach((key, value) {
        message = message.replaceAll('{$key}', value);
      });
    }

    return message;
  }

  /// メッセージコンポーネントを作成
  static TextComponent createMessageComponent(
    String messageKey, {
    required Vector2 position,
    required double fontSize,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.normal,
    Anchor anchor = Anchor.topLeft,
    Map<String, String>? params,
  }) {
    return TextComponent(
      text: getMessage(messageKey, params: params),
      textRenderer: JapaneseFontSystem.getTextPaint(
        fontSize,
        color,
        fontWeight,
      ),
      position: position,
      anchor: anchor,
    );
  }

  /// 一時的なメッセージを表示
  static Component createTemporaryMessage(
    String messageKey, {
    required Vector2 position,
    required double fontSize,
    Color color = Colors.yellow,
    double duration = 2.0,
    Map<String, String>? params,
  }) {
    final component = createMessageComponent(
      messageKey,
      position: position,
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.bold,
      anchor: Anchor.center,
      params: params,
    );

    // フェードアウト効果を追加
    component.add(
      OpacityEffect.fadeOut(
        EffectController(duration: duration),
        onComplete: () => component.removeFromParent(),
      ),
    );

    return component;
  }

  /// インベントリ用のメッセージを取得
  static String getInventoryMessage(String itemId, String action) {
    final itemName = getMessage('item_$itemId');
    switch (action) {
      case 'obtained':
        return getMessage('item_obtained', params: {'item': itemName});
      case 'selected':
        return getMessage('item_selected', params: {'item': itemName});
      case 'removed':
        return getMessage('item_removed', params: {'item': itemName});
      default:
        return itemName;
    }
  }

  /// Flutter Widget用の統一テキスト作成
  static Text createText(
    String messageKey, {
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    Map<String, String>? params,
  }) {
    return Text(
      getMessage(messageKey, params: params),
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        fontFamily: 'Noto Sans JP', // 統一フォント
      ),
      textAlign: textAlign,
    );
  }
}

/// 日本語フォントシステム
/// プロジェクト全体で統一されたフォント設定（文字化け対策）
class JapaneseFontSystem {
  static const String fontFamily = 'Noto Sans JP';

  /// Web環境での日本語フォント設定（調査結果に基づく最適化）
  static const List<String> fontFamilyFallback = [
    // システムフォント優先（Web最適化）
    'system-ui',
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'Roboto',
    'Helvetica Neue',
    'Arial',
    // 日本語フォント
    'Noto Sans JP',
    'Hiragino Sans',
    'Hiragino Kaku Gothic ProN',
    'Yu Gothic',
    'Meiryo',
    'MS PGothic',
    // フォールバック
    'sans-serif',
  ];

  /// テキストペイントを取得（CanvasKit日本語文字化け対策）
  static TextPaint getTextPaint(
    double fontSize,
    Color color, [
    FontWeight fontWeight = FontWeight.normal,
  ]) {
    return TextPaint(
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        fontFamily: 'Noto Sans JP', // 明示的な日本語フォント指定
        fontFamilyFallback: fontFamilyFallback, // フォールバック設定追加
      ),
    );
  }

  /// インベントリ用のテキストスタイルを取得
  static TextPaint getInventoryTextStyle(double screenHeight, Color color) {
    return getTextPaint(screenHeight * 0.025, color, FontWeight.bold);
  }

  /// アイテム名用のテキストスタイルを取得
  static TextPaint getItemNameTextStyle(double itemHeight, Color color) {
    return getTextPaint(itemHeight * 0.15, color, FontWeight.bold);
  }

  /// ツールチップ用のテキストスタイルを取得
  static TextPaint getTooltipTextStyle() {
    return TextPaint(
      style: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        fontSize: 12,
        color: Colors.white,
        backgroundColor: Colors.black.withValues(alpha: 0.8),
      ),
    );
  }

  /// エラーメッセージ用のテキストスタイルを取得
  static TextPaint getErrorTextStyle(double fontSize) {
    return getTextPaint(fontSize, Colors.red, FontWeight.bold);
  }

  /// 成功メッセージ用のテキストスタイルを取得
  static TextPaint getSuccessTextStyle(double fontSize) {
    return getTextPaint(fontSize, Colors.green, FontWeight.bold);
  }
}
