# 第5章 テーマとルーティング

本章ではFlutterフレームワークの機能を紹介します。その中でも「テーマ」「画面遷移」この2点に的を絞って解説します。筆者の経験上、この2つの要素はおおよそどのようなアプリを開発する場合にも知識として必要になり、後工程での方針変更は手間がかかることがあります。

前章は、はじめに整えておくべき要素を紹介しました。本章では、はじめに設計しておくとよい要素として、フレームワークの2つの要素を紹介します。

なお、本章では解説に重きを置くため、関連したコードの断片を掲載していますので、省略されている部分がある点に留意してください。完全なサンプルコードの場合は、その旨を明記しています。手もとで動作確認する際は、`./lib/main.dart`を書き換えてください。

構文はバリュー全体をブレース（`{ }`）で囲い、プレースホルダ名に続けて、`plural`というキーワードを記述します。

たとえば、日本語のarbファイルを以下のように作成したとします。

**./lib/l10n/app_ja.arb**

```json
{
  // 省略
  "numOfSearchResult": "{count, plural, =0{検索結果はありません} other{検索結果は{count}件です}}",
  "@numOfSearchResult": {
    "description": "検索結果",
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}
```

実行結果は次のようになります。

```dart
Text(l10n.numOfSearchResult(0)), 
// => 検索結果はありません
Text(l10n.numOfSearchResult(1)), 
// => 検索結果は1件です
Text(l10n.numOfSearchResult(2)), 
// => 検索結果は2件です
```

この英語訳を作ります。検索結果を「result」と訳し、さらに「result」と「results」を使い分けます。arbファイルを以下のように記述することで実現できます。

```json
"numOfSearchResult": "{count, plural, =0{There is no result} =1{1 result found} other{{count} results found}}"
```

英語での実行結果は次のようになります。

```dart
Text(l10n.numOfSearchResult(0)),
// => There is no result
Text(l10n.numOfSearchResult(1)),
// => 1 result found
Text(l10n.numOfSearchResult(2)),
// => 2 results found
```

場合分けは=0や=1のほかに、fewやmanyといったキーワードも存在しますが、日本語や英語では使われません。具体的な数値がどのケースに該当するかは言語ごとに異なるので注意してください。その挙動はICU（International Components for Unicode）というライブラリに準拠しており、ICUはCLDR（Common Locale Data Repository）が提供するデータを活用しています。詳細な挙動を知りたい方はUnicode CLDR²のドキュメントを参照してください。

### 複数の言語への対応

対応する言語ごとにarbファイルを追加することでアプリを複数の言語に翻訳できます。arbファイルがどの言語に対応しているかはファイル名で決定します。アンダーバーと拡張子の間の文字列が、そのarbファイルが対応する言語として扱われます。たとえば、app_ja.arbではアンダーバーと拡張子の間がjaなので日本語のarbファイルとして扱われます。日本語と英語に対応する場合は次のようなファイル構成となります。

```
~/project_root
└── lib
    ├── l10n
    │   ├── app_en.arb
    │   └── app_ja.arb
    └── ...（省略）
```

また、それ以外にも`@@locale`キーに言語を指定する方法もあります。

**./lib/l10n/japanese.arb**

```json
{
  "@@locale": "ja",
  "helloWorld": "こんにちは世界！",
  "@helloWorld": {
    "description": "お決まりの挨拶"
  }
}
```

この場合は自由にファイルを決めて問題ありません。

```
~/project_root
└── lib
    ├── l10n
    │   ├── english.arb
    │   └── japanese.arb
    └── ...（省略）
```

---

² https://cldr.unicode.org/index/cldr-spec/plural-rules

# 4.3 プロジェクトにアセットを追加する

Flutterではアプリに同梱する画像やテキストファイルなどをアセットと呼びます。本書では主に画像の取り扱いについて紹介します。後半ではアセットを扱う際に便利なflutter_genというパッケージについても紹介します。アセットを扱う際はこのパッケージを使うことをお勧めします。

