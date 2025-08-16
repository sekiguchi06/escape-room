# 第1章　環境構築とアプリの実行
*Flutter SDK、Android Studio、Xcode*

本章では、Flutterの特徴を簡単に紹介したのち、環境構築の手順を解説します。Flutter公式がアナウンスしている環境構築の手順に加え、筆者が普段から利用しているツールなども紹介します。最後には、テンプレートのFlutterアプリを起動するところまでを実践します。

## 1.1　なぜFlutterが注目を集めているのか

FlutterはGoogleを中心としたオープンソースコミュニティによって開発されているマルチプラットフォームフレームワークです<sup>注1</sup>。これまでのマルチプラットフォーム技術とは一線を画した実現方式を持ち、高速な実行速度と優れた開発者体験が特徴です。このFlutterがスマートフォンアプリの開発において、シェアを伸ばしています。

### マルチプラットフォーム

Flutterは1つのコードベースからさまざまなプラットフォームへアプリケーションを提供することができます。そのサポート環境は、公式発表でモバイル（iOSおよびAndroid）、デスクトップ（Windows、macOSおよびLinux）、Webフロントエンドと多岐にわたります。

また、複数のプラットフォームで安定した動作を実現する構成になっている点も特徴です。マルチプラットフォーム技術の中にはXamarin<sup>注2</sup>のようにネイティブUI（User Interface）をラップした形式のものがあります。こうしたフレームワークでは、複数プラットフォームのAPIをラップする過程で、吸収しきれない差異が発生するケースがあります。一方でFlutterはネイティブのUIを使わない、独自のレンダリングのしくみを持っています。そのため「iOSでデバッグしたあと、Androidでデバッグすると想定したUIになっていない」といった動作差異が限りなく小さくなります。

なお、本書ではiOSとAndroidを対象としたモバイル開発についてのみ取り扱います。

### 高速な実行速度

Flutterで開発したアプリケーションはネイティブコードにコンパイルされます。Cordova<sup>注3</sup>などのようにWebView上で動作するマルチプラットフォームフレームワークよりも、高速に動作することが期待できます。開発元のGoogleは、前項でも触れた独自のレンダリングのしくみによる高いパフォーマンスをアピールしています。筆者の体感としても、他のいくつかのマルチプラットフォームフレームワークと比較して、Flutterは安定して高いパフォーマンスを発揮しているように感じます。

### 優れた開発者体験

フレームワークの浸透、発展において優れた開発者体験は重要であり、Flutterはその要素を十分に持っています。筆頭に挙げられるのはホットリロードで、ソースコードの変更を実行中のアプリに即座に反映するしくみです。プログラムでUIを微調整したらすぐにアプリの画面に反映されるため、トライ＆エラーをすばやく繰り返すことが可能です。また、コードラボ（チュートリアル）<sup>注4</sup>やクックブック（実装例）<sup>注5</sup>が充実しています。パッケージ管理ツールやコードの静的解析ツールなどが統合されている点も開発者にとってうれしいポイントの一つです。

## 1.2　Flutterの環境構築

それではFlutterの開発環境を構築しましょう。Flutterの環境構築は大きく2つの段階があります。

1つ目はFlutter SDK（Software Development Kit）のインストール、2つ目は実行するプラットフォームであるiOSとAndroidの開発環境のインストールです。

なお、iOSを開発対象にすることもあり、本書ではmacOS環境についてのみ取り扱います。執筆時の環境は以下です。

- **macOS Sonoma 14.3**
- **Flutter 3.16.9**

### Flutterのインストール

本項のいくつかの手順は、後述の「1.3 fvmによるFlutterのバージョン管理」の節で解説するfvmというツールを導入することで省略できます。しかし、はじめての環境構築は内容を理解するためにも、手順を踏んでインストールしてみることをお勧めします。

まずは、Flutterの公式WebサイトからFlutter SDKのZIPファイルをダウンロードします。URLの参照先はiOSの環境構築に関するページですが、Flutter SDKのZIPファイルは他のプラットフォームと共通です。

- https://docs.flutter.dev/get-started/install/macos/mobile-ios?tab=download#install-the-flutter-sdk

ZIPファイルはIntel CPU向けとApple Silicon向けが用意されていますので、お使いの環境に合わせてダウンロードしてください。

Apple Silicon搭載のMacをお使いの場合は、加えてRosetta 2をインストールしましょう。SDKに含まれる一部の実行ファイルがx64アーキテクチャで提供されており、これらをApple Silicon搭載のMacで動作させるためにRosetta 2が必要になります。Rosetta 2は以下のコマンドでインストールします。

```bash
# Rosetta 2をインストール
$ sudo softwareupdate --install-rosetta --agree-to-license
```

ダウンロードしたZIPファイルを解凍し、任意のディレクトリに配置します。今回は公式Webサイトで紹介されているディレクトリ（~/development）で進めます。

