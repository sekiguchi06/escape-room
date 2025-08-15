# 1.2 Flutterの環境構築

## Android Studioの設定と開発環境

### Android toolchainの問題対処

`flutter doctor`コマンドを実行した時に以下のようなエラーが表示される場合：

```
[✗] Android toolchain - develop for Android devices
 ✗ Unable to locate Android SDK.
 Install Android Studio from: https://developer.android.com/studio/index.html
```

この場合は、最初にAndroid アプリ開発用のIDE（Integrated Development Environment、統合開発環境）であるAndroid Studioをインストールします。

**Android Studioのインストール手順：**
1. Androidの開発者向けWebサイトからダウンロード：https://developer.android.com/studio/index.html
2. セットアップウィザードの手順に従ってインストール

### Android SDK Command-line Toolsのインストール

Android Studioインストール後、Android toolchainをインストールします：

1. Android Studioを起動
2. アプリケーションメニューから「Settings」を選択
3. Settingsウィンドウの検索窓に「Android SDK」と入力
4. ツリーから「Android SDK」を選択
5. 「SDK Tools」タブを選択
6. 「Android SDK Command-line Tools (latest)」にチェック
7. OKボタンを押してインストール

### Androidライセンスの同意

再び`flutter doctor`を実行し、ライセンス同意のメッセージが表示された場合：

```
[!] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
 ! Some Android licenses not accepted. To resolve this, run: flutter doctor --android-licenses
```

以下のコマンドでライセンスに同意します：

```bash
# Android toolchainのライセンスに同意する
$ flutter doctor --android-licenses
```

対話形式でライセンス同意操作を進め、「All SDK package licenses accepted」と表示されたら完了です。

正常にインストールされると以下のように表示されます：

```
[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
```

## iOSの開発環境をインストールする

### Xcodeのインストール

`flutter doctor`でXcodeの情報を確認し、以下のメッセージが表示される場合：

```
[✗] Xcode - develop for iOS and macOS
 ✗ Xcode installation is incomplete; a full installation is necessary for iOS and macOS development.
 Download at: https://developer.apple.com/xcode/
```

**Xcodeのインストール方法：**
- Mac App StoreからXcodeを検索してインストール（最も簡単）
- またはApple開発者サイトからダウンロード

### Xcodeの設定コマンド

Xcodeインストール後、以下のコマンドを実行：

```bash
# Xcodeコマンドラインツールのディレクトリを指定
$ sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# Xcodeの関連パッケージをインストール
$ sudo xcodebuild -runFirstLaunch

# XcodeとSDKのライセンスに同意
$ sudo xcodebuild -license
```

ライセンス同意時は「agree」と入力します。

### iOS Simulatorランタイムのインストール

iOS Simulatorのランタイムがインストールされていない場合：

```
[!] Xcode - develop for iOS and macOS (Xcode 15.2)
 ✗ Unable to get list of installed Simulator runtimes.
```

以下のコマンドでインストール：

```bash
# iOS Simulatorのランタイムをインストール
$ xcodebuild -downloadPlatform iOS
```

### CocoaPodsのインストール

CocoaPodsがインストールされていない場合：

```
[!] Xcode - develop for iOS and macOS (Xcode 15.2)
 ✗ CocoaPods not installed.
```

CocoaPodsはiOSアプリ開発で用いられるRuby製のパッケージ管理ツールです。macOS標準のRubyでインストール：

```bash
# CocoaPodsをインストール
$ sudo gem install cocoapods
```

正常にインストールされると以下のように表示されます：

```
[✓] Xcode - develop for iOS and macOS (Xcode 15.2)
```

## CocoaPodsがインストールできない場合の対処法

macOS標準のRubyのバージョンではCocoaPodsがインストールできない場合があります。その場合はrbenvを使ってRubyのバージョンを上げます。

### Homebrewのインストール

```bash
# Homebrewをインストール
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Homebrewにパスを通す
$ echo "export PATH=\"\$PATH:/opt/homebrew/bin\"" >> ~/.zshenv

# 実行中のシェルにパスを適用
$ . ~/.zshenv
```

### rbenvのインストール

```bash
# rbenvをインストール
$ brew install rbenv ruby-build

# rbenvにパスを通す
$ echo "eval \"\$(rbenv init - zsh)\"" >> ~/.zshrc

# 実行中のシェルにパスを適用
$ . ~/.zshrc
```

### Rubyのインストール

```bash
# バージョン2.7.5のRubyをインストール
$ rbenv install 2.7.5

# グローバルのRubyのバージョンを2.7.5に設定
$ rbenv global 2.7.5

# Rubyのバージョンを確認
$ ruby --version
```

バージョン2.7.5が適用されていない場合はターミナルを再起動してください。

### CocoaPodsのインストール

```bash
# CocoaPodsをインストール
$ gem install cocoapods

# CocoaPodsのバージョンを確認
$ pod --version
```

無事にバージョンが表示されれば完了です。

## Android Studioの設定 ── Flutterと親和性の高いIDE

Flutterアプリの開発にはAndroid Studio、IntelliJ IDEA、Visual Studio Code（VS Code）がよく用いられます。これらのIDEにはプラグインが提供されており、コード補完やデバッグ、ステップ実行などの機能が利用できます。

### Flutterプラグインのインストール

Android StudioでFlutterプラグインをインストールする手順：

1. アプリケーションメニューから「Settings」を選択
2. Settingsウィンドウの検索窓に「Plugins」と入力
3. ツリーから「Plugins」を選択
4. 「Marketplace」タブを開く
5. 「Flutter」というキーワードでプラグインを検索
6. Flutterプラグインのインストールボタンを押す

FlutterプラグインとDartプラグインが同時にインストールされます。インストール完了後、Android Studioを再起動します。

## Tips

### Xcodeのバージョンを使い分けるインストールのしかた

Mac App StoreからXcodeをインストールした場合は、新しいバージョンのXcodeがリリースされると上書きアップデートされます。実際のアプリ開発では複数バージョンのXcodeの使い分けが必要なこともあります。

この場合、Appleの開発者向けサイト（https://developer.apple.com/download/applications/）からXcodeをダウンロードし、/Applications配下に配置する方法を推奨します。