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

  @override
  String get floor_indicator_1f => '1階';

  @override
  String get floor_indicator_underground => '地下';

  @override
  String get floor_progress_title => '進行状況';

  @override
  String get floor_progress_floor1 => '1階探索';

  @override
  String get floor_progress_underground => '地下探索';

  @override
  String get floor_progress_final => '最終謎';

  @override
  String get floor_transition_to_underground => '地下へ降りる';

  @override
  String get floor_transition_to_floor1 => '1階へ戻る';

  @override
  String get floor_transition_locked => 'まだ開放されていません';

  @override
  String get item_dark_crystal_name => '闇のクリスタル';

  @override
  String get item_dark_crystal_description =>
      '地下深くで見つけた暗い光を放つクリスタル。何かの儀式に使われていたようだ。';

  @override
  String get item_ritual_stone_name => '儀式の石';

  @override
  String get item_ritual_stone_description =>
      '古代の儀式に使われていたと思われる神秘的な石。温かみのある光を放っている。';

  @override
  String get item_pure_water_name => '清浄な水';

  @override
  String get item_pure_water_description =>
      '地下水源から湧き出る透明で清らかな水。神聖な力を持っているかもしれない。';

  @override
  String get item_ancient_rune_name => '古代ルーン';

  @override
  String get item_ancient_rune_description => '謎めいた文字が刻まれた古代の石版。強い魔法の力を秘めている。';

  @override
  String get item_underground_key_name => '地下の鍵';

  @override
  String get item_underground_key_description =>
      '地下の奥深くで発見された重厚な鍵。特別な扉を開けることができそうだ。';

  @override
  String get item_underground_master_key_name => '地下マスターキー';

  @override
  String get item_underground_master_key_description =>
      '3つの力が融合して生まれた特別な鍵。地下の最深部へ続く扉を開けられる。';

  @override
  String get combination_underground_master_key => '地下の3つの力を統合して特別な鍵を作成した';

  @override
  String get combination_underground_master_key_description =>
      '闇のクリスタル、儀式の石、清浄な水の力が融合し、地下マスターキーが完成した。';
}
