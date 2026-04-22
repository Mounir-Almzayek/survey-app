import 'package:flutter/services.dart';

/// Accepts an optional leading `+`/`-`, then digits (Latin + Arabic-Indic).
/// If [allowDecimal] is true, accepts at most one `.` with fractional digits.
class DigitsAndSignFormatter extends TextInputFormatter {
  DigitsAndSignFormatter({required this.allowDecimal})
      : _allowed = RegExp(
          allowDecimal
              ? '^[-+]?[0-9٠-٩]*(\\.[0-9٠-٩]*)?\$'
              : '^[-+]?[0-9٠-٩]*\$',
        );

  final bool allowDecimal;
  final RegExp _allowed;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_allowed.hasMatch(newValue.text)) return newValue;
    return oldValue;
  }
}
