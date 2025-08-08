# SimpleGameベース量産ゲーム作成ガイド

## 🎯 概要
SimpleGameの成功パターンを活用して、エラーなく新ゲームを量産するためのガイドです。

## 📊 エラー分析結果

### 発生した5つのエラーと根本原因

| エラー | 根本原因 | 修正方法 | 予防策 |
|--------|----------|----------|--------|
| **TapDownInfo vs TapDownEvent** | Flame API型の混同 | `TapDownEvent.localPosition`使用 | 型注釈明示 |
| **playExplosion vs playEffect** | メソッド名の推測実装 | `playEffect('explosion', position)`使用 | API確認必須 |
| **implements vs extends** | 抽象クラス継承の誤解 | `extends GameConfiguration`使用 | 継承図確認 |
| **GameState import不足** | 依存関係の不備 | `import 'game_state_system.dart'`追加 | 自動import |
| **void vs bool戻り値** | インターフェース不整合 | `void`統一 | 契約確認 |

## 🚀 量産テンプレート（コピー＆ペースト用）

### 1. ゲーム設定クラス
```dart
import '../../framework/config/game_configuration.dart';
import '../../framework/state/game_state_system.dart';

class [GAME_NAME]Config {
  final int gameDuration;
  final double [SPECIFIC_PARAM];
  final String difficulty;

  const [GAME_NAME]Config({
    this.gameDuration = 30,
    this.[SPECIFIC_PARAM] = 1.0,
    this.difficulty = 'normal',
  });

  [GAME_NAME]Config copyWith({
    int? gameDuration,
    double? [SPECIFIC_PARAM],
    String? difficulty,
  }) {
    return [GAME_NAME]Config(
      gameDuration: gameDuration ?? this.gameDuration,
      [SPECIFIC_PARAM]: [SPECIFIC_PARAM] ?? this.[SPECIFIC_PARAM],
      difficulty: difficulty ?? this.difficulty,
    );
  }

  Map<String, dynamic> toJson() => {
    'gameDuration': gameDuration,
    '[SPECIFIC_PARAM]': [SPECIFIC_PARAM],
    'difficulty': difficulty,
  };

  factory [GAME_NAME]Config.fromJson(Map<String, dynamic> json) => [GAME_NAME]Config(
    gameDuration: json['gameDuration'] ?? 30,
    [SPECIFIC_PARAM]: json['[SPECIFIC_PARAM]']?.toDouble() ?? 1.0,
    difficulty: json['difficulty'] ?? 'normal',
  );
}

class [GAME_NAME]Configuration extends GameConfiguration<GameState, [GAME_NAME]Config> {
  [GAME_NAME]Configuration([GAME_NAME]Config config) : super(config: config);

  static final [GAME_NAME]Configuration defaultConfig = 
    [GAME_NAME]Configuration(const [GAME_NAME]Config());

  @override
  bool isValid() => config.gameDuration > 0;

  @override
  bool isValidConfig([GAME_NAME]Config config) => config.gameDuration > 0;

  @override
  [GAME_NAME]Config copyWith(Map<String, dynamic> overrides) {
    return config.copyWith(
      gameDuration: overrides['gameDuration'] as int?,
      [SPECIFIC_PARAM]: overrides['[SPECIFIC_PARAM]'] as double?,
      difficulty: overrides['difficulty'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => config.toJson();
}
```

