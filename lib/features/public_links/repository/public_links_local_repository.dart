import 'dart:convert';
import '../../../core/services/hive_service.dart';
import '../models/public_link.dart';
import '../models/save_section_answers_request.dart';
import '../models/public_link_active_response.dart';

class PublicLinksLocalRepository {
  static const String _publicLinksKey = 'public_links_list';
  static const String _sectionAnswersKeyPrefix = 'section_answers_';
  static const String _activeResponsesKey =
      'active_public_link_responses_index';

  /// Save public links list to local storage
  static Future<void> savePublicLinks(List<PublicLink> links) async {
    try {
      final jsonList = links.map((link) => link.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await HiveService.saveData(_publicLinksKey, jsonString);
    } catch (e) {
      // Log or handle error
    }
  }

  /// Retrieve public links list from local storage
  static Future<List<PublicLink>> getPublicLinks() async {
    try {
      final jsonString = await HiveService.getData(_publicLinksKey) as String?;
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((item) => PublicLink.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get a single public link by ID from local storage
  static Future<PublicLink?> getPublicLinkById(int id) async {
    final links = await getPublicLinks();
    try {
      return links.firstWhere((link) => link.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get a single public link by short code from local storage
  static Future<PublicLink?> getPublicLinkByShortCode(String shortCode) async {
    final links = await getPublicLinks();
    try {
      return links.firstWhere((link) => link.shortCode == shortCode);
    } catch (e) {
      return null;
    }
  }

  /// Save/Update an active response in the index
  static Future<void> saveActiveResponse(
    PublicLinkActiveResponse activeResponse,
  ) async {
    try {
      final responses = await getActiveResponses();
      final index = responses.indexWhere(
        (r) => r.shortCode == activeResponse.shortCode,
      );

      if (index != -1) {
        responses[index] = activeResponse;
      } else {
        responses.add(activeResponse);
      }

      final jsonString = json.encode(responses.map((r) => r.toJson()).toList());
      await HiveService.saveData(_activeResponsesKey, jsonString);
    } catch (e) {}
  }

  /// Get all active responses from the index
  static Future<List<PublicLinkActiveResponse>> getActiveResponses() async {
    try {
      final activeJson =
          await HiveService.getData(_activeResponsesKey) as String?;
      if (activeJson == null || activeJson.isEmpty) return [];
      final jsonList = json.decode(activeJson) as List<dynamic>;
      return jsonList
          .map(
            (item) =>
                PublicLinkActiveResponse.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Remove an active response from the index
  static Future<void> removeActiveResponse(String shortCode) async {
    try {
      final responses = await getActiveResponses();
      responses.removeWhere((r) => r.shortCode == shortCode);

      final jsonString = json.encode(responses.map((r) => r.toJson()).toList());
      await HiveService.saveData(_activeResponsesKey, jsonString);
    } catch (e) {}
  }

  /// Save section answers request to local storage
  static Future<void> saveSectionAnswersRequest({
    required String shortCode,
    required int responseId,
    required int sectionId,
    required SaveSectionAnswersRequest request,
  }) async {
    try {
      final key =
          '$_sectionAnswersKeyPrefix${shortCode}_${responseId}_$sectionId';
      final jsonString = json.encode(request.toJson(forApi: false));
      await HiveService.saveData(key, jsonString);
    } catch (e) {
      // ignore
    }
  }

  /// Get section answers request from local storage
  static Future<SaveSectionAnswersRequest?> getSectionAnswersRequest({
    required String shortCode,
    required int responseId,
    required int sectionId,
  }) async {
    try {
      final key =
          '$_sectionAnswersKeyPrefix${shortCode}_${responseId}_$sectionId';
      final jsonString = await HiveService.getData(key) as String?;
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return SaveSectionAnswersRequest.fromJson(jsonData);
    } catch (e) {
      return null;
    }
  }

  /// Clear all public links from local storage
  static Future<void> clearPublicLinks() async {
    await HiveService.deleteData(_publicLinksKey);
    await HiveService.deleteData(_activeResponsesKey);
  }
}
