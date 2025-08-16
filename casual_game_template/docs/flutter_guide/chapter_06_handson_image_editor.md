# 第6章 実践ハンズオン❶ 画像編集アプリを開発

本章ではFlutterアプリをハンズオン形式で実装していきます。簡単な画像編集アプリを作成する過程で、第4章や第5章で学んだ内容を実践します。本章のハンズオンではiOS Simulatorを使用します。あわせてもらえばすべての工程を体験できます。なお、本章でもfvmコマンドを省略してflutterコマンドを記載しています。ご自身の環境、コマンドを実行するディレクトリにあわせて読み替えてください。その中でも「テーマ」「画面遷移」この2点に的を絞って解説します。筆者の経験上、この2つの要素はおおよそどのようなアプリを開発する場合にも知識として必要になり、後工程での方針変更は手間がかかることがあります。

前章は、はじめに整えておくべき要素を紹介しました。本章では、はじめに設計しておくとよい要素として、フレームワークの2つの要素を紹介します。

なお、本章では解説に重きを置くため、関連したコードの断片を掲載していますので、省略されている部分がある点に留意してください。完全なサンプルコードの場合は、その旨を明記しています。手もとで動作確認する際は、`./lib/main.dart`を書き換えてください。

## 5.1 テーマ ── アプリ全体のヴィジュアルを管理

アプリ全体を通した色やフォントを定義し、適用する方法を解説します。アプリのUIで一貫した世界観を演出したり、視覚的にわかりやすいことは重要です。

本節では「アプリ全体を通した色やフォントの定義」をテーマと呼ぶことにし、テーマに関する2つの機能を解説します。1つ目はアプリのテーマを自動的に計算し適用する機能、2つ目はアプリ独自のテーマを管理し適用する機能です。

### フレームワークによるテーマの自動計算機能

まずはテーマの自動計算機能を確認しましょう。Flutterのテンプレートプロジェクトで動作を確認します。第1章で解説した方法で新たにプロジェクトを作成し、アプリを実行します。

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
```# テーマとルーティング（続き）

## 5.1 テーマ ── アプリ全体のヴィジュアルを管理（続き）

### フレームワークによるテーマの自動計算機能（続き）

```dart
const MyApp({super.key});

// This widget is the root of your application.
@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData( // ❶
      // This is the theme of your application.
      //
      // TRY THIS: Try running your application with "flutter run". You'll see
      // the application has a purple toolbar. Then, without quitting the app,
      // try changing the seedColor in the colorScheme below to Colors.green
      // and then invoke "hot reload" (save your changes or press the "hot
      // reload" button in a Flutter-supported IDE, or press "r" if you used
      // the command line to start the app).
      //
      // Notice that the counter didn't reset back to zero; the application
      // state is not lost during the reload. To reset the state, use hot
      // restart instead.
      //
      // This works for code too, not just values: Most code changes can be
      // tested with just a hot reload.
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), // ❂
      useMaterial3: true,
    ),
    home: const MyHomePage(title: 'Flutter Demo Home Page'),
  );
}
```

❶でThemeDataクラスのインスタンスを作成し、MaterialAppウィジェットに渡しています。英語のコメントにもあるように、カラーを変更して動作を確認してみましょう。

今回は❷のdeepPurpleをblueに変更してください。ソースコードを保存すると、ホットリロード機能でアプリの外観が変化します。もし、変化しなければAndroid Studioのホットリロードボタンをクリックしてみましょう。

アプリの外観が紫を基調としたテーマから青に変化したことが確認できると思います。ThemeDataクラスはアプリのテーマ情報を持つクラスです。ThemeDataクラスの代表的なプロパティに、色のパラメータを持つcolorSchemeと、文字のパラメータを持つtextThemeがあります。

ColorSchemeクラスはマテリアルデザインのルールにのっとり、テーマの色のパラメータを計算します。さらに、計算済みの色を一部カスタマイズすることもできます。

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      // ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)
            .copyWith(background: Colors.blueGrey), // ❶
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
```

ColorSchemeクラスのcopyWithメソッドを使い、カラーを変更したコピーを作成します。この例では背景カラーを変更しています（❶、図5.1）。

**図5.1 backgroundカラーが変更された様子**

