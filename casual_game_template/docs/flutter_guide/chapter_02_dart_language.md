# 第2章 Dartの言語仕様

Flutterの開発にはDartというプログラミング言語を用います。SwiftやKotlin、Javaと同じように静的型付け言語、クラスベースのオブジェクト指向言語です。2023年にメジャーアップデートされたDart 3ではすべてのコードがnull安全になったほか、Recordやパターンマッチングなどの新機能が追加されました。これらの新機能も解説します。

本章はできるだけDartの言語仕様を広く網羅することを目指しましたので分量が多くなっています。これは「新しいフレームワークに触れるときは、使用言語を頭にたたき込んでから」という筆者のスタイルを反映しています。とはいえ、勉強スタイルは人それぞれですので、本章は必要に応じて読み飛ばしていただいてもかまいません。

## 2.1 変数宣言

Dartの変数宣言の記述方法はいくつかあります。一つずつ見ていきましょう。

### 変数と型推論

```dart
int age = 0;
```

この例では`int`型の`age`という変数を整数リテラル0で初期化しました。ここでの`int`のように変数の型を宣言する部分をDartでは型注釈（Type Annotation）と呼びます。

Dartは型推論の機能があります。型注釈を省略し代わりに`var`と記述することで、変数の型を推論させることができます。

```dart
var age = 0;
```

### 定数 ── finalとconst

変更する予定のない変数は、定数を利用することが推奨されています。定数として宣言するには`final`修飾子を付けます。するとその変数への再代入はコンパイルエラーとなります。

```dart
final int age = 37;
age = 38; 
// => Error: Can't assign to the final variable 'num'.
```

また、この場合も型注釈を省略して型推論させることができます。

```dart
final age = 37;
```

`final`のほか、`const`という修飾子でも定数を宣言できます。

```dart
const int age = 37;
const age = 37; // constも型推論可能
```

こちらはコンパイル時定数として扱われます。そのため、クラス変数などは`const`宣言することはできません（静的なクラス変数であれば可能）。

また、`final`で宣言されたクラスのフィールドは変更可能ですが、`const`で宣言されたクラスのフィールドは変更不可です。クラスについては「2.12 クラス」で詳しく解説します。

### いろいろな初期値の与え方

変数は必ずしも宣言時に初期化される必要はありません。利用時までに初期化されていればOKです。初期化済みかどうかはDartコンパイラが判断してくれます。

```dart
final flag = DateTime.now().hour.isEven;
final int number; // 宣言時に初期化しない（この場合もfinalで宣言可能）
if (flag) {
  number = 0;
} else {
  number = 255;
}
print(number); // 必ず初期化されているのでOK
```

以下のように利用時までに初期化が保証されていないコードはコンパイルエラーとなります。

```dart
final userName = 'steve';
int number; // 宣言時に初期化しない
if (userName == 'joe') {
  number = 0;
} else if (userName == 'john') {
  number = 255;
} // else ケースがない
print(number);
// => Error: Non-nullable variable 'num' must be assigned before it can be used.
```

### 遅延初期化

変数の初期化をDartコンパイラが必ずしも正しく判断できない場合もあります。たとえば、グローバル変数の初期化などがそれにあたります。

そのようなときは`late`修飾子を付与することでコンパイラのチェックを回避できます。

```dart
late String globalVariable; // 宣言時に初期化しない

void main() {
  globalVariable = 'initialized';
  print(globalVariable);
  // => initialized
}
```

`final late`のように`late`修飾子と`final`修飾子を併用し、一度初期化されたら変更不可にすることもできます。

また`late`修飾子は、宣言時に初期化処理を記述すると、変数にアクセスされるまで初期化処理を遅延することができます。以下の例では変数`variable`にアクセスするまで、初期値を計算する`highCostFunction`は実行されません。

```dart
late String variable = highCostFunction();
```

使用されるかどうかわからない変数や、初期化処理の実行コストが高い場合に用いると効果的です。

`late`修飾子を使う場合は、未初期化の変数にアクセスすると実行時エラーとなりますので利用には注意が必要です。

## 2.2 組み込み型

Dartの代表的な組み込み型を紹介します。

### 数値型

数値型を表現する型は整数型として`int`クラス、浮動小数型として`double`クラス、以上の2つが用意されています。どちらも共通のスーパークラス`num`を継承しています。

#### int ── 整数型

符号付整数型として`int`クラスが提供されています。bitサイズはプラットフォームごとに異なります。昨今のiOSとAndroidを対象とするなら64bitのみと考えて差し支えないでしょう。

以下は`int`クラスとして推論される整数リテラルです。

```dart
final x = 1;
final hex = 0xFF; // 16進数リテラル
final exponent = 1e5; // 指数リテラル
```

#### double ── 浮動小数型

64bit浮動小数型として`double`クラスが提供されています。

以下は`double`クラスとして推論される小数リテラルです。

```dart
final y = 1.1;
final exponents = 1.42e5; // 指数表記も可
```

### String ── 文字列型

文字列型として`String`クラスが提供されています（その他、本書では詳しく解説しませんが、UTF-16コードポイントのコレクションとして`Runes`クラス、（書記素クラスタによる）部分文字のコレクションとして`Characters`クラスがあります）。

`String`クラスとして推論される文字列リテラルは、ダブルクオートとシングルクオートどちらも対応しています。

```dart
final str1 = 'Hello, Dart!';
final str2 = "Hello, Dart!";
```

文字列リテラルに変数の値を挿入することもできます。変数名の前に`$`を置きます。式の結果を挿入する場合は`${}`で式を囲います。

```dart
final name = 'dart';
final str1 = 'Hello, $name!';
print(str1); 
// => Hello, dart!

final str2 = 'Hello, ${name.toUpperCase()}!';
print(str2); 
// => Hello, DART!
```

隣接する文字列リテラルは自動的に連結されます。`+`演算子で連結を明示することもできます。

```dart
final message1 = 'Hello, ' 'Dart!';
print(message1); 
// => Hello, Dart!

final message2 = 'Hello, ' // 改行してもOK
                  'Dart!';
print(message2); 
// => Hello, Dart!

final message3 = 'Hello, ' + 
                  'Dart!';
print(message3); 
// => Hello, Dart!
```

複数行の文字列を定義するには三重のダブルクオート、または三重のシングルクオートが便利です。

```dart
final message1 = "<div>\n <p>Hello, Dart!</p>\n</div>";

final message2 = """
<div>
  <p>Hello, Dart!</p>
</div>
""";

final message3 = '''
<div>
  <p>Hello, Dart!</p>
</div>
''';
```

文字列リテラルの前に`r`を置くことで、改行文字などの特殊文字の解釈が無効にできます。

```dart
final message1 = 'Hello,\nDart!';
print(message1);
// => Hello,
// => Dart!

final message2 = r'Hello,\nDart!';
print(message2);
// => Hello,\nDart!
```

### bool ── 論理型

論理型として`bool`クラスが提供されます。

`bool`型のリテラルとして`true`と`false`があります。

```dart
final flag1 = true;
final flag2 = false;
```

### List ── 配列

配列に相当する順序付きコレクションには、Dartでは`List`クラスが用意されています。リテラル表現は以下です。各要素をカンマ（`,`）で区切り、大括弧（`[ ]`）で囲います。

```dart
final list1 = [0, 1, 2, 3];
final list2 = [0, 1, 2, 3,]; // 末尾にカンマを付与してもOK
```

`List`の要素の型は推論され、型の異なる要素を追加しようとするとコンパイル時にエラーとなります。

```dart
final intList = [0, 1, 2, 3];
intList.add(4); // OK
intList.add('abc'); // => Error: The argument type 'String' can't be assigned to the parameter type 'int'.
```

`List`の要素の型を明示するには以下のように型注釈を記述します。

```dart
final list = <int>[0, 1, 2, 3];
```

なお、`List`には可変長と固定長の2種類が存在します。リテラルで作られるのは可変長`List`になります。`List`の名前付きコンストラクタ`unmodifiable`を使うと、その`List`は固定長となります（名前付きコンストラクタは「2.12 クラス」で解説します）。固定長`List`の要素数を変更しようとすると実行時エラーとなります。

```dart
final baseList = [0, 1, 2, 3,];
final fixedLengthList = List.unmodifiable(baseList); // baseListを元に固定長の新しいインスタンスを生成
fixedLengthList.add(4); // 実行時エラー
```

### Set ── 集合

順序が保持されない、要素が重複しないコレクションとして`Set`クラスが用意されています。リテラル表現は以下です。各要素をカンマ（`,`）で区切り、中括弧（`{ }`）で囲います。

```dart
final map1 = { 'Apple', 'Orange', 'Grape' };
final map2 = { 'Apple', 'Orange', 'Grape', }; // 末尾にカンマを付与してもOK
```

`Set`の要素の型は推論され、型の異なる要素を追加しようとするとコンパイル時にエラーとなります。

```dart
final fruits = { 'Apple', 'Orange', 'Grape' };
fruits.add('Cherry'); // OK
fruits.add(123); // => Error: The argument type 'int' can't be assigned to the parameter type 'String'.
```

`Set`の要素の型を明示するには以下のように型注釈を記述します。

```dart
final fruits = <String>{ 'Apple', 'Orange', 'Grape' };
```

### Map ── 連想配列

連想配列や辞書に相当するkey-valueペアとして`Map`クラスが用意されています。他の多くの言語と同様にキーは重複しません。キーとバリューの型に制限はありません。リテラル表現は以下です。キーとバリューはコロン（`:`）、要素はカンマ（`,`）で区切り、全体を中括弧（`{ }`）で囲います。

```dart
final map1 = {
  200: 'OK',
  403: 'access forbidden',
  404: 'not found'
};

final map2 = {
  200: 'OK',
  403: 'access forbidden',
  404: 'not found', // 末尾にカンマを付与してもOK
};
```

`List`や`Set`と同様にキーやバリューの型は推論され、型の異なる要素を追加しようとするとコンパイル時にエラーとなります。

```dart
final statusCodes = {
  200: 'OK',
  403: 'access forbidden',
  404: 'not found'
};

statusCodes[204] = 'No Content'; // OK
statusCodes['204'] = 'No Content'; // => Error: A value of type 'String' can't be assigned to a variable of type 'int'.
```

`Map`の要素の型を明示するには以下のように型注釈を記述します。

```dart
final statusCodes = <int, String>{
  200: 'OK',
  403: 'access forbidden',
  404: 'not found'
};
```

