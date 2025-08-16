# 第10章 高速で保守性の高いアプリを開発するためのコツ

第9章ではフレームワークが内部で行っているパフォーマンスの最適化を解説しました。本章も同じくパフォーマンスをテーマに、コードを書く際に考慮すべきポイントを紹介します。

## 10.1 パフォーマンスと保守性、どちらを優先すべきか

一般に、高速な（パフォーマンスを最優先した）実装と、保守性を意識した実装は、相反する場合があります。Flutterのパフォーマンスを最大限に引き出す実装は、時にソースコードの可読性や保守性を低下させます。

では、パフォーマンスと保守性はどのようなバランスでアプリを開発すればよいのでしょうか。基本的には保守性を第一に実装を進めるのが良いと筆者は考えます。前章で解説したとおり、Flutterにはパフォーマンスを意識したElementの再利用など、最適化のしくみがあります。それらのしくみにより、パフォーマンスに深刻な問題が起こることは多くないからです。

上記の前提はありますが、パフォーマンスを意識した実装と、保守性を意識した実装が必ずしも両立しないわけではありません。本章では、パフォーマンスに寄与しつつも保守性が高まるような実装の考え方を紹介します。意識すべきポイントとして、常に頭の片隅に置いておいてください。

### 高速でないアプリとは

前項では「高速な」という言葉を使いましたが、本章で示す「高速な」アプリとは表示がカクカクしないアプリ、画面がフリーズしないアプリのことを指します。

Flutterは60fps（毎秒60フレーム）または対応デバイスでは120fpsで描画を行うことを目標にしています。毎秒60フレームの場合ですと1フレームあたり約16ミリ秒、この間に次のフレームの準備が整わなければ、表示がカクカクしたり、画面がフリーズしたように見えたりします。

### 高速だが保守性が低い実装

パフォーマンスを優先した結果、保守性が下がる実装の一例を紹介しましょう。

---

² ウィジェットの階層が深くなっても、計算時間が一定であることを意味します。# 高速で保守性の高い実装

## 10.2 高速で保守性の高い実装（続き）

ょう。「ウィジェットのbuildメソッドが生成するウィジェット階層は、少ないほど効率が良い」とされ、Flutterの公式リファレンスに記載されています。

- StatelessWidget class - Performance considerations¹
- StatefulWidget class - Performance considerations²

これを素直に受け取り、すべてのウィジェットのbuildメソッドで1つのウィジェットを生成するように実装すると、細かなウィジェットクラスが増えてしまい、保守性が低下します。

パフォーマンスにも寄与しながら、保守性の向上にもつながる実装を紹介します。なお、本章では解説に重きを置くため、関連したコードの断片を掲載している場合があります。省略されている部分がある点に留意してください。

### buildメソッドで高コストな計算をしない

buildメソッドは表示更新が必要なたびに繰り返し呼び出されます。この中でコストのかかる処理は避けるべきです。たとえば、巨大なリストから要素を検索するような処理です。画面遷移のためにNavigatorStateクラスを取得するNavigator.ofメソッドはウィジェットの階層によっては計算量の大きな処理になり得ます。

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final navigator = Navigator.of(context); // ❶
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: (() {
            final navigator = Navigator.of(context); // ❷
            navigator.push(
              MaterialPageRoute(builder: (context) => const DetailScreen()));
          }),
          child: const Text('Go to detail'),
        ),
      ),
    );
  }
}
```

buildメソッドの中で❶のようにNavigatorStateを取得すると、buildメソッドが実行されるたびにNavigatorStateを検索することになり無駄が多いです。この場合は❷のようにボタンがタップされたときにのみNavigatorStateを取得するのが好ましい実装と言えます。

また、次の例ではListViewウィジェットでデータをリスト表示していますが、表示するリストの要素をbuildメソッド内でフィルタリングしています。

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // buildメソッド内で要素をフィルタリング
    final filteredItems = items.where((item) => /* itemのフィルタ条件 */).toList();
    return Scaffold(
      body: ListView.builder(
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(filteredItems[index]),
          );
        },
      ),
    );
  }
}
```

