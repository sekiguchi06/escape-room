# カジュアルゲームフレームワーク流用ガイド

## 🎯 このガイドの目的

このフレームワークを新しいカジュアルゲームプロジェクトで流用する際の**実用的な手順書**です。AIが迷わずに実装できるよう、具体的な手順とコード例を記載しています。

## 📁 必須ディレクトリ構造

新規プロジェクトで以下の構造を作成：

```
your_new_game/
├── assets/
│   └── audio/
│       ├── bgm/          # BGMファイル(.mp3, .ogg等)
│       │   ├── menu.mp3
│       │   └── game.mp3
│       └── sfx/          # 効果音ファイル(.wav, .mp3等)
│           ├── tap.wav
│           ├── success.wav
│           └── error.wav
├── lib/
│   ├── main.dart
│   └── game/
│       └── my_game.dart  # あなたのゲーム実装
└── pubspec.yaml
```

## 🔧 pubspec.yaml設定

```yaml
dependencies:
  flutter:
    sdk: flutter
  flame: ^1.30.1
  provider: ^6.1.2
  google_mobile_ads: ^6.0.0
  firebase_core: ^2.24.2
  firebase_analytics: ^10.7.4
  shared_preferences: ^2.5.3
  audioplayers: ^6.5.0

flutter:
  uses-material-design: true
  
  # 🚨 必須: アセット設定
  assets:
    - assets/audio/bgm/
    - assets/audio/sfx/
```

## 🎵 音声システムの簡単な統合

### 1. ゲームクラスの基本構造

```dart
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

// フレームワークのインポート
import 'package:casual_game_template/framework/core/configurable_game.dart';
import 'package:casual_game_template/framework/audio/game_audio_helper.dart';
import 'package:casual_game_template/framework/audio/providers/audioplayers_provider.dart';
import 'package:casual_game_template/framework/monetization/providers/google_ad_provider.dart';
import 'package:casual_game_template/framework/analytics/providers/firebase_analytics_provider.dart';

class MyGame extends ConfigurableGame<GameState, MyGameConfig> with TapCallbacks {
  
  MyGame() : super(
    configuration: MyGameConfiguration.defaultConfig,
    debugMode: true,
  );
  
  @override
  AudioProvider createAudioProvider() {
    return AudioPlayersProvider(); // 実音声再生用
    // return GameAudioHelper.createSilentProvider(); // テスト用
  }

  @override
  AdProvider createAdProvider() {
    return GoogleAdProvider();
  }

  @override
  AnalyticsProvider createAnalyticsProvider() {
    return FirebaseAnalyticsProvider();
  }

  @override
  Future<void> initializeGame() async {
    // 🎵 音声システムの簡単な初期化
    await _initializeAudio();
    
    // ゲーム固有の初期化処理...
  }
  
  // 🎵 音声システムの初期化（推奨パターン）
  Future<void> _initializeAudio() async {
    try {
      await GameAudioIntegration.setupAudio(
        audioManager: audioManager,
        bgmFiles: {
          'menu_bgm': 'menu.mp3',      // assets/audio/bgm/menu.mp3
          'game_bgm': 'game.mp3',      // assets/audio/bgm/game.mp3
        },
        sfxFiles: {
          'tap': 'tap.wav',            // assets/audio/sfx/tap.wav
          'success': 'success.wav',    // assets/audio/sfx/success.wav
          'error': 'error.wav',        // assets/audio/sfx/error.wav
        },
        masterVolume: 1.0,
        bgmVolume: 0.7,
        sfxVolume: 0.8,
        debugMode: true, // 開発時はtrue
      );
      
      print('🎵 Audio system ready');
      
      // BGM自動開始（ユーザーインタラクション後）
      audioManager.playBgm('menu_bgm');
    } catch (e) {
      print('❌ Audio initialization failed: $e');
    }
  }
  
  // ゲームイベントでの音声再生例
  void onGameStart() {
    audioManager.playSfx('success', volumeMultiplier: 1.0);
  }
  
  void onButtonTap() {
    audioManager.playSfx('tap', volumeMultiplier: 0.7);
  }
  
  void onGameOver() {
    audioManager.playSfx('error', volumeMultiplier: 0.9);
  }
}
```

### 2. よくある音声パターンの利用

```dart
// よくあるゲーム音声のプリセットを使用
Future<void> _initializeAudioWithPresets() async {
  await GameAudioIntegration.setupAudio(
    audioManager: audioManager,
    bgmFiles: GameAudioIntegration.getCommonBgmPreset(),
    sfxFiles: GameAudioIntegration.getCommonSfxPreset(),
    debugMode: true,
  );
}
```

## 🚨 よくある間違いと対策

