import '../../../core/services/storage_service.dart';

class DeviceCookieRepository {
  static const String _deviceCookieKey = 'device_cookie';

  /// Save device cookie
  static Future<void> saveDeviceCookie(String cookie) async {
    await StorageService.setString(_deviceCookieKey, cookie);
  }

  /// Retrieve device cookie
  static String? getDeviceCookie() {
    return StorageService.getString(_deviceCookieKey);
  }

  /// Clear device cookie
  static Future<void> clearDeviceCookie() async {
    await StorageService.remove(_deviceCookieKey);
  }
}
