# インベントリシステム実装戦略

**作成日**: 2025-08-14  
**対象**: 新規Escape Roomフレームワークへのインベントリシステム移植  
**基準**: Flutter・Flame公式ドキュメント + 新規アーキテクチャ設計ガイド準拠

## 🎯 実装方針概要

### ✅ 基盤確認結果
1. **InventoryManager**: 基本機能実装済み（90行）
2. **UI基盤**: UILayoutManager・UILayerPriority実装済み
3. **Component基盤**: InteractiveHotspot・ClickableInventoryItem実装済み
4. **アーキテクチャ準拠**: Composition over Inheritance・Component-based設計確立

### 🏗️ 採用アーキテクチャ

#### Component-based設計（Flame FCS準拠）
```dart
// レイヤー構造
┌─ InventoryUIComponent (表示レイヤー)
├─ InventoryItemComponent (アイテム個別コンポーネント) 
├─ InventoryManager (データ管理レイヤー)
└─ GameItem (データモデル)
```

#### 責任分離原則
- **InventoryManager**: データ管理・ビジネスロジック専任
- **InventoryUIComponent**: UI描画・レイアウト専任  
- **InventoryItemComponent**: 個別アイテムUI・イベント専任
- **ResponsiveLayoutCalculator**: 画面サイズ対応専任

#### Composition over Inheritance
- 継承階層: 最大2層（PositionComponent → 具象クラス）
- 機能拡張: Mixinとコンポーネント組み合わせ
- Strategy Pattern: アイテム表示戦略の切り替え対応

## 📱 スマートフォン縦型レイアウト設計

### レスポンシブ対応方針
```dart
// 既存のUILayoutManagerを拡張
class MobileInventoryLayoutManager extends UILayoutManager {
  // 縦型5分割レイアウト準拠
  static const double inventoryAreaRatio = 0.2; // 20%エリア
  static const int maxItemsPerRow = 4;          // 横並び最大数
  static const double itemSpacing = 0.05;      // アイテム間隔
  
  Vector2 calculateInventoryArea(Vector2 screenSize);
  Vector2 calculateItemPosition(int index, Vector2 inventoryArea);
  Vector2 calculateItemSize(Vector2 inventoryArea, int itemCount);
}
```

### UI Priority Management
```dart
// 既存UILayerPriorityを拡張
class InventoryUILayerPriority extends UILayerPriority {
  static const int inventoryBackground = ui + 10;     // 210
  static const int inventoryItems = ui + 20;          // 220  
  static const int selectedItem = ui + 30;            // 230
  static const int itemTooltip = tooltip;             // 500
}
```

## 🔧 実装すべきコンポーネント

### 1. InventoryUIComponent（メインUI）
```dart
class InventoryUIComponent extends PositionComponent with HasVisibility {
  final InventoryManager manager;
  final Vector2 screenSize;
  String? selectedItemId;
  
  // Flame Component System準拠
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _setupInventoryLayout();
    _setupItemComponents();
  }
  
  @override 
  void update(double dt) {
    super.update(dt);
    _updateItemStates();
  }
  
  // 責任: UI全体レイアウト・状態同期
  void _setupInventoryLayout();
  void _createInventoryBackground();
  void _addNavigationArrows();
  void refreshUI();
}
```

### 2. InventoryItemComponent（個別アイテム）
```dart
class InventoryItemComponent extends PositionComponent with TapCallbacks {
  final String itemId;
  final GameItem item;
  final Function(String) onItemTapped;
  bool isSelected = false;
  
  // Flame TapCallbacks準拠
  @override
  void onTapUp(TapUpEvent event) {
    onItemTapped(itemId);
    // 継続非伝播（Flame推奨）
  }
  
  // 責任: 個別アイテム表示・選択状態・タップ処理
  void updateSelectionState(bool selected);
  void _renderItemIcon();
  void _renderSelectionIndicator();
}
```

### 3. ResponsiveLayoutCalculator（レイアウト計算）
```dart
class ResponsiveLayoutCalculator {
  final Vector2 screenSize;
  final int maxItems;
  
  // 単一責任: 座標・サイズ計算専任
  List<Vector2> calculateItemPositions(int itemCount);
  Vector2 calculateItemSize(int itemCount);  
  Vector2 calculateInventoryArea();
  bool shouldShowScrollIndicator();
  
  // スマートフォン縦型特化
  static const _mobilePortraitRatios = {
    'inventoryArea': 0.2,
    'itemSpacing': 0.05,
    'marginRatio': 0.02,
  };
}
```

