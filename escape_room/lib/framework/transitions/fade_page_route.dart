import 'package:flutter/material.dart';

/// カスタムフェードページトランジション
/// ゲームスタート・リトライ時の画面遷移用
class FadePageRoute<T> extends PageRoute<T> {
  final Widget child;
  final Duration fadeDuration;
  final Curve curve;

  FadePageRoute({
    required this.child,
    this.fadeDuration = const Duration(milliseconds: 800), // 部屋移動より長め
    this.curve = Curves.easeInOut,
    super.settings,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // フェードイン・アウト効果
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: curve),
      child: child,
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => fadeDuration;

  @override
  Duration get reverseTransitionDuration => fadeDuration;
}

/// ゲーム専用の長いフェードトランジション
class GameFadePageRoute<T> extends FadePageRoute<T> {
  GameFadePageRoute({required super.child, super.settings})
    : super(
        fadeDuration: const Duration(milliseconds: 800), // 部屋移動(300ms)より長め
        curve: Curves.easeInOut,
      );
}

/// 便利な拡張メソッド
extension FadeNavigationExtension on NavigatorState {
  /// フェードイン・アウトでページを遷移
  Future<T?> pushFade<T extends Object?>(Widget page) {
    return push<T>(GameFadePageRoute<T>(child: page));
  }

  /// フェードイン・アウトでページを置き換え（通常のpushReplacement）
  Future<T?> pushReplacementFade<T extends Object?, TO extends Object?>(
    Widget page, {
    TO? result,
  }) {
    return pushReplacement<T, TO>(
      GameFadePageRoute<T>(child: page),
      result: result,
    );
  }

  /// ゲーム専用リスタート遷移（フェードアウト→フェードイン）
  Future<T?> restartGameWithFade<T extends Object?>(Widget page) async {
    // まず現在のページをフェードアウト
    await push<void>(
      FadePageRoute<void>(
        child: Container(color: Colors.black),
        fadeDuration: const Duration(milliseconds: 400),
      ),
    );

    // 瞬時に戻る
    pop();

    // そして新しいページをフェードインで表示
    return pushReplacement<T, void>(GameFadePageRoute<T>(child: page));
  }
}
