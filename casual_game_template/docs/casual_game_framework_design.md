# カジュアルゲームフレームワーク設計書

## 概要

Flutter + Flame をベースとした**汎用カジュアルゲーム開発フレームワーク**の設計書。
月4本リリース、迅速なプロトタイピング、A/Bテスト対応を目標とした再利用可能なアーキテクチャを提供する。

## アーキテクチャ全体図

```
┌─────────────────────────────────────────────────────────────┐
│                        Application Layer                      │
├─────────────────────────────────────────────────────────────┤
│  Game Implementation (SimpleGame, PuzzleGame, ActionGame...) │
├─────────────────────────────────────────────────────────────┤
│                     Framework Core                           │
├─────────────────────────────────────────────────────────────┤
│ ConfigSystem │ StateSystem │ TimerSystem │ UISystem │ I/O   │
├─────────────────────────────────────────────────────────────┤
│              Component System (Flame-based)                  │
├─────────────────────────────────────────────────────────────┤
│         Provider (State Management) + Flutter                │
└─────────────────────────────────────────────────────────────┘
```

## フレームワーク設計原則

### 1. 汎用性 (Genericity)
- 具体的なゲームロジックに依存しない抽象化
- 型パラメータによる状態・設定の自由な定義
- プラガブルなシステム設計

### 2. 設定駆動 (Configuration-Driven)
- 外部設定ファイル・リモート設定によるゲーム制御
- A/Bテスト・リアルタイム調整への対応
- JSON/YAML形式での設定管理

### 3. 高速プロトタイピング (Rapid Prototyping)
- 最小限のコードでゲーム作成
- テンプレート・プリセットの活用
- Hot Reload対応開発環境

### 4. データドリブン (Data-Driven)
- Analytics統合
- メトリクス自動収集
- パフォーマンス監視

## コアシステム設計

### 1. 汎用設定システム (ConfigSystem)

```dart
abstract class GameConfiguration<TState, TConfig> {
  TConfig config;
  Map<TState, dynamic> stateConfigs;
  
  bool isValid();
  void updateConfig(TConfig newConfig);
  TConfig copyWith(Map<String, dynamic> overrides);
  
  // JSON/Remote Config対応
  Map<String, dynamic> toJson();
  static T fromJson<T>(Map<String, dynamic> json);
}

class ConfigurableGame<TState, TConfig> extends FlameGame {
  late GameConfiguration<TState, TConfig> configuration;
  
  void applyConfiguration(TConfig config);
  void onConfigurationChanged(TConfig oldConfig, TConfig newConfig);
}
```

### 2. 汎用状態管理システム (StateSystem)

```dart
abstract class GameState {}

class GameStateMachine<T extends GameState> extends ChangeNotifier {
  T _currentState;
  Map<Type, List<Type>> _transitions = {};
  
  T get currentState => _currentState;
  
  bool canTransitionTo<U extends T>();
  void transitionTo<U extends T>(U newState);
  void defineTransition<From extends T, To extends T>();
  
  // Analytics統合
  void trackStateTransition(T from, T to);
}

class GameStateProvider<T extends GameState> extends ChangeNotifier {
  late GameStateMachine<T> _stateMachine;
  
  // メトリクス
  int sessionCount = 0;
  int totalGames = 0;
  Duration sessionDuration = Duration.zero;
}
```

### 3. 汎用タイマーシステム (TimerSystem)

```dart
enum TimerType { countdown, countup, interval }

class TimerConfiguration {
  final Duration duration;
  final TimerType type;
  final bool autoStart;
  final void Function()? onComplete;
  final void Function(Duration remaining)? onUpdate;
}

class TimerManager extends Component {
  Map<String, GameTimer> _timers = {};
  
  void addTimer(String id, TimerConfiguration config);
  void removeTimer(String id);
  void pauseTimer(String id);
  void resumeTimer(String id);
  void updateTimerConfig(String id, TimerConfiguration config);
  
  GameTimer? getTimer(String id);
  Map<String, Duration> getTimerStates();
}

class GameTimer extends Component {
  Duration _current;
  Duration _duration;
  TimerType _type;
  bool _isRunning = false;
  
  // 設定変更対応
  void updateConfiguration(TimerConfiguration config);
}
```

### 4. 汎用UIシステム (UISystem)

```dart
abstract class UITheme {
  TextStyle getTextStyle(String styleId);
  Color getColor(String colorId);
  double getDimension(String dimensionId);
}

class ThemeManager {
  Map<String, UITheme> _themes = {};
  String _currentTheme = 'default';
  
  void registerTheme(String id, UITheme theme);
  void setTheme(String themeId);
  UITheme get currentTheme;
}

class UIComponent<T> extends PositionComponent {
  String themeId = 'default';
  Map<String, dynamic> properties = {};
  
  void updateTheme(String newThemeId);
  void setProperty(String key, dynamic value);
  T? getProperty<T>(String key);
}

class TextUIComponent extends UIComponent<String> {
  late TextComponent _textComponent;
  
  void setText(String text, {String? styleId});
  void applyTextStyle(String styleId);
}
```

### 5. 汎用入力システム (InputSystem)

```dart
abstract class InputEvent {}
class TapEvent extends InputEvent {
  final Vector2 position;
  final Duration timestamp;
}
class SwipeEvent extends InputEvent {
  final Vector2 start, end;
  final Duration duration;
}

class InputManager extends Component with TapCallbacks {
  Map<Type, List<void Function(InputEvent)>> _handlers = {};
  
  void addHandler<T extends InputEvent>(void Function(T) handler);
  void removeHandler<T extends InputEvent>(void Function(T) handler);
  void fireEvent<T extends InputEvent>(T event);
}

class GameInputComponent extends Component {
  late InputManager _inputManager;
  bool _isEnabled = true;
  
  void enable() => _isEnabled = true;
  void disable() => _isEnabled = false;
}
```

