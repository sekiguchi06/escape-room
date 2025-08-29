import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../../core/configurable_game_base.dart';
import '../../ui/multi_floor_navigation_system.dart';
import '../../ui/screen_factory.dart';
import '../../ui/screen_builders/background_utils.dart';
import '../../../game/components/game_menu_bar.dart';
import '../../../game/components/inventory_widget.dart';
import '../../../game/components/hotspot_display.dart';
import '../../../game/components/room_navigation_system.dart';
import 'room_types.dart';
import 'escape_room_game_logic.dart';

class EscapeRoomUIBuilder {
  final ConfigurableGameBase gameBase;
  final MultiFloorNavigationSystem navigationSystem;
  final ScreenFactory screenFactory;
  final EscapeRoomGameLogic gameLogic;

  EscapeRoomUIBuilder({
    required this.gameBase,
    required this.navigationSystem,
    required this.screenFactory,
    required this.gameLogic,
  });

  Widget buildGameScreen(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(context),
          _buildGameContent(context),
          _buildUI(context),
        ],
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    return Container(
      decoration: BackgroundUtils.createGradientDecoration(
        colors: [
          const Color(0xFF1a1a2e),
          const Color(0xFF16213e),
          const Color(0xFF0f3460),
        ],
      ),
    );
  }

  Widget _buildGameContent(BuildContext context) {
    return Positioned.fill(
      child: GameWidget<ConfigurableGameBase>.controlled(
        gameFactory: () => gameBase,
      ),
    );
  }

  Widget _buildUI(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: _buildMainContent(context),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildMenuButton(context),
          const Spacer(),
          _buildFloorIndicator(context),
          const Spacer(),
          _buildSettingsButton(context),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu, color: Colors.white),
      onPressed: () => _showGameMenu(context),
    );
  }

  Widget _buildFloorIndicator(BuildContext context) {
    final floor = navigationSystem.currentFloor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getFloorDisplayName(floor),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings, color: Colors.white),
      onPressed: () => _showSettings(context),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Stack(
      children: [
        _buildRoomContent(context),
        _buildHotspots(context),
        _buildInteractionOverlay(context),
      ],
    );
  }

  Widget _buildRoomContent(BuildContext context) {
    final roomId = RoomIdentifier.fromString('main_room'); // Default room
    return _buildRoomView(context, roomId);
  }

  Widget _buildRoomView(BuildContext context, RoomIdentifier roomId) {
    return Center(
      child: Text(
        'Room: ${roomId.toString()}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildHotspots(BuildContext context) {
    final hotspots = <String>[]; // Empty for now
    return Stack(
      children: hotspots.map((hotspotId) => 
        HotspotDisplay(
          hotspotId: hotspotId,
          onInteraction: (id, ctx) => 
            gameLogic.handleHotspotInteraction(id, {}),
        )
      ).toList(),
    );
  }

  Widget _buildInteractionOverlay(BuildContext context) {
    const isInteracting = false; // Default to false
    if (!isInteracting) return const SizedBox.shrink();
    
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildInventoryButton(context),
          const Spacer(),
          _buildNavigationControls(context),
          const Spacer(),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildInventoryButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.inventory, color: Colors.white),
      onPressed: () => _showInventory(context),
    );
  }

  Widget _buildNavigationControls(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => gameLogic.performRoomTransition(
            RoomIdentifier.fromString('previous'),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward, color: Colors.white),
          onPressed: () => gameLogic.performRoomTransition(
            RoomIdentifier.fromString('next'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.help, color: Colors.white),
          onPressed: () => _showHint(context),
        ),
        IconButton(
          icon: const Icon(Icons.save, color: Colors.white),
          onPressed: () => gameLogic.handleMenuAction('save'),
        ),
      ],
    );
  }

  void _showGameMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => GameMenuBar(
        onAction: gameLogic.handleMenuAction,
      ),
    );
  }

  void _showSettings(BuildContext context) {
    Navigator.pushNamed(context, '/settings');
  }

  void _showInventory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => InventoryWidget(
        onAction: gameLogic.handleInventoryAction,
      ),
    );
  }

  void _showHint(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hint'),
        content: const Text('Look for interactive objects in the room.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getFloorDisplayName(EscapeRoomFloor floor) {
    switch (floor) {
      case EscapeRoomFloor.ground:
        return '1F';
      case EscapeRoomFloor.underground:
        return 'B1F';
      case EscapeRoomFloor.hidden:
        return 'Hidden';
    }
  }
}