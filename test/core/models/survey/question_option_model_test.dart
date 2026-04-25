import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_option_model.dart';

void main() {
  group('QuestionOption.fromJson — is_other parsing', () {
    test('parses is_other: true', () {
      final o = QuestionOption.fromJson({
        'id': 1,
        'question_id': 10,
        'label': 'Other',
        'value': 'other',
        'order': 5,
        'is_other': true,
      });
      expect(o.isOther, isTrue);
    });

    test('parses is_other: false', () {
      final o = QuestionOption.fromJson({
        'id': 2,
        'question_id': 10,
        'label': 'Yes',
        'value': 'yes',
        'order': 1,
        'is_other': false,
      });
      expect(o.isOther, isFalse);
    });

    test('defaults to false when is_other missing from JSON', () {
      // Backend sometimes omits the field entirely (older surveys, partial
      // serializers). The model must read it as `false`, never `null`, so
      // downstream `isOther == true` checks behave correctly.
      final o = QuestionOption.fromJson({
        'id': 3,
        'question_id': 10,
        'label': 'No',
        'value': 'no',
      });
      expect(o.isOther, isFalse);
    });
  });

  group('QuestionOption.toJson — is_other round-trip', () {
    test('writes is_other when set', () {
      const o = QuestionOption(
        id: 1,
        questionId: 10,
        label: 'Other',
        value: 'other',
        order: 5,
        isOther: true,
      );
      expect(o.toJson()['is_other'], isTrue);
    });
  });
}
