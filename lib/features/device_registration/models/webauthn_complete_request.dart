class WebAuthnCompleteRequest {
  final String token;
  final Map<String, dynamic> credentials;

  const WebAuthnCompleteRequest({
    required this.token,
    required this.credentials,
  });

  Map<String, dynamic> toJson() => {
        'credentials': credentials,
      };
}