## ゲーム実装テンプレート

### 1. 基本ゲームテンプレート

```dart
// 1. 状態定義
enum SimpleGameState implements GameState { start, playing, gameOver }

// 2. 設定定義
class SimpleGameConfig {
  final Duration gameDuration;
  final Map<SimpleGameState, String> stateTexts;
  final Map<SimpleGameState, Color> stateColors;
}

// 3. ゲーム実装
class SimpleGame extends ConfigurableGame<SimpleGameState, SimpleGameConfig> {
  @override
  Future<void> onLoad() async {
    // フレームワークが自動セットアップ
    await super.onLoad();
    
    // ゲーム固有の初期化のみ記述
    setupGameSpecificComponents();
  }
  
  @override
  void onConfigurationChanged(SimpleGameConfig old, SimpleGameConfig config) {
    // 設定変更時の処理
    timerManager.updateTimerConfig('main', TimerConfiguration(
      duration: config.gameDuration,
      type: TimerType.countdown,
    ));
  }
}
```

### 2. アドバンスドゲームテンプレート

```dart
// 複雑な状態管理が必要なゲーム
class PuzzleGameState implements GameState {
  final int level;
  final int score;
  final List<PuzzlePiece> pieces;
}

class PuzzleGame extends ConfigurableGame<PuzzleGameState, PuzzleGameConfig> {
  // 複数タイマー管理
  void setupTimers() {
    timerManager.addTimer('main', TimerConfiguration(
      duration: config.levelDuration,
      onComplete: onLevelComplete,
    ));
    
    timerManager.addTimer('bonus', TimerConfiguration(
      duration: config.bonusDuration,
      type: TimerType.countdown,
      onComplete: onBonusEnd,
    ));
  }
}
```

## 開発フロー

### 1. プロトタイピングフロー (5分)
```
1. テンプレート選択 (30秒)
2. 状態・設定定義 (2分)
3. ゲームロジック実装 (2分)
4. 設定調整・テスト (30秒)
```

### 2. プロダクションフロー (1-3日)
```
Day 1: コアゲームロジック実装
Day 2: UI・エフェクト・サウンド
Day 3: バランス調整・A/Bテスト設定
```

## A/Bテスト・アナリティクス統合

### 1. A/Bテスト設定例
```json
{
  "experiments": {
    "timer_duration": {
      "variants": {
        "A": { "duration": 5000 },
        "B": { "duration": 7000 },
        "C": { "duration": 3000 }
      },
      "traffic_split": { "A": 40, "B": 40, "C": 20 }
    }
  }
}
```

### 2. 自動メトリクス収集
- セッション時間・ゲーム数
- 状態遷移トラッキング
- パフォーマンスメトリクス
- ユーザー行動分析

## フレームワーク提供機能

### 1. 開発支援
- **Hot Configuration**: リアルタイム設定変更
- **Debug UI**: 状態・設定可視化
- **Performance Monitor**: FPS・メモリ監視
- **Analytics Dashboard**: メトリクス表示

### 2. デプロイ支援
- **Remote Config**: Firebase Remote Config統合
- **A/B Testing**: Firebase A/B Testing統合
- **Analytics**: Firebase Analytics統合
- **Crash Reporting**: 自動エラー収集

### 3. 最適化
- **Asset Management**: 画像・音声の最適化
- **Memory Management**: オブジェクトプール
- **Performance Optimization**: 自動最適化

## 拡張性

### 1. プラグインシステム
```dart
abstract class GamePlugin {
  void onLoad(ConfigurableGame game);
  void onUpdate(double dt);
  void onUnload();
}

class AnalyticsPlugin implements GamePlugin {
  // Firebase Analytics統合
}

class AdPlugin implements GamePlugin {
  // 広告統合
}
```

### 2. カスタムコンポーネント
```dart
class ParticleEffectComponent extends UIComponent<ParticleConfig> {
  // カスタムエフェクト実装
}
```

## フレームワーク使用例

### タップゲーム (5分実装)
```dart
enum TapState { waiting, tapping, finished }

class TapGameConfig {
  final Duration timeLimit;
  final int targetTaps;
}

class TapGame extends ConfigurableGame<TapState, TapGameConfig> {
  int _taps = 0;
  
  @override
  void setupInputHandlers() {
    inputManager.addHandler<TapEvent>((event) {
      if (currentState == TapState.tapping) {
        _taps++;
        if (_taps >= config.targetTaps) {
          stateMachine.transitionTo(TapState.finished);
        }
      }
    });
  }
}
```

### パズルゲーム (30分実装)
```dart
class PuzzleGame extends ConfigurableGame<PuzzleState, PuzzleConfig> {
  // フレームワークが提供する基盤上で
  // パズル固有のロジックのみ実装
}
```

## まとめ

このフレームワークにより：

1. **開発速度向上**: 5分プロトタイプ、1-3日プロダクション
2. **品質保証**: ベストプラクティス組み込み済み
3. **データドリブン**: 自動メトリクス・A/Bテスト
4. **保守性**: 汎用的・拡張可能な設計
5. **スケーラビリティ**: 月4本リリース対応

ゲーム開発者は**ゲームロジックに集中**でき、フレームワークが**技術的複雑性を隠蔽**する。