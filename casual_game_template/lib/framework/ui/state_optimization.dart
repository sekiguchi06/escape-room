/// setState最適化ユーティリティ
/// 
/// StatefulWidgetでの局所的なsetState呼び出しパターンと状態管理の最適化
library state_optimization;

import 'package:flutter/material.dart';

/// setState最適化のためのMixin
mixin StateOptimization<T extends StatefulWidget> on State<T> {
  /// 安全なsetState（mountedチェック付き）
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  /// 条件付きsetState
  void conditionalSetState(bool condition, VoidCallback fn) {
    if (condition && mounted) {
      setState(fn);
    }
  }

  /// 遅延setState（nextFrame）
  void delayedSetState(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      safeSetState(fn);
    });
  }

  /// 非同期処理後のsetState
  Future<void> asyncSetState(Future<void> Function() asyncOperation, [VoidCallback? onComplete]) async {
    try {
      await asyncOperation();
      if (onComplete != null) {
        safeSetState(onComplete);
      }
    } catch (e) {
      debugPrint('AsyncSetState error: $e');
    }
  }
}

/// 局所的な状態管理のためのStatefulBuilderラッパー
class LocalStateBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, StateSetter setState) builder;
  final VoidCallback? onInit;

  const LocalStateBuilder({
    super.key,
    required this.builder,
    this.onInit,
  });

  @override
  State<LocalStateBuilder> createState() => _LocalStateBuilderState();
}

class _LocalStateBuilderState extends State<LocalStateBuilder> {
  @override
  void initState() {
    super.initState();
    widget.onInit?.call();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, setState);
  }
}

/// プレス状態管理の最適化されたウィジェット
class OptimizedPressButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration animationDuration;

  const OptimizedPressButton({
    super.key,
    required this.child,
    this.onPressed,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  @override
  State<OptimizedPressButton> createState() => _OptimizedPressButtonState();
}

class _OptimizedPressButtonState extends State<OptimizedPressButton>
    with StateOptimization, TickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _handleTapDown() {
    safeSetState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp() {
    safeSetState(() => _isPressed = false);
    _animationController.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    safeSetState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _handleTapDown(),
            onTapUp: (_) => _handleTapUp(),
            onTapCancel: _handleTapCancel,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// インベントリ状態管理の最適化
class OptimizedInventoryState extends StatefulWidget {
  final List<String?> initialItems;
  final Widget Function(BuildContext context, List<String?> items, Function(int, String) addItem, Function(int) selectSlot) builder;

  const OptimizedInventoryState({
    super.key,
    required this.initialItems,
    required this.builder,
  });

  @override
  State<OptimizedInventoryState> createState() => _OptimizedInventoryStateState();
}

class _OptimizedInventoryStateState extends State<OptimizedInventoryState> with StateOptimization {
  late List<String?> _inventory;
  int _selectedSlotIndex = 0;

  @override
  void initState() {
    super.initState();
    _inventory = List.from(widget.initialItems);
  }

  void _addItem(int index, String itemId) {
    safeSetState(() {
      if (index >= 0 && index < _inventory.length) {
        _inventory[index] = itemId;
      }
    });
  }

  void _selectSlot(int index) {
    conditionalSetState(
      index != _selectedSlotIndex && index >= 0 && index < _inventory.length,
      () => _selectedSlotIndex = index,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _inventory, _addItem, _selectSlot);
  }
}

/// 設定変更の最適化されたハンドラー
class OptimizedConfigurationWidget<T> extends StatefulWidget {
  final T initialConfig;
  final Widget Function(BuildContext context, T config, Function(T) updateConfig) builder;
  final void Function(T oldConfig, T newConfig)? onConfigChanged;

  const OptimizedConfigurationWidget({
    super.key,
    required this.initialConfig,
    required this.builder,
    this.onConfigChanged,
  });

  @override
  State<OptimizedConfigurationWidget<T>> createState() => _OptimizedConfigurationWidgetState<T>();
}

class _OptimizedConfigurationWidgetState<T> extends State<OptimizedConfigurationWidget<T>> with StateOptimization {
  late T _currentConfig;

  @override
  void initState() {
    super.initState();
    _currentConfig = widget.initialConfig;
  }

  @override
  void didUpdateWidget(OptimizedConfigurationWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialConfig != widget.initialConfig) {
      safeSetState(() {
        final oldConfig = _currentConfig;
        _currentConfig = widget.initialConfig;
        widget.onConfigChanged?.call(oldConfig, _currentConfig);
      });
    }
  }

  void _updateConfig(T newConfig) {
    conditionalSetState(
      newConfig != _currentConfig,
      () {
        final oldConfig = _currentConfig;
        _currentConfig = newConfig;
        widget.onConfigChanged?.call(oldConfig, _currentConfig);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentConfig, _updateConfig);
  }
}