# iOSシミュレーター言語テストガイド

## 📱 実行環境
- 実行デバイス: iPhone 16 Pro Simulator (iOS 18.6)
- Flutterバージョン: 3.16.9+
- 対応言語: 日本語(ja)、英語(en)

## 🎯 手動テスト手順

### ステップ1: シミュレーター言語変更
```
1. iOSシミュレーターを起動
2. Settingsアプリをタップ
3. General > Language & Region をタップ
4. iPhone Language をタップ
5. 「English」または「日本語」を選択
6. "Done"をタップして適用
7. シミュレーターが再起動されるまで待機
```

### ステップ2: Flutterアプリテスト
```
1. flutter run -d [DEVICE_ID] でアプリ起動
2. アプリタイトルの言語確認
3. ボタンテキストの言語確認
4. 期待される表示と実際の表示を比較
```

## 🔄 コマンドライン自動テスト

### 英語設定
```bash
# シミュレーターを英語に設定
xcrun simctl spawn E8C74717-4FBF-41FC-97CE-234ED61CF757 defaults write NSGlobalDomain AppleLanguages '("en")'

# 再起動
xcrun simctl shutdown E8C74717-4FBF-41FC-97CE-234ED61CF757
xcrun simctl boot E8C74717-4FBF-41FC-97CE-234ED61CF757

# Flutterアプリ起動
flutter run -d E8C74717-4FBF-41FC-97CE-234ED61CF757
```

### 日本語設定
```bash
# シミュレーターを日本語に設定
xcrun simctl spawn E8C74717-4FBF-41FC-97CE-234ED61CF757 defaults write NSGlobalDomain AppleLanguages '("ja")'

# 再起動
xcrun simctl shutdown E8C74717-4FBF-41FC-97CE-234ED61CF757
xcrun simctl boot E8C74717-4FBF-41FC-97CE-234ED61CF757

# Flutterアプリ起動
flutter run -d E8C74717-4FBF-41FC-97CE-234ED61CF757
```

## 📊 期待される表示結果

### 日本語表示 (ja)
| 項目 | 期待値 |
|------|--------|
| アプリタイトル | "カジュアルゲームテンプレート" |
| 脱出ゲームボタン | "🔓 脱出ゲームをプレイ" |

### 英語表示 (en)
| 項目 | 期待値 |
|------|--------|
| アプリタイトル | "Casual Game Template" |
| 脱出ゲームボタン | "🔓 Play Escape Room" |

## 🔧 トラブルシューティング

### 言語が切り替わらない場合
1. シミュレーターを完全にシャットダウン
2. Xcodeを再起動
3. `flutter clean && flutter pub get` を実行
4. 再度テスト実行

### シミュレーター一覧確認
```bash
xcrun simctl list devices
```

### 特定シミュレーターの再起動
```bash
xcrun simctl shutdown [DEVICE_ID]
xcrun simctl boot [DEVICE_ID]
```

## ✅ テスト完了確認項目

- [ ] 日本語環境でのアプリ起動確認
- [ ] 英語環境でのアプリ起動確認  
- [ ] 言語切り替え後の文字列変更確認
- [ ] UIレイアウト崩れがないことの確認
- [ ] フォント表示の正常性確認

## 📚 参考資料

- [Flutter Internationalization Guide](https://docs.flutter.dev/ui/accessibility-and-localization/internationalization)
- [iOS Simulator Command Reference](https://developer.apple.com/documentation/xcode/running-your-app-in-the-simulator-or-on-a-device)
- [Xcode Simulator User Guide](https://help.apple.com/simulator/mac/current/)

---

**注意**: このガイドは現在の実装（最小限の国際化対応）に基づいています。新しい言語や文字列を追加した場合は、適切にテスト項目を更新してください。