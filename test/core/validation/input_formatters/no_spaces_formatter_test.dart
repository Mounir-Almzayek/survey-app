import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/input_formatters/no_spaces_formatter.dart';

TextEditingValue _val(String s) =>
    TextEditingValue(text: s, selection: TextSelection.collapsed(offset: s.length));

void main() {
  final f = NoSpacesFormatter();

  test('accepts non-whitespace', () {
    expect(f.formatEditUpdate(_val(''), _val('abc123')).text, 'abc123');
  });

  test('rejects single space — reverts', () {
    expect(f.formatEditUpdate(_val('abc'), _val('abc ')).text, 'abc');
  });

  test('rejects tab — reverts', () {
    expect(f.formatEditUpdate(_val('abc'), _val('abc\t')).text, 'abc');
  });

  test('rejects paste with internal space — reverts', () {
    expect(f.formatEditUpdate(_val('ab'), _val('a b c')).text, 'ab');
  });
}
