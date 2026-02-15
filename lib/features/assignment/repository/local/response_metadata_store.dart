import 'dart:convert';

import '../../../../core/enums/survey_enums.dart';
import '../../models/response_metadata.dart';
import 'assignment_storage.dart';

/// Response demographic metadata (links responseId to who we're collecting for).
class ResponseMetadataStore {
  static Future<void> save(
    int responseId,
    int surveyId,
    Gender gender,
    AgeGroup ageGroup,
  ) async {
    final key = AssignmentStorageKeys.metadata(responseId);
    final meta = ResponseMetadata(
      surveyId: surveyId,
      gender: gender,
      ageGroup: ageGroup,
    );
    await AssignmentStorage.setString(key, jsonEncode(meta.toJson()));
  }

  static Future<ResponseMetadata?> get(int responseId) async {
    final key = AssignmentStorageKeys.metadata(responseId);
    final jsonStr = await AssignmentStorage.getString(key);
    if (jsonStr == null) return null;
    try {
      return ResponseMetadata.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> remove(int responseId) async {
    final key = AssignmentStorageKeys.metadata(responseId);
    await AssignmentStorage.remove(key);
  }

  static Future<void> remap(int oldId, int newId) async {
    final oldKey = AssignmentStorageKeys.metadata(oldId);
    final newKey = AssignmentStorageKeys.metadata(newId);
    final data = await AssignmentStorage.getString(oldKey);
    if (data != null) {
      await AssignmentStorage.setString(newKey, data);
      await AssignmentStorage.remove(oldKey);
    }
  }
}
