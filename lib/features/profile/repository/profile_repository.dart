import 'profile_local_repository.dart';
import 'profile_online_repository.dart';
import '../models/user.dart';

class ProfileRepository {
  /// Get profile data (chooses between local and online)
  static Future<User> getProfile({bool forceOnline = false}) async {
    if (forceOnline) {
      final user = await ProfileOnlineRepository.getProfile();
      await ProfileLocalRepository.saveUser(user);
      return user;
    }

    final localUser = await ProfileLocalRepository.getUser();
    if (localUser != null) {
      return localUser;
    }

    final onlineUser = await ProfileOnlineRepository.getProfile();
    await ProfileLocalRepository.saveUser(onlineUser);
    return onlineUser;
  }

  /// Perform logout (online and local)
  static Future<void> logout() async {
    try {
      await ProfileOnlineRepository.logout();
    } catch (_) {
      // Even if online logout fails, we clear local data
    } finally {
      await ProfileLocalRepository.clearProfileData();
    }
  }
}