これでは、buildメソッドが実行されるたびにリストのフィルタリングが行われてしまいます。あらかじめフィルタリングしたリストをウィジェットに渡すことで、buildメソッドの実行コストを下げられるでしょう。buildメソッドにロジックがなくなり可読性や再利用性も向上します。

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.filteredItems});

  final filteredItems; // フィルタリング済みのリストを受け取る

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(filteredItems[index]),
          );
        },
      ),
    );
  }
}
```

### buildメソッドで大きなウィジェットツリーを構築しない

buildメソッドで構築するウィジェットツリーを小さくすることを意識しましょう。StatefulWidgetのsetStateメソッドの呼び出し、Providerの状態更新など、buildメソッドが繰り返し呼び出されるケースがあります。このときに再構築するウィジェットを少なくすることで、Elementの再利用判定などのコストを減らすことができます。

ウィジェットツリーを小さくといっても、常に1つのウィジェットだけを構築するところまで小さくすると逆に保守性に難が出てしまいます。たとえば、ウィジェットの選択を見なおすことで、ウィジェットツリーを小さくすることができます。

### ウィジェットツリーの階層が浅くなるようウィジェットの選択を見なおす

ウィジェットの選択を見なおすことで階層を浅くすることができます。ウィジェットを右下に配置したい場合、RowウィジェットとColumnウィジェットを組み合わせて構築することができます。

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      /* ◆ Row
         子ウィジェットを水平方向に並べる */
      body: Row( // Row
        mainAxisAlignment: MainAxisAlignment.end, // 右寄せ
        children: [
          Column( // Column
            mainAxisAlignment: MainAxisAlignment.end, // 下寄せ
            children: [
              ElevatedButton(
                onPressed: (() {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const DetailScreen()));
                }),
                child: const Text('Go to detail'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

同様のレイアウトをAlignウィジェット1つで実現できます。

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      /* ◆ Align
         alignmentパラメータに応じて子ウィジェットを配置するWidget */
      body: Align( // Align
        alignment: Alignment.bottomRight, // 右下寄せ
        child: ElevatedButton(
          onPressed: (() {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const DetailScreen()));
          }),
          child: const Text('Go to detail'),
        ),
      ),
    );
  }
}
```

ウィジェットの階層が減り、可読性向上にもつながります。

### const修飾子を付与する

const修飾子を付与することで、ウィジェットがコンパイル時定数として扱われ、常に同じインスタンスが使われるようになります。そのため、buildメソッドが実行されてもconst修飾子が付与されているウィジェットは再構築されません。

