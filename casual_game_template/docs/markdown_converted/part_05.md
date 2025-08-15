# 1.3 fvmによるFlutterのバージョン管理

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