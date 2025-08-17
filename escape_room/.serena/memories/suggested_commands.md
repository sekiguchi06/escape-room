# 開発コマンド一覧

## テスト関連
```bash
flutter test                                    # 全テスト実行
flutter test test/effects/                      # 特定フォルダのテスト
flutter test test/effects/particle_system_test.dart  # 特定ファイルのテスト
```

## 実行・デバッグ
```bash
flutter run -d chrome --web-port=8080          # デバッグモード
flutter run -d chrome --web-port=8080 --release # リリースモード
```

## ビルド
```bash
flutter build web                              # Webビルド
flutter build ios                              # iOSビルド  
flutter build apk                              # Androidビルド
```

## 分析・品質管理
```bash
flutter analyze                                # 静的解析
flutter pub deps                              # 依存関係確認
flutter pub outdated                          # 古いパッケージ確認
```

## Git操作
```bash
git status                                     # 変更確認
git add .                                      # 全変更をステージング
git commit -m "feat: 機能追加"                  # コミット
git push origin master                         # プッシュ
```

## シミュレーション確認（必須）
```bash
# iOS Simulator起動
open -a Simulator
flutter run -d ios

# Android Emulator起動
flutter emulators --launch <emulator_id>
flutter run -d android

# Webブラウザ確認
flutter run -d chrome --web-port=8080
# ブラウザでhttp://localhost:8080にアクセス
```

## Darwin固有コマンド
```bash
ls -la                                         # ファイル一覧（詳細）
find . -name "*.dart" -type f                  # Dartファイル検索
grep -r "pattern" lib/                         # パターン検索
```