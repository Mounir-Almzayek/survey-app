import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/utils/survey_validator.dart';

void main() {
  group('SurveyValidator.isValueEmpty (grid)', () {
    test('empty map is empty', () {
      expect(SurveyValidator.isValueEmpty(<String, String>{}), isTrue);
    });
    test('map with only empty-list values is empty', () {
      expect(
        SurveyValidator.isValueEmpty(<String, List<String>>{'a': []}),
        isTrue,
      );
    });
    test('map with non-empty list is not empty', () {
      expect(
        SurveyValidator.isValueEmpty(<String, List<String>>{'a': ['yes']}),
        isFalse,
      );
    });
    test('map with string value is not empty', () {
      expect(
        SurveyValidator.isValueEmpty(<String, String>{'a': 'yes'}),
        isFalse,
      );
    });
  });
}
