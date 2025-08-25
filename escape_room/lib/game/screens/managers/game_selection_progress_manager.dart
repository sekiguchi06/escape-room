import 'package:flutter/foundation.dart';
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

    if (kDebugMode) {
      debugPrint('🔍 Progress Manager Debug:');
      debugPrint('  Has Progress: ${_progressManager!.progressManager.hasProgress}');
      debugPrint(
        '  Current Progress: ${_progressManager!.progressManager.currentProgress}',
      );
      if (_progressManager!.progressManager.currentProgress != null) {
        final progress = _progressManager!.progressManager.currentProgress!;
        debugPrint('  Game ID: ${progress.gameId}');
        debugPrint('  Level: ${progress.currentLevel}');
        debugPrint('  Completion: ${progress.completionRate}');
      }
    }

    _hasProgress = _progressManager!.progressManager.hasProgress;
    if (kDebugMode) {
      debugPrint('🎮 Progress Manager Initialized - Has Progress: $_hasProgress');
    }
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
      if (kDebugMode) {
        debugPrint('🔄 Refreshing progress state...');
      }
      await _progressManager!.progressManager.initialize();

      _hasProgress = _progressManager!.progressManager.hasProgress;
      if (kDebugMode) {
        debugPrint('🔄 Progress state refreshed - Has Progress: $_hasProgress');
      }
      _onProgressChanged?.call();
    }
  }

  Future<void> startNewGame() async {
    if (_progressManager == null) return;

    if (kDebugMode) {
      debugPrint('🆕 Starting new game...');
    }

    if (_hasProgress) {
      await _progressManager!.resetProgress();
      if (kDebugMode) {
        debugPrint('🗑️ Previous progress data deleted');
      }
    }

    RoomNavigationSystem().resetToInitialRoom();
    LightingSystem().resetToInitialState();
    InventorySystem().initializeEmpty();

    await _progressManager!.startNewGame('escape_room');

    if (kDebugMode) {
      debugPrint('🆕 New game started successfully');
      debugPrint('  Has Progress: ${_progressManager!.progressManager.hasProgress}');
      debugPrint(
        '  Current Progress: ${_progressManager!.progressManager.currentProgress}',
      );
    }

    _hasProgress = _progressManager!.progressManager.hasProgress;
    _onProgressChanged?.call();
  }

  Future<GameProgress?> loadSavedGame() async {
    if (kDebugMode) {
      debugPrint('🔄 Loading saved game...');
      debugPrint('  Progress Manager: ${_progressManager != null}');
      debugPrint('  Has Progress: $_hasProgress');
    }

    if (_progressManager == null || !_hasProgress) {
      if (kDebugMode) {
        debugPrint('❌ Cannot load: Manager is null or no progress');
      }
      return null;
    }

    try {
      final progress = await _progressManager!.continueGame();

      if (kDebugMode) {
        debugPrint('🔄 Continue game result: $progress');
      }

      if (progress != null) {
        if (kDebugMode) {
          debugPrint('✅ Progress loaded successfully:');
          debugPrint('  Game ID: ${progress.gameId}');
          debugPrint('  Level: ${progress.currentLevel}');
          debugPrint('  Completion: ${progress.completionRate}');
        }

        _restoreGameState(progress);
        return progress;
      } else {
        if (kDebugMode) {
          debugPrint('❌ Progress is null');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading saved game: $e');
      }
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
