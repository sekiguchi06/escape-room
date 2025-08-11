import 'package:flutter/material.dart';
import 'custom_game_ui.dart';

/// スタート画面用のカスタムUI
class CustomStartUI extends StatelessWidget {
  final VoidCallback? onStartPressed;
  final VoidCallback? onSettingsPressed;
  final String title;

  const CustomStartUI({
    super.key,
    this.onStartPressed,
    this.onSettingsPressed,
    this.title = 'Simple Game',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade900,
            Colors.purple.shade900,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // タイトル
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: 0,
            right: 0,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          
          // スタートボタン
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.3,
            left: 0,
            right: 0,
            child: Center(
              child: CustomActionButton(
                icon: Icons.play_arrow,
                onPressed: onStartPressed,
                color: Colors.green.shade600,
              ),
            ),
          ),
          
          // 設定ボタン
          Positioned(
            top: 60,
            right: 20,
            child: CustomActionButton(
              icon: Icons.settings,
              onPressed: onSettingsPressed,
              color: Colors.grey.shade600,
            ),
          ),
          
          // スタートボタンのラベル
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.25,
            left: 0,
            right: 0,
            child: const Text(
              'START GAME',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}