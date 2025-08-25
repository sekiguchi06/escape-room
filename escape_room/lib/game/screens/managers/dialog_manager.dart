import 'package:flutter/material.dart';

import '../../../framework/device/device_feedback_manager.dart';
import '../../../framework/audio/volume_manager.dart';
import '../../../framework/audio/audio_service.dart';

/// Manages all dialog operations for the game selection screen
class DialogManager {
  static void showHowToPlayDialog(BuildContext context) {
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
              onPressed: () {
                // 閉じる音を再生
                AudioService().playUI(AudioAssets.close);
                Navigator.of(context).pop();
              },
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  static void showVolumeDialog(BuildContext context) {
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
                                    DeviceFeedbackManager().vibrate(
                                      pattern: VibrationPattern.light,
                                    );
                                  },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

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
                                    volumeManager.playGameSfx(
                                      GameSfxType.buttonTap,
                                    );
                                  },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

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
                    TextButton(
                      onPressed: () {
                        volumeManager.resetToDefaults();
                        DeviceFeedbackManager().gameActionVibrate(
                          GameAction.buttonTap,
                        );
                      },
                      child: const Text('リセット'),
                    ),
                    TextButton(
                      onPressed: () {
                        volumeManager.playGameSfx(GameSfxType.success);
                        DeviceFeedbackManager().gameActionVibrate(
                          GameAction.buttonTap,
                        );
                      },
                      child: const Text('テスト'),
                    ),
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


  static void showAboutDialog(BuildContext context) {
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

  static void showOverwriteWarningDialog(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
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
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
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
}
