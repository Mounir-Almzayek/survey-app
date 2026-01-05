import '../../../core/models/fingerprint.dart';

class DeviceBoundKeyChallengeRequest {
  final String token;
  final String browser;
  final String os;
  final Fingerprint fingerprint;

  DeviceBoundKeyChallengeRequest({
    required this.token,
    required this.browser,
    required this.os,
    required this.fingerprint,
  });

  Map<String, dynamic> toJson() {
    return {'browser': browser, 'os': os, 'fingerprint': fingerprint.toJson()};
  }
}
