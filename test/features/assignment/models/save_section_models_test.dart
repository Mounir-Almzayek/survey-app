import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/features/assignment/models/save_section_models.dart';

void main() {
  group('SaveSectionRequest.createdAt', () {
    test('toJson includes created_at as ISO 8601 UTC string', () {
      final t = DateTime.utc(2026, 4, 25, 14, 35, 22, 143);
      final req = SaveSectionRequest(
        sectionId: 10,
        answers: const [],
        createdAt: t,
      );
      expect(req.toJson()['created_at'], '2026-04-25T14:35:22.143Z');
    });

    test('defaults createdAt to now when omitted', () {
      final before = DateTime.now().toUtc();
      final req = SaveSectionRequest(sectionId: 10, answers: const []);
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

    test('toJson is stable across re-invocations', () async {
      final req = SaveSectionRequest(sectionId: 10, answers: const []);
      final first = req.toJson()['created_at'];
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final second = req.toJson()['created_at'];
      expect(first, second);
    });

    test('copyWith preserves createdAt when not overridden', () {
      final t = DateTime.utc(2026, 4, 25, 10);
      final req = SaveSectionRequest(
        sectionId: 10,
        answers: const [],
        createdAt: t,
      );
      expect(req.copyWith(sectionId: 11).createdAt, t);
    });

    test('fromJson reads created_at if present, falls back to now otherwise', () {
      final t = DateTime.utc(2026, 4, 25, 12);
      final withTs = SaveSectionRequest.fromJson({
        'section_id': 10,
        'answers': <Map<String, dynamic>>[],
        'created_at': t.toIso8601String(),
      });
      expect(withTs.createdAt, t);

      final before = DateTime.now().toUtc();
      final without = SaveSectionRequest.fromJson({
        'section_id': 10,
        'answers': <Map<String, dynamic>>[],
      });
      final after = DateTime.now().toUtc();
      final ca = without.createdAt.toUtc();
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
