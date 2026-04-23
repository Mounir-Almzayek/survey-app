import '../../../../core/services/hive_service.dart';

/// Centralized keys for assignment local storage (must match legacy keys for migration).
abstract class AssignmentStorageKeys {
  static const String surveys = 'cached_surveys_list';
  static const String syncedCount = 'synced_responses_total_count';
  static const String negativeIdCounter = 'negative_response_id_counter';

  static String draft(int responseId) => 'response_draft_$responseId';
  static String metadata(int responseId) => 'response_metadata_$responseId';
  static String completed(int surveyId) => 'completed_responses_$surveyId';
  static const String optimisticQuotaIncrementedIds =
      'optimistic_quota_incremented_response_ids';
  static const String searchHistory = 'recent_survey_searches';
}

/// Assignment local storage via Hive (same service used by auth, profile, etc.).
class AssignmentStorage {
  static Future<String?> getString(String key) async {
    try {
      final value = await HiveService.getData(key);
      return value is String ? value : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> setString(String key, String value) async {
    try {
      await HiveService.saveData(key, value);
    } catch (_) {}
  }

  static Future<void> remove(String key) async {
    try {
      await HiveService.deleteData(key);
    } catch (_) {}
  }

  /// Remove all keys that belong to assignment feature (for logout).
  static Future<void> clearAllAssignmentKeys() async {
    try {
      final keys = await HiveService.getDefaultBoxKeys();
      for (final key in keys) {
        if (key == AssignmentStorageKeys.surveys ||
            key == AssignmentStorageKeys.syncedCount ||
            key == AssignmentStorageKeys.negativeIdCounter ||
            key == AssignmentStorageKeys.optimisticQuotaIncrementedIds ||
            key.startsWith('response_draft_') ||
            key.startsWith('response_metadata_') ||
            key.startsWith('completed_responses_')) {
          await HiveService.deleteData(key);
        }
      }
    } catch (_) {}
  }

  static Future<List<String>?> getStringList(String key) async {
    try {
      final value = await HiveService.getData(key);
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> setStringList(String key, List<String> value) async {
    try {
      await HiveService.saveData(key, value);
    } catch (_) {}
  }

  static Future<int?> getInt(String key) async {
    try {
      final value = await HiveService.getData(key);
      if (value is int) return value;
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> setInt(String key, int value) async {
    try {
      await HiveService.saveData(key, value);
    } catch (_) {}
  }
}
