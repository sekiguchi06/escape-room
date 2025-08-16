# 第9章 フレームワークによるパフォーマンスの最適化
*BuildContext、Key*

ウィジェットのbuildメソッドの引数に渡されるBuildContextや、ウィジェットのコンストラクタに渡されるKeyについて、ここまで詳しい解説をしてきませんでした。本章ではいよいよBuildContextとKeyの役割を明らかにし、それがアプリのパフォーマンス最適化につながっていることを解説します。

## 9.1 BuildContextは何者なのか ── Element

ウィジェットのbuildメソッドの引数には必ずBuildContextが渡されます。このBuildContextは何者なのでしょうか。先に結論を言うと、**Element（エレメント）** というクラスです。

### 祖先の情報にアクセスできるBuildContext

通常のアプリ開発で使う場面は少ないですが、BuildContextには興味深いAPIが用意されています。

```dart
T? findAncestorWidgetOfExactType<T extends Widget>();
```

ウィジェットの親をたどり、ツリーの中で最も近い位置にあるT型のウィジェットを探して返却するメソッドです。計算量はO(n)¹です。実際に動作を確認してみましょう。

**./lib/main.dart**
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
    final materialApp = context.findAncestorWidgetOfExactType<MaterialApp>(); // ❶
    print(materialApp);
    // => MaterialApp
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: const Center(
        child: Text('Home Screen'),
      ),
    );
  }
}
```

❶でfindAncestorWidgetOfExactTypeメソッドを呼び出し、親のMaterialAppウィジェットが取得できることが確認できます。

ウィジェットは親や子にアクセスするAPIを持ちませんし、内部でもその情報は持っていません。しかし、BuildContext（Element）は親子関係をツリー構造で管理しているので、このようなAPIが実現できるのです。

ちなみに、似たAPIとして、直近の祖先のStateを取得するAPIがあります。

```dart
T? findAncestorStateOfType<T extends State<StatefulWidget>>()
```

BuildContextを引数にNavigatorStateを取得するNavigator.ofメソッドは、このAPIを使って実現されています。

### Elementがツリーを構成していく工程

Flutterフレームワークの内部でElementがツリーを構成していく様子を図で表します。次のようにMaterialAppウィジェット、その子にHomeScreenというウィジェットがあるような状況を想定します。

**./lib/main.dart**
```dart
void main() {
  runApp(
    MaterialApp(
      home: HomeScreen()
    ),
  );
}
```

main関数ではrunApp関数が呼び出され、引数にはMaterialAppウィジェットが渡されます。このとき、runApp関数の内部では、ルートになるElementとウィジェットが生成されます（図9.1の❶）。ルートのElementはMaterialAppのElement生成を命令します（図9.1の❷、❸）。

**図9.1 MaterialAppのElementが生成される様子**

```
Frameworkが作る        ❶
ルートのElement  ────────────→ createElement ❷
                              ↓        ❸
                      MaterialAppの ← MaterialApp
                        Element
```

MaterialAppのElementがツリーの一部として構成されます（図9.2の❶）。

**図9.2 MaterialAppのElementがツリーの一部として構成される様子**

```
Frameworkが作る
ルートのElement
   ⋮
   ❶
MaterialAppの        MaterialApp
  Element
```

MaterialAppのElementがMaterialAppのbuildメソッドを呼び出します（図9.3の❶）。

**図9.3 MaterialAppのbuildメソッドが呼ばれる様子**

```
Frameworkが作る
ルートのElement
   ⋮

MaterialAppの   ❁ build ────→ MaterialApp
  Element
```

MaterialAppのbuildメソッドで、HomeScreenウィジェットが返却されます（図9.4の❶）。

**図9.4 HomeScreenが生成される様子**

```
Frameworkが作る
ルートのElement
   ⋮

MaterialAppの  build ────→ MaterialApp
  Element                     ❶
                              ↓
                         HomeScreen
```

MaterialAppのElementがHomeScreenのElement生成を命令します（図9.5の❶）。

**図9.5 HomeScreenのElementが生成される様子**

```
Frameworkが作る
ルートのElement
   ⋮

MaterialAppの              MaterialApp
  Element     ────────────────→
                createElement
HomeScreenの  ←────────────── HomeScreen
  Element              ❶
```

HomeScreenのElementがツリーの一部として構成されます（図9.6の❶）。

**図9.6 HomeScreenのElementがツリーの一部として構成される様子**

```
Frameworkが作る
ルートのElement
   ⋮
MaterialAppの        MaterialApp
  Element
   ⋮
   ❶
HomeScreenの         HomeScreen
  Element
```

以上を末端のウィジェットまで繰り返し、Elementのツリーを構成していきます。

### StatefulWidgetの状態を保持する役割

次は別の視点からBuildContextを見てみましょう。StatefulWidgetのStateは、誰が管理しているのでしょうか？ライフサイクルはStatefulWidgetと同じでしょうか？

StatefulWidgetを入れ子構造にしたサンプルを用意しました。

[以下、第9章の内容が続く...]

---

¹ ウィジェットの階層が深くなると、計算時間が線形に増えていくことを意味します。

---