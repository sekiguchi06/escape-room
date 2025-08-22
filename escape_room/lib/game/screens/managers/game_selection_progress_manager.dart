import 'package:flutter/material.dart';

import '../../../framework/state/game_progress_system.dart';
import '../../../framework/state/game_autosave_system.dart';
import '../../components/room_navigation_system.dart';
import '../../components/lighting_system.dart';
import '../../components/inventory_system.dart';

/// Manages game progress operations for the game selection screen
class GameSelectionProgressManager with WidgetsBindingObserver {
  ProgressAwareDataManager? _progressManager;
  bool _hasProgress = false;
  VoidCallback? _onProgressChanged;

  bool get hasProgress => _hasProgress;
  ProgressAwareDataManager? get progressManager => _progressManager;

  GameSelectionProgressManager({VoidCallback? onProgressChanged}) {
    _onProgressChanged = onProgressChanged;
  }

  Future<void> initialize() async {
    _progressManager = ProgressAwareDataManager.defaultInstance();
    await _progressManager!.initialize();

    print('🔍 Progress Manager Debug:');
    print('  Has Progress: ${_progressManager!.progressManager.hasProgress}');
    print(
      '  Current Progress: ${_progressManager!.progressManager.currentProgress}',
    );
    if (_progressManager!.progressManager.currentProgress != null) {
      final progress = _progressManager!.progressManager.currentProgress!;
      print('  Game ID: ${progress.gameId}');
      print('  Level: ${progress.currentLevel}');
      print('  Completion: ${progress.completionRate}');
    }

    _hasProgress = _progressManager!.progressManager.hasProgress;
    print('🎮 Progress Manager Initialized - Has Progress: $_hasProgress');
    _onProgressChanged?.call();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshProgressState();
    }
  }

  Future<void> refreshProgressState() async {
    if (_progressManager != null) {
      print('🔄 Refreshing progress state...');
      await _progressManager!.progressManager.initialize();

      _hasProgress = _progressManager!.progressManager.hasProgress;
      print('🔄 Progress state refreshed - Has Progress: $_hasProgress');
      _onProgressChanged?.call();
    }
  }

  Future<void> startNewGame() async {
    if (_progressManager == null) return;

    print('🆕 Starting new game...');

    if (_hasProgress) {
      await _progressManager!.resetProgress();
      print('🗑️ Previous progress data deleted');
    }

    RoomNavigationSystem().resetToInitialRoom();
    LightingSystem().resetToInitialState();
    InventorySystem().initializeEmpty();

    await _progressManager!.startNewGame('escape_room');

    print('🆕 New game started successfully');
    print('  Has Progress: ${_progressManager!.progressManager.hasProgress}');
    print(
      '  Current Progress: ${_progressManager!.progressManager.currentProgress}',
    );

    _hasProgress = _progressManager!.progressManager.hasProgress;
    _onProgressChanged?.call();
  }

  Future<GameProgress?> loadSavedGame() async {
    print('🔄 Loading saved game...');
    print('  Progress Manager: ${_progressManager != null}');
    print('  Has Progress: $_hasProgress');

    if (_progressManager == null || !_hasProgress) {
      print('❌ Cannot load: Manager is null or no progress');
      return null;
    }

    try {
      final progress = await _progressManager!.continueGame();

      print('🔄 Continue game result: $progress');

      if (progress != null) {
        print('✅ Progress loaded successfully:');
        print('  Game ID: ${progress.gameId}');
        print('  Level: ${progress.currentLevel}');
        print('  Completion: ${progress.completionRate}');

        _restoreGameState(progress);
        return progress;
      } else {
        print('❌ Progress is null');
        return null;
      }
    } catch (e) {
      print('❌ Error loading saved game: $e');
      rethrow;
    }
  }

  void _restoreGameState(GameProgress progress) {
    final gameData = progress.gameData;

    if (gameData.containsKey('current_room')) {
      final currentRoom = gameData['current_room'] as String?;
      if (currentRoom != null) {
        // TODO: RoomNavigationSystem に進行度復元機能を追加後に実装
      }
    }

    if (gameData.containsKey('inventory')) {
      final inventoryData = gameData['inventory'] as Map<String, dynamic>?;
      if (inventoryData != null) {
        // TODO: InventorySystem に進行度復元機能を追加後に実装
      }
    }

    if (gameData.containsKey('lighting')) {
      final lightingData = gameData['lighting'] as Map<String, dynamic>?;
      if (lightingData != null) {
        // TODO: LightingSystem に進行度復元機能を追加後に実装
      }
    }
  }

  void dispose() {
    _progressManager?.dispose();
  }
}
