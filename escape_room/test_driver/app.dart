import 'package:flutter_driver/driver_extension.dart';
import 'package:casual_game_template/main.dart' as app;

void main() {
  // Flutter Driver統合の有効化
  enableFlutterDriverExtension();
  
  // アプリケーションの開始
  app.main();
}