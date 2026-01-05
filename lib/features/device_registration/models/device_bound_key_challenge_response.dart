class DeviceBoundKeyChallengeResponse {
  final String challenge;
  final String? cookie;

  DeviceBoundKeyChallengeResponse({
    required this.challenge,
    this.cookie,
  });

  factory DeviceBoundKeyChallengeResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return DeviceBoundKeyChallengeResponse(
      challenge: data['challenge'] as String,
      cookie: data['cookie'] as String?,
    );
  }
}

