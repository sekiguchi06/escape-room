/// constコンストラクタ最適化ユーティリティ
/// 
/// ウィジェットのconstコンストラクタ使用によるパフォーマンス最適化
library const_optimization;

import 'package:flutter/material.dart';

/// const最適化のためのウィジェット基底クラス
abstract class ConstOptimizedWidget extends StatelessWidget {
  const ConstOptimizedWidget({super.key});
}

/// const最適化のためのStatefulWidget基底クラス
abstract class ConstOptimizedStatefulWidget extends StatefulWidget {
  const ConstOptimizedStatefulWidget({super.key});
}

/// よく使用されるconst最適化済みウィジェット
class ConstOptimizedWidgets {
  /// 最適化されたSizedBox
  static const sizedBoxZero = SizedBox.shrink();
  static const sizedBox8 = SizedBox(width: 8, height: 8);
  static const sizedBox16 = SizedBox(width: 16, height: 16);
  static const sizedBox24 = SizedBox(width: 24, height: 24);
  
  /// 最適化されたPadding
  static const padding8 = EdgeInsets.all(8.0);
  static const padding16 = EdgeInsets.all(16.0);
  static const padding24 = EdgeInsets.all(24.0);
  
  /// 最適化されたDivider
  static const divider = Divider();
  static const verticalDivider = VerticalDivider();
  
  /// 最適化されたIcon
  static const iconHome = Icon(Icons.home);
  static const iconSettings = Icon(Icons.settings);
  static const iconClose = Icon(Icons.close);
  static const iconArrowBack = Icon(Icons.arrow_back);
  static const iconArrowForward = Icon(Icons.arrow_forward);
  
  /// 最適化されたText
  static const textEmpty = Text('');
  static const textLoading = Text('Loading...');
  static const textError = Text('Error');
}

/// const最適化チェッカー
class ConstOptimizationChecker {
  /// ウィジェットがconst対応可能かチェック
  static bool canBeConst(Widget widget) {
    // 基本的なconst対応チェック
    if (widget is StatelessWidget) {
      return true; // StatelessWidgetは基本的にconst可能
    }
    if (widget is StatefulWidget) {
      return false; // StatefulWidgetはconst不可
    }
    return true;
  }
  
  /// const使用推奨のウィジェットかチェック
  static bool shouldUseConst(Widget widget) {
    return widget is SizedBox ||
           widget is Padding ||
           widget is Divider ||
           widget is Icon ||
           (widget is Text && widget.data != null);
  }
}

/// const最適化のためのBuilder
class ConstOptimizedBuilder {
  /// const対応のContainer
  static Widget constContainer({
    Key? key,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    Widget? child,
  }) {
    return Container(
      key: key,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      color: color,
      child: child,
    );
  }
  
  /// const対応のColumn
  static Widget constColumn({
    Key? key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    required List<Widget> children,
  }) {
    return Column(
      key: key,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
  
  /// const対応のRow
  static Widget constRow({
    Key? key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    required List<Widget> children,
  }) {
    return Row(
      key: key,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}

/// const最適化のためのMixin
mixin ConstOptimizationMixin {
  /// constウィジェットを生成
  Widget buildConstWidget() {
    return const SizedBox.shrink();
  }
  
  /// constを推奨するウィジェットの生成
  Widget buildOptimizedSizedBox({double? width, double? height}) {
    if (width == null && height == null) {
      return ConstOptimizedWidgets.sizedBoxZero;
    }
    if (width == 8 && height == 8) {
      return ConstOptimizedWidgets.sizedBox8;
    }
    if (width == 16 && height == 16) {
      return ConstOptimizedWidgets.sizedBox16;
    }
    if (width == 24 && height == 24) {
      return ConstOptimizedWidgets.sizedBox24;
    }
    return SizedBox(width: width, height: height);
  }
  
  /// constを推奨するPaddingの生成
  Widget buildOptimizedPadding(EdgeInsetsGeometry padding, Widget child) {
    if (padding == const EdgeInsets.all(8.0)) {
      return Padding(padding: ConstOptimizedWidgets.padding8, child: child);
    }
    if (padding == const EdgeInsets.all(16.0)) {
      return Padding(padding: ConstOptimizedWidgets.padding16, child: child);
    }
    if (padding == const EdgeInsets.all(24.0)) {
      return Padding(padding: ConstOptimizedWidgets.padding24, child: child);
    }
    return Padding(padding: padding, child: child);
  }
}

/// 最適化されたスペーサーウィジェット
class OptimizedSpacer {
  /// 水平方向のスペース
  static const Widget horizontal4 = SizedBox(width: 4);
  static const Widget horizontal8 = SizedBox(width: 8);
  static const Widget horizontal12 = SizedBox(width: 12);
  static const Widget horizontal16 = SizedBox(width: 16);
  static const Widget horizontal20 = SizedBox(width: 20);
  static const Widget horizontal24 = SizedBox(width: 24);
  
  /// 垂直方向のスペース
  static const Widget vertical4 = SizedBox(height: 4);
  static const Widget vertical8 = SizedBox(height: 8);
  static const Widget vertical12 = SizedBox(height: 12);
  static const Widget vertical16 = SizedBox(height: 16);
  static const Widget vertical20 = SizedBox(height: 20);
  static const Widget vertical24 = SizedBox(height: 24);
}

/// ゲーム特有のconst最適化済みウィジェット
class GameConstWidgets {
  /// ゲーム関連のアイコン
  static const iconHome = Icon(Icons.home, color: Colors.white);
  static const iconRestart = Icon(Icons.restart_alt, color: Colors.white);
  static const iconPause = Icon(Icons.pause, color: Colors.white);
  static const iconPlay = Icon(Icons.play_arrow, color: Colors.white);
  static const iconVolume = Icon(Icons.volume_up, color: Colors.white);
  static const iconVolumeOff = Icon(Icons.volume_off, color: Colors.white);
  
  /// スタイル済みテキスト
  static const scoreLabel = Text(
    'Score',
    style: TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );
  
  static const timeLabel = Text(
    'Time',
    style: TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );
  
  /// 黒背景コンテナ
  static const blackBackground = ColoredBox(color: Colors.black);
  
  /// 透明コンテナ
  static const transparentBackground = ColoredBox(color: Colors.transparent);
}