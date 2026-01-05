class DeviceBoundKeyCompleteRequest {
  final String token;
  final String publicKey;
  final String keyId;
  final String deviceId;
  final String signature;

  DeviceBoundKeyCompleteRequest({
    required this.token,
    required this.publicKey,
    required this.keyId,
    required this.deviceId,
    required this.signature,
  });

  Map<String, dynamic> toJson() {
    return {
      'publicKey': publicKey,
      'keyId': keyId,
      'deviceId': deviceId,
      'signature': signature,
    };
  }
}