以下の例を見てみましょう。

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        A(
          child: Text('A'),
        ),
        B(
          child: Text('B'),
        ),
        const C(
          child: Text('C'),
        ),
      ],
    );
  }
}
```

Columnウィジェットの子ウィジェットに注目してください。const修飾子が付与されていないウィジェットとしてAとB、const修飾子が付与されているウィジェットとしてCがあります。

このbuildメソッドが実行されるたびにAとB、さらにその子のTextウィジェットも再構築されます。一方、Cとその子であるTextウィジェットは再構築されません。Dartの最適化により、const修飾子が付与されているCウィジェットは常に同じインスタンスが使われるためです。

では、このCウィジェット配下は表示更新をすることができないのでしょうか。そんなことはありません。ウィジェットがStatefulWidgetであれば状態を更新することができますし、InheritedWidgetの更新を購読することで表示更新を行うこともできます（第9章参照）。

const修飾子はそのウィジェット以下を更新不可にするのではなく、先祖の再構築の影響を受けない効果があると覚えておきましょう。

### const修飾子が使えるようウィジェットの選択を見なおす

Flutterが提供するウィジェットの中にはconstantコンストラクタを持たないものがあります。必要に応じて、constantコンストラクタを持つウィジェットに置き換えることを検討しましょう。

たとえば、背景色を指定可能なウィジェットとしてContainerウィジェットとColoredBoxウィジェットがあります。

```dart
ListView(
  children: [
    Container( // ❶
      color: Colors.green,
      child: const Text('Container'),
    ), 
    const ColoredBox( // ❷
      color: Colors.green,
      child: Text('ColoredBox'),
    )
  ],
)
```

Containerウィジェットを使い背景色を指定した例（❶）と、ColoredBoxウィジェットを使い背景色を指定した例（❷）です。どちらも結果は同じですが、Containerウィジェットはconstantコンストラクタを持たないため、この場合はColoredBoxウィジェットを使用するのがよいでしょう。

### 独自のウィジェットクラスにconstantコンストラクタを実装する

独自のウィジェットクラスを実装する場合は、constantコンストラクタを実装しましょう。これには2つの効果があります。1つ目は、const修飾子を付与することで祖先の再構築の影響を受けなくなることです。2つ目は、constantコンストラクタを実装するためにウィジェットクラスをイミュータブルにする必要があり、ウィジェットが状態を持たないようになることです。ウィジェットクラスの堅牢性が高まります。

Flutterのテンプレートプロジェクトをベースにしたサンプルを用意しました。

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: HomeScreen(),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
            ColoredBox( // ❶
              color: Colors.blueGrey,
              child: Text(
                'You have pushed the button\nthis many times:',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
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
```

FloadingActionButtonウィジェットをタップするとカウントアップする、Flutterのテンプレートプロジェクトをベースにしました。変更点は、❶で囲まれたColoredBoxウィジェットを追加したことです。文字列You have pushed the button\nthis many times:の表示部分に背景色をつけ、少しリッチな見た目にしてみました。

このサンプルは、FloadingActionButtonウィジェットをタップするとHomeScreen画面全体が再構築されます。続いて、ColoredBoxウィジェット以下を別のウィジェットクラスに分割してみましょう。

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: HomeScreen(),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;
```

---

¹ https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html#performance-considerations
² https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html#performance-considerations# const修飾子・状態管理・Riverpod最適化

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
```# Riverpod状態監視・パフォーマンス測定・第11章開始

## 10.2 高速で保守性の高い実装（続き）

```dart
class CounterText extends ConsumerWidget {
  const CounterText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    return Text(
      '$counter',
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}
```

カウンタの状態を表示するウィジェットをCounterTextウィジェットとして切り出しました（❷）。HomeScreen画面のbuildメソッドではカウンタの監視は行われなくなりました（❶）。

このサンプルを実行すると、カウンタをインクリメントするとHomeScreen画面のbuildメソッドは呼ばれず、CounterTextウィジェットのbuildメソッドのみが呼ばれることが確認できます。ウィジェットの再構築範囲が小さくなり、カウンタの値を表示するウィジェットとしてCounterTextウィジェットは再利用性のあるクラスとなりました。

### アプリのパフォーマンスを計測する

高速なアプリに仕上がっているかどうかを確認する際は以下の点に注意しましょう。

- Profileモードでアプリを実行すること
- シミュレータなどは使用せず、実機でアプリを実行すること

DebugビルドしたFlutterアプリはアサーションの処理が含まれています。また、ビルド方式もまったく異なるためReleaseビルドしたアプリよりも遅い可能性が高いです。ProfileモードはほぼReleaseビルドと同等のパフォーマンスを発揮し、さらに最低限のデバッグ情報を含んでいるため、パフォーマンス計測に適しています。

シミュレータやエミュレータもパフォーマンスの特性が異なるため計測には向きません。サポート対象とする端末の中でも、性能の低いものを選択し、実機計測するのが良いとされています。

---

## 10.3 まとめ

パフォーマンスを意識した実装は、ときとして保守性を下げることにつながります。本章ではアプリのパフォーマンスとプログラムの保守性、どちらも両立させるポイントに絞って紹介しました。Flutterアプリを開発する際は、本章の内容をいつも頭の片隅に置いて設計を行ってみてください。

---

