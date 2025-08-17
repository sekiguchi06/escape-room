import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// アプリケーションのタイトル
  ///
  /// In ja, this message translates to:
  /// **'カジュアルゲームテンプレート'**
  String get appTitle;

  /// 脱出ゲームボタンのタイトル
  ///
  /// In ja, this message translates to:
  /// **'🔓 脱出ゲームをプレイ'**
  String get escapeGameTitle;

  /// タップファイアゲームボタン
  ///
  /// In ja, this message translates to:
  /// **'Tap Fire Gameをプレイ'**
  String get playTapFireGame;

  /// シンプルゲームボタン
  ///
  /// In ja, this message translates to:
  /// **'Simple Gameをプレイ'**
  String get playSimpleGame;

  /// タップシューターボタン
  ///
  /// In ja, this message translates to:
  /// **'Simple Tap Shooterをプレイ'**
  String get playTapShooter;

  /// ゲーム終了メッセージ
  ///
  /// In ja, this message translates to:
  /// **'ゲームオーバー'**
  String get gameOver;

  /// ゲームクリアメッセージ
  ///
  /// In ja, this message translates to:
  /// **'クリア！'**
  String get clear;

  /// プレイボタン
  ///
  /// In ja, this message translates to:
  /// **'プレイ'**
  String get play;

  /// 設定ボタン
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get settings;

  /// 戻るボタン
  ///
  /// In ja, this message translates to:
  /// **'戻る'**
  String get back;

  /// リスタートボタン
  ///
  /// In ja, this message translates to:
  /// **'リスタート'**
  String get restart;

  /// 一時停止ボタン
  ///
  /// In ja, this message translates to:
  /// **'一時停止'**
  String get pause;

  /// 再開ボタン
  ///
  /// In ja, this message translates to:
  /// **'再開'**
  String get resume;

  /// メニューボタン
  ///
  /// In ja, this message translates to:
  /// **'メニュー'**
  String get menu;

  /// スコア表示
  ///
  /// In ja, this message translates to:
  /// **'スコア'**
  String get score;

  /// 残り時間表示
  ///
  /// In ja, this message translates to:
  /// **'残り時間'**
  String get timeRemaining;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
