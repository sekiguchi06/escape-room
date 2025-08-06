import 'package:flutter/material.dart';

class SettingsMenuWidget extends StatelessWidget {
  final void Function(String difficulty)? onDifficultyChanged;
  final void Function()? onClosePressed;
  
  const SettingsMenuWidget({
    Key? key,
    this.onDifficultyChanged,
    this.onClosePressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
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
                child: Text(difficulty),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  minimumSize: Size(70, 35),
                ),
              );
            }).toList(),
          ),
          
          SizedBox(height: 60),
          
          // 閉じるボタン
          ElevatedButton(
            onPressed: onClosePressed,
            child: Text('Close'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: Size(120, 40),
            ),
          ),
        ],
      ),
    );
  }
}