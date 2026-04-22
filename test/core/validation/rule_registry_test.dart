import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rule_registry.dart';

import '_fixtures/seeded_validations.dart';

Question _q({required List<QuestionValidation> qvs}) => Question(
      id: 1,
      type: QuestionType.textShort,
      label: 'q',
      questionValidations: qvs,
    );

void main() {
  group('validateAll', () {
    test('passes when value satisfies all rules', () {
      final q = _q(qvs: [
        QuestionValidation(id: 1, questionId: 1, validationId: 1,
            values: const {}, validation: vNumber),
      ]);
      final errs = RuleRegistry.validateAll(
        question: q, normalizedValue: '42', locale: 'en',
      );
      expect(errs, isEmpty);
    });

    test('returns message from arContent when locale ar', () {
      final q = _q(qvs: [
        QuestionValidation(id: 1, questionId: 1, validationId: 1,
            values: const {}, validation: vNumber),
      ]);
      final errs = RuleRegistry.validateAll(
        question: q, normalizedValue: 'abc', locale: 'ar',
      );
      expect(errs, contains(vNumber.arContent));
    });

    test('skips rules with isActive=false', () {
      final disabled = Validation(
        id: vNumber.id, type: ValidationType.questions,
        validation: vNumber.validation,
        enTitle: vNumber.enTitle, arTitle: vNumber.arTitle,
        enContent: vNumber.enContent, arContent: vNumber.arContent,
        isActive: false,
      );
      final q = _q(qvs: [
        QuestionValidation(id: 1, questionId: 1, validationId: 1,
            values: const {}, validation: disabled),
      ]);
      final errs = RuleRegistry.validateAll(
        question: q, normalizedValue: 'abc', locale: 'en',
      );
      expect(errs, isEmpty);
    });

    test('collects multiple errors in attachment order', () {
      final q = _q(qvs: [
        QuestionValidation(id: 1, questionId: 1, validationId: 1,
            values: const {}, validation: vNumber),
        QuestionValidation(id: 2, questionId: 1, validationId: 6,
            values: const {'min': 10}, validation: vMinLength),
      ]);
      final errs = RuleRegistry.validateAll(
        question: q, normalizedValue: 'abc', locale: 'en',
      );
      expect(errs.length, 2);
      expect(errs[0], contains('Value must be a number'));
    });

    test('unknown-id Value Range validation disambiguates via qv.values', () {
      // Simulates backend sending a Value Range rule under an id that's not
      // in the client registry (re-seed / tenant-specific id). Without params
      // disambiguation, fingerprint routes to NumberRule and "11" passes —
      // the exact user-reported bug.
      final unknownRange = Validation(
        id: 9999,
        type: ValidationType.questions,
        validation: r'^[-+]?[0-9٠-٩]+(\.[0-9٠-٩]+)?$',
        enTitle: 'Value Range',
        arTitle: 'نطاق القيمة',
        enContent: 'Value must be in range',
        arContent: 'يجب أن تكون القيمة ضمن النطاق',
        isActive: true,
      );
      final q = _q(qvs: [
        QuestionValidation(
          id: 1, questionId: 1, validationId: 9999,
          values: const {'min': 3, 'max': 10},
          validation: unknownRange,
        ),
      ]);
      final errs = RuleRegistry.validateAll(
        question: q, normalizedValue: '11', locale: 'en',
      );
      expect(errs, isNotEmpty,
          reason: '11 is out of range 3-10, must produce an error');
      expect(errs.first, contains('10'));
    });
  });

  group('formattersFor', () {
    test('returns formatters from matching rules, deduped', () {
      final q = _q(qvs: [
        QuestionValidation(id: 1, questionId: 1, validationId: 7,
            values: const {'max': 5}, validation: vMaxLength),
        QuestionValidation(id: 2, questionId: 1, validationId: 8,
            values: const {'min': 1, 'max': 3}, validation: vLengthRange),
      ]);
      final fs = RuleRegistry.formattersFor(q);
      // Both rules install LengthLimitingTextInputFormatter; dedupe keeps
      // the smaller cap (3).
      expect(fs.length, 1);
    });

    test('returns empty for question with no validations', () {
      final q = Question(id: 1, type: QuestionType.textShort, label: 'q');
      expect(RuleRegistry.formattersFor(q), isEmpty);
    });
  });
}
