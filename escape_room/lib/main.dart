import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flame/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

import 'framework/ui/image_preloader.dart';
// import 'game/example_games/simple_escape_room.dart'; // 削除済み
import 'game/escape_room.dart';
import 'framework/device/device_feedback_manager.dart';
import 'framework/audio/volume_manager.dart';
import 'framework/transitions/fade_page_route.dart';
import 'game/components/room_navigation_system.dart';
import 'game/components/lighting_system.dart';
import 'game/components/inventory_system.dart';
import 'game/components/flutter_particle_system.dart';
import 'game/components/global_tap_detector.dart';
import 'framework/state/game_progress_system.dart';
import 'framework/state/game_autosave_system.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase初期化（Web環境では無効化）
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (e) {
      debugPrint('Firebase初期化エラー: $e');
    }
  }

  runApp(const ProviderScope(child: PreloadedApp(child: EscapeRoomApp())));
}

class EscapeRoomApp extends StatefulWidget {
  const EscapeRoomApp({super.key});

  @override
  State<EscapeRoomApp> createState() => _EscapeRoomAppState();
}

class _EscapeRoomAppState extends State<EscapeRoomApp> {
  @override
  void initState() {
    super.initState();
    // システム初期化
    DeviceFeedbackManager().initialize();
    VolumeManager().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return GlobalTapDetector(
      child: MaterialApp(
        title: 'Escape Master',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Noto Sans JP', // 日本語フォント設定（文字化け対策）
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ja'), // 日本語
          Locale('en'), // 英語
        ],
        builder: (context, child) {
          return Stack(
            children: [
              child!,
              // グローバルパーティクルシステム（最前面）
              Positioned.fill(
                child: FlutterParticleSystem(
                  key: FlutterParticleSystem.globalKey,
                ),
              ),
            ],
          );
        },
        home: const GameSelectionScreen(),
      ),
    );
  }
}

class GameSelectionScreen extends ConsumerStatefulWidget {
  const GameSelectionScreen({super.key});

  @override
  ConsumerState<GameSelectionScreen> createState() =>
      _GameSelectionScreenState();
}

