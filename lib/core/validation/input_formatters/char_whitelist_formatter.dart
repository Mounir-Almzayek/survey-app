import 'package:flutter/services.dart';

/// Rejects any new value that contains a character not matching [allowedChar].
/// [allowedChar] is a single-char regex — the formatter tests each rune.
class CharWhitelistFormatter extends TextInputFormatter {
  CharWhitelistFormatter(this.allowedChar);

  final RegExp allowedChar;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    for (final rune in text.runes) {
      final ch = String.fromCharCode(rune);
      if (!allowedChar.hasMatch(ch)) return oldValue;
    }
    return newValue;
  }
}