### 2. メインゲームクラス
```dart
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../framework/state/game_state_system.dart';
import '../framework/core/configurable_game.dart';
import '../framework/audio/providers/flame_audio_provider.dart';
import '../framework/effects/particle_system.dart';
import 'framework_integration/simple_game_states.dart';
import 'config/[GAME_NAME]_config.dart';

class [GAME_NAME] extends ConfigurableGame<GameState, [GAME_NAME]Config> {
  // ゲーム状態
  late ParticleEffectManager _particleManager;
  bool _gameActive = false;
  int _score = 0;
  double _gameTimeRemaining = 0;

  [GAME_NAME]() : super(
    configuration: [GAME_NAME]Configuration.defaultConfig,
    debugMode: false,
  );

  @override
  GameStateProvider<GameState> createStateProvider() {
    return SimpleGameStateProvider(); // 既存プロバイダー流用
  }

  @override
  AudioProvider createAudioProvider() {
    return FlameAudioProvider(); // 既存プロバイダー流用
  }

  @override
  Future<void> initializeGame() async {
    debugPrint('🎮 [GAME_NAME] initializing...');
    
    // パーティクルシステム初期化
    _particleManager = ParticleEffectManager();
    add(_particleManager);
    
    // ゲーム状態リセット
    _resetGame();
    
    debugPrint('🎮 [GAME_NAME] initialized');
  }

  void _resetGame() {
    _score = 0;
    _gameTimeRemaining = config.gameDuration.toDouble();
    _gameActive = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (!_gameActive) return;

    // タイマー更新
    _gameTimeRemaining -= dt;

    // ゲーム終了チェック
    if (_gameTimeRemaining <= 0) {
      _endGame();
    }
  }

  @override
  void onTapDown(TapDownEvent event) { // 正しい型使用
    if (!_gameActive) {
      _resetGame();
      return;
    }

    final tapPosition = event.localPosition; // 正しいプロパティ
    
    // ゲーム固有の処理
    _handleTap(tapPosition);
  }

  void _handleTap(Vector2 position) {
    // タップ処理の実装
    _score += 10;
    
    // パーティクルエフェクト（正しいメソッド名）
    _particleManager.playEffect('explosion', position);
    
    // 効果音
    audioManager.playSfx('tap');
    
    debugPrint('🎮 Score: $_score');
  }

  void _endGame() {
    _gameActive = false;
    
    // 分析イベント
    analyticsManager.trackEvent('[GAME_NAME]_completed', parameters: {
      'score': _score,
      'duration': config.gameDuration,
    });
    
    debugPrint('🎮 Game Over! Final Score: $_score');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // 背景
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = Colors.black.withOpacity(0.8),
    );
    
    // UI描画
    _renderUI(canvas);
  }

  void _renderUI(Canvas canvas) {
    final textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );

    // スコア表示
    final scoreSpan = TextSpan(text: 'Score: $_score', style: textStyle);
    final scorePainter = TextPainter(
      text: scoreSpan,
      textDirection: TextDirection.ltr,
    );
    scorePainter.layout();
    scorePainter.paint(canvas, const Offset(20, 50));

    // タイマー表示
    final minutes = _gameTimeRemaining ~/ 60;
    final seconds = (_gameTimeRemaining % 60).round();
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    final timeSpan = TextSpan(text: 'Time: $timeString', style: textStyle);
    final timePainter = TextPainter(
      text: timeSpan,
      textDirection: TextDirection.ltr,
    );
    timePainter.layout();
    timePainter.paint(canvas, Offset(size.x - 150, 50));

    // ゲーム終了メッセージ
    if (!_gameActive) {
      final gameOverStyle = textStyle.copyWith(fontSize: 32);
      final gameOverSpan = TextSpan(text: 'Game Over!\nTap to Restart', style: gameOverStyle);
      final gameOverPainter = TextPainter(
        text: gameOverSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      gameOverPainter.layout();
      gameOverPainter.paint(canvas, Offset(
        (size.x - gameOverPainter.width) / 2,
        (size.y - gameOverPainter.height) / 2,
      ));
    }
  }
}
```

## ✅ 新ゲーム作成チェックリスト

### 作成前（必須確認）
- [ ] SimpleGameの最新版を確認済み
- [ ] このテンプレートファイルを最新版に更新済み
- [ ] ゲーム名とファイル名を決定済み

### 実装時（置換作業）
- [ ] `[GAME_NAME]`を実際のゲーム名に置換（例：`TapFire`）
- [ ] `[SPECIFIC_PARAM]`をゲーム固有パラメータに置換（例：`fireballSpeed`）
- [ ] `_handleTap`メソッドにゲーム固有ロジックを実装
- [ ] 必要に応じてゲーム固有コンポーネントを追加

### 完了時（動作確認）
- [ ] `flutter analyze`でエラー0件
- [ ] `flutter run`で正常起動
- [ ] 基本ゲームプレイが動作
- [ ] スコア表示が正常
- [ ] タイマーが正常動作

## 🚨 絶対に守る5つのルール

### 1. 型安全性
```dart
✅ 正解: void onTapDown(TapDownEvent event)
❌ 間違い: bool onTapDown(TapDownInfo info)
```

### 2. メソッド名
```dart
✅ 正解: _particleManager.playEffect('explosion', position)
❌ 間違い: _particleManager.playExplosion(position)
```

### 3. 継承関係
```dart
✅ 正解: extends GameConfiguration<GameState, Config>
❌ 間違い: implements GameConfiguration<Config>
```

### 4. プロパティ名
```dart
✅ 正解: event.localPosition
❌ 間違い: event.canvasPosition
```

### 5. プロバイダー流用
```dart
✅ 正解: SimpleGameStateProvider() // 既存を流用
❌ 間違い: CustomGameStateProvider() // 新規作成
```

## 📈 成功指標

### 目標値
- **初回コンパイル成功率**: 95%以上
- **型エラー発生率**: 0%
- **実装時間**: 30分以下（基本ゲーム）

このガイドに従うことで、SimpleGameの安定性を維持しながら効率的なゲーム量産が可能になります。