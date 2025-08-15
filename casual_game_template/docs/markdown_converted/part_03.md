# 目次（続き）

## 第10章　高速で保守性の高いアプリを開発するためのコツ　285

### 10.1　パフォーマンスと保守性、どちらを優先すべきか　286
- 高速でないアプリとは　286
- 高速だが保守性が低い実装　286

### 10.2　高速で保守性の高い実装　287
- **buildメソッドで高コストな計算をしない**　287
- **buildメソッドで大きなウィジェットツリーを構築しない**　289
  - ウィジェットツリーの階層が浅くなるようウィジェットの選択を見なおす　289
- **const修飾子を付与する**　291
  - const修飾子が使えるようウィジェットの選択を見なおす　292
  - 独自のウィジェットクラスにconstantコンストラクタを実装する　292
- **状態を末端のウィジェットに移す**　297
- **Riverpodの状態監視は末端のウィジェットで行う**　300
- **Tips** アプリのパフォーマンスを計測する　303

### 10.3　まとめ　304

---

## 第11章　Flutterアプリ開発に必要なネイティブの知識　305

### 11.1　ネイティブAPIのバージョンと最低サポートOSのバージョン　306

#### 最低サポートOSのバージョン　306
- iOSの最低サポートOSバージョンを設定する　308
- **Tips** XcodeのBuild Settings　308
- Androidの最低サポートOSバージョンを設定する　310

#### ビルドSDKバージョン　310
- iOSのビルドSDKバージョンの設定　310
- AndroidのビルドSDKバージョンの設定　310

#### ターゲットSDKバージョン　311

### 11.2　アプリの設定変更　312

#### アプリ名　312
- iOSのアプリ名を変更する　312
- Androidのアプリ名を変更する　312

#### アプリアイコン　313
- iOSのアプリアイコンを変更する　313
- Androidのアプリアイコンを変更する　314
- アプリアイコンを手軽に生成するパッケージ　315

#### スプラッシュ画面　316
- iOSとAndroidで異なるスプラッシュ画面の位置付け　316
- iOSのスプラッシュ画面　316
- Androidのスプラッシュ画面　317
- スプラッシュ画面を手軽に実現するパッケージ　317

#### アプリのID　319
- iOSのアプリIDを設定する　319
- AndroidのアプリIDを設定する　320

### 11.3　アプリの配布とコード署名　320

#### iOSのコード署名　321
- 管理の難しい秘密鍵　321
- アプリに署名する　322

#### Androidのコード署名　326

#### apkファイルとaabファイル　327
- アプリに署名する　327
- aabファイルをアップロードする　330

### 11.4　まとめ　334

---

## 付録
- **参考Web情報**　335
- **著者プロフィール**　335
- **索引**　336

---

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
- <sup>注5</sup> https://docs.flutter.dev/cookbook