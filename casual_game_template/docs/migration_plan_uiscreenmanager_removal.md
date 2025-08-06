# UIScreenManager廃止・移行計画

## 移行概要

### 目的
独自実装の`UIScreenManager`を廃止し、Flame公式の`RouterComponent + OverlayRoute`に移行

### 根拠
- **公式パターン準拠**: Flame 1.30.1で確認済み
- **保守性向上**: 公式アップデートに自動追従
- **バグリスク削減**: 実証済みパターン使用

## 現状分析

### 廃止対象コード

**1. UIScreenManager (lib/framework/ui/ui_system.dart:365-459)**
```dart
class UIScreenManager extends Component {
  final Map<String, Component> _screens = {};
  final List<ModalOverlayComponent> _modals = [];
  Component? _currentScreen;
  String? _currentScreenId;
  
  void showModal(...) {
    // 独自実装ロジック ← 廃止
    if (_currentScreen != null && _currentScreen!.isMounted) {
      _currentScreen!.removeFromParent();
    }
  }
}
```

**2. ModalOverlayComponent (lib/framework/ui/ui_system.dart:254-361)**
```dart
class ModalOverlayComponent extends PositionComponent with TapCallbacks {
  // 独自モーダル実装 ← 廃止
}
```

**3. SimpleGameでの使用箇所**
```dart
class SimpleGame extends ConfigurableGame {
  late UIScreenManager _screenManager; // ← 削除
  
  void _showConfigMenu() {
    _screenManager.showModal(...); // ← RouterComponent.pushNamed()に変更
  }
}
```

## 移行手順

### Phase 1: RouterComponent導入準備

**1.1 画面コンポーネント作成**

**StartScreenComponent**:
```dart
// lib/game/screens/start_screen_component.dart
class StartScreenComponent extends PositionComponent {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // 既存の_createStartScreen()から移植
    final game = findGame() as SimpleGame;
    final config = game.configuration.config;
    
    // 背景
    final background = RectangleComponent(
      position: Vector2.zero(),
      size: game.size,
      paint: Paint()..color = Colors.indigo.withOpacity(0.3),
    );
    background.priority = UILayerPriority.background;
    add(background);
    
    // タイトル
    final titleText = TextUIComponent(
      text: config.getStateText('start'),
      styleId: 'xlarge',
      position: Vector2(game.size.x / 2, game.size.y / 2 - 50),
    );
    titleText.anchor = Anchor.center;
    add(titleText);
    
    // START GAMEボタン
    final startButton = ButtonUIComponent(
      text: 'START GAME',
      colorId: 'primary',
      position: Vector2(game.size.x / 2 - 100, game.size.y / 2 + 20),
      size: Vector2(200, 50),
      onPressed: () => game.router.pushNamed('playing'),
    );
    startButton.anchor = Anchor.topLeft;
    add(startButton);
    
    // Settingsボタン
    final settingsButton = ButtonUIComponent(
      text: 'Settings',
      colorId: 'secondary',
      position: UILayoutManager.topRight(game.size, Vector2(120, 40), 20),
      size: Vector2(120, 40),
      onPressed: () => game.router.pushNamed('settings'),
    );
    settingsButton.anchor = Anchor.topLeft;
    add(settingsButton);
  }
}
```

**PlayingScreenComponent**:
```dart
// lib/game/screens/playing_screen_component.dart
class PlayingScreenComponent extends PositionComponent {
  late TextUIComponent _timerText;
  late GameComponent _testCircle;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    final game = findGame() as SimpleGame;
    
    // 既存の_createPlayingScreen()から移植
    final background = RectangleComponent(
      position: Vector2.zero(),
      size: game.size,
      paint: Paint()..color = Colors.indigo.withOpacity(0.3),
    );
    background.priority = UILayerPriority.background;
    add(background);
    
    // タイマー表示
    _timerText = TextUIComponent(
      text: 'TIME: 5.0',
      styleId: 'xlarge',
      position: Vector2(game.size.x / 2, 50),
    );
    _timerText.anchor = Anchor.center;
    _timerText.setTextColor(Colors.white);
    add(_timerText);
    
    // ゲームオブジェクト
    _testCircle = GameComponent(
      position: Vector2(game.size.x / 2, game.size.y / 2 + 100),
      size: Vector2(80, 80),
      anchor: Anchor.center,
    );
    _testCircle.paint.color = Colors.blue;
    add(_testCircle);
  }
  
  void updateTimer(double timeRemaining) {
    if (_timerText.isMounted) {
      _timerText.setText('TIME: ${timeRemaining.toStringAsFixed(1)}');
    }
  }
}
```

