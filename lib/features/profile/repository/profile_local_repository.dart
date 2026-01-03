import '../../auth/repository/auth_local_repository.dart';
import '../models/user.dart';

class ProfileLocalRepository {
  /// Get current user data
  static Future<User?> getUser() async {
    return await AuthLocalRepository.getUser();
  }

  /// Save/Update user data
  static Future<void> saveUser(User user) async {
    await AuthLocalRepository.saveUser(user);
  }

  /// Clear user data (handled by AuthLocalRepository.clearAuthData usually)
  static Future<void> clearProfileData() async {
    await AuthLocalRepository.clearAuthData();
  }
}
