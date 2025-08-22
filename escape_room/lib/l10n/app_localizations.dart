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

  /// Main app title displayed in UI
  ///
  /// In en, this message translates to:
  /// **'Escape Master'**
  String get appTitle;

  /// App tagline/subtitle
  ///
  /// In en, this message translates to:
  /// **'Ultimate Escape Puzzle Game'**
  String get appSubtitle;

  /// Start new game button
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get buttonStart;

  /// Continue saved game button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get buttonContinue;

  /// How to play instructions button
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get buttonHowToPlay;

  /// Settings button
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Close dialog button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get buttonClose;

  /// Cancel action button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// Confirm action button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get buttonConfirm;

  /// Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// New game confirmation option
  ///
  /// In en, this message translates to:
  /// **'Start New Game'**
  String get gameStartNewGame;

  /// Warning when overwriting saved progress
  ///
  /// In en, this message translates to:
  /// **'Starting a new game will delete current progress. Do you want to continue?'**
  String get gameOverwriteWarning;

  /// Confirm button to delete progress and start new game
  ///
  /// In en, this message translates to:
  /// **'Delete Progress and Start'**
  String get gameDeleteProgressConfirm;

  /// Game over message
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOver;

  /// Game clear message
  ///
  /// In en, this message translates to:
  /// **'Clear!'**
  String get clear;

  /// Play button
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// Restart button
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// Pause button
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Resume button
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// Menu button
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// Score display
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// Time remaining display
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get timeRemaining;

  /// Count of items with proper plural support
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String itemsCount(int count);

  /// Volume settings button tooltip
  ///
  /// In en, this message translates to:
  /// **'Volume settings'**
  String get tooltipVolumeSettings;

  /// Ranking button tooltip
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get tooltipRanking;

  /// Achievements button tooltip
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get tooltipAchievements;

  /// Settings button tooltip
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tooltipSettings;

  /// App info button tooltip
  ///
  /// In en, this message translates to:
  /// **'App info'**
  String get tooltipAppInfo;

  /// Settings dialog title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Vibration setting label
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settingsVibration;

  /// Vibration setting description
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback on tap'**
  String get settingsVibrationDesc;

  /// Push notification setting label
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get settingsPushNotification;

  /// Push notification setting description
  ///
  /// In en, this message translates to:
  /// **'Game updates and hint notifications'**
  String get settingsPushNotificationDesc;

  /// Auto save setting label
  ///
  /// In en, this message translates to:
  /// **'Auto Save'**
  String get settingsAutoSave;

  /// Auto save setting description
  ///
  /// In en, this message translates to:
  /// **'Automatic progress saving'**
  String get settingsAutoSaveDesc;

  /// Volume settings dialog title
  ///
  /// In en, this message translates to:
  /// **'Volume Settings'**
  String get volumeTitle;

  /// Background music volume label
  ///
  /// In en, this message translates to:
  /// **'BGM Volume'**
  String get volumeBgm;

  /// Sound effects volume label
  ///
  /// In en, this message translates to:
  /// **'Sound Effects Volume'**
  String get volumeSfx;

  /// Muted status label
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get volumeMuted;

  /// Reset volume settings button
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get volumeReset;

  /// Test sound button
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get volumeTest;

  /// Error message when save data loading fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load save data'**
  String get errorLoadSaveData;

  /// Generic error message with placeholder
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String errorOccurred(String error);

  /// Not implemented feature message
  ///
  /// In en, this message translates to:
  /// **'{feature} feature (coming soon)'**
  String messageNotImplemented(String feature);
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
