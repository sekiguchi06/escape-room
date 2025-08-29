# Audio System Constraints - FlameAudio制約とディレクトリ構成

## ⚠️ 重要：FlameAudioの必須制約事項

### FlameAudioは`assets/audio/`を強制している

**FlameAudioパッケージは内部で`assets/audio/`プレフィックスを自動付加します。**
そのため、**`assets/sounds/`や他のディレクトリのオーディオファイルは見つからずエラーになります。**

```dart
// ❌ これはエラーになる
await FlameAudio.play('assets/sounds/menu.mp3');

// ✅ FlameAudioは自動でassets/audio/を付加するため、ファイル名のみ指定
await FlameAudio.play('menu.mp3'); // 内部的に'assets/audio/menu.mp3'として解決
```

### 証拠コード (FlameAudioProvider:309行目)
```dart
/// アセットパスを解決（flame_audio公式準拠：assets/audio/直下に配置）
String _resolveAssetPath(String assetId, {required bool isBgm}) {
  // ...
  // flame_audio公式準拠の実験：audio/プレフィックスなしでテスト
  // FlameAudioが内部でassets/audio/を自動付加する可能性
  resolvedPath = fileName; // 'menu.mp3'のような単純名を返す
  // ...
}
```

## 📁 プロジェクトのディレクトリ構成

### ✅ 正しい構成
```
escape_room/
├── assets/
│   └── audio/          # 全てのオーディオファイルはここに配置
│       ├── menu.mp3
│       ├── tap.wav
│       ├── decision51.mp3
│       └── ...
└── pubspec.yaml
```

### ❌ 間違った構成
```
escape_room/
├── assets/
│   ├── audio/          # FlameAudioで動作する
│   │   └── menu.mp3
│   └── sounds/         # ❌ FlameAudioでエラーになる
│       └── tap.wav
└── pubspec.yaml
```

## 🔧 pubspec.yamlの設定

### ✅ 正しい設定
```yaml
flutter:
  assets:
    - assets/audio/     # FlameAudio対応
    - assets/images/
    - assets/fonts/
```

### ❌ 間違った設定
```yaml
flutter:
  assets:
    - assets/audio/
    - assets/sounds/    # ❌ FlameAudioでは使用不可
```

## 🚨 移行作業時の注意点

### 既存の`assets/sounds/`から移行する場合

1. **全ファイルを`assets/audio/`に移動**
   ```bash
   cp assets/sounds/* assets/audio/
   rm -rf assets/sounds/
   ```

2. **pubspec.yamlから`assets/sounds/`エントリを削除**

3. **重複ファイルの整理**
   - 同名ファイルがある場合は適切に統合

4. **自動生成ファイル更新**
   ```bash
   flutter packages get  # assets.gen.dartを再生成
   ```

## 💡 開発者向けガイド

### オーディオファイル追加時の手順

1. **ファイルを`assets/audio/`に配置**
2. **pubspec.yamlにアセットパスが含まれているか確認**
3. **FlameAudioでファイル名のみで再生**
   ```dart
   await FlameAudio.play('new_sound.mp3'); // パス指定不要
   ```

### デバッグ時のチェックポイント

- ❌ `FileSystemException`が発生 → ファイルが`assets/audio/`にない
- ❌ `AssetNotFoundException` → pubspec.yamlの設定不備
- ✅ 正常再生 → 正しく設定されている

## 📚 関連ファイル

- `lib/framework/audio/providers/flame_audio_provider.dart` - FlameAudio実装
- `lib/framework/audio/game_audio_helper.dart` - 設定ヘルパー
- `pubspec.yaml` - アセット定義
- `lib/gen/assets.gen.dart` - 自動生成アセット定義

## 🏷️ 更新履歴

- 2025-08-25: FlameAudio制約の発見と`assets/sounds/`から`assets/audio/`への統合完了
- プロジェクト開始時から`assets/audio/`使用を前提とした設計だったが、途中で`assets/sounds/`が混在していた問題を解決

---

**⚠️ 重要：今後オーディオファイルを追加する場合は、必ず`assets/audio/`ディレクトリに配置してください。**