import 'package:flutter/material.dart';

import '../../framework/device/device_feedback_manager.dart';
import '../../framework/audio/audio_service.dart';
import '../../game/screens/widgets/main_action_button.dart';
import '../../game/screens/managers/game_selection_progress_manager.dart';
import '../../game/screens/managers/game_selection_navigation_manager.dart';
import '../../game/screens/managers/dialog_manager.dart';

class MainActionButtonList extends StatelessWidget {
  final GameSelectionProgressManager progressManager;
  final GameSelectionNavigationManager navigationManager;
  final BuildContext context;

  const MainActionButtonList({
    super.key,
    required this.progressManager,
    required this.navigationManager,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 32.0,
        vertical: 20,
      ),
      child: Column(
        children: [
          _buildStartButton(),
          _buildSpacing(),
          _buildContinueButton(),
          _buildSpacing(),
          _buildHowToPlayButton(),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return MainActionButton(
      icon: Icons.play_arrow,
      text: 'はじめる',
      subtitle: '',
      color: Colors.green.shade600,
      onPressed: () async {
        // 音響効果・触覚フィードバック
        AudioService().playUI(AudioAssets.decisionButton);
        DeviceFeedbackManager().gameActionVibrate(GameAction.buttonTap);
        
        if (progressManager.hasProgress) {
          _showOverwriteWarningDialog();
        } else {
          await navigationManager.startNewGame(context);
        }
      },
    );
  }

  Widget _buildContinueButton() {
    return MainActionButton(
      icon: Icons.save_alt,
      text: 'つづきから',
      subtitle: '',
      color: progressManager.hasProgress
          ? Colors.blue.shade600
          : Colors.grey.shade600,
      onPressed: progressManager.hasProgress
          ? () async {
              // 音響効果・触覚フィードバック
              AudioService().playUI(AudioAssets.decisionButton);
              DeviceFeedbackManager().gameActionVibrate(GameAction.buttonTap);
              
              await navigationManager.loadSavedGame(context);
            }
          : null,
    );
  }

  Widget _buildHowToPlayButton() {
    return MainActionButton(
      icon: Icons.help_outline,
      text: 'あそびかた',
      subtitle: '',
      color: Colors.orange.shade600,
      onPressed: () {
        // 音響効果・触覚フィードバック
        AudioService().playUI(AudioAssets.buttonPress);
        DeviceFeedbackManager().gameActionVibrate(GameAction.buttonTap);
        
        DialogManager.showHowToPlayDialog(context);
      },
    );
  }

  Widget _buildSpacing() {
    return SizedBox(
      height: MediaQuery.of(context).size.height > 700 ? 16 : 12,
    );
  }

  void _showOverwriteWarningDialog() {
    DialogManager.showOverwriteWarningDialog(
      context,
      onConfirm: () async {
        await navigationManager.startNewGame(context);
      },
    );
  }
}