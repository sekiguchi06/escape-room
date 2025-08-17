# コードスタイルと規約

## Dartコードスタイル
- **Linting**: package:flutter_lints/flutter.yaml を使用
- **命名規約**: 
  - クラス名: PascalCase (例: TapFireGame)
  - 変数・メソッド名: camelCase (例: gameTimeRemaining)
  - ファイル名: snake_case (例: tap_fire_game.dart)
  - 定数: UPPER_SNAKE_CASE (例: DEFAULT_SPEED)

## Flameコンポーネント規約
- **Component継承**: 適切な基底クラス選択（PositionComponent, CircleComponent等）
- **Mixins活用**: TapCallbacks, HasGameReference等の積極活用
- **anchor設定**: 明示的なAnchor指定（通常はAnchor.center）
- **サイズ管理**: game.sizeからの相対サイズ計算

## ドキュメント規約
- **クラスコメント**: 3行でクラスの目的・使用方法・設計方針を説明
- **設定駆動**: 全ての数値パラメータを設定クラスに外出し
- **デバッグ情報**: debugPrint()による状態変更ログ出力

## プロバイダーパターン実装
```dart
// Abstract Provider契約
abstract class XXXProvider {
  Future<void> initialize();
  // ... 契約メソッド
  void dispose();
}

// 実装クラス
class FlameXXXProvider implements XXXProvider {
  @override
  Future<void> initialize() async { /* 実装 */ }
}
```

## 設定クラス実装パターン
```dart
class GameConfig {
  final Duration duration;
  final double speed;
  
  const GameConfig({this.duration, this.speed});
  
  GameConfig copyWith({Duration? duration, double? speed}) {
    return GameConfig(
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'duration': duration.inSeconds,
    'speed': speed,
  };
}
```

## エラーハンドリング
- **Web環境**: kIsWebでのプラットフォーム判定とMockProvider使用
- **初期化エラー**: late fieldの適切な初期化とnullチェック  
- **状態遷移**: canTransitionTo()による遷移可能性チェック