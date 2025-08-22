import 'package:flutter/material.dart';

import '../widgets/circular_icon_button.dart';
import '../managers/dialog_manager.dart';

/// Bottom navigation bar component with icon buttons
class GameBottomNavigationBar extends StatelessWidget {
  const GameBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircularIconButton(
            icon: Icons.volume_up,
            onPressed: () {
              DialogManager.showVolumeDialog(context);
            },
            tooltip: '音量設定',
          ),

          CircularIconButton(
            icon: Icons.leaderboard,
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('ランキング機能（実装予定）')));
            },
            tooltip: 'ランキング',
          ),

          CircularIconButton(
            icon: Icons.emoji_events,
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('実績機能（実装予定）')));
            },
            tooltip: '実績',
          ),

          CircularIconButton(
            icon: Icons.settings,
            onPressed: () {
              DialogManager.showSettingsDialog(context);
            },
            tooltip: '設定',
          ),

          CircularIconButton(
            icon: Icons.info_outline,
            onPressed: () {
              DialogManager.showAboutDialog(context);
            },
            tooltip: 'アプリ情報',
          ),
        ],
      ),
    );
  }
}
