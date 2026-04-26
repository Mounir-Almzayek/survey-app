import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/features/responses/models/response_details.dart';

void main() {
  Map<String, dynamic> minimal() => {
    'id': 5,
    'status': 'SUBMITTED',
    'duration_sec': 0,
    'created_at': '2026-04-26T10:00:00Z',
    'updated_at': '2026-04-26T10:01:00Z',
    'started_at': '2026-04-26T10:00:00Z',
    'answers': <Map<String, dynamic>>[],
  };

  group('ResponseDetails new fields', () {
    test('parses quotaTargetId/displayLabel/coordinates when present', () {
      final d = ResponseDetails.fromJson({
        ...minimal(),
        'quota_target_id': 301,
        'display_label': 'منطقة الباحة • ذكر • 18-29',
        'coordinates': [
          {
            'scope_criterion_id': 3,
            'criterion_name': 'Gender',
            'scope_criterion_category_id': 11,
            'category_label': 'ذكر',
            'category_value': 'male',
            'order': 3,
          }
        ],
      });
      expect(d.quotaTargetId, 301);
      expect(d.displayLabel, 'منطقة الباحة • ذكر • 18-29');
      expect(d.coordinates, isNotNull);
      expect(d.coordinates!.length, 1);
    });

    test('all three new fields are null when absent', () {
      final d = ResponseDetails.fromJson(minimal());
      expect(d.quotaTargetId, isNull);
      expect(d.displayLabel, isNull);
      expect(d.coordinates, isNull);
    });

    test('coordinates round-trip (Arabic preserved)', () {
      final d = ResponseDetails.fromJson({
        ...minimal(),
        'coordinates': [
          {
            'scope_criterion_id': 1,
            'criterion_name': 'Region',
            'scope_criterion_category_id': 5,
            'category_label': 'منطقة الباحة',
            'category_value': 'baha',
            'order': 1,
          }
        ],
      });
      expect(d.coordinates!.first.categoryLabel, 'منطقة الباحة');
      expect(d.coordinates!.first.categoryValue, 'baha');
    });
  });
}
