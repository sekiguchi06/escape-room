```dart
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

`async*`は購読されるまで関数の本体が実行されません。しかし、`StreamController`は購読されていなくても`add`メソッドで値を送信することができ、その値はバッファリングされ購読されたとき一斉に通知されます（購読の一時停止時も同様にバッファリングされます）。そのため、用途によりメモリを消費する可能性があるので注意が必要です。