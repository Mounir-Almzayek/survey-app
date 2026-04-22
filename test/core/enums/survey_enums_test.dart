import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';

void main() {
  group('QuestionType.phoneNumber', () {
    test('serialises to PHONE_NUMBER', () {
      expect(QuestionType.phoneNumber.toJson(), 'PHONE_NUMBER');
    });

    test('parses PHONE_NUMBER from backend', () {
      expect(QuestionType.fromJson('PHONE_NUMBER'), QuestionType.phoneNumber);
    });

    test('unknown value falls back to textShort', () {
      expect(QuestionType.fromJson('bogus'), QuestionType.textShort);
    });
  });
}
