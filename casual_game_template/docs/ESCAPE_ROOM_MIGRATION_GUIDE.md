# 脱出ゲーム新規フレームワーク移植ガイド

**作成日**: 2025-08-14  
**対象**: 既存escape_room_template.dart → 新規アーキテクチャへの機能移植  
**規模**: 2,303行の本格実装から8機能システムの体系的移植

## 📋 移植概要

### 🎯 移植対象
- **既存実装**: `casual_game_template/lib/framework/game_types/quick_templates/escape_room_template.dart` (削除済み)
- **新規アーキテクチャ**: Strategy Pattern + Component-based設計
- **移植範囲**: 8つの主要機能システム

### ✅ 移植済み機能
- **画像タップによる画像変化**: DualSpriteComponent実装完了
- **Strategy Pattern基盤**: InteractionStrategy・PuzzleStrategy実装完了
- **Component-based設計**: Flame Component System準拠

## 🚨 移植必須機能一覧（優先度順）

### 🔥 最高優先度（ゲーム動作に必須）

#### 1. インベントリシステム
**既存実装規模**: 約300行
**移植先**: `lib/framework/components/inventory_manager.dart` (現在90行 - 拡張必要)

**未移植機能**:
```dart
// 視覚的インベントリUI（完全未実装）
class InventoryUIComponent extends PositionComponent {
  final List<String> items;
  final String? selectedItem;
  final Function(String) onItemSelected;
  
  // スマートフォン縦型レイアウト対応
  void _setupInventoryUI();
  void _addInventoryItem(String item, Vector2 position, Vector2 size);
  void _updateItemSelection(String itemId);
}

// アイテム制限・管理システム
class InventoryManager {
  final int maxItems;                    // ✅ 実装済み
  bool hasItem(String itemId);          // ❌ 未実装
  void addItem(String itemId);          // ❌ 拡張必要
  void removeItem(String itemId);       // ❌ 未実装
  void clear();                         // ❌ 未実装
  List<String> get items;               // ❌ 未実装
}

// クリック可能アイテムコンポーネント
class ClickableInventoryItem extends RectangleComponent with TapCallbacks {
  void onTapUp(TapUpEvent event);       // タップ処理
}
```

#### 2. スマートフォン縦型レイアウトシステム
**既存実装規模**: 約200行
**移植先**: 新規ファイル `lib/framework/ui/mobile_layout_system.dart`

**未移植機能**:
```dart
// レスポンシブレイアウト計算
class MobileLayoutSystem {
  // 5分割レイアウト定義
  static const double topMenuRatio = 0.1;      // 10%: メニューバー
  static const double gameAreaRatio = 0.6;     // 60%: ゲーム領域
  static const double inventoryRatio = 0.2;    // 20%: インベントリ
  static const double bannerAdRatio = 0.1;     // 10%: 広告エリア
  
  Vector2 calculateGameArea(Vector2 screenSize);
  Vector2 calculateInventoryArea(Vector2 screenSize);
  Vector2 calculateMenuArea(Vector2 screenSize);
  Vector2 calculateAdArea(Vector2 screenSize);
}

// UI座標計算ヘルパー
class UIPositionCalculator {
  Vector2 containerSize;
  Vector2 containerOffset;
  
  Vector2 getRelativePosition(double x, double y);
  Vector2 getRelativeSize(double width, double height);
}
```

### 🔥 高優先度（ユーザー体験に必須）

#### 3. モーダルシステム
**既存実装規模**: 約400行
**移植先**: 新規ファイル `lib/framework/ui/escape_room_modal_system.dart`

**未移植機能**:
```dart
// モーダル種別定義
enum ModalType {
  item,         // アイテム詳細表示
  puzzle,       // パズル解答
  inspection    // オブジェクト詳細調査
}

// モーダル設定
class ModalConfig {
  final ModalType type;
  final String title;
  final String content;
  final Map<String, dynamic> data;     // パズル答え・ID等
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
}

// モーダルコンポーネント
class ModalComponent extends PositionComponent with TapCallbacks {
  final ModalConfig config;
  
  Future<void> show();
  void hide();
  void _setupModalUI();
  void _addConfirmButton();
  void _addCancelButton();
  void _setupNumberPuzzle();            // 数字パズル専用UI
}

// 数字パズル入力システム
class NumberPuzzleInput extends PositionComponent {
  String currentInput = '';
  String correctAnswer;
  
  void addDigit(String digit);
  bool checkAnswer();
  void reset();
}
```

#### 4. ゲーム状態管理システム
**既存実装規模**: 約100行
**移植先**: 既存 `lib/framework/state/game_state_system.dart` の拡張

**未移植機能**:
```dart
// 脱出ゲーム専用状態
enum EscapeRoomState implements GameState {
  exploring,    // 部屋探索中
  inventory,    // インベントリ確認中
  puzzle,       // パズル解答中
  escaped,      // 脱出成功
  timeUp;       // 時間切れ
}

// 状態遷移ロジック拡張
class EscapeRoomStateProvider extends GameStateProvider<EscapeRoomState> {
  void showInventory();
  void hideInventory();
  void startPuzzle(String puzzleId);
  void completePuzzle();
  void escapeSuccess();
  void timeUp();
}
```

### 🔸 中優先度（機能拡張）

#### 5. タイマー・進行管理システム
**既存実装規模**: 約150行
**移植先**: 既存 `lib/framework/timer/flame_timer_system.dart` の拡張

