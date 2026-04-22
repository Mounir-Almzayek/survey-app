import 'package:flutter/services.dart';

/// Rejects any value containing whitespace (space, tab, newline, etc.).
class NoSpacesFormatter extends TextInputFormatter {
  static final RegExp _anyWhitespace = RegExp(r'\s');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_anyWhitespace.hasMatch(newValue.text)) return oldValue;
    return newValue;
  }
}
