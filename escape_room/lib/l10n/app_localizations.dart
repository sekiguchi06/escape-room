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

  /// 1st floor indicator label
  ///
  /// In en, this message translates to:
  /// **'1st Floor'**
  String get floor_indicator_1f;

  /// Underground floor indicator label
  ///
  /// In en, this message translates to:
  /// **'Underground'**
  String get floor_indicator_underground;

  /// Floor progress widget title
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get floor_progress_title;

  /// 1st floor progress label
  ///
  /// In en, this message translates to:
  /// **'1st Floor Exploration'**
  String get floor_progress_floor1;

  /// Underground progress label
  ///
  /// In en, this message translates to:
  /// **'Underground Exploration'**
  String get floor_progress_underground;

  /// Final puzzle progress label
  ///
  /// In en, this message translates to:
  /// **'Final Puzzle'**
  String get floor_progress_final;

  /// Transition to underground button
  ///
  /// In en, this message translates to:
  /// **'Go to Underground'**
  String get floor_transition_to_underground;

  /// Transition to 1st floor button
  ///
  /// In en, this message translates to:
  /// **'Return to 1st Floor'**
  String get floor_transition_to_floor1;

  /// Locked floor transition message
  ///
  /// In en, this message translates to:
  /// **'Not yet unlocked'**
  String get floor_transition_locked;

  /// Dark crystal item name
  ///
  /// In en, this message translates to:
  /// **'Dark Crystal'**
  String get item_dark_crystal_name;

  /// Dark crystal item description
  ///
  /// In en, this message translates to:
  /// **'A crystal emitting dark light found deep underground. Seems to have been used in some ritual.'**
  String get item_dark_crystal_description;

  /// Ritual stone item name
  ///
  /// In en, this message translates to:
  /// **'Ritual Stone'**
  String get item_ritual_stone_name;

  /// Ritual stone item description
  ///
  /// In en, this message translates to:
  /// **'A mystical stone that appears to have been used in ancient rituals. It emits a warm glow.'**
  String get item_ritual_stone_description;

  /// Pure water item name
  ///
  /// In en, this message translates to:
  /// **'Pure Water'**
  String get item_pure_water_name;

  /// Pure water item description
  ///
  /// In en, this message translates to:
  /// **'Clear, clean water that springs from underground sources. It might possess sacred power.'**
  String get item_pure_water_description;

  /// Ancient rune item name
  ///
  /// In en, this message translates to:
  /// **'Ancient Rune'**
  String get item_ancient_rune_name;

  /// Ancient rune item description
  ///
  /// In en, this message translates to:
  /// **'An ancient stone tablet with mysterious script carved into it. It contains powerful magical force.'**
  String get item_ancient_rune_description;

  /// Underground key item name
  ///
  /// In en, this message translates to:
  /// **'Underground Key'**
  String get item_underground_key_name;

  /// Underground key item description
  ///
  /// In en, this message translates to:
  /// **'A heavy key discovered deep underground. It seems to be able to open special doors.'**
  String get item_underground_key_description;

  /// Underground master key item name
  ///
  /// In en, this message translates to:
  /// **'Underground Master Key'**
  String get item_underground_master_key_name;

  /// Underground master key item description
  ///
  /// In en, this message translates to:
  /// **'A special key born from the fusion of three powers. It can open doors to the deepest parts of the underground.'**
  String get item_underground_master_key_description;

  /// Underground master key combination message
  ///
  /// In en, this message translates to:
  /// **'Combined the three underground powers to create a special key'**
  String get combination_underground_master_key;

  /// Underground master key combination description
  ///
  /// In en, this message translates to:
  /// **'The powers of the dark crystal, ritual stone, and pure water have fused to complete the underground master key.'**
  String get combination_underground_master_key_description;
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