**未移植機能**:
```dart
// 脱出ゲーム専用タイマー
class EscapeRoomTimerSystem extends FlameTimerSystem {
  Duration timeLimit;
  double timeRemaining;
  
  void startGameTimer();
  void pauseTimer();
  void resumeTimer();
  void resetTimer();
  String formatTime(double seconds);    // MM:SS表示
  
  // 時間切れ判定
  void checkTimeUp();
}

// 進行状況管理
class ProgressManager {
  int puzzlesSolved = 0;
  int totalPuzzles;
  List<String> requiredItems;
  
  bool checkWinCondition();
  double getProgressPercentage();
  void addPuzzleSolved(String puzzleId);
}
```

#### 6. 複数エリア・ナビゲーションシステム
**既存実装規模**: 約250行
**移植先**: 新規ファイル `lib/framework/escape_room/area_navigation_system.dart`

**未移植機能**:
```dart
// エリア設定
class AreaConfig {
  final String id;
  final String name;
  final String description;
  final Map<String, String> connections; // 方向: 接続先エリアID
  final List<String> items;
}

// エリアナビゲーション管理
class AreaNavigationSystem {
  String currentAreaId = 'main';
  Map<String, AreaConfig> areas;
  Map<String, Map<String, dynamic>> areaStates; // エリア別状態保存
  
  void moveToArea(String direction);
  void switchToArea(String areaId);
  List<String> getAvailableDirections();
  void saveAreaState(String areaId);
  void loadAreaState(String areaId);
}

// 矢印ナビゲーションUI
class NavigationArrowUI extends PositionComponent with TapCallbacks {
  String direction; // 'left' or 'right'
  Function(String) onDirectionPressed;
  
  void _addArrowButton(String text, Vector2 position);
}
```

#### 7. 設定システム拡張
**既存実装規模**: 約80行
**移植先**: 既存 `lib/framework/config/game_configuration.dart` の拡張

**未移植機能**:
```dart
// 脱出ゲーム専用設定
class EscapeRoomConfig {
  final Duration timeLimit;            // ❌ 未実装
  final int maxInventoryItems;         // ❌ 未実装
  final List<String> requiredItems;    // ❌ 未実装
  final String roomTheme;              // ❌ 未実装
  final int difficultyLevel;           // ❌ 未実装
  final List<AreaConfig> areas;        // ❌ 未実装
}
```

#### 8. 日本語UI・メッセージシステム
**既存実装規模**: 約100行
**移植先**: 新規ファイル `lib/framework/ui/japanese_message_system.dart`

**未移植機能**:
```dart
// 日本語メッセージ管理
class JapaneseMessageSystem {
  static const Map<String, String> messages = {
    'game_start': 'ゲーム開始',
    'inventory_full': 'インベントリが満杯です',
    'item_obtained': 'アイテムを入手しました',
    'puzzle_solved': 'パズルを解きました！',
    'escape_success': '脱出成功！',
    'time_up': '時間切れです',
  };
  
  void showMessage(String messageKey, {Map<String, String>? params});
}

// 日本語フォント統一
class JapaneseFontSystem {
  static const String fontFamily = 'Noto Sans JP';
  static TextPaint getTextPaint(double fontSize, Color color);
}
```

## 📊 移植工数見積もり

| 機能 | 既存実装行数 | 移植工数 | 優先度 |
|------|-------------|----------|--------|
| インベントリシステム | 300行 | 4時間 | 最高 |
| スマートフォンレイアウト | 200行 | 3時間 | 最高 |
| モーダルシステム | 400行 | 5時間 | 高 |
| 状態管理拡張 | 100行 | 2時間 | 高 |
| タイマー・進行管理 | 150行 | 2時間 | 中 |
| エリアナビゲーション | 250行 | 3時間 | 中 |
| 設定システム拡張 | 80行 | 1時間 | 中 |
| 日本語UI | 100行 | 2時間 | 中 |
| **合計** | **1,580行** | **22時間** | - |

## 🔄 移植フロー推奨順序

### Phase 1: 基本機能（6時間）
1. **インベントリシステム** (4時間) - ゲーム動作の核心
2. **状態管理拡張** (2時間) - exploring/inventory/puzzle状態

### Phase 2: UI・UX（8時間）  
3. **スマートフォンレイアウト** (3時間) - 実用性確保
4. **モーダルシステム** (5時間) - パズル・調査機能

### Phase 3: 高機能（8時間）
5. **タイマー・進行管理** (2時間) - ゲーム制御
6. **エリアナビゲーション** (3時間) - 複数部屋対応
7. **設定システム拡張** (1時間) - 外部設定
8. **日本語UI** (2時間) - ローカライゼーション

## ✅ 移植完了判定基準

### 必須テスト項目
1. **インベントリ**: アイテム追加・選択・制限確認
2. **レイアウト**: スマートフォン縦画面での正常表示
3. **モーダル**: パズル入力・確認・キャンセル動作
4. **状態遷移**: exploring ↔ inventory ↔ puzzle の切り替え
5. **タイマー**: カウントダウン・時間切れ判定
6. **ナビゲーション**: エリア間移動・状態保持
7. **設定**: 時間制限・難易度の外部設定反映
8. **日本語**: 文字化けなし・フォント正常表示

### 動作確認環境
- **ブラウザ**: Chrome・Safari
- **実機**: iOS・Android
- **画面**: 縦型・レスポンシブ確認

## 📚 関連ドキュメント
- [ESCAPE_ROOM_UNIFIED_DESIGN_GUIDE.md](ESCAPE_ROOM_UNIFIED_DESIGN_GUIDE.md) - 新規アーキテクチャ設計
- [AI_MASTER.md](AI_MASTER.md) - プロジェクト全体情報
- [CLAUDE.md](CLAUDE.md) - AI開発ルール・品質基準