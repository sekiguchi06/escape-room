/// A/Bテスト設定を管理するクラス
/// 
/// A/Bテストの基本設定とバリアント情報を保持します。
class ABTestConfig {
  /// テスト名（一意識別子）
  final String testName;
  
  /// テストの説明
  final String description;
  
  /// テストが有効かどうか
  final bool isEnabled;
  
  /// バリアントのリスト
  final List<ABTestVariant> variants;
  
  /// デフォルトバリアント（テスト無効時に使用）
  final String defaultVariant;
  
  /// テスト開始日時（Unix timestamp）
  final int startTime;
  
  /// テスト終了日時（Unix timestamp、nullの場合は無期限）
  final int? endTime;

  const ABTestConfig({
    required this.testName,
    required this.description,
    required this.isEnabled,
    required this.variants,
    required this.defaultVariant,
    required this.startTime,
    this.endTime,
  });

  /// JSONからABTestConfigを作成
  factory ABTestConfig.fromJson(Map<String, dynamic> json) {
    return ABTestConfig(
      testName: json['testName'] as String,
      description: json['description'] as String,
      isEnabled: json['isEnabled'] as bool,
      variants: (json['variants'] as List<dynamic>)
          .map((v) => ABTestVariant.fromJson(v as Map<String, dynamic>))
          .toList(),
      defaultVariant: json['defaultVariant'] as String,
      startTime: json['startTime'] as int,
      endTime: json['endTime'] as int?,
    );
  }

  /// ABTestConfigをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'testName': testName,
      'description': description,
      'isEnabled': isEnabled,
      'variants': variants.map((v) => v.toJson()).toList(),
      'defaultVariant': defaultVariant,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  /// テストが現在有効期間内かどうかを判定
  bool isActive() {
    if (!isEnabled) return false;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // 開始時刻チェック
    if (now < startTime) return false;
    
    // 終了時刻チェック（nullの場合は無期限）
    if (endTime != null && now > endTime!) return false;
    
    return true;
  }

  /// 指定されたバリアント名が存在するかチェック
  bool hasVariant(String variantName) {
    return variants.any((v) => v.name == variantName);
  }

  /// バリアント名でバリアントを取得
  ABTestVariant? getVariant(String variantName) {
    try {
      return variants.firstWhere((v) => v.name == variantName);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'ABTestConfig{testName: $testName, isEnabled: $isEnabled, variants: ${variants.length}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ABTestConfig) return false;
    
    return testName == other.testName &&
           description == other.description &&
           isEnabled == other.isEnabled &&
           defaultVariant == other.defaultVariant &&
           startTime == other.startTime &&
           endTime == other.endTime;
  }

  @override
  int get hashCode {
    return testName.hashCode ^
           description.hashCode ^
           isEnabled.hashCode ^
           defaultVariant.hashCode ^
           startTime.hashCode ^
           (endTime?.hashCode ?? 0);
  }
}

/// A/Bテストのバリアント（実験パターン）を表すクラス
class ABTestVariant {
  /// バリアント名（一意識別子）
  final String name;
  
  /// バリアントの説明
  final String description;
  
  /// 割り当て重み（0-100の整数、全バリアントの合計は100である必要がある）
  final int weight;
  
  /// バリアント固有の設定パラメータ
  final Map<String, dynamic> parameters;

  const ABTestVariant({
    required this.name,
    required this.description,
    required this.weight,
    this.parameters = const {},
  });

  /// JSONからABTestVariantを作成
  factory ABTestVariant.fromJson(Map<String, dynamic> json) {
    return ABTestVariant(
      name: json['name'] as String,
      description: json['description'] as String,
      weight: json['weight'] as int,
      parameters: json['parameters'] as Map<String, dynamic>? ?? {},
    );
  }

  /// ABTestVariantをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'weight': weight,
      'parameters': parameters,
    };
  }

  /// パラメータの値を型安全に取得
  T? getParameter<T>(String key) {
    final value = parameters[key];
    return value is T ? value : null;
  }

  @override
  String toString() {
    return 'ABTestVariant{name: $name, weight: $weight}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ABTestVariant) return false;
    
    return name == other.name &&
           description == other.description &&
           weight == other.weight;
  }

  @override
  int get hashCode {
    return name.hashCode ^ description.hashCode ^ weight.hashCode;
  }
}