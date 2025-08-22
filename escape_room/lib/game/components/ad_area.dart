import 'package:flutter/material.dart';

/// 広告表示エリア
class AdArea extends StatelessWidget {
  const AdArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Center(
        child: Text(
          '📱 広告領域 (320x50)',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
