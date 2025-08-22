import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'string_operations.dart';

/// 複雑データ操作の専用クラス
class FlutterComplexDataOperations {
  final FlutterStringOperations _stringOps;

  FlutterComplexDataOperations(this._stringOps);

  /// JSONオブジェクト保存
  Future<bool> saveJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await _stringOps.saveString(key, jsonString);
    } catch (e) {
      debugPrint('❌ Failed to encode JSON for $key: $e');
      return false;
    }
  }

  /// JSONオブジェクト読み込み
  Map<String, dynamic>? loadJson(
    String key, {
    Map<String, dynamic>? defaultValue,
  }) {
    try {
      final jsonString = _stringOps.loadString(key);
      if (jsonString == null) return defaultValue;

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Failed to decode JSON for $key: $e');
      return defaultValue;
    }
  }
}
