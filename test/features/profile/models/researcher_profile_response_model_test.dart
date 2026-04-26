import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/features/profile/models/researcher_profile_response_model.dart';

void main() {
  group('Profile ResearcherQuotaModel.fromJson', () {
    final wire = {
      'id': 1001,
      'quota_id': 501,
      'assignment_id': 77,
      'quota_target_id': 301,
      'target': 10,
      'limit': 10,
      'progress': 4,
      'used': 4,
      'collected': 4,
      'remaining': 6,
      'responses_count': 4,
      'progress_percent': 40,
      'display_label': 'منطقة الباحة • ذكر • 18-29',
      'coordinates': [
        {
          'scope_criterion_id': 3,
          'criterion_name': 'Gender',
          'scope_criterion_category_id': 11,
          'category_label': 'ذكر',
          'category_value': 'male',
          'order': 3,
        },
      ],
    };

    test('exposes quotaTargetId/displayLabel/coordinates', () {
      final q = ResearcherQuotaModel.fromJson(wire);
      expect(q.quotaTargetId, 301);
      expect(q.displayLabel, 'منطقة الباحة • ذكر • 18-29');
      expect(q.coordinates.length, 1);
    });

    test('legacy gender/age_group are ignored', () {
      final q = ResearcherQuotaModel.fromJson({
        ...wire,
        'gender': 'MALE',
        'age_group': 'AGE_18_29',
      });
      expect(q.quotaTargetId, 301);
    });

    test('quotaTargetId is nullable', () {
      final q = ResearcherQuotaModel.fromJson({...wire, 'quota_target_id': null});
      expect(q.quotaTargetId, isNull);
    });

    test('toJson omits gender + age_group', () {
      final q = ResearcherQuotaModel.fromJson(wire);
      final out = q.toJson();
      expect(out.containsKey('gender'), isFalse);
      expect(out.containsKey('age_group'), isFalse);
      expect(out['display_label'], 'منطقة الباحة • ذكر • 18-29');
    });
  });
}
