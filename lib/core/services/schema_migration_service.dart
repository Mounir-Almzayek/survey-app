import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'storage_service.dart';

/// Runs once per app launch (early, before any survey/profile read) to bring
/// the local cache in line with [StorageService.currentSchemaVersion].
///
/// When the persisted `schema_version` is older than the current value, this:
///   - clears the keys in `home_data_box` whose value-shape changed
///     (`cached_surveys_list`, `researcher_profile`, `response_metadata_*`,
///     `optimistic_quota_incremented_response_ids`)
///   - strips obsolete `gender` and `age_group` keys from any queued
///     start-response request bodies so the new server doesn't reject replays
///
/// Response drafts and completed-response keys are intentionally preserved —
/// the new parsers tolerate the legacy `gender`/`age_group` fields.
class SchemaMigrationService {
  static const String _versionKey = 'schema_version';
  static const String _homeDataBox = 'home_data_box';
  static const String _queueBox = 'request_queue_box';
  static const String _queueListKey = 'queued_requests';

  // Keys whose value shape changed and must be wiped:
  static const String _surveysKey = 'cached_surveys_list';
  static const String _profileKey = 'researcher_profile';
  static const String _optimisticTrackerKey = 'optimistic_quota_incremented_response_ids';
  static const String _metadataKeyPrefix = 'response_metadata_';

  // Paths whose request bodies used to carry `gender` / `age_group`.
  static final RegExp _startPathPattern = RegExp(
    r'^/researcher/assignment/survey/\d+/start$|^/public-link/[^/]+/start$',
  );

  final SharedPreferences prefs;

  SchemaMigrationService({required this.prefs});

  Future<void> runIfNeeded() async {
    final stored = prefs.getInt(_versionKey) ?? 1;
    if (stored >= StorageService.currentSchemaVersion) return;

    try {
      await _wipeKeysInHomeBox();
      await _sanitizeQueue();
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

  Future<void> _sanitizeQueue() async {
    if (!Hive.isBoxOpen(_queueBox)) {
      await Hive.openBox(_queueBox);
    }
    final box = Hive.box(_queueBox);

    final raw = box.get(_queueListKey);
    if (raw is! String || raw.isEmpty) return;

    List<dynamic> items;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      items = decoded;
    } catch (_) {
      // Malformed entry — leave as-is rather than dropping queued user data.
      return;
    }

    var changed = false;
    for (final item in items) {
      if (item is! Map) continue;
      final request = item['request'];
      if (request is! Map) continue;
      final path = request['path'];
      if (path is! String) continue;
      if (!_startPathPattern.hasMatch(path)) continue;
      final body = request['body'];
      if (body is! Map) continue;

      if (body.remove('gender') != null) changed = true;
      if (body.remove('age_group') != null) changed = true;
    }

    if (changed) {
      await box.put(_queueListKey, jsonEncode(items));
    }
  }
}
