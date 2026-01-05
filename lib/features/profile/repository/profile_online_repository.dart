import '../../../data/network/api_request.dart';
import '../models/user.dart';

class ProfileOnlineRepository {
  /// Fetch profile from API (GET /auth/me)
  static Future<User> getProfile() async {
    final apiRequest = APIRequest(
      path: '/auth/me',
      method: HTTPMethod.get,
      authorizationOption: AuthorizationOption.authorized,
    );
    final response = await apiRequest.send();
    return User.fromJson(response.data['data'] ?? response.data);
  }

  /// Logout (POST /auth/me/logout)
  static Future<void> logout() async {
    final apiRequest = APIRequest(
      path: '/auth/me/logout',
      method: HTTPMethod.post,
      authorizationOption: AuthorizationOption.authorized,
    );
    await apiRequest.send();
  }
}
