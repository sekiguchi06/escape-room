# UI架構設計 - 公式パターン準拠

## 設計検証結果

### 検証日時
2025-08-01

### 検証方法
1. **公式ドキュメント確認**: https://docs.flame-engine.org/latest/flame/router.html
2. **ソースコード確認**: `/Users/sekiguchi/.pub-cache/hosted/pub.dev/flame-1.30.1/lib/src/components/router/`
3. **Web調査**: GitHub examples, Google Codelabs, 実装事例

### 検証結果
**Flame 1.30.1においてRouterComponent + OverlayRouteが公式推奨UI管理パターンであることを確認**

## 現在の問題

### ❌ 独自実装の問題点

**現在のUIScreenManager**:
```dart
class UIScreenManager extends Component {
  void showModal(...) {
    // 独自の画面非表示ロジック
    if (_currentScreen != null && _currentScreen!.isMounted) {
      _currentScreen!.removeFromParent(); // ← 公式パターンではない
    }
  }
}
```

**問題**:
1. **車輪の再発明**: 公式RouterComponentが存在するのに独自実装
2. **保守性**: 公式アップデートに追従できない
3. **バグリスク**: 独自ロジックによる予期しない動作
4. **学習コスト**: 他開発者が理解困難

## 公式設計パターン

### ✅ RouterComponent + OverlayRoute

**Flame 1.30.1公式アーキテクチャ**:
```dart
class SimpleGame extends ConfigurableGame {
  late final RouterComponent router;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // 公式RouterComponent使用
    router = RouterComponent(
      routes: {
        // 通常画面（不透明）
        'start': Route(() => StartScreen()),
        'playing': Route(() => PlayingScreen()),
        'gameOver': Route(() => GameOverScreen()),
        
        // モーダル（透明）
        'settings': OverlayRoute((context, game) => SettingsDialog()),
        'pause': OverlayRoute((context, game) => PauseDialog()),
        'confirm': OverlayRoute((context, game) => ConfirmDialog()),
      },
      initialRoute: 'start',
    );
    
    add(router);
  }
}
```

### 技術仕様

#### 1. Route Types

**通常画面 (Route)**:
```dart
'start': Route(() => StartScreen(), transparent: false), // デフォルト
```
- **不透明**: 下の画面は描画されない
- **イベント遮断**: 下の画面はタップイベントを受信しない
- **用途**: メイン画面、ゲーム画面

**モーダル (OverlayRoute)**:
```dart
'settings': OverlayRoute(
  (context, game) => SettingsDialog(),
  transparent: true, // デフォルト
),
```
- **透明**: 下の画面が描画される
- **イベント制御可能**: 背景タップでモーダル閉じる実装可能
- **用途**: 設定画面、確認ダイアログ、ポーズメニュー

#### 2. Navigation API

**画面遷移**:
```dart
// 通常遷移
router.pushNamed('playing');

// モーダル表示
router.pushNamed('settings');

// モーダル閉じる
router.pop();

// 値を返すモーダル
final result = await router.pushAndWait(ConfirmRoute());
```

#### 3. State Management

**自動状態管理**:
```dart
Route(() => PlayingScreen(), maintainState: true), // デフォルト
```
- **maintainState: true**: 画面状態を保持（推奨）
- **maintainState: false**: 毎回新規作成

#### 4. Event Handling

**背景タップ処理**:
```dart
class SettingsDialog extends PositionComponent with TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) {
    // モーダル内タップ
    event.handled = true; // イベント伝播停止
  }
}

class ModalBackground extends RectangleComponent with TapCallbacks {
  @override  
  void onTapDown(TapDownEvent event) {
    // 背景タップでモーダル閉じる
    findGame().router.pop();
    event.handled = true;
  }
}
```

## 実装ガイド

### Phase 1: RouterComponent導入

**1. SimpleGameの修正**:
```dart
class SimpleGame extends ConfigurableGame {
  late final RouterComponent router;
  
  // 独自UIScreenManager削除
  // late UIScreenManager _screenManager; ← 削除
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    router = RouterComponent(
      routes: _createRoutes(),
      initialRoute: 'start',
    );
    add(router);
  }
  
  Map<String, Route> _createRoutes() {
    return {
      'start': Route(() => StartScreenComponent()),
      'playing': Route(() => PlayingScreenComponent()),  
      'gameOver': Route(() => GameOverScreenComponent()),
      'settings': OverlayRoute(_buildSettingsDialog),
    };
  }
  
  Widget _buildSettingsDialog(BuildContext context, Game game) {
    return Center(
      child: SettingsMenuWidget(
        onDifficultyChanged: (difficulty) {
          _applyConfiguration(difficulty);
          router.pop();
        },
        onClosePressed: () => router.pop(),
      ),
    );
  }
}
```

