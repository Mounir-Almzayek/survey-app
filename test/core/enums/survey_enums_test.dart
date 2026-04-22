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

  group('QuestionType snake-case serialisation', () {
    test('textShort → TEXT_SHORT (round-trip)', () {
      expect(QuestionType.textShort.toJson(), 'TEXT_SHORT');
      expect(QuestionType.fromJson('TEXT_SHORT'), QuestionType.textShort);
    });
    test('textLong → TEXT_LONG (round-trip)', () {
      expect(QuestionType.textLong.toJson(), 'TEXT_LONG');
      expect(QuestionType.fromJson('TEXT_LONG'), QuestionType.textLong);
    });
    test('multiSelectGrid → MULTI_SELECT_GRID (round-trip)', () {
      expect(QuestionType.multiSelectGrid.toJson(), 'MULTI_SELECT_GRID');
      expect(
        QuestionType.fromJson('MULTI_SELECT_GRID'),
        QuestionType.multiSelectGrid,
      );
    });
    test('singleSelectGrid → SINGLE_SELECT_GRID (round-trip)', () {
      expect(QuestionType.singleSelectGrid.toJson(), 'SINGLE_SELECT_GRID');
      expect(
        QuestionType.fromJson('SINGLE_SELECT_GRID'),
        QuestionType.singleSelectGrid,
      );
    });
  });
}
