// TODO: 200行制限のカスタムlintルール（一時的に無効化）
// Custom lint APIの互換性問題により一時的にコメントアウト

/*
import 'package:analyzer/dart/ast/ast.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class FileLineCountRule extends DartLintRule {
  const FileLineCountRule() : super(code: _code);

  static const _code = LintCode(
    name: 'file_line_count_limit',
    problemMessage: 'File has more than 200 lines ({0} lines). '
        'Consider breaking this file into smaller, more focused files.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    CustomLintReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((node) {
      final source = resolver.source;
      final content = source.contents.data;
      final lines = content.split('\n');
      final lineCount = lines.length;

      // 200行を超える場合にワーニングを出力
      if (lineCount > 200) {
        reporter.reportErrorForNode(
          _code,
          node,
          ['$lineCount'],
        );
      }
    });
  }
}
*/