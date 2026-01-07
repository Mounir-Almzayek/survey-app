import '../../../core/models/fingerprint.dart';

class DeviceBoundKeyChallengeRequest {
  final String token;
  final String os;
  final Fingerprint fingerprint;

  DeviceBoundKeyChallengeRequest({
    required this.token,
    required this.os,
    required this.fingerprint,
  });

  Map<String, dynamic> toJson() {
    return {'os': os, 'fingerprint': fingerprint.toJson()};
  }
}
