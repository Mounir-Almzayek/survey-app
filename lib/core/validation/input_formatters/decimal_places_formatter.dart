import 'package:flutter/services.dart';

/// Caps the number of fractional digits (after a `.`) at [maxDecimals].
/// Does NOT enforce digit-only input on its own — compose with
/// [DigitsAndSignFormatter] for a full numeric field.
class DecimalPlacesFormatter extends TextInputFormatter {
  DecimalPlacesFormatter(this.maxDecimals);

  final int maxDecimals;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final dot = text.indexOf('.');
    if (dot < 0) return newValue;
    final frac = text.substring(dot + 1);
    if (frac.length > maxDecimals) return oldValue;
    return newValue;
  }
}
