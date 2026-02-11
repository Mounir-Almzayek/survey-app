import 'dart:convert';
import '../../../core/services/hive_service.dart';
import '../models/researcher_profile_response_model.dart';

class ProfileLocalRepository {
  static const String _researcherProfileKey = 'researcher_profile';

  /// Get current researcher profile data
  static Future<ResearcherProfileResponseModel?> getResearcherProfile() async {
    try {
      final jsonString =
          await HiveService.getData(_researcherProfileKey) as String?;
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return ResearcherProfileResponseModel.fromJson(jsonData);
    } catch (e) {
      return null;
    }
  }

  /// Save/Update researcher profile data
  static Future<void> saveResearcherProfile(
    ResearcherProfileResponseModel profile,
  ) async {
    try {
      final jsonString = json.encode(profile.toJson());
      await HiveService.saveData(_researcherProfileKey, jsonString);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Clear researcher profile data
  static Future<void> clearProfileData() async {
    await HiveService.deleteData(_researcherProfileKey);
  }
}