**2. 画面コンポーネント化**:
```dart
class StartScreenComponent extends PositionComponent {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // 既存の_createStartScreen()ロジックを移植
    final startButton = ButtonUIComponent(
      text: 'START GAME',
      onPressed: () => findGame().router.pushNamed('playing'),
    );
    add(startButton);
    
    final settingsButton = ButtonUIComponent(
      text: 'Settings',
      onPressed: () => findGame().router.pushNamed('settings'),
    );
    add(settingsButton);
  }
}
```

### Phase 2: 独自UIScreenManager除去

**削除対象**:
```dart
// lib/framework/ui/ui_system.dart
class UIScreenManager extends Component { // ← 完全削除
class ModalOverlayComponent extends PositionComponent { // ← 完全削除
```

**移行手順**:
1. `_screenManager`フィールド削除
2. `_showConfigMenu()`をOverlayRoute使用に変更
3. 画面作成メソッド（`_createStartScreen`等）をComponentクラス化
4. `_currentScreen`、`_currentBackground`管理をRouterComponentに委譲

### Phase 3: ValueRoute対応

**確認ダイアログ実装**:
```dart
class ConfirmRoute extends ValueRoute<bool> {
  final String message;
  
  ConfirmRoute(this.message);
  
  @override
  Component build() {
    return ConfirmDialog(
      message: message,
      onYes: () => completeWith(true),
      onNo: () => completeWith(false),
    );
  }
}

// 使用例
final confirmed = await router.pushAndWait(ConfirmRoute('ゲームを終了しますか？'));
if (confirmed) {
  // 終了処理
}
```

## 品質保証

### テスト要件

**1. 単体テスト**:
```dart
test('RouterComponent navigation', () {
  final router = RouterComponent(
    routes: {'home': Route(() => Component())},
    initialRoute: 'home',
  );
  
  router.pushNamed('settings');
  expect(router.currentRoute.name, equals('settings'));
});
```

**2. 統合テスト**:
```dart
testWidgets('Modal overlay functionality', (tester) async {
  await tester.pumpWidget(GameWidget(game: SimpleGame()));
  
  // Settings ボタンタップ
  await tester.tap(find.text('Settings'));
  await tester.pump();
  
  // モーダル表示確認
  expect(find.text('Settings'), findsOneWidget);
  
  // 背景タップでモーダル閉じる
  await tester.tapAt(Offset(50, 50));
  await tester.pump();
  
  // モーダル非表示確認
  expect(find.text('Settings'), findsNothing);
});
```

**3. ブラウザシミュレーション**:
```bash
flutter run -d chrome
```
- モーダル表示時の背景要素完全遮断
- Settings ボタン正常動作
- 画面遷移の正常動作

## 完了定義

### 必須条件（CLAUDE.md準拠）

**1. テスト成功**:
- 単体テスト: 100% PASS
- 統合テスト: 100% PASS
- パフォーマンステスト: 目標値達成

**2. シミュレーション成功**:
- Chrome ブラウザでの実動作確認
- iOS Simulator での実動作確認  
- 全UI操作の正常動作

**3. 問題なし確認**:
- モーダル表示時の背景要素完全遮断
- 適切な画面遷移動作
- メモリリークなし

### 完了報告テンプレート

```
## RouterComponent UI Architecture 実装完了

### 1. テスト結果
- 単体テスト: 15件中15件成功
- 統合テスト: 8件中8件成功
- パフォーマンステスト: 目標値達成

### 2. シミュレーション結果
- 実行環境: Chrome + iOS Simulator
- 確認項目: 画面遷移、モーダル表示、タップ処理
- 結果: 全項目正常動作

### 3. 完了判定
✅ テスト成功 + ✅ シミュレーション成功 = 🎯 完了確定
```

## 技術的利点

### 1. 公式準拠
- **アップデート対応**: Flame更新に自動追従
- **バグ修正**: 公式メンテナンスの恩恵
- **コミュニティサポート**: 標準パターンによる情報共有

### 2. 開発効率
- **学習コスト削減**: 公式ドキュメント参照可能
- **実装時間短縮**: 実証済みパターン使用
- **デバッグ容易**: 標準的な問題解決方法

### 3. 保守性
- **責務明確**: RouterComponentが画面管理を担当
- **拡張容易**: 新画面・モーダル追加が簡単
- **テスト容易**: 各画面コンポーネントの独立テスト

## 参考資料

- **Flame公式**: https://docs.flame-engine.org/latest/flame/router.html
- **ソースコード**: `/Users/sekiguchi/.pub-cache/hosted/pub.dev/flame-1.30.1/lib/src/components/router/`
- **実装例**: Google Codelabs - Introduction to Flame with Flutter
- **GitHub**: https://github.com/flame-engine/flame/tree/main/examples

---

**文書バージョン**: 1.0  
**作成日**: 2025-08-01  
**検証済みFlameバージョン**: 1.30.1