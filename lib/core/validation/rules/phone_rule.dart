import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import '../../l10n/generated/l10n.dart';
import '../../models/survey/validation_model.dart';
import '../rule.dart';

class PhoneNumberRule extends Rule {
  @override
  int get id => 33; // Assigned a new ID
  @override
  String get debugName => 'Phone Number';

  @override
  RuleResult validate({
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final s = coerceString(value);
    if (s.isEmpty) return const RuleResult.valid();

    try {
      final parsed = PhoneNumber.parse(s);
      if (parsed.isValid()) return const RuleResult.valid();
    } catch (_) {
      /* fall through */
    }

    return RuleResult.invalid(S.current.invalid_phone_number);
  }
}
