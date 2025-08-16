import 'package:flutter/material.dart';
import 'smooth_game_background.dart';
import 'hotspot_display.dart';
import 'game_background.dart';

/// 背景とホットスポットを統合したルームコンポーネント
/// フェード効果時にホットスポットが浮いてしまう問題を解決
class RoomWithHotspots extends StatefulWidget {
  final GameBackgroundConfig config;
  final double topReservedHeight;
  final double bottomReservedHeight;
  final Size gameSize;

  const RoomWithHotspots({
    super.key,
    required this.config,
    required this.topReservedHeight,
    required this.bottomReservedHeight,
    required this.gameSize,
  });

  @override
  State<RoomWithHotspots> createState() => _RoomWithHotspotsState();
}

class _RoomWithHotspotsState extends State<RoomWithHotspots> {
  GameBackgroundConfig? _currentConfig;

  @override
  void initState() {
    super.initState();
    _currentConfig = widget.config;
  }

  @override
  void didUpdateWidget(RoomWithHotspots oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.asset.path != widget.config.asset.path) {
      setState(() {
        _currentConfig = widget.config;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return _buildBlackFadeTransition(child, animation);
      },
      child: _buildRoomWithHotspots(),
    );
  }

  /// 黒ベースのフェードトランジション
  Widget _buildBlackFadeTransition(Widget child, Animation<double> animation) {
    return Stack(
      children: [
        // 常に黒背景を維持
        Container(color: Colors.black),
        // 背景+ホットスポットを一緒にフェード
        FadeTransition(
          opacity: animation,
          child: child,
        ),
      ],
    );
  }

  /// 背景とホットスポットを統合したWidget
  Widget _buildRoomWithHotspots() {
    if (_currentConfig == null) {
      return Container(color: Colors.black);
    }

    return Stack(
      key: ValueKey(_currentConfig!.asset.path),
      children: [
        // 背景画像
        OptimizedSmoothGameBackground(
          config: _currentConfig!,
          bottomReservedHeight: widget.bottomReservedHeight,
        ),
        
        // ホットスポット（背景と一緒にフェード）
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: HotspotDisplay(
            gameSize: widget.gameSize,
          ),
        ),
      ],
    );
  }
}

/// 高性能版ルーム+ホットスポット統合コンポーネント
class OptimizedRoomWithHotspots extends StatelessWidget {
  final GameBackgroundConfig config;
  final double topReservedHeight;
  final double bottomReservedHeight;
  final Size gameSize;

  const OptimizedRoomWithHotspots({
    super.key,
    required this.config,
    required this.topReservedHeight,
    required this.bottomReservedHeight,
    required this.gameSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 背景（フェード効果付き）
        OptimizedSmoothGameBackground(
          config: config.copyWith(
            topReservedHeight: topReservedHeight,
          ),
          bottomReservedHeight: bottomReservedHeight,
        ),
        
        // ホットスポット（常にタップ可能）
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: HotspotDisplay(
            gameSize: gameSize,
          ),
        ),
      ],
    );
  }
}