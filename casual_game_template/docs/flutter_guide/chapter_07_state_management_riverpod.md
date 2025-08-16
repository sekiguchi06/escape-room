# 第7章 状態管理とRiverpod

本章ではFlutterアプリにおける状態管理について解説し、状態管理パッケージとして有力な選択肢の一つであるRiverpodの使い方を学びます。

goメソッドに戻してみましょう。

```dart
class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FirstScreen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('FirstからFirstへ'),
              onPressed: () {
                GoRouter.of(context).push('/');
              },
            ),
            ElevatedButton(
              child: const Text('FirstからSecondへ'),
              onPressed: () {
                GoRouter.of(context).push('/second');
              },
            ),
            ElevatedButton(
              child: const Text('FirstからThirdへ'),
              onPressed: () {
                // GoRouter.of(context).push('/second/third');
                GoRouter.of(context).go('/second/third'); // ❶
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

FirstScreen画面からThirdScreen画面への遷移処理をgoメソッドに戻しました（❶）。これで、ThirdScreen画面へ遷移し、「戻る」ボタンをタップするとSecondScreen画面が表示されるようになりました。しかし、図5.12のように遷移すると一部のFirstScreen画面がスタックから消えてしまいます。

**図5.12 goメソッドでのスタックの変化**

```
First Screen → push → First Screen → push → First Screen → go → Third Screen
First Screen         First Screen         First Screen         Second Screen
                     First Screen         First Screen         First Screen
```

goメソッドはGoRouteの入れ子構造をそのまま画面スタックに再現するのでした。そのため、pushメソッドで複数のFirstScreen画面をスタックに積んだとしても、その後goメソッドで遷移するとスタックが書き換えられ、FirstScreen画面は1つしかスタックに残らないのです。

画面スタックをどのように変化させたいのかを意識して、適切なメソッドを選択しましょう。

---

## 5.3 まとめ

Flutterフレームワークが提供する「テーマ」と「画面遷移」に関する機能を紹介しました。

MaterialAppウィジェットやThemeDataクラスを使うことで、マテリアルデザインにのっとったアプリを簡単に作ることができます。ThemeDataクラスがテーマを自動計算してくれるので、テーマのカスタマイズやダークモード対応も容易です。

アプリ独自のテーマ、世界観を演出するなら、Theme Extensionを使うのがよいでしょう。

アプリの画面遷移の実装方法を学ぶために、Navigator 1.0とNavigator 2.0の違いを確認しました。シンプルな画面遷移であればNavigator 1.0のpushメソッド、popメソッドで対応できるケースも十分あるでしょう。複雑な画面遷移を実装する場合はNavigator 2.0が候補に挙がります。本章では、例としてgo_routerパッケージを使った画面遷移の実装を紹介しました。

---