`Set`と`Map`はリテラルが似ていますが、以下は`Map`として推論されます。

```dart
final setOrMap = {};
print(setOrMap is Map); // is演算子で型を確認
// => true
```

### Record ── タプル

`Record`は複数の値を集約した不変の匿名型を表現します。他の多くの言語にあるタプル型によく似ています。

`Record`の初期化はカンマ（`,`）区切りでフィールドを記述し括弧（`( )`）で囲います。

```dart
final record1 = (300, 'cake');
```

`Record`の型注釈はカンマ（`,`）区切りでフィールドの型注釈を記述し括弧（`( )`）で囲います。

```dart
final (int, String) record2 = record1;
```

フィールドに名前を付与することもできます。名前を付けたフィールドを「名前付きフィールド」、名前を付けないフィールドを「位置フィールド」と呼びます。型注釈では名前付きフィールドを中括弧（`{ }`）で囲います。

```dart
final record1 = (price: 300, name: 'cake');
// 型注釈では名前付きフィールドを中括弧で囲う
final ({int price, String name}) record2 = (price: 300, name: 'cake');
```

名前付きフィールドの記述順は等値性に影響を与えません。

```dart
final record1 = (price: 300, name: 'cake');
final record2 = (name: 'cake', price: 300);
print(record1 == record2); 
// => true
```

型注釈の中では位置フィールドに名前を付与することができます。その名前はフィールドの等値性に影響を与えません。

```dart
// 左辺、Recordの型注釈でフィールドに名前を付与している
// 中括弧で囲っていないので名前付きフィールドではない
final (int price, String name) record1 = (300, 'cake');
final (int x, String y) record2 = (300, 'cake');
print(record1 == record2); 
// => true
```

名前付きフィールドと位置フィールドを混在させることが可能です。その場合、型注釈では位置フィールドが常に先頭に配置されます。

```dart
// 99のみが位置フィールド
final record1 = (price: 300, name: 'cake', 99);
// 型注釈では位置フィールドが先頭
final (int count, {String name, int price}) record2 = record1;
```

名前付きフィールドは、同名のゲッタから読み取りが可能です。位置フィールドは`$`に続けて引数の順序のゲッタが作られます。なお、`Record`は不変なためセッタはありません（ゲッタ、セッタについては「2.12 クラス」で解説します）。

```dart
final record = (price: 300, name: 'cake', 99);

print(record.price); 
// => 300
print(record.name); 
// => cake
print(record.$1); 
// => 99
```

### Objectクラス ── すべてのクラスのスーパークラス

`Object`クラスはDartのすべてのクラスのスーパークラスです（スーパークラスや継承については「2.12 クラス」で解説します）。代表的な用途は、型の異なる要素を持ったコレクションを扱う場合です。この例では、変数`list`は`List<Object>`型に推論されます。

```dart
final list = [
  0,
  'abc',
  true,
];
```

近い表現に`dynamic`という型があるので紹介します。

```dart
final List<dynamic> list = [
  0,
  'abc',
  true,
];
```

`dynamic`は特殊な型で、コンパイル時に型のチェックが行われません。存在しないメソッドを呼び出すようなコードであってもコンパイルエラーになりませんし、nullかどうかの判断もされません（nullについては「2.9 null安全」で解説します）。よって、実行時エラーのリスクが高まります。明確な理由がない限り、`dynamic`の利用は避け`Object`または`Object?`（この`?`の文法は「2.9 null安全」で解説します）を利用すべきです。

## 2.3 ジェネリクス

他の多くの言語と同じように、Dartにもジェネリクスの機能があります。型をパラメータ化し、特定の型に依存しない汎用的な実装を行うことができます。すでに紹介した`List`や`Map`は、要素の型をパラメータとして受け取るジェネリック型です。

```dart
final List<int> intList = [0, 1, 2]; // intのリスト
final stringList = <String>['a', 'b', 'c']; // Stringのリスト
```

### ジェネリッククラス

型名のあとに括弧（`< >`）で型のパラメータ名を与えます。慣習的にTなど1文字で表現します。クラス内で型のパラメータ名を実際の型名のように扱うことができます。

```dart
// Tが型のパラメータ名
class Foo<T> {
  // フィールド `_value`の型をパラメータ名Tで宣言
  T _value;
  
  Foo(this._value);
  
  // 戻り値の型をパラメータ名Tで宣言
  T getValue() {
    return _value;
  }
}

final intFoo = Foo(3);
print(intFoo.getValue());
// => 3

final stringFoo = Foo('hoge');
print(stringFoo.getValue());
// => hoge
```

### ジェネリック関数

ジェネリクスな関数は関数名のあとに型パラメータ名を記述します。型パラメータは戻り値、引数、またローカル変数で使用可能です。

```dart
// `T?`はT型またはnullを表す
T? firstOrNull<T>(List<T> list) {
  if (list.isEmpty) {
    return null;
  }
  return list[0];
}

final list1 = [1, 2, 3];
print(firstOrNull(list1));
// => 1

final list2 = <String>[];
print(firstOrNull(list2));
// => null
```

## 2.4 演算子

他の多くの言語と同じように扱えるものを中心に、Dartのオペレータの一部を紹介します。他の言語機能と併せて解説すべきものは別の項で紹介します。

### 算術演算子

和算や乗算などの四則演算を行う演算子は他の多くの言語と同じように扱うことができます。

```dart
print(2 + 3); 
// => 5
print(2 - 3);
// => -1
print(2 * 3);
// => 6
print(5 / 2); 
// => 2.5
print(5 % 2);
// => 1
```

インクリメント、デクリメントについても他の多くの言語と同じように扱うことができます。

```dart
int a;
int b;

a = 0;
b = ++a;
print("$a, $b");
// => 1, 1

a = 0;
b = a++;
print("$a, $b");
// => 1, 0

a = 0;
b = --a;
print("$a, $b");
// => -1, -1

a = 0;
b = a--;
print("$a, $b");
// => -1, 0
```

### 比較演算子

比較演算についても、他の多くの言語と同じように扱うことができます。

```dart
print(2 == 2);
// => true
print(2 != 1);
// => true
print(10 > 2);
// => true
print(2 < 10);
// => true
print(5 >= 5);
// => true
print(5 <= 5);
// => true
```

`==`オペレータはデフォルトの動作は参照の比較です。オーバーライドして同値性を指定することも可能です。また、両方が`null`の場合は`true`、一方のみが`null`の場合は`false`となります。

### 三項演算子

Dartは以下の三項演算子が利用できます。

```
条件式 ? 式1 : 式2
```

条件式が`true`なら式1が評価され戻り値となり、`false`なら式2が評価され戻り値となります。

```dart
int a = 128;
int b = 256;
final max = a > b ? a : b;
print(max);
// => 256
```

### カスケード記法

カスケード記法は同じオブジェクトに対して、繰り返し操作を行うときに便利な記述方法です。オブジェクトのメソッドやプロパティへドット2つ（`..`）でアクセスすると、そのオブジェクトそのものが戻り値となります。

```dart
final sb = StringBuffer()
  ..write('Hello');
print(sb.toString());
// => Hello
```

上の例では`StringBuffer`のインスタンスを生成し`write`メソッドを呼び出しました。`write`メソッドの戻り値は`void`型ですが、カスケード記法で呼び出しているため、変数`sb`には`StringBuffer`のインスタンスが代入されます。

以下のように、同じインスタンスに繰り返しアクセスする場合に便利です。

```dart
final sb = StringBuffer()
  ..write('Hello')
  ..write(', ')
  ..write('Dart!!');
print(sb.toString());
// => Hello, Dart!!
```

### コレクションのオペレータ

`List`、`Set`、`Map`のリテラルでのみ利用できるオペレータです。

#### Spread演算子

複数のコレクションを結合する際に便利なオペレータです。コレクションリテラル内で`...`を記述すると、そのコレクションの要素が展開されます。

```dart
final list1 = [0, 1, 2, 3];
// list1はその要素が展開され、list2の要素となる
final list2 = [-1, ...list1];
print(list2);
// => [-1, 0, 1, 2, 3]
```

#### 制御構文演算子

コレクションのリテラル内で`if`や`for`が記述できます。要素を追加する条件を記述したり、他のコレクションを追加したりする際に前処理を行うことができます。

```dart
// flagがtrueのときのみ、3を追加
final list = [0, 1, 2, if (flag) 3];

final list1 = [1, 2, 3];
// list1の要素を2倍したものを追加
final list2 = [0, for (var i in list1) i * 2];
print(list2);
// => [0, 2, 4, 6]
```# 2.5 制御構文

分岐やループなどの制御構文です。

## 分岐

### if文

他の多くの言語と同じように、Dartでは`if`文が利用できます。`else`および`else if`は必須ではありません。中括弧（`{ }`）は実行処理が1文の場合に省略可能です。

```dart
final now = DateTime.now();
if (now.hour >= 6 && now.hour < 13) {
  print('Good morning');
} else if (now.hour >= 13 && now.hour < 18) {
  print('Good afternoon');
} else {
  print('Good evening');
}
```

条件式は`bool`型以外を`if`などの条件分岐に利用することはできません。

```dart
final number = 0;

if (number > 0) { // OK
  print('number is greater than 0');
}

if (number) { // => Error: A value of type 'int' can't be assigned to a variable of type 'bool'.
  print('number is true'); 
}
```

### if-case文

`if-case`文はパターンのマッチングと併せて変数へ分解する文法です（パターンと分解宣言については「2.6 パターン」で詳しく解説します）。以下の例は`Record`のフィールドが`null`でないことを判定し、変数`message`と変数`statusCode`に分解しています。いずれかが`null`の場合には`else`節が実行されます。

```dart
final (String?, int?) response = ('OK', 200);
if (response case (String message, int statusCode)) {
  print('Response: message = $message, statusCode = $statusCode');
} else {
  print('No response received.');
}
// => Response: message = OK, statusCode = 200
```

さらに、`when`キーワードに続けて条件式を記述することもできます。

```dart
final (String?, int?) response = ('OK', 200);
if (response case (String message, int statusCode) when statusCode == 200) {
  // messageが非nullかつ、statusCodeが200のときのみ、メッセージを出力
  print('Response: message = $message, statusCode = $statusCode');
} else {
  print('No response received.');
}
// => Response: message = OK, statusCode = 200
```

### switch文

