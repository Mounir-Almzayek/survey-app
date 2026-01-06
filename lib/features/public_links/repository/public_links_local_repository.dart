import '../../../core/services/hive_service.dart';
import '../models/public_link.dart';

/// Repository for public links local storage
class PublicLinksLocalRepository {
  static const String _publicLinksKey = 'public_links';
  static const String _lastSyncKey = 'public_links_last_sync';

  /// Save public links locally
  static Future<void> savePublicLinks(List<PublicLink> links) async {
    final linksJson = links.map((link) => link.toJson()).toList();
    await HiveService.saveData(_publicLinksKey, linksJson);
    await HiveService.saveData(_lastSyncKey, DateTime.now().toIso8601String());
  }

  /// Get public links from local storage
  static Future<List<PublicLink>> getPublicLinks() async {
    try {
      final data = await HiveService.getData(_publicLinksKey) as List<dynamic>?;
      if (data == null) return [];
      
      return data.map((item) => PublicLink.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get last sync time
  static Future<DateTime?> getLastSync() async {
    try {
      final syncStr = await HiveService.getData(_lastSyncKey) as String?;
      if (syncStr == null) return null;
      return DateTime.parse(syncStr);
    } catch (e) {
      return null;
    }
  }

  /// Clear local public links
  static Future<void> clearPublicLinks() async {
    await HiveService.deleteData(_publicLinksKey);
    await HiveService.deleteData(_lastSyncKey);
  }
}

