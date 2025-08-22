import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../gen/assets.gen.dart';

/// 画像プリローダー
/// ゲーム起動時にすべての背景画像をプリキャッシュして
/// 画面切り替え時のフラッシュバック現象を防ぐ
class ImagePreloader {
  static final ImagePreloader _instance = ImagePreloader._internal();
  factory ImagePreloader() => _instance;
  ImagePreloader._internal();

  /// プリロード済みかどうか
  bool _isPreloaded = false;
  bool get isPreloaded => _isPreloaded;

  /// プリロード進行状況
  double _progress = 0.0;
  double get progress => _progress;

  /// プリロード完了通知
  final ValueNotifier<bool> _preloadComplete = ValueNotifier<bool>(false);
  ValueListenable<bool> get preloadComplete => _preloadComplete;

  /// プリロード進行状況通知
  final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(0.0);
  ValueListenable<double> get progressNotifier => _progressNotifier;

  /// すべてのルーム画像をプリロード
  Future<void> preloadAllRoomImages(BuildContext context) async {
    if (_isPreloaded) return;

    // プリロード対象の画像リスト
    final images = [
      // 基本ルーム画像
      Assets.images.escapeRoomBg,
      Assets.images.roomLeft,
      Assets.images.roomLeftmost,
      Assets.images.roomRight,
      Assets.images.roomRightmost,

      // 夜モード画像
      Assets.images.escapeRoomBgNight,
      Assets.images.roomLeftNight,
      Assets.images.roomLeftmostNight,
      Assets.images.roomRightNight,
      Assets.images.roomRightmostNight,
    ];

    final total = images.length;
    int loaded = 0;

    // 並列プリロードでパフォーマンス向上
    final futures = images.map((asset) async {
      try {
        // Flutter Image Provider にプリキャッシュ
        await precacheImage(asset.provider(), context);

        // AssetBundle にもプリロード
        await _preloadAssetBundle(asset.path);

        loaded++;
        _progress = loaded / total;
        _progressNotifier.value = _progress;
      } catch (e) {
        debugPrint('❌ Failed to preload ${asset.path}: $e');
      }
    });

    // すべての画像プリロードを待機
    await Future.wait(futures);

    _isPreloaded = true;
    _preloadComplete.value = true;
  }

  /// AssetBundle レベルでのプリロード
  Future<void> _preloadAssetBundle(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
    } catch (e) {
      debugPrint('⚠️ AssetBundle preload failed for $assetPath: $e');
    }
  }

  /// プリロード状況をリセット（テスト用）
  void reset() {
    _isPreloaded = false;
    _progress = 0.0;
    _preloadComplete.value = false;
    _progressNotifier.value = 0.0;
  }

  /// プリロード完了を待機
  Future<void> waitForPreload() async {
    if (_isPreloaded) return;

    // プリロード完了まで待機
    while (!_preloadComplete.value) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }
}

/// プリロード進行状況表示ウィジェット（ミニマル版）
class ImagePreloadIndicator extends StatelessWidget {
  const ImagePreloadIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: ImagePreloader().progressNotifier,
      builder: (context, progress, child) {
        if (progress >= 1.0) {
          return const SizedBox.shrink();
        }

        // 非常にミニマルなインジケーター（文字なし）
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white30),
          ),
        );
      },
    );
  }
}

/// 画像プリロード付きアプリ初期化ウィジェット
class PreloadedApp extends StatefulWidget {
  final Widget child;
  final Widget? loadingWidget;

  const PreloadedApp({super.key, required this.child, this.loadingWidget});

  @override
  State<PreloadedApp> createState() => _PreloadedAppState();
}

class _PreloadedAppState extends State<PreloadedApp> {
  final ImagePreloader _preloader = ImagePreloader();
  bool _hasStartedPreload = false;
  bool _showErrorRecovery = false;

  @override
  void initState() {
    super.initState();
    _safePreloadImages();
  }

  /// 安全な画像プリロード実行
  void _safePreloadImages() async {
    try {
      // フレーム構築完了を待機
      await WidgetsBinding.instance.endOfFrame;

      if (!mounted) return;

      setState(() {
        _hasStartedPreload = true;
      });

      // プリロード実行（エラーハンドリング付き）
      await _preloader.preloadAllRoomImages(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _showErrorRecovery = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // プリロード開始前は初期ローディング画面
    if (!_hasStartedPreload) {
      return _buildInitialLoadingScreen();
    }

    // エラー時はリカバリー画面
    if (_showErrorRecovery) {
      return _buildErrorRecoveryScreen();
    }

    // プリロード状況に応じて表示切り替え
    return ValueListenableBuilder<bool>(
      valueListenable: _preloader.preloadComplete,
      builder: (context, isComplete, child) {
        if (isComplete) {
          // アニメーション付きでメインアプリに切り替え
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: widget.child,
          );
        }

        return _buildPreloadingScreen();
      },
    );
  }

  /// 初期ローディング画面（無音版）
  Widget _buildInitialLoadingScreen() {
    return MaterialApp(
      home: const Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.shrink(), // 完全に無音
      ),
    );
  }

  /// プリロード中画面（無音版）
  Widget _buildPreloadingScreen() {
    return MaterialApp(
      home: const Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.shrink(), // 完全に無音
      ),
    );
  }

  /// エラーリカバリー画面
  Widget _buildErrorRecoveryScreen() {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Loading failed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Some images could not be loaded',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showErrorRecovery = false;
                    _hasStartedPreload = false;
                  });
                  _safePreloadImages();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // プリロードをスキップしてメインアプリへ
                  _preloader._preloadComplete.value = true;
                },
                child: const Text(
                  'Skip and Continue',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
