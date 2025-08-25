import 'package:flutter/material.dart';
import '../../framework/ui/multi_floor_navigation_system.dart';

/// 部屋の位置を示すインジケーター
class RoomIndicator extends StatelessWidget {
  const RoomIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MultiFloorNavigationSystem(),
      builder: (context, _) {
        final currentIndex = MultiFloorNavigationSystem().currentRoomIndex;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final roomIndex = index - 2; // -2, -1, 0, 1, 2
              final isActive = roomIndex == currentIndex;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? Colors.amber[400]
                      : Colors.white.withValues(alpha: 0.4),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
