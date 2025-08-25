// escape-room専用カスタムlintルール定義
import 'package:custom_lint_builder/custom_lint_builder.dart';

// import 'file_line_count_rule.dart'; // 一時的に無効化

/// escape-roomプロジェクト専用のカスタムlintルール
PluginBase createPlugin() => _EscapeRoomLintPlugin();

class _EscapeRoomLintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    // 200行制限ルール（一時的に無効化）
    // const FileLineCountRule(),
  ];
}