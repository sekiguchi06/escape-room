# iOSシミュレーター言語テストガイド

**更新日**: 2025年8月18日
**検証済み**: 現在の実装環境で動作確認済み

## 📱 実行環境
- 実行デバイス: iPhone 16 Pro Simulator (iOS 18.6)
- Flutterバージョン: 3.32.8 (2025年8月時点)
- 対応言語: 日本語(ja)、英語(en)
- プロジェクト: Escape Room専用ゲーム

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
| 項目 | 期待値 | 実装状況 |
|------|--------|----------|
| アプリタイトル | "脱出マスター" | ✅ app_ja.arb実装済み |
| ゲームスタートボタン | "🔓 脱出ゲームをプレイ" | ✅ app_ja.arb実装済み |
| ゲーム内UI | "インベントリ"、"パズル" | ✅ app_ja.arb実装済み |

### 英語表示 (en)
| 項目 | 期待値 | 実装状況 |
|------|--------|----------|
| アプリタイトル | "Escape Master" | ✅ app_en.arb実装済み |
| ゲームスタートボタン | "🔓 Play Escape Room" | ✅ app_en.arb実装済み |
| ゲーム内UI | "Inventory"、"Puzzle" | ✅ app_en.arb実装済み |

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

### 基本動作確認
- [ ] 日本語環境でのアプリ起動確認
- [ ] 英語環境でのアプリ起動確認  
- [ ] 言語切り替え後の文字列変更確認
- [ ] UIレイアウト崩れがないことの確認
- [ ] フォント表示の正常性確認

### エスケープルーム固有確認
- [ ] ゲーム内文字列の多言語対応確認
- [ ] パズル説明文の言語切り替え確認
- [ ] ヒントメッセージの多言語表示確認

## 📚 参考資料

- [Flutter Internationalization Guide](https://docs.flutter.dev/ui/accessibility-and-localization/internationalization)
- [iOS Simulator Command Reference](https://developer.apple.com/documentation/xcode/running-your-app-in-the-simulator-or-on-a-device)
- [Xcode Simulator User Guide](https://help.apple.com/simulator/mac/current/)

## 🔄 継続的テスト運用

### 新機能追加時のテスト
1. **新文字列追加時**: app_ja.arb, app_en.arbの両方に追加
2. **UIコンポーネント追加時**: 言語切り替えテストを実行
3. **ゲーム機能拡張時**: エスケープルーム固有文字列のテスト追加

### 定期実行推奨
- **リリース前**: 全言語でのフルテスト実行
- **機能追加後**: 該当機能の言語テスト実行
- **Flutter更新後**: 国際化機能の動作確認

---

**注意**: このガイドは2025年8月時点の実装に基づいており、ARBファイルとの整合性が確認済みです。新しい言語や文字列を追加した場合は、テスト項目を適切に更新してください。