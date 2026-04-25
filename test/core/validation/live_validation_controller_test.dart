import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/l10n/generated/l10n.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/live_validation_controller.dart';

import '_fixtures/seeded_validations.dart';

Question _required({required List<QuestionValidation> qvs}) => Question(
      id: 1,
      type: QuestionType.textShort,
      label: 'q',
      isRequired: true,
      questionValidations: qvs,
    );

void main() {
  setUpAll(() async => await S.load(const Locale('en')));

  testWidgets('error is null on pristine field', (tester) async {
    final c = LiveValidationController(
      question: _required(qvs: [
        QuestionValidation(
            id: 1, questionId: 1, validationId: 1,
            values: const {}, validation: vNumber),
      ]),
      locale: 'en',
    );
    addTearDown(c.dispose);
    expect(c.error, null);
  });

  testWidgets('error appears after onChanged + debounce', (tester) async {
    final c = LiveValidationController(
      question: _required(qvs: [
        QuestionValidation(
            id: 1, questionId: 1, validationId: 1,
            values: const {}, validation: vNumber),
      ]),
      locale: 'en',
      debounce: const Duration(milliseconds: 50),
    );
    addTearDown(c.dispose);

    c.onChanged('abc');
    await tester.pump(const Duration(milliseconds: 60));
    expect(c.error, isNotNull);
  });

  testWidgets('onBlur flushes the debounce immediately', (tester) async {
    final c = LiveValidationController(
      question: _required(qvs: [
        QuestionValidation(
            id: 1, questionId: 1, validationId: 1,
            values: const {}, validation: vNumber),
      ]),
      locale: 'en',
      debounce: const Duration(seconds: 10),
    );
    addTearDown(c.dispose);

    c.onChanged('abc');
    c.onBlur('abc');
    await tester.pump();
    expect(c.error, isNotNull);
  });

  testWidgets('markSubmitAttempted alone does not fabricate an error', (tester) async {
    final c = LiveValidationController(
      question: _required(qvs: const []),
      locale: 'en',
    );
    addTearDown(c.dispose);

    expect(c.error, null);
    c.markSubmitAttempted();
    await tester.pump();
    expect(c.error, null);
  });

  testWidgets('markSubmitAttempted lets a previously cached error render', (tester) async {
    final c = LiveValidationController(
      question: _required(qvs: [
        QuestionValidation(
            id: 1, questionId: 1, validationId: 1,
            values: const {}, validation: vNumber),
      ]),
      locale: 'en',
      debounce: const Duration(milliseconds: 50),
    );
    addTearDown(c.dispose);

    c.onChanged('abc');
    await tester.pump(const Duration(milliseconds: 60));
    expect(c.error, isNotNull);

    c.markSubmitAttempted();
    await tester.pump();
    expect(c.error, isNotNull);
  });
}