Dartの`switch`文では、ケースに一致すると処理が実行され`switch`文から抜けます。途中で`switch`文を抜けるには`break`が使え、`switch`文のあとの処理を続けて実行します。または、`switch`文が記述されたスコープから抜ける効果として`return`や`throw`を使うこともできます（`throw`と例外処理については「2.11 例外処理」で解説します）。ケースの処理が空の場合は次のケースに抜けます（フォールスルーと言います）。どのケースにも一致しない場合は`default`が実行されます。

```dart
final String color = // 省略
switch (color) {
  case 'red':
    doSomethingIfRed();
  case 'blue':
    doSomethingIfBlue();
  case 'black':
    break; // switch文を抜ける
  case 'green':
  case 'yellow':
    doSomethingIfGreenOrYellow(); // greenとyellowのときに実行される
  default:
    throw 'Unexpected color';
}
```

`continue`文とラベルを使い、ケースの順に関係なくフォールスルーすることが可能です。

```dart
final String color = // 省略
switch (color) {
  case 'red':
    doSomethingIfRed();
    continue other;
  case 'blue':
    doSomethingIfBlue();
  other:
  case 'black':
    throw 'Unexpected color'; // redとblackのときに実行される
}
```

`switch`文も`when`キーワードに続けて条件式を追加することができます。

```dart
final int? statusCode = null;
switch (statusCode) {
  case (int statusCode) when 100 <= statusCode && statusCode < 200:
    print('informational');
  case (int statusCode) when 200 <= statusCode && statusCode < 300:
    print('successful');
  case (int statusCode) when 300 <= statusCode && statusCode < 400:
    print('redirection');
  case (int statusCode) when 400 <= statusCode && statusCode < 500:
    print('client error');
  case (int statusCode) when 500 <= statusCode && statusCode < 600:
    print('server error');
  case (null):
    print('no response received.');
  default:
    print('unknown status code');
}
// => no response received.
```

### 式としてのswitch

`switch`を式として扱うことができます。以下の例は数値`statusCode`の値に応じて、メッセージ文字列を生成しています。

```dart
final int statusCode = // 省略
final message = switch (statusCode) {
  >= 100 && < 200 => 'informational',
  >= 200 && < 300 => 'successful',
  >= 300 && < 400 => 'redirection',
  >= 400 && < 500 => 'client error',
  >= 500 && < 600 => 'server error',
  _ => 'unknown status code',
};
print(message);
```

式としての`switch`は次のような文法となります。

- ケースは`case`キーワードではじまらない
- ケースの処理は単一の式
- 空のケースは記述できない
- ケースのパターンと処理の区切りは`:`ではなく`=>`
- ケースは`,`で区切る
- デフォルトのケースは`_`（ワイルドカード表記）で記述する

## ループ

### for文

他の多くの言語と同じように、Dartでは`for`文が利用できます。

```dart
for (int i = 0; i < 3; ++i) {
  print('index = $i');
}
// => index = 0
// => index = 1
// => index = 2
```

順番にアクセスできるコレクションの`Iterable`クラスがあります。`List`や`Set`のスーパークラスです。この`Iterable`は`for-in`の形式や、

```dart
final list = [0, 1, 2];
for (final element in list) {
  print('element = $element');
}
// => element = 0
// => element = 1
// => element = 2
```

`forEach`メソッドが利用できます。

```dart
final list = [0, 1, 2];
list.forEach((element) {
  print('element = $element');
});
// => element = 0
// => element = 1
// => element = 2
```

### while文

Dartはループの前に条件式を評価する`while`文、ループのあとに条件式を評価する`do-while`文の両方が利用できます。

```dart
final flag = // 省略

while (flag) {
  doSomething();
}

do {
  doSomething();
} while (flag);
```

### breakとcontinue

`for`や`while`文は`break`キーワードでループから抜けます。また、`continue`キーワードで次のループへスキップします。

```dart
for (int i = 0; i < 10; ++i) {
  if (i % 2 == 0) {
    continue;
  }
  if (i > 6) {
    break;
  }
  print('index = $i');
}
// => index = 1
// => index = 3
// => index = 5
```

# 2.6 パターン

Dartにパターンという構文があります。パターン構文にはオブジェクトのマッチングと分解宣言の2つの機能があります。

マッチングはオブジェクトが特定の形式であるかを判断する機能です。以下は値がリテラルと一致するかを判定するパターンです。

```dart
final name = // 省略
switch (name) {
  case 'john': // nameが'john'と一致するか判定
    doSomething();
}
```

分解宣言はオブジェクトをいくつかの変数に分解する機能です。以下は`Record`のフィールドをそれぞれ変数に分解します。

```dart
final record = ('cake', 300);
final (name, price) = record; // recordをnameとpriceに分解
print('This $name is $price yen.');
// => This cake is 300 yen.
```

パターンはいくつか種類があり、使える場所も異なります。そこで、本書ではパターンを以下のように分類し、それぞれを解説します。

1. **マッチング機能しか持たないパターン**
2. **マッチングと分解宣言の2つの機能を持つパターン**
3. **パターンを補助する構文**

## マッチング機能しか持たないパターン

マッチング機能しか持たないパターンは`switch`文、または式としての`switch`、`if-case`文で利用できます。変数の宣言には利用できません。

### 論理演算子、比較演算子

`and`（`&&`）、`or`（`||`）、`==`などの演算子を使ってパターンを記述できます。これらのパターンはマッチング機能しか持たないため変数の宣言には利用できません。

```dart
final int statusCode = // 省略
final message = switch (statusCode) {
  >= 100 && < 200 => 'informational',
  >= 200 && < 300 => 'successful',
  >= 300 && < 400 => 'redirection',
  >= 400 && < 500 => 'client error',
  >= 500 && < 600 => 'server error',
  _ => 'unknown status code',
};
print(message);
```

### 一致判定

リテラルや定数との一致判定をパターンとして記述できます。このパターンはマッチング機能しか持たないため変数の宣言には利用できません。

リテラルであれば、数値、`bool`、文字列リテラルが利用可能です。

```dart
switch (variable) {
  case 123:
    print('123');
  case 'str':
    print('str');
  case false:
    print('false');
}
```

コレクションの一致判定ではリテラルに`const`修飾子を付与する必要があります。

```dart
switch (variable) {
  case const [0, 1, 2]:
    print('list');
  case const {0, 1, 2}:
    print('set');
  case const {'key': 0}:
    print('map');
}
```

`const`や`static`を付与した定数も利用できます。

```dart
switch (variable) {
  case double.maxFinite:
    print('maxFinite');
  case const SomeClass():
    print('SomeClass');
}
```

## マッチングと分解宣言の2つの機能を持つパターン

マッチングと分解宣言の2つの機能を持ち、マッチした際に変数にバインドするパターンです。前項の「マッチング機能しか持たないパターン」と同様に`switch`文、または式としての`switch`、`if-case`文で利用できます。さらに、変数の宣言や`for`文や`for-in`文でも利用できます。

### List

`List`のパターンは`var`または`final`からはじまり、`List`リテラルのように大括弧（`[ ]`）で囲い、中に分解宣言する変数を記述します。

`List`型を分解宣言する場合は要素数が一致している必要があります。ただし、`...`を記述すると任意の長さをマッチさせることができます。

```dart
final [a, b, ..., c] = [0, 1, 2, 3, 4, 5];
print('a = $a, b = $b, c = $c');
// => a = 0, b = 1, c = 5
```

ちなみに、`Set`はパターンが利用できません。

### Map

`Map`のパターンは`var`または`final`からはじまり、`Map`リテラルのように中括弧（`{ }`）で囲い、キーとバリューを`:`で区切ります。キーが一致するとバリューが変数にバインドされます。

`Map`を分解宣言する場合はマップ全体と一致する必要はありません。パターンに存在しないキーは無視されます。

```dart
final { 200: successful, 404: notFound } = {
  200 : 'OK',
  404 : 'Not Found',
  500 : 'Internal Server Error',
};
print('200 -> $successful, 404 -> $notFound');
// => 200 -> OK, 404 -> Not Found
```

### Record

`Record`はすべての構造が一致する必要があります。名前付きフィールドはパターンにもフィールド名を含める必要があります。

```dart
final record = (name: 'cake', price: 300);
// パターンにもフィールド名を含めているのでマッチする
``````dart
final (name: n, price: p) = record;
print('This $n is $p yen.');
// => This cake is 300 yen.

// フィールド名がないのでマッチしない
final (String name, int price) = record;
```

フィールド名を変数名で推論させる記法もあります。

```dart
final record = (name: 'cake', price: 300);
// `:`に続けてフィールド名と同じ名前の変数を宣言
final (:name, :price) = record;
print('This $name is $price yen.');
// => This cake is 300 yen.
```

### Object

その他のクラスをマッチさせることも可能です。クラスのゲッタから分解宣言できます。

```dart
class SomeClass {
  const SomeClass(this.x);
  final int x;
}

final someInstance = SomeClass(123);
final SomeClass(x: number) = someInstance;
print('x = $number');
// => x = 123
```

こちらもゲッタ名を変数名で推論させることができます。

```dart
class SomeClass {
  const SomeClass(this.x);
  final int x;
}

final someInstance = SomeClass(123);
final SomeClass(:x) = someInstance;
print('x = $x');
// => x = 123
```

このパターンはオブジェクト全体と一致する必要はありません。変数へのバインドを省略すれば、クラスの一致だけでマッチさせることも可能です。

```dart
final variable = // 省略
switch (variable) {
  case SomeClass():
    print('SomeClass');
  case String():
    print('String');
}
```

## Tips: for-in文での分解宣言

`for-in`文で分解宣言を利用する例をここで紹介します。`Record`のリストを`for-in`文で処理するときに、`Record`のフィールドを変数にバインドしてみましょう。

```dart
final sweets = [
  (name: 'cake', price: 300),
  (name: 'dango', price: 250),
];

for (final (:name, :price) in sweets) {
  print('name = $name, price = $price');
}
// => name = cake, price = 300
// => name = dango, price = 250
```

このように、`in`の前に分解宣言を使って変数にバインドすることができます。

`Map`の場合はというと、`Iterable`のサブクラスではないため`for-in`文でループを回すことができません。ただし、`Map`の`entries`プロパティを使えば、キーとバリューのペアを変数にバインドしてループを回すことができます。

```dart
final map = {
  200 : 'OK',
  404 : 'Not Found',
  500 : 'Internal Server Error',
};

/* ◆ MapEntry
   キーとバリューを持ったMapの要素 */
// entriesプロパティでIterable<MapEntry>を取得できる
for (var MapEntry(key: key, value: value) in map.entries) {
  print('code: $key, $value');
}
// => code: 200, OK
// => code: 404, Not Found
// => code: 500, Internal Server Error
```