## アプリに画像を追加する

まずはアセットを配置するディレクトリを作成します。ディレクトリ名は任意ですがassetsなどが一般的です。assetsディレクトリを作成したら、その中に画像を配置します。今回はPNG形式で円の画像を用意し、circle.pngという名前でassetsディレクトリに配置します（図4.9）。

```
~/project_root
└── assets
    └── circle.png
```

なお、Flutterが対応している画像フォーマットはJPEG、WebP、GIF、PNG、BMP、WBMPです。

![図4.9 circle.png](図4.9)

続いて、pubspec.yamlにアセットのパスを記述します。flutterセクションのサブセクションにassetsを追加し、その下にアセットのパスを記述します。

**./pubspec.yaml**

```yaml
flutter:
  # 省略
  assets:
    - assets/circle.png
```

これでアセットの準備は完了です。このアセットを表示するシンプルなアプリを作成してみましょう。

**./lib/main.dart**

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: HomeScreen(),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/circle.png'), // ❶
      ),
    );
  }
}
```

画像を表示するウィジェットとして`Image`ウィジェットがあります。❶でアセットのパスを指定し、`Image`ウィジェットを作成しています。

アプリを実行すると、図4.10のように円が表示されます。

![図4.10 アセットの画像が表示される様子](図4.10)

pubspec.yamlに記述するアセットのパスは、ディレクトリ単位で指定することもできます。以下のように、/で終わるパスを指定すると、そのディレクトリのすべてのファイルがアセットとして扱われます。ただし、通常はサブディレクトリを再帰的に探索しないので注意しましょう（後述の解像度バリエーションを除く）。

以下のようにアセットのパスを指定したとします。

**./pubspec.yaml**

```yaml
flutter:
  # 省略
  assets:
    - assets/
```

次のようなディレクトリ構成であれば、circle.pngとsquare.pngはアセットしてアプリに組み込まれますが、icon.pngはアセットとして扱われません。

```
~/project_root
└── assets
    ├── circle.png
    ├── square.png
    └── icons
        └── icon.png
```

アプリ内でassets/icons/icon.pngを参照すると実行時エラーになります。

## 端末の解像度に応じて画像を切り替える

スマートフォンのディスプレイ解像度はさまざまです。解像度別にいくつか画像を用意し、実行時に切り替える手法があります。以下のようなディレクトリ構成でアセットを配置します。

```
~/project_root
└── assets
    ├── 2x
    │   └── circle.png
    ├── 3x
    │   └── circle.png
    └── circle.png
```

そして、前節で紹介したようにpubspec.yamlにアセットのパスをディレクトリ単位で指定します。

**./pubspec.yaml**

```yaml
flutter:
  # 省略
  assets:
    - assets/
