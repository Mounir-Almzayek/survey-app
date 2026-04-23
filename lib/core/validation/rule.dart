import 'package:flutter/services.dart';

import '../models/survey/validation_model.dart';

/// Outcome of running a single rule against a normalized value.
class RuleResult {
  final bool isValid;
  final String? message;

  const RuleResult.valid()
      : isValid = true,
        message = null;

  const RuleResult.invalid(this.message) : isValid = false;
}

/// A typed validation rule. One instance per seeded backend rule.
///
/// Instances are stateless and may be held statically in [RuleRegistry].
abstract class Rule {
  /// Backend `validation.id` this rule corresponds to. Used by [RuleRegistry]
  /// for id-keyed lookup.
  int get id;

  /// English title of the seeded rule (e.g. "Minimum Length"). Used only
  /// for debug output.
  String get debugName;

  /// Whether this rule is meaningful for text-input question types (text_short,
  /// text_long, phone-ish). Non-text question types skip the registry entirely
  /// so this guard is cheap insurance.
  bool get appliesToTextInput => true;

  /// Run the rule against a value. [params] is `qv.values` from the backend
  /// (e.g. `{"min": 3}`); the rule pulls the fields it needs via the helpers
  /// in `param_helpers.dart`.
  RuleResult validate({
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  });

  /// Helper to get a string representation for rules that expect text.
  String coerceString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is List) return value.join(',');
    if (value is Map) {
      final lat = value['latitude'];
      final lng = value['longitude'];
      if (lat != null && lng != null) {
        final la = lat is List ? lat.firstOrNull : lat;
        final lo = lng is List ? lng.firstOrNull : lng;
        if (la != null && lo != null) return '$la,$lo';
      }
      return value.toString();
    }
    return value.toString();
  }

  /// Optional input formatters installed by the field widget for this rule.
  /// Default: no formatters (keystroke-time rejection is opt-in per rule).
  List<TextInputFormatter> formatters(Map<String, dynamic> params) => const [];
}
