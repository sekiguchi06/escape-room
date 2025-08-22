// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Escape Master';

  @override
  String get appSubtitle => '究極の脱出パズルゲーム';

  @override
  String get buttonStart => 'はじめる';

  @override
  String get buttonContinue => 'つづきから';

  @override
  String get buttonHowToPlay => 'あそびかた';

  @override
  String get settings => '設定';

  @override
  String get buttonClose => '閉じる';

  @override
  String get buttonCancel => 'キャンセル';

  @override
  String get buttonConfirm => '確認';

  @override
  String get back => '戻る';

  @override
  String get gameStartNewGame => '新しいゲームを開始';

  @override
  String get gameOverwriteWarning => '新しいゲームを開始すると、現在の進行状況が削除されます。続けますか？';

  @override
  String get gameDeleteProgressConfirm => 'データを削除して開始';

  @override
  String get gameOver => 'ゲームオーバー';

  @override
  String get clear => 'クリア！';

  @override
  String get play => 'プレイ';

  @override
  String get restart => 'リスタート';

  @override
  String get pause => '一時停止';

  @override
  String get resume => '再開';

  @override
  String get menu => 'メニュー';

  @override
  String get score => 'スコア';

  @override
  String get timeRemaining => '残り時間';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count個のアイテム',
      one: '1個のアイテム',
      zero: 'アイテムなし',
    );
    return '$_temp0';
  }

  @override
  String get tooltipVolumeSettings => '音量設定';

  @override
  String get tooltipRanking => 'ランキング';

  @override
  String get tooltipAchievements => '実績';

  @override
  String get tooltipSettings => '設定';

  @override
  String get tooltipAppInfo => 'アプリ情報';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsVibration => 'バイブレーション';

  @override
  String get settingsVibrationDesc => 'タップ時の振動フィードバック';

  @override
  String get settingsPushNotification => 'プッシュ通知';

  @override
  String get settingsPushNotificationDesc => 'ゲーム更新やヒントの通知';

  @override
  String get settingsAutoSave => '自動セーブ';

  @override
  String get settingsAutoSaveDesc => '進行状況の自動保存';

  @override
  String get volumeTitle => '音量設定';

  @override
  String get volumeBgm => 'BGM音量';

  @override
  String get volumeSfx => '効果音音量';

  @override
  String get volumeMuted => 'ミュート中';

  @override
  String get volumeReset => 'リセット';

  @override
  String get volumeTest => 'テスト';

  @override
  String get errorLoadSaveData => 'セーブデータの読み込みに失敗しました';

  @override
  String errorOccurred(String error) {
    return 'エラーが発生しました: $error';
  }

  @override
  String messageNotImplemented(String feature) {
    return '$feature機能（実装予定）';
  }
}
