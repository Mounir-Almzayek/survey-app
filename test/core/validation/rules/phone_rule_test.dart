import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/l10n/generated/l10n.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rule.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rules/phone_rule.dart';

/// Backend stores `phone_number` as a question type, not a validation row, so
/// PhoneNumberRule receives a synthetic Validation that just identifies the
/// title — the rule does its own checking.
final Validation _vPhone = Validation(
  id: 33,
  type: ValidationType.questions,
  validation: null,
  enTitle: 'Phone Number',
  arTitle: 'رقم هاتف',
  isActive: true,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await S.load(const Locale('en'));
  });

  group('PhoneNumberRule (id 33) — Saudi format enforcement', () {
    final r = PhoneNumberRule();

    RuleResult run(String? value) => r.validate(
          value: value,
          params: const {},
          validation: _vPhone,
          locale: 'en',
        );

    // -------------------------------------------------------------------------
    // ACCEPT cases — every valid Saudi mobile shape the field can produce
    // -------------------------------------------------------------------------

    test('accepts national format with leading 0: 0501234567', () {
      expect(run('0501234567').isValid, isTrue);
    });

    test('accepts national format without leading 0: 501234567', () {
      expect(run('501234567').isValid, isTrue);
    });

    test('accepts E.164 Saudi format: +966501234567', () {
      expect(run('+966501234567').isValid, isTrue);
    });

    test('accepts E.164 Saudi with stray leading 0: +9660501234567', () {
      // The IntlPhoneField sometimes lets the user type the national leading 0
      // through, so the stored value can have one even though it shouldn't.
      // Treat as valid Saudi to avoid spurious rejections.
      expect(run('+9660501234567').isValid, isTrue);
    });

    test('accepts 00966 international prefix: 00966501234567', () {
      expect(run('00966501234567').isValid, isTrue);
    });

    test('accepts unprefixed E.164 digits: 966501234567', () {
      expect(run('966501234567').isValid, isTrue);
    });

    test('accepts value with spaces around (gets trimmed)', () {
      expect(run('  +966501234567  ').isValid, isTrue);
    });

    test('accepts every leading-5 digit (50, 53, 54, 55, 56, 57, 58, 59)', () {
      for (final prefix in ['50', '53', '54', '55', '56', '57', '58', '59']) {
        expect(run('0${prefix}1234567').isValid, isTrue,
            reason: 'prefix 0$prefix should be valid Saudi mobile');
      }
    });

    test('empty value passes (required-check handled elsewhere)', () {
      expect(run('').isValid, isTrue);
      expect(run(null).isValid, isTrue);
    });

    // -------------------------------------------------------------------------
    // REJECT cases — must produce the Saudi-specific error
    // -------------------------------------------------------------------------

    test('rejects national starting with 04 (landline-style)', () {
      final res = run('0401234567');
      expect(res.isValid, isFalse);
      expect(res.message, isNotNull);
    });

    test('rejects national too short (only 9 digits with leading 0)', () {
      // 050123456 = 0 + 5 + 7 digits → rejected
      expect(run('050123456').isValid, isFalse);
    });

    test('rejects national too long (11+ digits)', () {
      expect(run('05012345678').isValid, isFalse);
    });

    test('rejects 5-prefixed national too short (8 digits total)', () {
      // 50123456 = 5 + 7 digits → rejected
      expect(run('50123456').isValid, isFalse);
    });

    test('rejects non-Saudi country code: +971501234567 (UAE)', () {
      expect(run('+971501234567').isValid, isFalse);
    });

    test('rejects non-Saudi country code: +201234567890 (Egypt)', () {
      expect(run('+201234567890').isValid, isFalse);
    });

    test('rejects letters in number: 050abc4567', () {
      expect(run('050abc4567').isValid, isFalse);
    });

    test('rejects starting with 1: 1501234567', () {
      expect(run('1501234567').isValid, isFalse);
    });

    test('error message includes Arabic Saudi reference', () {
      // We set defaultLocale to 'en' in setUpAll but the rule should still
      // reference "Saudi" in its message so testers know the cause.
      final res = run('0401234567');
      expect(res.message, contains('Saudi'));
    });
  });
}
