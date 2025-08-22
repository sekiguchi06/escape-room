import 'package:flutter/material.dart';

/// クリア画面でのアプリ評価ダイアログ管理
class ClearScreenRatingDialog {
  /// アプリ評価ダイアログを表示
  static Future<void> showAppRatingDialog(BuildContext context) async {
    if (!context.mounted) return;

    try {
      // TODO: 実際のネイティブ評価機能（要パッケージ追加）
      // final InAppReview inAppReview = InAppReview.instance;
      // if (await inAppReview.isAvailable()) {
      //   inAppReview.requestReview();
      // }

      // シミュレータ用のテスト用ダイアログ
      _showTestRatingDialog(context);
    } catch (e) {
      debugPrint('評価ダイアログエラー: $e');
      _showTestRatingDialog(context);
    }
  }

  /// テスト用評価ダイアログを表示（開発用）
  static void _showTestRatingDialog(BuildContext context) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown[800],
        title: Text(
          '⭐ アプリ評価（開発用テスト）',
          style: TextStyle(
            color: Colors.amber[200],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '本番環境では、ここでネイティブの評価ダイアログが表示されます。\n\n'
          '📱 iOS: StoreKit RequestReview\n'
          '🤖 Android: In-App Review API\n\n'
          '🔧 ネイティブ評価への切り替え方法:\n'
          '1. pubspec.yamlにin_app_reviewパッケージを追加\n'
          '2. premium_clear_screen.dartのコメントアウトを解除\n\n'
          '詳細: プロジェクト内のNATIVE_RATING_SETUP.mdを参照',
          style: TextStyle(color: Colors.brown[100], height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.amber[300]),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}
