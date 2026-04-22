import 'package:flutter/services.dart';

/// Accepts only Latin digits (`0-9`) and Arabic-Indic digits (`٠-٩`).
/// Rejects any other character, including `+`, `-`, `.`, whitespace.
class DigitsOnlyFormatter extends TextInputFormatter {
  static final RegExp _allowed = RegExp('^[0-9٠-٩]*\$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_allowed.hasMatch(newValue.text)) return newValue;
    return oldValue;
  }
}
