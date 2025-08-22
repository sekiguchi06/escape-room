/// アプリケーション統一設定管理システム
///
/// このファイルは全ての設定項目を一元管理し、
/// ビルド時・実行時の設定値を提供します。
library;

import 'package:flutter/foundation.dart';

/// 使用方法:
/// ```dart
/// final config = AppConfig.instance;
/// String appName = config.appName;
/// String packageName = config.packageName;
/// ```

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  static AppConfig get instance => _instance;

  AppConfig._internal();

  // ========================================
  // アプリ基本情報
  // ========================================

  /// アプリ名（表示用）
  /// TODO: 最終決定が必要
  String get appName => '未定アプリ名';

  /// アプリ名（英語）
  /// TODO: ASO最適化を考慮して決定
  String get appNameEn => 'TBD App Name';

  /// アプリ副題・キャッチフレーズ
  /// TODO: マーケティング効果を考慮して作成
  String get appSubtitle => '究極の脱出パズルゲーム';

  /// アプリ副題（英語）
  String get appSubtitleEn => 'Ultimate Escape Puzzle Game';

  /// 開発者名
  /// TODO: 公開時の開発者名を決定
  String get developerName => '未定開発者名';

  /// 会社名
  /// TODO: パッケージ名にも影響するため重要
  String get companyName => '未定会社名';

  /// アプリバージョン
  String get versionName => '1.0.0';

  /// ビルド番号
  int get versionCode => 1;

  // ========================================
  // パッケージ・Bundle ID
  // ========================================

  /// Android Package Name
  /// TODO: 決定後は変更不可のため慎重に決定
  /// 形式: com.{company}.{appname}
  String get androidPackageName => 'com.example.escape_room'; // TEMPORARY

  /// iOS Bundle ID
  /// TODO: Androidと統一推奨
  String get iosBundleId => 'com.example.escapeRoom'; // TEMPORARY

  /// ドメイン形式の会社識別子
  /// TODO: 実際のドメインまたは一意の識別子
  String get companyDomain => 'example.com'; // TEMPORARY

  // ========================================
  // アプリストア・ASO設定
  // ========================================

  /// アプリカテゴリ
  String get appCategory => 'ゲーム/パズル';

  /// 対象年齢
  String get targetAudience => '13+';

  /// コンテンツレーティング
  String get contentRating => 'Everyone';

  /// 主要キーワード（ASO最適化用）
  List<String> get primaryKeywords => [
    '脱出ゲーム',
    'パズル',
    '謎解き',
    'アドベンチャー',
    'ブレインティーザー',
  ];

  /// 副次キーワード
  List<String> get secondaryKeywords => [
    '思考力',
    '推理',
    '探索',
    'アイテム',
    'ルーム',
    '暇つぶし',
    '頭の体操',
  ];

  /// 短い説明文（80文字以内）
  /// TODO: ASO最適化を考慮して作成
  String get shortDescription => 'まだ決まっていない短い説明文です。80文字以内でキーワードを含める必要があります。';

  /// 詳細説明文
  /// TODO: 魅力的で検索最適化された説明文を作成
  String get longDescription => '''
まだ決まっていない詳細説明文です。

【ゲームの特徴】
・直感的な操作で楽しめる謎解きパズル
・美しいグラフィックと没入感のあるサウンド
・段階的な難易度で初心者から上級者まで楽しめる
・ヒントシステムで詰まっても安心

【対象ユーザー】
・パズルゲームが好きな方
・謎解きや推理が好きな方
・暇つぶしのゲームを探している方
・頭の体操をしたい方

この説明文は実際の決定時に詳細に作成する必要があります。
''';

  // ========================================
  // ブランディング・デザイン
  // ========================================

  /// メインブランドカラー
  /// TODO: ブランドアイデンティティに基づいて決定
  String get primaryColor => '#2196F3'; // TEMPORARY

  /// セカンダリカラー
  String get secondaryColor => '#FFC107'; // TEMPORARY

  /// アクセントカラー
  String get accentColor => '#FF5722'; // TEMPORARY

  /// アプリアイコンのコンセプト
  /// TODO: デザイナーと相談して決定
  String get iconConcept => '未定：鍵、パズルピース、部屋のドアなどを検討中';

  // ========================================
  // Firebase設定
  // ========================================

  /// Firebase プロジェクト ID
  String get firebaseProjectId => 'escape-room-001-e5996';

  /// Firebase プロジェクト名
  String get firebaseProjectName => 'escape-room-001';

  /// Firebase Android App ID
  String get firebaseAndroidAppId =>
      '1:860949363241:android:080fe469b02e1d11ffba38';

  /// Firebase iOS App ID
  String get firebaseIosAppId => '1:860949363241:ios:89b2e182884c8327ffba38';

  // ========================================
  // AdMob設定
  // ========================================

  /// AdMob Android App ID
  /// TODO: AdMobアカウント作成後に取得・設定
  String get admobAndroidAppId =>
      'ca-app-pub-3940256099942544~3347511713'; // TEST ID

  /// AdMob iOS App ID
  /// TODO: AdMobアカウント作成後に取得・設定
  String get admobIosAppId =>
      'ca-app-pub-3940256099942544~1458002511'; // TEST ID

  /// バナー広告ユニットID (Android)
  /// TODO: AdMob設定後に実際のIDに変更
  String get bannerAdUnitIdAndroid =>
      'ca-app-pub-3940256099942544/6300978111'; // TEST ID

  /// バナー広告ユニットID (iOS)
  String get bannerAdUnitIdIos =>
      'ca-app-pub-3940256099942544/2934735716'; // TEST ID

  /// インタースティシャル広告ユニットID (Android)
  String get interstitialAdUnitIdAndroid =>
      'ca-app-pub-3940256099942544/1033173712'; // TEST ID

  /// インタースティシャル広告ユニットID (iOS)
  String get interstitialAdUnitIdIos =>
      'ca-app-pub-3940256099942544/4411468910'; // TEST ID

  /// リワード広告ユニットID (Android)
  String get rewardedAdUnitIdAndroid =>
      'ca-app-pub-3940256099942544/5224354917'; // TEST ID

  /// リワード広告ユニットID (iOS)
  String get rewardedAdUnitIdIos =>
      'ca-app-pub-3940256099942544/1712485313'; // TEST ID

  // ========================================
  // 国際化・ローカライゼーション戦略
  // ========================================

  /// メイン言語
  String get primaryLanguage => 'ja';

  /// フェーズ1: 即実装対応言語（英語UI対応）
  List<String> get phase1Languages => ['ja', 'en'];

  /// フェーズ2: アジア市場対応言語（収益確認後）
  List<String> get phase2Languages => ['ko', 'zh-CN'];

  /// フェーズ3: グローバル展開言語（本格国際化）
  List<String> get phase3Languages => ['fr', 'de', 'es', 'th', 'vi'];

  /// 現在サポート中の言語（段階的に拡張）
  List<String> get supportedLanguages => phase1Languages;

  /// 国際化戦略フェーズ
  String get currentInternationalizationPhase => 'phase1';

  /// テキスト多言語化の深度
  Map<String, String> get textLocalizationDepth => {
    'phase1': 'ui_only', // UI要素のみ
    'phase2': 'story_basic', // 基本ストーリー
    'phase3': 'full_immersion', // 完全没入体験
  };

  /// ビジュアル国際化設定
  Map<String, String> get visualLocalizationConfig => {
    'icons': 'universal', // 普遍的アイコン使用
    'text_in_images': 'minimal', // 画像内テキスト最小化
    'cultural_symbols': 'neutral', // 文化的中立性
  };

  /// フェーズ移行条件
  Map<String, Map<String, dynamic>> get phaseTransitionCriteria => {
    'phase1_to_phase2': {
      'monthly_downloads': 10000,
      'revenue_stability': '3ヶ月連続黒字',
      'user_retention': 0.3,
    },
    'phase2_to_phase3': {
      'overseas_monthly_revenue': 1000000, // 100万円
      'supported_countries': 3,
      'localization_roi': 3.0,
    },
  };

  // ========================================
  // 開発・デバッグ設定
  // ========================================

  /// デバッグモード
  bool get isDebugMode => true; // TODO: リリース時はfalse

  /// テスト広告を使用するか
  bool get useTestAds => true; // TODO: リリース時はfalse

  /// Firebase Analytics を有効にするか
  bool get enableAnalytics => true;

  /// クラッシュレポートを有効にするか
  bool get enableCrashlytics => true;

  // ========================================
  // URL・リンク設定
  // ========================================

  /// プライバシーポリシーURL
  /// TODO: 実際のURLに変更
  String get privacyPolicyUrl => 'https://example.com/privacy';

  /// 利用規約URL
  /// TODO: 実際のURLに変更
  String get termsOfServiceUrl => 'https://example.com/terms';

  /// サポートURL・問い合わせ先
  /// TODO: 実際のサポート体制に応じて設定
  String get supportUrl => 'https://example.com/support';

  /// 公式サイトURL
  /// TODO: 公式サイト作成時に設定
  String get officialWebsiteUrl => 'https://example.com';

  // ========================================
  // ユーティリティメソッド
  // ========================================

  /// 現在のプラットフォーム用AdMob App IDを取得
  String getCurrentPlatformAdMobAppId() {
    // プラットフォーム判定ロジックは実装時に追加
    return admobAndroidAppId; // TEMPORARY
  }

  /// プラットフォーム別パッケージ名/Bundle IDを取得
  String getCurrentPlatformPackageName() {
    // プラットフォーム判定ロジックは実装時に追加
    return androidPackageName; // TEMPORARY
  }

  /// 設定完了状況をチェック
  Map<String, bool> getConfigurationStatus() {
    return {
      'アプリ名決定済み': appName != '未定アプリ名',
      '開発者名決定済み': developerName != '未定開発者名',
      'パッケージ名設定済み': !androidPackageName.contains('example'),
      'AdMob ID設定済み': !admobAndroidAppId.contains('3940256099942544'),
      'URL設定済み': !privacyPolicyUrl.contains('example.com'),
      'ブランドカラー決定済み': primaryColor != '#2196F3',
      '英語UI対応済み': supportedLanguages.contains('en'),
      '国際化戦略確定済み': currentInternationalizationPhase.isNotEmpty,
    };
  }

  /// 国際化フェーズの進行状況をチェック
  Map<String, dynamic> getInternationalizationStatus() {
    return {
      'current_phase': currentInternationalizationPhase,
      'supported_languages_count': supportedLanguages.length,
      'phase1_ready': supportedLanguages.contains('en'),
      'phase2_criteria_met': false, // 実際の指標で判定
      'phase3_criteria_met': false, // 実際の指標で判定
      'recommended_next_languages': _getRecommendedNextLanguages(),
    };
  }

  /// 次に対応すべき言語を推奨
  List<String> _getRecommendedNextLanguages() {
    switch (currentInternationalizationPhase) {
      case 'phase1':
        return phase2Languages;
      case 'phase2':
        return phase3Languages;
      default:
        return [];
    }
  }

  /// 未完了設定項目を取得
  List<String> getIncompleteSettings() {
    final status = getConfigurationStatus();
    return status.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  /// デバッグ情報を出力
  void printDebugInfo() {
    debugPrint('=== App Configuration Debug Info ===');
    debugPrint('App Name: $appName');
    debugPrint('Package Name: $androidPackageName');
    debugPrint('Firebase Project: $firebaseProjectId');
    debugPrint('AdMob App ID: $admobAndroidAppId');
    debugPrint('Internationalization Phase: $currentInternationalizationPhase');
    debugPrint('Supported Languages: $supportedLanguages');
    debugPrint('Incomplete Settings: ${getIncompleteSettings()}');
    debugPrint('=====================================');
  }

  /// 国際化戦略の詳細情報を出力
  void printInternationalizationInfo() {
    debugPrint('=== Internationalization Strategy Info ===');
    debugPrint('Current Phase: $currentInternationalizationPhase');
    debugPrint('Supported Languages: $supportedLanguages');
    debugPrint('Phase 1 Languages: $phase1Languages');
    debugPrint('Phase 2 Languages: $phase2Languages');
    debugPrint('Phase 3 Languages: $phase3Languages');
    debugPrint('Recommended Next: ${_getRecommendedNextLanguages()}');
    debugPrint(
      'Localization Depth: ${textLocalizationDepth[currentInternationalizationPhase]}',
    );
    debugPrint('Visual Config: $visualLocalizationConfig');
    debugPrint('=========================================');
  }
}

/// アプリ設定へのショートカットアクセス
AppConfig get appConfig => AppConfig.instance;
