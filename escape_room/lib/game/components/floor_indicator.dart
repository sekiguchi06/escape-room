import 'package:flutter/material.dart';
import '../../framework/escape_room/core/room_types.dart';
import '../../framework/escape_room/core/floor_transition_service.dart';

/// 階層表示ウィジェット
class FloorIndicatorWidget extends StatefulWidget {
  final FloorType currentFloor;
  final bool isUndergroundUnlocked;
  final VoidCallback? onFloorTap;
  
  const FloorIndicatorWidget({
    Key? key,
    required this.currentFloor,
    required this.isUndergroundUnlocked,
    this.onFloorTap,
  }) : super(key: key);

  @override
  State<FloorIndicatorWidget> createState() => _FloorIndicatorWidgetState();
}

class _FloorIndicatorWidgetState extends State<FloorIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFloorIndicator(
            floor: FloorType.floor1,
            icon: Icons.home,
            label: '1階',
            isActive: widget.currentFloor == FloorType.floor1,
            isAccessible: true,
          ),
          const SizedBox(width: 12),
          Container(
            width: 2,
            height: 24,
            color: Colors.amber.withOpacity(0.5),
          ),
          const SizedBox(width: 12),
          _buildFloorIndicator(
            floor: FloorType.underground,
            icon: Icons.stairs,
            label: '地下',
            isActive: widget.currentFloor == FloorType.underground,
            isAccessible: widget.isUndergroundUnlocked,
          ),
        ],
      ),
    );
  }
  
  Widget _buildFloorIndicator({
    required FloorType floor,
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isAccessible,
  }) {
    final color = isActive 
        ? Colors.amber 
        : isAccessible 
            ? Colors.white70 
            : Colors.grey.withOpacity(0.5);
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isActive ? _scaleAnimation.value : 1.0,
          child: GestureDetector(
            onTap: isAccessible ? () => _onFloorTap(floor) : null,
            onTapDown: isActive ? (_) => _animationController.forward() : null,
            onTapUp: isActive ? (_) => _animationController.reverse() : null,
            onTapCancel: isActive ? () => _animationController.reverse() : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? Colors.amber.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isActive 
                    ? Border.all(color: Colors.amber, width: 1.5) 
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (!isAccessible) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.lock,
                      color: Colors.grey.withOpacity(0.5),
                      size: 14,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _onFloorTap(FloorType floor) {
    if (widget.currentFloor == floor) return;
    
    final transitionService = FloorTransitionService();
    
    switch (floor) {
      case FloorType.underground:
        if (transitionService.canTransitionToUnderground()) {
          transitionService.transitionToFloor(FloorType.underground);
          widget.onFloorTap?.call();
        } else {
          _showCannotTransitionMessage('地下への移動条件が満たされていません\n最右端の部屋で1階をクリアしてください');
        }
        break;
        
      case FloorType.floor1:
        if (transitionService.canTransitionToFloor1()) {
          transitionService.transitionToFloor(FloorType.floor1);
          widget.onFloorTap?.call();
        } else {
          _showCannotTransitionMessage('1階への移動は地下中央からのみ可能です');
        }
        break;
        
      // 隠し部屋・最終謎部屋は直接移動不可（専用の入口から移動）
      case FloorType.hiddenRoomA:
      case FloorType.hiddenRoomB:
      case FloorType.hiddenRoomC:
      case FloorType.hiddenRoomD:
      case FloorType.finalPuzzleRoom:
        _showCannotTransitionMessage('隠し部屋・最終謎部屋への直接移動はできません');
        break;
    }
  }
  
  void _showCannotTransitionMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.withOpacity(0.8),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

/// 階層進行状況表示ウィジェット
class FloorProgressWidget extends StatelessWidget {
  final FloorType currentFloor;
  final bool isFloor1Cleared;
  final bool isUndergroundUnlocked;
  
  const FloorProgressWidget({
    Key? key,
    required this.currentFloor,
    required this.isFloor1Cleared,
    required this.isUndergroundUnlocked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '進行状況',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildProgressItem(
            icon: Icons.home,
            label: '1階探索',
            isCompleted: isFloor1Cleared,
            isCurrent: currentFloor == FloorType.floor1 && !isFloor1Cleared,
          ),
          _buildProgressItem(
            icon: Icons.stairs,
            label: '地下探索',
            isCompleted: false, // Phase 1では未完了
            isCurrent: currentFloor == FloorType.underground,
            isLocked: !isUndergroundUnlocked,
          ),
          _buildProgressItem(
            icon: Icons.star,
            label: '最終謎',
            isCompleted: false,
            isCurrent: false,
            isLocked: true, // Phase 1では未実装
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressItem({
    required IconData icon,
    required String label,
    required bool isCompleted,
    required bool isCurrent,
    bool isLocked = false,
  }) {
    Color color;
    IconData statusIcon;
    
    if (isLocked) {
      color = Colors.grey;
      statusIcon = Icons.lock;
    } else if (isCompleted) {
      color = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (isCurrent) {
      color = Colors.amber;
      statusIcon = Icons.play_circle;
    } else {
      color = Colors.grey;
      statusIcon = Icons.circle_outlined;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Icon(statusIcon, color: color, size: 14),
        ],
      ),
    );
  }
}