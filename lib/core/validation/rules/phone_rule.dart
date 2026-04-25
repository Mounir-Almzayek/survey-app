import '../../l10n/generated/l10n.dart';
import '../../models/survey/validation_model.dart';
import '../rule.dart';

/// Saudi mobile number validator.
///
/// Accepts a phone in any of the shapes the survey UI can produce:
///  - National with or without the leading 0 (`0501234567` / `501234567`)
///  - E.164 with the `+966` prefix (`+966501234567`)
///  - International dial form `00966...` or bare `966...`
///  - Tolerates a stray leading 0 in the international form
///    (`+9660501234567`) which the IntlPhoneField sometimes lets through.
///
/// Anything else — wrong country code, wrong national prefix, wrong digit
/// count, non-digit characters — is rejected with "Saudi number required".
class PhoneNumberRule extends Rule {
  @override
  int get id => 33;

  @override
  String get debugName => 'Phone Number';

  /// Saudi mobile national format: optional 0, then 5, then 8 more digits.
  static final RegExp _saudiNational = RegExp(r'^0?5\d{8}$');

  @override
  RuleResult validate({
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final raw = coerceString(value).trim();
    if (raw.isEmpty) return const RuleResult.valid();

    final national = _toNational(raw);
    if (national != null && _saudiNational.hasMatch(national)) {
      return const RuleResult.valid();
    }
    return RuleResult.invalid(S.current.must_be_saudi_number);
  }

  /// Strips Saudi country-code prefixes and returns the national portion.
  /// Returns null when the input clearly belongs to another country (a `+`
  /// or `00` prefix that isn't `+966` / `00966`).
  static String? _toNational(String input) {
    var s = input;

    // Plus-prefixed: must be Saudi to continue.
    if (s.startsWith('+')) {
      if (s.startsWith('+966')) return s.substring(4);
      return null; // Different country — rejected.
    }

    // 00-prefixed international form.
    if (s.startsWith('00')) {
      if (s.startsWith('00966')) return s.substring(5);
      return null;
    }

    // Bare 966-prefixed digits — only treat as country code when the rest
    // looks like a national number (so we don't strip the prefix from a
    // landline that happens to start with 966).
    if (s.startsWith('966') && s.length >= 12) {
      return s.substring(3);
    }

    return s;
  }
}
