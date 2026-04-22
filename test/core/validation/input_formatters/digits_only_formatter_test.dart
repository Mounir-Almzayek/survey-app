import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/input_formatters/digits_only_formatter.dart';

TextEditingValue _val(String s) =>
    TextEditingValue(text: s, selection: TextSelection.collapsed(offset: s.length));

void main() {
  final f = DigitsOnlyFormatter();

  test('accepts Latin digits', () {
    final r = f.formatEditUpdate(_val(''), _val('123'));
    expect(r.text, '123');
  });

  test('accepts Arabic-Indic digits', () {
    final r = f.formatEditUpdate(_val(''), _val('٠١٢٣'));
    expect(r.text, '٠١٢٣');
  });

  test('rejects letters — reverts to old value', () {
    final r = f.formatEditUpdate(_val('12'), _val('12a'));
    expect(r.text, '12');
  });

  test('rejects a leading sign', () {
    final r = f.formatEditUpdate(_val(''), _val('+1'));
    expect(r.text, '');
  });

  test('rejects a decimal point', () {
    final r = f.formatEditUpdate(_val(''), _val('1.5'));
    expect(r.text, '');
  });
}
