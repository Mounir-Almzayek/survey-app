import 'assignment_storage.dart';

/// Sync count and negative ID generation for offline responses.
class SyncAndIdStore {
  static Future<int> getNextNegativeId() async {
    final key = AssignmentStorageKeys.negativeIdCounter;
    final current = await AssignmentStorage.getInt(key) ?? 0;
    final next = current - 1;
    await AssignmentStorage.setInt(key, next);
    return next;
  }

  static Future<int> getSyncedResponsesCount() async {
    final v = await AssignmentStorage.getInt(AssignmentStorageKeys.syncedCount);
    return v ?? 0;
  }

  static Future<void> incrementSyncedResponsesCount() async {
    final key = AssignmentStorageKeys.syncedCount;
    final current = await AssignmentStorage.getInt(key) ?? 0;
    await AssignmentStorage.setInt(key, current + 1);
  }
}
