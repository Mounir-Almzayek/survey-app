import 'auth_local_repository.dart';
import 'auth_online_repository.dart';
import '../models/email_verification_request.dart';
import '../models/resend_verification_request.dart';
import '../models/forgot_password_request.dart';
import '../models/reset_password_request.dart';
import '../models/researcher_login_initiate_request.dart';
import '../models/researcher_login_initiate_response.dart';
import '../models/researcher_login_verify_request.dart';
import '../models/researcher_login_verify_response.dart';
import '../models/message_response.dart';

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

    // 1. Save token locally first (needed for authorized requests)
    await AuthLocalRepository.saveToken(response.accessToken);

    return response;
  }

  /// Verify email confirmation code
  static Future<MessageResponse> verifyEmail(
    EmailVerificationRequest request,
  ) async {
    return await AuthOnlineRepository.verifyEmail(request);
  }

  /// Resend email confirmation code
  static Future<MessageResponse> resendVerificationCode(
    ResendVerificationRequest request,
  ) async {
    return await AuthOnlineRepository.resendVerificationCode(request);
  }

  /// Initiate password reset
  static Future<MessageResponse> requestPasswordReset(
    ForgotPasswordRequest request,
  ) async {
    return await AuthOnlineRepository.requestPasswordReset(request);
  }

  /// Reset password using code
  static Future<MessageResponse> resetPassword(
    ResetPasswordRequest request,
  ) async {
    return await AuthOnlineRepository.resetPassword(request);
  }

  /// Logout and clear all auth data
  static Future<void> logout() async {
    await AuthLocalRepository.clearAuthData();
  }
}
