import 'assignment_storage.dart';

/// Completed response IDs per survey.
class CompletedResponsesStore {
  static Future<void> add(int surveyId, int responseId) async {
    final key = AssignmentStorageKeys.completed(surveyId);
    final current = await AssignmentStorage.getStringList(key) ?? [];
    if (!current.contains(responseId.toString())) {
      current.add(responseId.toString());
      await AssignmentStorage.setStringList(key, current);
    }
  }

  static Future<List<int>> get(int surveyId) async {
    final key = AssignmentStorageKeys.completed(surveyId);
    final list = await AssignmentStorage.getStringList(key) ?? [];
    try {
      return list.map((e) => int.parse(e)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Remap oldId to newId in completed lists for the given survey ids.
  static Future<void> remap(
    List<int> surveyIds,
    int oldId,
    int newId,
  ) async {
    final oldStr = oldId.toString();
    final newStr = newId.toString();
    for (final surveyId in surveyIds) {
      final key = AssignmentStorageKeys.completed(surveyId);
      final list = await AssignmentStorage.getStringList(key);
      if (list != null && list.contains(oldStr)) {
        final updated = list
            .map((id) => id == oldStr ? newStr : id)
            .toList();
        await AssignmentStorage.setStringList(key, updated);
      }
    }
  }
}