### ❌ 間違い1: パス設定の重複
```dart
// ❌ 間違い: フルパスを指定してしまう
bgmFiles: {
  'menu': 'assets/audio/bgm/menu.mp3', // 重複！
},

// ✅ 正しい: ファイル名のみ指定
bgmFiles: {
  'menu': 'menu.mp3', // GameAudioHelperが自動でパス付加
},
```

### ❌ 間違い2: アセット設定忘れ
```yaml
# ❌ pubspec.yamlでアセット設定を忘れる
flutter:
  uses-material-design: true
  # assetsの設定なし → ファイルが見つからないエラー

# ✅ 正しい設定
flutter:
  uses-material-design: true
  assets:
    - assets/audio/bgm/
    - assets/audio/sfx/
```

### ❌ 間違い3: 初期化順序の問題
```dart
// ❌ 間違い: audioManagerの初期化前に音声再生
@override
Future<void> initializeGame() async {
  audioManager.playBgm('menu'); // まだ初期化されていない！
  await _initializeAudio();
}

// ✅ 正しい: 初期化後に音声再生
@override
Future<void> initializeGame() async {
  await _initializeAudio();
  audioManager.playBgm('menu'); // 初期化済み
}
```

## 🧪 開発・テスト時のコツ

### 音声ファイルがない場合のテスト

```dart
@override
AudioProvider createAudioProvider() {
  // 開発初期段階：音声ファイルなしでテスト
  return GameAudioHelper.createSilentProvider();
  
  // 音声ファイル準備後：実音声で動作確認
  // return GameAudioHelper.createRealProvider();
}
```

### デバッグ情報の活用

```dart
await GameAudioIntegration.setupAudio(
  audioManager: audioManager,
  bgmFiles: {'menu': 'menu.mp3'},
  sfxFiles: {'tap': 'tap.wav'},
  debugMode: true, // コンソールに詳細ログ出力
);
```

## 📋 流用チェックリスト

新規プロジェクトで以下を確認：

- [ ] **ディレクトリ構造**: `assets/audio/bgm/` と `assets/audio/sfx/` フォルダ作成済み
- [ ] **pubspec.yaml**: アセット設定追加済み
- [ ] **音声ファイル**: 必要な音声ファイルを配置済み
- [ ] **GameAudioHelper**: インポートと使用方法確認済み
- [ ] **初期化順序**: `_initializeAudio()`を`initializeGame()`内で実行
- [ ] **エラーハンドリング**: try-catch文で音声初期化を囲む
- [ ] **ブラウザテスト**: 実際に音声再生されることを確認

## 🎮 完全な実装例

最小限のゲーム実装例：

```dart
// lib/game/my_simple_game.dart
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:casual_game_template/framework/core/configurable_game.dart';
import 'package:casual_game_template/framework/audio/game_audio_helper.dart';
import 'package:casual_game_template/framework/audio/providers/audioplayers_provider.dart';

class MySimpleGame extends ConfigurableGame<GameState, SimpleGameConfig> with TapCallbacks {
  late TextComponent _statusText;
  
  MySimpleGame() : super(
    configuration: SimpleGameConfiguration.defaultConfig,
    debugMode: true,
  );
  
  @override
  AudioProvider createAudioProvider() => AudioPlayersProvider();
  
  @override
  Future<void> initializeGame() async {
    // 音声システム初期化
    await GameAudioIntegration.setupAudio(
      audioManager: audioManager,
      bgmFiles: {'menu': 'menu.mp3'},
      sfxFiles: {'tap': 'tap.wav', 'success': 'success.wav'},
      debugMode: true,
    );
    
    // UI作成
    _statusText = TextComponent(
      text: 'TAP TO START',
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
    );
    add(_statusText);
    
    // BGM開始
    audioManager.playBgm('menu');
  }
  
  @override
  void onTapDown(TapDownEvent event) {
    audioManager.playSfx('tap', volumeMultiplier: 0.8);
    _statusText.text = 'GAME STARTED!';
    audioManager.playSfx('success');
  }
}
```

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/my_simple_game.dart';

void main() {
  runApp(MyGameApp());
}

class MyGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Casual Game',
      home: Scaffold(
        body: GameWidget<MySimpleGame>.controlled(
          gameFactory: MySimpleGame.new,
        ),
      ),
    );
  }
}
```

## 🚀 次のステップ

音声システムが動作したら、他のシステムも順次統合：

1. **アニメーションシステム**: `AnimationPresets`の活用
2. **状態管理システム**: ゲーム状態の管理
3. **収益化システム**: 広告表示の統合
4. **分析システム**: プレイヤー行動の分析

詳細は各システムの個別ドキュメントを参照してください。

---

**💡 重要**: このガイドに従えば、音声関連のパス設定エラーを回避し、素早くゲーム開発を開始できます。何か問題が発生した場合は、チェックリストを再確認してください。