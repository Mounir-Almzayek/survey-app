import '../../../../core/models/fingerprint.dart';

abstract class ResearcherLoginBaseRequest {
  final String email;
  final String password;
  final String os;
  final String browser;
  final String deviceToken;
  final Fingerprint fingerprint;

  ResearcherLoginBaseRequest({
    required this.email,
    required this.password,
    required this.os,
    required this.browser,
    required this.deviceToken,
    required this.fingerprint,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'os': os,
    'browser': browser,
    'device_token': deviceToken,
    'fingerprint': fingerprint.toJson(),
  };
}
