import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../../core/configurable_game_base.dart';
import '../../state/game_state_system.dart';
import '../../ui/multi_floor_navigation_system.dart';
import '../../persistence/data_manager.dart';
import '../../../game/components/room_navigation_system.dart';
import 'room_types.dart';
import 'floor_transition_service.dart';

class EscapeRoomGameLogic {
  final ConfigurableGameBase gameBase;
  final GameStateProvider gameStateSystem;
  final MultiFloorNavigationSystem navigationSystem;
  final DataManager dataManager;
  final RoomNavigationSystem roomNavigationSystem;
  final FloorTransitionService floorTransitionService;

  EscapeRoomGameLogic({
    required this.gameBase,
    required this.gameStateSystem,
    required this.navigationSystem,
    required this.dataManager,
    required this.roomNavigationSystem,
    required this.floorTransitionService,
  });

  void performFloorTransition(EscapeRoomFloor floor) {
    floorTransitionService.transitionToFloor(floor);
  }

  void performRoomTransition(RoomIdentifier roomId) {
    roomNavigationSystem.navigateToRoom(roomId);
  }

  void handleMenuAction(String action) {
    switch (action) {
      case 'pause':
        gameStateSystem.pauseGame();
        break;
      case 'resume':
        gameStateSystem.resumeGame();
        break;
      case 'restart':
        gameStateSystem.resetGame();
        break;
      case 'save':
        dataManager.saveGame();
        break;
      case 'load':
        dataManager.loadGame();
        break;
      default:
        debugPrint('Unknown menu action: $action');
    }
  }

  void handleInventoryAction(String action, dynamic data) {
    switch (action) {
      case 'use_item':
        _useItem(data);
        break;
      case 'combine_items':
        _combineItems(data);
        break;
      case 'examine_item':
        _examineItem(data);
        break;
      default:
        debugPrint('Unknown inventory action: $action');
    }
  }

  void _useItem(dynamic itemData) {
    // Item usage logic
    debugPrint('Using item: $itemData');
  }

  void _combineItems(dynamic itemsData) {
    // Item combination logic
    debugPrint('Combining items: $itemsData');
  }

  void _examineItem(dynamic itemData) {
    // Item examination logic
    debugPrint('Examining item: $itemData');
  }

  void handleHotspotInteraction(String hotspotId, Map<String, dynamic> context) {
    debugPrint('Interacting with hotspot: $hotspotId');
    // Hotspot interaction logic
  }

  void handlePuzzleSolved(String puzzleId, Map<String, dynamic> result) {
    debugPrint('Puzzle solved: $puzzleId with result: $result');
    // Puzzle completion logic
  }

  void handleStateChange(String stateKey, dynamic value) {
    gameStateSystem.setState(stateKey, value);
  }

  Map<String, dynamic> getCurrentGameState() {
    return gameStateSystem.getState();
  }

  void initializeGame() {
    gameStateSystem.initializeState();
    floorTransitionService.initialize();
    roomNavigationSystem.initialize();
  }

  void disposeGame() {
    gameStateSystem.dispose();
    floorTransitionService.dispose();
    roomNavigationSystem.dispose();
  }
}