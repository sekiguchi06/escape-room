import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../widgets/circular_icon_button.dart';
import '../managers/dialog_manager.dart';
import '../../../screens/debug/audio_debug_screen.dart';

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

          // デバッグモードでのみ表示
          if (kDebugMode)
            CircularIconButton(
              icon: Icons.audio_file,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AudioDebugScreen(),
                  ),
                );
              },
              tooltip: '音響テスト (デバッグ)',
            ),


        ],
      ),
    );
  }
}
