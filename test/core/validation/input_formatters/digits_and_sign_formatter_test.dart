import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/input_formatters/digits_and_sign_formatter.dart';

TextEditingValue _val(String s) =>
    TextEditingValue(text: s, selection: TextSelection.collapsed(offset: s.length));

void main() {
  group('allowDecimal: false', () {
    final f = DigitsAndSignFormatter(allowDecimal: false);

    test('accepts empty', () {
      expect(f.formatEditUpdate(_val(''), _val('')).text, '');
    });

    test('accepts leading + then digits', () {
      expect(f.formatEditUpdate(_val(''), _val('+12')).text, '+12');
    });

    test('accepts leading - then digits', () {
      expect(f.formatEditUpdate(_val(''), _val('-5')).text, '-5');
    });

    test('accepts Arabic-Indic digits', () {
      expect(f.formatEditUpdate(_val(''), _val('-٥')).text, '-٥');
    });

    test('rejects decimal point', () {
      expect(f.formatEditUpdate(_val('12'), _val('12.')).text, '12');
    });

    test('rejects sign in middle', () {
      expect(f.formatEditUpdate(_val('1'), _val('1+')).text, '1');
    });
  });

  group('allowDecimal: true', () {
    final f = DigitsAndSignFormatter(allowDecimal: true);

    test('accepts decimal', () {
      expect(f.formatEditUpdate(_val(''), _val('-1.25')).text, '-1.25');
    });

    test('rejects two decimal points', () {
      expect(f.formatEditUpdate(_val('1.2'), _val('1.2.')).text, '1.2');
    });
  });
}
