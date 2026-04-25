import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/features/public_links/repository/public_links_online_repository.dart';

void main() {
  group('PublicLinksOnlineRepository.buildStartBody', () {
    test('includes gender, age_group, and created_at', () {
      final t = DateTime.utc(2026, 4, 25, 14, 35, 22, 143);
      final body = PublicLinksOnlineRepository.buildStartBody(
        gender: 'MALE',
        ageGroup: '19_29',
        createdAt: t,
      );
      expect(body['gender'], 'MALE');
      expect(body['age_group'], '19_29');
      expect(body['created_at'], '2026-04-25T14:35:22.143Z');
      expect(body.containsKey('location'), isFalse);
    });

    test('includes location when provided', () {
      final body = PublicLinksOnlineRepository.buildStartBody(
        gender: 'FEMALE',
        ageGroup: '30_39',
        location: (latitude: 24.7136, longitude: 46.6753),
        createdAt: DateTime.utc(2026, 4, 25),
      );
      expect(body['location'], {'latitude': 24.7136, 'longitude': 46.6753});
    });

    test('defaults createdAt to now when omitted', () {
      final before = DateTime.now().toUtc();
      final body = PublicLinksOnlineRepository.buildStartBody(
        gender: 'MALE',
        ageGroup: '19_29',
      );
      final after = DateTime.now().toUtc();
      final ca = DateTime.parse(body['created_at'] as String);
      expect(
        ca.isBefore(before.subtract(const Duration(milliseconds: 5))),
        isFalse,
      );
      expect(
        ca.isAfter(after.add(const Duration(milliseconds: 5))),
        isFalse,
      );
    });
  });

  group('PublicLinksOnlineRepository.buildSectionSubmitBody', () {
    test('includes answers and created_at', () {
      final t = DateTime.utc(2026, 4, 25, 14, 40);
      final body = PublicLinksOnlineRepository.buildSectionSubmitBody(
        answers: [
          (questionId: 1, value: 'A'),
          (questionId: 2, value: 42),
        ],
        createdAt: t,
      );
      expect(body['answers'], [
        {'question_id': 1, 'value': 'A'},
        {'question_id': 2, 'value': 42},
      ]);
      expect(body['created_at'], '2026-04-25T14:40:00.000Z');
    });

    test('defaults createdAt to now when omitted', () {
      final before = DateTime.now().toUtc();
      final body = PublicLinksOnlineRepository.buildSectionSubmitBody(
        answers: const [],
      );
      final after = DateTime.now().toUtc();
      final ca = DateTime.parse(body['created_at'] as String);
      expect(
        ca.isBefore(before.subtract(const Duration(milliseconds: 5))),
        isFalse,
      );
      expect(
        ca.isAfter(after.add(const Duration(milliseconds: 5))),
        isFalse,
      );
    });
  });
}