これは「Mapの分解宣言」というより、`MapEntry`を`Object`として分解宣言していることになります。少しややこしいので、Tipsとして紹介しました。

## パターンを補助する構文

ここまで紹介したパターンと組み合わせ使うことで効果を発揮する記述方法を紹介します。

### キャスト

分解宣言で変数に渡す際に、`as`演算子を使い値をキャストします。キャストに失敗すると実行時エラーとなります。

```dart
final List<Object> list = [0, 'one'];
final [number as int, str as String] = list;
```

### nullチェック

値が非nullかどうかをチェックするパターンです。変数名の後ろに`?`を付与します。`when`キーワードと組み合わせて非nullの場合にさらに条件を加えるような書き方ができます。

```dart
int? code = // 省略
switch (code) {
  case final i? when i >= 0:
    doSomething();
  default:
    print('code is null or negative');
}
```

### nullアサーション

nullアサーションパターンは値が`null`だった場合に実行時エラーとなります。変数名の後ろに`!`を付与します。

```dart
int? code = // 省略
switch (code) {
  case final i! when i >= 0:
    doSomething();
  default:
    print('code is negative');
}
```

### ワイルドカード

`_`と記述するとワイルドカードパターンとなります。変数にバインドさせることなく、プレースホルダとして機能します。

```dart
final record = ('cake', 300);
final (name, _) = record;
print('name = $name');
// => name = cake
```

ワイルドカードパターンに型注釈を付与すると、クラスの一致だけでマッチさせることも可能です。

```dart
final variable = // 省略
switch (variable) {
  case SomeClass _:
    print('SomeClass');
  case String _:
    print('String');
}
```

# 2.7 例外処理

Dartの例外処理です。他の多くの言語と同様に`throw`キーワードで例外をスローし、`try-catch`構文で例外を捕捉します。例外が捕捉されなければプログラムは中断します。ただし、Flutterはフレームワークが例外を捕捉する機構を持っているため、例外がスローされてもアプリは終了しません（意図的に終了させることはできます）。

```dart
void doSomething() {
  throw MyException();
}

try {
  doSomething();
} catch (e) {
  print(e);
}
```

## 例外の型 ── ErrorとException

Dartには`Error`型と`Exception`型があり、それぞれ`throw`キーワードで例外としてスローすることができます。

`Error`型はプログラムの失敗によりスローされるものとされています。間違った関数の使い方や、無効な引数が渡された場合など、プログラム上の問題に使用されます。呼び出し元で捕捉する必要のないものです。

一方、`Exception`型は捕捉されることを目的にしたクラスで、エラーに関する情報を持たせるべきとされています。

Dartは以上2つのタイプのほかに任意のオブジェクトを例外としてスローすることも可能ですが、製品レベルのコードでは推奨されていません。

## 例外の捕捉

捕捉する例外の型を指定する場合は`on`キーワードを使用します。

```dart
try {
  doSomething();
} on MyException {
  print('catch MyException');
}
```

例外オブジェクトを受け取りたい場合は`catch`キーワードを使用します。`catch`の第一引数は例外オブジェクト、第二引数はスタックトレースです。第二引数は省略可能です。

```dart
try {
  doSomething();
} catch(e, st) {
  print('catch $e');
  print('stackTrace $st');
}
```

捕捉する型を指定しつつ、例外オブジェクトを受け取る場合は`on`と`catch`を併用します。

```dart
try {
  doSomething();
} on MyException catch(e) {
  print('catch $e');
}
```

## 例外の再スロー

例外処理の中で、呼び出し元へ例外を再スローする場合は`rethrow`キーワードを使用します。

```dart
try {
  doSomething();
} on MyException catch(e) {
  print('catch $e');
  rethrow; // 呼び出し元へ例外を再スロー
}
```

## finally句

例外がスローされるかどうかにかかわらず、最後に実行したい処理を`finally`句に記述できます。

```dart
try {
  doSomething();
} on MyException catch(e) {
  print('catch $e');
} finally {
  doClean();
}
```

例外に一致する`catch`句がない場合は`finally`句が実行されたあとに例外が呼び出し元に伝播します。

## アサーション

プログラムの開発中に思わぬバグが潜んでいないかチェックする機能です。`assert`の第一引数へ`bool`型の条件を渡します。条件が`false`の場合にプログラムの実行を中断します。

```dart
final variable = nonNullObject();
assert(variable != null); // オブジェクトがnullでないことをチェック
assert(variable != null, 'variables should not be null'); // メッセージを付与することもできる
```

Flutterでは`debug`ビルドのときにだけ`assert`文が処理されます。その特徴を利用し、`debug`ビルドのときだけ実行したい処理を以下のように記述することも可能です。

```dart
assert(() {
  print('debug mode');
  return true;
}());
```

## Flutterの例外処理

Flutterアプリはフレームワークが例外を捕捉する機構を持っており、例外がスローされてもプログラムが終了するとは限りません。

フレームワークは2つの例外ハンドラを提供しています。

Flutterのフレームワーク自身がトリガするコールバック（レンダリング処理やウィジェットの`build`メソッドなど）で発生した例外は`FlutterError.onError`にルーティングされます。デフォルトではログをコンソールに出力する動作ですが、コールバックを上書きして独自に処理することも可能です。

```dart
void main() {
  FlutterError.onError = (details) {
    // do something
  };
  runApp(const MyApp());
}
```

それ以外のFlutter内で発生した例外（ボタンのタップイベントハンドラなど）は`PlatformDispatcher`でハンドリングします。

```dart
void main() {
  PlatformDispatcher.instance.onError = (error, stack) {
    print(error);
    return true; // 例外を処理した場合はtrueを返す
  };
  runApp(const MyApp());
}
```

# 2.8 コメント

Dartのコメント、およびドキュメントコメントについて解説します。

単一行のコメントは`//`、複数行のコメントは`/*`で開始し`*/`で終了します。

```dart
// 引数を2倍にする
int doubleValue(int value) {
  return value * 2;
}

/*
  以下のように書くこともできる
  int doubleValue(int value) => value * 2;
*/
```

ドキュメントコメントもサポートしています。`///`または`/**`で開始するコメントはドキュメントコメントとして扱われます（`///`を採用することが推奨されています）。クラスや関数、引数名などを`[ ]`で囲うとその定義へジャンプできるようになります。

```dart
///
/// 引数の値を2倍にして返す
///
/// この関数は、引数の値を2倍にして返す関数です。
/// 引数を半分にする仮数を返す関数として[half]関数があります。
int doubleValue(int value) {
  return value * 2;
}

/**
 * 引数の値を半分にして返す
 * 
 * この関数は、引数の値を半分にして返す関数です。
 * 引数を2倍にする関数として[doubleValue]関数があります。
*/
double half(double value) {
  return value / 2;
}
```# 2.9 null安全

## null許容演算子

Dartではデフォルトが非null許容型です。変数をnull許容型で宣言するときは、型注釈の末尾に`?`を付与します。null許容型の変数は初期値を省略すると`null`で初期化されます。

```dart
int? num; // nullで初期化される
```

非null許容型の変数を`null`で初期化したり、`null`を代入することはコンパイルエラーとなります。

```dart
int nonnullNumber;
nonnullNumber = null; // => A value of type 'Null' can't be assigned to a variable of type 'int'.

int? nullableNumber;
nullableNumber = null; // OK
```

null許容型の変数を扱うには、大きく3つのアプローチがあります。

## null認識演算子

`?.`に続けてプロパティやメソッドを呼び出します。変数が`null`の場合は`null`が返却されます。

```dart
String? str;
print(str?.length); 
// => null
```

## nullアサーション演算子

変数の最後に`!`を付与することで、非null許容型にキャストできます。ただし、変数が`null`の場合は実行時エラーとなります。

```dart
String? str = // 省略
print(str!.length); 
```

## タイププロモーション

`if`文などで`null`チェックを行い、変数が必ず`null`でないことが明らかな場合は自動的に非null許容型として扱うことができます。

```dart
String? str;
if (str == null) {
  return;
}
print(str.length);
```

## そのほかの便利なnull関連演算子

`??`オペレータは評価結果が`null`だった場合に右辺の値を返します。

```dart
String? str1 = 'some string';
String? str2 = null;
print(str1 ?? 'null'); 
// => some string
print(str2 ?? 'null'); 
// => variable is null.
```

`??=`オペレータは変数が`null`の場合にだけ代入が実行されます。

```dart
String? str1 = 'some string';
String? str2 = null;

str1 ??= 'new string';
str2 ??= 'new string';

print(str1);
// => some string
print(str2);
// => new string
```

# 2.10 ライブラリと可視性

Dartでは1つのDartファイルをライブラリと呼びます（`part`命令文により複数のファイルを1つのライブラリとして扱う場合もあります）。外部のライブラリの名前空間にアクセスするには`import`命令を使用します。

```dart
// Dartの組み込みライブラリは dart: スキームを指定します
import 'dart:math';
// それ以外は package: スキームを指定するのが一般的です
import 'package:path/to/file.dart';
```

Dartには`private`や`public`といった可視性をコントロールするキーワードはありません。デフォルトの振る舞いが`public`に相当し、クラスや関数は`import`命令によってライブラリの外からもアクセスできます。クラス名や関数名を`_`（アンダーバー）ではじめると`private`として扱われ、外部からアクセスできなくなります。

# 2.11 関数

Dartの関数はトップレベルに定義することができ、Javaなどとは違い必ずしもクラスに属している必要はありません。

Dartの関数を見ていきましょう。

```dart
String greet(String name) {
  return 'Hello, $name';
}
```

他の多くの言語と記述方法は似ています。この例では、関数`greet()`は`String`型を引数にとり、戻り値が`String`型の関数です。

## 引数

引数の宣言方法には、省略可能引数と名前付き引数という2つのユニークな仕様があります。

### 省略可能引数

`[ ]`で囲った引数は省略して呼び出せるようになります。省略可能引数は省略されると`null`が渡ります。

```dart
void makeColor(int red, int green, int blue, [int? alpha]) {
  // 省略
}

makeColor(0xFF, 0x00, 0x33); // 引数alphaを省略して呼び出し
makeColor(0xFF, 0x00, 0x33, 0xFF); // 引数alphaを与えて呼び出し
```

