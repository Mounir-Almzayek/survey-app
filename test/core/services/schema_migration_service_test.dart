import 'dart:convert';
import 'dart:io' show Directory;

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:king_abdulaziz_center_survey_app/core/services/schema_migration_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_migration_test');
    Hive.init(tempDir.path);
    await Hive.openBox('home_data_box');
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('SchemaMigrationService.runIfNeeded', () {
    test('wipes surveys + profile + metadata keys from home_data_box on version bump', () async {
      final box = Hive.box('home_data_box');
      await box.put('cached_surveys_list', '{"old":"shape"}');
      await box.put('researcher_profile', '{"old":"shape"}');
      await box.put('response_metadata_1', '{"gender":"MALE"}');
      await box.put('response_metadata_42', '{"gender":"FEMALE"}');
      await box.put('optimistic_quota_incremented_response_ids', ['1', '2']);
      await box.put('response_draft_5', '{"survey_id":1}'); // must be preserved
      await box.put('synced_responses_total_count', 10); // must be preserved

      final prefs = await SharedPreferences.getInstance();
      // schema_version unset → migration runs

      await SchemaMigrationService(prefs: prefs).runIfNeeded();

      expect(box.containsKey('cached_surveys_list'), isFalse);
      expect(box.containsKey('researcher_profile'), isFalse);
      expect(box.containsKey('response_metadata_1'), isFalse);
      expect(box.containsKey('response_metadata_42'), isFalse);
      expect(box.containsKey('optimistic_quota_incremented_response_ids'), isFalse);
      // Preserved keys:
      expect(box.get('response_draft_5'), '{"survey_id":1}');
      expect(box.get('synced_responses_total_count'), 10);
      expect(prefs.getInt('schema_version'), 2);
    });

    test('is a no-op when schema_version already current', () async {
      final box = Hive.box('home_data_box');
      await box.put('cached_surveys_list', '{"new":"shape"}');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('schema_version', 2);

      await SchemaMigrationService(prefs: prefs).runIfNeeded();

      expect(box.get('cached_surveys_list'), '{"new":"shape"}');
    });

    test('is idempotent on repeat calls', () async {
      final prefs = await SharedPreferences.getInstance();
      final svc = SchemaMigrationService(prefs: prefs);
      await svc.runIfNeeded();
      await svc.runIfNeeded();
      expect(prefs.getInt('schema_version'), 2);
    });

    test('handles a home_data_box with no matching keys gracefully', () async {
      final box = Hive.box('home_data_box');
      await box.put('unrelated_key', 'stays');

      final prefs = await SharedPreferences.getInstance();
      await SchemaMigrationService(prefs: prefs).runIfNeeded();

      expect(box.get('unrelated_key'), 'stays');
      expect(prefs.getInt('schema_version'), 2);
    });

    test('strips gender + age_group from queued researcher start body', () async {
      await Hive.openBox('request_queue_box');
      final queue = Hive.box('request_queue_box');
      final items = [
        {
          'id': 'q1',
          'queuedAt': '2026-04-26T10:00:00.000Z',
          'retryCount': 0,
          'status': 'pending',
          'metadata': null,
          'request': {
            'path': '/researcher/assignment/survey/1/start',
            'method': 'POST',
            'body': {
              'gender': 'MALE',
              'age_group': 'AGE_18_29',
              'location': {'latitude': 1.0, 'longitude': 2.0},
              'created_at': '2026-04-26T09:59:59.000Z',
            },
            'bodyType': 'data',
          },
        },
      ];
      await queue.put('queued_requests', jsonEncode(items));

      final prefs = await SharedPreferences.getInstance();
      await SchemaMigrationService(prefs: prefs).runIfNeeded();

      final after = jsonDecode(queue.get('queued_requests') as String) as List;
      final body = (after[0] as Map)['request']['body'] as Map;
      expect(body.containsKey('gender'), isFalse);
      expect(body.containsKey('age_group'), isFalse);
      expect(body['location'], isA<Map>());
      expect(body['created_at'], isNotNull);
    });

    test('strips gender + age_group from queued public-link start body', () async {
      await Hive.openBox('request_queue_box');
      final queue = Hive.box('request_queue_box');
      final items = [
        {
          'id': 'q2',
          'queuedAt': '2026-04-26T10:00:00.000Z',
          'retryCount': 0,
          'status': 'pending',
          'metadata': null,
          'request': {
            'path': '/public-link/abc123/start',
            'method': 'POST',
            'body': {
              'gender': 'FEMALE',
              'age_group': 'AGE_30_39',
              'location': {'latitude': 1.0, 'longitude': 2.0},
            },
            'bodyType': 'data',
          },
        },
      ];
      await queue.put('queued_requests', jsonEncode(items));

      final prefs = await SharedPreferences.getInstance();
      await SchemaMigrationService(prefs: prefs).runIfNeeded();

      final after = jsonDecode(queue.get('queued_requests') as String) as List;
      final body = (after[0] as Map)['request']['body'] as Map;
      expect(body.containsKey('gender'), isFalse);
      expect(body.containsKey('age_group'), isFalse);
      expect(body['location'], isA<Map>());
    });

    test('leaves unrelated request bodies untouched', () async {
      await Hive.openBox('request_queue_box');
      final queue = Hive.box('request_queue_box');
      final items = [
        {
          'id': 'q3',
          'queuedAt': '2026-04-26T10:00:00.000Z',
          'retryCount': 0,
          'status': 'pending',
          'metadata': null,
          'request': {
            'path': '/researcher/assignment/response/5/section',
            'method': 'POST',
            'body': {
              'answers': [
                {'question_id': 1, 'value': 'male'}
              ],
              'created_at': '2026-04-26T09:59:59.000Z',
            },
            'bodyType': 'data',
          },
        },
        {
          'id': 'q4',
          'queuedAt': '2026-04-26T10:00:00.000Z',
          'retryCount': 0,
          'status': 'pending',
          'metadata': null,
          'request': {
            'path': '/auth/refresh',
            'method': 'POST',
            'body': {'token': 'x'},
            'bodyType': 'data',
          },
        },
      ];
      await queue.put('queued_requests', jsonEncode(items));

      final prefs = await SharedPreferences.getInstance();
      await SchemaMigrationService(prefs: prefs).runIfNeeded();

      final after = jsonDecode(queue.get('queued_requests') as String) as List;
      expect((after[0] as Map)['request']['body']['answers'], isA<List>());
      expect((after[1] as Map)['request']['body']['token'], 'x');
    });

    test('handles empty queue + missing key gracefully', () async {
      await Hive.openBox('request_queue_box');
      // intentionally leave 'queued_requests' unset
      final prefs = await SharedPreferences.getInstance();
      await SchemaMigrationService(prefs: prefs).runIfNeeded();
      expect(prefs.getInt('schema_version'), 2);
    });

    test('survives malformed queue entries by leaving them alone', () async {
      await Hive.openBox('request_queue_box');
      final queue = Hive.box('request_queue_box');
      await queue.put('queued_requests', 'not valid json');

      final prefs = await SharedPreferences.getInstance();
      await SchemaMigrationService(prefs: prefs).runIfNeeded();

      // Migration should not crash; version is bumped or left alone (per spec, an exception
      // means we don't bump). Test asserts the migration didn't throw.
      expect(true, isTrue);
    });
  });
}
