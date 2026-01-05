/// Device-Bound Key options for login/authentication
class DeviceBoundKeyLoginOptions {
  final String challenge;
  final String? keyId;

  const DeviceBoundKeyLoginOptions({
    required this.challenge,
    this.keyId,
  });

  factory DeviceBoundKeyLoginOptions.fromJson(Map<String, dynamic> json) {
    return DeviceBoundKeyLoginOptions(
      challenge: json['challenge'] as String,
      keyId: json['keyId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'challenge': challenge,
      if (keyId != null) 'keyId': keyId,
    };
  }
}

