import 'package:flutter/material.dart';
import '../../escape_room/core/room_types.dart';
import 'multi_floor_navigation_system.dart';

/// ナビゲーション状態を監視するウィジェット
class NavigationListener extends StatefulWidget {
  final Widget child;
  final Function(FloorType floor, RoomType room)? onNavigationChanged;
  
  const NavigationListener({
    super.key,
    required this.child,
    this.onNavigationChanged,
  });

  @override
  State<NavigationListener> createState() => _NavigationListenerState();
}

class _NavigationListenerState extends State<NavigationListener> {
  final MultiFloorNavigationSystem _navigationSystem = MultiFloorNavigationSystem();
  FloorType? _previousFloor;
  RoomType? _previousRoom;
  
  @override
  void initState() {
    super.initState();
    _navigationSystem.addListener(_onNavigationChanged);
    _previousFloor = _navigationSystem.currentFloor;
    _previousRoom = _navigationSystem.currentRoom;
  }
  
  @override
  void dispose() {
    _navigationSystem.removeListener(_onNavigationChanged);
    super.dispose();
  }
  
  void _onNavigationChanged() {
    final currentFloor = _navigationSystem.currentFloor;
    final currentRoom = _navigationSystem.currentRoom;
    
    if (_previousFloor != currentFloor || _previousRoom != currentRoom) {
      widget.onNavigationChanged?.call(currentFloor, currentRoom);
      _previousFloor = currentFloor;
      _previousRoom = currentRoom;
      
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}