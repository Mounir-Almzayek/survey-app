import '../../../data/network/api_request.dart';
import '../models/researcher_profile_response_model.dart';

class ProfileOnlineRepository {
  /// Fetch researcher profile from API (GET /researcher/profile)
  static Future<ResearcherProfileResponseModel> getResearcherProfile() async {
    final apiRequest = APIRequest(
      path: '/researcher/profile',
      method: HTTPMethod.get,
      authorizationOption: AuthorizationOption.authorized,
    );
    final response = await apiRequest.send();
    return ResearcherProfileResponseModel.fromJson(
      response.data['data'] ?? response.data,
    );
  }

  /// Logout (POST /auth/me/logout)
  static Future<void> logout() async {
    final apiRequest = APIRequest(
      path: '/auth/me/logout',
      method: HTTPMethod.post,
      body: {}, // Provide empty body
      authorizationOption: AuthorizationOption.authorized,
    );
    await apiRequest.send();
  }
}
