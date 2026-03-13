import '../../auth/repository/auth_repository.dart';
import '../../assignment/repository/assignment_local_repository.dart';
import '../../custody/repository/custody_local_repository.dart';
import '../../device_location/repository/device_location_local_repository.dart';
import '../../device_registration/repository/device_cookie_repository.dart';
import '../../public_links/repository/public_links_local_repository.dart';
import '../../responses/repository/responses_local_repository.dart';
import '../../upload/repository/upload_local_repository.dart';
import '../../../core/queue/services/request_queue_service.dart';
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

  /// Perform logout (online and local).
  /// Also clears all user-specific local data so the next account sees a clean state.
  static Future<void> logout() async {
    try {
      await ProfileOnlineRepository.logout();
    } catch (_) {
      // Even if online logout fails, we clear local data
    } finally {
      await ProfileLocalRepository.clearProfileData();
      await AuthRepository.logout();
      // Clear all data that might belong to the previous account
      await AssignmentLocalRepository.clearAllForLogout();
      await RequestQueueService.clearAll();
      await CustodyLocalRepository.clearCustodyRecords();
      await UploadLocalRepository.clearPendingUploads();
      await UploadLocalRepository.clearFailedUploads();
      await DeviceLocationLocalRepository.clearPendingLocations();
      await PublicLinksLocalRepository.clearPublicLinks();
      await ResponsesLocalRepository.clearAll();
      await DeviceCookieRepository.clearDeviceCookie();
    }
  }
}
