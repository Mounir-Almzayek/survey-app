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
  });
}