### 4. InventoryStateNotifier（状態管理）
```dart
// Flutter状態管理原則準拠
class InventoryStateNotifier extends ChangeNotifier {
  String? _selectedItemId;
  final InventoryManager _manager;
  
  // 状態変更通知（Flutter推奨パターン）  
  void selectItem(String itemId) {
    _selectedItemId = itemId;
    notifyListeners();
  }
  
  void addItem(String itemId) {
    if (_manager.addItem(itemId)) {
      notifyListeners();
    }
  }
}
```

## 🎨 視覚的設計方針

### 日本語フォント統合
```dart
// 既存のテーマシステム活用
class InventoryTextStyles {
  static TextPaint getItemNameStyle(Vector2 screenSize) {
    return TextPaint(
      style: TextStyle(
        fontFamily: 'Noto Sans JP',  // プロジェクト標準
        fontSize: screenSize.y * 0.02,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
```

### AI生成画像統合
```dart
// 既存のアセット管理パターン準拠
class InventoryIconManager {
  static const Map<String, String> itemIconPaths = {
    'key': 'assets/images/items/key.png',
    'tool': 'assets/images/items/tool.png', 
    'code': 'assets/images/items/code.png',
  };
  
  Future<SpriteComponent> createItemIcon(String itemId, Vector2 size);
}
```

## 🧪 テスト戦略

### 必須テスト項目
1. **コンポーネントライフサイクル**: onLoad・onMount・update・render
2. **レスポンシブレイアウト**: 異なる画面サイズでの正常表示
3. **タップ処理**: アイテム選択・選択状態表示
4. **データ同期**: InventoryManager ↔ UI状態同期
5. **パフォーマンス**: 大量アイテム時のフレームレート維持

### テスト実装例
```dart
// Flame Test準拠
testWithFlameGame('inventory UI displays items correctly', (game) async {
  final inventory = InventoryManager(maxItems: 4, onItemSelected: (_) {});
  inventory.addItem('key');
  inventory.addItem('tool');
  
  final ui = InventoryUIComponent(
    manager: inventory,
    screenSize: Vector2(400, 600),
  );
  
  await game.add(ui);
  await game.ready();
  
  // UI表示確認
  expect(ui.children.length, greaterThan(0));
  expect(find.text('アイテム'), findsOneWidget);
});
```

## ⚡ 実装優先順序

### Phase 1: 基盤実装（1時間）
1. **ResponsiveLayoutCalculator**: 座標計算ロジック
2. **InventoryUIComponent**: 基本レイアウト・背景

### Phase 2: コア機能（2時間）  
3. **InventoryItemComponent**: 個別アイテム表示・タップ
4. **状態同期**: Manager ↔ UI連携

### Phase 3: 高度機能（1時間）
5. **選択状態表示**: 視覚的フィードバック
6. **日本語対応**: フォント・メッセージ表示

## 🚫 避けるべき実装パターン

### アンチパターン
```dart
❌ // 単一巨大クラス（200行超）
class MassiveInventoryComponent extends PositionComponent {
  // データ管理 + UI描画 + イベント処理 + レイアウト計算
}

❌ // 深い継承階層（3層超）  
class BaseInventory -> AbstractInventory -> ConcreteInventory

❌ // switch文による分岐制御
void onItemTapped(String itemId) {
  switch (itemId) {
    case 'key': handleKey(); break;
    case 'tool': handleTool(); break;
  }
}
```

### 推奨パターン
```dart
✅ // Component組み合わせ
final inventory = InventoryUIComponent()
  ..add(InventoryLayoutManager())
  ..add(InventoryItemRenderer())
  ..add(TapEventHandler());

✅ // Strategy Pattern
interface ItemDisplayStrategy {
  void display(GameItem item, Vector2 position);
}

✅ // 責任分離
class InventoryController {  // データ制御専任
class InventoryView {        // UI表示専任  
class InventoryEvents {      // イベント処理専任
```

## 📊 期待される成果

### 定量目標
- **実装規模**: 300行 → 4個のクラス（各75行以下）
- **テスト成功率**: 100%（5項目全て）
- **パフォーマンス**: 60fps維持（8アイテム表示時）
- **レスポンシブ**: 320px～1024px対応

### 定性目標
- **保守性**: 単一責任原則によるメンテナンス性向上
- **拡張性**: 新アイテム追加の容易性
- **互換性**: 既存フレームワークとの完全統合
- **品質**: Flutter・Flame公式ガイドライン100%準拠

この戦略に基づいて、新規フレームワークの設計原則を維持しながら、既存の高機能インベントリシステムを段階的に移植します。