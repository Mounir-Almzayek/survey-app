import 'auth_local_repository.dart';
import 'auth_online_repository.dart';
import '../models/researcher_login_initiate_request.dart';
import '../models/researcher_login_initiate_response.dart';
import '../models/researcher_login_verify_request.dart';
import '../models/researcher_login_verify_response.dart';

class AuthRepository {
  /// Researcher Login - Step 1: Initiate
  static Future<ResearcherLoginInitiateResponse> initiateResearcherLogin({
    required ResearcherLoginInitiateRequest request,
  }) async {
    return await AuthOnlineRepository.initiateResearcherLogin(request: request);
  }

  /// Researcher Login - Step 2: Verify
  static Future<ResearcherLoginVerifyResponse> verifyResearcherLogin({
    required ResearcherLoginVerifyRequest request,
  }) async {
    final response = await AuthOnlineRepository.verifyResearcherLogin(
      request: request,
    );

    // Save token and user data locally upon successful login
    await AuthLocalRepository.saveToken(response.accessToken);
    await AuthLocalRepository.saveUser(response.user);

    return response;
  }

  /// Logout and clear all auth data
  static Future<void> logout() async {
    await AuthLocalRepository.clearAuthData();
  }
}
