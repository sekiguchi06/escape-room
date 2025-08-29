import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'audio_service.dart';

/// 音響効果付きボタンのMixin
mixin AudioButtonMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  AudioService get _audioService => ref.read(audioServiceProvider);

  /// 音響効果付きボタンタップ
  void onTapWithAudio({
    required VoidCallback onTap,
    String audioFile = AudioAssets.decisionButton,
    AudioCategory category = AudioCategory.ui,
    double? volume,
  }) {
    // 音響効果を再生
    _audioService.play(audioFile, category, volume: volume);
    
    // 元のタップ処理を実行
    onTap();
  }

  /// 音響効果付きナビゲーション
  void navigateWithAudio({
    required BuildContext context,
    required Widget destination,
    String audioFile = AudioAssets.decisionButton,
    bool replace = false,
  }) {
    // 音響効果を再生
    _audioService.playUI(audioFile);
    
    // ナビゲーション実行
    if (replace) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => destination),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => destination),
      );
    }
  }
}

/// 音響効果付きボタンウィジェット
class AudioButton extends ConsumerWidget {
  final VoidCallback onPressed;
  final Widget child;
  final String audioFile;
  final AudioCategory audioCategory;
  final double? audioVolume;
  final ButtonStyle? style;

  const AudioButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.audioFile = AudioAssets.decisionButton,
    this.audioCategory = AudioCategory.ui,
    this.audioVolume,
    this.style,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.read(audioServiceProvider);

    return ElevatedButton(
      style: style,
      onPressed: () {
        // 音響効果を再生
        audioService.play(audioFile, audioCategory, volume: audioVolume);
        
        // 元のタップ処理を実行
        onPressed();
      },
      child: child,
    );
  }
}

/// 音響効果付きIconButton
class AudioIconButton extends ConsumerWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String audioFile;
  final AudioCategory audioCategory;
  final double? audioVolume;
  final double? iconSize;
  final Color? color;
  final String? tooltip;

  const AudioIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.audioFile = AudioAssets.buttonPress,
    this.audioCategory = AudioCategory.ui,
    this.audioVolume,
    this.iconSize,
    this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.read(audioServiceProvider);

    return IconButton(
      onPressed: () {
        // 音響効果を再生
        audioService.play(audioFile, audioCategory, volume: audioVolume);
        
        // 元のタップ処理を実行
        onPressed();
      },
      icon: Icon(icon),
      iconSize: iconSize,
      color: color,
      tooltip: tooltip,
    );
  }
}