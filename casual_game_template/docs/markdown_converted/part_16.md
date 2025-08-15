```dart
class Counter extends StatefulWidget { // ❶
  const Counter({super.key});
  
  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;
  
  @override
  Widget build(BuildContext context) { // �②
    return GestureDetector(
      onTap: () {
        print('tapped!');
      },
      child: Container(
        color: Colors.red,
        width: 100,
        height: 100,
        child: Center(
          child: Text(
            '$_count',
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  }
}
```

`Counter`ウィジェットを`StatefulWidget`に書き換えました。`StatefulWidget`は`build`メソッドを持ちません。代わりに`createState`メソッドをオーバーライドし`State`オブジェクトを返します（❶）。`build`メソッドは`State`クラスで実装します（❷）。`State`クラスは状態が変化したことをフレームワークに知らせる`setState()`というメソッドを持っており、このメソッドを呼び出すと`build`メソッドが呼び出されるしくみになっています。

## Widgetの状態を変化させる

それでは`_count`の値を変化させ、それに追従して`build`メソッドが呼び出されるように修正してみます。

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(
    const Center(
      child: Counter(),
    ),
  );
}

class Counter extends StatefulWidget {
  const Counter({super.key});
  
  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('tapped!');
        setState(() { // ❶
          _count += 1;
        });
      },
      child: Container(
        color: Colors.red,
        width: 100,
        height: 100,
        child: Center(
          child: Text(
            '$_count',
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  }
}
```

`onTap`に渡すコールバックの中で、`setState`の呼び出しと`_count`の変更を実装しました（❶）。`setState`は引数にクロージャで`_count`の変更処理を渡しています。このように、状態を変更するときは`setState`の引数で行います。

このサンプルコードを実行すると、赤い四角形をタップするたびに数字が更新されカウントアップします。

# 3.4 まとめ

`StatelessWidget`と`StatefulWidget`について、それぞれの特徴をあらためておさらいします。

## StatelessWidgetの特徴
- 状態を持たない
- `build`メソッドをオーバーライドし、1つ以上のWidgetを組み合わせてUIを構成する
- 自身で表示更新するしくみがない

## StatefulWidgetの特徴
- `StatefulWidget`は`State`を生成する
- `StatelessWidget`にあった`build`メソッドは`State`で実装する
- 状態を変化させるときは`setState`の引数コールバック内で行う
- `setState`を呼び出すと自身の表示更新が行われる

シンプルなアプリであれば、`StatelessWidget`と`StatefulWidget`の組み合わせだけで開発することができます。アプリが複雑になり、ウィジェットの更新や状態の受け渡しに課題が見えてきたときは、状態管理について検討するとよいでしょう。第7章でその考え方や代表的な手法を解説します。

---

# 第4章 アプリの日本語化対応、アセット管理、環境変数

本章では国際化対応、アイコンなどのアセット管理のしくみ、環境変数の取り扱いについて解説します。特に製品レベルのアプリを開発する際には、はじめに整えておくべき要素であり、さしずめ「開発の土台作り」と言えます。

また、これらの要素を整えるために必要なパッケージ管理についても併せて解説します。

# 4.1 パッケージやツールを導入する

Dart言語は標準でパッケージ管理ツールを提供しており、Flutterのプロジェクトで利用することができます。まず、混乱のないよう用語の解説を表4.1にまとめたので確認してください。

## 表4.1 パッケージに関する用語

| 用語 | 解説 |
|------|------|
| パッケージ | Dartのプログラムライブラリ、アプリ、リソースなどを含んだディレクトリ。パッケージそのものや依存関係を記述したpubspecファイルが必ず含まれる |
| プラグイン | ネイティブコード（iOS向けのSwiftコードやAndroid向けのKotlinコードなど）を同梱したパッケージ |
| pub | パッケージ管理ツール。パッケージを入手するために使う |
| pub.dev | 共有パッケージを閲覧、検索できるWebサイト。https://pub.dev |
| Flutter Favorite Program | 「最初に導入を検討すべきパッケージ」を選出する活動のこと。pub.devで公開されている |

pub.dev¹にはたくさんのパッケージが公開されています。サードパーティのプログラムライブラリのみならず、Flutterが公式で提供するパッケージもあります。カメラ操作、データ永続化、Firebase連携など、pub.devでパッケージを検索することで多くのユースケースに対応できるでしょう。本章でも後述のアセット管理のところで便利なパッケージを紹介します。

多くのパッケージはpubspec.yamlに所定の記述をし、コマンドを実行することで導入できます。ただし、導入に必要な手順はパッケージにより異なりますので、必ずそれぞれのドキュメントを参照してください。

---

¹ https://pub.dev

## パッケージの導入方法

pubspec.yamlにはパッケージを記述するセクションが2種類あります。以下にサンプルを示します。

```yaml
dependencies: # ❶
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  http: ^0.13.6

dev_dependencies: # ❷
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
  build_runner: ^2.3.3
```

`dependencies`セクションはアプリのコードが依存するパッケージを記述します（❶）。`dev_dependencies`は開発フェーズでのみ利用するパッケージを記述します。たとえばテストに関わるパッケージや、コード生成ツールなどです（❷）。

依存するパッケージを追加するには、YAML（YAML Ain't Markup Language）ファイルを直接編集するか、コマンドを実行します。たとえば、httpというパッケージを導入する場合は、以下のようにコマンドを実行すると`dependencies`セクションにhttpパッケージが追加されます。

```bash
$ flutter pub add http
```

`dev_dependencies`セクションに追加する際は`--dev`オプションを付与します。たとえば、build_runnerというパッケージを導入する場合は、以下のようにコマンドを実行します。

```bash
$ flutter pub add --dev build_runner
```

こうしてpubspec.yamlにパッケージを追加したら、コマンドを実行してパッケージを導入します。

```bash
$ flutter pub get
```

またはAndroid Studioには`pub get`コマンドを実行するためのボタンが用意されています。pubspec.yamlを開いている状態で「Pub get」ボタンを押すとパッケージを導入できます（図4.1）。

![図4.1 Android Studioの「Pub get」ボタン](図4.1)

## パッケージバージョンの指定方法

パッケージのバージョン指定には次のような記述方法があります。

```yaml
# 2.1.0以上、互換性のある限り最新のバージョンを利用する
shared_preferences: ^2.1.0  # ❶

# 2.1.0以上 3.0.0未満のバージョンを利用する
shared_preferences: '>=2.1.0 <3.0.0'  # ❷

# 2.1.0以下のバージョンを利用する
shared_preferences: '<=2.1.0'  # ❸

# 2.0.0より新しいバージョンを利用する
shared_preferences: '>2.0.0'  # ❹

# バージョンを2.1.1に固定する
shared_preferences: 2.1.1  # ❺
```