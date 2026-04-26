import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/scope_criterion_binding.dart';

void main() {
  group('ScopeCriterionBinding', () {
    test('fromJson + toJson round-trip', () {
      final json = {'source_question_id': 42, 'scope_criterion_id': 3};
      final b = ScopeCriterionBinding.fromJson(json);
      expect(b.sourceQuestionId, 42);
      expect(b.scopeCriterionId, 3);
      expect(b.toJson(), json);
    });

    test('equality is structural', () {
      final a = ScopeCriterionBinding(sourceQuestionId: 1, scopeCriterionId: 2);
      final b = ScopeCriterionBinding(sourceQuestionId: 1, scopeCriterionId: 2);
      expect(a, b);
    });
  });
}
