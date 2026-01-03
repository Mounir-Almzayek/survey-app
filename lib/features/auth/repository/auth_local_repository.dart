import 'dart:convert';
import '../../../core/services/hive_service.dart';
import '../../profile/models/user.dart';

class AuthLocalRepository {
  static const String _tokenKey = 'token';
  static const String _userKey = 'user';

  /// Retrieve saved token
  static Future<String> retrieveToken() async {
    final tokenValue = await HiveService.getData(_tokenKey) as String?;
    return tokenValue ?? "";
  }

  /// Save token to Hive database
  static Future<void> saveToken(String token) async {
    await HiveService.saveData(_tokenKey, token);
  }

  /// Save user to Hive database
  static Future<void> saveUser(User user) async {
    try {
      final jsonString = json.encode(user.toJson());
      await HiveService.saveData(_userKey, jsonString);
    } catch (e) {}
  }

  /// Retrieve saved user from Hive database
  static Future<User?> getUser() async {
    try {
      final jsonString = await HiveService.getData(_userKey) as String?;
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return User.fromJson(jsonData);
    } catch (e) {
      return null;
    }
  }

  /// Clear authentication-related data
  static Future<void> clearAuthData() async {
    await HiveService.deleteData(_tokenKey);
    await HiveService.deleteData(_userKey);
  }
}
