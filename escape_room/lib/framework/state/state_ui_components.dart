import 'package:flutter/widgets.dart';
import 'game_state_base.dart';
import 'game_state_provider.dart';

/// 状態ベースのWidget構築
class StateBuilder<T extends GameState> extends StatelessWidget {
  final GameStateProvider<T> provider;
  final Widget Function(BuildContext context, T state) builder;

  const StateBuilder({
    super.key,
    required this.provider,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: provider,
      builder: (context, child) {
        return builder(context, provider.currentState);
      },
    );
  }
}

/// 状態遷移アニメーション
class StateTransitionAnimator<T extends GameState> {
  final Duration animationDuration;
  final Map<Type, Widget Function()> stateWidgets;

  StateTransitionAnimator({
    this.animationDuration = const Duration(milliseconds: 300),
    required this.stateWidgets,
  });

  Widget buildTransition(T fromState, T toState, Animation<double> animation) {
    final fromWidget = stateWidgets[fromState.runtimeType]?.call();
    final toWidget = stateWidgets[toState.runtimeType]?.call();

    if (fromWidget == null || toWidget == null) {
      return toWidget ?? const SizedBox.shrink();
    }

    return Stack(
      children: [
        FadeTransition(
          opacity: Tween<double>(begin: 1.0, end: 0.0).animate(animation),
          child: fromWidget,
        ),
        FadeTransition(opacity: animation, child: toWidget),
      ],
    );
  }
}