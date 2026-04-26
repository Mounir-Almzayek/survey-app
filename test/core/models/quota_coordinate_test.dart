import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/quota_coordinate.dart';

void main() {
  group('QuotaCoordinate', () {
    final json = {
      'scope_criterion_id': 3,
      'criterion_name': 'Gender',
      'scope_criterion_category_id': 11,
      'category_label': 'ذكر',
      'category_value': 'male',
      'order': 3,
    };

    test('fromJson parses all fields', () {
      final c = QuotaCoordinate.fromJson(json);
      expect(c.scopeCriterionId, 3);
      expect(c.criterionName, 'Gender');
      expect(c.scopeCriterionCategoryId, 11);
      expect(c.categoryLabel, 'ذكر');
      expect(c.categoryValue, 'male');
      expect(c.order, 3);
    });

    test('toJson round-trips', () {
      final c = QuotaCoordinate.fromJson(json);
      expect(c.toJson(), json);
    });

    test('equality is structural', () {
      final a = QuotaCoordinate.fromJson(json);
      final b = QuotaCoordinate.fromJson(json);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('preserves Arabic category_label byte-exact', () {
      final c = QuotaCoordinate.fromJson(json);
      expect(c.categoryLabel.codeUnits, 'ذكر'.codeUnits);
    });
  });
}
