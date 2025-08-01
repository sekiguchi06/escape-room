# 🚀 カジュアルゲーム 10分クイックスタート

## 📋 AIへの指示テンプレート

以下をコピペしてAIに指示してください：

```
新しいカジュアルゲーム「[ゲーム名]」を作成してください。

1. プロジェクト作成
2. casual_game_templateフレームワークを流用
3. 音声システム統合
4. 基本ゲームロジック実装

手順:
- フレームワークの docs/framework_usage_guide.md を参照
- GameAudioHelper を使用して音声システム統合
- 必要なアセットファイル（BGM・SFX）の配置指示
- ブラウザでの動作確認まで実行
```

## 🎵 音声ファイル準備（最優先）

### Step 1: 音声ファイル配置
```
your_project/
├── assets/
│   └── audio/
│       ├── bgm/
│       │   └── menu.mp3    # メニュー用BGM
│       └── sfx/
│           ├── tap.wav     # タップ音
│           ├── success.wav # 成功音
│           └── error.wav   # エラー音
```

### Step 2: pubspec.yaml設定
```yaml
flutter:
  assets:
    - assets/audio/bgm/
    - assets/audio/sfx/
```

## 💻 コード実装テンプレート

### 最小構成ゲーム
```dart
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:casual_game_template/framework/core/configurable_game.dart';
import 'package:casual_game_template/framework/audio/game_audio_helper.dart';
import 'package:casual_game_template/framework/audio/providers/audioplayers_provider.dart';

class MyGame extends ConfigurableGame<GameState, MyGameConfig> with TapCallbacks {
  late TextComponent _statusText;
  int _score = 0;
  
  MyGame() : super(
    configuration: MyGameConfiguration.defaultConfig,
    debugMode: true,
  );
  
  @override
  AudioProvider createAudioProvider() => AudioPlayersProvider();
  
  @override
  Future<void> initializeGame() async {
    // 音声システム統合（GameAudioHelperを使用）
    await GameAudioIntegration.setupAudio(
      audioManager: audioManager,
      bgmFiles: {'menu': 'menu.mp3'},
      sfxFiles: {
        'tap': 'tap.wav',
        'success': 'success.wav',
        'error': 'error.wav',
      },
      debugMode: true,
    );
    
    // UI初期化
    _statusText = TextComponent(
      text: 'TAP TO START - Score: $_score',
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
    add(_statusText);
    
    // BGM開始
    audioManager.playBgm('menu');
  }
  
  @override
  void onTapDown(TapDownEvent event) {
    // タップ音再生
    audioManager.playSfx('tap', volumeMultiplier: 0.8);
    
    // スコア更新
    _score++;
    _statusText.text = 'Score: $_score';
    
    // 成功音再生（10点ごと）
    if (_score % 10 == 0) {
      audioManager.playSfx('success');
    }
  }
}
```

### main.dart
```dart
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/my_game.dart';

void main() {
  runApp(MyGameApp());
}

class MyGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Casual Game',
      home: Scaffold(
        appBar: AppBar(title: const Text('My Casual Game')),
        body: GameWidget<MyGame>.controlled(
          gameFactory: MyGame.new,
        ),
      ),
    );
  }
}
```

## ✅ 確認チェックリスト

流用成功の確認項目：

### 基本動作
- [ ] `flutter run -d chrome` でブラウザ起動
- [ ] ゲーム画面表示
- [ ] エラーなしで初期化完了

### 音声システム
- [ ] 初期化時にBGM自動再生（ユーザーインタラクション後）
- [ ] タップ時にタップ音再生
- [ ] 成功時に成功音再生
- [ ] コンソールに音声ログ出力

### 期待されるログ
```
🎵 GameAudioIntegration: Audio setup completed
  BGM files: menu
  SFX files: tap, success, error
🎵 Audio system initialized with GameAudioHelper
SFX playing: tap (volume: 0.64)
SFX playing: success (volume: 0.8)
```

## 🚨 よくあるエラーと解決法

### エラー1: "AudioPlayerException ... Format error"
**原因**: 音声ファイルが存在しないか、パス設定が間違っている
**解決**: assets/audio/ フォルダに実際の音声ファイルを配置

### エラー2: "BGM asset not found"
**原因**: GameAudioIntegration の bgmFiles 設定とファイル名の不一致
**解決**: bgmFiles のキーとファイル名を確認

### エラー3: "NotAllowedError: play() failed"
**原因**: ブラウザの自動再生ポリシー
**解決**: 正常（ユーザーがタップした後にBGM再生される）

## 🎮 応用例

### パズルゲーム
```dart
bgmFiles: {'puzzle': 'puzzle_theme.mp3'},
sfxFiles: {
  'move': 'piece_move.wav',
  'match': 'match_sound.wav',
  'clear': 'line_clear.wav',
},
```

### アクションゲーム
```dart
bgmFiles: {'action': 'action_theme.mp3'},
sfxFiles: {
  'jump': 'jump.wav',
  'hit': 'hit.wav',
  'coin': 'coin.wav',
  'powerup': 'powerup.wav',
},
```

## 🔄 次のステップ

音声システムが動作したら：

1. **アニメーションシステム**: `AnimationPresets` を追加
2. **状態管理**: ゲームオーバー・リスタート機能
3. **収益化**: 広告システム統合
4. **分析**: プレイヤー行動追跡

---

**💡 このテンプレートを使用すれば、10分でフレームワークを流用した基本ゲームが完成します！**