import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/features/assignment/models/start_response_request_model.dart';

void main() {
  group('StartResponseRequest.createdAt', () {
    test('toJson includes created_at as ISO 8601 UTC string', () {
      final t = DateTime.utc(2026, 4, 25, 14, 35, 22, 143);
      final req = StartResponseRequest(
        surveyId: 1,
        gender: Gender.male,
        ageGroup: AgeGroup.age18_29,
        createdAt: t,
      );
      final json = req.toJson();
      expect(json['created_at'], '2026-04-25T14:35:22.143Z');
    });

    test('defaults createdAt to now when omitted', () {
      final before = DateTime.now().toUtc();
      final req = StartResponseRequest(
        surveyId: 1,
        gender: Gender.male,
        ageGroup: AgeGroup.age18_29,
      );
      final after = DateTime.now().toUtc();
      final ca = req.createdAt.toUtc();
      expect(
        ca.isBefore(before.subtract(const Duration(milliseconds: 5))),
        isFalse,
      );
      expect(
        ca.isAfter(after.add(const Duration(milliseconds: 5))),
        isFalse,
      );
    });

    test(
      'toJson is stable across re-invocations (timestamp frozen at construction)',
      () async {
        final req = StartResponseRequest(
          surveyId: 1,
          gender: Gender.male,
          ageGroup: AgeGroup.age18_29,
        );
        final first = req.toJson()['created_at'];
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final second = req.toJson()['created_at'];
        expect(first, second);
      },
    );

    test('copyWith preserves createdAt when not overridden', () {
      final t = DateTime.utc(2026, 4, 25, 10);
      final req = StartResponseRequest(
        surveyId: 1,
        gender: Gender.male,
        ageGroup: AgeGroup.age18_29,
        createdAt: t,
      );
      final copy = req.copyWith(surveyId: 2);
      expect(copy.createdAt, t);
    });
  });
}
