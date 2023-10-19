import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:suraasa_flutter_lint/rules/suraasa_page_route_lint.dart';

PluginBase createPlugin() => _SuraasaLinter();

class _SuraasaLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        SuraasaPageRouteLint(),
      ];
}
