import 'package:casual_game_template/framework/framework.dart';

/// 脱出ゲーム用のGameConfiguration実装
class EscapeRoomConfiguration extends GameConfiguration<EscapeRoomState, EscapeRoomConfig> {
  EscapeRoomConfiguration(EscapeRoomConfig config) : super(config: config);
  
  @override
  bool isValid() => config.timeLimit.inSeconds > 0;
  
  @override
  bool isValidConfig(EscapeRoomConfig config) => config.timeLimit.inSeconds > 0;
  
  @override
  EscapeRoomConfig copyWith(Map<String, dynamic> overrides) {
    return EscapeRoomConfig(
      timeLimit: Duration(minutes: overrides['timeLimit'] ?? config.timeLimit.inMinutes),
      maxInventoryItems: overrides['maxInventoryItems'] ?? config.maxInventoryItems,
      requiredItems: List<String>.from(overrides['requiredItems'] ?? config.requiredItems),
      roomTheme: overrides['roomTheme'] ?? config.roomTheme,
      difficultyLevel: overrides['difficultyLevel'] ?? config.difficultyLevel,
    );
  }
  
  @override
  Map<String, dynamic> toJson() => {
    'timeLimit': config.timeLimit.inMinutes,
    'maxInventoryItems': config.maxInventoryItems,
    'requiredItems': config.requiredItems,
    'roomTheme': config.roomTheme,
    'difficultyLevel': config.difficultyLevel,
  };
}

/// App Store公開用: バランス調整済み脱出ゲーム（カジュアルユーザー向け）
class SimpleEscapeRoom extends QuickEscapeRoomTemplate {
  @override
  EscapeRoomConfig get gameConfig => const EscapeRoomConfig(
    timeLimit: Duration(minutes: 4),      // 適度な緊張感・カジュアル向け
    maxInventoryItems: 6,                 // 操作しやすいインベントリサイズ  
    requiredItems: ['key', 'code', 'tool'], // 達成感のある3アイテム
    roomTheme: 'escape_room',             // わかりやすいテーマ名
    difficultyLevel: 2,                   // 中程度の難易度（カジュアル向け）
    areas: [                               // 複数エリア設定
      AreaConfig(
        id: 'main',
        name: 'メインルーム',
        description: '広い部屋。いくつかのドアが見える。',
        connections: {
          'east': 'storage',
          'west': 'office',
        },
        items: ['tool'],
      ),
      AreaConfig(
        id: 'storage',
        name: '物置部屋',
        description: '薄暗い物置部屋。何か隠されているかも。',
        connections: {
          'west': 'main',
        },
        items: ['code'],
      ),
      AreaConfig(
        id: 'office',
        name: 'オフィス',
        description: '整理されたオフィス。金庫がある。',
        connections: {
          'east': 'main',
        },
        items: ['key'],
      ),
    ],
  );
  
  @override
  GameStateProvider<EscapeRoomState> createStateProvider() {
    return GameStateProvider<EscapeRoomState>(EscapeRoomState.exploring);
  }
  
  @override
  Future<void> initializeGame() async {
    // 脱出ゲーム初期化処理
    print('🎯 脱出ゲーム初期化開始');
    
    // 設定初期化
    configuration = EscapeRoomConfiguration(gameConfig);
  }
  
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
  
  @override
  GameStateProvider<EscapeRoomState> createStateProvider() {
    return GameStateProvider<EscapeRoomState>(EscapeRoomState.exploring);
  }
  
  @override
  Future<void> initializeGame() async {
    print('🏦 金庫脱出ゲーム初期化');
  }
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
  
  @override
  GameStateProvider<EscapeRoomState> createStateProvider() {
    return GameStateProvider<EscapeRoomState>(EscapeRoomState.exploring);
  }
  
  @override
  Future<void> initializeGame() async {
    print('🏰 屋敷脱出ゲーム初期化');
  }
}