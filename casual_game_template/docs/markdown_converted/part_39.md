# 高速で保守性の高い実装

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
² https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html#performance-considerations