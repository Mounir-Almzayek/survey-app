import 'webauthn_login_options.dart';

class ResearcherLoginInitiateResponse {
  final String method;
  final WebAuthnLoginOptions? options;
  final String? cookie;

  ResearcherLoginInitiateResponse({
    required this.method,
    this.options,
    this.cookie,
  });

  factory ResearcherLoginInitiateResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final method = json['method'] ?? data?['method'] ?? '';
    final optionsData = json['options'] ?? data?['options'];

    WebAuthnLoginOptions? options;
    if (optionsData != null && optionsData is Map<String, dynamic>) {
      try {
        options = WebAuthnLoginOptions.fromJson(optionsData);
      } catch (e) {
        // If parsing fails, options will remain null
        options = null;
      }
    }

    return ResearcherLoginInitiateResponse(
      method: method,
      options: options,
      cookie: json['cookie'] ?? data?['cookie'],
    );
  }
}
