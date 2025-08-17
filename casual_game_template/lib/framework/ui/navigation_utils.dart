/// Navigator操作の最適化ユーティリティ
/// 
/// BuildContextの効率的な使用パターンとNavigator.ofの最適化を提供
library navigation_utils;

import 'package:flutter/material.dart';

/// Navigator操作の最適化クラス
class NavigationUtils {
  /// buildメソッド内でのNavigator.of呼び出しを最適化
  /// 
  /// buildメソッド内でNavigator.ofを呼び出すのは計算コストが高いため、
  /// 実際の操作時まで遅延させる最適化パターン
  static VoidCallback createNavigatorCallback(
    BuildContext context,
    NavigatorAction action,
  ) {
    return () {
      final navigator = Navigator.of(context);
      action(navigator);
    };
  }

  /// 画面遷移の最適化されたpush操作
  static VoidCallback pushRoute(
    BuildContext context,
    Widget Function() routeBuilder,
  ) {
    return createNavigatorCallback(context, (navigator) {
      navigator.push(
        MaterialPageRoute(builder: (_) => routeBuilder()),
      );
    });
  }

  /// 画面を閉じる最適化されたpop操作
  static VoidCallback popRoute(BuildContext context, [dynamic result]) {
    return createNavigatorCallback(context, (navigator) {
      navigator.pop(result);
    });
  }

  /// 画面置換の最適化されたpushReplacement操作
  static VoidCallback pushReplacementRoute(
    BuildContext context,
    Widget Function() routeBuilder,
  ) {
    return createNavigatorCallback(context, (navigator) {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => routeBuilder()),
      );
    });
  }
}

/// Navigator操作のアクション型定義
typedef NavigatorAction = void Function(NavigatorState navigator);

/// 最適化されたNavigatorコールバックのMixin
/// 
/// StatefulWidgetで使用してNavigator操作を最適化
mixin NavigatorOptimization<T extends StatefulWidget> on State<T> {
  /// キャッシュされたNavigatorState
  NavigatorState? _cachedNavigator;

  /// 最適化されたNavigatorStateの取得
  NavigatorState get navigator {
    _cachedNavigator ??= Navigator.of(context);
    return _cachedNavigator!;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 依存関係が変更された場合はキャッシュをクリア
    _cachedNavigator = null;
  }

  /// 最適化されたpush操作
  Future<T?> pushOptimized<T extends Object?>(Route<T> route) {
    return navigator.push(route);
  }

  /// 最適化されたpop操作
  void popOptimized<T extends Object?>([T? result]) {
    navigator.pop(result);
  }
}

/// constコンストラクタ使用推奨のウィジェット基底クラス
abstract class OptimizedWidget extends StatelessWidget {
  const OptimizedWidget({super.key});
}

/// constコンストラクタ使用推奨のStatefulWidget基底クラス
abstract class OptimizedStatefulWidget extends StatefulWidget {
  const OptimizedStatefulWidget({super.key});
}