続いてtextThemeについて見てみましょう。

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)
            .copyWith(background: Colors.blueGrey),
        textTheme: const TextTheme( // ❶
          bodyMedium: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        useMaterial3: true, // ❷
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
```

ThemeDataクラスへTextThemeを渡しました（❶）。ここではbodyMediumというテキストスタイルの色とフォントウェイトを変更しています（図5.2）。

**図5.2 TextThemeが変更された様子**

アプリのデザインを細かくカスタマイズするには、ColorSchemeの[リファレンス](https://api.flutter.dev/flutter/material/ColorScheme-class.html)とTextThemeの[リファレンス](https://api.flutter.dev/flutter/material/TextTheme-class.html)、それと併せてマテリアルデザインの[ドキュメント](https://m3.material.io/styles/color/the-color-system/color-roles)を参照してください。

また最後にuseMaterial3というコンストラクタのパラメータについても触れておきます（❷）。このパラメータはMaterial Design 3（以降、M3）のテーマを利用するかどうかを指定します。M3はGoogleが提唱するマテリアルデザインの新しいバージョンで、従来のものよりも表現力が豊かでアクセシビリティが高いデザインとなっています。

M3はオプトインの形で段階的に導入されてきましたが、Flutter 3.16をもってM3がデフォルトになりました。今後はuseMaterial3フラグは削除され、従来までのMaterial Design 2のコードは削除される予定です。

### ダークモード対応

ここ数年のiOSやAndroidはユーザー設定や時間帯に応じて暗い外観に切り替わるダークモード機能を持っています（iOSはダークモード、Androidではダークテーマと言いますが、本書では両方を指してダークモードと呼ぶこととします）。MaterialAppウィジェットやThemeDataクラスを使うことで簡単にダークモードに対応できます。サンプルをお見せしましょう。

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData( // ❶
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark, // ❷
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
```

MaterialAppウィジェットのdarkThemeパラメータにダークモード用のThemeDataクラスを渡します（❶）。ThemeDataクラスはbrightnessにBrightness.darkを指定することで、ダークモード用のテーマを自動計算してくれます（❷）。MaterialAppウィジェットがシステムのダークモード設定を監視しているので、スマートフォンがダークモードに切り替わるとアプリの外観もダークモードに変化します。

それでは実際にアプリを実行し、ダークモードを切り替えてみましょう。iOS Simulatorの場合は、設定アプリから「Developer」➡「Dark Appearance」の順に選択し、スイッチでモードを切り替えます（図5.3）。

**図5.3 モード切り替えでアプリの外観が変化する様子**

### アプリ独自のテーマ管理

マテリアルデザインにのっとったテーマについては、MaterialAppウィジェットやThemeDataクラスを用いることで実現できることがわかりました。一方で、アプリ独自のテーマを管理する方法としてTheme Extensionがあります。

```dart
class MyTheme extends ThemeExtension<MyTheme> {
  const MyTheme({
    required this.themeColor,
  });

  final Color? themeColor; // ❶

  @override
  MyTheme copyWith({Color? themeColor}) { // ❷
    return MyTheme(
      themeColor: themeColor ?? this.themeColor,
    );
  }

  @override
  MyTheme lerp(MyTheme? other, double t) { // ❸
    if (other is! MyTheme) {
      return this;
    }
    return MyTheme(
      themeColor: Color.lerp(themeColor, other.themeColor, t),
    );
  }
}
```

ThemeExtensionクラスを継承したMyThemeクラスを実装しました。MyThemeクラスではthemeColorというカラーを扱うことにします（❶）。ThemeExtensionは抽象クラスで、サブクラスでは2つのメソッドを実装しなければなりません。

❷のcopyWithメソッドは任意のフィールドを変更したコピーをインスタンス化するメソッドです。

❸のlerpメソッドはテーマの変化を線形補間するメソッドです。このメソッドを実装しておくことで、テーマ変更時にアニメーション処理されるようになります。たとえば、ダークモードへの切り替えタイミングが該当します。

こうして実装したMyThemeクラスはThemeDataクラスのパラメータに渡します。

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        extensions: const [MyTheme(themeColor: Color(0xFF0000FF))], // ❶
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
        extensions: const [MyTheme(themeColor: Color(0xFFFF0000))], // ❷
      ),
    );
  }
}
```

ThemeDataクラスのextensionsパラメータにThemeExtensionクラスを継承したMyThemeクラスのインスタンスを渡します（❶）。extensionsパラメータはList型なので、複数のTheme Extensionを設定することも可能です。ThemeDataクラスのパラメータなので、ダークモード用に別のMyThemeクラスを指定することも容易です（❷）。

続いて、MyThemeクラスのテーマを適用したウィジェットを実装します。ThemedWidgetという正方形を描画するウィジェットです。

**./lib/main.dart**
```dart
class ThemedWidget extends StatelessWidget {
  const ThemedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context); // ❶
    final myTheme = themeData.extension<MyTheme>()!; // ❷
    final color = myTheme.themeColor;
    return Container(width: 100, height: 100, color: color);
  }
}
```

Themeウィジェットのofメソッドを使い、ThemeDataクラスのインスタンスを取得します（❶）。さらに、ThemeDataクラスのextensionメソッドを使い、MyThemeクラスのインスタンスを取得します（❷）。

Themeというウィジェットがここで初めて登場しましたが、MaterialAppウィジェットが内部で生成しているウィジェットで、ThemeDataクラスのインスタンスを持っています。Themeウィジェットの子孫であれば、どのウィジェットもofメソッドを使ってThemeDataクラスのインスタンスを取得することができるのです。さらにこのThemedWidgetのように、buildメソッドの中でThemeウィジェットのofメソッドを呼び出すと、テーマが変更されたときに再描画されるしくみも備わっています（詳しくは第9章で解説します）。このしくみのおかげで、ダークモードへの切り替え時に色がアニメーションする様子を確認できます。

### Theme Extensionを利用したアプリのサンプル

最後に、Theme Extensionを利用したサンプルの全体を掲載します。このサンプルではシステムのダークテーマ設定を利用せず、アプリ独自にダークテーマ設定を持つようにしました。Theme Extensionを継承したクラスでlerpメソッドを実装したことにより、テーマ変更時に色がアニメーションする様子が確認できます。

**./lib/main.dart**
```dart
import 'package:flutter/material.dart';