省略可能引数はデフォルト値を与えることができます。デフォルト値を与えると、省略可能引数も非null許容型とすることができます。

```dart
void makeColor(int red, int green, int blue, [int alpha = 0xFF]) {
  // 省略
}

makeColor(0xFF, 0x00, 0x33); // 引数alphaを省略して呼び出し
makeColor(0xFF, 0x00, 0x33, 0x88); // 引数alphaを与えて呼び出し
```

なお、省略可能引数のリストは引数リストの末尾に置く必要があります。

### 名前付き引数

名前付き引数とは、関数呼び出し時に引数の名前を指定させるしくみです。名前付き引数は引数リストを中括弧（`{ }`）で囲います。

```dart
void makeColor({int? red, int? green, int? blue}) {
  // 省略
}

// 引数の名前を指定する
makeColor(red: 0xFF, green: 0x00, blue: 0x12);
```

名前付き引数はデフォルトでは省略可能として扱われます。必須にする場合は`required`キーワードを与えます。また、デフォルト値を与えることもできます。

```dart
void makeColor({required int red, required int green, required int blue, int alpha = 0xFF}) {
  // 省略
}

makeColor(red: 0x78, green: 0x30, blue: 0xBF);
```

名前付き引数は、引数の順番を変えて呼び出すこともできます。

```dart
void makeColor({required int red, required int green, required int blue, int alpha = 0xFF}) {
  // 省略
}

makeColor(blue: 0xBF, green: 0x30, red: 0x78);
```

なお、名前付き引数のリストは引数リストの末尾に置く必要がありますが、呼び出し時は位置引数を後方に置いても問題ありません。

```dart
// 名前付き引数のリストを末尾に置く
void makeColor(String colorName, {required int red, required int green, required int blue}) {
  // 省略
}

// 呼び出し時は名前付き引数が先頭でも可
makeColor(red: 0x78, green: 0x30, blue: 0xBF, 'purple');
```

## 関数の省略記法

関数が1つの式からなる場合はアロー演算子を使用した省略記法が利用できます。

```dart
// 引数を2倍にして返す関数
int doubleValue(int x) {
  return x * 2;
}

// 上の関数を省略記法で宣言
int doubleValue(int x) => x * 2;
```

## 第一級関数と匿名関数

Dartは第一級関数をサポートした言語です。関数を変数に代入したり、引数に受け取ったりできます。

```dart
// 引数を2倍にして返す関数
int doubleValue(int x) {
  return x * 2;
}

// 関数doubleValueを変数fに代入
final int Function(int) f = doubleValue; 
final result = f(8); 
print("num: $result"); 
// => num: 16
```

関数オブジェクトの型は、

```
戻り値の型 Function(引数リストの型)
```

と宣言します。もちろん型推論も利用可能です。

また、Dartは名前を持たない匿名関数の機能も利用できます。構文は、

```
(引数リスト) { 関数の本体 }
```

のようになります。

先ほどの引数を2倍にして返す関数を匿名関数で記述してみましょう。

```dart
final int Function(int) f = (x) {
  return x * 2;
};
final result = f(8); 
print("num: $result"); 
// => num: 16
```

Dartの匿名関数はクロージャの性質を持ちます。以下のサンプルは`multiple`関数で、引数をキャプチャしたクロージャを生成しています。

```dart
Function multiple(int i) {
  return (x) => x * i;
}

final f1 = multiple(3);
final f2 = multiple(7);

print(f1(2));
// => 6
print(f2(6)); 
// => 42
```

# 2.12 クラス

Dartはクラスベースのオブジェクト指向言語です。すべてのオブジェクトはクラスのインスタンスであり、`null`以外のすべてのクラスは`Object`クラスのサブクラスです。

クラスの定義は`class`キーワードに続けてクラス名を記述します。

```dart
class Point {
  int x = 0;
  int y = 0;
}
```

`Point`という二次元座標を表すクラスを宣言しました。`x`と`y`の初期値をコンストラクタから与える方法を見てみましょう。

```dart
class Point {
  Point(int xPosition, int yPosition) : x = xPosition, y = yPosition;
  
  int x;
  int y;
}
```

コンストラクタの後ろ、`:`に続けて初期化リストを記述します。上の例のように、コンストラクタ引数を直接初期値として与える記述には糖衣構文が用意されています。

```dart
class Point {
  Point(this.x, this.y);
  
  int x;
  int y;
}
```

また、コンストラクタに本体を持たせることも可能ですが、本体が実行される前に非null許容型のクラス変数は初期化済みである必要があります。下記の`Point`クラスではコンパイルエラーになります。

```dart
class Point {
  Point(int xPosition, int yPosition) {
    // => Non-nullable instance field 'x' must be initialized.
    // => Non-nullable instance field 'y' must be initialized.
    x = xPosition;
    y = yPosition;
  }
  
  int x;
  int y;
}
```

初期化リストでパラメータのアサーションを記述することができます。

```dart
class Point {
  Point(this.x, this.y) : assert(x >= 0), assert(y >= 0);
  
  final int x;
  final int y;
}
```

## ゲッタとセッタ

すべてのインスタンス変数は暗黙的にゲッタを持ちます。`final`修飾子のないインスタンス変数は暗黙的にセッタを持ちます。

また、プロパティのカスタムゲッタ、セッタを提供する機能があります。`get`および`set`キーワードを利用します。

```dart
class User {
  User(this.id, this._password);
  
  final int id;
  String _password;
  
  // カスタムゲッタ
  // パスワードを伏せ字にして返す
  String get password => '*******';
  
  // カスタムセッタ
  // パスワードをハッシュ化して保存する
  set password(String newPassword) {
    _password = hash(newPassword);
  }
}
```

## いろいろなコンストラクタ

Dartのクラスのコンストラクタを3つ紹介します。### constantコンストラクタ

クラスインスタンスをコンパイル時定数として扱うためには`constant`コンストラクタが必要です。コンストラクタに`const`キーワードを付与します。インスタンス変数はすべて再代入不可な`final`である必要があります。

```dart
class Point {
  const Point(this.x, this.y);
  
  final int x;
  final int y;
}

const point = Point(1, 2);
```

`constant`コンストラクタは常にコンパイル時定数を生成するとは限りません。`constant`コンストラクタの前に`const`キーワードを付与する、または`const`変数に代入した場合に、常に同じインスタンスが使われます。無駄なインスタンス生成を避けることができるため、Flutterのパフォーマンス向上に役立ちます。

```dart
class Point {
  const Point(this.x, this.y);
  
  final int x;
  final int y;
}

final point1 = const Point(1, 2); // constantコンストラクタの前に`const`キーワードを付与
const point2 = Point(1, 2); // `const`変数に代入
final point3 = Point(1, 2);

print('${point1 == point2}'); // point1とpoint2は同じインスタンス
// => true
print('${point1 == point3}');
// => false
```

### 名前付きコンストラクタ

コンストラクタに識別子を追加して、名前付きコンストラクタを宣言することができます。クラスに複数のコンストラクタを宣言する場合、特別な意味を持ったインスタンスを生成する場合などに有効です。

通常のコンストラクタはクラス名で宣言しますが、名前付きコンストラクタはクラス名.識別子の形で宣言します。

```dart
class Point {
  const Point(this.x, this.y);
  const Point.zero() : x = 0, y = 0; // 名前付きコンストラクタ
  
  final int x;
  final int y;
}
```

また、コンストラクタから自クラスの別のコンストラクタを呼び出すことも可能です。

```dart
class Point {
  const Point(this.x, this.y);
  const Point.zero() : this(0, 0); // 名前のないコンストラクタを呼び出し
  
  final int x;
  final int y;
}
```

### factoryコンストラクタ

必ずしも新しいインスタンスを生成しない場合（キャッシュの利用）や、初期化リストに記述できないロジックがある場合は`factory`コンストラクタを利用します。コンストラクタに`factory`キーワードを付与し、コンストラクタ本体でインスタンスを返す`return`文を記述する必要があります。

```dart
class UserData {
  static final Map<int, UserData> _cache = {};
  
  factory UserData.fromCache(int userId) {
    // キャッシュを探す
    final cache = _cache[userId];
    if (cache != null) {
      // キャッシュがあったので返す
      return cache;
    }
    
    // キャッシュがなかったので新しいインスタンスを生成して返す
    final newInstance = UserData();
    _cache[userId] = newInstance;
    return newInstance;
  }
  
  // 省略
}
```

## クラス継承

Dartの公式ドキュメントではクラス継承のことを「拡張」（Extend a class）と呼んでいますが、本書では「継承」と呼ぶこととします。のちほど紹介します「拡張メソッド」（Extension methods）と区別するためです。

サブクラスの宣言は`extends`キーワードに続けてスーパークラスの名前を記述します。

```dart
class Animal {
  String greet() => 'hello';
}

class Dog extends Animal {
}

final dog = Dog();
print(dog.greet()); 
// => hello
```

スーパークラスを参照するには`super`キーワードを用います。

```dart
class Animal {
  String greet() => 'hello';
}

class Dog extends Animal {
  String sayHello() => super.greet();
}

Dog dog = Dog();
print(dog.sayHello());
// => hello
```

スーパークラスのメソッドをオーバーライドする際は、`@override`アノテーションを付与することが推奨されています。

```dart
class Animal {
  String greet() => 'hello';
}

class Dog extends Animal {
  @override
  String greet() => 'bowwow';
}

Animal animal = Dog();
print(animal.greet()); 
// => bowwow
```

メソッドのオーバーライドにはいくつかの条件があります。

- 戻り値の型がスーパークラスのメソッドの戻り値の型と同じ、またはそのサブタイプである
- 引数の型がスーパークラスのメソッドの引数の型と同じ、またはそのスーパークラスである
- 位置パラメータの数が同じである
- ジェネリックメソッドを非ジェネリックメソッドでオーバーライドできない、また非ジェネリックメソッドをジェネリックメソッドでオーバーライドできない

また、戻り値の型がnull許容型のメソッドを非null許容型のメソッドでオーバーライドすることもできます。

```dart
class Animal {
  String? greet() => null; // 戻り値はnull許容型
}

class Dog extends Animal {
  @override
  String greet() => 'bowwow'; // 戻り値を非null許容型でオーバーライド
}
```

## スーパークラスのコンストラクタ

サブクラスのコンストラクタでは、スーパークラスの引数のないコンストラクタが自動的に呼び出されます。スーパークラスに引数なしコンストラクタがない場合は、明示的にスーパークラスのコンストラクタを呼び出す必要があります。