**GameOverScreenComponent**:
```dart
// lib/game/screens/game_over_screen_component.dart
class GameOverScreenComponent extends PositionComponent {
  final int sessionCount;
  
  GameOverScreenComponent({required this.sessionCount});
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    final game = findGame() as SimpleGame;
    
    // 既存の_createGameOverScreen()から移植
    // ... (同様の実装)
  }
}
```

**1.2 OverlayRoute用Widget作成**

**SettingsMenuWidget**:
```dart
// lib/game/widgets/settings_menu_widget.dart
class SettingsMenuWidget extends StatelessWidget {
  final void Function(String difficulty)? onDifficultyChanged;
  final void Function()? onClosePressed;
  
  const SettingsMenuWidget({
    Key? key,
    this.onDifficultyChanged,
    this.onClosePressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 40),
          
          // 難易度選択
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['Easy', 'Default', 'Hard'].map((difficulty) {
              return ElevatedButton(
                onPressed: () => onDifficultyChanged?.call(difficulty.toLowerCase()),
                child: Text(difficulty),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              );
            }).toList(),
          ),
          
          SizedBox(height: 60),
          
          // 閉じるボタン
          ElevatedButton(
            onPressed: onClosePressed,
            child: Text('Close'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: Size(120, 40),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Phase 2: RouterComponent統合

**2.1 SimpleGame修正**

**Before (現在)**:
```dart
class SimpleGame extends ConfigurableGame {
  late UIScreenManager _screenManager; // ← 削除
  Component? _currentScreen; // ← 削除
  RectangleComponent? _currentBackground; // ← 削除
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _screenManager = UIScreenManager(); // ← 削除
    add(_screenManager);
  }
  
  void _showConfigMenu() {
    _screenManager.showModal(...); // ← 変更
  }
}
```

**After (移行後)**:
```dart
class SimpleGame extends ConfigurableGame {
  late final RouterComponent router; // ← 追加
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    router = RouterComponent(
      routes: {
        'start': Route(() => StartScreenComponent()),
        'playing': Route(() => PlayingScreenComponent()),
        'gameOver': Route(() => _createGameOverScreen()),
        'settings': OverlayRoute(_buildSettingsDialog),
      },
      initialRoute: 'start',
    );
    add(router);
  }
  
  Component _createGameOverScreen() {
    return GameOverScreenComponent(sessionCount: _sessionCount);
  }
  
  Widget _buildSettingsDialog(BuildContext context, Game game) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8), // 背景マスク
        ),
        child: Center(
          child: SettingsMenuWidget(
            onDifficultyChanged: (difficulty) {
              _applyConfiguration(difficulty);
              router.pop();
            },
            onClosePressed: () => router.pop(),
          ),
        ),
      ),
    );
  }
}
```

**2.2 状態遷移修正**

**SimpleGameStateProvider修正**:
```dart
class SimpleGameStateProvider extends GameStateProvider<GameState> {
  void startGame(double initialTime) {
    final newState = SimpleGamePlayingState(timeRemaining: initialTime);
    if (transitionTo(newState)) {
      // RouterComponentによる画面遷移
      final game = /* game instance */;
      game.router.pushNamed('playing');
    }
  }
  
