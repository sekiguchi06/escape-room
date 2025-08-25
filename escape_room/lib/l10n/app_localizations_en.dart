// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Escape Master';

  @override
  String get appSubtitle => 'Ultimate Escape Puzzle Game';

  @override
  String get buttonStart => 'Start';

  @override
  String get buttonContinue => 'Continue';

  @override
  String get buttonHowToPlay => 'How to Play';

  @override
  String get settings => 'Settings';

  @override
  String get buttonClose => 'Close';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonConfirm => 'Confirm';

  @override
  String get back => 'Back';

  @override
  String get gameStartNewGame => 'Start New Game';

  @override
  String get gameOverwriteWarning =>
      'Starting a new game will delete current progress. Do you want to continue?';

  @override
  String get gameDeleteProgressConfirm => 'Delete Progress and Start';

  @override
  String get gameOver => 'Game Over';

  @override
  String get clear => 'Clear!';

  @override
  String get play => 'Play';

  @override
  String get restart => 'Restart';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get menu => 'Menu';

  @override
  String get score => 'Score';

  @override
  String get timeRemaining => 'Time Remaining';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get tooltipVolumeSettings => 'Volume settings';

  @override
  String get tooltipRanking => 'Ranking';

  @override
  String get tooltipAchievements => 'Achievements';

  @override
  String get tooltipSettings => 'Settings';

  @override
  String get tooltipAppInfo => 'App info';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsVibration => 'Vibration';

  @override
  String get settingsVibrationDesc => 'Haptic feedback on tap';

  @override
  String get settingsPushNotification => 'Push Notifications';

  @override
  String get settingsPushNotificationDesc =>
      'Game updates and hint notifications';

  @override
  String get settingsAutoSave => 'Auto Save';

  @override
  String get settingsAutoSaveDesc => 'Automatic progress saving';

  @override
  String get volumeTitle => 'Volume Settings';

  @override
  String get volumeBgm => 'BGM Volume';

  @override
  String get volumeSfx => 'Sound Effects Volume';

  @override
  String get volumeMuted => 'Muted';

  @override
  String get volumeReset => 'Reset';

  @override
  String get volumeTest => 'Test';

  @override
  String get errorLoadSaveData => 'Failed to load save data';

  @override
  String errorOccurred(String error) {
    return 'An error occurred: $error';
  }

  @override
  String messageNotImplemented(String feature) {
    return '$feature feature (coming soon)';
  }

  @override
  String get floor_indicator_1f => '1st Floor';

  @override
  String get floor_indicator_underground => 'Underground';

  @override
  String get floor_progress_title => 'Progress';

  @override
  String get floor_progress_floor1 => '1st Floor Exploration';

  @override
  String get floor_progress_underground => 'Underground Exploration';

  @override
  String get floor_progress_final => 'Final Puzzle';

  @override
  String get floor_transition_to_underground => 'Go to Underground';

  @override
  String get floor_transition_to_floor1 => 'Return to 1st Floor';

  @override
  String get floor_transition_locked => 'Not yet unlocked';

  @override
  String get item_dark_crystal_name => 'Dark Crystal';

  @override
  String get item_dark_crystal_description =>
      'A crystal emitting dark light found deep underground. Seems to have been used in some ritual.';

  @override
  String get item_ritual_stone_name => 'Ritual Stone';

  @override
  String get item_ritual_stone_description =>
      'A mystical stone that appears to have been used in ancient rituals. It emits a warm glow.';

  @override
  String get item_pure_water_name => 'Pure Water';

  @override
  String get item_pure_water_description =>
      'Clear, clean water that springs from underground sources. It might possess sacred power.';

  @override
  String get item_ancient_rune_name => 'Ancient Rune';

  @override
  String get item_ancient_rune_description =>
      'An ancient stone tablet with mysterious script carved into it. It contains powerful magical force.';

  @override
  String get item_underground_key_name => 'Underground Key';

  @override
  String get item_underground_key_description =>
      'A heavy key discovered deep underground. It seems to be able to open special doors.';

  @override
  String get item_underground_master_key_name => 'Underground Master Key';

  @override
  String get item_underground_master_key_description =>
      'A special key born from the fusion of three powers. It can open doors to the deepest parts of the underground.';

  @override
  String get combination_underground_master_key =>
      'Combined the three underground powers to create a special key';

  @override
  String get combination_underground_master_key_description =>
      'The powers of the dark crystal, ritual stone, and pure water have fused to complete the underground master key.';
}
