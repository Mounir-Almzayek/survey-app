import 'profile_local_repository.dart';
import 'profile_online_repository.dart';
import '../models/researcher_profile_response_model.dart';

class ProfileRepository {
  /// Get profile data (chooses between local and online)
  static Future<ResearcherProfileResponseModel> getProfile({
    bool forceOnline = false,
  }) async {
    if (forceOnline) {
      final profile = await ProfileOnlineRepository.getResearcherProfile();
      await ProfileLocalRepository.saveResearcherProfile(profile);
      return profile;
    }

    // Try to get from local storage first
    final localProfile = await ProfileLocalRepository.getResearcherProfile();
    if (localProfile != null) {
      return localProfile;
    }

    // If no local data, fetch from online
    final onlineProfile = await ProfileOnlineRepository.getResearcherProfile();
    await ProfileLocalRepository.saveResearcherProfile(onlineProfile);
    return onlineProfile;
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
