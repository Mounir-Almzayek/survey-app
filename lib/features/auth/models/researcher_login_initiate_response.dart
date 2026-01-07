import 'device_bound_key_login_options.dart';

/// Login method types
enum LoginMethod { deviceBoundKey, cookieBased }

class ResearcherLoginInitiateResponse {
  final String method;
  final DeviceBoundKeyLoginOptions? deviceBoundKeyOptions;
  final String? cookie;

  ResearcherLoginInitiateResponse({
    required this.method,
    this.deviceBoundKeyOptions,
    this.cookie,
  });

  /// Get login method enum
  LoginMethod get loginMethod {
    switch (method.toLowerCase()) {
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
      case LoginMethod.deviceBoundKey:
        return deviceBoundKeyOptions;
      default:
        return null;
    }
  }

  factory ResearcherLoginInitiateResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    String method = json['method'] ?? data['method'] ?? '';
    final optionsData = json['options'] ?? data['options'];

    DeviceBoundKeyLoginOptions? deviceBoundKeyOptions;

    if (optionsData != null && optionsData is Map<String, dynamic>) {
      // Determine method type
      final methodLower = method.toLowerCase();

      if (methodLower == 'device-bound-key' ||
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

    // Fallback for researcher-login device-bound-key flow:
    // Backend returns only { success, data: { challenge: "..." } }
    // In this case, treat it as device-bound-key login with simple options.
    if ((method.isEmpty) && deviceBoundKeyOptions == null) {
      final challenge = data['challenge'];
      if (challenge is String && challenge.isNotEmpty) {
        method = 'device-bound-key';
        deviceBoundKeyOptions = DeviceBoundKeyLoginOptions(
          challenge: challenge,
          keyId: null,
        );
      }
    }

    return ResearcherLoginInitiateResponse(
      method: method,
      deviceBoundKeyOptions: deviceBoundKeyOptions,
      cookie: json['cookie'] ?? data['cookie'],
    );
  }
}