```
~/development
└── flutter
    ├── bin
    ├── dev
    ├── examples
    ├── packages
    └── ...（省略）
```

次に、配置したFlutter SDKにパスを通します。以下のコマンドを実行し、SDKに同梱されている実行ファイルをどのディレクトリからでも実行できるようにします。

```bash
# flutterのコマンドラインツールにパスを通す
$ echo "export PATH=\"\$PATH:$HOME/development/flutter/bin\"" >> ~/.zshenv
# 実行中のシェルにパスを適用
$ . ~/.zshenv
```

これでFlutterのインストールは完了です。確認のため、Flutterのバージョンをターミナルに出力してみましょう。

```bash
# flutterのバージョンを出力
$ flutter --version
```

環境にgitがインストールされていない場合は、デベロッパツールのインストールを促すダイアログが表示されます（図1.1）。これはFlutterのコマンドラインツールが、内部でgitコマンドを呼び出しているためです。インストールしておきましょう。

![図1.1 デベロッパツールのインストールダイアログ](図1.1)

筆者の環境では`flutter --version`の結果は以下のように出力されました。

```
Flutter 3.16.9 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 41456452f2 (32 hours ago) • 2024-01-25 10:06:23 -0800
Engine • revision f40e976bed
Tools • Dart 3.2.6 • DevTools 2.28.5
```

### プラットフォームごとの環境のインストール

Flutterで開発したプロジェクトをiOSやAndroidへビルドするために、各プラットフォームの開発環境を構築する必要があります。開発環境の情報を出力するコマンド（`flutter doctor`）を活用しながら各プラットフォームの開発環境をインストールしていきましょう。

```bash
# flutterの開発環境の情報を出力
$ flutter doctor
```

**図1.2　flutter doctorの出力結果**

```
[✓] Flutter (Channel stable, 3.16.9, on macOS 14.3 23D56 darwin-arm64, locale ja-JP)
[✗] Android toolchain - develop for Android devices
    ✗ Unable to locate Android SDK.
      Install Android Studio from: https://developer.android.com/studio/index.html
      On first launch it will assist you in installing the Android SDK components.
      (or visit https://flutter.dev/docs/get-started/install/macos#android-setup for 
      detailed instructions).
      If the Android SDK has been installed to a custom location, please use
      `flutter config --android-sdk` to update to that location.

[✗] Xcode - develop for iOS and macOS
    ✗ Xcode installation is incomplete; a full installation is necessary for iOS and 
      macOS development.
      Download at: https://developer.apple.com/xcode/
      Or install Xcode via the App Store.
      Once installed, run:
      sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
      sudo xcodebuild -runFirstLaunch
    ✗ CocoaPods not installed.
      CocoaPods is used to retrieve the iOS and macOS platform side's plugin code 
      that responds to your plugin usage on the Dart side.
      Without CocoaPods, plugins will not work on iOS or macOS.
      For more info, see https://flutter.dev/platform-plugins
      To install see https://guides.cocoapods.org/using/getting-started.html#install
      ation for instructions.

[✗] Chrome - develop for the web (Cannot find Chrome executable at /Applications/Google
     Chrome.app/Contents/MacOS/Google Chrome)
    ! Cannot find Chrome. Try setting CHROME_EXECUTABLE to a Chrome executable.

[!] Android Studio (not installed)
[✗] Connected device (1 available)
[✗] Network resources
```

コマンドの出力結果（図1.2）の❶と❸がAndroidの開発環境、❷がiOSの開発環境に関わる項目です。

#### Androidの開発環境をインストールする

あらためて`flutter doctor`の出力結果から、Androidの開発環境に関わる項目を確認します。Androidの開発環境がまだ構築されていない場合は、以下

### 参考リンク

- <sup>注1</sup> https://flutter.dev/
- <sup>注2</sup> https://docs.microsoft.com/ja-jp/xamarin/
- <sup>注3</sup> https://cordova.apache.org
- <sup>注4</sup> https://docs.flutter.dev/codelabs
- <sup>注5</sup> https://docs.flutter.dev/cookbook# 1.2 Flutterの環境構築

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

この場合、Appleの開発者向けサイト（https://developer.apple.com/download/applications/）からXcodeをダウンロードし、/Applications配下に配置する方法を推奨します。# 1.3 fvmによるFlutterのバージョン管理

## fvmによるFlutterのバージョン管理

プロジェクトごとにFlutterのバージョンを切り替えることができるfvmというツールを紹介します。fvmを利用することで、Flutterのバージョンを切り替えるためにFlutter SDKを再インストールする手間を省くことができます。「過去に開発したFlutterアプリをメンテナンスするために、古いバージョンのFlutterを入れなおす……」といった面倒ごとから解放されます。

### fvmのインストール

