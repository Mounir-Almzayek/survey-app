import '../../../data/network/api_request.dart';
import '../models/email_verification_request.dart';
import '../models/resend_verification_request.dart';
import '../models/forgot_password_request.dart';
import '../models/reset_password_request.dart';
import '../models/researcher_login_initiate_request.dart';
import '../models/researcher_login_initiate_response.dart';
import '../models/researcher_login_verify_request.dart';
import '../models/researcher_login_verify_response.dart';
import '../models/message_response.dart';

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

  /// Verify email confirmation code
  static Future<MessageResponse> verifyEmail(
    EmailVerificationRequest request,
  ) async {
    final apiRequest = APIRequest(
      path: '/auth/register/verify-email',
      method: HTTPMethod.post,
      body: request.toJson(),
      authorizationOption: AuthorizationOption.unauthorized,
    );
    final response = await apiRequest.send();
    return MessageResponse.fromJson(response.data);
  }

  /// Resend email confirmation code
  static Future<MessageResponse> resendVerificationCode(
    ResendVerificationRequest request,
  ) async {
    final apiRequest = APIRequest(
      path: '/auth/register/resend-email-confirmation-code',
      method: HTTPMethod.post,
      body: request.toJson(),
      authorizationOption: AuthorizationOption.unauthorized,
    );
    final response = await apiRequest.send();
    return MessageResponse.fromJson(response.data);
  }

  /// Initiate password reset
  static Future<MessageResponse> requestPasswordReset(
    ForgotPasswordRequest request,
  ) async {
    final apiRequest = APIRequest(
      path: '/auth/reset-password/prepare',
      method: HTTPMethod.post,
      body: request.toJson(),
      authorizationOption: AuthorizationOption.unauthorized,
    );
    final response = await apiRequest.send();
    return MessageResponse.fromJson(response.data);
  }

  /// Reset password using code
  static Future<MessageResponse> resetPassword(
    ResetPasswordRequest request,
  ) async {
    final apiRequest = APIRequest(
      path: '/auth/reset-password/reset',
      method: HTTPMethod.post,
      body: request.toJson(),
      authorizationOption: AuthorizationOption.unauthorized,
    );
    final response = await apiRequest.send();
    return MessageResponse.fromJson(response.data);
  }
}
