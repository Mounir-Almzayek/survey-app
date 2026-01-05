import 'webauthn_login_options.dart';
import 'device_bound_key_login_options.dart';

/// Login method types
enum LoginMethod { webauthn, deviceBoundKey, cookieBased }

class ResearcherLoginInitiateResponse {
  final String method;
  final WebAuthnLoginOptions? webauthnOptions;
  final DeviceBoundKeyLoginOptions? deviceBoundKeyOptions;
  final String? cookie;

  ResearcherLoginInitiateResponse({
    required this.method,
    this.webauthnOptions,
    this.deviceBoundKeyOptions,
    this.cookie,
  });

  /// Get login method enum
  LoginMethod get loginMethod {
    switch (method.toLowerCase()) {
      case 'webauthn':
      case 'passkey':
        return LoginMethod.webauthn;
      case 'device-bound-key':
      case 'deviceboundkey':
        return LoginMethod.deviceBoundKey;
      default:
        return LoginMethod.cookieBased;
    }
  }

  /// Get options (for backward compatibility)
  dynamic get options {
    switch (loginMethod) {
      case LoginMethod.webauthn:
        return webauthnOptions;
      case LoginMethod.deviceBoundKey:
        return deviceBoundKeyOptions;
      default:
        return null;
    }
  }

  factory ResearcherLoginInitiateResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final method = json['method'] ?? data?['method'] ?? '';
    final optionsData = json['options'] ?? data?['options'];

    WebAuthnLoginOptions? webauthnOptions;
    DeviceBoundKeyLoginOptions? deviceBoundKeyOptions;

    if (optionsData != null && optionsData is Map<String, dynamic>) {
      // Determine method type
      final methodLower = method.toLowerCase();

      if (methodLower == 'webauthn' || methodLower == 'passkey') {
        try {
          webauthnOptions = WebAuthnLoginOptions.fromJson(optionsData);
        } catch (e) {
          webauthnOptions = null;
        }
      } else if (methodLower == 'device-bound-key' ||
          methodLower == 'deviceboundkey') {
        try {
          deviceBoundKeyOptions = DeviceBoundKeyLoginOptions.fromJson(
            optionsData,
          );
        } catch (e) {
          deviceBoundKeyOptions = null;
        }
      }
    }

    return ResearcherLoginInitiateResponse(
      method: method,
      webauthnOptions: webauthnOptions,
      deviceBoundKeyOptions: deviceBoundKeyOptions,
      cookie: json['cookie'] ?? data?['cookie'],
    );
  }
}