```dart
class Animal {
  Animal(this.name);
  final String name;
}

class Dog extends Animal {
  Dog(String name) : super(name);
}
```

コンストラクタの後ろ、`super`キーワードに続けてスーパークラスのコンストラクタを呼び出します。上の例のように、コンストラクタ引数をそのままスーパークラスのコンストラクタに渡す記述は糖衣構文が用意されています。

```dart
class Animal {
  Animal(this.name);
  final String name;
}

class Dog extends Animal {
  Dog(super.name);
}
```

## 暗黙のインタフェース

Dartではすべてのクラスは暗黙的にインタフェースが定義されています。そのクラスのすべての関数とインスタンスメンバを持ったインタフェースです。`implements`キーワードに続けてインタフェースとして実装する型名を記述します。

```dart
class Animal {
  String greet() => 'hello';
}

class Dog implements Animal {
  @override
  String greet() => 'bowwow';
}

Animal animal = Dog();
print(animal.greet()); 
// => bowwow
```

すべてのインスタンスメンバ、メソッドをオーバーライドしなければならない点が、`extends`キーワードで継承するときとの違いです。

## 拡張メソッド

既存のクラスへメソッドやゲッタ、セッタを追加することができます。拡張メソッドは以下のような文法で宣言します。

```dart
extension <拡張名> on <拡張対象の型> {
  ...
}
```

`List`型に要素を入れ替える`swap`関数を拡張する例を示します。

```dart
extension SwapList<T> on List<T> {
  // 引数のインデックスの要素を入れ替える拡張メソッド
  void swap(int index1, int index2) {
    final tmp = this[index1];
    this[index1] = this[index2];
    this[index2] = tmp;
  }
}

final list = [1, 2, 3];
list.swap(0, 2); // インデックス0と2の要素を入れ替える
print(list); 
// => [3, 2, 1]
```

静的な拡張メソッドを宣言することはできません。ですが、拡張メソッドから呼び出し可能なヘルパ関数として利用することができます。

```dart
extension SwapList<T> on List<T> {
  // 静的メソッド（拡張メソッドから呼び出し可能）
  static bool noNeedToSwap(List<T> list) {
    return list.isEmpty;
  }
  
  void swap(int index1, int index2) {
    if (noNeedToSwap(this)) { // 拡張メソッド内で静的メソッドを利用するのはOK
      return;
    }
    
    final tmp = this[index1];
    this[index1] = this[index2];
    this[index2] = tmp;
  }
}

final list = [1, 2, 3];
// 拡張メソッド以外からは呼び出せない
List.noNeedToSwap(list); // => Error: The method 'noNeedToSwap' isn't defined for the type 'List'.
```

拡張名のない拡張メソッドは同一ファイル内でのみ参照可能です。

```dart
extension on List<T> {
  void swap(int index1, int index2) {
    final tmp = this[index1];
    this[index1] = this[index2];
    this[index2] = tmp;
  }
}
```

## mixin ── クラスに機能を追加する

Dartは多重継承を許可していませんが、それに似た言語仕様として`mixin`（ミックスイン）があります。`with`キーワードに続けてミックスイン名を記述します。

```dart
mixin Horse {
  void run() {
    print('run');
  }
}

mixin Bird {
  void fly() {
    print('fly');
  }
}

class Pegasus with Bird, Horse {
}

final pegasus = Pegasus();
pegasus.run(); // PegasusはHorseのメソッドを持つ
// => run
pegasus.fly(); // PegasusはBirdのメソッドも持つ
// => fly
```

ミックスイン（上の例では`Horse`と`Bird`）はクラスのようにメソッドやフィールドを宣言できます。クラスとの違いは、

- インスタンス化できないこと
- `extends`キーワードを使って他のクラスから継承できないこと
- コンストラクタを宣言できないこと

です。

ミックスインを宣言する際に、使用するクラスを制限することも可能です。次の例ではミックスイン`Horse`と`Bird`は`on`キーワードでクラス`Animal`でしか使用できないよう制限をしています。この制限によりミックスイン`Horse`と`Bird`内でクラス`Animal`のメソッドが利用できます。

```dart
class Animal {
  String greet() => 'hello';
}

// onキーワードで使用可能なクラスをAnimalに制限
mixin Horse on Animal {
  void run() {
    greet(); // Animalのメソッドを使用可能
    print('run');
  }
}

// onキーワードで使用可能なクラスをAnimalに制限
mixin Bird on Animal {
  void fly() {
    greet(); // Animalのメソッドを使用可能
    print('fly');
  }
}

class Pegasus extends Animal with Bird, Horse {
}
```

なお、`mixin class`で宣言する場合は`on`キーワードは使えません。

## Enum

Dartの列挙型です。

### Enumの宣言

列挙型は`enum`キーワードを使い宣言します。```dart
enum Shape {
  circle, triangle, square,
}
```

フィールドやメソッド、`constant`コンストラクタを持った高機能な`Enum`も宣言できます。通常のクラスに似た構文ですが、いくつかの条件があります。

- 1つ以上のインスタンスすべてが冒頭で宣言されていなくてはならない
- インスタンス変数は`final`でなければならない（`mixin`で追加されるものも同様）
- コンストラクタは`constant`コンストラクタまたは`factory`コンストラクタが宣言可能
- 他のクラスを継承することはできない
- `index`、`hashCode`、`==`演算子をオーバーライドすることはできない
- `values`という名前のメンバを宣言することができない

```dart
// フィールドやfactoryコンストラクタを持ったEnum
enum Shape { 
  circle(corner: 0), 
  triangle(corner: 3), 
  square(corner: 4); 
  
  final int corner; 
  
  const Shape({ 
    required this.corner, 
  }); 
  
  factory Shape.ellipse() {
    return circle; 
  } 
}

// factoryコンストラクタからインスタンスを取得
final ellipse = Shape.ellipse();
// フィールドにアクセス
print(ellipse.corner);
// => 0
```

### Enumの利用

`Enum`の型名に続きドット（`.`）のあとに列挙子名でアクセスすることができます。

```dart
final myShape = Shape.circle;
assert(myShape == Shape.circle);
```

各列挙子には宣言された順に`index`が振られ、ゲッタから取得できます。また列挙子の名前を`String`型で取得できる`name`プロパティも生成されます。

```dart
final myShape = Shape.circle;
print(myShape.index);
// => 0
print(myShape.name);
// => circle
```

`Enum`の型にはすべての列挙子をリストで得られる`values`プロパティも生成されます。

```dart
Shape.values.forEach((shape) {
  print(shape.name);
});
// => circle
// => triangle
// => square
```

## クラス修飾子

クラス修飾子はクラスやミックスインに付与し、インスタンス化や継承に制限を与えます。その効果はさまざまありますが、本書では以下のように分類してみました。

- **タイプ1**: インスタンス化、`extends`キーワードによる継承、`implements`キーワードによる実装、これらに制限を与える
- **タイプ2**: タイプ1以外の効果を持つ修飾子（タイプ1の効果を併せ持つ場合もある）

以下はクラス修飾子の一覧です。

- `abstract`
- `base`
- `final`
- `interface`
- `sealed`
- `mixin`

### abstract

`abstract`修飾子はタイプ1です。

| インスタンス化 | extendsキーワードによる継承 | implementsキーワードによる実装 |
|---------------|---------------------------|------------------------------|
| × | ○ | ○ |

`abstract`修飾子を使って宣言されたクラスは本体のない関数を宣言できます。またクラスをインスタンス化できなくなります。

```dart
abstract class Animal {
  String greet(); // 本体のないabstract関数
}

class Dog extends Animal {
  @override
  String greet() => 'bowwow';
}

// インスタンス化はできない
// final animal = Animal();

Animal dog = Dog();
print(dog.greet()); 
// => bowwow
```

### base

`base`修飾子はタイプ1です（表は自身が宣言されたライブラリ以外での制限を示しています）。

| インスタンス化 | extendsキーワードによる継承 | implementsキーワードによる実装 |
|---------------|---------------------------|------------------------------|
| ○ | ○ | × |

`base`修飾子を使って宣言されたクラスは自身が宣言されたライブラリ以外では`implements`キーワードを使った実装を禁止します。

**ライブラリ1**
```dart
base class Animal {
  String greet() {
    return 'hello';
  }
}
```

**ライブラリ2**
```dart
// クラスの継承はOK。Dogクラスにもbase修飾子を付与しなければならない理由は後述。
base class Dog extends Animal {
}

// クラスの実装はNG、コンパイルエラー
// base class Cat implements Animal {
//   @override
//   String greet() => 'mew';
// }

final animal = Animal(); // インスタンス化はOK
final dog = Dog();
print(dog.greet()); 
// => hello
```

`implements`キーワードを使ったクラスの実装が自身のライブラリ内に限定されるため、プライベートメソッドも含めて実装を強制することになります。`base`修飾子を使う目的はプライベートメソッドまで含めて全体の整合性を保つことにあります。そのため、`base`修飾子を使って宣言されたクラスはライブラリ外でも`base`修飾子か、同じように実装を制限するクラス修飾子を付与しなければなりません。上の例では`Dog`クラスにも`base`修飾子を付与しています。

**ライブラリ1**
```dart
base class Animal {
  void _sleep() {
    print('sleep');
  }
  
  String greet() {
    return 'hello';
  }
}

// 同一ライブラリ内であればクラスの実装OK
base class Cat implements Animal {
  // 同一ライブラリ内なのでプライベートメソッドもオーバーライドが強制される
  @override
  void _sleep() {
    // 省略
  }
  
  @override
  String greet() {
    return 'mew';
  }
}
```

### interface

`interface`修飾子はタイプ1です（表は自身が宣言されたライブラリ以外での制限を示しています）。

| インスタンス化 | extendsキーワードによる継承 | implementsキーワードによる実装 |
|---------------|---------------------------|------------------------------|
| ○ | × | ○ |

`interface`修飾子を使って宣言されたクラスは自身が宣言されたライブラリ以外では`extends`キーワードを使ったクラスの継承を禁止します。

**ライブラリ1**
```dart
interface class Animal {
  String greet() {
    return 'hello';
  }
}
```

**ライブラリ2**
```dart
// クラスの継承はNG
// class Dog extends Animal {
// }

// クラスの実装はOK
class Cat implements Animal {
  @override
  String greet() => 'mew';
}

final animal = Animal(); // インスタンス化はOK
final cat = Cat();
print(cat.greet()); 
// => mew
```

