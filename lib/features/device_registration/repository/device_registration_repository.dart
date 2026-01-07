import '../../../data/network/api_request.dart';
import '../models/validate_token_request.dart';
import '../models/validate_token_response.dart';
import '../models/cookie_based_complete_request.dart';
import '../models/complete_registration_response.dart';
import '../models/device_bound_key_challenge_request.dart';
import '../models/device_bound_key_challenge_response.dart';
import '../models/device_bound_key_complete_request.dart';
import '../models/verify_key_response.dart';

class DeviceRegistrationRepository {
  /// Validate device registration token
  static Future<ValidateTokenResponse> validateToken({
    required ValidateTokenRequest request,
  }) async {
    final apiRequest = APIRequest(
      path: '/device-registration/validate-token/${request.token}',
      method: HTTPMethod.get,
      authorizationOption: AuthorizationOption.unauthorized,
    );
    final response = await apiRequest.send();
    return ValidateTokenResponse.fromJson(
      response.data['data'] ?? response.data,
    );
  }

  /// Complete cookie-based registration
  static Future<CompleteRegistrationResponse> completeCookieBasedRegistration({
    required CookieBasedCompleteRequest request,
  }) async {
    final apiRequest = APIRequest(
      path:
          '/device-registration/register/cookie-based/complete/${request.token}',
      method: HTTPMethod.post,
      body: request.toJson(),
      authorizationOption: AuthorizationOption.unauthorized,
    );
    final response = await apiRequest.send();
    return CompleteRegistrationResponse.fromJson(response.data);
  }

  /// Get Device-Bound Key challenge
  static Future<DeviceBoundKeyChallengeResponse> getDeviceBoundKeyChallenge({
    required DeviceBoundKeyChallengeRequest request,
  }) async {
    final apiRequest = APIRequest(
      path:
          '/device-registration/register/device-bound-key/challenge/${request.token}',
      method: HTTPMethod.post,
      body: request.toJson(),
      authorizationOption: AuthorizationOption.unauthorized,
    );
    final response = await apiRequest.send();
    return DeviceBoundKeyChallengeResponse.fromJson(
      response.data['data'] ?? response.data,
    );
  }

  /// Complete Device-Bound Key registration
  static Future<CompleteRegistrationResponse>
  completeDeviceBoundKeyRegistration({
    required DeviceBoundKeyCompleteRequest request,
  }) async {
    final apiRequest = APIRequest(
      path:
          '/device-registration/register/device-bound-key/complete/${request.token}',
      method: HTTPMethod.post,
      body: request.toJson(),
      authorizationOption: AuthorizationOption.unauthorized,
    );
    final response = await apiRequest.send();
    return CompleteRegistrationResponse.fromJson(response.data);
  }

  /// Verify if a device key is still valid
  static Future<VerifyKeyResponse> verifyKey({required String keyId}) async {
    final apiRequest = APIRequest(
      path: '/device-registration/verify-key/$keyId',
      method: HTTPMethod.get,
      authorizationOption: AuthorizationOption.unauthorized,
    );
    final response = await apiRequest.send();
    return VerifyKeyResponse.fromJson(response.data);
  }
}