```

このように、数値と末尾に「x」で終わるディレクトリを作成すると、解像度別のバリエーションとして解釈されます。assets/circle.pngが縦横72pxだとしたら、これを基準に2xには縦横144px、3xには縦横216pxの画像を配置します。

iPhoneを例に、これらの画像がどのように選択されるか説明します。iPhone15 Pro Maxのディスプレイ解像度は縦横2796×1290pxですが、論理解像度は縦横932×430ptです。論理解像度に対して、ディスプレイの物理解像度が3倍なのでiPhone15 Pro Maxで実行した場合、3xの画像が自動的に選択されます。

わかりやすいように、2xの画像（図4.11）と3xの画像（図4.12）として意図的に異なるものを用意しました。

![図4.11 2x配下のcircle.png](図4.11) ![図4.12 3x配下のcircle.png](図4.12)

iPhone14 Pro Maxのシミュレータ、iPhone SE（第3世代）のシミュレータそれぞれでアプリを実行すると、図4.13と図4.14のようになります。

![図4.13 iPhone15 Pro Maxのシミュレータで実行した様子](図4.13) ![図4.14 iPhone SE（第3世代）のシミュレータで実行した様子](図4.14)

ただし、この方法は画像の準備に手間がかかったり、アプリのファイルサイズが大きくなるという問題があります。この問題はベクタ画像を使うことで解決できますので、flutter_svgというパッケージを利用して画像を扱うことをお勧めします。後述のflutter_genと組み合わて利用する方法を紹介します。

## flutter_gen ── 型安全にアセットを扱うパッケージ

本節の最初に画像アセットを表示するアプリの例を紹介しましたが、アセットのパスを文字列で指定していました。パスを誤って入力すると、実行時エラーとなってしまいます。これを防ぐために、アセットを扱う際はflutter_genというパッケージを利用することをお勧めします。flutter_genは、アセットにアクセスするコードを自動生成してくれるパッケージです。

なお、前節でメッセージをローカライズした際に、生成されたコードが.dart_tool/flutter_gen/gen_l10nディレクトリに出力されていましたが、ここで紹介するflutter_genパッケージとは関係ありません。

### flutter_genを導入する

flutter_genを利用してみましょう。パッケージを導入するためにプロジェクトのディレクトリで、ターミナルから以下のコマンドを実行してください。

```bash
# build_runnerパッケージとflutter_gen_runnerパッケージを導入
$ flutter pub add --dev build_runner flutter_gen_runner
```

ソースコード生成ツールのbuild_runnerと、flutter_genのコードジェネレータであるflutter_gen_runnerを導入しました。

パッケージを追加したら、コードを生成するコマンドを実行します。

```bash
$ flutter packages pub run build_runner build
```

さっそくflutter_genが生成したコードを利用するコードを書いてみましょう。

**./lib/main.dart**

```dart
import 'package:flutter/material.dart';
import 'gen/assets.gen.dart'; // ❶

void main() {
  runApp(
    const MaterialApp(
      home: HomeScreen(),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
          // Image.asset('assets/circle.png'),
          Assets.circle.image(), // ❷
      ),
    );
  }
}
```

まずflutter_genが生成したコードをインポートしています（❶）。アセットへのアクセスはflutter_genの実行によって`Assets`クラスに定義されています。また、画像のアセットに関しては`Image`ウィジェットを返すメソッドも生成され便利です（❷）。

### SVG画像の利用

先にも述べましたが、さまざまなスマートフォンの解像度に合わせて画像を複数用意するのは手間がかかります。それを解決する方法として、SVG形式のファイルを利用する方法があります。SVGファイルはベクタ画像の一種で、拡大／縮小しても画質が劣化しません。FlutterはSVG画像をサポートしていませんが、flutter_svgというパッケージがSVG画像を描画するウィジェットを提供しています。# プロジェクトにアセットを追加する（続き）・環境変数・テーマとルーティング

## 4.3 プロジェクトにアセットを追加する（続き）

### flutter_svgパッケージの導入

パッケージを導入するためにプロジェクトのディレクトリで、ターミナルから以下のコマンドを実行してください。

```bash
# flutter_svgパッケージを導入
$ flutter pub add flutter_svg
```

flutter_genはflutter_svgと組み合わせて利用することを想定して、オプションを用意しています。pubspec.yamlのトップレベルにflutter_genセクションを追加します。

**./pubspec.yaml**
```yaml
flutter_gen:
  integrations:
    flutter_svg: true
```

### SVG形式のアセットの追加

続いてプロジェクトにSVG形式のアセットを追加します。assetsフォルダに図4.15のSVG画像を配置します。

**図4.15 SVG形式のアイコン**

```
~/project_root
└── assets
    └── check.svg
```

アセットを追加したら、コードを生成するコマンドを実行します。

```bash
$ flutter packages pub run build_runner build
```

### SVG画像を描画するコード

**./lib/main.dart**
```dart
import 'package:flutter/material.dart';
import 'gen/assets.gen.dart';