class _GameSelectionScreenState extends ConsumerState<GameSelectionScreen>
    with WidgetsBindingObserver {
  ProgressAwareDataManager? _progressManager;
  bool _hasProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeProgressManager();
  }

  Future<void> _initializeProgressManager() async {
    _progressManager = ProgressAwareDataManager.defaultInstance();
    await _progressManager!.initialize();

    // デバッグ情報を表示
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

    if (mounted) {
      setState(() {
        _hasProgress = _progressManager!.progressManager.hasProgress;
        debugPrint('🎮 UI Updated - Has Progress: $_hasProgress');
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // アプリが再開された時に進行度を再チェック
      _refreshProgressState();
    }
  }

  Future<void> _refreshProgressState() async {
    if (_progressManager != null) {
      debugPrint('🔄 Refreshing progress state...');
      await _progressManager!.progressManager.initialize();

      if (mounted) {
        setState(() {
          _hasProgress = _progressManager!.progressManager.hasProgress;
          debugPrint('🔄 Progress state refreshed - Has Progress: $_hasProgress');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade900,
              Colors.indigo.shade900,
              Colors.blue.shade800,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 背景装飾
              Positioned(
                top: 100,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: 150,
                left: -75,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),

              // メインコンテンツ
              Column(
                children: [
                  // メインコンテンツエリア（修正版レスポンシブ対応）
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            // タイトルエリア（固定サイズ）
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '🔓',
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.height >
                                              700
                                          ? 64
                                          : 48,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    localizations?.appTitle ?? 'Escape Master',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.of(context).size.height >
                                              700
                                          ? 48
                                          : 36,
                                      fontWeight: FontWeight.bold,
                                      shadows: const [
                                        Shadow(
                                          color: Colors.black54,
                                          offset: Offset(2, 2),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    localizations?.appSubtitle ?? '究極の脱出パズルゲーム',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontSize:
                                          MediaQuery.of(context).size.height >
                                              700
                                          ? 18
                                          : 14,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // メインボタンエリア
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32.0,
                                vertical: 20,
                              ),
                              child: Column(
                                children: [
                                  // 始めるボタン
                                  _buildMainButton(
                                    context: context,
                                    icon: Icons.play_arrow,
                                    text: localizations?.buttonStart ?? 'はじめる',
                                    subtitle: '',
                                    color: Colors.green.shade600,
                                    onPressed: () async {
                                      DeviceFeedbackManager().gameActionVibrate(
                                        GameAction.buttonTap,
                                      );
                                      if (_hasProgress) {
                                        _showOverwriteWarningDialog();
                                      } else {
                                        await _startNewGame();
                                      }
                                    },
                                  ),

                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height > 700
                                        ? 16
                                        : 12,
                                  ),

                                  // 続きからボタン
                                  _buildMainButton(
                                    context: context,
                                    icon: Icons.save_alt,
                                    text:
                                        localizations?.buttonContinue ??
                                        'つづきから',
                                    subtitle: '',
                                    color: _hasProgress
                                        ? Colors.blue.shade600
                                        : Colors.grey.shade600,
                                    onPressed: _hasProgress
                                        ? () async {
                                            DeviceFeedbackManager()
                                                .gameActionVibrate(
                                                  GameAction.buttonTap,
                                                );
                                            await _loadSavedGame();
                                          }
                                        : null,
                                  ),

                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height > 700
                                        ? 16
                                        : 12,
                                  ),

                                  // 遊び方ボタン
                                  _buildMainButton(
                                    context: context,
                                    icon: Icons.help_outline,
                                    text:
                                        localizations?.buttonHowToPlay ??
                                        'あそびかた',
                                    subtitle: '',
                                    color: Colors.orange.shade600,
                                    onPressed: () {
                                      DeviceFeedbackManager().gameActionVibrate(
                                        GameAction.buttonTap,
                                      );
                                      _showHowToPlayDialog(context);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 下部ボタンエリア
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 音量設定ボタン
                        _buildIconButton(
                          icon: Icons.volume_up,
                          onPressed: () {
                            _showVolumeDialog(context);
                          },
                          tooltip:
                              localizations?.tooltipVolumeSettings ?? '音量設定',
                        ),

                        // ランキングボタン
                        _buildIconButton(
                          icon: Icons.leaderboard,
                          onPressed: () {
                            // TODO: ランキング機能
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ランキング機能（実装予定）')),
                            );
                          },
                          tooltip: localizations?.tooltipRanking ?? 'ランキング',
                        ),

                        // 実績ボタン
                        _buildIconButton(
                          icon: Icons.emoji_events,
                          onPressed: () {
                            // TODO: 実績機能
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('実績機能（実装予定）')),
                            );
                          },
                          tooltip: localizations?.tooltipAchievements ?? '実績',
                        ),

                        // 設定ボタン
                        _buildIconButton(
                          icon: Icons.settings,
                          onPressed: () {
                            _showSettingsDialog(context);
                          },
                          tooltip: localizations?.tooltipSettings ?? '設定',
                        ),

                        // 情報ボタン
                        _buildIconButton(
                          icon: Icons.info_outline,
                          onPressed: () {
                            _showAboutDialog(context);
                          },
                          tooltip: localizations?.tooltipAppInfo ?? 'アプリ情報',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton({
    required BuildContext context,
    required IconData icon,
    required String text,
    required String subtitle,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    return SizedBox(
      width: double.infinity,
      height: isSmallScreen ? 65 : 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: color.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(icon, size: isSmallScreen ? 28 : 32),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white70),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  void _showHowToPlayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🎮 あそびかた'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('📱 基本操作', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• 画面をタップして部屋の中を調べよう'),
                Text('• アイテムをタップして詳細を確認'),
                Text('• インベントリのアイテムを組み合わせて使用'),
                SizedBox(height: 16),
                Text(
                  '🔍 ゲームの進め方',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• 部屋に隠されたアイテムを見つけよう'),
                Text('• パズルを解いて新しいアイテムを入手'),
                Text('• すべての謎を解いて部屋から脱出'),
                SizedBox(height: 16),
                Text('💡 ヒント', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• 困ったときはヒントボタンを活用'),
                Text('• アイテムは詳しく調べると新たな発見が'),
                Text('• 複数の部屋を行き来することも重要'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  void _showVolumeDialog(BuildContext context) {
    final volumeManager = VolumeManager();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ListenableBuilder(
              listenable: volumeManager,
              builder: (context, child) {
                return AlertDialog(
                  title: Row(
                    children: [
                      const Text('🔊 音量設定'),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          volumeManager.isMuted
                              ? Icons.volume_off
                              : Icons.volume_up,
                          color: volumeManager.isMuted ? Colors.red : null,
                        ),
                        onPressed: () {
                          volumeManager.toggleMute();
                          // ミュート切り替え時にフィードバック
                          DeviceFeedbackManager().gameActionVibrate(
                            GameAction.buttonTap,
                          );
                        },
                        tooltip: volumeManager.isMuted ? 'ミュート解除' : 'ミュート',
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // BGM音量スライダー
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('🎵 BGM音量'),
                              Text(
                                '${(volumeManager.bgmVolume * 100).round()}%',
                              ),
                            ],
                          ),
                          Slider(
                            value: volumeManager.bgmVolume,
                            min: 0.0,
                            max: 1.0,
                            divisions: 20,
                            onChanged: volumeManager.isMuted
                                ? null
                                : (value) {
                                    volumeManager.setBgmVolume(value);
                                    // 音量変更時に軽いフィードバック
                                    DeviceFeedbackManager().vibrate(
                                      pattern: VibrationPattern.light,
                                    );
                                  },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 効果音音量スライダー
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('🔔 効果音音量'),
                              Text(
                                '${(volumeManager.sfxVolume * 100).round()}%',
                              ),
                            ],
                          ),
                          Slider(
                            value: volumeManager.sfxVolume,
                            min: 0.0,
                            max: 1.0,
                            divisions: 20,
                            onChanged: volumeManager.isMuted
                                ? null
                                : (value) {
                                    volumeManager.setSfxVolume(value);
                                    // 音量変更時にテスト効果音を再生
                                    volumeManager.playGameSfx(
                                      GameSfxType.buttonTap,
                                    );
                                  },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ミュート状態の表示
                      if (volumeManager.isMuted)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.volume_off,
                                color: Colors.red,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'ミュート中',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  actions: [
                    // リセットボタン
                    TextButton(
                      onPressed: () {
                        volumeManager.resetToDefaults();
                        DeviceFeedbackManager().gameActionVibrate(
                          GameAction.buttonTap,
                        );
                      },
                      child: const Text('リセット'),
                    ),
                    // テストボタン
                    TextButton(
                      onPressed: () {
                        volumeManager.playGameSfx(GameSfxType.success);
                        DeviceFeedbackManager().gameActionVibrate(
                          GameAction.buttonTap,
                        );
                      },
                      child: const Text('テスト'),
                    ),
                    // 閉じるボタン
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        DeviceFeedbackManager().gameActionVibrate(
                          GameAction.buttonTap,
                        );
                      },
                      child: const Text('閉じる'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final deviceManager = DeviceFeedbackManager();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('⚙️ 設定'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: const Text('バイブレーション'),
                    subtitle: const Text('タップ時の振動フィードバック'),
                    value: deviceManager.vibrationEnabled,
                    onChanged: (value) {
                      setState(() {
                        deviceManager.vibrationEnabled = value;
                      });
                      if (value) {
                        // 設定変更時にテストバイブレーション
                        deviceManager.vibrate(pattern: VibrationPattern.light);
                      }
                    },
                  ),
                  SwitchListTile(
                    title: const Text('プッシュ通知'),
                    subtitle: const Text('ゲーム更新やヒントの通知'),
                    value: deviceManager.notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        deviceManager.notificationsEnabled = value;
                      });
                      if (value) {
                        // 設定変更時にテスト通知
                        deviceManager.showLocalNotification(
                          title: '通知が有効になりました',
                          body: 'Escape Masterからの通知を受け取れます',
                        );
                      }
                    },
                  ),
                  SwitchListTile(
                    title: const Text('自動セーブ'),
                    subtitle: const Text('進行状況の自動保存'),
                    value: true,
                    onChanged: (value) {
                      // TODO: 自動セーブ設定
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('自動セーブ機能（実装予定）')),
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('閉じる'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ℹ️ アプリ情報'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Escape Master',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text('バージョン: 1.0.0'),
              Text('開発者: Claude Code'),
              SizedBox(height: 16),
              Text('本格的な脱出ゲームを楽しめるアプリです。'),
              Text('様々な謎解きにチャレンジして、'),
              Text('すべての部屋からの脱出を目指しましょう！'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  void _showOverwriteWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange.shade600, size: 28),
              const SizedBox(width: 12),
              const Text('確認', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '新しいゲームを開始すると、現在の進行状況が削除されます。',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '「つづきから」で現在の進行状況を再開できます',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '本当に新しいゲームを開始しますか？',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'キャンセル',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _startNewGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'データを削除して開始',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startNewGame() async {
    if (_progressManager == null) return;

    debugPrint('🆕 Starting new game...');

    // 既存の進行度があれば削除
    if (_hasProgress) {
      await _progressManager!.resetProgress();
      debugPrint('🗑️ Previous progress data deleted');
    }

    // ゲーム開始時：すべての状態を初期化
    RoomNavigationSystem().resetToInitialRoom();
    LightingSystem().resetToInitialState();
    InventorySystem().initializeEmpty();

    // 新しいゲームを開始
    await _progressManager!.startNewGame('escape_room');

    debugPrint('🆕 New game started successfully');
    debugPrint('  Has Progress: ${_progressManager!.progressManager.hasProgress}');
    debugPrint(
      '  Current Progress: ${_progressManager!.progressManager.currentProgress}',
    );

    if (mounted) {
      Navigator.of(context).pushFade(const EscapeRoom()).then((_) {
        // ゲームから戻った時に進行度を再チェック
        _refreshProgressState();
      });
    }
  }

  Future<void> _loadSavedGame() async {
    debugPrint('🔄 Loading saved game...');
    debugPrint('  Progress Manager: ${_progressManager != null}');
    debugPrint('  Has Progress: $_hasProgress');

    if (_progressManager == null || !_hasProgress) {
      debugPrint('❌ Cannot load: Manager is null or no progress');
      return;
    }

    try {
      // 保存されたゲームを読み込み
      final progress = await _progressManager!.continueGame();

      debugPrint('🔄 Continue game result: $progress');

      if (progress != null) {
        debugPrint('✅ Progress loaded successfully:');
        debugPrint('  Game ID: ${progress.gameId}');
        debugPrint('  Level: ${progress.currentLevel}');
        debugPrint('  Completion: ${progress.completionRate}');

        // 進行度に基づいてゲーム状態を復元
        _restoreGameState(progress);

        if (mounted) {
          Navigator.of(context).pushFade(const EscapeRoom()).then((_) {
            // ゲームから戻った時に進行度を再チェック
            _refreshProgressState();
          });
        }
      } else {
        debugPrint('❌ Progress is null');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('セーブデータの読み込みに失敗しました')));
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading saved game: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
      }
    }
  }

  void _restoreGameState(GameProgress progress) {
    // ゲーム状態を進行度から復元
    final gameData = progress.gameData;

    // レベル/ルーム状態の復元
    if (gameData.containsKey('current_room')) {
      final currentRoom = gameData['current_room'] as String?;
      if (currentRoom != null) {
        // TODO: RoomNavigationSystem に進行度復元機能を追加後に実装
      }
    }

    // インベントリ状態の復元
    if (gameData.containsKey('inventory')) {
      final inventoryData = gameData['inventory'] as Map<String, dynamic>?;
      if (inventoryData != null) {
        // TODO: InventorySystem に進行度復元機能を追加後に実装
      }
    }

    // ライティング状態の復元
    if (gameData.containsKey('lighting')) {
      final lightingData = gameData['lighting'] as Map<String, dynamic>?;
      if (lightingData != null) {
        // TODO: LightingSystem に進行度復元機能を追加後に実装
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _progressManager?.dispose();
    super.dispose();
  }
}

class GameScreen<T extends Game> extends StatelessWidget {
  final String gameTitle;
  final T Function() gameFactory;

  const GameScreen({
    super.key,
    required this.gameTitle,
    required this.gameFactory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(gameTitle),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: GameWidget<T>.controlled(
        gameFactory: gameFactory,
        key: ValueKey('${gameTitle}_canvas'),
        overlayBuilderMap: _buildOverlayMap(),
      ),
    );
  }

  Map<String, Widget Function(BuildContext, T)> _buildOverlayMap() {
    return {
      'startUI': (context, game) {
        // SimpleEscapeRoom削除済み
        return const SizedBox.shrink();
      },
      'settingsUI': (context, game) {
        return const SizedBox.shrink();
      },
      'gameUI': (context, game) {
        // SimpleEscapeRoom削除済み
        return const SizedBox.shrink();
      },
      'gameOverUI': (context, game) {
        // SimpleEscapeRoom削除済み
        return const SizedBox.shrink();
      },
    };
  }
}
