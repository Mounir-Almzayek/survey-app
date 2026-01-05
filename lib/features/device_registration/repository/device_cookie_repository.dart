import '../../../core/services/secure_storage_service.dart';

class DeviceCookieRepository {
  static const String _deviceCookieKey = 'device_cookie';
  static final SecureStorageService _secureStorage = SecureStorageService();

  /// Save device cookie securely
  static Future<void> saveDeviceCookie(String cookie) async {
    await _secureStorage.write(_deviceCookieKey, cookie);
  }

  /// Retrieve device cookie securely
  static Future<String?> getDeviceCookie() async {
    return await _secureStorage.read(_deviceCookieKey);
  }

  /// Clear device cookie
  static Future<void> clearDeviceCookie() async {
    await _secureStorage.delete(_deviceCookieKey);
  }
}