`implements`キーワードを使い、すべてのメソッドを実装する必要があります。常に同じライブラリで実装された既知の実装が呼び出されることが保証できます。

#### abstractとinterfaceの組み合わせ

`abstract`と`interface`の2つの修飾子を組み合わせると実装を持たない純粋なインタフェースを定義することが可能になります。`interface`修飾子の効果として、外部のライブラリでは`implements`キーワードを使ったクラス実装が強制され、`abstract`修飾子の効果として実装を持たない関数を宣言できます。

### final

`final`修飾子はタイプ1です（表は自身が宣言されたライブラリ以外での制限を示しています）。

| インスタンス化 | extendsキーワードによる継承 | implementsキーワードによる実装 |
|---------------|---------------------------|------------------------------|
| ○ | × | × |

`final`修飾子を使って宣言されたクラスは、自身が宣言されたライブラリ以外ではすべてのサブタイプ化を禁止します。`extends`キーワードを使ったクラスの継承、`implements`キーワードを使ったクラスの実装の両方が禁止されます。

**ライブラリ1**
```dart
final class Animal {
  String greet() {
    return 'hello';
  }
}
```

**ライブラリ2**
```dart
// クラスの継承はNG
// base class Dog extends Animal {
// }

// クラスの実装もNG
// base class Cat implements Animal {
//   @override
//   String greet() => 'mew';
// }

final animal = Animal(); // インスタンス化はOK
```

### mixin

`mixin`修飾子はタイプ2です。

`mixin`修飾子を使って宣言されたクラスはミックスインのように扱うことが可能でありながら、クラスなのでインスタンス化することができます。ただし、ミックスインと同様に`extends`は使えずコンストラクタも宣言できません。

```dart
mixin class Horse { // `mixin class`で宣言
}

mixin Bird {
}

class Pegasus with Bird, Horse { // `with`キーワードでHorseをmixin
}

final horse = Horse(); // Horseはインスタンス化可能
```

### sealed

`sealed`修飾子はタイプ2です。`sealed`修飾子を使うとサブタイプを`Enum`のように扱うことができます。`sealed`修飾子を使って宣言されたクラスは、自身が宣言されたライブラリ以外ではすべてのサブタイプ化を禁止します。この点は`final`と共通していますが、さらにクラス自身が暗黙的に`abstract class`として扱われます。

**ライブラリ1**
```dart
sealed class Shape {
  abstract int corner;
}

// Shape shape = Shape(); インスタンス化はNG

class Rectangle extends Shape {
  @override
  int corner = 4;
}

class Triangle extends Shape {
  @override
  int corner = 3;
}

class Circle extends Shape {
  @override
  int corner = 0;
}
```

`switch`文ですべてのサブタイプが網羅されていなければ、コンパイラが警告を出します。

**ライブラリ2**
```dart
// サブクラス化はNG
// class Rectangle extends Shape {
//   @override
//   int corner = 4;
// }

final Shape shape = getShepe();
switch (shape) {
  case Rectangle():
    print('Rectangle');
  case Triangle():
    print('Triangle');
  case Circle():
    print('Circle');
}
```

# 2.13 非同期処理

Dartの非同期処理です。`Future`型と`Stream`型、スレッドのようなしくみのアイソレートについて解説します。

## Future型

Dartには非同期処理の結果を取り扱う`Future`型があります。

```dart
import 'dart:io';

void main() {
``````dart
  Future<String> content = File('file.txt').readAsString();
  content.then((content) {
    print(content);
  });
}
```

`readAsString`メソッドは非同期にファイルの内容を読み取り、文字列として返します。戻り値の型は`Future<String>`型です。`Future`の`then`メソッドには処理が完了したときに呼び出されるコールバックを渡します。

`Future`クラスは`async`、`await`キーワードと組み合わせることで、同期的なコードのように記述できます。

```dart
import 'dart:io';

Future<void> main() async {
  String content = await File('file.txt').readAsString();
  print(content);
}
```

`readAsString`メソッドの呼び出しに`await`キーワードを付与しました。これにより、`readAsString`が終了するまで待機します。また、戻り値の`Future<String>`型を`String`型に自動的に変換します。コールバックのネストが減り、コードが簡潔になります。

重要なポイントとして`await`キーワードは`async`キーワードを付与したメソッド内でしか使えません。また、`async`キーワードを付与したメソッドの戻り値は暗黙的に`Future`クラスでラップされます。`main()`の本体に`async`キーワードを付与し、戻り値は`Future<void>`に変更しています。

### エラーハンドリング

`Future`型のエラーハンドリングです。`catchError`メソッドで例外が発生したときに呼び出されるコールバックを登録します。

```dart
// 戻り値がFuture型、例外をスローする関数
Future<String> fetchUserName() {
  var str = Future.delayed(
    const Duration(seconds: 1),
    () => throw 'User not found.');
  return str;
}

fetchUserName()
  .then((name) {
    print('User name is $name');
  })
  .catchError((e) {
    print(e);
  });
// => User not found.
```

`async-await`で実行した非同期処理は`try-catch`構文で例外を捕捉します。

```dart
// 戻り値がFuture型、例外をスローする関数
Future<String> fetchUserName() {
  var str = Future.delayed(
    const Duration(seconds: 1),
    () => throw 'User not found.');
  return str;
}

try {
  final name = await fetchUserName();
  print('User name = $name');
} catch (e) {
  print(e); 
}
// => User not found.
```

例外発生時に返す代替の値がある場合は`then`メソッドの引数`onError`で処理する方法があります。

```dart
// 戻り値がFuture型、例外をスローする関数
Future<String> fetchUserName() {
  var str = Future.delayed(
    const Duration(seconds: 1),
    () => throw 'User not found.');
  return str;
}

final result = await fetchUserName()
  .then((name) {
    // fetchUserName関数が正常終了した場合の値を返す
    return 'User name is $name';
  },
  onError: (e, st) {
    // fetchUserName関数で例外が発生した場合の値を返す
    return 'Unknown user';
  },
);
print(result); 
// => Unknown user
```

## Stream型

非同期に連続した値を扱う`Stream`型です。

```dart
import 'dart:io';

void main() {
  final file = File('file.txt');
  final Stream<List<int>> stream = file.openRead();
  stream.listen((data) {
    print('data: ${data.length} bytes');
  });
}
```

`openRead`メソッドはファイルを読み込み、一定のサイズごとにデータを返します。戻り値の型は`Stream<List<int>>`型です。`Stream`は`listen`メソッドで購読し、データが通知されたときに呼び出されるコールバックを登録します。

`Future`クラスと同様に`async`と`await for`キーワードと組み合わせることで、同期的なコードのように記述できます。

```dart
import 'dart:io';

Future<void> main() async {
  final file = File('file.txt');
  final Stream<List<int>> stream = file.openRead();
  await for (final data in stream) {
    print('data: ${data.length} bytes');
  };
}
```

`Stream`を`for`文に渡し、`await`キーワードを付与しました。`for`文の一時変数`data`には`Stream`の値である`List<int>`型のデータが代入されます。こちらも`await`を使うため関数に`async`キーワードを付与する必要があります。

### Streamの購読をキャンセル、一時停止する

`listen`メソッドの戻り値は`StreamSubscription`型です。`cancel`メソッドで購読をキャンセルできます。

```dart
import 'dart:io';

void main() {
  final file = File('file.txt');
  final subscription = file.openRead()
    .listen((data) {
      print('data: ${data.length} bytes');
    }
  );
  
  Future<void> result = subscription.cancel(); // 購読をキャンセル
}
```

`cancel`を呼び出すと、以降イベントが通知されなくなります。購読がキャンセルされることで、`Stream`でリソースの解放処理が発生する場合があります。解放処理の完了や例外を検知するために`cancel`メソッドの戻り値は`Future`型となっています。たとえば、ファイルを`openRead`メソッドで読み込んだ後に削除するようなケースで利用します。

また、購読を一時停止する`pause`メソッド、購読を再開する`resume`メソッドがあります。

```dart
import 'dart:io';

Future<void> main() async {
  final file = File('file.txt');
  final subscription = file.openRead()
    .listen((data) {
      print('data: ${data.length} bytes');
    }
  );
  
  await Future.delayed(const Duration(seconds: 1));
  subscription.pause(); // 購読を一時停止
  await Future.delayed(const Duration(seconds: 4));
  subscription.resume(); // 購読を再開
}
```

### Stream型を生成する関数

`Stream`型を返す関数を実装するには`async*`キーワードを使います。関数が呼び出されると`Stream`が生成され、`Stream`が購読されると関数の本体が実行されます。

```dart
import 'dart:io';

Stream<String> languages() async* {
  await Future.delayed(const Duration(seconds: 1));
  yield 'Dart';
  await Future.delayed(const Duration(seconds: 1));
  yield 'Kotlin';
  await Future.delayed(const Duration(seconds: 1));
  yield 'Swift';
  await Future.delayed(const Duration(seconds: 1));
  yield* Stream.fromIterable(['JavaScript', 'C++', 'Go']);
}
```

`String`型の`Stream`を生成する関数の例です。`yield`に続いて`String`を記述すると、その値が戻り値の`Stream`に通知されます。`yield*`に続いて`Stream`を記述すると、その`Stream`の値が戻り値の`Stream`に通知されます。購読がキャンセルされた際は、次の`yield`文が実行されると関数の実行が中断されます。

### Streamの終わり

`Stream`の終了時に処理を実行するには`listen`メソッドの`onDone`にコールバックを渡します。

```dart
Stream<String> languages() async* {
  await Future.delayed(const Duration(seconds: 1));
  yield 'Dart';
  await Future.delayed(const Duration(seconds: 1));
  yield 'Kotlin';
  await Future.delayed(const Duration(seconds: 1));
  yield 'Swift';
  await Future.delayed(const Duration(seconds: 1));
  yield* Stream.fromIterable(['JavaScript', 'C++', 'Go']);
}

void main() async {
  languages().listen((language) {
    print(language);
  }, onDone: () {
    print('Done');
  });
}
// => Dart
// => Kotlin
// => Swift
// => JavaScript
// => C++
// => Go
// => Done
```

`async - await for`を使った場合は、`Stream`が終了すると`for`文から抜けます。`Stream`の終了時に実行する処理はシンプルに`for`文のあとに書けばOKです。

