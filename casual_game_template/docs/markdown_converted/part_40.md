# const修飾子・状態管理・Riverpod最適化

## 10.2 高速で保守性の高い実装（続き）

```dart
void _incrementCounter() {
  setState(() {
    _counter++;
  });
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Home Screen'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ColoredText( // ❶
            text: 'You have pushed the button\nthis many times:',
            color: Colors.blueGrey,
          ),
          Text(
            '$_counter',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _incrementCounter,
      tooltip: 'Increment',
      child: const Icon(Icons.add),
    ),
  );
}
}

class ColoredText extends StatelessWidget { // ❷
  const ColoredText({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    print('ColoredText build'); // ❸
    return ColoredBox(
      color: color,
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
```

ColoredBoxウィジェットを構築していた部分を、ColoredTextウィジェットとして切り出しました（❷）。ColoredTextウィジェットはconstantコンストラクタを実装しています。また、ColoredTextウィジェットを生成している箇所は、const修飾子を付与しています（❶）。これで、ColoredTextウィジェットは祖先の再構築の影響を受けなくなります。

このサンプルを実行すると、FloadingActionButtonウィジェットをタップしてもColoredTextウィジェットは再構築されず、❸で出力しているログはアプリ起動時の一度しか出力されません。

また、ColoredTextウィジェットはconstantコンストラクタを実装しているため、状態の変化しないイミュータブルなクラスとして実装され副作用を持ちません。プログラムの堅牢性が高まります。

一方、以下のような実装方法も考えられますが、お勧めしません。ウィジェットをクラスではなく、ヘルパメソッドで実装する方法です。

```dart
class _MyHomeScreenState extends State<HomeScreen> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _colordText( // ❶
              text: 'You have pushed the button\nthis many times:',
              color: Colors.blueGrey,
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _colordText({required String text, required Color color}) { // ❷
    return ColoredBox(
      color: color,
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
```

この例では先ほどのColorTextウィジェットを関数として実装しました（❶、❷）。同じUIは実現可能ですが、ウィジェットの再構築を抑える効果はありません。

### 状態を末端のウィジェットに移す

状態を末端のウィジェットに移すことで、ウィジェットが再構築される範囲を小さくすることができます。タップすると数字がカウントアップするボタンを例に考えてみましょう。

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: ElevatedButton( // ❶
          child: Text('count = $_counter'),
          onPressed: () => _increment(),
        ),
      ),
    );
  }
}
```

画面中央のボタンがカウント数を表示しており、タップするとカウントアップします。このサンプルでは、❶のボタンをタップするたびにScaffoldやAppBarウィジェットも含めて再構築されます。実際に表示更新を行うのはTextウィジェットのみです。

そこで、このアプリの状態である_counterを持つウィジェットを末端に移動させてみましょう。

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: const Center(
        child: CountButton(),
      ),
    );
  }
}

class CountButton extends StatefulWidget {
  const CountButton({super.key});

  @override
  State createState() => _CountButtonState();
}

class _CountButtonState extends State<CountButton> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text('count = $_counter'),
      onPressed: () => _increment(),
    );
  }
}
```

タップするとカウントアップするボタンをCountButtonウィジェットとして切り出しました。アプリの状態である_counterはCountButtonウィジェットが持つようになりました。ボタンをタップして再構築されるのはCountButtonウィジェットのみになり不必要な再構築が行われなくなりました。

また、関心事を分けることにもつながり、HomeScreen画面のコードからカウントアップのロジックを分離することができました。保守性が高まり、CountButtonウィジェットは再利用性も確保されています。

### Riverpodの状態監視は末端のウィジェットで行う

Riverpodの状態監視を末端のウィジェットで行うことで、ウィジェットの再構築範囲を小さくすることができます。StatefulWidgetの状態を末端に移動することと同じ考え方です。FlutterのテンプレートプロジェクトをRiverpodで書き換えた例を見てみましょう。

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main.g.dart';

@riverpod
class Counter extends _$Counter { // ❶
  @override
  int build() => 0;

  void increment() => state++;
}

void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        home: HomeScreen(),
      ),
    ),
  );
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '${ref.watch(counterProvider)}', // ❷
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(counterProvider.notifier).increment(); // ❸
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

カウンタをRiverpodのクラスベースのProviderで実装しました（❶）。カウンタの状態は❷の箇所で監視、FloatingActionButtonウィジェットのonPressedコールバックでは❸のようにカウンタをインクリメントしています。

この例では、カウンタをインクリメントすると、HomeScreen画面のbuildメソッドが呼ばれウィジェットが再構築されます。実際に更新が必要なのはカウンタの状態を表示するTextウィジェットのみですので、別のウィジェットクラスに切り出してしまいましょう。

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main.g.dart';

@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
}

void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        home: HomeScreen(),
      ),
    ),
  );
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'You have pushed the button this many times:',
            ),
            CounterText(), // ❶
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(counterProvider.notifier).increment();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```