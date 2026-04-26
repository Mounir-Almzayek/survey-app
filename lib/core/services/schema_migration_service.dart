import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'storage_service.dart';

/// Runs once per app launch (early, before any survey/profile read) to bring
/// the local cache in line with [StorageService.currentSchemaVersion].
///
/// When the persisted `schema_version` is older than the current value, this
/// clears keys in `home_data_box` whose value-shape changed (surveys, profile,
/// response metadata, the obsolete optimistic-quota tracker). Response drafts
/// and completed-response keys are intentionally preserved — the new parsers
/// are tolerant of the legacy `gender`/`age_group` fields.
///
/// Queue sanitization (stripping obsolete keys from queued request bodies) is
/// added in Task 3.
class SchemaMigrationService {
  static const String _versionKey = 'schema_version';
  static const String _homeDataBox = 'home_data_box';

  // Keys whose value shape changed and must be wiped:
  static const String _surveysKey = 'cached_surveys_list';
  static const String _profileKey = 'researcher_profile';
  static const String _optimisticTrackerKey = 'optimistic_quota_incremented_response_ids';
  static const String _metadataKeyPrefix = 'response_metadata_';

  final SharedPreferences prefs;

  SchemaMigrationService({required this.prefs});

  Future<void> runIfNeeded() async {
    final stored = prefs.getInt(_versionKey) ?? 1;
    if (stored >= StorageService.currentSchemaVersion) return;

    try {
      await _wipeKeysInHomeBox();
      await prefs.setInt(_versionKey, StorageService.currentSchemaVersion);
    } catch (e, st) {
      // Log but do not bump version; next launch retries.
      // ignore: avoid_print
      print('SchemaMigrationService failed: $e\n$st');
    }
  }

  Future<void> _wipeKeysInHomeBox() async {
    if (!Hive.isBoxOpen(_homeDataBox)) {
      await Hive.openBox(_homeDataBox);
    }
    final box = Hive.box(_homeDataBox);

    await box.delete(_surveysKey);
    await box.delete(_profileKey);
    await box.delete(_optimisticTrackerKey);

    final metadataKeys = box.keys
        .map((k) => k.toString())
        .where((k) => k.startsWith(_metadataKeyPrefix))
        .toList();
    if (metadataKeys.isNotEmpty) {
      await box.deleteAll(metadataKeys);
    }
  }
}
