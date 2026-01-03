import '../../../data/network/api_request.dart';
import '../models/researcher_login_initiate_request.dart';
import '../models/researcher_login_initiate_response.dart';
import '../models/researcher_login_verify_request.dart';
import '../models/researcher_login_verify_response.dart';

class AuthOnlineRepository {
  /// Initiate researcher login (Step 1)
  static Future<ResearcherLoginInitiateResponse> initiateResearcherLogin({
    required ResearcherLoginInitiateRequest request,
  }) async {
    final apiRequest = APIRequest(
      path: '/auth/researcher-login/initiate',
      method: HTTPMethod.post,
      body: request.toJson(),
      authorizationOption: AuthorizationOption.unauthorized,
    );
    final response = await apiRequest.send();
    return ResearcherLoginInitiateResponse.fromJson(
      response.data['data'] ?? response.data,
    );
  }

  /// Verify researcher login (Step 2)
  static Future<ResearcherLoginVerifyResponse> verifyResearcherLogin({
    required ResearcherLoginVerifyRequest request,
  }) async {
    final apiRequest = APIRequest(
      path: '/auth/researcher-login/verify-login',
      method: HTTPMethod.post,
      body: request.toJson(),
      authorizationOption: AuthorizationOption.unauthorized,
    );
    final response = await apiRequest.send();
    return ResearcherLoginVerifyResponse.fromJson(
      response.data['data'] ?? response.data,
    );
  }
}
