import '../models/login_method_type.dart';
import '../../../core/services/hive_service.dart';
import '../../../../core/models/pending_custody.dart';

class AuthLocalRepository {
  static const String _tokenKey = 'token';
  static const String _loginMethodKey = 'login_method';
  static const String _shouldVerifyCustodyKey = 'should_verify_custody';
  static const String _pendingCustodyKey = 'pending_custody';

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
    await HiveService.deleteData(_shouldVerifyCustodyKey);
    await HiveService.deleteData(_pendingCustodyKey);
  }

  /// Save custody verification state
  static Future<void> saveCustodyVerificationState({
    required bool shouldVerify,
    PendingCustody? pendingCustody,
  }) async {
    await HiveService.saveData(_shouldVerifyCustodyKey, shouldVerify);
    if (pendingCustody != null) {
      await HiveService.saveData(_pendingCustodyKey, pendingCustody.toJson());
    } else {
      await HiveService.deleteData(_pendingCustodyKey);
    }
  }

  /// Get custody verification state
  static Future<(bool shouldVerify, PendingCustody? pendingCustody)>
  getCustodyVerificationState() async {
    final shouldVerify =
        await HiveService.getData(_shouldVerifyCustodyKey) as bool? ?? false;

    PendingCustody? pendingCustody;
    final custodyData = await HiveService.getData(_pendingCustodyKey);
    if (custodyData != null && custodyData is Map) {
      // Convert dynamic Map to Map<String, dynamic>
      final stringKeyedMap = Map<String, dynamic>.from(custodyData);
      pendingCustody = PendingCustody.fromJson(stringKeyedMap);
    }

    return (shouldVerify, pendingCustody);
  }

  /// Clear custody verification state
  static Future<void> clearCustodyVerificationState() async {
    await HiveService.deleteData(_shouldVerifyCustodyKey);
    await HiveService.deleteData(_pendingCustodyKey);
  }
}