まずfvmをインストールするために、macOS向けのパッケージ管理ツールHomebrewをインストールします。CocoaPodsのインストール時にHomebrewを導入した場合はこの手順は不要です。

```bash
# Homebrewをインストール
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Homebrewにパスを通す
$ echo "export PATH=\"\$PATH:/opt/homebrew/bin\"" >> ~/.zshenv

# 実行中のシェルにパスを適用
$ . ~/.zshenv
```

次にHomebrewを利用してfvmをインストールします。

```bash
# fvmのGitHubリポジトリをHomebrewに追加
$ brew tap leoafarias/fvm

# fvmをインストール
$ brew install fvm
```

これでfvmのインストールは完了です。

### fvmを利用したFlutterのインストール

続いて、fvmを利用して最新安定版のFlutterおよびそれに対応したDartの環境をインストールしましょう。インストール可能なFlutterバージョンをターミナルから確認します。

```bash
# インストール可能なFlutterバージョンを出力
$ fvm releases
```

stableと書かれたバージョンが最新の安定版となります。執筆時点のコマンド実行結果を以下に示します。最新の安定版は3.16.9でした。

```
.
.
.
（省略）
Nov 30 23 │ 3.16.2 
Dec 5 23 │ 3.18.0-0.1.pre 
Dec 6 23 │ 3.16.3 
Dec 13 23 │ 3.16.4 
Dec 14 23 │ 3.18.0-0.2.pre 
Dec 20 23 │ 3.16.5 
Jan 10 24 │ 3.16.6 
Jan 10 24 │ 3.19.0-0.1.pre 
Jan 11 24 │ 3.16.7 
Jan 17 24 │ 3.16.8 
Jan 18 24 │ 3.19.0-0.2.pre 
--------------------------------------
Jan 25 24 │ 3.16.9 stable
--------------------------------------
--------------------------------------
Jan 26 24 │ 3.19.0-0.3.pre beta
--------------------------------------
```

それではバージョン3.16.9のFlutterをインストールします。

```bash
# バージョン3.16.9のFlutterをインストール
$ fvm install 3.16.9
```

これでFlutterのインストールは完了です。

後述の「1.4 プロジェクトの作成」の節で、プロジェクトで利用するfvmのFlutterのバージョンを指定する方法を解説します。その設定が完了すると、プロジェクトのディレクトリ配下でfvmコマンドを介してFlutterを使用することができます。たとえば、Flutterのバージョン番号を確認するには以下のように実行します。

```bash
# fvmを経由してFlutterのバージョンを出力
$ fvm flutter --version

# fvmを経由してDartのバージョンを出力
$ fvm dart --version
```

「1.2 Flutterの環境構築」の節でインストールしたFlutterはそのまま残っており、fvmコマンドを使わなければそのまま利用可能です。ちなみに、筆者はshellのエイリアスを利用してfvmの入力を省略しています。

```bash
# ~/.zshrc 
alias flutter="fvm flutter"
```

なお、第2章以降ではfvmコマンドを省略してflutterコマンド、dartコマンドを扱います。ご自身の環境、コマンドを実行するディレクトリにあわせて読み替えてください。

# 1.4 プロジェクトの作成

FlutterプロジェクトはAndroid StudioからGUI（Graphical User Interface）で作成します。

## Android Studioでの作成手順

Android Studioのアプリケーションメニューから「File」➡「New」➡「New Flutter Project」の順で選択すると、ウィンドウが表示されます。

### 新規プロジェクトウィンドウの設定

ウィンドウ左のリストで「Flutter」が選択されていることを確認します。「Flutter SDK path」はfvmでインストールしたFlutter SDKを選択します。「Next」をクリックすると、プロジェクトの詳細を選択する画面に切り替わります。

### プロジェクト詳細の設定

- **Project name**: 任意の名前でけっこうです
- **Project location**: プロジェクトを作成するディレクトリを変更したい場合は任意に編集
- **Project type**: ApplicationになっていることをiOSとAndroidで動作するアプリのプロジェクト作成のため確認
- **Platforms**: AndroidとiOSにチェックが入っていることを確認

「Create」をクリックすると、Android Studioで作成したFlutterのテンプレートプロジェクトが開きます。

## テンプレートプロジェクトをのぞいてみよう

作成されたプロジェクトのファイル、ディレクトリは以下のような構成になっています。

