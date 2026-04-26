import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/quota_coordinate.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/researcher_quota_model.dart';

void main() {
  group('ResearcherQuota.fromJson (new shape)', () {
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
          'scope_criterion_id': 1,
          'criterion_name': 'Region',
          'scope_criterion_category_id': 5,
          'category_label': 'منطقة الباحة',
          'category_value': 'baha',
          'order': 1,
        },
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

    test('parses new fields', () {
      final q = ResearcherQuota.fromJson(wire);
      expect(q.id, 1001);
      expect(q.quotaTargetId, 301);
      expect(q.target, 10);
      expect(q.progress, 4);
      expect(q.collected, 4);
      expect(q.responsesCountInCategory, 4);
      expect(q.serverRemaining, 6);
      expect(q.displayLabel, 'منطقة الباحة • ذكر • 18-29');
      expect(q.coordinates.length, 2);
      expect(q.coordinates.first, isA<QuotaCoordinate>());
    });

    test('quotaTargetId is nullable', () {
      final q = ResearcherQuota.fromJson({...wire, 'quota_target_id': null});
      expect(q.quotaTargetId, isNull);
    });

    test('legacy gender/age_group keys are silently ignored', () {
      final legacy = {...wire, 'gender': 'MALE', 'age_group': 'AGE_18_29'};
      final q = ResearcherQuota.fromJson(legacy);
      expect(q.id, 1001);
    });

    test('toJson round-trips new shape (no gender/age_group emitted)', () {
      final q = ResearcherQuota.fromJson(wire);
      final out = q.toJson();
      expect(out['quota_target_id'], 301);
      expect(out['display_label'], 'منطقة الباحة • ذكر • 18-29');
      expect((out['coordinates'] as List).length, 2);
      expect(out.containsKey('gender'), isFalse);
      expect(out.containsKey('age_group'), isFalse);
    });
  });
}
