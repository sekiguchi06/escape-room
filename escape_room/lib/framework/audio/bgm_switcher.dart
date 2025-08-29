import 'package:flutter/foundation.dart';
import 'package:flame_audio/flame_audio.dart';
import 'audio_service.dart';

/// BGM切り替えヘルパー関数
/// 画面遷移時のBGM切り替えを統一化するユーティリティ
class BGMSwitcher {
  static final AudioService _audioService = AudioService();

  /// ゲーム状態に応じたBGM切り替え
  /// 
  /// [context] 画面コンテキスト（スタート、ゲーム中、地下等）
  /// [fadeOutDuration] フェードアウト時間（デフォルト1.0秒）
  static Future<void> switchToContextBGM(
    BGMContext context, {
    Duration fadeOutDuration = const Duration(milliseconds: 1000),
  }) async {
    debugPrint('🎵 BGMSwitcher: switchToContextBGM called with context: $context');
    
    // AudioService初期化を確実に行う
    debugPrint('🎵 BGMSwitcher: Initializing AudioService...');
    await _audioService.initialize();
    debugPrint('🎵 BGMSwitcher: AudioService initialized: ${_audioService.isInitialized}');
    
    final bgmFile = _getBGMFileForContext(context);
    if (bgmFile != null) {
      debugPrint('🎵 BGMSwitcher: Switching to BGM file: $bgmFile');
      await _audioService.switchBGMWithFade(
        bgmFile,
        fadeOutDuration: fadeOutDuration,
      );
      debugPrint('🎵 BGMSwitcher: BGM switch completed');
    } else {
      debugPrint('⚠️ BGMSwitcher: BGM file is null for context: $context');
    }
  }

  /// ルーム遷移時のBGM切り替え
  /// 
  /// [roomType] 部屋タイプ
  /// [fadeOutDuration] フェードアウト時間（デフォルト1.0秒）
  static Future<void> switchToRoomBGM(
    RoomBGMType roomType, {
    Duration fadeOutDuration = const Duration(milliseconds: 1000),
  }) async {
    // AudioService初期化を確実に行う
    await _audioService.initialize();
    
    final bgmFile = _getBGMFileForRoom(roomType);
    if (bgmFile != null) {
      await _audioService.switchBGMWithFade(
        bgmFile,
        fadeOutDuration: fadeOutDuration,
      );
    }
  }

  /// 画面遷移時の即座BGM切り替え（フェードあり）
  /// 
  /// [newBGMFile] 新しいBGMファイル名（空文字列の場合は停止のみ）
  /// [fadeOutDuration] フェードアウト時間（デフォルト1.0秒）
  static Future<void> switchBGM(
    String newBGMFile, {
    Duration fadeOutDuration = const Duration(milliseconds: 1000),
  }) async {
    debugPrint('🎵 BGMSwitcher: switchBGM called with file: "$newBGMFile", fadeOutDuration: ${fadeOutDuration.inMilliseconds}ms');
    
    // AudioService初期化を確実に行う
    await _audioService.initialize();
    
    // 空文字列の場合もフェードアウトを使って停止
    if (newBGMFile.isEmpty) {
      debugPrint('🎵 BGMSwitcher: Empty file - stopping BGM with fade');
      await _audioService.switchBGMWithFade(
        '', // 空文字列を渡してフェードアウト停止
        fadeOutDuration: fadeOutDuration,
      );
      return;
    }
    
    await _audioService.switchBGMWithFade(
      newBGMFile,
      fadeOutDuration: fadeOutDuration,
    );
  }

  /// コンテキストからBGMファイルを取得
  static String? _getBGMFileForContext(BGMContext context) {
    String? bgmFile;
    switch (context) {
      case BGMContext.startScreen:
        bgmFile = AudioAssets.moonlight;         // スタート画面BGM
        break;
      case BGMContext.mainGame:
        bgmFile = AudioAssets.mistyDream;        // 1階BGM
        break;
      case BGMContext.underground:
        bgmFile = AudioAssets.swimmingFishDream; // 地下BGM
        break;
      case BGMContext.menu:
        bgmFile = AudioAssets.moonlight;         // メニュー画面BGM
        break;
      case BGMContext.gameOver:
        bgmFile = null; // 無音またはSEのみ
        break;
    }
    
    debugPrint('🎵 BGMSwitcher: Context $context → BGM file: ${bgmFile ?? "null"}');
    return bgmFile;
  }

  /// 部屋タイプからBGMファイルを取得
  static String? _getBGMFileForRoom(RoomBGMType roomType) {
    switch (roomType) {
      case RoomBGMType.mainFloor:
        return AudioAssets.mistyDream;        // 1階メインBGM
      case RoomBGMType.underground:
        return AudioAssets.swimmingFishDream; // 地下BGM
      case RoomBGMType.hiddenRoom:
        return AudioAssets.mistyDream;        // 隠し部屋（1階BGMと同じ）
      case RoomBGMType.finalPuzzle:
        return AudioAssets.swimmingFishDream; // 最終謎（緊張感のある地下BGM）
    }
  }

  /// 現在再生中のBGMファイル名を取得
  static String? get currentBGM => _audioService.currentBGMFile;

  /// フェード中かどうか
  static bool get isFading => _audioService.isFading;

  /// 【一時的なテスト用メソッド】FlameAudio直接テスト
  static Future<void> testDirectBGM() async {
    try {
      debugPrint('🧪 BGMSwitcher: Testing direct FlameAudio BGM playback...');
      await FlameAudio.bgm.play('moonlight.mp3', volume: 0.7);
      debugPrint('✅ BGMSwitcher: Direct FlameAudio BGM test successful');
    } catch (e) {
      debugPrint('❌ BGMSwitcher: Direct FlameAudio BGM test failed: $e');
    }
  }
}

/// BGMコンテキスト（画面状態）
enum BGMContext {
  startScreen,  // スタート画面
  mainGame,     // メインゲーム
  underground,  // 地下エリア
  menu,         // メニュー画面
  gameOver,     // ゲームオーバー
}

/// 部屋BGMタイプ
enum RoomBGMType {
  mainFloor,    // 1階
  underground,  // 地下
  hiddenRoom,   // 隠し部屋
  finalPuzzle,  // 最終謎
}