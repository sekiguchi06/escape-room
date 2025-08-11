import 'package:casual_game_template/framework/framework.dart';

/// 使用例: 5分で作成できるシンプルな脱出ゲーム
class SimpleEscapeRoom extends QuickEscapeRoomTemplate {
  @override
  EscapeRoomConfig get gameConfig => const EscapeRoomConfig(
    timeLimit: Duration(minutes: 10),
    maxInventoryItems: 8,
    requiredItems: ['key', 'code', 'tool'],
    roomTheme: 'office',
    difficultyLevel: 1,
  );
  
  @override
  void onMessageShow(String message) {
    // カスタムメッセージ表示（オプション）
    // UIオーバーレイにメッセージを表示
    print('🔍 $message'); // デバッグ用
  }
  
  @override
  void onPuzzleSolved(String puzzleId) {
    // カスタムパズル解決処理（オプション）
    print('✅ パズル解決: $puzzleId');
  }
  
  @override
  void onEscapeSuccessful(int puzzlesSolved, double timeRemaining) {
    // 脱出成功処理（オプション）
    print('🎉 脱出成功！ パズル: $puzzlesSolved個, 残り時間: ${timeRemaining}秒');
  }
}

/// 使用例: 短時間・高難易度バージョン
class QuickEscapeChallenge extends QuickEscapeRoomTemplate {
  @override
  EscapeRoomConfig get gameConfig => const EscapeRoomConfig(
    timeLimit: Duration(minutes: 5),
    maxInventoryItems: 4,
    requiredItems: ['key', 'code'],
    roomTheme: 'vault',
    difficultyLevel: 3,
  );
}

/// 使用例: 長時間・探索重視バージョン
class DetailedEscapeRoom extends QuickEscapeRoomTemplate {
  @override
  EscapeRoomConfig get gameConfig => const EscapeRoomConfig(
    timeLimit: Duration(minutes: 20),
    maxInventoryItems: 15,
    requiredItems: ['key', 'code', 'tool', 'map', 'flashlight'],
    roomTheme: 'mansion',
    difficultyLevel: 2,
  );
}