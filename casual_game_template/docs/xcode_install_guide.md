# Xcodeインストールガイド

## インストール手順

1. **App Storeからインストール中**
   - サイズ: 約15GB
   - 予想時間: 2-4時間
   - 開始時刻: 記録してください

2. **インストール完了後の手順**

### 1. Xcodeの初期設定
```bash
# Xcodeのパスを設定
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# ライセンス同意と初期設定
sudo xcodebuild -runFirstLaunch
```

### 2. CocoaPodsのインストール
```bash
# Homebrewを使用してインストール（推奨）
brew install cocoapods

# インストール確認
pod --version
```

✅ 完了済み: CocoaPods 1.16.2 インストール済み

### 3. Flutter doctorで確認
```bash
flutter doctor -v
```

### 4. iOSシミュレータの起動テスト
```bash
# 利用可能なシミュレータを確認
xcrun simctl list devices

# シミュレータを起動
open -a Simulator
```

### 5. Flutterプロジェクトでテスト
```bash
cd /Users/sekiguchi/git/proto/casual_game_template

# iOSビルドの準備
flutter pub get
cd ios && pod install && cd ..

# iOSシミュレータで実行
flutter run
```

## トラブルシューティング

### Xcodeライセンスエラーの場合
```bash
sudo xcodebuild -license accept
```

### CocoaPodsエラーの場合
```bash
# Homebrewでインストール（代替方法）
brew install cocoapods
```

### シミュレータが起動しない場合
1. Xcode → Preferences → Components
2. iOS Simulatorをダウンロード

## 進捗記録
- [ ] Xcodeダウンロード開始
- [ ] Xcodeインストール完了
- [ ] 初期設定完了
- [ ] CocoaPods インストール完了
- [ ] flutter doctor 問題解決
- [ ] iOSビルド成功