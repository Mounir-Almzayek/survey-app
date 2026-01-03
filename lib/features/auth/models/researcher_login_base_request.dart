import 'researcher_login_fingerprint.dart';

abstract class ResearcherLoginBaseRequest {
  final String email;
  final String password;
  final String os;
  final String browser;
  final ResearcherLoginFingerprint fingerprint;

  ResearcherLoginBaseRequest({
    required this.email,
    required this.password,
    required this.os,
    required this.browser,
    required this.fingerprint,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'os': os,
    'browser': browser,
    'fingerprint': fingerprint.toJson(),
  };
}