void main() {
  runApp(
    const MaterialApp(
      home: HomeScreen(),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Assets.check.svg( // ❶
          width: 72,
          height: 72,
        ),
      ),
    );
  }
}
```

SVG画像を描画するコードに書き換えました（❶）。これで端末の解像度を気にすることなく、画像アセットを扱うことができます。このコードを実行すると、図4.16のようにSVG画像が表示されます。

**図4.16 SVG画像を描画した様子**

### その他のアセット

flutter_genは画像アセットだけでなく、フォントやJSONファイルなどのアセットにも対応しています。また、オプションで組み合わせて利用できるパッケージもflutter_svg以外にいくつか用意されています。アプリで扱うアセットの種類が増えた場合は、[pub.dev](https://pub.dev/packages/flutter_gen)を参照しサポートされているか確認してみましょう。

また、既知の問題があるようで、ソースコードを自動生成する際にエラーが発生した際も同様にpub.devを参照してください。

## 4.4 dart-define-from-file ── 環境変数を扱う

アプリを設計する際に、コードと設定を分離することは重要です。たとえば開発環境と本番環境でAPIのエンドポイントが異なる場合、環境を切り替えるためにコードを書き換えるのは良い運用とは言えません。ログレベルなども同様です。こういった設定情報は環境変数として扱うことで、コードと分離することができます。

### 環境変数をJSON形式で記述する

Flutterのdart-define-from-fileというしくみを利用することで、環境変数をコードから参照できます。例として、プロジェクトルートにdefine/env.jsonというファイルを作成し、以下の内容を記述します。

**./define/env.json**
```json
{
  "apiEndpoint": "https://example.com/api",
  "logLevel": 1,
  "enableDebugMenu": true
}
```

このファイルのパスをFlutterのコマンドへ渡すことで、コードから参照できるようになります。Android Studioで実行する場合は、「Run」➡「Edit Configurations」を選択し、「Run/Debug Configurations」ウィンドウを開きます（図4.17）。「Additional run args」に`--dart-define-from-file=`に続いて、JSONファイルのパスを記述します。今回の場合は`--dart-define-from-file=define/env.json`となります。

**図4.17 Run/Debug Configrationsウィンドウ**

### 環境変数をコードから参照する

Dartのコードから環境変数を参照するには、以下のように記述します。

```dart
const endpoint = String.fromEnvironment('apiEndpoint');
const logLevel = int.fromEnvironment('logLevel');
const enableDebugMenu = bool.fromEnvironment('enableDebugMenu');
```

String型、int型、bool型のそれぞれに対応したfromEnvironmentメソッドを呼び出します。引数には環境変数のキーを指定します。

このとき必ずconst変数に代入するか、呼び出し側にconstキーワードを付与する必要があるので注意してください。これを忘れると環境変数が取得できず、デフォルト値が返されます。キーが間違っている場合も同様です。デフォルト値はfromEnvironmentメソッドの第二引数で指定するか、未指定の場合は表4.3の値が返されます。

**表4.3 fromEnvironment()のデフォルト値**

| 型 | デフォルト値 |
|---|---|
| String | 空文字 |
| int | 0 |
| bool | false |

## 4.5 まとめ

アプリのローカライズ、アセットの管理、環境変数の扱い方を紹介しました。

Flutterは、たとえ日本語だけをサポートするアプリであっても、しっかりと対応しなければ意図せず英語が表示されてしまうことがあります。ローカライズ対応は少々手間ですが、はじめに整えておくことでメッセージの管理にも役立ちます。

アセットはパス文字列にタイプミスの懸念があるのでflutter_genを利用して安全に扱うことが望ましいです。また、解像度別の画像を用意するのは手間がかかりますので、SVG形式のファイルを使うのがお勧めです。

コードと設定を分離する手法として、環境変数を扱う方法を紹介しました。

本章で紹介した内容は、製品レベルのアプリを開発、保守していくうえで重要な要素です。もちろん要件によっては不要な要素もあるでしょうが、採用するか否かをはじめに検討しておくことで、後々の開発がスムーズに進むことでしょう。

---

