import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../framework/device/device_feedback_manager.dart';
import 'components/background_decoration.dart';
import 'components/game_selection_header.dart';
import 'components/bottom_navigation_bar.dart';
import 'widgets/main_action_button.dart';
import 'managers/game_selection_progress_manager.dart';
import 'managers/game_selection_navigation_manager.dart';
import 'managers/dialog_manager.dart';

class GameSelectionScreen extends ConsumerStatefulWidget {
  const GameSelectionScreen({super.key});

  @override
  ConsumerState<GameSelectionScreen> createState() =>
      _GameSelectionScreenState();
}

class _GameSelectionScreenState extends ConsumerState<GameSelectionScreen>
    with WidgetsBindingObserver {
  late GameSelectionProgressManager _progressManager;
  late GameSelectionNavigationManager _navigationManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _progressManager = GameSelectionProgressManager(
      onProgressChanged: () {
        if (mounted) setState(() {});
      },
    );
    _navigationManager = GameSelectionNavigationManager(
      progressManager: _progressManager,
    );
    _progressManager.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundDecoration(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      const GameSelectionHeader(),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32.0,
                          vertical: 20,
                        ),
                        child: Column(
                          children: [
                            MainActionButton(
                              icon: Icons.play_arrow,
                              text: 'はじめる',
                              subtitle: '',
                              color: Colors.green.shade600,
                              onPressed: () async {
                                DeviceFeedbackManager().gameActionVibrate(
                                  GameAction.buttonTap,
                                );
                                if (_progressManager.hasProgress) {
                                  _showOverwriteWarningDialog();
                                } else {
                                  await _navigationManager.startNewGame(
                                    context,
                                  );
                                }
                              },
                            ),

                            SizedBox(
                              height: MediaQuery.of(context).size.height > 700
                                  ? 16
                                  : 12,
                            ),

                            MainActionButton(
                              icon: Icons.save_alt,
                              text: 'つづきから',
                              subtitle: '',
                              color: _progressManager.hasProgress
                                  ? Colors.blue.shade600
                                  : Colors.grey.shade600,
                              onPressed: _progressManager.hasProgress
                                  ? () async {
                                      DeviceFeedbackManager().gameActionVibrate(
                                        GameAction.buttonTap,
                                      );
                                      await _navigationManager.loadSavedGame(
                                        context,
                                      );
                                    }
                                  : null,
                            ),

                            SizedBox(
                              height: MediaQuery.of(context).size.height > 700
                                  ? 16
                                  : 12,
                            ),

                            MainActionButton(
                              icon: Icons.help_outline,
                              text: 'あそびかた',
                              subtitle: '',
                              color: Colors.orange.shade600,
                              onPressed: () {
                                DeviceFeedbackManager().gameActionVibrate(
                                  GameAction.buttonTap,
                                );
                                DialogManager.showHowToPlayDialog(context);
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

            const GameBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  void _showOverwriteWarningDialog() {
    DialogManager.showOverwriteWarningDialog(
      context,
      onConfirm: () async {
        await _navigationManager.startNewGame(context);
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _progressManager.dispose();
    super.dispose();
  }
}
