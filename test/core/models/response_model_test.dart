import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/response_model.dart';

void main() {
  group('Response.fromJson (new shape)', () {
    test('parses quotaTargetId when present', () {
      final r = Response.fromJson({
        'id': 5,
        'survey_id': 1,
        'assignment_id': 7,
        'status': 'DRAFT',
        'quota_target_id': 301,
      });
      expect(r.id, 5);
      expect(r.quotaTargetId, 301);
    });

    test('quotaTargetId is null when absent', () {
      final r = Response.fromJson({
        'id': 5,
        'survey_id': 1,
        'assignment_id': 7,
        'status': 'DRAFT',
      });
      expect(r.quotaTargetId, isNull);
    });

    test('ignores legacy gender/age_group keys', () {
      final r = Response.fromJson({
        'id': 5,
        'survey_id': 1,
        'assignment_id': 7,
        'status': 'DRAFT',
        'gender': 'MALE',
        'age_group': 'AGE_18_29',
      });
      expect(r.id, 5);
    });

    test('toJson does not emit gender/age_group', () {
      final r = Response.fromJson({
        'id': 5,
        'survey_id': 1,
        'assignment_id': 7,
        'status': 'DRAFT',
        'quota_target_id': 301,
      });
      final j = r.toJson();
      expect(j['quota_target_id'], 301);
      expect(j.containsKey('gender'), isFalse);
      expect(j.containsKey('age_group'), isFalse);
    });
  });
}
