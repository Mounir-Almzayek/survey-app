import '../models/login_method_type.dart';
import '../../../core/services/hive_service.dart';

class AuthLocalRepository {
  static const String _tokenKey = 'token';
  static const String _loginMethodKey = 'login_method';

  /// Retrieve saved token
  static Future<String> retrieveToken() async {
    // return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6OCwiYm91bmRfZGV2aWNlX2lkIjo0LCJpYXQiOjE3NjgyMjk5MjUsImV4cCI6MTc2ODgzNDcyNX0.IMWZ0l47-p5F8mC7paFcOT_YkwzIhU7Zi4CYC9vxjmE";

    final tokenValue = await HiveService.getData(_tokenKey) as String?;
    return tokenValue ?? "";
  }

  /// Save token to Hive database
  static Future<void> saveToken(String token) async {
    await HiveService.saveData(_tokenKey, token);
  }

  /// Save login method (challenge vs email-only)
  static Future<void> saveLoginMethod(LoginMethodType type) async {
    await HiveService.saveData(_loginMethodKey, type.name);
  }

  /// Get login method used for current session (null when not logged in)
  static Future<LoginMethodType?> getLoginMethod() async {
    final value = await HiveService.getData(_loginMethodKey) as String?;
    if (value == null || value.isEmpty) return null;
    return switch (value) {
      'challenge' => LoginMethodType.challenge,
      'emailOnly' => LoginMethodType.emailOnly,
      _ => null,
    };
  }

  /// Clear authentication-related data
  static Future<void> clearAuthData() async {
    await HiveService.deleteData(_tokenKey);
    await HiveService.deleteData(_loginMethodKey);
  }
}
