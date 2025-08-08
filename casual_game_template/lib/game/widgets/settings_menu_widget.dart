import 'package:flutter/material.dart';

class SettingsMenuWidget extends StatelessWidget {
  final void Function(String difficulty)? onDifficultyChanged;
  final void Function()? onClosePressed;
  
  const SettingsMenuWidget({
    super.key,
    this.onDifficultyChanged,
    this.onClosePressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // タイトル
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 40),
          
          // 難易度選択
          Text(
            'Difficulty',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['Easy', 'Default', 'Hard'].map((difficulty) {
              return ElevatedButton(
                onPressed: () => onDifficultyChanged?.call(difficulty.toLowerCase()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  minimumSize: Size(70, 35),
                ),
                child: Text(difficulty),
              );
            }).toList(),
          ),
          
          SizedBox(height: 60),
          
          // 閉じるボタン
          ElevatedButton(
            onPressed: onClosePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: Size(120, 40),
            ),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}