import 'package:flutter/services.dart';

import '../../models/survey/validation_model.dart';
import '../input_formatters/no_spaces_formatter.dart';
import '../rule.dart';

String _msg(Validation v, String locale) =>
    (locale == 'ar' ? v.arContent : v.enContent) ?? '';

bool _match(String pattern, String value) {
  try {
    return RegExp(pattern, unicode: true).hasMatch(value);
  } catch (_) {
    return false;
  }
}

class EmailRule extends Rule {
  @override
  int get id => 15;
  @override
  String get debugName => 'Email';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_msg(validation, locale));
  }
}

class UrlRule extends Rule {
  @override
  int get id => 16;
  @override
  String get debugName => 'URL';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_msg(validation, locale));
  }
}

class NoSpacesRule extends Rule {
  @override
  int get id => 17;
  @override
  String get debugName => 'No Spaces';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_msg(validation, locale));
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) =>
      [NoSpacesFormatter()];
}
