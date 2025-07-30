# カジュアルゲーム開発フレームワーク API リファレンス

## 目次

1. [状態管理API](#1-状態管理api)
2. [設定管理API](#2-設定管理api)
3. [タイマーシステムAPI](#3-タイマーシステムapi)
4. [UIシステムAPI](#4-uiシステムapi)
5. [フレームワーク統合API](#5-フレームワーク統合api)
6. [実装例](#6-実装例)
7. [制約・注意事項](#7-制約注意事項)
8. [パフォーマンス最適化](#8-パフォーマンス最適化)

---

## 1. 状態管理API

### GameState

ゲーム状態の基底クラス。すべてのゲーム状態はこのクラスを継承する。

#### 抽象メソッド

```dart
abstract class GameState {
  const GameState();
  
  /// 状態の一意な名前
  String get name;
  
  /// 状態の詳細説明（オプション）
  String get description => name;
  
  /// 状態データのJSON表現
  Map<String, dynamic> toJson() => {
    'name': name, 
    'description': description
  };
}
```

#### 実装例

```dart
class MyGameStartState extends GameState {
  const MyGameStartState() : super();
  
  @override
  String get name => 'start';
  
  @override
  String get description => 'ゲーム開始待ち状態';
}

class MyGamePlayingState extends GameState {
  final double timeRemaining;
  final int level;
  
  const MyGamePlayingState({
    required this.timeRemaining,
    required this.level,
  }) : super();
  
  @override
  String get name => 'playing';
  
  @override
  String get description => 'プレイ中 (レベル$level, 残り${timeRemaining.toStringAsFixed(1)}秒)';
  
  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'timeRemaining': timeRemaining,
    'level': level,
  };
  
  @override
  bool operator ==(Object other) =>
      other is MyGamePlayingState &&
      other.timeRemaining == timeRemaining &&
      other.level == level;
  
  @override
  int get hashCode => Object.hash(name, timeRemaining, level);
}
```

### StateTransition<T>

状態遷移の定義クラス。

#### コンストラクタ

```dart
StateTransition({
  required Type fromState,        // 遷移元の状態型
  required Type toState,          // 遷移先の状態型
  bool Function(T current, T target)? condition,  // 遷移条件
  void Function(T from, T to)? onTransition,      // 遷移時コールバック
})
```

#### メソッド

```dart
/// 指定された状態間の遷移が可能かチェック
bool canTransition(T current, T target)
```

#### 実装例

```dart
final transitions = [
  // 開始 → プレイ中
  StateTransition<GameState>(
    fromState: MyGameStartState,
    toState: MyGamePlayingState,
    condition: (current, target) => 
        current is MyGameStartState && target is MyGamePlayingState,
    onTransition: (from, to) {
      final playing = to as MyGamePlayingState;
      print('ゲーム開始: レベル${playing.level}');
    },
  ),
  
  // プレイ中 → プレイ中 (進捗更新)
  StateTransition<GameState>(
    fromState: MyGamePlayingState,
    toState: MyGamePlayingState,
    condition: (current, target) => 
        current is MyGamePlayingState && target is MyGamePlayingState,
    onTransition: (from, to) {
      final fromPlaying = from as MyGamePlayingState;
      final toPlaying = to as MyGamePlayingState;
      if (toPlaying.level > fromPlaying.level) {
        print('レベルアップ: ${fromPlaying.level} → ${toPlaying.level}');
      }
    },
  ),
];
```

### GameStateMachine<T>

状態遷移の実行エンジン。

#### プロパティ

```dart
T get currentState              // 現在の状態
List<StateTransition<T>> get transitions  // 定義済み遷移リスト
```

#### メソッド

```dart
/// 状態遷移を実行
bool transitionTo(T newState)

/// 状態遷移の可能性をチェック
bool canTransitionTo(T newState)

/// 単一の遷移を定義
void defineTransition(StateTransition<T> transition)

/// 複数の遷移を一括定義
void defineTransitions(List<StateTransition<T>> transitions)

/// 状態を強制設定（テスト用）
void forceSetState(T newState)
```

#### 実装例

```dart
final stateMachine = GameStateMachine<GameState>(MyGameStartState());

// 遷移定義
stateMachine.defineTransitions([
  StateTransition<GameState>(
    fromState: MyGameStartState,
    toState: MyGamePlayingState,
  ),
]);

// 遷移実行
final success = stateMachine.transitionTo(MyGamePlayingState(
  timeRemaining: 60.0,
  level: 1,
));

if (success) {
  print('遷移成功: ${stateMachine.currentState.name}');
}
```

### GameStateProvider<T>

Provider統合とセッション管理を提供。

#### プロパティ

```dart
T get currentState                    // 現在の状態
GameStateMachine<T> get stateMachine  // 状態マシン
int get sessionCount                  // セッション数
Duration get sessionDuration          // セッション継続時間
List<StateTransitionRecord<T>> get transitionHistory  // 遷移履歴
```

#### メソッド

```dart
/// 状態遷移を実行（Provider通知付き）
bool transitionTo(T newState)

/// 遷移可能性チェック
bool canTransitionTo(T newState)

/// 新しいセッションを開始
void startNewSession()

/// 統計情報を取得
StateStatistics getStatistics()
```

#### 実装例

```dart
class MyGameStateProvider extends GameStateProvider<GameState> {
  MyGameStateProvider() : super(MyGameStartState()) {
    _setupTransitions();
  }
  
  void _setupTransitions() {
    stateMachine.defineTransitions([
      StateTransition<GameState>(
        fromState: MyGameStartState,
        toState: MyGamePlayingState,
        onTransition: (from, to) => startNewSession(),
      ),
    ]);
  }
  
  /// ゲーム開始
  bool startGame({required int level, required double timeLimit}) {
    return transitionTo(MyGamePlayingState(
      timeRemaining: timeLimit,
      level: level,
    ));
  }
  
  /// 進捗更新
  bool updateProgress(double timeRemaining, int level) {
    if (currentState is! MyGamePlayingState) return false;
    
    return transitionTo(MyGamePlayingState(
      timeRemaining: timeRemaining,
      level: level,
    ));
  }
}

// 使用例
final stateProvider = MyGameStateProvider();

// Provider登録
ChangeNotifierProvider<MyGameStateProvider>(
  create: (_) => stateProvider,
  child: MyGameApp(),
)

// Widget内での使用
Consumer<MyGameStateProvider>(
  builder: (context, provider, child) {
    return Text('現在の状態: ${provider.currentState.description}');
  },
)
```

### StateStatistics

状態統計情報クラス。

#### プロパティ

```dart
String currentState;                    // 現在の状態名
int sessionCount;                       // セッション数
int totalStateChanges;                  // 総状態変更数
Duration sessionDuration;               // セッション継続時間
String mostVisitedState;                // 最多訪問状態
double averageStateTransitionsPerSession;  // セッション平均遷移数
Map<String, int> stateVisitCounts;      // 状態別訪問数
```

---

## 2. 設定管理API

### GameConfiguration<TState, TConfig>

ゲーム設定の基底クラス。

#### 抽象メソッド

```dart
abstract class GameConfiguration<TState, TConfig> {
  TConfig config;
  Map<TState, dynamic> stateConfigs;
  
  /// 設定の妥当性チェック
  bool isValid();
  
  /// 設定オブジェクトの妥当性チェック
  bool isValidConfig(TConfig config);
  
  /// 設定のコピー作成
  TConfig copyWith(Map<String, dynamic> overrides);
  
  /// JSON形式で出力
  Map<String, dynamic> toJson();
  
  /// A/Bテスト用バリアント取得
  TConfig getConfigForVariant(String variantId);
}
```

#### 実装例

```dart
class MyGameConfig {
  final Duration gameTime;
  final int maxLevel;
  final Map<String, String> messages;
  final Map<String, Color> colors;
  final bool enablePowerUps;
  
  const MyGameConfig({
    required this.gameTime,
    required this.maxLevel,
    required this.messages,
    required this.colors,
    this.enablePowerUps = false,
  });
  
  MyGameConfig copyWith({
    Duration? gameTime,
    int? maxLevel,
    Map<String, String>? messages,
    Map<String, Color>? colors,
    bool? enablePowerUps,
  }) {
    return MyGameConfig(
      gameTime: gameTime ?? this.gameTime,
      maxLevel: maxLevel ?? this.maxLevel,
      messages: messages ?? this.messages,
      colors: colors ?? this.colors,
      enablePowerUps: enablePowerUps ?? this.enablePowerUps,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'gameTimeMs': gameTime.inMilliseconds,
    'maxLevel': maxLevel,
    'messages': messages,
    'colors': colors.map((k, v) => MapEntry(k, v.value)),
    'enablePowerUps': enablePowerUps,
  };
}

class MyGameConfiguration extends GameConfiguration<GameState, MyGameConfig> 
    with ChangeNotifier, ConfigurationNotifier<GameState, MyGameConfig> {
  
  MyGameConfiguration({required super.config});
  
  @override
  bool isValid() {
    return config.gameTime.inMilliseconds > 0 &&
           config.maxLevel > 0 &&
           config.messages.isNotEmpty &&
           config.colors.isNotEmpty;
  }
  
  @override
  bool isValidConfig(MyGameConfig config) => isValid();
  
  @override
  MyGameConfig copyWith(Map<String, dynamic> overrides) {
    return config.copyWith(
      gameTime: overrides['gameTime'] as Duration?,
      maxLevel: overrides['maxLevel'] as int?,
      messages: overrides['messages'] as Map<String, String>?,
      colors: overrides['colors'] as Map<String, Color>?,
      enablePowerUps: overrides['enablePowerUps'] as bool?,
    );
  }
  
  @override
  Map<String, dynamic> toJson() => config.toJson();
  
  @override
  MyGameConfig getConfigForVariant(String variantId) {
    switch (variantId) {
      case 'easy':
        return config.copyWith(
          gameTime: Duration(seconds: 120),
          maxLevel: 3,
        );
      case 'hard':
        return config.copyWith(
          gameTime: Duration(seconds: 30),
          maxLevel: 10,
        );
      default:
        return config;
    }
  }
}
```

### ConfigurationNotifier<TState, TConfig>

設定変更通知のMixin。

#### メソッド

```dart
/// 設定変更通知
void notifyConfigChanged()

/// 設定変更リスナー追加
void addConfigListener(VoidCallback listener)

/// 設定変更リスナー削除
void removeConfigListener(VoidCallback listener)
```

---

## 3. タイマーシステムAPI

### TimerType

タイマーの種類を定義する列挙型。

```dart
enum TimerType {
  countdown,  // カウントダウン
  countup,    // カウントアップ
  interval,   // インターバル
}
```

### TimerConfiguration

タイマーの設定クラス。

#### コンストラクタ

```dart
TimerConfiguration({
  required Duration duration,         // タイマー時間
  required TimerType type,           // タイマータイプ
  VoidCallback? onComplete,          // 完了時コールバック
  void Function(Duration)? onUpdate, // 更新時コールバック
  bool autoStart = false,            // 自動開始フラグ
})
```

### GameTimer

個別タイマーの実装クラス。

#### プロパティ

```dart
String get id              // タイマーID
Duration get current       // 現在の時間
Duration get duration      // 設定時間
TimerType get type         // タイマータイプ
bool get isRunning         // 実行中フラグ
bool get isPaused          // 一時停止フラグ
bool get isCompleted       // 完了フラグ
```

#### メソッド

```dart
/// タイマー開始
void start()

/// タイマー一時停止
void pause()

/// タイマー再開
void resume()

/// タイマーリセット
void reset()

/// タイマー停止
void stop()

/// タイマー更新（フレーム毎に呼び出し）
void update(double deltaTime)
```

#### 実装例

```dart
// カウントダウンタイマー
final countdownTimer = GameTimer('main_timer', TimerConfiguration(
  duration: Duration(seconds: 60),
  type: TimerType.countdown,
  onComplete: () => print('タイムアップ！'),
  onUpdate: (remaining) => print('残り: ${remaining.inSeconds}秒'),
  autoStart: true,
));

// カウントアップタイマー
final countupTimer = GameTimer('score_timer', TimerConfiguration(
  duration: Duration(minutes: 5),
  type: TimerType.countup,
  onComplete: () => print('5分経過'),
));

// インターバルタイマー
final intervalTimer = GameTimer('spawn_timer', TimerConfiguration(
  duration: Duration(seconds: 2),
  type: TimerType.interval,
  onComplete: () => spawnEnemy(),
  autoStart: true,
));
```

### TimerManager

複数タイマーの管理クラス。

#### メソッド

```dart
/// タイマー追加
void addTimer(String id, TimerConfiguration config)

/// タイマー取得
GameTimer? getTimer(String id)

/// タイマー削除
void removeTimer(String id)

/// 全タイマー開始
void startAllTimers()

/// 全タイマー一時停止
void pauseAllTimers()

/// 全タイマー再開
void resumeAllTimers()

/// 全タイマー停止
void stopAllTimers()

/// タイマーID一覧取得
List<String> getTimerIds()

/// 実行中タイマーID一覧取得
List<String> getRunningTimerIds()
```

#### 実装例

```dart
final timerManager = TimerManager();

// メインゲームタイマー
timerManager.addTimer('main', TimerConfiguration(
  duration: Duration(seconds: 60),
  type: TimerType.countdown,
  onComplete: () => _onGameOver(),
));

// 敵出現タイマー
timerManager.addTimer('enemy_spawn', TimerConfiguration(
  duration: Duration(seconds: 3),
  type: TimerType.interval,
  onComplete: () => _spawnEnemy(),
));

// パワーアップタイマー
timerManager.addTimer('powerup', TimerConfiguration(
  duration: Duration(seconds: 10),
  type: TimerType.countup,
  onComplete: () => _endPowerUp(),
));

// 全タイマー開始
timerManager.startAllTimers();

// フレーム更新での時間更新
@override
void update(double dt) {
  for (final timerId in timerManager.getTimerIds()) {
    final timer = timerManager.getTimer(timerId);
    timer?.update(dt);
  }
  super.update(dt);
}
```

---

## 4. UIシステムAPI

### UITheme

UIテーマの基底インターフェース。

#### 抽象メソッド

```dart
abstract class UITheme {
  /// 色を取得
  Color getColor(String key);
  
  /// フォントサイズを取得
  double getFontSize(String key);
  
  /// フォント重みを取得
  FontWeight getFontWeight(String key);
  
  /// パディングを取得
  EdgeInsets getPadding(String key);
}
```

### DefaultUITheme

デフォルトUIテーマの実装。

#### コンストラクタ

```dart
DefaultUITheme({
  required Map<String, Color> colors,
  required Map<String, double> fontSizes,
  Map<String, FontWeight> fontWeights = const {},
  Map<String, EdgeInsets> paddings = const {},
})
```

#### 実装例

```dart
final customTheme = DefaultUITheme(
  colors: const {
    'primary': Colors.blue,
    'secondary': Colors.green,
    'background': Colors.white,
    'text': Colors.black,
    'accent': Colors.orange,
  },
  fontSizes: const {
    'small': 12.0,
    'medium': 16.0,
    'large': 24.0,
    'title': 32.0,
  },
  fontWeights: const {
    'normal': FontWeight.normal,
    'bold': FontWeight.bold,
    'light': FontWeight.w300,
  },
  paddings: const {
    'small': EdgeInsets.all(8.0),
    'medium': EdgeInsets.all(16.0),
    'large': EdgeInsets.all(24.0),
  },
);
```

### ThemeManager

テーマの管理クラス。

#### プロパティ

```dart
UITheme get currentTheme     // 現在のテーマ
String get currentThemeId    // 現在のテーマID
```

#### メソッド

```dart
/// デフォルトテーマを初期化
void initializeDefaultThemes()

/// カスタムテーマを登録
void registerTheme(String id, UITheme theme)

/// テーマを設定
void setTheme(String themeId)

/// 利用可能なテーマ一覧を取得
List<String> getAvailableThemes()
```

#### 実装例

```dart
final themeManager = ThemeManager();

// デフォルトテーマ初期化
themeManager.initializeDefaultThemes();

// カスタムテーマ登録
themeManager.registerTheme('custom', customTheme);

// テーマ切り替え
themeManager.setTheme('dark');  // ダークテーマ
themeManager.setTheme('custom'); // カスタムテーマ

// テーマ使用
final primaryColor = themeManager.currentTheme.getColor('primary');
final titleSize = themeManager.currentTheme.getFontSize('title');
```

### 汎用UIコンポーネント

#### TextUIComponent

テキスト表示コンポーネント。

```dart
class TextUIComponent extends PositionComponent {
  TextUIComponent({
    required String text,
    required Vector2 position,
    TextStyle? style,
  });
  
  /// テキスト更新
  void updateText(String newText)
  
  /// スタイル更新
  void updateStyle(TextStyle style)
}
```

#### ButtonUIComponent

ボタンコンポーネント。

```dart
class ButtonUIComponent extends PositionComponent with TapCallbacks {
  ButtonUIComponent({
    required Vector2 position,
    required Vector2 size,
    required String text,
    VoidCallback? onPressed,
  });
  
  /// ボタン状態更新
  void updateState(ButtonState state)
  
  /// テキスト更新
  void updateText(String newText)
}

enum ButtonState { normal, pressed, disabled }
```

#### ProgressBarUIComponent

プログレスバーコンポーネント。

```dart
class ProgressBarUIComponent extends PositionComponent {
  ProgressBarUIComponent({
    required Vector2 position,
    required Vector2 size,
    double progress = 0.0,
    Color? backgroundColor,
    Color? progressColor,
  });
  
  /// 進捗更新
  void updateProgress(double progress)
  
  /// 色更新
  void updateColors({Color? backgroundColor, Color? progressColor})
}
```

---

## 5. フレームワーク統合API

### ConfigurableGame<TState, TConfig>

フレームワーク統合の基底クラス。

#### 抽象プロパティ

```dart
abstract class ConfigurableGame<TState extends GameState, TConfig> 
    extends FlameGame {
  
  /// 状態プロバイダー
  GameStateProvider<TState> get stateProvider;
  
  /// 設定管理
  GameConfiguration<TState, TConfig> get configuration;
  
  /// タイマー管理
  TimerManager get timerManager;
  
  /// テーマ管理
  ThemeManager get themeManager;
}
```

#### ライフサイクルメソッド

```dart
/// 初期化処理
@override
Future<void> onLoad() async {
  // システム初期化
  await super.onLoad();
}

/// フレーム更新
@override
void update(double dt) {
  // タイマー更新
  for (final timerId in timerManager.getTimerIds()) {
    timerManager.getTimer(timerId)?.update(dt);
  }
  super.update(dt);
}

/// 描画処理
@override
void render(Canvas canvas) {
  super.render(canvas);
}
```

#### 実装例

```dart
class MyGame extends ConfigurableGame<GameState, MyGameConfig> {
  late final MyGameStateProvider _stateProvider;
  late final MyGameConfiguration _configuration;
  late final TimerManager _timerManager;
  late final ThemeManager _themeManager;
  
  @override
  GameStateProvider<GameState> get stateProvider => _stateProvider;
  
  @override
  GameConfiguration<GameState, MyGameConfig> get configuration => _configuration;
  
  @override
  TimerManager get timerManager => _timerManager;
  
  @override
  ThemeManager get themeManager => _themeManager;
  
  @override
  Future<void> onLoad() async {
    // システム初期化
    _stateProvider = MyGameStateProvider();
    _configuration = MyGameConfiguration(config: MyGameConfig.defaultConfig);
    _timerManager = TimerManager();
    _themeManager = ThemeManager();
    
    // テーマ初期化
    _themeManager.initializeDefaultThemes();
    
    // タイマー設定
    _timerManager.addTimer('main', TimerConfiguration(
      duration: _configuration.config.gameTime,
      type: TimerType.countdown,
      onComplete: () => _onGameComplete(),
    ));
    
    // UI初期化
    await _initializeUI();
    
    await super.onLoad();
  }
  
  Future<void> _initializeUI() async {
    // UI コンポーネント追加
    add(TextUIComponent(
      text: 'TAP TO START',
      position: Vector2(size.x / 2, size.y / 2),
      style: TextStyle(
        fontSize: _themeManager.currentTheme.getFontSize('large'),
        color: _themeManager.currentTheme.getColor('primary'),
      ),
    ));
  }
  
  void _onGameComplete() {
    // ゲーム完了処理
    _stateProvider.transitionTo(MyGameOverState());
  }
}
```

---

## 6. 実装例

### 完全なゲーム実装例

```dart
// 1. 状態定義
class TapGameIdleState extends GameState {
  const TapGameIdleState() : super();
  @override
  String get name => 'idle';
  @override
  String get description => 'タップして開始';
}

class TapGamePlayingState extends GameState {
  final int score;
  final double timeRemaining;
  
  const TapGamePlayingState({
    required this.score,
    required this.timeRemaining,
  }) : super();
  
  @override
  String get name => 'playing';
  
  @override
  String get description => 'スコア: $score, 残り: ${timeRemaining.toStringAsFixed(1)}s';
  
  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'score': score,
    'timeRemaining': timeRemaining,
  };
}

class TapGameOverState extends GameState {
  final int finalScore;
  
  const TapGameOverState({required this.finalScore}) : super();
  
  @override
  String get name => 'gameOver';
  
  @override
  String get description => '最終スコア: $finalScore';
}

// 2. 設定定義
class TapGameConfig {
  final Duration gameTime;
  final int targetScore;
  final Map<String, String> messages;
  final Map<String, Color> colors;
  
  const TapGameConfig({
    required this.gameTime,
    required this.targetScore,
    required this.messages,
    required this.colors,
  });
  
  static const defaultConfig = TapGameConfig(
    gameTime: Duration(seconds: 30),
    targetScore: 100,
    messages: {
      'start': 'TAP TO START',
      'playing': 'TAP FAST!',
      'gameOver': 'GAME OVER',
    },
    colors: {
      'background': Colors.black,
      'text': Colors.white,
      'accent': Colors.yellow,
    },
  );
}

// 3. 状態プロバイダー
class TapGameStateProvider extends GameStateProvider<GameState> {
  TapGameStateProvider() : super(const TapGameIdleState()) {
    _setupTransitions();
  }
  
  void _setupTransitions() {
    stateMachine.defineTransitions([
      StateTransition<GameState>(
        fromState: TapGameIdleState,
        toState: TapGamePlayingState,
        onTransition: (from, to) => startNewSession(),
      ),
      StateTransition<GameState>(
        fromState: TapGamePlayingState,
        toState: TapGamePlayingState,
      ),
      StateTransition<GameState>(
        fromState: TapGamePlayingState,
        toState: TapGameOverState,
      ),
      StateTransition<GameState>(
        fromState: TapGameOverState,
        toState: TapGameIdleState,
      ),
    ]);
  }
  
  bool startGame() => transitionTo(const TapGamePlayingState(
    score: 0,
    timeRemaining: 30.0,
  ));
  
  bool updateScore(int score, double timeRemaining) {
    if (currentState is! TapGamePlayingState) return false;
    
    if (timeRemaining <= 0) {
      return transitionTo(TapGameOverState(finalScore: score));
    }
    
    return transitionTo(TapGamePlayingState(
      score: score,
      timeRemaining: timeRemaining,
    ));
  }
  
  bool resetGame() => transitionTo(const TapGameIdleState());
}

// 4. メインゲームクラス
class TapGame extends ConfigurableGame<GameState, TapGameConfig> {
  late final TapGameStateProvider _stateProvider;
  late final TimerManager _timerManager;
  late final ThemeManager _themeManager;
  
  int _score = 0;
  late TextUIComponent _statusText;
  late TextUIComponent _scoreText;
  
  @override
  GameStateProvider<GameState> get stateProvider => _stateProvider;
  
  @override
  TimerManager get timerManager => _timerManager;
  
  @override
  ThemeManager get themeManager => _themeManager;
  
  @override
  GameConfiguration<GameState, TapGameConfig> get configuration => 
      throw UnimplementedError(); // 簡略化のため省略
  
  @override
  Future<void> onLoad() async {
    // システム初期化
    _stateProvider = TapGameStateProvider();
    _timerManager = TimerManager();
    _themeManager = ThemeManager();
    
    _themeManager.initializeDefaultThemes();
    
    // UI初期化
    _statusText = TextUIComponent(
      text: 'TAP TO START',
      position: Vector2(size.x / 2, size.y / 2 - 50),
      style: TextStyle(
        fontSize: 24,
        color: Colors.white,
      ),
    );
    add(_statusText);
    
    _scoreText = TextUIComponent(
      text: 'Score: 0',
      position: Vector2(size.x / 2, 50),
      style: TextStyle(
        fontSize: 18,
        color: Colors.yellow,
      ),
    );
    add(_scoreText);
    
    // 状態変更リスナー
    _stateProvider.addListener(_onStateChanged);
    
    await super.onLoad();
  }
  
  @override
  void update(double dt) {
    // タイマー更新
    final mainTimer = _timerManager.getTimer('main');
    if (mainTimer != null && mainTimer.isRunning) {
      mainTimer.update(dt);
      
      final remaining = mainTimer.current.inMilliseconds / 1000.0;
      _stateProvider.updateScore(_score, remaining);
    }
    
    super.update(dt);
  }
  
  @override
  bool onTapDown(TapDownEvent event) {
    final state = _stateProvider.currentState;
    
    if (state is TapGameIdleState) {
      _startGame();
    } else if (state is TapGamePlayingState) {
      _incrementScore();
    } else if (state is TapGameOverState) {
      _resetGame();
    }
    
    return true;
  }
  
  void _startGame() {
    _score = 0;
    _stateProvider.startGame();
    
    _timerManager.addTimer('main', TimerConfiguration(
      duration: const Duration(seconds: 30),
      type: TimerType.countdown,
      onComplete: () => _endGame(),
    ));
    
    _timerManager.getTimer('main')?.start();
  }
  
  void _incrementScore() {
    _score++;
    _scoreText.updateText('Score: $_score');
  }
  
  void _endGame() {
    final finalScore = _score;
    _stateProvider.updateScore(finalScore, 0.0);
  }
  
  void _resetGame() {
    _score = 0;
    _stateProvider.resetGame();
    _timerManager.removeTimer('main');
  }
  
  void _onStateChanged() {
    final state = _stateProvider.currentState;
    
    if (state is TapGameIdleState) {
      _statusText.updateText('TAP TO START');
      _scoreText.updateText('Score: 0');
    } else if (state is TapGamePlayingState) {
      _statusText.updateText('TAP FAST!');
    } else if (state is TapGameOverState) {
      _statusText.updateText('GAME OVER\\nFinal Score: ${state.finalScore}\\nTAP TO RESTART');
    }
  }
}

// 5. アプリケーション統合
class TapGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider<TapGameStateProvider>(
        create: (_) => TapGameStateProvider(),
        child: GameWidget<TapGame>.controlled(
          gameFactory: TapGame.new,
        ),
      ),
    );
  }
}
```

### テスト実装例

```dart
// テストファイル例
void main() {
  group('TapGame Tests', () {
    late TapGameStateProvider stateProvider;
    
    setUp(() {
      stateProvider = TapGameStateProvider();
    });
    
    test('初期状態がIdleであること', () {
      expect(stateProvider.currentState, isA<TapGameIdleState>());
    });
    
    test('ゲーム開始でPlayingState に遷移すること', () {
      final success = stateProvider.startGame();
      
      expect(success, isTrue);
      expect(stateProvider.currentState, isA<TapGamePlayingState>());
      expect(stateProvider.sessionCount, equals(1));
    });
    
    test('スコア更新でPlayingState が更新されること', () {
      stateProvider.startGame();
      final success = stateProvider.updateScore(50, 15.0);
      
      expect(success, isTrue);
      final state = stateProvider.currentState as TapGamePlayingState;
      expect(state.score, equals(50));
      expect(state.timeRemaining, equals(15.0));
    });
    
    test('時間切れでGameOverState に遷移すること', () {
      stateProvider.startGame();
      final success = stateProvider.updateScore(75, 0.0);
      
      expect(success, isTrue);
      expect(stateProvider.currentState, isA<TapGameOverState>());
      final gameOverState = stateProvider.currentState as TapGameOverState;
      expect(gameOverState.finalScore, equals(75));
    });
    
    test('統計情報が正しく記録されること', () {
      stateProvider.startGame();
      stateProvider.updateScore(25, 20.0);
      stateProvider.updateScore(50, 10.0);
      stateProvider.updateScore(75, 0.0);
      
      final stats = stateProvider.getStatistics();
      expect(stats.sessionCount, equals(1));
      expect(stats.totalStateChanges, greaterThan(0));
      expect(stats.mostVisitedState, equals('playing'));
    });
  });
}
```

---

## 7. 制約・注意事項

### 7.1 技術的制約

#### 状態管理
- **状態数上限**: 実用的には10-15状態まで（遷移管理の複雑化）
- **遷移履歴**: 1000件で自動削除（メモリ制約）
- **型安全性**: ジェネリクス使用で実行時エラーリスク減少

#### タイマーシステム
- **同時実行数**: 100個程度が実用限界（パフォーマンス劣化）
- **精度**: 16.67ms（60FPS）が最小更新間隔
- **プラットフォーム依存**: ブラウザでの精度制限あり

#### 設定管理
- **JSON制約**: Colorクラス等はシリアライズ前変換必要
- **A/Bテスト**: variantId は事前定義済みのもののみ有効
- **設定サイズ**: 大きすぎる設定はJSON変換コスト増大

### 7.2 プラットフォーム依存性

```dart
// ✅ プラットフォーム対応例
class PlatformAwareTimer {
  static double getDeltaTime() {
    if (kIsWeb) {
      // ブラウザでは精度制限
      return math.max(0.016, actualDeltaTime);
    }
    return actualDeltaTime;
  }
}
```

### 7.3 実装時の注意事項

#### 状態遷移の競合
```dart
// ❌ 危険: 複数箇所からの同時遷移
Future<void> gameLoop() async {
  stateProvider.transitionTo(PlayingState()); // Thread A
}

void onUserTap() {
  stateProvider.transitionTo(PausedState()); // Thread B
}

// ✅ 安全: 単一責任での状態管理
class GameController {
  void requestStateChange(GameState newState) {
    _pendingStateChange = newState;
  }
  
  void update() {
    if (_pendingStateChange != null) {
      stateProvider.transitionTo(_pendingStateChange!);
      _pendingStateChange = null;
    }
  }
}
```

## 8. パフォーマンス最適化

### 8.1 状態遷移最適化

```dart
// ❌ 非効率: 毎フレーム新しい状態作成
void update(double dt) {
  final playing = PlayingState(timeRemaining: currentTime);
  stateProvider.transitionTo(playing);
}

// ✅ 効率的: 値変更時のみ遷移
void update(double dt) {
  if (abs(currentTime - lastUpdatedTime) > 0.1) {
    final playing = PlayingState(timeRemaining: currentTime);
    stateProvider.transitionTo(playing);
    lastUpdatedTime = currentTime;
  }
}
```

### 8.2 タイマー最適化

```dart
// ✅ バッチ更新でパフォーマンス向上
class OptimizedTimerManager extends TimerManager {
  void batchUpdate(double dt) {
    final runningTimers = getRunningTimerIds()
        .map((id) => getTimer(id))
        .where((timer) => timer != null)
        .cast<GameTimer>();
    
    for (final timer in runningTimers) {
      timer.update(dt);
    }
  }
}
```

### 8.3 設定管理最適化

```dart
// ✅ 設定キャッシュで頻繁なアクセス最適化
class CachedGameConfiguration extends GameConfiguration {
  Map<String, dynamic>? _cachedJson;
  
  @override
  Map<String, dynamic> toJson() {
    return _cachedJson ??= super.toJson();
  }
  
  void invalidateCache() {
    _cachedJson = null;
  }
}
```

### 8.4 メモリ管理

```dart
// ✅ 適切なリソース管理
class GameResourceManager {
  static final _stateProviders = <String, GameStateProvider>{};
  
  static GameStateProvider getOrCreate(String gameId) {
    return _stateProviders.putIfAbsent(
      gameId, 
      () => createNewProvider(),
    );
  }
  
  static void cleanup(String gameId) {
    _stateProviders[gameId]?.dispose();
    _stateProviders.remove(gameId);
  }
}
```

---

## 関連ドキュメント

- [フレームワーク技術仕様書](framework_specification.md)
- [カジュアルゲームフレームワーク設計書](casual_game_framework_design.md)
- [ベストプラクティス準拠チェック](bestpractice_compliance_check.md)

---

**文書バージョン**: 1.1  
**最終更新**: 2025-07-30  
**作成者**: Claude Code Framework Team