import 'dart:convert';

import '../../models/save_section_models.dart';
import 'assignment_storage.dart';

/// Response section drafts (answers per response).
class ResponseDraftStore {
  static Future<void> save(int responseId, SaveSectionRequest request) async {
    final key = AssignmentStorageKeys.draft(responseId);
    await AssignmentStorage.setString(key, jsonEncode(request.toLocalJson()));
  }

  static Future<SaveSectionRequest?> get(int responseId) async {
    final key = AssignmentStorageKeys.draft(responseId);
    final jsonStr = await AssignmentStorage.getString(key);
    if (jsonStr == null) return null;
    try {
      return SaveSectionRequest.fromJson(jsonDecode(jsonStr));
    } catch (_) {
      return null;
    }
  }

  static Future<void> remove(int responseId) async {
    final key = AssignmentStorageKeys.draft(responseId);
    await AssignmentStorage.remove(key);
  }

  static Future<void> remap(int oldId, int newId) async {
    final oldKey = AssignmentStorageKeys.draft(oldId);
    final newKey = AssignmentStorageKeys.draft(newId);
    final data = await AssignmentStorage.getString(oldKey);
    if (data != null) {
      await AssignmentStorage.setString(newKey, data);
      await AssignmentStorage.remove(oldKey);
    }
  }
}