class MyTheme extends ThemeExtension<MyTheme> {
  const MyTheme({
    required this.themeColor,
  });

  final Color? themeColor;

  @override
  MyTheme copyWith({Color? themeColor}) {
    return MyTheme(
      themeColor: themeColor ?? this.themeColor,
    );
  }

  @override
  MyTheme lerp(MyTheme? other, double t) {
    if (other is! MyTheme) {
      return this;
    }
    return MyTheme(
      themeColor: Color.lerp(themeColor, other.themeColor, t),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}
```# 第6章 実践ハンズオン❶ 画像編集アプリを開発

本章ではFlutterアプリをハンズオン形式で実装していきます。簡単な画像編集アプリを作成する過程で、第4章や第5章で学んだ内容を実践します。本章のハンズオンではiOS Simulatorを使用します。あわせてもらえばすべての工程を体験できます。なお、本章でもfvmコマンドを省略してflutterコマンドを記載しています。ご自身の環境、コマンドを実行するディレクトリにあわせて読み替えてください。

図6.1が完成イメージです。

**図6.1 アプリの完成イメージ**

```
StartScreen → SnapSelectScreen → EditSnapScreen
ウィジェット   ウィジェット      ウィジェット
```

## 6.1 開発するアプリの概要

このハンズオンで実装するアプリの概要を説明します。スマートフォンの画像ライブラリから取得した画像を回転、反転させて編集するアプリです。画面は全部で3つあります。

### スタート画面

アプリ起動後に表示される画面です（図6.2）。現在の日付が表示され、「開始する」ボタンをタップすると画像選択画面に遷移します。# 画像編集アプリ開発（第6章・続き）

## 6.1 開発するアプリの概要（続き）

### 画像選択画面

スマートフォンの画像ライブラリから画像を選択する画面です（図6.3）。「画像を選ぶ」ボタンをタップすると画像ライブラリから画像を選択でき、選択した画像はプレビューされます。画像ライブラリへのアクセスはimage_pickerというパッケージを使用します。また、画像のプレビューのためにimageパッケージを使用します。「画像を編集する」ボタンをタップすると画像編集画面に遷移します。

**図6.2 スタート画面**

**図6.3 画像選択画面**

### 画像編集画面

選択した画像を回転、反転させる画面です（図6.4）。画像の回転は90度単位で行います。画像の回転、反転にはimageパッケージを使用します。

**図6.4 画像編集画面**

---

## 開発の土台づくり

第4章で解説した「開発の土台づくり」の要素です。アプリは日本語にローカライズし、アセットはflutter_genパッケージを使用して管理します。環境変数は特に設定しません。

導入するパッケージは表6.1のとおりです。

**表6.1 導入するパッケージ一覧**

| パッケージ名 | 用途 |
|------------|------|
| intl | アプリのローカライズ |
| image_picker | 画像ライブラリへのアクセス |
| image | 画像データの加工 |
| flutter_svg | SVG画像の表示 |
| build_runner | flutter_genのコード生成 |
| flutter_gen_runner | アセットの管理 |

### テーマと画面遷移の方針

テーマはMaterial Design 3のテーマを使用します。テーマの変更はColorSchemeクラスのseedColorのみを変更するにとどめます。

画面遷移はNavigator 1.0のAPIのみを使用します。

---

## 6.2 プロジェクトを作成する

新たにプロジェクトを作成します。第1章の「1.1 プロジェクトの作成」で示した手順に従って、プロジェクトを作成してください。プロジェクト名は「edit_snap」としましょう。プロジェクト作成直後はlib/main.dartにテンプレートになるアプリコードが書かれていますので、不要なコードを削除してしまいましょう。

**./lib/main.dart**
```dart
