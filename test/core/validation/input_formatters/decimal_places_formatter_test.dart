import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/input_formatters/decimal_places_formatter.dart';

TextEditingValue _val(String s) =>
    TextEditingValue(text: s, selection: TextSelection.collapsed(offset: s.length));

void main() {
  final f = DecimalPlacesFormatter(2);

  test('accepts 0 decimal places', () {
    expect(f.formatEditUpdate(_val(''), _val('123')).text, '123');
  });

  test('accepts 1 decimal place', () {
    expect(f.formatEditUpdate(_val('12'), _val('12.3')).text, '12.3');
  });

  test('accepts 2 decimal places', () {
    expect(f.formatEditUpdate(_val('12.3'), _val('12.34')).text, '12.34');
  });

  test('rejects 3rd decimal place — reverts', () {
    expect(f.formatEditUpdate(_val('12.34'), _val('12.345')).text, '12.34');
  });

  test('accepts deletions', () {
    expect(f.formatEditUpdate(_val('12.34'), _val('12.3')).text, '12.3');
  });

  test('accepts Arabic-Indic digits in fraction', () {
    expect(f.formatEditUpdate(_val('12.'), _val('12.٣٤')).text, '12.٣٤');
  });
}
