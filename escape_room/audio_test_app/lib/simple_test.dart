import 'package:flutter/material.dart';

void main() {
  runApp(SimpleTestApp());
}

class SimpleTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Test',
      home: Scaffold(
        appBar: AppBar(title: Text('Simple Test App')),
        body: Center(
          child: Text(
            'Hello! This is the audio test app location test.',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}