import 'dart:convert';
import '../../../core/services/hive_service.dart';
import '../models/public_link.dart';

class PublicLinksLocalRepository {
  static const String _publicLinksKey = 'public_links_list';

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

  /// Clear all public links from local storage
  static Future<void> clearPublicLinks() async {
    await HiveService.deleteData(_publicLinksKey);
  }
}
