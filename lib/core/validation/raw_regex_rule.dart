import '../models/survey/validation_model.dart';
import 'rule.dart';

/// Tier-3 dispatch fallback. Executes whatever regex the backend sent for
/// an unknown-to-the-registry rule. Performs `{key}` placeholder substitution
/// using [Validation.validation] and the `qv.values` map supplied at validate
/// time. Uses the backend's arContent/enContent verbatim as the error message.
class RawRegexRule extends Rule {
  RawRegexRule(this._source);

  final Validation _source;

  @override
  int get id => _source.id;

  @override
  String get debugName => 'RawRegexRule(${_source.enTitle})';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final raw = validation.validation ?? '';
    if (raw.isEmpty) return const RuleResult.valid();

    var pattern = raw;
    if (pattern.startsWith('/') && pattern.lastIndexOf('/') > 0) {
      pattern = pattern.substring(1, pattern.lastIndexOf('/'));
    }

    params.forEach((k, v) {
      pattern = pattern.replaceAll(k, '$v');
    });

    try {
      final re = RegExp(pattern, unicode: true, dotAll: true);
      if (re.hasMatch(value)) return const RuleResult.valid();
    } catch (_) {
      return const RuleResult.valid();
    }

    final msg = (locale == 'ar' ? validation.arContent : validation.enContent) ??
        (locale == 'ar' ? validation.arTitle : validation.enTitle) ??
        'Validation error';
    return RuleResult.invalid(msg);
  }
}
