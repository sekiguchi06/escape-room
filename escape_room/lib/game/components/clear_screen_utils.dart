import '../components/inventory_system.dart';

/// クリア画面のユーティリティ関数群
class ClearScreenUtils {
  /// クリア時間を文字列形式に変換
  static String formatClearTime(Duration? clearTime) {
    if (clearTime == null) return '';
    final minutes = clearTime.inMinutes;
    final seconds = clearTime.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// ゲームデータをリセットしてホームに戻る
  static void resetGameDataAndGoHome(void Function() onHomePressed) {
    // インベントリをクリア
    InventorySystem().resetToInitialState();

    // ホーム画面に戻る
    onHomePressed();
  }
}