```dart
Stream<String> languages() async* {
  await Future.delayed(const Duration(seconds: 1));
  yield 'Dart';
  await Future.delayed(const Duration(seconds: 1));
  yield 'Kotlin';
  await Future.delayed(const Duration(seconds: 1));
  yield 'Swift';
  await Future.delayed(const Duration(seconds: 1));
  yield* Stream.fromIterable(['JavaScript', 'C++', 'Go']);
}

Future<void> main() async {
  await for (final language in languages()) {
    print(language);
  }
  print('Done');
}
// => Dart
// => Kotlin
// => Swift
// => JavaScript
// => C++
// => Go
// => Done
```

`Stream`は購読をキャンセルしない限り終了しない特性を持ったものもあり得ます。たとえば、`Stream.periodic`コンストラクタから得られる`Stream`は一定の間隔で繰り返し値を通知する`Stream`を生成します。このような終了しない`Stream`で`async - await for`を用いると以降の処理が実行されないので注意が必要です。

```dart
Future<void> main() async {
  await for (final count in Stream<int>.periodic(const Duration(seconds: 1), (i) => i)) {
    print(count);
  }
  print('Done!'); // この行は実行されない
}
```

### エラーハンドリング

`Stream`の例外を処理するには`listen`メソッドの`onError`にコールバックを渡します。

```dart
Stream<String> languages() async* {
  await Future.delayed(const Duration(seconds: 1));
  yield 'Dart';
  await Future.delayed(const Duration(seconds: 1));
  throw Exception('Some error');
}

void main() {
  languages().listen((language) {
    print(language);
  }, onError: (e) {
    print(e);
  });
}
// => Dart
// => Exception: Some error
```

`async - await for`を使った場合は、`try-catch`構文で例外を捕捉します。

```dart
Stream<String> languages() async* {
  await Future.delayed(const Duration(seconds: 1));
  yield 'Dart';
  await Future.delayed(const Duration(seconds: 1));
  throw Exception('Some error');
}

Future<void> main() async {
  try {
    await for (final language in languages()) {
      print(language);
    }
  } catch (e) {
    print(e);
  }
}
// => Dart
// => Exception: Some error
```

また、`listen`メソッドの第四引数`cancelOnError`は`Stream`で例外が発生した場合に購読を中止するかどうかを指定できます。デフォルト値は`false`で、例外が発生しても購読は継続されます。

### StreamController

`async*`関数よりも簡単に`Stream`を生成する方法として`StreamController`クラスがあります。

```dart
import 'dart:async';

class Counter {
  int _count = 0;
  StreamController<int> _controller = StreamController<int>();
  
  Stream<int> get stream => _controller.stream;
  
  void increment() {
    _count++;
    _controller.add(_count);
  }
}

Future<void> main() async {
  final counter = Counter();
  counter.increment();
  counter.increment();
  
  counter.stream.listen((i) {
    print('count: $i');
  });
  
  counter.increment();
}
// => count: 1
// => count: 2
// => count: 3
```

`Counter`クラスは内部に`StreamController`を持ち、`increment`メソッドが呼び出されると`StreamController`に値を送信します。`StreamController`への値の送信は`add`メソッドで行います。`async*`関数では関数内で`yield`を使ってイベントを送信しましたが、`StreamController`では外部からイベントを送信できるため、より柔軟に`Stream`を扱うことができます。

このほか、例外を送信する`addError`メソッドや、購読されているかどうかを判定する`hasListener`プロパティなどがあります。

`async*`は購読されるまで関数の本体が実行されません。しかし、`StreamController`は購読されていなくても`add`メソッドで値を送信することができ、その値はバッファリングされ購読されたとき一斉に通知されます（購読の一時停止時も同様にバッファリングされます）。そのため、用途によりメモリを消費する可能性があるので注意が必要です。### ブロードキャスト

1つの`Stream`に対して複数回購読すると例外が発生します。複数の購読者へイベントを通知するには、`asBroadcastStream`メソッドを使います。

```dart
import 'dart:async';

Stream<String> languages() async* {
  await Future.delayed(const Duration(milliseconds: 500));
  yield 'Dart';
  await Future.delayed(const Duration(milliseconds: 500));
  yield 'Kotlin';
  await Future.delayed(const Duration(milliseconds: 500));
  yield 'Swift';
  await Future.delayed(const Duration(milliseconds: 500));
  yield* Stream.fromIterable(['JavaScript', 'C++', 'Go']);
}

Future<void> main() async {
  final broadcastStream = languages().asBroadcastStream();
  
  await Future.delayed(const Duration(milliseconds: 1000)); // ❶
  
  broadcastStream.listen((i) { // ❷
    print('listener 1: $i');
  });
  
  await Future.delayed(const Duration(milliseconds: 1100));
  
  broadcastStream.listen((i) { // ❸
    print('listener 2: $i');
  });
}
// => listener 1: Dart
// => listener 1: Kotlin
// => listener 1: Swift
// => listener 2: Swift
// => listener 1: JavaScript
// => listener 2: JavaScript
// => listener 1: C++
// => listener 2: C++
// => listener 1: Go
// => listener 2: Go
```

ブロードキャストタイプの`Stream`は最初に購読されたタイミングで元の`Stream`の購読を開始します。そのため❶で待機している間は`languages`関数の本体は実行されません。❷で購読が開始されると`languages`関数の本体が実行され、`yield`でイベントが通知されます。❸で2つ目の購読がスタートすると、そのタイミングからイベントが通知され、それまでの値は通知されません。

### Streamを変更する

標準で`Stream`を変化させるメソッドが多く提供されています。ここですべてを紹介しませんが、代表的なものは、

- `Stream`の値を変換する`map`
- `Stream`の値をフィルタする`where`
- `Stream`の値の最大数を制限する`take`

などがあります。

```dart
import 'dart:async';

Stream<int> numberStream() {
  return Stream.fromIterable(List.generate(10, (index) => index));
}

void main() {
  numberStream()
    .where((num) => num % 2 == 0) // 0, 2, 4, 6, 8
    .map((num) => num * 2) // 0, 4, 8, 12, 16
    .take(3) // 0, 4, 8
    .listen((num) {
      print(num);
    });
}
// => 0
// => 4
// => 8
```

## Zone ── 非同期処理のコンテキスト管理

Dartには`Zone`という非同期処理のコンテキストを管理するしくみがあります。その機能の一つに非同期処理で捕捉されなかった例外のハンドリングがあります。

以下は`Zone`を使わない場合の例です。

```dart
import 'dart:async';

// 戻り値がFuture型、例外をスローする関数
Future<String> fetchUserName() {
  var str =
    Future.delayed(const Duration(seconds: 1), () => throw 'User not found.');
  return str;
}

void main() {
  fetchUserName().then((data) {
    print(data);
  });
}
```

例外をスローする非同期処理です。`Future`へ例外発生時のコールバックを登録していません。実行するとプログラムが強制終了します。

続いて、`Zone`を使って例外をハンドリングする例です。

```dart
import 'dart:async';

// 戻り値がFuture型、例外をスローする関数
Future<String> fetchUserName() {
  var str =
    Future.delayed(const Duration(seconds: 1), () => throw 'User not found.');
  return str;
}

void main() {
  runZonedGuarded(() {
    fetchUserName().then((data) {
      print(data);
    });
  }, (error, stackTrace) {
    print('Caught: $error');
  });
}
// => Caught: User not found.
```

`runZonedGuarded`は第一引数に受け取った処理を自身の`Zone`で実行します。第二引数には自身の`Zone`で発生した例外をハンドリングするコールバックを渡します。実行するとプログラムが強制終了することなく、例外がハンドリングされます。ただし、Flutterのエラーハンドリングは`Zone`ではなく前述の`PlatformDispatcher`を使うことが一般的です。

実際はすべてのDartコードは`Zone`で実行されます（`main`関数は暗黙的にデフォルト`Zone`で実行されています）。`Zone`にはエラーハンドリングのほかにも`print`関数の動作を変更する機能や非同期コールバックの登録を捕捉する機能などがあります。

## アイソレート

アイソレートはスレッドやプロセスのようなしくみで、

- 専用のヒープメモリを持つ
- 専用の単一のスレッドを持ち、イベントループを実行する
- アイソレート間でメモリの共有はできない

といった特徴があります。

すべてのDartプログラムはアイソレートの中で実行されます。通常、自動的にメインアイソレートが起動し、その中でプログラムが実行されるので意識することはありません。

### Flutterアプリとアイソレート

Flutterアプリを作るうえでアイソレートを意識することはほとんどありません。前述のとおりメインアイソレートが自動的に起動し、その中でDartのプログラムが実行されます。

アプリでよく実装される時間のかかる処理として、HTTP通信やファイルのI/Oが挙げられます。これらはOSなどDartコード外で実行され（その間Dartのアイソレートは他のイベントを処理可能）、完了するとDartが再開されるためアプリがフリーズするようなことは起こりません。

アイソレートを活用するアプリのサンプルを以下に用意しました。Dartのプログラムで数値が素数かどうか判定する関数です。67280421310721という大きな素数を判定させるため計算に時間がかかります。ボタンをタップすると計算が開始します。

**lib/main.dart**

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: HomeScreen(),
    ),
  );
}

// 引数が素数かどうか判定する関数
bool isPrime(int value) {
  if (value == 1) {
    return false;
  }
  for (var i = 2; i < value; ++i) {
    if (value % i == 0) {
      return false;
    }
  }
  return true;
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            ElevatedButton(
              onPressed: () async {
                const number = 67280421310721;
                final result = await compute((number) { // ❶
                  return isPrime(number);
                }, number);
                print('$number is prime: $result');
              },
              child: const Text('button')),
          ],
        ),
      ),
    );
  }
}
```

`compute`関数は新たにアイソレートを起動し、引数に渡した関数オブジェクトを実行します（❶）。筆者の環境では、`compute`関数に渡した`isPrime(number);`をメインアイソレートで実行するとインジケータのアニメーションが止まり、Dartプログラムがブロックしたことが目視できました。

# 2.14 まとめ

Dartの言語仕様について解説しました。変数宣言、組み込み型、オペレータなど他の多くの言語と似たような文法が多く、基本的には習得しやすい言語だと思います。ただ、Dart 3で登場したパターンや、クラス修飾子など、全体像を把握するのが難しい機能も増えてきた印象です。

Dartは現在も活発に開発が進んでおり、これからも新しい機能が増えていくことでしょう。最新情報は公式の情報を参照してください。その前の基礎固めに本章がお役に立てばと思います。

---
