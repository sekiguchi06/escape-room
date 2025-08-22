import '../test_utils/test_environment.dart';
import '../audio/audio_system.dart';
import '../audio/providers/flame_audio_provider.dart';
import '../audio/providers/audioplayers_provider.dart';
import 'package:flutter/foundation.dart';

/// AudioProvider自動選択ファクトリー
///
/// 実行環境に基づいて適切なAudioProvider実装を自動選択：
/// - テスト環境: FlameAudioProvider（プラグイン依存なし）
/// - プロダクション環境: AudioPlayersProvider（実際の音声再生）
class AudioProviderFactory {
  /// 環境に応じた最適なAudioProvider実装を作成
  ///
  /// [forceImplementation] - 強制的に特定の実装を使用する場合
  /// [testEnvironment] - テスト環境かどうかを明示的に指定
  static AudioProvider create({
    String? forceImplementation,
    bool? testEnvironment,
  }) {
    // 強制指定がある場合
    if (forceImplementation != null) {
      return _createByName(forceImplementation);
    }

    // テスト環境判定（明示指定 > 自動検知）
    final isTest =
        testEnvironment ?? TestEnvironmentDetector.isDefinitelyTestEnvironment;

    if (isTest) {
      debugPrint('🎵 AudioProvider: FlameAudioProvider (Test Environment)');
      return FlameAudioProvider();
    } else {
      debugPrint(
        '🎵 AudioProvider: AudioPlayersProvider (Production Environment)',
      );
      return AudioPlayersProvider();
    }
  }

  /// 名前による実装作成（主にテスト・デバッグ用）
  static AudioProvider _createByName(String name) {
    switch (name.toLowerCase()) {
      case 'flame':
      case 'mock':
      case 'test':
        return FlameAudioProvider();
      case 'audioplayers':
      case 'production':
      case 'real':
        return AudioPlayersProvider();
      default:
        throw ArgumentError('Unknown AudioProvider implementation: $name');
    }
  }

  /// 利用可能な実装一覧
  static List<String> get availableImplementations => ['flame', 'audioplayers'];

  /// デバッグ情報
  static Map<String, dynamic> get debugInfo => {
    'testEnvironment': TestEnvironmentDetector.isDefinitelyTestEnvironment,
    'selectedProvider': TestEnvironmentDetector.isDefinitelyTestEnvironment
        ? 'FlameAudioProvider'
        : 'AudioPlayersProvider',
    'availableImplementations': availableImplementations,
    ...TestEnvironmentDetector.debugInfo,
  };
}

/// ファクトリーを使用した便利な拡張
extension AudioProviderFactoryExtension on AudioProvider {
  /// 現在のproviderがテスト環境用かどうか
  bool get isTestProvider => this is FlameAudioProvider;

  /// 現在のproviderがプロダクション環境用かどうか
  bool get isProductionProvider => this is AudioPlayersProvider;

  /// プロバイダー名を取得
  String get providerName {
    if (this is FlameAudioProvider) return 'FlameAudioProvider';
    if (this is AudioPlayersProvider) return 'AudioPlayersProvider';
    return runtimeType.toString();
  }
}
