import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

bool _filterNode(InstanceCreationExpression node) {
  final elementName = node.staticType?.element?.name;

  return elementName == "MaterialPageRoute" ||
      elementName == "CupertinoPageRoute";
}

class SuraasaPageRouteLint extends DartLintRule {
  SuraasaPageRouteLint() : super(code: _code);

  /// Metadata about the warning that will show-up in the IDE.
  /// This is used for `// ignore: code` and enabling/disabling the lint
  static const _code = LintCode(
    name: 'suraasa_page_route_lint',
    problemMessage:
        'Not using SuraasaPageRoute interferes with screen name tracking.',
    correctionMessage:
        'Use SuraasaPageRoute instead of MaterialPageRoute or CupertinoPageRoute.',
    errorSeverity: ErrorSeverity.ERROR,
    uniqueName: 'suraasa_page_route_lint',
    url:
        'https://github.com/les-transformations/suraasa_flutter_lint/README.md',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      if (_filterNode(node)) {
        reporter.reportErrorForNode(
          _code,
          node,
        );
      }
    });
  }

  @override
  List<Fix> getFixes() {
    return [SuraasaPageRouteFix()];
  }
}

class SuraasaPageRouteFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      if (!node.sourceRange.intersects(analysisError.sourceRange)) return;

      if (_filterNode(node)) {
        final changeBuilder = reporter.createChangeBuilder(
          message: 'Use SuraasaPageRoute',
          priority: 80,
        );

        changeBuilder.addDartFileEdit((builder) {
          final lastArgument = node.argumentList.arguments.lastOrNull;

          final insertAt = lastArgument?.end ?? node.end;

          builder.addSimpleReplacement(
            node.constructorName.sourceRange,
            'SuraasaPageRoute',
          );
          final Expression? builderArgument =
              node.argumentList.arguments.firstWhere(
            (element) {
              return element.toString().startsWith('builder:');
            },
            orElse: null,
          );

          if (builderArgument != null) {
            final fn = builderArgument.childEntities.lastOrNull;
            if (fn != null) {
              final String? widgetName = fn
                  .toString()
                  .split('(')
                  .firstWhere((element) => element.contains(')'), orElse: null)
                  .split(')')
                  .last
                  .split(' ')
                  .last
                  .replaceAll(RegExp('[^A-Za-z0-9]'), '');

              builder.addSimpleInsertion(
                insertAt,
                ', screenName: $widgetName.screenName',
              );
            }
          } else {
            builder.addSimpleInsertion(
              insertAt,
              ', screenName: Widget.screenName',
            );
          }
        });
      }
    });
  }
}
