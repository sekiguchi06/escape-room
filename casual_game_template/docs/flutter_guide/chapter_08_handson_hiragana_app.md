# 第8章 実践ハンズオン❷ ひらがな変換アプリを開発

本章では再びハンズオン形式でアプリの実装に挑戦します。入力したテキストをひらがなに変換するアプリです。第7章で学んだRiverpodを採用し、状態管理を行います。なお、本章でもfvmコマンドを省略してflutterコマンドを記載しています。ご自身の環境、コマンドを実行するディレクトリにあわせて読み替えてください。

図8.1が完成イメージです。

**図8.1 アプリの完成イメージ**

## 8.1 開発するアプリの概要

このハンズオンで実装するアプリの概要を説明します。公開されたWeb APIを利用し、入力したテキストをひらがなに変換します。文字入力とバリデーション、Web APIのリクエストにJSONの取り扱いと実用的な機能を盛り込んでいます。

1つの画面で状態により表示を切り替えるように実装します。入力状態で変換ボタンをタップし（図8.1の左）、APIリクエストを実行するとインジケータを表示します（図8.1の中央）。APIのレスポンスが返ると結果を表示します（図8.1の右）。再入力ボタンをタップすると、再び入力状態に戻ります。

### 入力状態

テキストを入力する状態です（図8.2）。テキストはバリデーションチェックを行い、空文字の場合はメッセージを表示します。「変換」ボタンをタップすると、ひらがな変換のリクエストを行います。

**図8.2 入力状態**

### レスポンス待ち状態

Web APIのレスポンス待ちの状態です（図8.3）。インジケータを表示することで、ユーザーにリクエスト中であることを伝えます。

**図8.3 レスポンス待ちの状態**

### 変換完了状態

APIリクエストが完了し、変換結果のある状態です（図8.4）。「再入力」ボタンをタップすると、再び入力状態に戻ります。

**図8.4 変換完了状態**

---

## 開発の土台づくり

第4章で解説した「開発の土台づくり」の要素です。アプリの日本語化など第6章のハンズオンで実装した機能は省略します。Web APIの呼び出しに必要なアプリケーションIDを環境変数として扱います。

導入するパッケージは「8.3 アプリで使用するパッケージを導入する」で解説します。

### テーマと画面遷移の方針

テーマはMaterial Design 3のテーマを使用し、すべてデフォルトのままにします。画面遷移はありません。

---

## 8.2 プロジェクトを作成する

プロジェクトを作成します。第1章の「1.1 プロジェクトの作成」で示した手順に従って、プロジェクトを作成してください。プロジェクト名は「hiragana_converter」としましょう。プロジェクト作成直後はlib/main.dartにテンプレートになるアプリコードが書かれていますので、まずは以下のように修正します。

**./lib/main.dart**
```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hiragana Converter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

テンプレートプロジェクトの不要なコードを削除したこの状態から作業を開始しましょう。

---

## 8.3 アプリで使用するパッケージを導入する

まずはじめに、アプリで使用するパッケージを一気に導入してしまいましょう。

パッケージを導入するためにプロジェクトのディレクトリで、ターミナルから以下のコマンドを実行してください。

```bash
# httpパッケージを導入❶
$ flutter pub add http

# JSONのシリアライズ、デシリアライズを行うパッケージを導入❷
$ flutter pub add json_annotation
$ flutter pub add --dev json_serializable

# Riverpodを導入❸
$ flutter pub add flutter_riverpod riverpod_annotation
$ flutter pub add --dev riverpod_generator custom_lint riverpod_lint

# コード生成のためにbuild_runnerを導入❹
$ flutter pub add --dev build_runner
```

Web APIを呼び出すためにhttpというパッケージを導入します（❶）。このパッケージはHTTPリクエストを簡単に扱うことのできるパッケージです。

Web APIのリクエストとレスポンスはJSON形式でやりとりします。JSONを取り扱うため、json_annotationとjson_serializableパッケージを導入します（❷）。これらのパッケージはDartのオブジェクトとMapの相互変換を行うコードを自動生成してくれるパッケージです。

そのほか、状態管理にRiverpodを採用するため❸を導入します。Riverpodとjson_serializableはコード生成を行うため、build_runnerパッケージも導入します（❹）。

### riverpod_lintを設定する

第7章で紹介したriverpod_lintの設定を行います。riverpod_lintはcustom_lintパッケージを利用して実現しています。以下のようにanalysis_options.yamlへcustom_lintを有効化する記述を追加します。

**./analysis_options.yaml**
```yaml
analyzer:
  plugins:
    - custom_lint
```

---

## 8.4 入力状態のウィジェットを実装する

第5章で作成したアプリはNavigation APIを使っていくつかの画面を行き来するアプリでした。本章のハンズオンは1つの画面で状態により表示を切り替えるように実装していきます。上記の2つの違いは、プログラム上どちらが良いということはなく、ユーザーにどのような体験を提供するかによります。

### レイアウトを作成する

まずはテキストを入力するレイアウトを作成します。libフォルダの配下にinput_form.dartという新しいファイルを追加し、以下のコードを記述します。

**./lib/input_form.dart**
```dart
import 'package:flutter/material.dart';

class InputForm extends StatefulWidget {
  const InputForm({super.key});

  @override
  State<InputForm> createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /* ◆ Padding
           余白を与えて子要素を配置するWidget */
        Padding( // ❶
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField( // ❷
            maxLines: 5,
            decoration: const InputDecoration( // ❸
              hintText: '文章を入力してください',
            ),
          ), 
        ),
        /* ◆ SizedBox
           サイズを指定できるWidget */
        const SizedBox(height: 20), // ❸
        ElevatedButton( // ❹
          onPressed: () {},
          child: const Text(
            '変換',
          ),
        ),
      ],
    );
  }
}
```

[以下、第8章の内容が続く...]

## 8.9 まとめ

入力したテキストをひらがなに変換するアプリを開発しました。文字入力とバリデーション、Web APIのリクエストやJSONの取り扱いといった実践的な機能を盛り込みました。

また、このハンズオンのポイントは次の2つです。

- アプリの状態をsealed classで実装し、簡潔にアプリの状態を表現した
- アプリの状態管理にRiverpodを利用し、ウィジェットとロジックを分離した

このハンズオンで採用したアプリの状態表現や状態管理は、筆者お勧めの設計パターンの一つです。

---