  void endGame() {
    final newState = SimpleGameOverState();
    if (transitionTo(newState)) {
      final game = /* game instance */;
      game.router.pushNamed('gameOver');
    }
  }
}
```

### Phase 3: 廃止コード削除

**3.1 ファイル削除**

削除対象:
```
lib/framework/ui/ui_system.dart の以下クラス:
- UIScreenManager (line 365-459)
- ModalOverlayComponent (line 254-361) 
```

**3.2 インポート削除**

**SimpleGameから削除**:
```dart
// 削除するインポート
import '../framework/ui/ui_system.dart'; // UIScreenManager使用部分のみ削除
```

**3.3 メソッド削除**

**SimpleGameから削除**:
```dart
// 削除するメソッド
void _createStartScreen() { /* ... */ }
void _createPlayingScreen() { /* ... */ }  
void _createGameOverScreen() { /* ... */ }
void _onStateChanged() { /* ... */ } // RouterComponentが自動処理
```

## テスト戦略

### Phase 1テスト: 画面コンポーネント

**単体テスト**:
```dart
// test/game/screens/start_screen_component_test.dart
void main() {
  group('StartScreenComponent', () {
    test('should create start button', () {
      final component = StartScreenComponent();
      // ボタン存在確認テスト
    });
    
    test('should handle start button tap', () {
      // タップイベントテスト  
    });
  });
}
```

### Phase 2テスト: RouterComponent統合

**統合テスト**:
```dart
// test/game/simple_game_router_test.dart
void main() {
  group('SimpleGame RouterComponent', () {
    test('should navigate to playing screen', () {
      final game = SimpleGame();
      game.router.pushNamed('playing');
      expect(game.router.currentRoute.name, equals('playing'));
    });
    
    test('should show settings modal', () {
      final game = SimpleGame();
      game.router.pushNamed('settings');
      expect(game.router.currentRoute.name, equals('settings'));
    });
  });
}
```

### Phase 3テスト: ブラウザシミュレーション

**実動作確認**:
```bash
flutter run -d chrome
```

**確認項目**:
1. **画面遷移**: Start → Playing → GameOver
2. **モーダル表示**: Settings ボタンクリック
3. **背景遮断**: モーダル表示時の背景要素非表示
4. **モーダル閉じる**: Close ボタン、背景クリック
5. **状態保持**: 画面戻り時の状態維持

## リスク管理

### 高リスク項目

**1. 状態同期問題**
- **リスク**: RouterComponentと既存状態管理の競合
- **対策**: StateProviderとRouterの責務明確化
- **検証**: 状態遷移テストで確認

**2. タイマー更新**
- **リスク**: PlayingScreenComponentでのタイマー表示更新
- **対策**: 親から子コンポーネントへの更新メソッド提供
- **検証**: タイマー動作テストで確認

**3. ゲームオブジェクト管理**
- **リスク**: `_testCircle`等の既存オブジェクト参照
- **対策**: 各画面コンポーネント内で完結する設計
- **検証**: ゲーム動作テストで確認

### 中リスク項目

**1. 設定適用**
- **リスク**: モーダルからの設定変更処理
- **対策**: コールバック関数による疎結合
- **検証**: 設定変更テストで確認

**2. アニメーション**
- **リスク**: 既存アニメーション処理の移植
- **対策**: 各コンポーネントでのAnimationPresets活用
- **検証**: アニメーション動作確認

## 完了条件

### 必須条件（CLAUDE.md準拠）

**1. テスト成功**:
- 画面コンポーネント単体テスト: 100% PASS
- RouterComponent統合テスト: 100% PASS
- 既存機能回帰テスト: 100% PASS

**2. シミュレーション成功**:
- Chrome ブラウザでの完全動作確認
- 全画面遷移の正常動作
- モーダル表示・非表示の正常動作

**3. 問題なし確認**:
- モーダル表示時の背景要素完全遮断
- 既存機能の非劣化
- パフォーマンス非劣化

### 完了報告テンプレート

```
## UIScreenManager廃止・RouterComponent移行 完了

### 1. テスト結果
- 画面コンポーネントテスト: X件中X件成功
- RouterComponent統合テスト: X件中X件成功  
- 回帰テスト: X件中X件成功

### 2. シミュレーション結果
- 実行環境: Chrome + iOS Simulator
- 確認項目: 画面遷移、モーダル表示、既存機能
- 結果: 全項目正常動作、問題なし

### 3. 完了判定
✅ テスト成功 + ✅ シミュレーション成功 = 🎯 完了確定
```

## 実装スケジュール

### Day 1: Phase 1 (画面コンポーネント作成)
- StartScreenComponent実装・テスト
- PlayingScreenComponent実装・テスト  
- GameOverScreenComponent実装・テスト
- SettingsMenuWidget実装・テスト

### Day 2: Phase 2 (RouterComponent統合)
- SimpleGame RouterComponent導入
- 状態遷移ロジック修正
- 統合テスト実行
- ブラウザシミュレーション確認

### Day 3: Phase 3 (廃止コード削除)
- UIScreenManager削除
- ModalOverlayComponent削除
- 不要メソッド削除
- 最終テスト・確認

---

**文書バージョン**: 1.0  
**作成日**: 2025-08-01  
**対象**: UIScreenManager → RouterComponent 移行