| ファイル名、ディレクトリ名 | 説明 |
|---------------------------|------|
| .dart_tool | Dart言語のツールが配置されるディレクトリ |
| .idea | Android Studioのプロジェクト設定ファイルが配置されるディレクトリ |
| .metadata | Flutterツールが利用するファイル |
| analysis_options.yaml | コード静的解析のオプションファイル。lintルールを変更する場合に編集する |
| android | Android Studioのプロジェクト。Androidネイティブのコード、しくみを利用する場合に閲覧、編集する |
| ios | Xcodeのプロジェクト。iOSネイティブのコード、しくみを利用する場合に閲覧、編集する |
| lib | Flutterの実装ファイルを配置するディレクトリ。Dartの実装ファイルはここに配置する |
| my_app.iml | Android Studioのモジュールファイル |
| pubspec.lock | パッケージ（ライブラリなど）のバージョンを解決するファイル |
| pubspec.yaml | Flutterプロジェクトの設定、依存関係を記述するファイル。パッケージ（ライブラリなど）やアセット類はこのファイルに記述する |
| test | Flutterのテストコードを配置するディレクトリ |

## fvmの設定

作成したプロジェクトに対してfvmの設定を行います。今回はFlutterのバージョンを3.16.9に設定します。プロジェクトのルートディレクトリで以下のコマンドを実行します。

```bash
# プロジェクトで利用するfvmのバージョンを設定
$ fvm use 3.16.9
```

すると、プロジェクトのルートディレクトリに.fvmというディレクトリが作成され、その中にFlutter SDKへのシンボリックリンクが配置されます。もし、gitでバージョン管理する場合は除外するように.gitignoreを編集しておきましょう。

```bash
# .gitignore 
# 省略
.fvm/flutter_sdk # この行を追加
```

### Android StudioのFlutter SDK Path設定

続いて、Android Studioが参照するFlutter SDKのパスを変更します。

1. Android Studioを起動
2. アプリケーションメニューから「Settings」を選択
3. Settingsウィンドウの検索窓に「Flutter」と入力
4. ツリーの中から「Flutter」を選択
5. 「Flutter SDK Path」へ.fvm/flutter_sdkのシンボリックリンクが示している先のパスを入力
6. OKボタンを押す

# 1.5 Flutterアプリの実行

それではさっそくアプリを実行してみましょう。まずは「Flutter Device Selection」ボタンから実行デバイスを選択します。

## iOS Simulatorでの実行

「Flutter Device Selection」のボタンをクリックすると「Open iOS Simulator」という項目があります。これを選択するとiOS Simulatorが起動します。

iOS Simulatorが起動したら、Android StudioのNavigation Barにある実行ボタンをクリックします。

するとiOS Simulator上でテンプレートのFlutterアプリが起動します。

### トラブルシューティング

今まで一度もiOS Simulatorを起動したことがない環境では、エラーが発生することがあります。筆者の環境では、Xcodeから一度だけiOS Simulatorを起動すると解決しました。

XcodeからiOS Simulatorを起動するには、Xcodeのアプリケーションメニューから「Xcode」➡「Open Developer Tool」➡「Simulator」の順で選択します。

## Android Emulatorでの実行

作成済みのAndroid Emulatorを探します。Android Studioのバージョンによって、初期状態でAndroid Emulatorが作成されている場合と作成されていない場合があります。Android Studioのアプリケーションメニューから「Tools」➡「Device Manager」を選択します。Device Managerの画面にEmulatorが表示されなければ、以下の手順で作成します。

### Android Emulatorを作成する

1. Device Managerの画面で「Create virtual device...」ボタンをクリック
2. Android Emulatorを作成するウィンドウが表示される
3. Emulatorの画面解像度や仮想ディスプレイサイズを選択し「Next」ボタンをクリック

### EmulatorのAPIレベル選択

続いてEmulatorのAPIレベルを選択します。本書ではAPI Level 34を選択しました。なお、FlutterがサポートしているAPIレベルは公式ドキュメントの「Supported deployment platforms」で確認できます。

選択したAPIレベルのシステムイメージをダウンロード、選択し「Next」ボタンをクリックします。

最後にEmulatorの名前やその他の設定を行う画面に遷移します。特に必要なければ初期値のまま「Finish」ボタンをクリックします。これでAndroid Emulatorの作成が完了しました。

### Android Emulatorを起動し、アプリを実行する

iOSのときと同様に「Flutter Device Selection」のボタンをクリックして、作成したAndroid Emulatorを選択します。リストに現れない場合は「Refresh」を選択してみましょう。

Android Emulatorのウィンドウが表示されない場合は、Android Studioのメニューから「View」➡「Tool Windows」➡「Running Devices」を選択すると起動中のAndroid Emulatorが表示されます。

Android Emulatorが起動したら実行ボタンをクリックします。

するとAndroid Emulator上でテンプレートのFlutterアプリが起動します。

# 1.6 まとめ

Flutterの開発環境をインストールし、iOS SimulatorとAndroid Emulatorでアプリが実行できるところまでを体験しました。

マルチプラットフォームであるため環境を整える作業は多くの手順が必要となりますが、flutter doctorコマンドのようなサポートツールが用意されていました。アプリの実行もエディタのプラグインによってスムーズだったかと思います。これらの優れた開発者体験もFlutterの魅力の一つですね。