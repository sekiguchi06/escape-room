# 2.5 制御構文

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
```