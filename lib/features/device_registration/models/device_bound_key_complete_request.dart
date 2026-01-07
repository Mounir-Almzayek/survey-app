class DeviceBoundKeyCompleteRequest {
  final String token;
  final String publicKey;
  final String keyId;
  final String signature;
  final String algorithm;
  final Attestation? attestation;

  DeviceBoundKeyCompleteRequest({
    required this.token,
    required this.publicKey,
    required this.keyId,
    required this.signature,
    this.algorithm = 'ES256',
    this.attestation,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'publicKey': publicKey,
      'keyId': keyId,
      'signature': signature,
      'algorithm': algorithm,
    };
    if (attestation != null) {
      json['attestation'] = attestation!.toJson();
    }
    return json;
  }
}

class Attestation {
  final List<String> certificateChain;

  Attestation({required this.certificateChain});

  Map<String, dynamic> toJson() {
    return {'certificateChain': certificateChain};
  }
}
