import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/input_formatters/char_whitelist_formatter.dart';

TextEditingValue _val(String s) =>
    TextEditingValue(text: s, selection: TextSelection.collapsed(offset: s.length));

void main() {
  test('letters-only pattern accepts Latin letters', () {
    final f = CharWhitelistFormatter(RegExp('[a-zA-Z]'));
    expect(f.formatEditUpdate(_val(''), _val('abc')).text, 'abc');
  });

  test('letters-only pattern accepts Arabic letters', () {
    final f = CharWhitelistFormatter(
      RegExp('[؀-ٰٟ-ۿa-zA-Z]'),
    );
    expect(f.formatEditUpdate(_val(''), _val('مرحبا')).text, 'مرحبا');
  });

  test('rejects disallowed character — reverts to old', () {
    final f = CharWhitelistFormatter(RegExp('[a-zA-Z]'));
    final r = f.formatEditUpdate(_val('abc'), _val('abc1'));
    expect(r.text, 'abc');
  });

  test('rejects paste of mixed content — reverts to old', () {
    final f = CharWhitelistFormatter(RegExp('[a-zA-Z]'));
    final r = f.formatEditUpdate(_val('ab'), _val('ab12'));
    expect(r.text, 'ab');
  });

  test('accepts empty input', () {
    final f = CharWhitelistFormatter(RegExp('[a-zA-Z]'));
    expect(f.formatEditUpdate(_val('a'), _val('')).text, '');
  });
}
